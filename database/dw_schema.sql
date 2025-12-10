-- ============================================
-- ESQUEMA DE DATA WAREHOUSE
-- Modelo Multidimensional (Esquema Estrella)
-- ============================================

-- ============================================
-- TABLAS DE DIMENSIONES
-- ============================================

-- Dimensión Tiempo
CREATE TABLE IF NOT EXISTS dim_tiempo (
    tiempo_id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    año INTEGER NOT NULL,
    trimestre INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    semana INTEGER NOT NULL,
    dia_semana INTEGER NOT NULL,
    nombre_dia VARCHAR(20),
    es_fin_semana BOOLEAN,
    hora INTEGER,
    minuto INTEGER,
    timestamp_completo TIMESTAMP,
    CONSTRAINT unique_fecha UNIQUE (fecha, hora, minuto)
);

CREATE INDEX idx_dim_tiempo_fecha ON dim_tiempo(fecha);
CREATE INDEX idx_dim_tiempo_año_mes ON dim_tiempo(año, mes);

-- Dimensión Planta
CREATE TABLE IF NOT EXISTS dim_planta (
    planta_id SERIAL PRIMARY KEY,
    plant_id INTEGER,  -- Referencia a tabla original
    tipo_planta VARCHAR(50) NOT NULL,
    estado VARCHAR(20),
    fecha_siembra DATE,
    dias_desde_siembra INTEGER,
    etapa_crecimiento VARCHAR(50),
    variedad VARCHAR(50),
    lote VARCHAR(50)
);

CREATE INDEX idx_dim_planta_tipo ON dim_planta(tipo_planta);
CREATE INDEX idx_dim_planta_estado ON dim_planta(estado);

-- Dimensión Sensor
CREATE TABLE IF NOT EXISTS dim_sensor (
    sensor_id_dim SERIAL PRIMARY KEY,
    sensor_id VARCHAR(50) NOT NULL UNIQUE,
    tipo_sensor VARCHAR(50),
    ubicacion VARCHAR(100),
    firmware_version VARCHAR(20),
    fecha_instalacion DATE,
    estado VARCHAR(20),
    tipo_planta_monitoreada VARCHAR(50)
);

CREATE INDEX idx_dim_sensor_id ON dim_sensor(sensor_id);
CREATE INDEX idx_dim_sensor_tipo ON dim_sensor(tipo_sensor);

-- Dimensión Ubicación
CREATE TABLE IF NOT EXISTS dim_ubicacion (
    ubicacion_id SERIAL PRIMARY KEY,
    invernadero VARCHAR(50),
    sector VARCHAR(50),
    rack VARCHAR(50),
    posicion VARCHAR(50),
    coordenada_x DECIMAL(10,2),
    coordenada_y DECIMAL(10,2),
    zona_climatica VARCHAR(50)
);

CREATE INDEX idx_dim_ubicacion_invernadero ON dim_ubicacion(invernadero);

-- ============================================
-- TABLAS DE HECHOS
-- ============================================

-- Tabla de Hechos: Mediciones
CREATE TABLE IF NOT EXISTS fact_mediciones (
    medicion_id BIGSERIAL PRIMARY KEY,
    tiempo_id INTEGER REFERENCES dim_tiempo(tiempo_id),
    planta_id INTEGER REFERENCES dim_planta(planta_id),
    sensor_id_dim INTEGER REFERENCES dim_sensor(sensor_id_dim),
    ubicacion_id INTEGER REFERENCES dim_ubicacion(ubicacion_id),
    
    -- Medidas (métricas)
    temperatura DECIMAL(5,2),
    humedad DECIMAL(5,2),
    humedad_suelo DECIMAL(5,2),
    nivel_nutrientes DECIMAL(5,2),
    ph DECIMAL(4,2),
    intensidad_luz DECIMAL(8,2),
    co2 DECIMAL(6,2),
    
    -- Medidas calculadas
    temperatura_promedio DECIMAL(5,2),
    humedad_promedio DECIMAL(5,2),
    desviacion_temperatura DECIMAL(5,2),
    
    -- Metadatos
    calidad_dato INTEGER,  -- 1: bueno, 0: error
    timestamp_original TIMESTAMP,
    
    CONSTRAINT fk_tiempo FOREIGN KEY (tiempo_id) REFERENCES dim_tiempo(tiempo_id),
    CONSTRAINT fk_planta FOREIGN KEY (planta_id) REFERENCES dim_planta(planta_id),
    CONSTRAINT fk_sensor FOREIGN KEY (sensor_id_dim) REFERENCES dim_sensor(sensor_id_dim),
    CONSTRAINT fk_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES dim_ubicacion(ubicacion_id)
);

CREATE INDEX idx_fact_mediciones_tiempo ON fact_mediciones(tiempo_id);
CREATE INDEX idx_fact_mediciones_planta ON fact_mediciones(planta_id);
CREATE INDEX idx_fact_mediciones_sensor ON fact_mediciones(sensor_id_dim);
CREATE INDEX idx_fact_mediciones_ubicacion ON fact_mediciones(ubicacion_id);
CREATE INDEX idx_fact_mediciones_timestamp ON fact_mediciones(timestamp_original);

-- Tabla de Hechos: Predicciones
CREATE TABLE IF NOT EXISTS fact_predicciones (
    prediccion_id BIGSERIAL PRIMARY KEY,
    tiempo_id INTEGER REFERENCES dim_tiempo(tiempo_id),
    planta_id INTEGER REFERENCES dim_planta(planta_id),
    
    -- Medidas (métricas)
    rendimiento_previsto DECIMAL(8,2),
    confianza DECIMAL(4,3),
    dias_hasta_cosecha INTEGER,
    
    -- Factores de predicción
    temperatura_promedio_periodo DECIMAL(5,2),
    humedad_promedio_periodo DECIMAL(5,2),
    ph_promedio_periodo DECIMAL(4,2),
    nutrientes_promedio_periodo DECIMAL(5,2),
    
    -- Metadatos
    modelo_utilizado VARCHAR(100),
    version_modelo VARCHAR(20),
    factores_riesgo TEXT[],
    
    timestamp_original TIMESTAMP,
    
    CONSTRAINT fk_tiempo_pred FOREIGN KEY (tiempo_id) REFERENCES dim_tiempo(tiempo_id),
    CONSTRAINT fk_planta_pred FOREIGN KEY (planta_id) REFERENCES dim_planta(planta_id)
);

CREATE INDEX idx_fact_predicciones_tiempo ON fact_predicciones(tiempo_id);
CREATE INDEX idx_fact_predicciones_planta ON fact_predicciones(planta_id);
CREATE INDEX idx_fact_predicciones_timestamp ON fact_predicciones(timestamp_original);

-- ============================================
-- VISTAS MATERIALIZADAS PARA OLAP
-- ============================================

-- Vista agregada: Mediciones por día y tipo de planta
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_mediciones_dia_planta AS
SELECT 
    dt.fecha,
    dt.año,
    dt.mes,
    dp.tipo_planta,
    COUNT(*) as total_mediciones,
    AVG(fm.temperatura) as temp_promedio,
    AVG(fm.humedad) as humedad_promedio,
    AVG(fm.ph) as ph_promedio,
    AVG(fm.nivel_nutrientes) as nutrientes_promedio,
    MIN(fm.temperatura) as temp_min,
    MAX(fm.temperatura) as temp_max,
    STDDEV(fm.temperatura) as temp_stddev
FROM fact_mediciones fm
JOIN dim_tiempo dt ON fm.tiempo_id = dt.tiempo_id
JOIN dim_planta dp ON fm.planta_id = dp.planta_id
GROUP BY dt.fecha, dt.año, dt.mes, dp.tipo_planta;

CREATE INDEX idx_mv_mediciones_dia_planta_fecha ON mv_mediciones_dia_planta(fecha);
CREATE INDEX idx_mv_mediciones_dia_planta_tipo ON mv_mediciones_dia_planta(tipo_planta);

-- Vista agregada: Predicciones por semana y tipo de planta
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_predicciones_semana_planta AS
SELECT 
    dt.año,
    dt.trimestre,
    dt.semana,
    dp.tipo_planta,
    COUNT(*) as total_predicciones,
    AVG(fp.rendimiento_previsto) as rendimiento_promedio,
    AVG(fp.confianza) as confianza_promedio,
    MIN(fp.rendimiento_previsto) as rendimiento_min,
    MAX(fp.rendimiento_previsto) as rendimiento_max,
    SUM(CASE WHEN fp.confianza >= 0.8 THEN 1 ELSE 0 END) as predicciones_alta_confianza
FROM fact_predicciones fp
JOIN dim_tiempo dt ON fp.tiempo_id = dt.tiempo_id
JOIN dim_planta dp ON fp.planta_id = dp.planta_id
GROUP BY dt.año, dt.trimestre, dt.semana, dp.tipo_planta;

CREATE INDEX idx_mv_pred_semana_planta_semana ON mv_predicciones_semana_planta(semana);
CREATE INDEX idx_mv_pred_semana_planta_tipo ON mv_predicciones_semana_planta(tipo_planta);

-- ============================================
-- FUNCIONES DE UTILIDAD
-- ============================================

-- Función para poblar dimensión tiempo
CREATE OR REPLACE FUNCTION poblar_dim_tiempo(fecha_inicio DATE, fecha_fin DATE)
RETURNS INTEGER AS $$
DECLARE
    fecha_actual DATE;
    contador INTEGER := 0;
BEGIN
    fecha_actual := fecha_inicio;
    
    WHILE fecha_actual <= fecha_fin LOOP
        INSERT INTO dim_tiempo (
            fecha, año, trimestre, mes, semana, dia_semana,
            nombre_dia, es_fin_semana, hora, minuto
        ) VALUES (
            fecha_actual,
            EXTRACT(YEAR FROM fecha_actual),
            EXTRACT(QUARTER FROM fecha_actual),
            EXTRACT(MONTH FROM fecha_actual),
            EXTRACT(WEEK FROM fecha_actual),
            EXTRACT(DOW FROM fecha_actual),
            TO_CHAR(fecha_actual, 'Day'),
            EXTRACT(DOW FROM fecha_actual) IN (0, 6),
            0, 0
        )
        ON CONFLICT (fecha, hora, minuto) DO NOTHING;
        
        fecha_actual := fecha_actual + INTERVAL '1 day';
        contador := contador + 1;
    END LOOP;
    
    RETURN contador;
END;
$$ LANGUAGE plpgsql;

