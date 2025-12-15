# kafka/kafka_producer.py
from kafka import KafkaProducer
import json
import time
import psycopg2
from datetime import datetime

class KafkaInvernaderoProducer:
    def __init__(self):
        self.producer = KafkaProducer(
            bootstrap_servers=['localhost:9092'],
            value_serializer=lambda v: json.dumps(v).encode('utf-8')
        )
        self.conn = psycopg2.connect(
            host="localhost",
            database="invernadero_bio",
            user="postgres",
            password="tu_password"
        )
    
    def stream_datos_en_tiempo_real(self):
        """Stream de datos a Kafka para procesamiento real-time"""
        while True:
            cursor = self.conn.cursor()
            
            # Obtener últimas lecturas
            cursor.execute("""
                SELECT sensor_id, tipo_planta, temperatura, humedad, ph, 
                       conductividad, luminosidad, co2, timestamp
                FROM lecturas_sensores 
                WHERE timestamp >= NOW() - INTERVAL '1 minute'
                ORDER BY timestamp DESC
            """)
            
            for row in cursor.fetchall():
                mensaje_kafka = {
                    'sensor_id': row[0],
                    'tipo_planta': row[1],
                    'temperatura': float(row[2]),
                    'humedad': float(row[3]),
                    'ph': float(row[4]),
                    'conductividad': float(row[5]),
                    'luminosidad': float(row[6]),
                    'co2': float(row[7]),
                    'timestamp': row[8].isoformat(),
                    'procesado_por': 'kafka_stream'
                }
                
                # Enviar a topic de Kafka
                self.producer.send('invernadero-sensores', mensaje_kafka)
                print(f"Enviado a Kafka: {mensaje_kafka['sensor_id']}")
            
            cursor.close()
            time.sleep(10)

# kafka/kafka_consumer.py
from kafka import KafkaConsumer
import json
import psycopg2

class KafkaInvernaderoConsumer:
    def __init__(self):
        self.consumer = KafkaConsumer(
            'invernadero-sensores',
            bootstrap_servers=['localhost:9092'],
            value_deserializer=lambda m: json.loads(m.decode('utf-8')),
            auto_offset_reset='latest',
            enable_auto_commit=True
        )
        self.conn = psycopg2.connect(
            host="localhost",
            database="invernadero_bio",
            user="postgres",
            password="tu_password"
        )
    
    def procesar_stream_datos(self):
        """Procesar stream de datos para alertas y análisis"""
        for mensaje in self.consumer:
            datos = mensaje.value
            
            # Análisis en tiempo real
            alertas = self.verificar_alertas(datos)
            
            if alertas:
                self.registrar_alertas(datos['sensor_id'], alertas)
                
            print(f"Procesado: {datos['sensor_id']} - Temp: {datos['temperatura']}")
    
    def verificar_alertas(self, datos):
        """Verificar condiciones de alerta"""
        alertas = []
        
        # Umbrales de alerta
        if datos['temperatura'] > 28 or datos['temperatura'] < 16:
            alertas.append(f"Temperatura crítica: {datos['temperatura']}°C")
        
        if datos['humedad'] > 85 or datos['humedad'] < 45:
            alertas.append(f"Humedad crítica: {datos['humedad']}%")
        
        if datos['ph'] > 7.5 or datos['ph'] < 5.5:
            alertas.append(f"pH crítico: {datos['ph']}")
            
        return alertas
    
    def registrar_alertas(self, sensor_id, alertas):
        """Registrar alertas en base de datos"""
        cursor = self.conn.cursor()
        for alerta in alertas:
            cursor.execute("""
                INSERT INTO alertas_sistema (sensor_id, mensaje, severidad)
                VALUES (%s, %s, %s)
            """, (sensor_id, alerta, 'alta'))
        self.conn.commit()
        cursor.close()