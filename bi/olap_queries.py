"""
Módulo OLAP (Online Analytical Processing)
Consultas multidimensionales para análisis
"""
import psycopg2
from datetime import datetime, timedelta
import json

class OLAPAnalyzer:
    """Analizador OLAP para consultas multidimensionales"""
    
    def __init__(self, db_connection):
        self.conn = db_connection
    
    def drill_down(self, nivel_inicial='mes', nivel_detalle='dia', tipo_planta=None, fecha_inicio=None, fecha_fin=None):
        """
        Operación OLAP: Drill-Down
        Desglosar datos de un nivel agregado a uno más detallado
        """
        cursor = self.conn.cursor()
        
        try:
            # Construir query según nivel
            nivel_map = {
                'año': 'dt.año',
                'trimestre': 'dt.trimestre',
                'mes': 'dt.mes',
                'semana': 'dt.semana',
                'dia': 'dt.fecha'
            }
            
            nivel_col = nivel_map.get(nivel_detalle, 'dt.fecha')
            
            query = f"""
                SELECT 
                    {nivel_col} as nivel,
                    dp.tipo_planta,
                    COUNT(*) as total_mediciones,
                    AVG(fm.temperatura) as temp_promedio,
                    AVG(fm.humedad) as humedad_promedio,
                    AVG(fm.ph) as ph_promedio,
                    MIN(fm.temperatura) as temp_min,
                    MAX(fm.temperatura) as temp_max
                FROM fact_mediciones fm
                JOIN dim_tiempo dt ON fm.tiempo_id = dt.tiempo_id
                JOIN dim_planta dp ON fm.planta_id = dp.planta_id
                WHERE 1=1
            """
            
            params = []
            
            if fecha_inicio:
                query += " AND dt.fecha >= %s"
                params.append(fecha_inicio)
            
            if fecha_fin:
                query += " AND dt.fecha <= %s"
                params.append(fecha_fin)
            
            if tipo_planta:
                query += " AND dp.tipo_planta = %s"
                params.append(tipo_planta)
            
            query += f" GROUP BY {nivel_col}, dp.tipo_planta ORDER BY {nivel_col}"
            
            cursor.execute(query, params)
            results = cursor.fetchall()
            
            return [{
                'nivel': str(row[0]),
                'tipo_planta': row[1],
                'total_mediciones': row[2],
                'temp_promedio': float(row[3]) if row[3] else 0,
                'humedad_promedio': float(row[4]) if row[4] else 0,
                'ph_promedio': float(row[5]) if row[5] else 0,
                'temp_min': float(row[6]) if row[6] else 0,
                'temp_max': float(row[7]) if row[7] else 0
            } for row in results]
            
        except Exception as e:
            print(f"❌ Error en drill-down: {e}")
            return []
        finally:
            cursor.close()
    
    def roll_up(self, nivel_detalle='dia', nivel_agregado='mes', tipo_planta=None):
        """
        Operación OLAP: Roll-Up
        Agregar datos de un nivel detallado a uno más general
        """
        return self.drill_down(nivel_detalle, nivel_agregado, tipo_planta)
    
    def slice(self, dimension, valor, fecha_inicio=None, fecha_fin=None):
        """
        Operación OLAP: Slice
        Seleccionar un subcubo fijando una dimensión
        """
        cursor = self.conn.cursor()
        
        try:
            query = """
                SELECT 
                    dt.fecha,
                    dp.tipo_planta,
                    AVG(fm.temperatura) as temp_promedio,
                    AVG(fm.humedad) as humedad_promedio,
                    COUNT(*) as total_mediciones
                FROM fact_mediciones fm
                JOIN dim_tiempo dt ON fm.tiempo_id = dt.tiempo_id
                JOIN dim_planta dp ON fm.planta_id = dp.planta_id
                WHERE 1=1
            """
            
            params = []
            
            if dimension == 'tipo_planta':
                query += " AND dp.tipo_planta = %s"
                params.append(valor)
            elif dimension == 'año':
                query += " AND dt.año = %s"
                params.append(valor)
            elif dimension == 'mes':
                query += " AND dt.mes = %s"
                params.append(valor)
            
            if fecha_inicio:
                query += " AND dt.fecha >= %s"
                params.append(fecha_inicio)
            
            if fecha_fin:
                query += " AND dt.fecha <= %s"
                params.append(fecha_fin)
            
            query += " GROUP BY dt.fecha, dp.tipo_planta ORDER BY dt.fecha"
            
            cursor.execute(query, params)
            results = cursor.fetchall()
            
            return [{
                'fecha': row[0].isoformat() if hasattr(row[0], 'isoformat') else str(row[0]),
                'tipo_planta': row[1],
                'temp_promedio': float(row[2]) if row[2] else 0,
                'humedad_promedio': float(row[3]) if row[3] else 0,
                'total_mediciones': row[4]
            } for row in results]
            
        except Exception as e:
            print(f"❌ Error en slice: {e}")
            return []
        finally:
            cursor.close()
    
    def dice(self, dimensiones, valores, fecha_inicio=None, fecha_fin=None):
        """
        Operación OLAP: Dice
        Seleccionar un subcubo fijando múltiples dimensiones
        """
        cursor = self.conn.cursor()
        
        try:
            query = """
                SELECT 
                    dt.fecha,
                    dp.tipo_planta,
                    ds.tipo_sensor,
                    AVG(fm.temperatura) as temp_promedio,
                    AVG(fm.humedad) as humedad_promedio,
                    AVG(fm.ph) as ph_promedio,
                    COUNT(*) as total_mediciones
                FROM fact_mediciones fm
                JOIN dim_tiempo dt ON fm.tiempo_id = dt.tiempo_id
                JOIN dim_planta dp ON fm.planta_id = dp.planta_id
                JOIN dim_sensor ds ON fm.sensor_id_dim = ds.sensor_id_dim
                WHERE 1=1
            """
            
            params = []
            
            for i, dim in enumerate(dimensiones):
                if dim == 'tipo_planta' and i < len(valores):
                    query += " AND dp.tipo_planta = %s"
                    params.append(valores[i])
                elif dim == 'tipo_sensor' and i < len(valores):
                    query += " AND ds.tipo_sensor = %s"
                    params.append(valores[i])
            
            if fecha_inicio:
                query += " AND dt.fecha >= %s"
                params.append(fecha_inicio)
            
            if fecha_fin:
                query += " AND dt.fecha <= %s"
                params.append(fecha_fin)
            
            query += " GROUP BY dt.fecha, dp.tipo_planta, ds.tipo_sensor ORDER BY dt.fecha"
            
            cursor.execute(query, params)
            results = cursor.fetchall()
            
            return [{
                'fecha': row[0].isoformat() if hasattr(row[0], 'isoformat') else str(row[0]),
                'tipo_planta': row[1],
                'tipo_sensor': row[2],
                'temp_promedio': float(row[3]) if row[3] else 0,
                'humedad_promedio': float(row[4]) if row[4] else 0,
                'ph_promedio': float(row[5]) if row[5] else 0,
                'total_mediciones': row[6]
            } for row in results]
            
        except Exception as e:
            print(f"❌ Error en dice: {e}")
            return []
        finally:
            cursor.close()
    
    def pivot(self, dimension_filas, dimension_columnas, medida='temperatura', fecha_inicio=None, fecha_fin=None):
        """
        Operación OLAP: Pivot
        Rotar el cubo para ver datos desde otra perspectiva
        """
        cursor = self.conn.cursor()
        
        try:
            medida_map = {
                'temperatura': 'AVG(fm.temperatura)',
                'humedad': 'AVG(fm.humedad)',
                'ph': 'AVG(fm.ph)',
                'nutrientes': 'AVG(fm.nivel_nutrientes)'
            }
            
            medida_sql = medida_map.get(medida, 'AVG(fm.temperatura)')
            
            if dimension_filas == 'fecha' and dimension_columnas == 'tipo_planta':
                query = f"""
                    SELECT 
                        dt.fecha as fila,
                        dp.tipo_planta as columna,
                        {medida_sql} as valor
                    FROM fact_mediciones fm
                    JOIN dim_tiempo dt ON fm.tiempo_id = dt.tiempo_id
                    JOIN dim_planta dp ON fm.planta_id = dp.planta_id
                    WHERE 1=1
                """
                
                params = []
                
                if fecha_inicio:
                    query += " AND dt.fecha >= %s"
                    params.append(fecha_inicio)
                
                if fecha_fin:
                    query += " AND dt.fecha <= %s"
                    params.append(fecha_fin)
                
                query += " GROUP BY dt.fecha, dp.tipo_planta ORDER BY dt.fecha, dp.tipo_planta"
                
                cursor.execute(query, params)
                results = cursor.fetchall()
                
                # Formatear como tabla pivot
                pivot_table = {}
                for row in results:
                    fila = row[0].isoformat() if hasattr(row[0], 'isoformat') else str(row[0])
                    columna = row[1]
                    valor = float(row[2]) if row[2] else 0
                    
                    if fila not in pivot_table:
                        pivot_table[fila] = {}
                    pivot_table[fila][columna] = valor
                
                return pivot_table
            
        except Exception as e:
            print(f"❌ Error en pivot: {e}")
            return {}
        finally:
            cursor.close()
    
    def analisis_multidimensional_completo(self):
        """Análisis multidimensional completo usando todas las operaciones OLAP"""
        fecha_inicio = (datetime.now() - timedelta(days=30)).date()
        fecha_fin = datetime.now().date()
        
        resultados = {
            'drill_down_mes_dia': self.drill_down('mes', 'dia', fecha_inicio=fecha_inicio, fecha_fin=fecha_fin),
            'slice_rabano': self.slice('tipo_planta', 'rabano', fecha_inicio=fecha_inicio, fecha_fin=fecha_fin),
            'pivot_temp': self.pivot('fecha', 'tipo_planta', 'temperatura', fecha_inicio=fecha_inicio, fecha_fin=fecha_fin),
            'roll_up_semana_mes': self.roll_up('semana', 'mes')
        }
        
        return resultados

