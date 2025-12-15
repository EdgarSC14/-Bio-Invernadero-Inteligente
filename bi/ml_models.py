"""
Módulo de Modelos de Minería de Datos
Implementa modelos de Machine Learning para predicciones y análisis
"""
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from sklearn.preprocessing import StandardScaler
import joblib
import os
from datetime import datetime
import psycopg2

class InvernaderoMLModels:
    """Modelos de Machine Learning para predicción de rendimiento"""
    
    def __init__(self, db_connection):
        self.conn = db_connection
        self.models = {}
        self.scalers = {}
        self.model_dir = "bi/models"
        os.makedirs(self.model_dir, exist_ok=True)
    
    def preparar_datos(self, plant_type=None):
        """Extraer y preparar datos históricos para entrenamiento"""
        cursor = self.conn.cursor()
        
        try:
            query = """
                SELECT 
                    sd.temperature,
                    sd.humidity,
                    sd.soil_moisture,
                    sd.nutrient_level,
                    sd.ph_level,
                    sd.light_intensity,
                    sd.co2_level,
                    p.predicted_yield,
                    p.confidence
                FROM sensor_data sd
                JOIN predictions p ON DATE(sd.timestamp) = DATE(p.prediction_date)
                JOIN plants pl ON p.plant_id = pl.plant_id
                WHERE p.predicted_yield IS NOT NULL
                AND p.predicted_yield > 0
            """
            
            if plant_type:
                query += f" AND pl.plant_type = '{plant_type}'"
            
            cursor.execute(query)
            data = cursor.fetchall()
            
            if len(data) < 10:
                print(f"⚠️ Datos insuficientes para entrenar modelo ({len(data)} registros)")
                return None, None
            
            df = pd.DataFrame(data, columns=[
                'temperature', 'humidity', 'soil_moisture', 'nutrient_level',
                'ph_level', 'light_intensity', 'co2_level', 'yield', 'confidence'
            ])
            
            # Separar features y target
            X = df[['temperature', 'humidity', 'soil_moisture', 'nutrient_level',
                   'ph_level', 'light_intensity', 'co2_level']].values
            y = df['yield'].values
            
            return X, y
            
        except Exception as e:
            print(f"❌ Error preparando datos: {e}")
            return None, None
        finally:
            cursor.close()
    
    def entrenar_modelo_rendimiento(self, plant_type='general'):
        """Entrenar modelo de regresión para predecir rendimiento"""
        print(f"🤖 Entrenando modelo de rendimiento para {plant_type}...")
        
        X, y = self.preparar_datos(plant_type)
        
        if X is None or len(X) < 10:
            print(f"⚠️ No hay suficientes datos para entrenar modelo de {plant_type}")
            return False
        
        # Normalizar datos
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
        
        # Dividir datos
        if len(X) < 20:
            X_train, X_test = X_scaled, X_scaled
            y_train, y_test = y, y
        else:
            X_train, X_test, y_train, y_test = train_test_split(
                X_scaled, y, test_size=0.2, random_state=42
            )
        
        # Entrenar Random Forest
        model_rf = RandomForestRegressor(
            n_estimators=100,
            max_depth=10,
            random_state=42,
            n_jobs=-1
        )
        model_rf.fit(X_train, y_train)
        
        # Entrenar Gradient Boosting
        model_gb = GradientBoostingRegressor(
            n_estimators=100,
            max_depth=5,
            learning_rate=0.1,
            random_state=42
        )
        model_gb.fit(X_train, y_train)
        
        # Evaluar modelos
        y_pred_rf = model_rf.predict(X_test)
        y_pred_gb = model_gb.predict(X_test)
        
        mse_rf = mean_squared_error(y_test, y_pred_rf)
        r2_rf = r2_score(y_test, y_pred_rf)
        mae_rf = mean_absolute_error(y_test, y_pred_rf)
        
        mse_gb = mean_squared_error(y_test, y_pred_gb)
        r2_gb = r2_score(y_test, y_pred_gb)
        mae_gb = mean_absolute_error(y_test, y_pred_gb)
        
        # Seleccionar mejor modelo
        if r2_rf > r2_gb:
            model = model_rf
            model_name = "RandomForest"
            metrics = {'mse': mse_rf, 'r2': r2_rf, 'mae': mae_rf}
        else:
            model = model_gb
            model_name = "GradientBoosting"
            metrics = {'mse': mse_gb, 'r2': r2_gb, 'mae': mae_gb}
        
        # Guardar modelo y scaler
        model_key = f"yield_{plant_type}"
        self.models[model_key] = model
        self.scalers[model_key] = scaler
        
        # Guardar en disco
        model_path = os.path.join(self.model_dir, f"{model_key}_model.pkl")
        scaler_path = os.path.join(self.model_dir, f"{model_key}_scaler.pkl")
        
        joblib.dump(model, model_path)
        joblib.dump(scaler, scaler_path)
        
        print(f"✅ Modelo {model_name} entrenado para {plant_type}")
        print(f"   R² Score: {metrics['r2']:.4f}")
        print(f"   MSE: {metrics['mse']:.2f}")
        print(f"   MAE: {metrics['mae']:.2f}")
        
        return True, metrics
    
    def predecir_rendimiento(self, features, plant_type='general'):
        """Predecir rendimiento basado en features ambientales"""
        model_key = f"yield_{plant_type}"
        
        # Cargar modelo si no está en memoria
        if model_key not in self.models:
            model_path = os.path.join(self.model_dir, f"{model_key}_model.pkl")
            scaler_path = os.path.join(self.model_dir, f"{model_key}_scaler.pkl")
            
            if os.path.exists(model_path) and os.path.exists(scaler_path):
                self.models[model_key] = joblib.load(model_path)
                self.scalers[model_key] = joblib.load(scaler_path)
            else:
                # Si no existe modelo, usar valores por defecto
                return None, 0.0
        
        model = self.models[model_key]
        scaler = self.scalers[model_key]
        
        # Preparar y normalizar features
        X = np.array(features).reshape(1, -1)
        X_scaled = scaler.transform(X)
        
        # Predecir
        prediction = model.predict(X_scaled)[0]
        
        # Calcular confianza basada en la varianza del modelo
        try:
            if hasattr(model, 'estimators_') and model.estimators_ is not None:
                # Para Random Forest, calcular std de predicciones de árboles
                # Verificar que los estimadores tengan el método predict
                tree_predictions = []
                for tree in model.estimators_:
                    # Verificar que el árbol tenga el método predict
                    if hasattr(tree, 'predict') and callable(getattr(tree, 'predict')):
                        try:
                            tree_pred = tree.predict(X_scaled)[0]
                            tree_predictions.append(tree_pred)
                        except:
                            continue
                
                if len(tree_predictions) > 0:
                    tree_predictions = np.array(tree_predictions)
                    std = np.std(tree_predictions)
                    confidence = max(0.5, min(0.95, 1.0 - (std / prediction) if prediction > 0 else 0.7))
                else:
                    # Si no se pudieron obtener predicciones de árboles, usar confianza por defecto
                    confidence = 0.85
            else:
                confidence = 0.85
        except Exception as e:
            # Si hay cualquier error al calcular confianza, usar valor por defecto
            print(f"⚠️ Error calculando confianza: {e}, usando valor por defecto")
            confidence = 0.85
        
        return float(prediction), float(confidence)
    
    def predecir_con_datos_sensor(self, sensor_data, plant_type='general'):
        """Predecir rendimiento usando datos de sensor"""
        features = [
            sensor_data.get('temperature', 22.0),
            sensor_data.get('humidity', 65.0),
            sensor_data.get('soil_moisture', 70.0),
            sensor_data.get('nutrient_level', 1.7),
            sensor_data.get('ph_level', 6.6),
            sensor_data.get('light_intensity', 1000.0),
            sensor_data.get('co2_level', 450.0)
        ]
        
        return self.predecir_rendimiento(features, plant_type)


class ClusteringModels:
    """Modelos de clustering para identificar patrones"""
    
    def __init__(self, db_connection):
        self.conn = db_connection
    
    def kmeans_clustering(self, n_clusters=3):
        """Clustering K-Means para identificar grupos de condiciones ambientales"""
        from sklearn.cluster import KMeans
        
        cursor = self.conn.cursor()
        
        try:
            query = """
                SELECT 
                    temperature,
                    humidity,
                    nutrient_level,
                    ph_level
                FROM sensor_data
                WHERE timestamp >= NOW() - INTERVAL '7 days'
                ORDER BY timestamp DESC
                LIMIT 1000
            """
            
            cursor.execute(query)
            data = cursor.fetchall()
            
            if len(data) < n_clusters:
                return None
            
            df = pd.DataFrame(data, columns=['temperature', 'humidity', 'nutrient_level', 'ph_level'])
            
            # Normalizar
            scaler = StandardScaler()
            X_scaled = scaler.fit_transform(df.values)
            
            # K-Means
            kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
            clusters = kmeans.fit_predict(X_scaled)
            
            # Agregar clusters al dataframe
            df['cluster'] = clusters
            
            # Estadísticas por cluster
            cluster_stats = df.groupby('cluster').agg({
                'temperature': ['mean', 'std'],
                'humidity': ['mean', 'std'],
                'nutrient_level': ['mean', 'std'],
                'ph_level': ['mean', 'std']
            }).to_dict()
            
            return {
                'clusters': clusters.tolist(),
                'centers': kmeans.cluster_centers_.tolist(),
                'stats': cluster_stats,
                'inertia': float(kmeans.inertia_)
            }
            
        except Exception as e:
            print(f"❌ Error en clustering: {e}")
            return None
        finally:
            cursor.close()

