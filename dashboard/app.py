# dashboard/app.py
import sys
import os

# Agregar el directorio raíz del proyecto al path de Python
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from flask import Flask, jsonify, render_template, request, send_file
import psycopg2
from datetime import datetime, timedelta
import csv
import io
import serial
import threading
import time
import json
import requests
from config.config import Config

app = Flask(__name__)

def get_db_connection():
    """Conectar a la base de datos invernadero_bio"""
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="invernadero_bio",
            user="edgar",
            password="12345",
            port="5432"
        )
        return conn
    except Exception as e:
        print(f"Error de conexión: {e}")
        return None

def inicializar_base_datos():
    """Inicializar la base de datos si no existe"""
    conn = get_db_connection()
    if not conn:
        print("❌ No se pudo conectar a la base de datos")
        return False
    
    cursor = conn.cursor()
    try:
        # Crear tablas si no existen
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS plants (
                plant_id SERIAL PRIMARY KEY,
                plant_type VARCHAR(50),
                planting_date TIMESTAMP,
                status VARCHAR(20)
            )
        """)
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS sensor_data (
                id SERIAL PRIMARY KEY,
                sensor_id VARCHAR(50),
                temperature DECIMAL(5,2),
                humidity DECIMAL(5,2),
                soil_moisture DECIMAL(5,2),
                nutrient_level DECIMAL(5,2),
                ph_level DECIMAL(4,2),
                light_intensity DECIMAL(8,2),
                co2_level DECIMAL(6,2),
                timestamp TIMESTAMP
            )
        """)
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS predictions (
                prediction_id SERIAL PRIMARY KEY,
                plant_id INTEGER,
                predicted_yield DECIMAL(8,2),
                prediction_date TIMESTAMP,
                confidence DECIMAL(4,3)
            )
        """)
        
        # Insertar plantas de ejemplo si no existen
        cursor.execute("SELECT COUNT(*) FROM plants")
        if cursor.fetchone()[0] == 0:
            plantas = [
                ('rabano', 'active'),
                ('rabano', 'active'), 
                ('cilantro', 'active'),
                ('cilantro', 'active'),
                ('rabano', 'active'),
                ('cilantro', 'active')
            ]
            for tipo_planta, estado in plantas:
                cursor.execute(
                    "INSERT INTO plants (plant_type, planting_date, status) VALUES (%s, %s, %s)",
                    (tipo_planta, datetime.now() - timedelta(days=10), estado)
                )
            print("✅ 6 plantas de ejemplo creadas (3 rábanos, 3 cilantros)")
        
        conn.commit()
        print("✅ Base de datos inicializada correctamente")
        return True
        
    except Exception as e:
        print(f"❌ Error inicializando base de datos: {e}")
        conn.rollback()
        return False
    finally:
        cursor.close()
        conn.close()

def start_serial_monitor():
    """Hilo para leer datos del Arduino por puerto serial COM7"""
    def monitor():
        serial_connected = False
        ser = None
        
        while True:
            try:
                if not serial_connected:
                    print("🔌 Intentando conectar con Arduino en COM7...")
                    # Intentar conectar con timeout
                    ser = serial.Serial('COM7', 9600, timeout=1)
                    serial_connected = True
                    print("✅ Conectado a Arduino en COM7")
                    print("📡 Esperando datos...")
                
                # Leer datos si hay conexión
                if serial_connected and ser.in_waiting > 0:
                    line = ser.readline().decode('utf-8', errors='ignore').strip()
                    
                    if line and line.startswith('{'):
                        try:
                            data = json.loads(line)
                            print(f"📊 Datos recibidos del Arduino: {data}")
                            
                            # Enviar datos a la API Flask
                            response = requests.post(
                                'http://localhost:5000/api/sensor/real',
                                json=data,
                                timeout=5
                            )
                            
                            if response.status_code == 200:
                                print(f"✅ Datos enviados a PostgreSQL - Temp: {data['temperature']}°C, Hum: {data['humidity']}%")
                            else:
                                print(f"❌ Error API: {response.status_code}")
                                
                        except json.JSONDecodeError:
                            print(f"❌ JSON inválido: {line}")
                        except Exception as e:
                            print(f"❌ Error procesando datos: {e}")
                    elif line:
                        print(f"📡 Arduino: {line}")
                
                # Pequeña pausa para no saturar
                time.sleep(0.1)
                    
            except serial.SerialException as e:
                if serial_connected:
                    print(f"❌ Error de conexión serial: {e}")
                    serial_connected = False
                    if ser:
                        ser.close()
                else:
                    print(f"⏳ No se puede conectar a COM7, reintentando en 5s...")
                
                time.sleep(5)
                
            except Exception as e:
                print(f"❌ Error inesperado: {e}")
                serial_connected = False
                if ser and ser.is_open:
                    ser.close()
                time.sleep(5)
    
    # Iniciar hilo
    thread = threading.Thread(target=monitor)
    thread.daemon = True
    thread.start()
    print("🚀 Monitor serial iniciado (se conectará automáticamente)")

# ===== RUTAS PRINCIPALES =====
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/monitor')
def monitor():
    return render_template('monitor.html')

@app.route('/predicciones')
def predicciones():
    return render_template('predicciones.html')

@app.route('/analytics')
def analytics():
    return render_template('dashboard_avanzado.html')

@app.route('/reportes')
def reportes():
    today = datetime.now().strftime('%Y-%m-%d')
    return render_template('reportes.html', today=today)

# ===== APIs PARA DATOS REALES =====
@app.route('/api/sensor/real', methods=['POST'])
def api_sensor_real():
    """API para recibir datos de sensores reales"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No JSON data received'}), 400
        
        # Validar datos requeridos
        required_fields = ['sensor_id', 'temperature', 'humidity']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing field: {field}'}), 400
        
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = conn.cursor()
        
        try:
            # Insertar datos en la base de datos
            cursor.execute("""
                INSERT INTO sensor_data 
                (sensor_id, temperature, humidity, soil_moisture, nutrient_level, 
                 ph_level, light_intensity, co2_level, timestamp)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                data['sensor_id'],
                float(data['temperature']),
                float(data['humidity']),
                float(data.get('soil_moisture', 70.0)),
                float(data.get('nutrient_level', 1.7)),
                float(data.get('ph_level', 6.6)),
                float(data.get('light_intensity', 1000.0)),
                float(data.get('co2_level', 450.0)),
                datetime.now()
            ))
            
            conn.commit()
            
            print(f"💾 Datos guardados en PostgreSQL - Sensor: {data['sensor_id']}")
            
            return jsonify({
                'status': 'success',
                'message': 'Data saved to PostgreSQL',
                'sensor_id': data['sensor_id'],
                'timestamp': datetime.now().isoformat()
            })
            
        except Exception as e:
            conn.rollback()
            print(f"❌ Error inserting data: {e}")
            return jsonify({'error': str(e)}), 500
        finally:
            cursor.close()
            conn.close()
            
    except Exception as e:
        print(f"❌ Error in api_sensor_real: {e}")
        return jsonify({'error': str(e)}), 500

# ===== APIs PARA CONSULTAR DATOS =====
@app.route('/api/sensors')
def api_sensors():
    """API para datos de sensores con filtros de fecha y hora"""
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    start_time = request.args.get('start_time')
    end_time = request.args.get('end_time')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'})
    
    cursor = conn.cursor()
    try:
        # Construir query con filtros de fecha y hora
        query = """
            SELECT sensor_id, temperature, humidity, light_intensity, nutrient_level, ph_level, timestamp 
            FROM sensor_data 
        """
        
        where_conditions = []
        params = []
        
        if start_date and start_time:
            start_datetime = f"{start_date} {start_time}"
            where_conditions.append("timestamp >= %s")
            params.append(start_datetime)
        elif start_date:
            where_conditions.append("timestamp >= %s")
            params.append(start_date)
            
        if end_date and end_time:
            end_datetime = f"{end_date} {end_time}"
            where_conditions.append("timestamp <= %s")
            params.append(end_datetime)
        elif end_date:
            where_conditions.append("timestamp <= %s")
            params.append(end_date + " 23:59:59")
        
        if where_conditions:
            query += " WHERE " + " AND ".join(where_conditions)
        
        query += " ORDER BY timestamp DESC LIMIT 100"
        
        cursor.execute(query, params)
        
        sensors = []
        for row in cursor.fetchall():
            sensors.append({
                'sensor_id': row[0],
                'temperature': float(row[1]) if row[1] is not None else 0,
                'humidity': float(row[2]) if row[2] is not None else 0,
                'light': float(row[3]) if row[3] is not None else 0,
                'nutrients': float(row[4]) if row[4] is not None else 0,
                'ph': float(row[5]) if row[5] is not None else 0,
                'timestamp': row[6].isoformat() if row[6] else ''
            })
        
        return jsonify({
            'sensors': sensors,
            'filtros_aplicados': {
                'start_date': start_date,
                'end_date': end_date,
                'start_time': start_time,
                'end_time': end_time
            }
        })
    except Exception as e:
        return jsonify({'error': str(e)})
    finally:
        cursor.close()
        conn.close()

@app.route('/api/predictions')
def api_predictions():
    """API para predicciones con filtros de fecha y hora"""
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    start_time = request.args.get('start_time')
    end_time = request.args.get('end_time')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'})
    
    cursor = conn.cursor()
    try:
        # Construir query con filtros de fecha y hora
        query = """
            SELECT p.prediction_id, pl.plant_type, p.predicted_yield, p.prediction_date, p.confidence
            FROM predictions p
            JOIN plants pl ON p.plant_id = pl.plant_id
        """
        
        where_conditions = []
        params = []
        
        if start_date and start_time:
            start_datetime = f"{start_date} {start_time}"
            where_conditions.append("p.prediction_date >= %s")
            params.append(start_datetime)
        elif start_date:
            where_conditions.append("p.prediction_date >= %s")
            params.append(start_date)
            
        if end_date and end_time:
            end_datetime = f"{end_date} {end_time}"
            where_conditions.append("p.prediction_date <= %s")
            params.append(end_datetime)
        elif end_date:
            where_conditions.append("p.prediction_date <= %s")
            params.append(end_date + " 23:59:59")
        
        if where_conditions:
            query += " WHERE " + " AND ".join(where_conditions)
        
        query += " ORDER BY p.prediction_date DESC LIMIT 100"
        
        cursor.execute(query, params)
        
        predictions = []
        for row in cursor.fetchall():
            predictions.append({
                'id': row[0],
                'plant_type': row[1],
                'yield': float(row[2]) if row[2] is not None else 0,
                'date': row[3].isoformat() if row[3] else '',
                'confidence': float(row[4]) if row[4] is not None else 0
            })
        
        return jsonify({
            'predictions': predictions,
            'filtros_aplicados': {
                'start_date': start_date,
                'end_date': end_date,
                'start_time': start_time,
                'end_time': end_time
            }
        })
    except Exception as e:
        return jsonify({'error': str(e)})
    finally:
        cursor.close()
        conn.close()

@app.route('/api/datos_monitor')
def api_datos_monitor():
    """API específica para el monitor con datos completos"""
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    start_time = request.args.get('start_time')
    end_time = request.args.get('end_time')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'})
    
    cursor = conn.cursor()
    try:
        # Construir query con filtros de fecha y hora
        query = """
            SELECT DISTINCT ON (sensor_id) 
                   sensor_id, temperature, humidity, nutrient_level, ph_level, 
                   light_intensity, co2_level, timestamp
            FROM sensor_data 
        """
        
        where_conditions = []
        params = []
        
        if start_date and start_time:
            start_datetime = f"{start_date} {start_time}"
            where_conditions.append("timestamp >= %s")
            params.append(start_datetime)
        elif start_date:
            where_conditions.append("timestamp >= %s")
            params.append(start_date)
        else:
            # Sin filtros: solo lecturas de los últimos 15 segundos
            where_conditions.append("timestamp >= NOW() - INTERVAL '15 seconds'")
            
        if end_date and end_time:
            end_datetime = f"{end_date} {end_time}"
            where_conditions.append("timestamp <= %s")
            params.append(end_datetime)
        elif end_date:
            where_conditions.append("timestamp <= %s")
            params.append(end_date + " 23:59:59")
        
        if where_conditions:
            query += " WHERE " + " AND ".join(where_conditions)
        
        query += " ORDER BY sensor_id, timestamp DESC"
        
        cursor.execute(query, params)
        
        sensores = []
        now_ts = datetime.now()
        for row in cursor.fetchall():
            ts = row[7]
            # Saltar registros sin timestamp o más antiguos que 15 segundos
            if not ts or (now_ts - ts).total_seconds() > 15:
                continue
            
            if 'rabano' in row[0].lower():
                tipo_planta = 'rabano'
            elif 'cilantro' in row[0].lower():
                tipo_planta = 'cilantro'
            else:
                tipo_planta = 'general'
                
            sensores.append({
                'sensor_id': row[0],
                'temperatura': float(row[1]) if row[1] is not None else 0,
                'humedad': float(row[2]) if row[2] is not None else 0,
                'nutrientes': float(row[3]) if row[3] is not None else 0,
                'ph': float(row[4]) if row[4] is not None else 0,
                'luminosidad': float(row[5]) if row[5] is not None else 0,
                'co2': float(row[6]) if row[6] is not None else 0,
                'conductividad': float(row[3]) * 2 if row[3] is not None else 0,
                'tipo_planta': tipo_planta,
                'timestamp': ts.isoformat()
            })
        
        return jsonify({
            'sensores': sensores,
            'total_sensores': len(sensores),
            'timestamp_actualizacion': datetime.now().isoformat(),
            'filtros_aplicados': {
                'start_date': start_date,
                'end_date': end_date,
                'start_time': start_time,
                'end_time': end_time
            }
        })
        
    except Exception as e:
        print(f"Error en api_datos_monitor: {e}")
        return jsonify({'error': str(e)})
    finally:
        cursor.close()
        conn.close()

@app.route('/api/predicciones_completas')
def api_predicciones_completas():
    """API para predicciones de ambas plantas con filtros de fecha y hora"""
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    start_time = request.args.get('start_time')
    end_time = request.args.get('end_time')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'})
    
    cursor = conn.cursor()
    try:
        # Construir query con filtros de fecha y hora
        query = """
            SELECT pl.plant_type, 
                   AVG(p.predicted_yield) as rendimiento_promedio,
                   AVG(p.confidence) as confianza_promedio,
                   COUNT(*) as total_predicciones
            FROM predictions p
            JOIN plants pl ON p.plant_id = pl.plant_id
        """
        
        where_conditions = []
        params = []
        
        if start_date and start_time:
            start_datetime = f"{start_date} {start_time}"
            where_conditions.append("p.prediction_date >= %s")
            params.append(start_datetime)
        elif start_date:
            where_conditions.append("p.prediction_date >= %s")
            params.append(start_date)
            
        if end_date and end_time:
            end_datetime = f"{end_date} {end_time}"
            where_conditions.append("p.prediction_date <= %s")
            params.append(end_datetime)
        elif end_date:
            where_conditions.append("p.prediction_date <= %s")
            params.append(end_date + " 23:59:59")
        
        # Si no hay filtros, usar último día por defecto
        if not where_conditions:
            where_conditions.append("p.prediction_date >= NOW() - INTERVAL '1 day'")
        
        if where_conditions:
            query += " WHERE " + " AND ".join(where_conditions)
        
        query += " GROUP BY pl.plant_type"
        
        cursor.execute(query, params)
        
        predicciones = {}
        for row in cursor.fetchall():
            plant_type = row[0]
            dias_cosecha = 15 if plant_type == 'rabano' else 25
            
            factores_riesgo = []
            confianza = float(row[2]) if row[2] else 0

            if confianza < 0.7:
                factores_riesgo = ['Humedad variable', 'Temperatura inestable']
            elif confianza < 0.8:
                factores_riesgo = ['Ligera variación en nutrientes']
            
            predicciones[plant_type] = {
                'rendimiento_previsto': float(row[1]) if row[1] else 0,
                'probabilidad_exito': confianza,
                'dias_cosecha': dias_cosecha,
                'factores_riesgo': factores_riesgo,
                'total_predicciones': row[3]
            }
        
        # Solo devolver datos reales, sin valores por defecto
        return jsonify({
            'predicciones': predicciones,
            'filtros_aplicados': {
                'start_date': start_date,
                'end_date': end_date,
                'start_time': start_time,
                'end_time': end_time
            }
        })
        
    except Exception as e:
        print(f"Error en api_predicciones_completas: {e}")
        return jsonify({'error': str(e)})
    finally:
        cursor.close()
        conn.close()

@app.route('/api/graficos_tiempo_real')
def api_graficos_tiempo_real():
    """API para datos de gráficos en tiempo real con filtros de fecha y hora"""
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    start_time = request.args.get('start_time')
    end_time = request.args.get('end_time')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'})
    
    cursor = conn.cursor()
    try:
        # Construir query con filtros de fecha y hora
        query = """
            SELECT timestamp, temperature, humidity, nutrient_level, ph_level
            FROM sensor_data 
        """
        
        where_conditions = []
        params = []
        
        if start_date and start_time:
            start_datetime = f"{start_date} {start_time}"
            where_conditions.append("timestamp >= %s")
            params.append(start_datetime)
        elif start_date:
            where_conditions.append("timestamp >= %s")
            params.append(start_date)
            
        if end_date and end_time:
            end_datetime = f"{end_date} {end_time}"
            where_conditions.append("timestamp <= %s")
            params.append(end_datetime)
        elif end_date:
            where_conditions.append("timestamp <= %s")
            params.append(end_date + " 23:59:59")
        
        # Si no hay filtros, usar últimas 12 horas por defecto
        if not where_conditions:
            where_conditions.append("timestamp >= NOW() - INTERVAL '12 hours'")
        
        if where_conditions:
            query += " WHERE " + " AND ".join(where_conditions)
        
        query += " ORDER BY timestamp ASC"
        
        cursor.execute(query, params)
        
        datos_temperatura = []
        datos_humedad = []
        datos_nutrientes = []
        datos_ph = []
        
        for row in cursor.fetchall():
            timestamp, temp, hum, nut, ph = row
            datos_temperatura.append({
                'x': timestamp.isoformat(),
                'y': float(temp) if temp is not None else 0
            })
            datos_humedad.append({
                'x': timestamp.isoformat(), 
                'y': float(hum) if hum is not None else 0
            })
            datos_nutrientes.append({
                'x': timestamp.isoformat(),
                'y': float(nut) if nut is not None else 0
            })
            datos_ph.append({
                'x': timestamp.isoformat(),
                'y': float(ph) if ph is not None else 0
            })
        
        return jsonify({
            'temperatura': datos_temperatura,
            'humedad': datos_humedad,
            'nutrientes': datos_nutrientes,
            'ph': datos_ph,
            'ultima_actualizacion': datetime.now().isoformat(),
            'filtros_aplicados': {
                'start_date': start_date,
                'end_date': end_date,
                'start_time': start_time,
                'end_time': end_time
            }
        })
        
    except Exception as e:
        print(f"Error en api_graficos_tiempo_real: {e}")
        return jsonify({'error': str(e)})
    finally:
        cursor.close()
        conn.close()

@app.route('/api/estado_actual')
def api_estado_actual():
    """API para datos en tiempo real del dashboard"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'})
    
    cursor = conn.cursor()
    try:
        cursor.execute("""
            SELECT DISTINCT ON (sensor_id) 
                   sensor_id, temperature, humidity, nutrient_level, ph_level, 
                   light_intensity, co2_level, timestamp
            FROM sensor_data 
            WHERE timestamp >= NOW() - INTERVAL '15 seconds'
            ORDER BY sensor_id, timestamp DESC
        """)
        
        sensores = []
        now_ts = datetime.now()
        for row in cursor.fetchall():
            ts = row[7]
            # Saltar sensores sin timestamp o muy antiguos (>15s)
            if not ts or (now_ts - ts).total_seconds() > 15:
                continue
            tipo_planta = 'rabano' if 'rabano' in row[0].lower() else 'cilantro'
            sensores.append({
                'sensor_id': row[0],
                'temperatura': float(row[1]) if row[1] is not None else 0,
                'humedad': float(row[2]) if row[2] is not None else 0,
                'nutrientes': float(row[3]) if row[3] is not None else 0,
                'ph': float(row[4]) if row[4] is not None else 0,
                'luminosidad': float(row[5]) if row[5] is not None else 0,
                'co2': float(row[6]) if row[6] is not None else 0,
                'conductividad': float(row[3]) * 2 if row[3] is not None else 0,
                'tipo_planta': tipo_planta,
                'timestamp': ts.isoformat() if ts else ''
            })
        
        cursor.execute("""
            SELECT plant_type, AVG(predicted_yield), AVG(confidence)
            FROM predictions p
            JOIN plants pl ON p.plant_id = pl.plant_id
            WHERE p.prediction_date >= NOW() - INTERVAL '1 day'
            GROUP BY plant_type
        """)
        
        predicciones = {}
        for row in cursor.fetchall():
            dias_cosecha = 15 if row[0] == 'rabano' else 25
            factores_riesgo = []
            
            if row[2] and float(row[2]) < 0.8:
                factores_riesgo = ['Humedad variable', 'Temperatura inestable']
            
            predicciones[row[0]] = {
                'rendimiento_previsto': float(row[1]) if row[1] else 0,
                'probabilidad_exito': float(row[2]) if row[2] else 0,
                'dias_cosecha': dias_cosecha,
                'factores_riesgo': factores_riesgo
            }
        
        estadisticas = {
            'total_sensores': len(sensores),
            'temp_promedio': round(sum(s['temperatura'] for s in sensores) / len(sensores), 1) if sensores else 0,
            'hum_promedio': round(sum(s['humedad'] for s in sensores) / len(sensores), 1) if sensores else 0
        }
        
        return jsonify({
            'sensores': sensores,
            'predicciones': predicciones,
            'estadisticas': estadisticas
        })
        
    except Exception as e:
        print(f"Error en api_estado_actual: {e}")
        return jsonify({'error': str(e)})
    finally:
        cursor.close()
        conn.close()

@app.route('/api/metricas_rendimiento')
def api_metricas_rendimiento():
    """API para métricas de rendimiento con filtros de fecha y hora"""
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    start_time = request.args.get('start_time')
    end_time = request.args.get('end_time')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'})
    
    cursor = conn.cursor()
    try:
        # Construir query con filtros de fecha y hora
        query = """
            SELECT pl.plant_type, 
                   AVG(p.predicted_yield) as rendimiento_promedio,
                   COUNT(*) as total_predicciones
            FROM predictions p
            JOIN plants pl ON p.plant_id = pl.plant_id
        """
        
        where_conditions = []
        params = []
        
        if start_date and start_time:
            start_datetime = f"{start_date} {start_time}"
            where_conditions.append("p.prediction_date >= %s")
            params.append(start_datetime)
        elif start_date:
            where_conditions.append("p.prediction_date >= %s")
            params.append(start_date)
            
        if end_date and end_time:
            end_datetime = f"{end_date} {end_time}"
            where_conditions.append("p.prediction_date <= %s")
            params.append(end_datetime)
        elif end_date:
            where_conditions.append("p.prediction_date <= %s")
            params.append(end_date + " 23:59:59")
        
        # Si no hay filtros, usar última semana por defecto
        if not where_conditions:
            where_conditions.append("p.prediction_date >= NOW() - INTERVAL '7 days'")
        
        if where_conditions:
            query += " WHERE " + " AND ".join(where_conditions)
        
        query += " GROUP BY pl.plant_type"
        
        cursor.execute(query, params)
        
        metricas = []
        for row in cursor.fetchall():
            metricas.append({
                'tipo_planta': row[0],
                'rendimiento_promedio': float(row[1]) if row[1] else 0,
                'total_predicciones': row[2]
            })
        
        return jsonify({
            'metricas': metricas,
            'filtros_aplicados': {
                'start_date': start_date,
                'end_date': end_date,
                'start_time': start_time,
                'end_time': end_time
            }
        })
    except Exception as e:
        return jsonify({'error': str(e)})
    finally:
        cursor.close()
        conn.close()

# ===== APIs PARA REPORTES =====
@app.route('/api/reportes/sensores')
def api_reportes_sensores():
    """API para generar reportes de sensores con filtros precisos"""
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    start_time = request.args.get('start_time')
    end_time = request.args.get('end_time')
    formato = request.args.get('formato', 'json')  # json o csv
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'})
    
    cursor = conn.cursor()
    try:
        # Construir query con filtros de fecha y hora
        query = """
            SELECT sensor_id, temperature, humidity, soil_moisture, nutrient_level, 
                   ph_level, light_intensity, co2_level, timestamp
            FROM sensor_data 
        """
        
        where_conditions = []
        params = []
        
        if start_date and start_time:
            start_datetime = f"{start_date} {start_time}"
            where_conditions.append("timestamp >= %s")
            params.append(start_datetime)
        elif start_date:
            where_conditions.append("timestamp >= %s")
            params.append(start_date)
            
        if end_date and end_time:
            end_datetime = f"{end_date} {end_time}"
            where_conditions.append("timestamp <= %s")
            params.append(end_datetime)
        elif end_date:
            where_conditions.append("timestamp <= %s")
            params.append(end_date + " 23:59:59")
        
        if where_conditions:
            query += " WHERE " + " AND ".join(where_conditions)
        
        query += " ORDER BY timestamp DESC"
        
        cursor.execute(query, params)
        
        datos = []
        for row in cursor.fetchall():
            datos.append({
                'sensor_id': row[0],
                'temperature': float(row[1]) if row[1] is not None else 0,
                'humidity': float(row[2]) if row[2] is not None else 0,
                'soil_moisture': float(row[3]) if row[3] is not None else 0,
                'nutrient_level': float(row[4]) if row[4] is not None else 0,
                'ph_level': float(row[5]) if row[5] is not None else 0,
                'light_intensity': float(row[6]) if row[6] is not None else 0,
                'co2_level': float(row[7]) if row[7] is not None else 0,
                'timestamp': row[8].isoformat() if row[8] else ''
            })
        
        if formato == 'csv':
            # Generar CSV
            output = io.StringIO()
            writer = csv.writer(output)
            writer.writerow(['Sensor ID', 'Temperature', 'Humidity', 'Soil Moisture', 
                           'Nutrient Level', 'pH Level', 'Light Intensity', 'CO2 Level', 'Timestamp'])
            
            for dato in datos:
                writer.writerow([
                    dato['sensor_id'],
                    dato['temperature'],
                    dato['humidity'],
                    dato['soil_moisture'],
                    dato['nutrient_level'],
                    dato['ph_level'],
                    dato['light_intensity'],
                    dato['co2_level'],
                    dato['timestamp']
                ])
            
            output.seek(0)
            return send_file(
                io.BytesIO(output.getvalue().encode('utf-8')),
                mimetype='text/csv',
                as_attachment=True,
                download_name=f'reporte_sensores_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv'
            )
        else:
            return jsonify({
                'datos': datos,
                'total_registros': len(datos),
                'filtros_aplicados': {
                    'start_date': start_date,
                    'end_date': end_date,
                    'start_time': start_time,
                    'end_time': end_time
                }
            })
            
    except Exception as e:
        return jsonify({'error': str(e)})
    finally:
        cursor.close()
        conn.close()

@app.route('/api/assistant/chat', methods=['POST'])
def api_assistant_chat():
    """API para el asistente de IA que puede responder sobre el contenido de la página"""
    try:
        data = request.get_json()
        user_message = data.get('message', '')
        page_content = data.get('page_content', '')
        current_url = data.get('current_url', '')
        
        if not user_message:
            return jsonify({'error': 'Mensaje requerido'}), 400
        
        # Construir el contexto con información de la página
        system_prompt = """Eres un asistente de IA especializado en el sistema de Bio-Invernadero Inteligente. 
Tu función es ayudar a los usuarios a entender cualquier información que se muestre en la página del dashboard.

El sistema monitorea cultivos de rábanos y cilantro, con sensores que miden:
- Temperatura (óptima: 18-26°C)
- Humedad (óptima: 50-80%)
- pH (óptimo: 6.0-7.0)
- Niveles de nutrientes
- Intensidad de luz
- Niveles de CO2

Puedes responder preguntas sobre:
- Datos de sensores y su significado
- Predicciones de rendimiento
- Interpretación de gráficos y métricas
- Recomendaciones para optimizar el cultivo
- Cualquier información visible en la página actual

Responde de manera clara, concisa y en español. Si no tienes suficiente información, pide más detalles o indica que necesitas ver datos específicos."""
        
        # Preparar el mensaje con contexto de la página
        context_message = f"""El usuario está viendo la página: {current_url}

Contenido visible en la página:
{page_content[:2000]}  # Limitar el contenido para no exceder límites

Pregunta del usuario: {user_message}"""
        
        # Llamar a la API de OpenAI
        headers = {
            'Authorization': f'Bearer {Config.OPENAI_API_KEY}',
            'Content-Type': 'application/json'
        }
        
        payload = {
            'model': 'gpt-3.5-turbo',
            'messages': [
                {'role': 'system', 'content': system_prompt},
                {'role': 'user', 'content': context_message}
            ],
            'temperature': 0.7,
            'max_tokens': 500
        }
        
        response = requests.post(
            Config.OPENAI_API_URL,
            headers=headers,
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            assistant_message = result['choices'][0]['message']['content']
            
            return jsonify({
                'status': 'success',
                'message': assistant_message,
                'timestamp': datetime.now().isoformat()
            })
        else:
            error_msg = f"Error en API de OpenAI: {response.status_code}"
            if response.text:
                try:
                    error_data = response.json()
                    error_msg = error_data.get('error', {}).get('message', error_msg)
                except:
                    error_msg = response.text[:200]
            
            return jsonify({
                'status': 'error',
                'message': f'No pude procesar tu pregunta. {error_msg}',
                'timestamp': datetime.now().isoformat()
            }), 500
            
    except Exception as e:
        print(f"Error en api_assistant_chat: {e}")
        return jsonify({
            'status': 'error',
            'message': f'Error al procesar la solicitud: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/api/reportes/predicciones')
def api_reportes_predicciones():
    """API para generar reportes de predicciones con filtros precisos"""
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    start_time = request.args.get('start_time')
    end_time = request.args.get('end_time')
    formato = request.args.get('formato', 'json')  # json o csv
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'})
    
    cursor = conn.cursor()
    try:
        # Construir query con filtros de fecha y hora
        query = """
            SELECT p.prediction_id, pl.plant_type, p.predicted_yield, p.prediction_date, p.confidence
            FROM predictions p
            JOIN plants pl ON p.plant_id = pl.plant_id
        """
        
        where_conditions = []
        params = []
        
        if start_date and start_time:
            start_datetime = f"{start_date} {start_time}"
            where_conditions.append("p.prediction_date >= %s")
            params.append(start_datetime)
        elif start_date:
            where_conditions.append("p.prediction_date >= %s")
            params.append(start_date)
            
        if end_date and end_time:
            end_datetime = f"{end_date} {end_time}"
            where_conditions.append("p.prediction_date <= %s")
            params.append(end_datetime)
        elif end_date:
            where_conditions.append("p.prediction_date <= %s")
            params.append(end_date + " 23:59:59")
        
        if where_conditions:
            query += " WHERE " + " AND ".join(where_conditions)
        
        query += " ORDER BY p.prediction_date DESC"
        
        cursor.execute(query, params)
        
        datos = []
        for row in cursor.fetchall():
            datos.append({
                'prediction_id': row[0],
                'plant_type': row[1],
                'predicted_yield': float(row[2]) if row[2] is not None else 0,
                'prediction_date': row[3].isoformat() if row[3] else '',
                'confidence': float(row[4]) if row[4] is not None else 0
            })
        
        if formato == 'csv':
            # Generar CSV
            output = io.StringIO()
            writer = csv.writer(output)
            writer.writerow(['Prediction ID', 'Plant Type', 'Predicted Yield', 'Prediction Date', 'Confidence'])
            
            for dato in datos:
                writer.writerow([
                    dato['prediction_id'],
                    dato['plant_type'],
                    dato['predicted_yield'],
                    dato['prediction_date'],
                    dato['confidence']
                ])
            
            output.seek(0)
            return send_file(
                io.BytesIO(output.getvalue().encode('utf-8')),
                mimetype='text/csv',
                as_attachment=True,
                download_name=f'reporte_predicciones_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv'
            )
        else:
            return jsonify({
                'datos': datos,
                'total_registros': len(datos),
                'filtros_aplicados': {
                    'start_date': start_date,
                    'end_date': end_date,
                    'start_time': start_time,
                    'end_time': end_time
                }
            })
            
    except Exception as e:
        return jsonify({'error': str(e)})
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    print("=== BIO-INVERNADERO INTELIGENTE ===")
    print("🌿 Dashboard: http://localhost:5000")
    print("📊 Rutas disponibles:")
    print("   - / (Inicio)")
    print("   - /monitor (Monitoreo en tiempo real)")
    print("   - /predicciones (Predicciones IA)")
    print("   - /analytics (Dashboard avanzado)")
    print("   - /reportes (Reportes y exportación)")
    print("📡 Funcionalidades integradas:")
    print("   - ✅ Monitor serial COM7 activo")
    print("   - ✅ Base de datos PostgreSQL")
    print("   - ✅ APIs REST para dashboard")
    print("   - ✅ Reportes exportables")
    
    # Inicializar base de datos
    inicializar_base_datos()
    
    # Iniciar monitor serial
    start_serial_monitor()
    
    print("✅ Sistema listo! El Arduino enviará datos automáticamente por COM7")
    app.run(debug=True, host='0.0.0.0', port=5000, use_reloader=False)