# config/config.py
import os
from datetime import timedelta

class Config:
    # PostgreSQL
    POSTGRES_HOST = os.getenv('POSTGRES_HOST', 'localhost')
    POSTGRES_DB = os.getenv('POSTGRES_DB', 'invernadero_bio')
    POSTGRES_USER = os.getenv('POSTGRES_USER', 'postgres')
    POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD', 'tu_password')
    POSTGRES_PORT = os.getenv('POSTGRES_PORT', '5432')
    
    # Kafka
    KAFKA_BOOTSTRAP_SERVERS = os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'localhost:9092')
    KAFKA_TOPIC_SENSORES = 'invernadero-sensores'
    KAFKA_TOPIC_ALERTAS = 'invernadero-alertas'
    
    # Parámetros del invernadero
    TEMP_OPTIMA_RABANO = 20.0
    TEMP_OPTIMA_CILANTRO = 18.0
    HUMEDAD_OPTIMA = 65.0
    PH_OPTIMO = 6.5
    LUZ_OPTIMA = 1000
    
    # Intervalos de simulación
    SIMULATION_INTERVAL = timedelta(seconds=30)
    PREDICTION_INTERVAL = timedelta(minutes=10)
    
    # Umbrales de alerta
    UMBRAL_TEMP_ALTA = 28.0
    UMBRAL_TEMP_BAJA = 16.0
    UMBRAL_HUMEDAD_ALTA = 85.0
    UMBRAL_HUMEDAD_BAJA = 45.0

# config/requirements.txt
psycopg2-binary==2.9.6
pandas==1.5.3
numpy==1.24.3
scipy==1.10.1
kafka-python==2.0.2
flask==2.3.3
plotly==5.15.0
scikit-learn==1.3.0
python-dotenv==1.0.0