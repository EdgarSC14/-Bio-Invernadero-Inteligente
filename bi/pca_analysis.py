"""
Módulo de Reducción de Dimensionalidad
Implementa PCA (Análisis de Componentes Principales)
"""
import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import psycopg2
import json

class PCAAnalyzer:
    """Análisis de Componentes Principales para reducción de dimensionalidad"""
    
    def __init__(self, db_connection):
        self.conn = db_connection
        self.pca_model = None
        self.scaler = None
        self.components_info = {}
    
    def extraer_datos_sensores(self, limit=1000):
        """Extraer datos de sensores para análisis PCA"""
        cursor = self.conn.cursor()
        
        try:
            query = """
                SELECT 
                    temperature,
                    humidity,
                    soil_moisture,
                    nutrient_level,
                    ph_level,
                    light_intensity,
                    co2_level
                FROM sensor_data
                WHERE timestamp >= NOW() - INTERVAL '30 days'
                AND temperature IS NOT NULL
                AND humidity IS NOT NULL
                ORDER BY timestamp DESC
                LIMIT %s
            """
            
            cursor.execute(query, (limit,))
            data = cursor.fetchall()
            
            if len(data) < 10:
                return None
            
            df = pd.DataFrame(data, columns=[
                'temperature', 'humidity', 'soil_moisture',
                'nutrient_level', 'ph_level', 'light_intensity', 'co2_level'
            ])
            
            return df
            
        except Exception as e:
            print(f"❌ Error extrayendo datos: {e}")
            return None
        finally:
            cursor.close()
    
    def aplicar_pca(self, n_components=None, varianza_explicada=0.95):
        """Aplicar PCA a los datos de sensores"""
        print("📊 Aplicando PCA a datos de sensores...")
        
        df = self.extraer_datos_sensores()
        
        if df is None:
            print("⚠️ No hay suficientes datos para aplicar PCA")
            return None
        
        # Normalizar datos
        self.scaler = StandardScaler()
        X_scaled = self.scaler.fit_transform(df.values)
        
        # Determinar número de componentes
        if n_components is None:
            # Encontrar número de componentes que explican varianza deseada
            pca_temp = PCA()
            pca_temp.fit(X_scaled)
            cumsum_var = np.cumsum(pca_temp.explained_variance_ratio_)
            n_components = np.argmax(cumsum_var >= varianza_explicada) + 1
        
        # Aplicar PCA
        self.pca_model = PCA(n_components=n_components)
        X_pca = self.pca_model.fit_transform(X_scaled)
        
        # Calcular información de componentes
        explained_variance = self.pca_model.explained_variance_ratio_
        cumulative_variance = np.cumsum(explained_variance)
        
        # Componentes principales (loadings)
        components = self.pca_model.components_
        feature_names = df.columns.tolist()
        
        # Crear información detallada
        self.components_info = {
            'n_components': n_components,
            'explained_variance_ratio': explained_variance.tolist(),
            'cumulative_variance': cumulative_variance.tolist(),
            'components': components.tolist(),
            'feature_names': feature_names,
            'total_variance_explained': float(cumulative_variance[-1]),
            'n_features_original': len(feature_names),
            'reduction_ratio': f"{len(feature_names)} → {n_components} ({((1 - n_components/len(feature_names)) * 100):.1f}% reducción)"
        }
        
        print(f"✅ PCA aplicado: {len(feature_names)} features → {n_components} componentes")
        print(f"   Varianza explicada: {cumulative_variance[-1]:.2%}")
        print(f"   Reducción: {((1 - n_components/len(feature_names)) * 100):.1f}%")
        
        return {
            'transformed_data': X_pca.tolist(),
            'info': self.components_info
        }
    
    def transformar_datos_nuevos(self, features):
        """Transformar nuevos datos usando el modelo PCA entrenado"""
        if self.pca_model is None or self.scaler is None:
            print("⚠️ PCA no ha sido entrenado aún")
            return None
        
        # Normalizar
        X_scaled = self.scaler.transform(np.array(features).reshape(1, -1))
        
        # Transformar con PCA
        X_pca = self.pca_model.transform(X_scaled)
        
        return X_pca[0].tolist()
    
    def obtener_contribuciones_features(self):
        """Obtener contribución de cada feature original a los componentes principales"""
        if self.pca_model is None:
            return None
        
        components = self.pca_model.components_
        feature_names = self.components_info['feature_names']
        
        contributions = []
        for i, component in enumerate(components):
            component_contrib = {}
            for j, feature in enumerate(feature_names):
                component_contrib[feature] = float(component[j])
            contributions.append({
                'component': i + 1,
                'contributions': component_contrib,
                'explained_variance': float(self.components_info['explained_variance_ratio'][i])
            })
        
        return contributions
    
    def guardar_resultados_pca(self):
        """Guardar resultados de PCA en base de datos"""
        if not self.components_info:
            return False
        
        cursor = self.conn.cursor()
        
        try:
            # Crear tabla si no existe
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS pca_results (
                    id SERIAL PRIMARY KEY,
                    fecha_analisis TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    n_components INTEGER,
                    n_features_original INTEGER,
                    total_variance_explained DECIMAL(5,4),
                    components_info JSONB
                )
            """)
            
            # Insertar resultados
            cursor.execute("""
                INSERT INTO pca_results 
                (n_components, n_features_original, total_variance_explained, components_info)
                VALUES (%s, %s, %s, %s)
            """, (
                self.components_info['n_components'],
                self.components_info['n_features_original'],
                self.components_info['total_variance_explained'],
                json.dumps(self.components_info)
            ))
            
            self.conn.commit()
            print("✅ Resultados de PCA guardados en base de datos")
            return True
            
        except Exception as e:
            print(f"❌ Error guardando resultados PCA: {e}")
            self.conn.rollback()
            return False
        finally:
            cursor.close()

