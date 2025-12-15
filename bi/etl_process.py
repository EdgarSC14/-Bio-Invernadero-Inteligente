"""
Módulo ETL (Extract, Transform, Load)
Procesos estructurados para poblar el Data Warehouse
"""
import psycopg2
from datetime import datetime, timedelta
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ETLProcessor:
    """Procesador ETL para Data Warehouse"""
    
    def __init__(self, db_connection):
        self.conn = db_connection
    
    def extract_from_source(self):
        """ETL: Extracción - Obtener datos de las tablas operacionales"""
        cursor = self.conn.cursor()
        
        try:
            # Extraer datos de sensores
            cursor.execute("""
                SELECT 
                    sd.id,
                    sd.sensor_id,
                    sd.temperature,
                    sd.humidity,
                    sd.soil_moisture,
                    sd.nutrient_level,
                    sd.ph_level,
                    sd.light_intensity,
                    sd.co2_level,
                    sd.timestamp,
                    pl.plant_id,
                    pl.plant_type,
                    pl.status
                FROM sensor_data sd
                LEFT JOIN plants pl ON sd.sensor_id LIKE '%' || pl.plant_type || '%'
                WHERE sd.timestamp >= NOW() - INTERVAL '30 days'
                ORDER BY sd.timestamp
            """)
            
            sensor_data = cursor.fetchall()
            
            # Extraer predicciones
            cursor.execute("""
                SELECT 
                    p.prediction_id,
                    p.plant_id,
                    p.predicted_yield,
                    p.confidence,
                    p.prediction_date,
                    pl.plant_type,
                    pl.status
                FROM predictions p
                JOIN plants pl ON p.plant_id = pl.plant_id
                WHERE p.prediction_date >= NOW() - INTERVAL '30 days'
                ORDER BY p.prediction_date
            """)
            
            predictions_data = cursor.fetchall()
            
            logger.info(f"✅ Extraídos {len(sensor_data)} registros de sensores")
            logger.info(f"✅ Extraídos {len(predictions_data)} predicciones")
            
            return {
                'sensor_data': sensor_data,
                'predictions_data': predictions_data
            }
            
        except Exception as e:
            logger.error(f"❌ Error en extracción: {e}")
            return None
        finally:
            cursor.close()
    
    def transform_data(self, raw_data):
        """ETL: Transformación - Limpiar y transformar datos"""
        if not raw_data:
            return None
        
        cursor = self.conn.cursor()
        
        try:
            transformed = {
                'mediciones': [],
                'predicciones': []
            }
            
            # Transformar datos de sensores
            for row in raw_data['sensor_data']:
                (id, sensor_id, temp, hum, soil, nutrients, ph, light, co2, 
                 timestamp, plant_id, plant_type, status) = row
                
                # Validar datos
                if temp is None or hum is None:
                    continue
                
                # Normalizar valores
                temp = max(0, min(50, float(temp) if temp else 22.0))
                hum = max(0, min(100, float(hum) if hum else 65.0))
                ph = max(0, min(14, float(ph) if ph else 6.5))
                
                # Obtener IDs de dimensiones
                tiempo_id = self.get_or_create_tiempo_id(timestamp)
                planta_id = self.get_or_create_planta_id(plant_id, plant_type, status)
                sensor_id_dim = self.get_or_create_sensor_id(sensor_id)
                ubicacion_id = self.get_or_create_ubicacion_id(sensor_id)
                
                # Solo agregar si todos los IDs son válidos
                if tiempo_id is None or planta_id is None or sensor_id_dim is None or ubicacion_id is None:
                    logger.warning(f"⚠️ Saltando medición por IDs inválidos: tiempo_id={tiempo_id}, planta_id={planta_id}, sensor_id={sensor_id_dim}, ubicacion_id={ubicacion_id}")
                    continue
                
                transformed['mediciones'].append({
                    'tiempo_id': tiempo_id,
                    'planta_id': planta_id,
                    'sensor_id_dim': sensor_id_dim,
                    'ubicacion_id': ubicacion_id,
                    'temperatura': temp,
                    'humedad': hum,
                    'humedad_suelo': float(soil) if soil else 70.0,
                    'nivel_nutrientes': float(nutrients) if nutrients else 1.7,
                    'ph': ph,
                    'intensidad_luz': float(light) if light else 1000.0,
                    'co2': float(co2) if co2 else 450.0,
                    'timestamp_original': timestamp
                })
            
            # Transformar predicciones
            for row in raw_data['predictions_data']:
                (pred_id, plant_id, yield_val, confidence, pred_date, 
                 plant_type, status) = row
                
                if yield_val is None or confidence is None:
                    continue
                
                # Obtener IDs de dimensiones
                tiempo_id = self.get_or_create_tiempo_id(pred_date)
                planta_id = self.get_or_create_planta_id(plant_id, plant_type, status)
                
                # Solo agregar si todos los IDs son válidos
                if tiempo_id is None or planta_id is None:
                    logger.warning(f"⚠️ Saltando predicción por IDs inválidos: tiempo_id={tiempo_id}, planta_id={planta_id}")
                    continue
                
                # Calcular promedios del período
                promedios = self.calcular_promedios_periodo(plant_id, pred_date)
                
                transformed['predicciones'].append({
                    'tiempo_id': tiempo_id,
                    'planta_id': planta_id,
                    'rendimiento_previsto': float(yield_val),
                    'confianza': float(confidence),
                    'temperatura_promedio_periodo': promedios.get('temp', 22.0),
                    'humedad_promedio_periodo': promedios.get('hum', 65.0),
                    'ph_promedio_periodo': promedios.get('ph', 6.5),
                    'nutrientes_promedio_periodo': promedios.get('nutrients', 1.7),
                    'modelo_utilizado': 'RandomForest',
                    'timestamp_original': pred_date
                })
            
            logger.info(f"✅ Transformados {len(transformed['mediciones'])} mediciones")
            logger.info(f"✅ Transformados {len(transformed['predicciones'])} predicciones")
            
            return transformed
            
        except Exception as e:
            logger.error(f"❌ Error en transformación: {e}")
            import traceback
            logger.error(traceback.format_exc())
            # Hacer rollback de la transacción si hay error
            try:
                self.conn.rollback()
            except:
                pass
            return None
        finally:
            cursor.close()
    
    def load_to_dw(self, transformed_data):
        """ETL: Carga - Insertar datos en Data Warehouse"""
        if not transformed_data:
            return False
        
        cursor = self.conn.cursor()
        
        try:
            # Cargar mediciones
            for med in transformed_data['mediciones']:
                cursor.execute("""
                    INSERT INTO fact_mediciones (
                        tiempo_id, planta_id, sensor_id_dim, ubicacion_id,
                        temperatura, humedad, humedad_suelo, nivel_nutrientes,
                        ph, intensidad_luz, co2, timestamp_original, calidad_dato
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 1)
                    ON CONFLICT DO NOTHING
                """, (
                    med['tiempo_id'], med['planta_id'], med['sensor_id_dim'],
                    med['ubicacion_id'], med['temperatura'], med['humedad'],
                    med['humedad_suelo'], med['nivel_nutrientes'], med['ph'],
                    med['intensidad_luz'], med['co2'], med['timestamp_original']
                ))
            
            # Cargar predicciones
            for pred in transformed_data['predicciones']:
                cursor.execute("""
                    INSERT INTO fact_predicciones (
                        tiempo_id, planta_id, rendimiento_previsto, confianza,
                        temperatura_promedio_periodo, humedad_promedio_periodo,
                        ph_promedio_periodo, nutrientes_promedio_periodo,
                        modelo_utilizado, timestamp_original
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT DO NOTHING
                """, (
                    pred['tiempo_id'], pred['planta_id'], pred['rendimiento_previsto'],
                    pred['confianza'], pred['temperatura_promedio_periodo'],
                    pred['humedad_promedio_periodo'], pred['ph_promedio_periodo'],
                    pred['nutrientes_promedio_periodo'], pred['modelo_utilizado'],
                    pred['timestamp_original']
                ))
            
            self.conn.commit()
            logger.info("✅ Datos cargados en Data Warehouse")
            
            # Actualizar vistas materializadas
            self.refresh_materialized_views()
            
            return True
            
        except Exception as e:
            logger.error(f"❌ Error en carga: {e}")
            self.conn.rollback()
            return False
        finally:
            cursor.close()
    
    def execute_etl(self):
        """Ejecutar proceso ETL completo"""
        logger.info("🔄 Iniciando proceso ETL...")
        
        # Extract
        raw_data = self.extract_from_source()
        if not raw_data:
            return False
        
        # Transform
        transformed_data = self.transform_data(raw_data)
        if not transformed_data:
            return False
        
        # Load
        success = self.load_to_dw(transformed_data)
        
        if success:
            logger.info("✅ Proceso ETL completado exitosamente")
        else:
            logger.error("❌ Error en proceso ETL")
        
        return success
    
    # Funciones auxiliares
    def get_or_create_tiempo_id(self, timestamp):
        """Obtener o crear ID de dimensión tiempo"""
        cursor = self.conn.cursor()
        fecha = timestamp.date() if hasattr(timestamp, 'date') else timestamp
        hora = timestamp.hour if hasattr(timestamp, 'hour') else 0
        minuto = timestamp.minute if hasattr(timestamp, 'minute') else 0
        
        try:
            # Primero intentar buscar si ya existe con fecha, hora y minuto exactos
            cursor.execute("""
                SELECT tiempo_id FROM dim_tiempo
                WHERE fecha = %s AND hora = %s AND minuto = %s
            """, (fecha, hora, minuto))
            
            result = cursor.fetchone()
            if result:
                return result[0]
            
            # Si no existe, buscar solo por fecha (debido a la restricción dim_tiempo_fecha_key)
            # que solo permite una entrada por fecha
            cursor.execute("""
                SELECT tiempo_id FROM dim_tiempo
                WHERE fecha = %s
                ORDER BY hora DESC, minuto DESC
                LIMIT 1
            """, (fecha,))
            
            result = cursor.fetchone()
            if result:
                # Ya existe una entrada para esta fecha, usar esa
                return result[0]
            
            # Si no existe ninguna entrada para esta fecha, intentar insertar
            # Nota: La restricción dim_tiempo_fecha_key solo permite una entrada por fecha
            # así que si ya existe una, usamos esa. Si no existe, creamos una nueva.
            try:
                cursor.execute("""
                    INSERT INTO dim_tiempo (
                        fecha, año, trimestre, mes, semana, dia_semana,
                        nombre_dia, es_fin_semana, hora, minuto, timestamp_completo
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (fecha) DO UPDATE SET
                        hora = EXCLUDED.hora,
                        minuto = EXCLUDED.minuto,
                        timestamp_completo = EXCLUDED.timestamp_completo
                    RETURNING tiempo_id
                """, (
                    fecha,
                    fecha.year,
                    (fecha.month - 1) // 3 + 1,
                    fecha.month,
                    fecha.isocalendar()[1],
                    fecha.weekday(),
                    fecha.strftime('%A'),
                    fecha.weekday() >= 5,
                    hora, minuto, timestamp
                ))
                
                result = cursor.fetchone()
                if result:
                    return result[0]
                
                # Si no retornó resultado, buscar de nuevo
                cursor.execute("""
                    SELECT tiempo_id FROM dim_tiempo
                    WHERE fecha = %s
                    LIMIT 1
                """, (fecha,))
                
                result = cursor.fetchone()
                if result:
                    return result[0]
                    
            except Exception as e:
                # Si falla, hacer rollback y buscar la entrada existente
                logger.warning(f"⚠️ Conflicto al insertar tiempo, buscando existente: {e}")
                try:
                    self.conn.rollback()
                except:
                    pass
                
                # Buscar por fecha
                cursor.execute("""
                    SELECT tiempo_id FROM dim_tiempo
                    WHERE fecha = %s
                    LIMIT 1
                """, (fecha,))
                
                result = cursor.fetchone()
                if result:
                    return result[0]
            
            # Si todo falla, retornar None
            logger.warning(f"⚠️ No se pudo obtener o crear tiempo_id para {fecha} {hora}:{minuto}")
            return None
        except Exception as e:
            logger.error(f"❌ Error en get_or_create_tiempo_id: {e}")
            try:
                self.conn.rollback()
            except:
                pass
            # Último intento: buscar solo por fecha
            try:
                cursor.execute("""
                    SELECT tiempo_id FROM dim_tiempo
                    WHERE fecha = %s
                    LIMIT 1
                """, (fecha,))
                result = cursor.fetchone()
                if result:
                    return result[0]
            except:
                pass
            return None
        finally:
            cursor.close()
    
    def get_or_create_planta_id(self, plant_id, plant_type, status):
        """Obtener o crear ID de dimensión planta"""
        cursor = self.conn.cursor()
        
        try:
            cursor.execute("""
                SELECT planta_id FROM dim_planta WHERE plant_id = %s
            """, (plant_id,))
            
            result = cursor.fetchone()
            if result:
                return result[0]
            
            cursor.execute("""
                INSERT INTO dim_planta (plant_id, tipo_planta, estado)
                VALUES (%s, %s, %s)
                RETURNING planta_id
            """, (plant_id, plant_type or 'desconocido', status or 'active'))
            
            return cursor.fetchone()[0]
        finally:
            cursor.close()
    
    def get_or_create_sensor_id(self, sensor_id):
        """Obtener o crear ID de dimensión sensor"""
        cursor = self.conn.cursor()
        
        try:
            cursor.execute("""
                SELECT sensor_id_dim FROM dim_sensor WHERE sensor_id = %s
            """, (sensor_id,))
            
            result = cursor.fetchone()
            if result:
                return result[0]
            
            cursor.execute("""
                INSERT INTO dim_sensor (sensor_id, tipo_sensor, estado)
                VALUES (%s, %s, %s)
                RETURNING sensor_id_dim
            """, (sensor_id, 'sensor_ambiental', 'activo'))
            
            return cursor.fetchone()[0]
        finally:
            cursor.close()
    
    def get_or_create_ubicacion_id(self, sensor_id):
        """Obtener o crear ID de dimensión ubicación"""
        cursor = self.conn.cursor()
        
        try:
            # Por defecto, ubicación 1
            cursor.execute("SELECT ubicacion_id FROM dim_ubicacion LIMIT 1")
            result = cursor.fetchone()
            
            if result:
                return result[0]
            
            cursor.execute("""
                INSERT INTO dim_ubicacion (invernadero, sector)
                VALUES (%s, %s)
                RETURNING ubicacion_id
            """, ('invernadero_principal', 'sector_a'))
            
            return cursor.fetchone()[0]
        finally:
            cursor.close()
    
    def calcular_promedios_periodo(self, plant_id, fecha):
        """Calcular promedios del período previo"""
        cursor = self.conn.cursor()
        
        try:
            cursor.execute("""
                SELECT 
                    AVG(temperature) as temp,
                    AVG(humidity) as hum,
                    AVG(ph_level) as ph,
                    AVG(nutrient_level) as nutrients
                FROM sensor_data
                WHERE timestamp >= %s - INTERVAL '7 days'
                AND timestamp < %s
                AND sensor_id LIKE (SELECT plant_type FROM plants WHERE plant_id = %s)
            """, (fecha, fecha, plant_id))
            
            result = cursor.fetchone()
            return {
                'temp': float(result[0]) if result[0] else 22.0,
                'hum': float(result[1]) if result[1] else 65.0,
                'ph': float(result[2]) if result[2] else 6.5,
                'nutrients': float(result[3]) if result[3] else 1.7
            }
        finally:
            cursor.close()
    
    def refresh_materialized_views(self):
        """Actualizar vistas materializadas"""
        cursor = self.conn.cursor()
        
        try:
            cursor.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY mv_mediciones_dia_planta")
            cursor.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY mv_predicciones_semana_planta")
            self.conn.commit()
            logger.info("✅ Vistas materializadas actualizadas")
        except Exception as e:
            logger.warning(f"⚠️ Error actualizando vistas: {e}")
        finally:
            cursor.close()

