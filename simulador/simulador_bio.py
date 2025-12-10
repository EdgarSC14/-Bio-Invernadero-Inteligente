# simulador/simulador_final.py
import psycopg2
import random
import time
from datetime import datetime, timedelta

print("=== GREENHOUSE SIMULATOR ===")
print("✅ Contraseña PostgreSQL confirmada: 1234")

def conectar_y_configurar():
    """Conectar y configurar la base de datos completa"""
    try:
        # Paso 1: Conectar a PostgreSQL
        conn = psycopg2.connect(
            host="localhost",
            database="postgres", 
            user="postgres",
            password="1234",
            port="5432"
        )
        print("✅ Conectado a PostgreSQL")
        
        # Paso 2: Crear base de datos si no existe
        conn.autocommit = True
        cursor = conn.cursor()
        
        cursor.execute("SELECT 1 FROM pg_database WHERE datname='greenhouse_monitoring'")
        if not cursor.fetchone():
            cursor.execute("CREATE DATABASE greenhouse_monitoring")
            print("✅ Base de datos 'greenhouse_monitoring' creada")
        else:
            print("✅ Base de datos ya existe")
        
        cursor.close()
        conn.close()
        
        # Paso 3: Conectar a la base de datos específica
        conn = psycopg2.connect(
            host="localhost",
            database="greenhouse_monitoring",
            user="postgres", 
            password="1234",
            port="5432"
        )
        print("✅ Conectado a greenhouse_monitoring")
        
        return conn
        
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def crear_tablas(conn):
    """Crear todas las tablas necesarias"""
    cursor = conn.cursor()
    
    try:
        # Tabla de plantas
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS plants (
                plant_id SERIAL PRIMARY KEY,
                plant_type VARCHAR(50),
                planting_date TIMESTAMP,
                status VARCHAR(20)
            )
        """)
        
        # Tabla de datos de sensores
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
        
        # Tabla de predicciones
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
                ('cilantro', 'active')
            ]
            for tipo_planta, estado in plantas:
                cursor.execute(
                    "INSERT INTO plants (plant_type, planting_date, status) VALUES (%s, %s, %s)",
                    (tipo_planta, datetime.now() - timedelta(days=10), estado)
                )
            print("✅ 4 plantas de ejemplo creadas (2 rábanos, 2 cilantros)")
        
        conn.commit()
        print("✅ Todas las tablas configuradas correctamente")
        
    except Exception as e:
        print(f"Error creando tablas: {e}")
        conn.rollback()
    finally:
        cursor.close()

def generar_datos_sensor(sensor_id, tipo_planta):
    """Generar datos realistas del sensor"""
    if tipo_planta == 'rabano':
        temp_base = 20.0
        hum_base = 65.0
    else:
        temp_base = 18.5
        hum_base = 70.0
    
    hora = datetime.now().hour
    es_dia = 6 <= hora <= 18
    
    # Variaciones realistas
    temp = temp_base + random.uniform(-3, 3)
    hum = hum_base + random.uniform(-10, 10)
    nutrientes = 1.5 + random.uniform(-0.5, 0.5)
    ph = 6.5 + random.uniform(-0.5, 0.5)
    luz = random.uniform(800, 1200) if es_dia else random.uniform(50, 200)
    
    return {
        'sensor_id': sensor_id,
        'temperature': round(max(15, min(30, temp)), 2),
        'humidity': round(max(40, min(85, hum)), 2),
        'soil_moisture': round(random.uniform(60, 80), 2),
        'nutrient_level': round(max(0.5, min(3.0, nutrientes)), 2),
        'ph_level': round(max(5.0, min(8.0, ph)), 2),
        'light_intensity': round(luz, 2),
        'co2_level': round(random.uniform(400, 500), 2),
        'timestamp': datetime.now()
    }

def insertar_datos_sensor(conn, datos):
    """Insertar datos del sensor en la base de datos"""
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO sensor_data 
            (sensor_id, temperature, humidity, soil_moisture, nutrient_level, ph_level, light_intensity, co2_level, timestamp)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            datos['sensor_id'],
            datos['temperature'],
            datos['humidity'],
            datos['soil_moisture'],
            datos['nutrient_level'],
            datos['ph_level'],
            datos['light_intensity'],
            datos['co2_level'],
            datos['timestamp']
        ))
        conn.commit()
        return True
    except Exception as e:
        print(f"Error insertando datos: {e}")
        conn.rollback()
        return False
    finally:
        cursor.close()

def generar_prediccion(conn, plant_id, plant_type):
    """Generar predicción de rendimiento"""
    cursor = conn.cursor()
    try:
        if plant_type == 'rabano':
            rendimiento = random.uniform(150, 220)
        else:
            rendimiento = random.uniform(100, 160)
        
        confianza = random.uniform(0.7, 0.95)
        
        cursor.execute("""
            INSERT INTO predictions (plant_id, predicted_yield, prediction_date, confidence)
            VALUES (%s, %s, %s, %s)
        """, (plant_id, round(rendimiento, 2), datetime.now(), round(confianza, 3)))
        
        conn.commit()
        return True
    except Exception as e:
        print(f"Error en predicción: {e}")
        conn.rollback()
        return False
    finally:
        cursor.close()

# PROGRAMA PRINCIPAL
def main():
    print("🔧 Inicializando sistema de monitoreo...")
    
    # Configurar base de datos
    conn = conectar_y_configurar()
    if not conn:
        return
    
    # Crear tablas
    crear_tablas(conn)
    
    # Configurar sensores
    sensores = [
        {'id': 'sensor_rabano_1', 'type': 'rabano'},
        {'id': 'sensor_rabano_2', 'type': 'rabano'},
        {'id': 'sensor_cilantro_1', 'type': 'cilantro'},
        {'id': 'sensor_cilantro_2', 'type': 'cilantro'}
    ]
    
    print("\n🚀 INICIANDO SIMULACIÓN")
    print("📡 Sensores activos: 4")
    print("🌱 Plantas monitoreadas: 2 rábanos, 2 cilantros")
    print("⏱️  Actualizaciones cada 10 segundos")
    print("⏹️  Presiona Ctrl+C para detener\n")
    
    ciclo = 0
    
    try:
        while True:
            # Insertar datos de todos los sensores
            for sensor in sensores:
                datos = generar_datos_sensor(sensor['id'], sensor['type'])
                if insertar_datos_sensor(conn, datos):
                    print(f"📡 {sensor['id']}: {datos['temperature']}°C, {datos['humidity']}%")
            
            # Generar predicciones cada 3 ciclos
            if ciclo % 3 == 0:
                cursor = conn.cursor()
                cursor.execute("SELECT plant_id, plant_type FROM plants LIMIT 2")
                plantas = cursor.fetchall()
                cursor.close()
                
                for plant_id, plant_type in plantas:
                    if generar_prediccion(conn, plant_id, plant_type):
                        print(f"🔮 Predicción generada para {plant_type}")
            
            ciclo += 1
            print(f"🔄 Ciclo {ciclo} completado - {datetime.now().strftime('%H:%M:%S')}")
            print("-" * 50)
            
            time.sleep(10)  # Esperar 10 segundos
            
    except KeyboardInterrupt:
        print("\n🛑 Simulación detenida por el usuario")
    except Exception as e:
        print(f"💥 Error en simulación: {e}")
    finally:
        conn.close()
        print("✅ Conexión a base de datos cerrada")

if __name__ == "__main__":
    main()