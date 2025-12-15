--
-- PostgreSQL database dump
--

\restrict btUV4VzVoX5pwrtpAMOdQleTLPCxoQJKZMv6LMxBVdmhagd0RuKfwm3Ic8r4wzi

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

-- Started on 2025-12-14 23:32:52 CST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: edgar
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO edgar;

--
-- TOC entry 235 (class 1255 OID 16791)
-- Name: poblar_dim_tiempo(date, date); Type: FUNCTION; Schema: public; Owner: edgar
--

CREATE FUNCTION public.poblar_dim_tiempo(fecha_inicio date, fecha_fin date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.poblar_dim_tiempo(fecha_inicio date, fecha_fin date) OWNER TO edgar;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 16662)
-- Name: dim_planta; Type: TABLE; Schema: public; Owner: edgar
--

CREATE TABLE public.dim_planta (
    planta_id integer NOT NULL,
    plant_id integer,
    tipo_planta character varying(50) NOT NULL,
    estado character varying(20),
    fecha_siembra date,
    dias_desde_siembra integer,
    etapa_crecimiento character varying(50),
    variedad character varying(50),
    lote character varying(50)
);


ALTER TABLE public.dim_planta OWNER TO edgar;

--
-- TOC entry 223 (class 1259 OID 16661)
-- Name: dim_planta_planta_id_seq; Type: SEQUENCE; Schema: public; Owner: edgar
--

CREATE SEQUENCE public.dim_planta_planta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_planta_planta_id_seq OWNER TO edgar;

--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 223
-- Name: dim_planta_planta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: edgar
--

ALTER SEQUENCE public.dim_planta_planta_id_seq OWNED BY public.dim_planta.planta_id;


--
-- TOC entry 226 (class 1259 OID 16671)
-- Name: dim_sensor; Type: TABLE; Schema: public; Owner: edgar
--

CREATE TABLE public.dim_sensor (
    sensor_id_dim integer NOT NULL,
    sensor_id character varying(50) NOT NULL,
    tipo_sensor character varying(50),
    ubicacion character varying(100),
    firmware_version character varying(20),
    fecha_instalacion date,
    estado character varying(20),
    tipo_planta_monitoreada character varying(50)
);


ALTER TABLE public.dim_sensor OWNER TO edgar;

--
-- TOC entry 225 (class 1259 OID 16670)
-- Name: dim_sensor_sensor_id_dim_seq; Type: SEQUENCE; Schema: public; Owner: edgar
--

CREATE SEQUENCE public.dim_sensor_sensor_id_dim_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_sensor_sensor_id_dim_seq OWNER TO edgar;

--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 225
-- Name: dim_sensor_sensor_id_dim_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: edgar
--

ALTER SEQUENCE public.dim_sensor_sensor_id_dim_seq OWNED BY public.dim_sensor.sensor_id_dim;


--
-- TOC entry 222 (class 1259 OID 16649)
-- Name: dim_tiempo; Type: TABLE; Schema: public; Owner: edgar
--

CREATE TABLE public.dim_tiempo (
    tiempo_id integer NOT NULL,
    fecha date NOT NULL,
    "año" integer NOT NULL,
    trimestre integer NOT NULL,
    mes integer NOT NULL,
    semana integer NOT NULL,
    dia_semana integer NOT NULL,
    nombre_dia character varying(20),
    es_fin_semana boolean,
    hora integer,
    minuto integer,
    timestamp_completo timestamp without time zone
);


ALTER TABLE public.dim_tiempo OWNER TO edgar;

--
-- TOC entry 221 (class 1259 OID 16648)
-- Name: dim_tiempo_tiempo_id_seq; Type: SEQUENCE; Schema: public; Owner: edgar
--

CREATE SEQUENCE public.dim_tiempo_tiempo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_tiempo_tiempo_id_seq OWNER TO edgar;

--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 221
-- Name: dim_tiempo_tiempo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: edgar
--

ALTER SEQUENCE public.dim_tiempo_tiempo_id_seq OWNED BY public.dim_tiempo.tiempo_id;


--
-- TOC entry 228 (class 1259 OID 16682)
-- Name: dim_ubicacion; Type: TABLE; Schema: public; Owner: edgar
--

CREATE TABLE public.dim_ubicacion (
    ubicacion_id integer NOT NULL,
    invernadero character varying(50),
    sector character varying(50),
    rack character varying(50),
    posicion character varying(50),
    coordenada_x numeric(10,2),
    coordenada_y numeric(10,2),
    zona_climatica character varying(50)
);


ALTER TABLE public.dim_ubicacion OWNER TO edgar;

--
-- TOC entry 227 (class 1259 OID 16681)
-- Name: dim_ubicacion_ubicacion_id_seq; Type: SEQUENCE; Schema: public; Owner: edgar
--

CREATE SEQUENCE public.dim_ubicacion_ubicacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_ubicacion_ubicacion_id_seq OWNER TO edgar;

--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 227
-- Name: dim_ubicacion_ubicacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: edgar
--

ALTER SEQUENCE public.dim_ubicacion_ubicacion_id_seq OWNED BY public.dim_ubicacion.ubicacion_id;


--
-- TOC entry 230 (class 1259 OID 16690)
-- Name: fact_mediciones; Type: TABLE; Schema: public; Owner: edgar
--

CREATE TABLE public.fact_mediciones (
    medicion_id bigint NOT NULL,
    tiempo_id integer,
    planta_id integer,
    sensor_id_dim integer,
    ubicacion_id integer,
    temperatura numeric(5,2),
    humedad numeric(5,2),
    humedad_suelo numeric(5,2),
    nivel_nutrientes numeric(5,2),
    ph numeric(4,2),
    intensidad_luz numeric(8,2),
    co2 numeric(6,2),
    temperatura_promedio numeric(5,2),
    humedad_promedio numeric(5,2),
    desviacion_temperatura numeric(5,2),
    calidad_dato integer,
    timestamp_original timestamp without time zone
);


ALTER TABLE public.fact_mediciones OWNER TO edgar;

--
-- TOC entry 229 (class 1259 OID 16689)
-- Name: fact_mediciones_medicion_id_seq; Type: SEQUENCE; Schema: public; Owner: edgar
--

CREATE SEQUENCE public.fact_mediciones_medicion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fact_mediciones_medicion_id_seq OWNER TO edgar;

--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 229
-- Name: fact_mediciones_medicion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: edgar
--

ALTER SEQUENCE public.fact_mediciones_medicion_id_seq OWNED BY public.fact_mediciones.medicion_id;


--
-- TOC entry 232 (class 1259 OID 16742)
-- Name: fact_predicciones; Type: TABLE; Schema: public; Owner: edgar
--

CREATE TABLE public.fact_predicciones (
    prediccion_id bigint NOT NULL,
    tiempo_id integer,
    planta_id integer,
    rendimiento_previsto numeric(8,2),
    confianza numeric(4,3),
    dias_hasta_cosecha integer,
    temperatura_promedio_periodo numeric(5,2),
    humedad_promedio_periodo numeric(5,2),
    ph_promedio_periodo numeric(4,2),
    nutrientes_promedio_periodo numeric(5,2),
    modelo_utilizado character varying(100),
    version_modelo character varying(20),
    factores_riesgo text[],
    timestamp_original timestamp without time zone
);


ALTER TABLE public.fact_predicciones OWNER TO edgar;

--
-- TOC entry 231 (class 1259 OID 16741)
-- Name: fact_predicciones_prediccion_id_seq; Type: SEQUENCE; Schema: public; Owner: edgar
--

CREATE SEQUENCE public.fact_predicciones_prediccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fact_predicciones_prediccion_id_seq OWNER TO edgar;

--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 231
-- Name: fact_predicciones_prediccion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: edgar
--

ALTER SEQUENCE public.fact_predicciones_prediccion_id_seq OWNED BY public.fact_predicciones.prediccion_id;


--
-- TOC entry 233 (class 1259 OID 16773)
-- Name: mv_mediciones_dia_planta; Type: MATERIALIZED VIEW; Schema: public; Owner: edgar
--

CREATE MATERIALIZED VIEW public.mv_mediciones_dia_planta AS
 SELECT dt.fecha,
    dt."año",
    dt.mes,
    dp.tipo_planta,
    count(*) AS total_mediciones,
    avg(fm.temperatura) AS temp_promedio,
    avg(fm.humedad) AS humedad_promedio,
    avg(fm.ph) AS ph_promedio,
    avg(fm.nivel_nutrientes) AS nutrientes_promedio,
    min(fm.temperatura) AS temp_min,
    max(fm.temperatura) AS temp_max,
    stddev(fm.temperatura) AS temp_stddev
   FROM ((public.fact_mediciones fm
     JOIN public.dim_tiempo dt ON ((fm.tiempo_id = dt.tiempo_id)))
     JOIN public.dim_planta dp ON ((fm.planta_id = dp.planta_id)))
  GROUP BY dt.fecha, dt."año", dt.mes, dp.tipo_planta
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_mediciones_dia_planta OWNER TO edgar;

--
-- TOC entry 234 (class 1259 OID 16782)
-- Name: mv_predicciones_semana_planta; Type: MATERIALIZED VIEW; Schema: public; Owner: edgar
--

CREATE MATERIALIZED VIEW public.mv_predicciones_semana_planta AS
 SELECT dt."año",
    dt.trimestre,
    dt.semana,
    dp.tipo_planta,
    count(*) AS total_predicciones,
    avg(fp.rendimiento_previsto) AS rendimiento_promedio,
    avg(fp.confianza) AS confianza_promedio,
    min(fp.rendimiento_previsto) AS rendimiento_min,
    max(fp.rendimiento_previsto) AS rendimiento_max,
    sum(
        CASE
            WHEN (fp.confianza >= 0.8) THEN 1
            ELSE 0
        END) AS predicciones_alta_confianza
   FROM ((public.fact_predicciones fp
     JOIN public.dim_tiempo dt ON ((fp.tiempo_id = dt.tiempo_id)))
     JOIN public.dim_planta dp ON ((fp.planta_id = dp.planta_id)))
  GROUP BY dt."año", dt.trimestre, dt.semana, dp.tipo_planta
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_predicciones_semana_planta OWNER TO edgar;

--
-- TOC entry 216 (class 1259 OID 16426)
-- Name: plants; Type: TABLE; Schema: public; Owner: edgar
--

CREATE TABLE public.plants (
    plant_id integer NOT NULL,
    plant_type character varying(50),
    planting_date timestamp without time zone,
    status character varying(20)
);


ALTER TABLE public.plants OWNER TO edgar;

--
-- TOC entry 215 (class 1259 OID 16425)
-- Name: plants_plant_id_seq; Type: SEQUENCE; Schema: public; Owner: edgar
--

CREATE SEQUENCE public.plants_plant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plants_plant_id_seq OWNER TO edgar;

--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 215
-- Name: plants_plant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: edgar
--

ALTER SEQUENCE public.plants_plant_id_seq OWNED BY public.plants.plant_id;


--
-- TOC entry 220 (class 1259 OID 16440)
-- Name: predictions; Type: TABLE; Schema: public; Owner: edgar
--

CREATE TABLE public.predictions (
    prediction_id integer NOT NULL,
    plant_id integer,
    predicted_yield numeric(8,2),
    prediction_date timestamp without time zone,
    confidence numeric(4,3)
);


ALTER TABLE public.predictions OWNER TO edgar;

--
-- TOC entry 219 (class 1259 OID 16439)
-- Name: predictions_prediction_id_seq; Type: SEQUENCE; Schema: public; Owner: edgar
--

CREATE SEQUENCE public.predictions_prediction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.predictions_prediction_id_seq OWNER TO edgar;

--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 219
-- Name: predictions_prediction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: edgar
--

ALTER SEQUENCE public.predictions_prediction_id_seq OWNED BY public.predictions.prediction_id;


--
-- TOC entry 218 (class 1259 OID 16433)
-- Name: sensor_data; Type: TABLE; Schema: public; Owner: edgar
--

CREATE TABLE public.sensor_data (
    id integer NOT NULL,
    sensor_id character varying(50),
    temperature numeric(5,2),
    humidity numeric(5,2),
    soil_moisture numeric(5,2),
    nutrient_level numeric(5,2),
    ph_level numeric(4,2),
    light_intensity numeric(8,2),
    co2_level numeric(6,2),
    "timestamp" timestamp without time zone
);


ALTER TABLE public.sensor_data OWNER TO edgar;

--
-- TOC entry 217 (class 1259 OID 16432)
-- Name: sensor_data_id_seq; Type: SEQUENCE; Schema: public; Owner: edgar
--

CREATE SEQUENCE public.sensor_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sensor_data_id_seq OWNER TO edgar;

--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 217
-- Name: sensor_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: edgar
--

ALTER SEQUENCE public.sensor_data_id_seq OWNED BY public.sensor_data.id;


--
-- TOC entry 3342 (class 2604 OID 16665)
-- Name: dim_planta planta_id; Type: DEFAULT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_planta ALTER COLUMN planta_id SET DEFAULT nextval('public.dim_planta_planta_id_seq'::regclass);


--
-- TOC entry 3343 (class 2604 OID 16674)
-- Name: dim_sensor sensor_id_dim; Type: DEFAULT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_sensor ALTER COLUMN sensor_id_dim SET DEFAULT nextval('public.dim_sensor_sensor_id_dim_seq'::regclass);


--
-- TOC entry 3341 (class 2604 OID 16652)
-- Name: dim_tiempo tiempo_id; Type: DEFAULT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_tiempo ALTER COLUMN tiempo_id SET DEFAULT nextval('public.dim_tiempo_tiempo_id_seq'::regclass);


--
-- TOC entry 3344 (class 2604 OID 16685)
-- Name: dim_ubicacion ubicacion_id; Type: DEFAULT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_ubicacion ALTER COLUMN ubicacion_id SET DEFAULT nextval('public.dim_ubicacion_ubicacion_id_seq'::regclass);


--
-- TOC entry 3345 (class 2604 OID 16693)
-- Name: fact_mediciones medicion_id; Type: DEFAULT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_mediciones ALTER COLUMN medicion_id SET DEFAULT nextval('public.fact_mediciones_medicion_id_seq'::regclass);


--
-- TOC entry 3346 (class 2604 OID 16745)
-- Name: fact_predicciones prediccion_id; Type: DEFAULT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_predicciones ALTER COLUMN prediccion_id SET DEFAULT nextval('public.fact_predicciones_prediccion_id_seq'::regclass);


--
-- TOC entry 3338 (class 2604 OID 16429)
-- Name: plants plant_id; Type: DEFAULT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.plants ALTER COLUMN plant_id SET DEFAULT nextval('public.plants_plant_id_seq'::regclass);


--
-- TOC entry 3340 (class 2604 OID 16443)
-- Name: predictions prediction_id; Type: DEFAULT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.predictions ALTER COLUMN prediction_id SET DEFAULT nextval('public.predictions_prediction_id_seq'::regclass);


--
-- TOC entry 3339 (class 2604 OID 16436)
-- Name: sensor_data id; Type: DEFAULT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.sensor_data ALTER COLUMN id SET DEFAULT nextval('public.sensor_data_id_seq'::regclass);


--
-- TOC entry 3556 (class 0 OID 16662)
-- Dependencies: 224
-- Data for Name: dim_planta; Type: TABLE DATA; Schema: public; Owner: edgar
--

COPY public.dim_planta (planta_id, plant_id, tipo_planta, estado, fecha_siembra, dias_desde_siembra, etapa_crecimiento, variedad, lote) FROM stdin;
\.


--
-- TOC entry 3558 (class 0 OID 16671)
-- Dependencies: 226
-- Data for Name: dim_sensor; Type: TABLE DATA; Schema: public; Owner: edgar
--

COPY public.dim_sensor (sensor_id_dim, sensor_id, tipo_sensor, ubicacion, firmware_version, fecha_instalacion, estado, tipo_planta_monitoreada) FROM stdin;
\.


--
-- TOC entry 3554 (class 0 OID 16649)
-- Dependencies: 222
-- Data for Name: dim_tiempo; Type: TABLE DATA; Schema: public; Owner: edgar
--

COPY public.dim_tiempo (tiempo_id, fecha, "año", trimestre, mes, semana, dia_semana, nombre_dia, es_fin_semana, hora, minuto, timestamp_completo) FROM stdin;
\.


--
-- TOC entry 3560 (class 0 OID 16682)
-- Dependencies: 228
-- Data for Name: dim_ubicacion; Type: TABLE DATA; Schema: public; Owner: edgar
--

COPY public.dim_ubicacion (ubicacion_id, invernadero, sector, rack, posicion, coordenada_x, coordenada_y, zona_climatica) FROM stdin;
\.


--
-- TOC entry 3562 (class 0 OID 16690)
-- Dependencies: 230
-- Data for Name: fact_mediciones; Type: TABLE DATA; Schema: public; Owner: edgar
--

COPY public.fact_mediciones (medicion_id, tiempo_id, planta_id, sensor_id_dim, ubicacion_id, temperatura, humedad, humedad_suelo, nivel_nutrientes, ph, intensidad_luz, co2, temperatura_promedio, humedad_promedio, desviacion_temperatura, calidad_dato, timestamp_original) FROM stdin;
\.


--
-- TOC entry 3564 (class 0 OID 16742)
-- Dependencies: 232
-- Data for Name: fact_predicciones; Type: TABLE DATA; Schema: public; Owner: edgar
--

COPY public.fact_predicciones (prediccion_id, tiempo_id, planta_id, rendimiento_previsto, confianza, dias_hasta_cosecha, temperatura_promedio_periodo, humedad_promedio_periodo, ph_promedio_periodo, nutrientes_promedio_periodo, modelo_utilizado, version_modelo, factores_riesgo, timestamp_original) FROM stdin;
\.


--
-- TOC entry 3548 (class 0 OID 16426)
-- Dependencies: 216
-- Data for Name: plants; Type: TABLE DATA; Schema: public; Owner: edgar
--

COPY public.plants (plant_id, plant_type, planting_date, status) FROM stdin;
1	rabano	2025-10-31 12:59:35.599008	active
2	rabano	2025-10-31 12:59:35.599335	active
3	cilantro	2025-10-31 12:59:35.599516	active
4	cilantro	2025-10-31 12:59:35.599643	active
5	rabano	2025-10-31 12:59:35.599747	active
6	cilantro	2025-10-31 12:59:35.599844	active
\.


--
-- TOC entry 3552 (class 0 OID 16440)
-- Dependencies: 220
-- Data for Name: predictions; Type: TABLE DATA; Schema: public; Owner: edgar
--

COPY public.predictions (prediction_id, plant_id, predicted_yield, prediction_date, confidence) FROM stdin;
1	1	183.92	2025-11-10 13:04:35.985839	0.923
2	2	168.39	2025-11-10 13:04:35.986377	0.927
3	3	119.24	2025-11-10 13:04:35.986534	0.785
4	4	115.51	2025-11-10 13:04:35.986654	0.778
5	5	214.83	2025-11-10 13:04:35.986756	0.929
6	6	127.22	2025-11-10 13:04:35.986855	0.839
7	1	200.78	2025-11-10 13:09:36.372018	0.803
8	2	164.86	2025-11-10 13:09:36.372432	0.886
9	3	110.34	2025-11-10 13:09:36.372577	0.845
10	4	145.59	2025-11-10 13:09:36.372685	0.856
11	5	170.72	2025-11-10 13:09:36.372787	0.838
12	6	152.41	2025-11-10 13:09:36.372884	0.931
13	1	197.79	2025-11-10 17:18:41.46049	0.936
14	2	191.21	2025-11-10 17:18:41.461429	0.770
15	3	129.23	2025-11-10 17:18:41.461569	0.750
16	4	131.99	2025-11-10 17:18:41.461623	0.889
17	5	219.29	2025-11-10 17:18:41.461664	0.722
18	6	145.58	2025-11-10 17:18:41.461701	0.783
19	1	199.63	2025-11-10 17:26:20.817787	0.843
20	2	200.99	2025-11-10 17:26:20.8182	0.814
21	3	106.62	2025-11-10 17:26:20.818351	0.904
22	4	159.04	2025-11-10 17:26:20.818609	0.776
23	5	156.56	2025-11-10 17:26:20.818777	0.766
24	6	122.72	2025-11-10 17:26:20.818908	0.701
25	1	160.06	2025-11-10 17:31:22.627639	0.907
26	2	153.50	2025-11-10 17:31:22.628037	0.869
27	3	150.85	2025-11-10 17:31:22.628209	0.827
28	4	140.49	2025-11-10 17:31:22.628369	0.858
29	5	207.76	2025-11-10 17:31:22.628501	0.894
30	6	117.23	2025-11-10 17:31:22.62867	0.737
31	1	177.66	2025-11-10 17:41:28.204796	0.731
32	2	187.43	2025-11-10 17:41:28.20519	0.868
33	3	111.03	2025-11-10 17:41:28.205333	0.916
34	4	114.68	2025-11-10 17:41:28.205441	0.787
35	5	169.31	2025-11-10 17:41:28.205538	0.751
36	6	142.31	2025-11-10 17:41:28.205632	0.795
37	1	213.04	2025-11-10 17:46:28.549913	0.838
38	2	195.13	2025-11-10 17:46:28.550424	0.915
39	3	114.44	2025-11-10 17:46:28.550625	0.767
40	4	115.24	2025-11-10 17:46:28.550756	0.786
41	5	151.29	2025-11-10 17:46:28.550868	0.941
42	6	128.45	2025-11-10 17:46:28.550966	0.765
43	1	202.40	2025-11-10 17:51:29.500593	0.933
44	2	206.86	2025-11-10 17:51:29.500854	0.712
45	3	115.46	2025-11-10 17:51:29.500915	0.871
46	4	116.56	2025-11-10 17:51:29.500954	0.818
47	5	163.93	2025-11-10 17:51:29.50099	0.839
48	6	150.51	2025-11-10 17:51:29.501024	0.802
49	1	188.14	2025-12-05 17:33:30.845717	0.914
50	2	171.98	2025-12-05 17:33:30.846463	0.900
51	3	122.88	2025-12-05 17:33:30.846544	0.871
52	4	119.58	2025-12-05 17:33:30.846588	0.841
53	5	194.73	2025-12-05 17:33:30.846625	0.701
54	6	142.14	2025-12-05 17:33:30.84666	0.716
55	1	216.53	2025-12-05 17:43:31.585362	0.893
56	2	217.64	2025-12-05 17:43:31.585972	0.864
57	3	158.58	2025-12-05 17:43:31.586165	0.773
58	4	119.55	2025-12-05 17:43:31.586331	0.827
59	5	173.23	2025-12-05 17:43:31.586489	0.895
60	6	135.68	2025-12-05 17:43:31.586682	0.740
61	1	197.57	2025-12-05 17:48:31.971407	0.758
62	2	195.48	2025-12-05 17:48:31.971961	0.826
63	3	106.17	2025-12-05 17:48:31.972192	0.838
64	4	104.80	2025-12-05 17:48:31.972371	0.855
65	5	210.51	2025-12-05 17:48:31.972505	0.793
66	6	122.05	2025-12-05 17:48:31.972667	0.890
67	1	174.90	2025-12-05 17:58:32.741352	0.927
68	2	168.58	2025-12-05 17:58:32.741869	0.885
69	3	144.75	2025-12-05 17:58:32.742046	0.805
70	4	104.98	2025-12-05 17:58:32.742241	0.706
71	5	162.81	2025-12-05 17:58:32.742383	0.796
72	6	143.28	2025-12-05 17:58:32.742517	0.903
73	1	163.69	2025-12-05 19:00:44.291571	0.870
74	2	213.54	2025-12-05 19:00:44.292126	0.727
75	3	104.02	2025-12-05 19:00:44.292298	0.938
76	4	119.65	2025-12-05 19:00:44.292445	0.818
77	5	160.17	2025-12-05 19:00:44.292608	0.777
78	6	159.95	2025-12-05 19:00:44.292735	0.785
79	1	176.38	2025-12-09 22:03:35.381235	0.763
80	2	165.37	2025-12-09 22:03:35.382673	0.907
81	3	135.10	2025-12-09 22:03:35.383007	0.818
82	4	140.29	2025-12-09 22:03:35.383131	0.933
83	5	181.19	2025-12-09 22:03:35.383241	0.919
84	6	154.43	2025-12-09 22:03:35.383337	0.814
85	1	199.64	2025-12-09 22:13:36.106367	0.722
86	2	204.25	2025-12-09 22:13:36.10687	0.753
87	3	150.42	2025-12-09 22:13:36.107061	0.849
88	4	123.34	2025-12-09 22:13:36.107227	0.720
89	5	206.61	2025-12-09 22:13:36.107399	0.713
90	6	144.66	2025-12-09 22:13:36.107567	0.799
91	1	171.12	2025-12-09 22:18:36.477386	0.873
92	2	199.79	2025-12-09 22:18:36.477873	0.901
93	3	144.90	2025-12-09 22:18:36.478066	0.942
94	4	108.93	2025-12-09 22:18:36.478227	0.720
95	5	161.81	2025-12-09 22:18:36.478333	0.762
96	6	100.78	2025-12-09 22:18:36.478429	0.793
\.


--
-- TOC entry 3550 (class 0 OID 16433)
-- Dependencies: 218
-- Data for Name: sensor_data; Type: TABLE DATA; Schema: public; Owner: edgar
--

COPY public.sensor_data (id, sensor_id, temperature, humidity, soil_moisture, nutrient_level, ph_level, light_intensity, co2_level, "timestamp") FROM stdin;
1	sensor_rabano_1	22.74	62.15	72.79	1.89	6.76	852.76	447.86	2025-11-10 12:59:35.611724
2	sensor_rabano_2	22.47	66.23	70.18	1.72	6.58	963.46	438.72	2025-11-10 12:59:35.613643
3	sensor_cilantro_1	21.50	75.35	62.67	1.81	6.71	983.95	493.61	2025-11-10 12:59:35.614033
4	sensor_cilantro_2	22.93	76.96	73.24	1.96	6.43	1169.83	413.82	2025-11-10 12:59:35.614456
5	sensor_rabano_1	20.50	72.48	61.70	1.80	6.79	889.59	496.06	2025-11-10 12:59:45.625163
6	sensor_rabano_2	23.19	71.00	79.71	1.83	6.56	985.85	452.32	2025-11-10 12:59:45.626058
7	sensor_cilantro_1	19.88	75.18	78.77	1.45	6.55	1157.01	493.20	2025-11-10 12:59:45.626306
8	sensor_cilantro_2	21.17	75.91	64.76	1.55	6.41	955.42	473.21	2025-11-10 12:59:45.626507
9	sensor_rabano_1	23.71	64.72	69.47	1.57	6.67	1113.60	494.63	2025-11-10 12:59:55.637015
10	sensor_rabano_2	21.86	67.86	66.27	1.94	6.73	824.37	442.15	2025-11-10 12:59:55.638014
11	sensor_cilantro_1	21.79	77.44	66.97	1.63	6.60	924.49	439.45	2025-11-10 12:59:55.638268
12	sensor_cilantro_2	19.93	67.42	78.08	1.72	6.48	1074.10	419.71	2025-11-10 12:59:55.638433
13	sensor_rabano_1	21.33	58.18	79.63	1.72	6.45	1123.61	405.38	2025-11-10 13:00:05.647864
14	sensor_rabano_2	23.10	63.65	71.01	1.47	6.53	841.04	474.64	2025-11-10 13:00:05.648559
15	sensor_cilantro_1	20.99	65.85	77.55	1.69	6.59	900.69	437.59	2025-11-10 13:00:05.648666
16	sensor_cilantro_2	19.65	77.04	67.60	1.82	6.54	973.98	466.26	2025-11-10 13:00:05.648727
17	sensor_rabano_1	23.85	58.31	79.91	1.85	6.70	1181.93	477.07	2025-11-10 13:00:15.657577
18	sensor_rabano_2	22.02	59.85	78.57	1.44	6.75	1015.59	423.60	2025-11-10 13:00:15.658418
19	sensor_cilantro_1	20.58	74.48	71.50	1.88	6.56	1093.35	489.36	2025-11-10 13:00:15.658642
20	sensor_cilantro_2	20.81	69.45	75.24	1.88	6.46	866.22	460.11	2025-11-10 13:00:15.658802
21	sensor_rabano_1	22.09	70.95	75.69	1.73	6.58	1101.83	480.95	2025-11-10 13:00:25.669372
22	sensor_rabano_2	22.58	64.15	60.57	1.73	6.62	916.06	491.62	2025-11-10 13:00:25.670198
23	sensor_cilantro_1	21.75	75.97	65.11	1.88	6.73	1137.13	481.57	2025-11-10 13:00:25.670391
24	sensor_cilantro_2	19.40	74.75	63.05	1.89	6.79	1160.40	476.53	2025-11-10 13:00:25.670537
25	sensor_rabano_1	21.12	64.95	60.49	1.65	6.78	1176.66	473.67	2025-11-10 13:00:35.680885
26	sensor_rabano_2	22.55	58.28	77.73	1.84	6.68	1096.39	468.10	2025-11-10 13:00:35.681648
27	sensor_cilantro_1	21.34	76.40	69.32	1.41	6.51	953.68	476.24	2025-11-10 13:00:35.68183
28	sensor_cilantro_2	21.28	73.43	68.17	1.90	6.45	1011.59	475.50	2025-11-10 13:00:35.681971
29	sensor_rabano_1	23.58	60.80	74.42	1.57	6.76	1189.60	485.16	2025-11-10 13:00:45.692295
30	sensor_rabano_2	23.46	67.04	78.83	1.91	6.44	1177.82	499.29	2025-11-10 13:00:45.693108
31	sensor_cilantro_1	22.57	71.08	63.02	1.89	6.74	1149.15	463.14	2025-11-10 13:00:45.693316
32	sensor_cilantro_2	21.67	68.21	65.97	1.79	6.49	820.11	495.31	2025-11-10 13:00:45.69346
33	sensor_rabano_1	23.17	72.83	70.29	1.53	6.69	1065.18	403.89	2025-11-10 13:00:55.703712
34	sensor_rabano_2	21.21	71.64	60.94	1.46	6.68	1073.94	450.09	2025-11-10 13:00:55.70457
35	sensor_cilantro_1	20.23	75.69	65.41	1.85	6.60	939.52	407.63	2025-11-10 13:00:55.704793
36	sensor_cilantro_2	21.37	69.29	70.80	1.51	6.53	1142.07	406.95	2025-11-10 13:00:55.704987
37	sensor_rabano_1	20.55	58.86	69.66	1.90	6.69	1075.19	456.53	2025-11-10 13:01:05.714288
38	sensor_rabano_2	20.56	57.08	62.92	1.95	6.56	1116.36	409.23	2025-11-10 13:01:05.715084
39	sensor_cilantro_1	20.19	74.56	66.17	1.65	6.74	1154.85	439.18	2025-11-10 13:01:05.715281
40	sensor_cilantro_2	20.31	77.00	72.91	1.95	6.52	1151.40	496.80	2025-11-10 13:01:05.715363
41	sensor_rabano_1	20.92	65.59	66.12	1.77	6.79	1016.06	415.93	2025-11-10 13:01:15.725998
42	sensor_rabano_2	21.56	67.11	77.97	1.74	6.80	1134.62	469.05	2025-11-10 13:01:15.726817
43	sensor_cilantro_1	19.52	74.06	73.58	1.55	6.69	1116.14	468.72	2025-11-10 13:01:15.726993
44	sensor_cilantro_2	22.48	68.49	61.75	1.71	6.70	1114.97	421.69	2025-11-10 13:01:15.72713
45	sensor_rabano_1	20.43	67.28	64.77	1.60	6.47	1157.93	457.66	2025-11-10 13:01:25.738449
46	sensor_rabano_2	22.09	60.69	60.86	1.91	6.71	906.64	490.20	2025-11-10 13:01:25.739324
47	sensor_cilantro_1	20.89	63.38	61.26	1.56	6.45	1032.12	476.37	2025-11-10 13:01:25.739529
48	sensor_cilantro_2	19.47	74.10	77.46	1.91	6.53	815.02	407.70	2025-11-10 13:01:25.73968
49	sensor_rabano_1	23.55	72.00	63.88	1.88	6.68	1034.53	451.89	2025-11-10 13:01:35.749774
50	sensor_rabano_2	23.48	69.40	60.69	1.87	6.63	1082.69	460.73	2025-11-10 13:01:35.75053
51	sensor_cilantro_1	21.71	74.25	75.46	1.92	6.78	1190.78	470.84	2025-11-10 13:01:35.750706
52	sensor_cilantro_2	19.74	71.77	64.44	1.71	6.72	801.91	496.91	2025-11-10 13:01:35.750847
53	sensor_rabano_1	21.72	65.70	77.49	1.83	6.79	1167.66	409.70	2025-11-10 13:01:45.760698
54	sensor_rabano_2	23.82	63.90	68.17	1.61	6.64	818.78	403.26	2025-11-10 13:01:45.761753
55	sensor_cilantro_1	22.73	72.37	69.99	1.41	6.70	1020.00	498.73	2025-11-10 13:01:45.762013
56	sensor_cilantro_2	22.27	75.87	66.63	1.75	6.44	925.44	497.21	2025-11-10 13:01:45.762225
57	sensor_rabano_1	21.76	65.54	70.85	1.90	6.49	1167.83	466.13	2025-11-10 13:01:55.772286
58	sensor_rabano_2	21.65	69.82	61.75	1.56	6.50	1133.41	444.66	2025-11-10 13:01:55.772888
59	sensor_cilantro_1	19.35	64.68	61.82	1.66	6.62	1048.22	458.98	2025-11-10 13:01:55.773268
60	sensor_cilantro_2	22.30	71.49	77.74	1.44	6.74	852.46	416.78	2025-11-10 13:01:55.773515
61	sensor_rabano_1	20.67	67.99	65.21	1.82	6.55	934.96	497.91	2025-11-10 13:02:05.783437
62	sensor_rabano_2	23.27	59.01	69.51	1.93	6.70	966.26	497.00	2025-11-10 13:02:05.784378
63	sensor_cilantro_1	21.20	68.55	65.22	1.44	6.54	1158.59	429.61	2025-11-10 13:02:05.784668
64	sensor_cilantro_2	19.31	67.99	60.55	1.89	6.79	1165.12	408.80	2025-11-10 13:02:05.78487
65	sensor_rabano_1	20.63	63.05	66.04	1.74	6.60	922.20	425.21	2025-11-10 13:02:15.797491
66	sensor_rabano_2	20.47	63.30	60.49	1.83	6.78	1044.80	435.96	2025-11-10 13:02:15.7981
67	sensor_cilantro_1	22.81	63.24	63.25	1.85	6.70	1080.02	421.23	2025-11-10 13:02:15.798186
68	sensor_cilantro_2	22.06	67.48	72.45	1.67	6.54	1160.46	444.18	2025-11-10 13:02:15.798244
69	sensor_rabano_1	22.18	64.26	79.16	1.60	6.65	880.93	454.22	2025-11-10 13:02:25.809586
70	sensor_rabano_2	23.97	62.41	75.29	1.66	6.70	803.88	474.38	2025-11-10 13:02:25.810422
71	sensor_cilantro_1	20.88	67.10	64.19	1.88	6.54	953.39	462.13	2025-11-10 13:02:25.810609
72	sensor_cilantro_2	22.53	66.88	65.85	1.81	6.69	1012.24	407.70	2025-11-10 13:02:25.810755
73	sensor_rabano_1	20.35	66.37	71.59	1.93	6.71	887.93	413.04	2025-11-10 13:02:35.82184
74	sensor_rabano_2	20.42	64.25	61.80	1.97	6.75	985.46	449.88	2025-11-10 13:02:35.82238
75	sensor_cilantro_1	21.66	72.66	64.34	1.52	6.41	993.42	412.47	2025-11-10 13:02:35.822467
76	sensor_cilantro_2	21.32	62.42	66.09	1.72	6.43	1000.25	400.14	2025-11-10 13:02:35.822527
77	sensor_rabano_1	22.64	72.21	67.71	1.79	6.73	883.99	468.59	2025-11-10 13:02:45.834451
78	sensor_rabano_2	21.33	60.84	78.95	1.49	6.54	849.02	479.78	2025-11-10 13:02:45.835335
79	sensor_cilantro_1	19.71	68.97	60.69	1.62	6.57	1054.98	444.44	2025-11-10 13:02:45.835602
80	sensor_cilantro_2	19.66	74.88	71.90	1.65	6.58	1011.91	415.07	2025-11-10 13:02:45.835806
81	sensor_rabano_1	21.81	67.14	65.88	1.69	6.43	940.98	477.51	2025-11-10 13:02:55.846452
82	sensor_rabano_2	22.59	62.91	65.64	1.51	6.47	956.29	422.09	2025-11-10 13:02:55.847516
83	sensor_cilantro_1	20.53	68.80	73.18	1.88	6.64	850.58	477.54	2025-11-10 13:02:55.847839
84	sensor_cilantro_2	20.60	69.91	76.04	1.74	6.50	1074.03	450.71	2025-11-10 13:02:55.848006
85	sensor_rabano_1	22.02	58.38	73.29	1.98	6.67	1197.21	441.48	2025-11-10 13:03:05.859508
86	sensor_rabano_2	22.55	65.51	61.75	1.49	6.78	1089.47	435.51	2025-11-10 13:03:05.860463
87	sensor_cilantro_1	19.07	63.16	60.39	1.58	6.75	1079.44	463.96	2025-11-10 13:03:05.860653
88	sensor_cilantro_2	22.73	76.53	66.02	1.80	6.49	1186.93	405.45	2025-11-10 13:03:05.860797
89	sensor_rabano_1	20.60	63.19	70.11	1.41	6.61	1187.47	491.26	2025-11-10 13:03:15.872302
90	sensor_rabano_2	20.54	61.57	62.45	1.69	6.46	904.99	492.31	2025-11-10 13:03:15.873125
91	sensor_cilantro_1	22.11	77.16	70.80	1.63	6.59	1016.54	479.16	2025-11-10 13:03:15.873364
92	sensor_cilantro_2	22.85	72.61	66.36	1.81	6.62	1006.23	487.80	2025-11-10 13:03:15.873521
93	sensor_rabano_1	22.15	58.49	71.22	1.54	6.75	1134.72	408.07	2025-11-10 13:03:25.885178
94	sensor_rabano_2	22.84	66.08	65.08	1.90	6.78	931.09	439.05	2025-11-10 13:03:25.886065
95	sensor_cilantro_1	22.39	77.64	66.70	1.49	6.61	973.49	417.75	2025-11-10 13:03:25.886272
96	sensor_cilantro_2	20.51	77.16	61.31	1.67	6.65	1085.45	423.84	2025-11-10 13:03:25.886423
97	sensor_rabano_1	22.64	61.40	68.87	1.73	6.64	1173.02	410.63	2025-11-10 13:03:35.898431
98	sensor_rabano_2	20.59	58.43	60.08	1.87	6.42	817.33	450.28	2025-11-10 13:03:35.899382
99	sensor_cilantro_1	19.20	72.86	64.85	1.91	6.79	835.90	414.71	2025-11-10 13:03:35.899617
100	sensor_cilantro_2	20.88	64.12	61.73	1.63	6.73	1145.32	403.68	2025-11-10 13:03:35.899819
101	sensor_rabano_1	22.55	58.88	78.74	1.72	6.50	881.00	475.15	2025-11-10 13:03:45.910102
102	sensor_rabano_2	23.24	59.92	73.00	1.84	6.77	1057.55	430.35	2025-11-10 13:03:45.911006
103	sensor_cilantro_1	19.16	67.30	79.32	1.94	6.71	1067.32	457.42	2025-11-10 13:03:45.91127
104	sensor_cilantro_2	19.57	64.86	75.95	1.57	6.72	1064.27	434.16	2025-11-10 13:03:45.911474
105	sensor_rabano_1	22.08	72.34	65.15	1.82	6.49	877.26	409.57	2025-11-10 13:03:55.923066
106	sensor_rabano_2	20.80	63.11	74.76	1.94	6.46	1176.11	476.19	2025-11-10 13:03:55.924102
107	sensor_cilantro_1	22.69	72.37	63.83	1.98	6.40	1014.46	430.32	2025-11-10 13:03:55.924554
108	sensor_cilantro_2	19.94	76.70	75.14	1.70	6.57	885.95	420.94	2025-11-10 13:03:55.92487
109	sensor_rabano_1	20.73	58.58	75.47	1.49	6.64	945.13	485.66	2025-11-10 13:04:05.936123
110	sensor_rabano_2	20.44	70.31	77.24	1.83	6.56	1053.81	469.07	2025-11-10 13:04:05.937006
111	sensor_cilantro_1	22.37	77.80	76.32	1.65	6.61	995.30	495.52	2025-11-10 13:04:05.937198
112	sensor_cilantro_2	22.76	67.02	70.08	1.95	6.57	1174.90	487.77	2025-11-10 13:04:05.937347
113	sensor_rabano_1	23.96	60.89	79.63	1.45	6.67	1088.89	425.41	2025-11-10 13:04:15.947211
114	sensor_rabano_2	23.69	57.43	79.79	1.80	6.65	1155.77	400.00	2025-11-10 13:04:15.948036
115	sensor_cilantro_1	21.66	72.33	63.93	1.63	6.58	1099.84	480.31	2025-11-10 13:04:15.948274
116	sensor_cilantro_2	20.60	62.59	79.26	1.98	6.52	907.92	469.28	2025-11-10 13:04:15.948469
117	sensor_rabano_1	21.89	66.69	74.48	1.60	6.62	921.50	463.25	2025-11-10 13:04:25.95866
118	sensor_rabano_2	20.77	64.63	79.81	1.53	6.44	1143.31	403.65	2025-11-10 13:04:25.959516
119	sensor_cilantro_1	19.31	73.38	76.92	1.58	6.45	1179.14	477.47	2025-11-10 13:04:25.960502
120	sensor_cilantro_2	21.00	68.06	71.41	1.66	6.58	1182.83	422.42	2025-11-10 13:04:25.960773
121	sensor_rabano_1	22.88	57.33	63.56	1.97	6.44	1192.75	405.79	2025-11-10 13:04:35.972349
122	sensor_rabano_2	21.89	70.49	76.79	1.65	6.52	1001.49	488.18	2025-11-10 13:04:35.973174
123	sensor_cilantro_1	22.48	76.74	63.17	1.43	6.47	861.06	410.39	2025-11-10 13:04:35.973357
124	sensor_cilantro_2	21.78	63.98	64.91	1.65	6.74	1086.41	482.36	2025-11-10 13:04:35.973499
125	sensor_rabano_1	20.44	60.63	75.04	1.65	6.61	907.85	410.53	2025-11-10 13:04:45.996847
126	sensor_rabano_2	20.16	62.81	66.59	1.77	6.54	938.73	459.16	2025-11-10 13:04:45.997628
127	sensor_cilantro_1	19.12	66.45	78.93	1.66	6.46	1142.25	422.60	2025-11-10 13:04:45.997803
128	sensor_cilantro_2	21.48	64.97	77.38	1.48	6.68	918.85	478.46	2025-11-10 13:04:45.997941
129	sensor_rabano_1	22.51	66.67	61.49	1.61	6.53	1185.84	483.76	2025-11-10 13:04:56.009625
130	sensor_rabano_2	22.12	63.27	61.77	1.79	6.69	843.43	449.72	2025-11-10 13:04:56.01047
131	sensor_cilantro_1	22.89	65.07	72.30	1.84	6.45	922.87	470.40	2025-11-10 13:04:56.01068
132	sensor_cilantro_2	21.32	72.40	65.49	1.50	6.51	1174.87	457.73	2025-11-10 13:04:56.010847
133	sensor_rabano_1	21.03	68.70	66.05	1.56	6.70	1048.64	432.76	2025-11-10 13:05:06.020467
134	sensor_rabano_2	20.94	63.01	64.77	1.96	6.48	917.50	411.50	2025-11-10 13:05:06.021422
135	sensor_cilantro_1	22.09	62.37	60.08	1.98	6.56	858.42	478.20	2025-11-10 13:05:06.021692
136	sensor_cilantro_2	20.52	72.73	73.64	1.50	6.43	871.74	424.50	2025-11-10 13:05:06.021876
137	sensor_rabano_1	23.40	65.95	74.65	1.64	6.79	835.14	426.71	2025-11-10 13:05:16.032251
138	sensor_rabano_2	20.81	65.69	64.23	1.58	6.74	1051.14	405.72	2025-11-10 13:05:16.033199
139	sensor_cilantro_1	22.83	75.29	74.12	1.91	6.52	832.60	434.94	2025-11-10 13:05:16.033404
140	sensor_cilantro_2	20.26	66.17	63.29	1.93	6.48	1163.34	416.06	2025-11-10 13:05:16.033552
141	sensor_rabano_1	22.58	57.34	71.46	1.62	6.58	864.18	491.02	2025-11-10 13:05:26.045452
142	sensor_rabano_2	21.32	62.34	70.25	1.47	6.79	826.47	478.33	2025-11-10 13:05:26.046333
143	sensor_cilantro_1	19.86	77.17	64.76	1.79	6.41	831.02	468.37	2025-11-10 13:05:26.046523
144	sensor_cilantro_2	20.48	68.71	70.72	1.69	6.58	1191.42	421.33	2025-11-10 13:05:26.046669
145	sensor_rabano_1	21.47	60.33	71.01	1.86	6.51	1165.49	410.35	2025-11-10 13:05:36.058604
146	sensor_rabano_2	23.15	65.23	73.38	1.74	6.49	869.54	412.36	2025-11-10 13:05:36.059484
147	sensor_cilantro_1	21.46	77.88	68.30	1.74	6.49	1059.34	468.78	2025-11-10 13:05:36.059716
148	sensor_cilantro_2	22.49	65.03	77.62	1.93	6.74	1128.69	473.93	2025-11-10 13:05:36.059879
149	sensor_rabano_1	20.90	72.63	61.62	1.42	6.57	1054.25	434.80	2025-11-10 13:05:46.071641
150	sensor_rabano_2	22.22	61.44	64.44	1.74	6.43	1083.66	490.37	2025-11-10 13:05:46.072215
151	sensor_cilantro_1	21.58	71.00	63.66	1.97	6.60	1149.77	470.50	2025-11-10 13:05:46.072449
152	sensor_cilantro_2	20.17	77.38	67.60	1.85	6.47	1139.06	497.51	2025-11-10 13:05:46.072655
153	sensor_rabano_1	23.45	60.16	66.98	1.48	6.64	1126.06	419.02	2025-11-10 13:05:56.084367
154	sensor_rabano_2	21.07	59.63	77.08	1.83	6.64	804.08	464.45	2025-11-10 13:05:56.085193
155	sensor_cilantro_1	19.15	69.66	67.88	1.97	6.59	1008.20	484.01	2025-11-10 13:05:56.085426
156	sensor_cilantro_2	21.90	62.95	72.83	1.57	6.67	1142.57	407.80	2025-11-10 13:05:56.085584
157	sensor_rabano_1	22.44	59.31	67.84	1.54	6.56	958.31	485.40	2025-11-10 13:06:06.097137
158	sensor_rabano_2	21.82	61.28	69.24	1.50	6.54	886.65	496.85	2025-11-10 13:06:06.098022
159	sensor_cilantro_1	22.88	72.18	69.46	1.99	6.72	1045.83	450.36	2025-11-10 13:06:06.098221
160	sensor_cilantro_2	20.72	65.83	61.97	1.92	6.53	923.07	494.21	2025-11-10 13:06:06.09841
161	sensor_rabano_1	21.77	63.20	77.82	1.45	6.79	800.71	473.30	2025-11-10 13:06:16.108034
162	sensor_rabano_2	20.76	70.14	67.26	1.68	6.45	841.97	453.16	2025-11-10 13:06:16.108556
163	sensor_cilantro_1	21.01	71.44	68.41	1.82	6.47	1156.03	440.16	2025-11-10 13:06:16.108637
164	sensor_cilantro_2	20.77	68.39	79.27	1.45	6.72	873.87	426.35	2025-11-10 13:06:16.108692
165	sensor_rabano_1	23.83	61.15	74.09	1.94	6.61	852.85	459.63	2025-11-10 13:06:26.12054
166	sensor_rabano_2	23.05	66.25	74.05	1.87	6.57	894.09	420.30	2025-11-10 13:06:26.121431
167	sensor_cilantro_1	20.31	62.74	74.43	1.69	6.68	963.77	483.93	2025-11-10 13:06:26.121656
168	sensor_cilantro_2	20.18	63.19	60.01	1.79	6.52	938.58	406.91	2025-11-10 13:06:26.121811
169	sensor_rabano_1	21.25	58.26	75.44	1.49	6.47	1073.54	481.65	2025-11-10 13:06:36.133463
170	sensor_rabano_2	21.51	70.51	62.71	1.83	6.80	1127.75	495.54	2025-11-10 13:06:36.134286
171	sensor_cilantro_1	21.34	63.24	63.68	1.69	6.71	952.59	462.31	2025-11-10 13:06:36.134465
172	sensor_cilantro_2	20.92	67.61	64.65	1.56	6.41	839.87	499.97	2025-11-10 13:06:36.134608
173	sensor_rabano_1	22.90	71.24	68.94	1.78	6.74	860.81	441.55	2025-11-10 13:06:46.144778
174	sensor_rabano_2	23.07	66.86	68.80	1.75	6.57	1123.76	492.52	2025-11-10 13:06:46.145609
175	sensor_cilantro_1	19.72	66.11	74.56	1.49	6.56	1021.01	403.11	2025-11-10 13:06:46.145796
176	sensor_cilantro_2	19.30	72.91	68.30	1.96	6.67	850.87	453.45	2025-11-10 13:06:46.145938
177	sensor_rabano_1	22.22	60.72	63.33	1.66	6.66	824.49	410.77	2025-11-10 13:06:56.157528
178	sensor_rabano_2	21.75	70.43	79.06	1.80	6.74	878.59	433.29	2025-11-10 13:06:56.158365
179	sensor_cilantro_1	21.01	62.30	69.24	1.50	6.55	828.28	436.29	2025-11-10 13:06:56.158554
180	sensor_cilantro_2	19.51	74.63	74.07	1.77	6.42	1103.97	418.56	2025-11-10 13:06:56.158699
181	sensor_rabano_1	22.86	67.74	70.98	1.97	6.59	1025.31	475.48	2025-11-10 13:07:06.170405
182	sensor_rabano_2	20.96	61.53	76.82	1.88	6.42	948.02	470.30	2025-11-10 13:07:06.17135
183	sensor_cilantro_1	22.56	67.58	64.45	1.89	6.69	1072.36	459.48	2025-11-10 13:07:06.171586
184	sensor_cilantro_2	21.20	62.97	60.89	1.95	6.63	1159.49	433.86	2025-11-10 13:07:06.171802
185	sensor_rabano_1	23.13	64.69	65.57	1.81	6.60	807.77	474.99	2025-11-10 13:07:16.183632
186	sensor_rabano_2	22.54	71.25	62.49	1.63	6.75	1158.37	411.14	2025-11-10 13:07:16.184332
187	sensor_cilantro_1	20.35	71.56	73.73	1.59	6.64	851.03	474.89	2025-11-10 13:07:16.184584
188	sensor_cilantro_2	19.57	69.87	79.82	1.93	6.41	1113.45	428.20	2025-11-10 13:07:16.184673
189	sensor_rabano_1	23.41	62.50	60.46	1.64	6.65	1136.38	435.04	2025-11-10 13:07:26.19667
190	sensor_rabano_2	23.54	65.53	76.17	1.56	6.73	1125.43	453.17	2025-11-10 13:07:26.197682
191	sensor_cilantro_1	20.72	62.04	73.36	1.72	6.58	1116.52	448.09	2025-11-10 13:07:26.197948
192	sensor_cilantro_2	19.73	69.07	69.13	1.82	6.54	847.88	405.92	2025-11-10 13:07:26.198139
193	sensor_rabano_1	23.02	59.64	62.11	1.49	6.77	877.81	450.04	2025-11-10 13:07:36.208978
194	sensor_rabano_2	23.02	64.09	78.65	1.59	6.43	992.14	499.61	2025-11-10 13:07:36.209736
195	sensor_cilantro_1	20.37	66.70	78.68	1.66	6.73	1072.37	404.64	2025-11-10 13:07:36.209913
196	sensor_cilantro_2	22.76	74.25	77.41	1.70	6.52	1194.99	432.77	2025-11-10 13:07:36.210049
197	sensor_rabano_1	22.75	58.98	69.54	1.99	6.75	1157.05	420.99	2025-11-10 13:07:46.222213
198	sensor_rabano_2	23.80	69.25	71.12	1.65	6.49	816.77	434.60	2025-11-10 13:07:46.223159
199	sensor_cilantro_1	20.23	72.26	62.01	1.57	6.52	937.09	456.56	2025-11-10 13:07:46.22344
200	sensor_cilantro_2	22.19	64.59	66.16	1.95	6.58	1113.40	403.15	2025-11-10 13:07:46.223648
201	sensor_rabano_1	21.88	63.36	76.92	1.49	6.46	1057.71	415.91	2025-11-10 13:07:56.233882
202	sensor_rabano_2	23.51	63.63	64.00	1.87	6.71	1057.16	486.29	2025-11-10 13:07:56.234739
203	sensor_cilantro_1	20.49	75.69	74.79	1.98	6.56	1170.75	480.43	2025-11-10 13:07:56.234927
204	sensor_cilantro_2	22.54	77.91	70.79	1.42	6.55	927.64	431.12	2025-11-10 13:07:56.235097
205	sensor_rabano_1	23.44	66.70	72.73	1.70	6.53	915.72	458.24	2025-11-10 13:08:06.245215
206	sensor_rabano_2	22.19	69.83	67.67	1.74	6.46	982.65	435.80	2025-11-10 13:08:06.246063
207	sensor_cilantro_1	21.23	69.78	65.56	1.40	6.79	838.47	448.74	2025-11-10 13:08:06.24626
208	sensor_cilantro_2	22.63	65.71	72.34	1.57	6.76	1139.95	447.06	2025-11-10 13:08:06.246407
209	sensor_rabano_1	23.31	60.77	70.79	1.58	6.59	1169.61	481.79	2025-11-10 13:08:16.258066
210	sensor_rabano_2	21.21	57.35	62.39	1.64	6.41	849.86	484.84	2025-11-10 13:08:16.258988
211	sensor_cilantro_1	19.65	74.52	73.41	1.77	6.41	1162.90	488.46	2025-11-10 13:08:16.259179
212	sensor_cilantro_2	20.21	71.89	68.62	1.41	6.51	846.58	441.00	2025-11-10 13:08:16.25942
213	sensor_rabano_1	20.87	67.14	76.46	1.68	6.45	879.69	485.35	2025-11-10 13:08:26.270956
214	sensor_rabano_2	23.43	72.56	70.03	1.91	6.75	972.87	492.62	2025-11-10 13:08:26.271717
215	sensor_cilantro_1	20.63	74.66	77.78	1.92	6.58	1076.81	439.82	2025-11-10 13:08:26.271895
216	sensor_cilantro_2	20.64	63.13	64.07	1.48	6.63	1143.06	494.25	2025-11-10 13:08:26.272041
217	sensor_rabano_1	23.48	62.75	70.74	1.46	6.67	1045.80	420.45	2025-11-10 13:08:36.287011
218	sensor_rabano_2	22.13	60.24	61.53	1.51	6.61	853.90	420.70	2025-11-10 13:08:36.288117
219	sensor_cilantro_1	22.63	63.20	73.80	1.67	6.61	1050.89	498.76	2025-11-10 13:08:36.288444
220	sensor_cilantro_2	20.66	77.18	71.57	1.45	6.42	805.60	409.30	2025-11-10 13:08:36.288671
221	sensor_rabano_1	23.04	58.91	79.59	1.69	6.62	962.00	418.41	2025-11-10 13:08:46.298957
222	sensor_rabano_2	23.83	66.59	60.59	1.84	6.47	940.40	412.51	2025-11-10 13:08:46.299713
223	sensor_cilantro_1	19.68	66.00	68.54	1.79	6.42	1078.32	429.50	2025-11-10 13:08:46.299884
224	sensor_cilantro_2	21.74	71.17	79.33	1.44	6.42	1035.72	477.16	2025-11-10 13:08:46.300023
225	sensor_rabano_1	23.54	57.57	71.73	1.67	6.42	1051.83	402.29	2025-11-10 13:08:56.310541
226	sensor_rabano_2	21.50	72.58	65.29	1.89	6.42	987.60	437.36	2025-11-10 13:08:56.311395
227	sensor_cilantro_1	19.19	69.84	70.90	1.98	6.76	1174.13	439.69	2025-11-10 13:08:56.311693
228	sensor_cilantro_2	20.96	74.02	66.02	1.72	6.49	916.07	487.71	2025-11-10 13:08:56.311863
229	sensor_rabano_1	22.40	60.89	66.90	1.42	6.59	910.99	488.29	2025-11-10 13:09:06.323463
230	sensor_rabano_2	21.08	69.66	78.50	1.87	6.69	945.76	485.60	2025-11-10 13:09:06.324393
231	sensor_cilantro_1	20.27	64.56	75.70	1.65	6.47	959.04	432.59	2025-11-10 13:09:06.324615
232	sensor_cilantro_2	20.86	73.25	63.28	1.97	6.77	813.59	478.56	2025-11-10 13:09:06.324774
233	sensor_rabano_1	20.03	70.89	66.01	1.63	6.53	1017.88	488.90	2025-11-10 13:09:16.336933
234	sensor_rabano_2	20.36	67.21	62.96	1.97	6.57	1168.98	466.90	2025-11-10 13:09:16.33799
235	sensor_cilantro_1	20.58	69.84	69.62	1.40	6.62	1040.19	405.54	2025-11-10 13:09:16.338214
236	sensor_cilantro_2	19.03	62.78	70.70	1.88	6.43	1018.63	426.72	2025-11-10 13:09:16.338525
237	sensor_rabano_1	21.76	60.20	65.24	1.57	6.55	1009.52	489.57	2025-11-10 13:09:26.349854
238	sensor_rabano_2	22.78	63.14	65.30	1.74	6.72	1097.58	433.99	2025-11-10 13:09:26.350614
239	sensor_cilantro_1	19.87	75.58	61.12	1.42	6.55	1134.26	464.38	2025-11-10 13:09:26.350789
240	sensor_cilantro_2	20.61	67.11	79.21	1.89	6.75	1185.19	496.38	2025-11-10 13:09:26.350929
241	sensor_rabano_1	22.43	68.47	62.71	1.66	6.66	910.15	455.66	2025-11-10 13:09:36.360342
242	sensor_rabano_2	23.26	70.33	72.73	1.91	6.60	911.99	412.77	2025-11-10 13:09:36.361249
243	sensor_cilantro_1	22.17	69.12	71.64	1.44	6.72	1132.24	470.79	2025-11-10 13:09:36.361478
244	sensor_cilantro_2	21.43	71.62	75.41	2.00	6.50	828.32	427.91	2025-11-10 13:09:36.361675
245	sensor_rabano_1	23.74	58.04	66.68	1.81	6.50	1192.53	459.71	2025-11-10 13:09:46.382866
246	sensor_rabano_2	22.87	60.09	74.44	1.49	6.70	861.90	410.41	2025-11-10 13:09:46.383765
247	sensor_cilantro_1	19.41	67.10	72.14	1.56	6.61	1010.52	438.39	2025-11-10 13:09:46.383958
248	sensor_cilantro_2	19.87	69.10	63.32	1.96	6.49	1005.18	436.64	2025-11-10 13:09:46.384105
249	sensor_rabano_1	20.76	65.97	65.33	1.66	6.59	895.67	492.36	2025-11-10 13:09:56.395331
250	sensor_rabano_2	23.26	67.80	75.57	1.94	6.69	858.29	482.69	2025-11-10 13:09:56.396128
251	sensor_cilantro_1	22.52	62.24	65.72	1.97	6.70	815.95	462.90	2025-11-10 13:09:56.396358
252	sensor_cilantro_2	19.73	67.54	78.62	1.55	6.53	951.82	423.65	2025-11-10 13:09:56.396561
253	sensor_rabano_1	20.68	63.65	64.42	1.68	6.79	1009.39	441.21	2025-11-10 13:10:06.408459
254	sensor_rabano_2	23.64	59.23	64.22	1.43	6.46	842.41	419.00	2025-11-10 13:10:06.409348
255	sensor_cilantro_1	19.82	72.75	60.03	1.89	6.66	1079.70	449.49	2025-11-10 13:10:06.409539
256	sensor_cilantro_2	21.50	66.98	75.22	1.67	6.75	1188.11	470.42	2025-11-10 13:10:06.409684
257	sensor_rabano_1	23.87	65.92	78.99	1.69	6.75	1059.20	442.49	2025-11-10 13:10:16.421532
258	sensor_rabano_2	20.10	70.62	75.56	1.91	6.51	815.89	405.27	2025-11-10 13:10:16.422399
259	sensor_cilantro_1	20.01	69.45	66.55	1.49	6.63	830.66	465.53	2025-11-10 13:10:16.422645
260	sensor_cilantro_2	19.28	62.77	61.12	1.54	6.41	821.50	422.89	2025-11-10 13:10:16.422805
261	sensor_rabano_1	22.31	63.53	68.46	1.85	6.48	1098.85	473.39	2025-11-10 13:10:26.432931
262	sensor_rabano_2	21.85	57.71	63.49	1.77	6.76	1044.16	462.72	2025-11-10 13:10:26.433718
263	sensor_cilantro_1	22.01	68.16	70.07	1.86	6.57	904.80	410.06	2025-11-10 13:10:26.433904
264	sensor_cilantro_2	20.25	72.20	63.84	1.98	6.55	1011.24	408.43	2025-11-10 13:10:26.434046
265	sensor_rabano_1	23.65	63.98	75.99	1.86	6.67	982.22	441.45	2025-11-10 13:10:36.446248
266	sensor_rabano_2	23.98	72.44	73.54	1.69	6.51	900.93	408.37	2025-11-10 13:10:36.447153
267	sensor_cilantro_1	19.36	75.70	70.41	1.43	6.78	1141.43	466.86	2025-11-10 13:10:36.447365
268	sensor_cilantro_2	22.26	72.64	70.45	1.96	6.40	816.24	438.11	2025-11-10 13:10:36.447533
269	sensor_rabano_1	22.36	64.64	64.25	1.71	6.79	1165.02	415.98	2025-11-10 13:10:46.459462
270	sensor_rabano_2	20.54	61.34	75.83	1.41	6.55	812.19	493.33	2025-11-10 13:10:46.460319
271	sensor_cilantro_1	19.10	62.49	77.39	1.62	6.69	803.97	493.09	2025-11-10 13:10:46.460509
272	sensor_cilantro_2	22.79	64.65	74.63	1.44	6.58	1134.89	422.93	2025-11-10 13:10:46.460653
273	sensor_rabano_1	22.90	57.24	69.98	1.85	6.46	901.72	449.87	2025-11-10 13:10:56.472347
274	sensor_rabano_2	20.75	64.89	68.93	1.68	6.55	1139.72	433.19	2025-11-10 13:10:56.473127
275	sensor_cilantro_1	19.74	77.02	61.82	1.60	6.66	1078.92	460.84	2025-11-10 13:10:56.473313
276	sensor_cilantro_2	20.82	63.17	70.66	1.78	6.43	922.19	450.61	2025-11-10 13:10:56.473457
277	sensor_rabano_1	22.84	72.65	77.91	1.83	6.50	1149.21	400.49	2025-11-10 13:11:06.485943
278	sensor_rabano_2	21.18	72.82	66.18	1.98	6.48	975.01	444.09	2025-11-10 13:11:06.486929
279	sensor_cilantro_1	20.83	63.57	67.82	1.72	6.41	919.69	454.56	2025-11-10 13:11:06.487137
280	sensor_cilantro_2	20.60	73.91	62.02	1.82	6.46	920.77	426.46	2025-11-10 13:11:06.487402
281	sensor_rabano_1	20.65	63.21	63.57	1.85	6.74	905.70	446.14	2025-11-10 13:11:16.498729
282	sensor_rabano_2	22.42	70.22	60.88	1.70	6.52	902.70	401.43	2025-11-10 13:11:16.499613
283	sensor_cilantro_1	22.39	76.28	76.50	1.90	6.42	892.96	423.66	2025-11-10 13:11:16.499838
284	sensor_cilantro_2	21.74	77.12	61.14	1.72	6.75	1103.83	445.34	2025-11-10 13:11:16.499996
285	sensor_rabano_1	21.18	71.03	75.80	1.72	6.67	981.19	413.64	2025-11-10 13:11:26.511646
286	sensor_rabano_2	21.59	65.43	60.16	1.64	6.62	1118.55	469.78	2025-11-10 13:11:26.512394
287	sensor_cilantro_1	20.56	75.55	73.08	1.41	6.50	923.55	402.04	2025-11-10 13:11:26.512569
288	sensor_cilantro_2	19.13	71.37	73.52	1.60	6.41	835.09	437.81	2025-11-10 13:11:26.512708
289	sensor_rabano_1	21.42	62.91	68.88	1.57	6.46	1182.43	412.77	2025-11-10 13:11:36.524217
290	sensor_rabano_2	22.95	65.21	75.16	1.59	6.45	1135.12	450.73	2025-11-10 13:11:36.52513
291	sensor_cilantro_1	21.08	67.34	61.83	1.64	6.62	1081.89	443.80	2025-11-10 13:11:36.525374
292	sensor_cilantro_2	20.17	64.96	76.71	1.71	6.55	820.14	488.53	2025-11-10 13:11:36.525522
293	sensor_rabano_1	23.51	57.97	64.06	1.63	6.45	963.07	470.91	2025-11-10 13:11:46.537205
294	sensor_rabano_2	22.25	61.85	62.54	1.92	6.64	887.15	478.52	2025-11-10 13:11:46.538097
295	sensor_cilantro_1	20.43	69.75	61.91	1.68	6.57	1089.91	447.82	2025-11-10 13:11:46.538349
296	sensor_cilantro_2	20.76	71.66	74.10	1.54	6.66	931.20	404.52	2025-11-10 13:11:46.538552
297	sensor_rabano_1	22.83	58.16	71.54	1.78	6.61	836.59	469.20	2025-11-10 13:11:56.54917
298	sensor_rabano_2	22.15	69.16	64.60	1.54	6.63	914.25	452.03	2025-11-10 13:11:56.549985
299	sensor_cilantro_1	21.97	75.17	74.38	1.78	6.77	880.95	491.04	2025-11-10 13:11:56.550163
300	sensor_cilantro_2	19.37	63.42	79.70	1.50	6.76	1141.17	456.47	2025-11-10 13:11:56.550306
301	sensor_rabano_1	23.96	65.11	65.49	1.47	6.74	1187.90	448.19	2025-11-10 13:12:06.562005
302	sensor_rabano_2	20.51	59.67	75.99	1.80	6.53	1067.53	424.53	2025-11-10 13:12:06.562932
303	sensor_cilantro_1	20.56	75.35	65.65	1.75	6.57	1102.20	481.93	2025-11-10 13:12:06.563123
304	sensor_cilantro_2	21.09	76.85	67.08	1.84	6.69	1137.88	441.67	2025-11-10 13:12:06.563283
305	sensor_rabano_1	22.81	64.45	79.42	1.96	6.52	929.00	477.84	2025-11-10 13:12:16.574089
306	sensor_rabano_2	21.03	65.12	72.64	1.51	6.49	923.98	416.44	2025-11-10 13:12:16.57478
307	sensor_cilantro_1	20.95	69.61	62.08	1.88	6.64	916.21	481.94	2025-11-10 13:12:16.57487
308	sensor_cilantro_2	19.54	62.32	74.58	1.63	6.40	1127.44	409.70	2025-11-10 13:12:16.574927
309	sensor_rabano_1	20.72	62.65	60.50	1.56	6.66	1083.43	413.58	2025-11-10 13:12:26.586495
310	sensor_rabano_2	23.62	58.80	67.44	2.00	6.48	882.78	470.73	2025-11-10 13:12:26.587384
311	sensor_cilantro_1	19.22	64.86	78.31	1.53	6.80	879.08	413.74	2025-11-10 13:12:26.587618
312	sensor_cilantro_2	20.48	70.57	65.12	1.83	6.57	1056.30	406.83	2025-11-10 13:12:26.587788
313	sensor_rabano_1	22.12	71.64	64.69	1.75	6.57	941.56	494.38	2025-11-10 13:12:36.599789
314	sensor_rabano_2	20.80	68.44	62.38	1.81	6.75	1157.80	435.97	2025-11-10 13:12:36.600709
315	sensor_cilantro_1	21.95	77.61	70.99	1.67	6.71	933.44	447.36	2025-11-10 13:12:36.600949
316	sensor_cilantro_2	22.68	72.97	62.61	1.71	6.56	1174.28	469.36	2025-11-10 13:12:36.601118
317	sensor_rabano_1	23.53	60.75	71.85	1.79	6.70	1176.25	453.91	2025-11-10 13:12:46.612052
318	sensor_rabano_2	23.22	62.02	63.10	1.46	6.42	881.85	451.80	2025-11-10 13:12:46.61297
319	sensor_cilantro_1	20.69	67.81	65.96	1.48	6.52	1122.36	456.48	2025-11-10 13:12:46.613196
320	sensor_cilantro_2	19.91	70.88	61.70	1.41	6.78	978.28	427.93	2025-11-10 13:12:46.613403
321	sensor_rabano_1	23.26	70.72	70.37	1.40	6.67	913.15	470.68	2025-11-10 13:12:56.624392
322	sensor_rabano_2	22.38	58.04	73.80	1.94	6.44	1016.80	472.00	2025-11-10 13:12:56.625106
323	sensor_cilantro_1	20.63	76.36	69.02	1.71	6.69	840.15	426.03	2025-11-10 13:12:56.625309
324	sensor_cilantro_2	20.80	64.47	72.45	1.94	6.66	981.36	400.73	2025-11-10 13:12:56.625485
325	sensor_rabano_1	23.70	64.72	78.70	1.55	6.75	1041.62	440.49	2025-11-10 13:13:06.636877
326	sensor_rabano_2	21.02	61.54	60.50	1.86	6.46	864.51	418.88	2025-11-10 13:13:06.637652
327	sensor_cilantro_1	22.03	75.17	74.59	1.99	6.67	827.31	441.21	2025-11-10 13:13:06.637869
328	sensor_cilantro_2	20.07	64.05	64.50	1.97	6.53	815.25	470.03	2025-11-10 13:13:06.637935
329	sensor_rabano_1	22.75	58.26	68.84	1.45	6.44	1160.85	453.95	2025-11-10 13:13:16.646908
330	sensor_rabano_2	21.51	60.29	72.90	1.95	6.70	946.80	484.36	2025-11-10 13:13:16.647437
331	sensor_cilantro_1	20.06	71.52	61.99	1.66	6.47	1158.51	448.72	2025-11-10 13:13:16.647607
332	sensor_cilantro_2	22.41	68.21	74.84	1.68	6.62	1154.47	497.08	2025-11-10 13:13:16.647689
333	sensor_rabano_1	22.78	62.71	63.20	1.47	6.42	1005.59	474.98	2025-11-10 13:13:26.659074
334	sensor_rabano_2	23.00	70.36	62.33	1.48	6.62	825.86	489.29	2025-11-10 13:13:26.659931
335	sensor_cilantro_1	19.97	64.04	72.37	1.48	6.59	1065.15	493.45	2025-11-10 13:13:26.660114
336	sensor_cilantro_2	22.34	77.88	61.39	1.83	6.53	1188.52	491.01	2025-11-10 13:13:26.660545
337	sensor_rabano_1	22.28	67.34	78.02	1.76	6.70	1160.83	432.18	2025-11-10 13:13:36.669767
338	sensor_rabano_2	23.10	66.25	61.95	1.88	6.74	1192.29	418.63	2025-11-10 13:13:36.670317
339	sensor_cilantro_1	19.75	73.31	70.08	1.75	6.75	1100.89	451.46	2025-11-10 13:13:36.6705
340	sensor_cilantro_2	22.38	62.62	74.75	1.92	6.50	983.08	457.91	2025-11-10 13:13:36.670581
341	sensor_rabano_1	21.39	59.16	75.92	1.97	6.78	1064.10	496.24	2025-11-10 13:13:46.682127
342	sensor_rabano_2	21.39	62.84	71.03	1.68	6.46	1062.16	489.17	2025-11-10 13:13:46.682978
343	sensor_cilantro_1	21.65	75.83	76.79	1.75	6.50	941.20	487.47	2025-11-10 13:13:46.683194
344	sensor_cilantro_2	20.95	72.44	71.27	1.85	6.52	949.05	437.98	2025-11-10 13:13:46.683389
345	sensor_rabano_1	21.12	72.53	67.70	1.96	6.43	1064.35	445.37	2025-11-10 13:13:56.691374
346	sensor_rabano_2	21.60	58.68	65.98	1.92	6.57	1021.10	495.26	2025-11-10 13:13:56.692318
347	sensor_cilantro_1	20.59	77.22	70.09	1.69	6.63	837.15	430.17	2025-11-10 13:13:56.692587
348	sensor_cilantro_2	21.52	64.65	77.03	1.94	6.61	1058.73	464.78	2025-11-10 13:13:56.692784
349	sensor_rabano_1	21.77	67.55	68.44	1.44	6.56	1005.56	459.24	2025-11-10 16:24:23.946641
350	sensor_rabano_2	23.95	70.57	77.09	1.75	6.63	1196.39	406.54	2025-11-10 16:24:23.95312
351	sensor_cilantro_1	20.78	68.93	75.24	1.82	6.59	800.73	454.29	2025-11-10 16:24:23.953422
352	sensor_cilantro_2	22.17	73.11	61.49	1.97	6.68	1146.53	449.82	2025-11-10 16:24:23.953625
353	sensor_rabano_1	22.41	66.21	68.14	1.66	6.74	897.81	423.31	2025-11-10 16:24:33.962421
354	sensor_rabano_2	23.07	69.23	66.96	1.98	6.56	800.08	402.90	2025-11-10 16:24:33.963091
355	sensor_cilantro_1	21.43	68.03	67.59	1.41	6.76	1151.39	471.19	2025-11-10 16:24:33.963256
356	sensor_cilantro_2	20.37	77.79	72.61	1.79	6.51	897.91	405.31	2025-11-10 16:24:33.963337
357	sensor_rabano_1	22.67	68.74	67.55	1.82	6.66	937.89	437.90	2025-11-10 16:24:43.974661
358	sensor_rabano_2	23.13	66.22	70.62	1.47	6.63	815.77	423.08	2025-11-10 16:24:43.975362
359	sensor_cilantro_1	19.49	67.82	61.09	1.66	6.49	1007.41	470.02	2025-11-10 16:24:43.975538
360	sensor_cilantro_2	21.65	64.13	63.98	1.48	6.62	1105.84	448.01	2025-11-10 16:24:43.975674
361	sensor_rabano_1	20.15	71.80	65.72	1.83	6.65	1114.82	403.15	2025-11-10 16:24:53.986441
362	sensor_rabano_2	22.51	62.64	68.09	1.42	6.58	818.15	427.35	2025-11-10 16:24:53.987221
363	sensor_cilantro_1	19.37	67.72	63.08	1.57	6.76	946.50	413.02	2025-11-10 16:24:53.987405
364	sensor_cilantro_2	19.48	75.41	74.15	1.50	6.60	1093.64	428.91	2025-11-10 16:24:53.987549
365	sensor_rabano_1	23.68	66.88	74.60	1.92	6.45	1185.31	443.40	2025-11-10 16:25:03.998726
366	sensor_rabano_2	23.47	68.18	68.30	1.70	6.45	1170.49	429.73	2025-11-10 16:25:03.999614
367	sensor_cilantro_1	20.11	76.93	63.43	1.45	6.79	1049.01	446.18	2025-11-10 16:25:03.999804
368	sensor_cilantro_2	20.25	64.49	62.50	1.97	6.70	926.06	421.25	2025-11-10 16:25:04.000013
369	sensor_rabano_1	23.10	61.46	68.70	1.90	6.53	813.28	499.41	2025-11-10 16:25:14.010105
370	sensor_rabano_2	22.23	65.97	61.28	1.98	6.51	1022.16	493.51	2025-11-10 16:25:14.011044
371	sensor_cilantro_1	19.15	76.73	62.34	1.82	6.68	1072.13	411.28	2025-11-10 16:25:14.011236
372	sensor_cilantro_2	22.10	77.29	76.09	1.45	6.50	1113.87	401.62	2025-11-10 16:25:14.011378
373	sensor_rabano_1	23.86	61.27	62.39	1.73	6.49	908.43	450.61	2025-11-10 16:25:24.021673
374	sensor_rabano_2	21.50	63.31	62.90	1.69	6.70	980.29	444.09	2025-11-10 16:25:24.022439
375	sensor_cilantro_1	19.62	64.28	77.38	1.49	6.64	963.09	461.18	2025-11-10 16:25:24.022628
376	sensor_cilantro_2	20.88	72.97	64.53	1.42	6.48	807.87	401.38	2025-11-10 16:25:24.022773
377	sensor_rabano_1	23.50	71.28	77.07	1.67	6.48	1067.28	469.10	2025-11-10 16:25:34.03065
378	sensor_rabano_2	21.60	65.09	64.09	1.47	6.52	1060.45	472.99	2025-11-10 16:25:34.031135
379	sensor_cilantro_1	20.75	74.44	74.22	1.95	6.61	1175.02	468.24	2025-11-10 16:25:34.031217
380	sensor_cilantro_2	20.76	71.34	69.39	1.51	6.43	917.57	414.67	2025-11-10 16:25:34.031274
381	sensor_rabano_1	21.41	59.18	75.60	1.64	6.41	944.62	492.16	2025-11-10 17:18:41.451132
382	sensor_rabano_2	22.85	72.33	72.28	1.41	6.58	940.28	403.01	2025-11-10 17:18:41.451959
383	sensor_cilantro_1	20.87	62.87	65.36	1.60	6.52	1155.23	446.48	2025-11-10 17:18:41.452159
384	sensor_cilantro_2	19.89	74.32	64.21	1.78	6.49	979.22	413.17	2025-11-10 17:18:41.452301
385	sensor_rabano_1	20.25	65.64	71.99	1.46	6.77	843.58	404.57	2025-11-10 17:18:51.470785
386	sensor_rabano_2	23.89	59.45	64.09	1.92	6.69	1032.90	452.91	2025-11-10 17:18:51.471402
387	sensor_cilantro_1	22.63	64.48	70.69	1.75	6.77	914.38	417.05	2025-11-10 17:18:51.471591
388	sensor_cilantro_2	20.44	64.46	70.45	1.70	6.65	921.52	405.38	2025-11-10 17:18:51.471672
389	sensor_rabano_1	23.67	67.28	63.71	1.88	6.77	951.15	430.11	2025-11-10 17:19:01.481125
390	sensor_rabano_2	21.90	63.49	76.16	1.88	6.58	1144.39	424.48	2025-11-10 17:19:01.481688
391	sensor_cilantro_1	19.04	72.71	73.37	1.73	6.72	888.59	457.81	2025-11-10 17:19:01.481826
392	sensor_cilantro_2	21.36	77.87	60.76	1.88	6.52	1170.37	411.41	2025-11-10 17:19:01.481917
393	sensor_rabano_1	20.17	62.98	74.84	1.48	6.61	1023.47	441.50	2025-11-10 17:19:11.489418
394	sensor_rabano_2	22.38	65.89	71.81	1.43	6.58	1090.88	422.80	2025-11-10 17:19:11.489962
395	sensor_cilantro_1	21.85	73.73	71.58	1.99	6.43	884.71	412.19	2025-11-10 17:19:11.490085
396	sensor_cilantro_2	21.85	65.57	78.09	1.67	6.77	942.51	470.78	2025-11-10 17:19:11.490193
397	sensor_rabano_1	23.69	66.74	67.73	1.95	6.78	921.86	475.84	2025-11-10 17:19:21.499433
398	sensor_rabano_2	21.73	66.97	69.91	1.60	6.58	917.31	466.27	2025-11-10 17:19:21.500129
399	sensor_cilantro_1	20.19	74.31	62.10	1.48	6.61	901.93	439.24	2025-11-10 17:19:21.500297
400	sensor_cilantro_2	20.40	63.50	62.49	1.76	6.59	852.12	459.44	2025-11-10 17:19:21.500454
401	sensor_rabano_1	23.69	63.89	71.37	1.93	6.61	1055.79	420.76	2025-11-10 17:19:31.50926
402	sensor_rabano_2	23.09	57.29	60.23	1.62	6.57	1085.51	437.20	2025-11-10 17:19:31.510285
403	sensor_cilantro_1	19.71	75.17	79.10	1.53	6.41	887.34	482.50	2025-11-10 17:19:31.51055
404	sensor_cilantro_2	20.55	66.15	63.38	1.78	6.59	1083.78	482.33	2025-11-10 17:19:31.510753
405	sensor_rabano_1	23.31	72.88	65.18	1.50	6.67	1174.28	441.85	2025-11-10 17:19:41.521237
406	sensor_rabano_2	20.67	66.94	72.46	1.51	6.70	956.81	481.14	2025-11-10 17:19:41.522034
407	sensor_cilantro_1	21.79	69.48	63.24	1.80	6.68	840.94	433.15	2025-11-10 17:19:41.522236
408	sensor_cilantro_2	19.65	73.02	76.73	1.88	6.50	856.66	472.74	2025-11-10 17:19:41.52238
409	sensor_rabano_1	23.17	65.33	78.49	1.86	6.73	1068.53	456.91	2025-11-10 17:19:51.531961
410	sensor_rabano_2	21.79	69.37	77.36	1.96	6.65	1178.21	435.04	2025-11-10 17:19:51.5328
411	sensor_cilantro_1	19.33	77.14	69.63	1.74	6.62	1120.39	431.77	2025-11-10 17:19:51.53299
412	sensor_cilantro_2	19.50	70.68	79.37	1.71	6.52	963.86	455.32	2025-11-10 17:19:51.533196
413	sensor_rabano_1	22.06	58.38	68.50	1.85	6.51	1178.27	486.36	2025-11-10 17:19:54.41644
414	sensor_rabano_2	20.54	70.01	76.75	1.80	6.57	851.18	445.95	2025-11-10 17:19:54.417414
415	sensor_cilantro_1	21.31	75.71	65.48	1.72	6.69	959.01	484.69	2025-11-10 17:19:54.417649
416	sensor_cilantro_2	20.38	74.54	60.36	1.69	6.60	1091.53	498.02	2025-11-10 17:19:54.41784
417	sensor_rabano_1	21.33	65.86	72.54	1.75	6.42	1126.41	440.08	2025-11-10 17:20:04.427536
418	sensor_rabano_2	23.67	59.21	67.86	1.67	6.51	812.09	456.62	2025-11-10 17:20:04.428132
419	sensor_cilantro_1	22.81	67.11	65.19	1.86	6.47	1102.45	425.00	2025-11-10 17:20:04.428212
420	sensor_cilantro_2	21.92	67.80	79.98	1.85	6.74	801.44	496.95	2025-11-10 17:20:04.42827
421	sensor_rabano_1	22.80	59.48	72.59	1.61	6.47	848.37	463.06	2025-11-10 17:20:14.439353
422	sensor_rabano_2	21.08	60.68	61.46	1.52	6.57	1012.25	491.70	2025-11-10 17:20:14.440128
423	sensor_cilantro_1	21.07	68.55	74.68	1.87	6.75	845.43	497.79	2025-11-10 17:20:14.440383
424	sensor_cilantro_2	19.18	70.61	79.54	1.84	6.62	1105.60	420.78	2025-11-10 17:20:14.440581
425	sensor_rabano_1	21.68	63.74	61.15	1.50	6.79	1026.65	437.94	2025-11-10 17:20:24.452481
426	sensor_rabano_2	21.10	70.84	63.25	1.80	6.57	1084.62	474.62	2025-11-10 17:20:24.453387
427	sensor_cilantro_1	19.18	64.06	74.40	1.56	6.44	1051.79	453.87	2025-11-10 17:20:24.45366
428	sensor_cilantro_2	20.68	66.65	75.48	1.90	6.51	814.48	457.60	2025-11-10 17:20:24.453912
429	sensor_rabano_1	21.57	62.96	75.51	1.55	6.54	1110.63	463.33	2025-11-10 17:20:34.465122
430	sensor_rabano_2	22.84	59.14	62.48	1.47	6.61	1074.22	449.38	2025-11-10 17:20:34.466165
431	sensor_cilantro_1	19.61	69.47	62.49	1.50	6.48	1191.74	434.97	2025-11-10 17:20:34.466487
432	sensor_cilantro_2	22.00	71.86	75.17	1.46	6.42	1195.44	445.68	2025-11-10 17:20:34.46675
433	sensor_rabano_1	20.80	70.88	79.22	1.73	6.41	1059.64	473.17	2025-11-10 17:20:44.478384
434	sensor_rabano_2	21.24	64.27	67.28	1.72	6.79	875.87	482.24	2025-11-10 17:20:44.47939
435	sensor_cilantro_1	21.09	67.73	73.78	1.43	6.59	1197.38	496.23	2025-11-10 17:20:44.47971
436	sensor_cilantro_2	19.11	74.44	66.41	1.52	6.45	916.29	498.47	2025-11-10 17:20:44.479902
437	sensor_rabano_1	20.60	64.08	75.01	1.60	6.46	1055.65	460.19	2025-11-10 17:20:54.491307
438	sensor_rabano_2	22.47	66.88	62.38	1.98	6.76	985.62	466.37	2025-11-10 17:20:54.492155
439	sensor_cilantro_1	19.35	69.37	61.99	1.80	6.62	920.69	433.37	2025-11-10 17:20:54.492357
440	sensor_cilantro_2	19.04	64.06	76.58	1.83	6.59	965.17	479.65	2025-11-10 17:20:54.492597
441	sensor_rabano_1	22.27	58.71	67.37	1.89	6.61	953.14	438.97	2025-11-10 17:21:04.504358
442	sensor_rabano_2	20.74	71.86	69.16	1.68	6.50	826.98	431.04	2025-11-10 17:21:04.505088
443	sensor_cilantro_1	19.80	68.70	79.05	1.96	6.61	1068.31	408.61	2025-11-10 17:21:04.505273
444	sensor_cilantro_2	22.11	62.04	61.57	1.63	6.78	1145.43	498.80	2025-11-10 17:21:04.505421
445	sensor_rabano_1	21.78	59.39	71.20	1.74	6.69	807.54	410.69	2025-11-10 17:21:14.517285
446	sensor_rabano_2	23.00	72.96	68.48	1.58	6.56	932.13	430.96	2025-11-10 17:21:14.518106
447	sensor_cilantro_1	22.05	65.68	79.38	1.46	6.76	922.75	415.88	2025-11-10 17:21:14.518299
448	sensor_cilantro_2	19.75	63.87	63.02	1.94	6.50	1032.79	448.84	2025-11-10 17:21:14.518498
449	sensor_rabano_1	22.78	58.10	76.14	1.52	6.42	1047.14	498.01	2025-11-10 17:21:31.049918
450	sensor_rabano_2	22.03	66.74	75.73	1.65	6.61	1082.40	433.71	2025-11-10 17:21:31.050681
451	sensor_cilantro_1	20.68	71.30	75.97	1.53	6.66	1043.70	499.78	2025-11-10 17:21:31.05092
452	sensor_cilantro_2	22.30	70.63	74.59	1.87	6.65	995.53	407.64	2025-11-10 17:21:31.05124
453	sensor_rabano_1	20.56	59.54	72.99	1.80	6.57	1021.33	425.01	2025-11-10 17:21:41.062201
454	sensor_rabano_2	20.13	62.72	64.76	1.50	6.68	1178.53	467.62	2025-11-10 17:21:41.063006
455	sensor_cilantro_1	19.13	65.78	69.70	1.49	6.63	1080.14	486.26	2025-11-10 17:21:41.063193
456	sensor_cilantro_2	19.69	74.75	75.11	1.59	6.73	1048.72	411.99	2025-11-10 17:21:41.063403
457	sensor_rabano_1	21.66	58.26	65.05	1.69	6.70	1132.49	471.08	2025-11-10 17:21:51.075323
458	sensor_rabano_2	20.83	67.92	61.08	1.68	6.65	904.27	416.86	2025-11-10 17:21:51.076203
459	sensor_cilantro_1	22.06	67.97	69.45	1.45	6.74	902.19	445.92	2025-11-10 17:21:51.076485
460	sensor_cilantro_2	21.47	71.82	64.81	1.81	6.64	1135.56	474.39	2025-11-10 17:21:51.076687
461	sensor_rabano_1	22.97	71.07	69.25	1.99	6.55	1097.59	483.61	2025-11-10 17:26:20.808495
462	sensor_rabano_2	20.17	63.54	68.77	1.75	6.52	891.90	495.96	2025-11-10 17:26:20.809292
463	sensor_cilantro_1	20.50	65.27	77.00	1.88	6.48	885.55	472.90	2025-11-10 17:26:20.809483
464	sensor_cilantro_2	21.27	72.63	67.10	1.47	6.56	887.11	499.32	2025-11-10 17:26:20.809625
465	sensor_rabano_1	23.14	72.42	70.46	1.86	6.80	831.32	443.97	2025-11-10 17:26:30.829109
466	sensor_rabano_2	20.94	59.81	62.49	1.67	6.44	889.76	463.93	2025-11-10 17:26:30.829886
467	sensor_cilantro_1	21.97	67.77	68.77	1.79	6.61	1026.33	465.36	2025-11-10 17:26:30.830078
468	sensor_cilantro_2	20.56	70.65	70.08	1.47	6.47	1040.25	488.86	2025-11-10 17:26:30.830233
469	sensor_rabano_1	20.80	69.08	68.31	1.52	6.48	975.00	450.41	2025-11-10 17:26:40.842226
470	sensor_rabano_2	22.70	65.40	67.31	1.64	6.50	996.63	452.09	2025-11-10 17:26:40.84301
471	sensor_cilantro_1	19.18	77.14	61.10	1.86	6.77	1073.40	474.84	2025-11-10 17:26:40.843199
472	sensor_cilantro_2	21.62	75.32	75.32	1.89	6.42	966.84	414.12	2025-11-10 17:26:40.843347
473	sensor_rabano_1	22.45	57.14	64.05	1.47	6.63	812.35	435.99	2025-11-10 17:26:50.862497
474	sensor_rabano_2	20.73	58.18	63.09	1.54	6.55	1051.38	493.55	2025-11-10 17:26:50.863907
475	sensor_cilantro_1	20.69	62.13	79.31	1.48	6.76	933.69	444.23	2025-11-10 17:26:50.864338
476	sensor_cilantro_2	20.44	63.41	71.65	1.82	6.67	955.81	416.95	2025-11-10 17:26:50.864654
477	sensor_rabano_1	20.45	62.31	66.27	1.44	6.65	971.67	463.42	2025-11-10 17:27:00.875487
478	sensor_rabano_2	20.67	62.44	64.62	1.69	6.76	1144.58	489.18	2025-11-10 17:27:00.876332
479	sensor_cilantro_1	21.13	74.08	68.12	1.45	6.54	929.92	441.62	2025-11-10 17:27:00.876559
480	sensor_cilantro_2	22.02	77.99	70.94	1.71	6.64	1136.38	493.87	2025-11-10 17:27:00.876751
481	sensor_rabano_1	22.24	69.94	60.13	1.93	6.48	982.78	462.22	2025-11-10 17:27:10.886786
482	sensor_rabano_2	21.06	58.29	61.08	1.56	6.45	1092.59	402.26	2025-11-10 17:27:10.887728
483	sensor_cilantro_1	22.42	73.23	60.15	2.00	6.66	1017.11	438.41	2025-11-10 17:27:10.887921
484	sensor_cilantro_2	21.82	73.50	70.62	1.64	6.59	1137.44	443.78	2025-11-10 17:27:10.888072
485	sensor_rabano_1	23.42	63.49	76.48	1.94	6.48	813.33	494.83	2025-11-10 17:27:20.899386
486	sensor_rabano_2	21.04	59.71	64.64	1.88	6.65	908.73	427.25	2025-11-10 17:27:20.900154
487	sensor_cilantro_1	21.12	75.89	62.15	1.96	6.46	944.55	499.88	2025-11-10 17:27:20.900371
488	sensor_cilantro_2	20.19	64.96	79.46	1.51	6.79	1174.06	414.40	2025-11-10 17:27:20.900515
489	sensor_rabano_1	22.82	69.71	70.49	1.63	6.53	1193.43	444.34	2025-11-10 17:27:30.912173
490	sensor_rabano_2	23.23	60.45	72.98	1.82	6.56	1156.30	487.96	2025-11-10 17:27:30.91294
491	sensor_cilantro_1	21.97	69.05	62.06	1.60	6.78	959.03	422.13	2025-11-10 17:27:30.913188
492	sensor_cilantro_2	19.46	76.69	75.10	1.93	6.79	975.62	406.37	2025-11-10 17:27:30.913351
493	sensor_rabano_1	22.28	58.13	65.57	1.71	6.58	806.59	429.39	2025-11-10 17:27:40.922777
494	sensor_rabano_2	22.79	63.02	74.84	1.87	6.42	1112.97	422.09	2025-11-10 17:27:40.923728
495	sensor_cilantro_1	19.52	77.97	67.68	1.63	6.67	871.83	452.20	2025-11-10 17:27:40.924229
496	sensor_cilantro_2	21.99	65.98	78.29	1.81	6.60	1091.26	422.80	2025-11-10 17:27:40.924485
497	sensor_rabano_1	23.98	57.07	78.08	1.73	6.67	880.87	453.45	2025-11-10 17:27:52.372212
498	sensor_rabano_2	21.64	70.65	65.29	1.43	6.52	803.64	488.27	2025-11-10 17:27:52.372712
499	sensor_cilantro_1	19.12	63.79	63.80	1.97	6.61	1016.54	426.64	2025-11-10 17:27:52.372879
500	sensor_cilantro_2	22.31	71.75	77.78	1.78	6.46	812.45	418.67	2025-11-10 17:27:52.373027
501	sensor_rabano_1	20.17	67.62	60.82	1.90	6.59	1037.20	440.41	2025-11-10 17:28:02.380121
502	sensor_rabano_2	22.05	72.52	67.39	1.57	6.78	946.04	471.05	2025-11-10 17:28:02.380599
503	sensor_cilantro_1	21.93	74.69	60.96	1.43	6.77	1165.60	419.96	2025-11-10 17:28:02.380681
504	sensor_cilantro_2	19.78	70.68	71.29	1.98	6.68	1080.52	433.40	2025-11-10 17:28:02.380736
505	sensor_rabano_1	22.12	58.95	66.12	1.61	6.66	1050.52	476.30	2025-11-10 17:28:12.390802
506	sensor_rabano_2	23.77	67.54	60.27	1.86	6.53	1040.01	469.69	2025-11-10 17:28:12.39157
507	sensor_cilantro_1	22.49	70.33	69.33	1.97	6.49	1023.63	411.65	2025-11-10 17:28:12.391794
508	sensor_cilantro_2	20.57	69.67	69.43	1.70	6.58	856.05	484.30	2025-11-10 17:28:12.391967
509	sensor_rabano_1	20.91	70.08	74.26	1.73	6.79	895.43	485.07	2025-11-10 17:28:22.400784
510	sensor_rabano_2	21.56	72.65	60.39	1.45	6.70	1063.18	480.90	2025-11-10 17:28:22.401253
511	sensor_cilantro_1	21.50	76.34	74.10	1.81	6.75	809.88	484.20	2025-11-10 17:28:22.401334
512	sensor_cilantro_2	20.51	77.60	74.66	1.88	6.66	885.83	441.01	2025-11-10 17:28:22.401391
513	sensor_rabano_1	23.34	60.17	63.17	1.59	6.75	935.55	476.12	2025-11-10 17:28:32.412463
514	sensor_rabano_2	23.71	64.07	73.32	1.83	6.49	1120.56	491.13	2025-11-10 17:28:32.413266
515	sensor_cilantro_1	19.05	75.67	60.71	1.45	6.55	899.94	441.77	2025-11-10 17:28:32.41349
516	sensor_cilantro_2	21.24	64.75	79.68	1.83	6.72	1177.58	400.03	2025-11-10 17:28:32.413694
517	sensor_rabano_1	22.46	61.56	74.44	1.91	6.60	897.36	479.33	2025-11-10 17:28:42.423276
518	sensor_rabano_2	20.22	58.54	60.16	1.87	6.50	895.93	418.18	2025-11-10 17:28:42.423756
519	sensor_cilantro_1	20.32	62.44	74.44	1.44	6.43	863.12	434.76	2025-11-10 17:28:42.42387
520	sensor_cilantro_2	21.26	69.33	78.34	1.40	6.42	1079.84	437.78	2025-11-10 17:28:42.42395
521	sensor_rabano_1	21.45	64.14	78.57	1.57	6.59	1119.49	406.28	2025-11-10 17:28:52.43409
522	sensor_rabano_2	23.90	72.07	77.53	1.67	6.68	1048.00	436.26	2025-11-10 17:28:52.434824
523	sensor_cilantro_1	22.80	69.21	79.51	1.93	6.44	890.87	420.76	2025-11-10 17:28:52.435017
524	sensor_cilantro_2	21.61	63.42	63.91	1.75	6.64	1034.15	456.30	2025-11-10 17:28:52.435164
525	sensor_rabano_1	22.98	57.49	68.55	1.60	6.72	1097.22	478.02	2025-11-10 17:29:02.445509
526	sensor_rabano_2	20.80	59.42	66.05	1.56	6.54	1079.81	427.13	2025-11-10 17:29:02.446363
527	sensor_cilantro_1	22.48	70.99	67.82	1.47	6.44	845.93	448.85	2025-11-10 17:29:02.446697
528	sensor_cilantro_2	22.50	63.29	62.33	1.56	6.57	1122.88	441.64	2025-11-10 17:29:02.446908
529	sensor_rabano_1	22.83	67.68	61.07	1.78	6.77	886.70	430.34	2025-11-10 17:29:12.458184
530	sensor_rabano_2	21.27	70.02	68.08	1.71	6.67	818.91	411.93	2025-11-10 17:29:12.459063
531	sensor_cilantro_1	22.66	70.67	71.34	1.92	6.51	1093.36	454.42	2025-11-10 17:29:12.459333
532	sensor_cilantro_2	19.10	74.20	66.22	1.48	6.46	863.33	415.98	2025-11-10 17:29:12.459587
533	sensor_rabano_1	20.14	59.83	73.57	1.54	6.42	1145.96	408.42	2025-11-10 17:29:22.471274
534	sensor_rabano_2	21.75	72.45	67.26	1.82	6.68	1138.49	460.33	2025-11-10 17:29:22.472046
535	sensor_cilantro_1	21.49	77.16	64.89	1.86	6.70	860.50	479.17	2025-11-10 17:29:22.472232
536	sensor_cilantro_2	19.01	70.29	63.78	1.59	6.54	808.82	474.12	2025-11-10 17:29:22.472373
537	sensor_rabano_1	20.09	62.82	72.37	1.72	6.41	869.55	470.00	2025-11-10 17:29:32.483731
538	sensor_rabano_2	20.95	59.17	64.08	1.82	6.75	870.50	495.88	2025-11-10 17:29:32.484541
539	sensor_cilantro_1	21.01	75.24	76.76	1.47	6.76	806.65	404.13	2025-11-10 17:29:32.484805
540	sensor_cilantro_2	21.96	77.00	64.63	1.84	6.76	1144.86	495.79	2025-11-10 17:29:32.484964
541	sensor_rabano_1	21.48	60.10	74.60	1.45	6.50	804.60	435.53	2025-11-10 17:29:42.49678
542	sensor_rabano_2	20.54	65.20	79.11	1.65	6.76	1082.08	434.91	2025-11-10 17:29:42.497586
543	sensor_cilantro_1	19.06	75.22	71.02	1.66	6.45	1093.31	423.07	2025-11-10 17:29:42.497794
544	sensor_cilantro_2	21.26	66.55	61.25	1.76	6.56	867.21	424.70	2025-11-10 17:29:42.497946
545	sensor_rabano_1	21.24	72.40	62.40	1.63	6.63	967.71	403.04	2025-11-10 17:29:52.509158
546	sensor_rabano_2	20.95	61.49	62.15	1.45	6.53	915.97	410.26	2025-11-10 17:29:52.509998
547	sensor_cilantro_1	20.36	64.32	65.00	1.76	6.80	1019.38	403.06	2025-11-10 17:29:52.510227
548	sensor_cilantro_2	22.73	65.62	70.45	1.56	6.51	1177.13	474.78	2025-11-10 17:29:52.510424
549	sensor_rabano_1	23.04	58.93	62.78	1.91	6.54	1089.49	479.62	2025-11-10 17:30:02.51931
550	sensor_rabano_2	22.57	64.83	73.52	1.48	6.63	1088.60	434.40	2025-11-10 17:30:02.519792
551	sensor_cilantro_1	21.35	69.87	64.81	1.85	6.80	871.68	479.39	2025-11-10 17:30:02.519879
552	sensor_cilantro_2	20.05	69.61	75.27	1.90	6.47	1166.32	492.57	2025-11-10 17:30:02.519936
553	sensor_rabano_1	22.68	63.56	76.09	1.82	6.76	817.53	457.52	2025-11-10 17:30:12.531102
554	sensor_rabano_2	20.44	60.23	67.10	1.42	6.69	844.32	420.17	2025-11-10 17:30:12.531824
555	sensor_cilantro_1	21.41	71.96	77.95	1.58	6.67	1194.37	427.26	2025-11-10 17:30:12.532069
556	sensor_cilantro_2	20.65	68.66	71.80	1.97	6.67	810.73	431.23	2025-11-10 17:30:12.532245
557	sensor_rabano_1	22.07	69.73	77.99	1.73	6.58	948.22	454.06	2025-11-10 17:30:22.54334
558	sensor_rabano_2	22.23	62.38	69.99	1.74	6.60	1007.76	489.54	2025-11-10 17:30:22.54408
559	sensor_cilantro_1	19.59	68.56	75.61	1.61	6.62	1077.19	478.96	2025-11-10 17:30:22.544259
560	sensor_cilantro_2	22.00	64.31	71.52	1.41	6.44	883.44	429.34	2025-11-10 17:30:22.544398
561	sensor_rabano_1	20.77	65.15	74.13	1.48	6.70	920.36	430.15	2025-11-10 17:30:32.555868
562	sensor_rabano_2	22.91	72.34	73.57	1.58	6.66	857.93	477.77	2025-11-10 17:30:32.556684
563	sensor_cilantro_1	19.84	69.65	69.42	1.73	6.64	835.94	454.96	2025-11-10 17:30:32.556968
564	sensor_cilantro_2	21.90	67.36	68.13	1.45	6.52	1193.72	459.09	2025-11-10 17:30:32.557245
565	sensor_rabano_1	22.14	57.07	66.41	1.42	6.63	982.79	449.16	2025-11-10 17:30:42.56627
566	sensor_rabano_2	22.68	69.31	66.67	1.48	6.61	1048.99	427.03	2025-11-10 17:30:42.566745
567	sensor_cilantro_1	20.36	75.85	66.88	1.69	6.80	865.73	487.51	2025-11-10 17:30:42.566832
568	sensor_cilantro_2	21.67	69.18	62.08	1.76	6.41	825.40	421.80	2025-11-10 17:30:42.566889
569	sensor_rabano_1	21.51	69.15	63.14	1.94	6.55	1109.47	461.65	2025-11-10 17:30:52.576493
570	sensor_rabano_2	21.74	64.03	65.64	1.61	6.74	874.62	463.22	2025-11-10 17:30:52.57743
571	sensor_cilantro_1	21.34	65.20	75.00	1.84	6.54	1090.48	449.01	2025-11-10 17:30:52.577671
572	sensor_cilantro_2	22.45	77.41	62.58	1.42	6.70	861.39	474.67	2025-11-10 17:30:52.577931
573	sensor_rabano_1	22.07	61.74	62.93	1.66	6.75	854.02	401.58	2025-11-10 17:31:02.589472
574	sensor_rabano_2	21.79	70.50	79.39	1.58	6.65	882.00	410.71	2025-11-10 17:31:02.590356
575	sensor_cilantro_1	21.89	73.61	77.80	1.69	6.64	970.80	471.50	2025-11-10 17:31:02.590549
576	sensor_cilantro_2	19.26	77.98	71.71	1.82	6.48	803.73	448.07	2025-11-10 17:31:02.590778
577	sensor_rabano_1	22.59	57.19	69.23	1.76	6.46	1047.25	448.17	2025-11-10 17:31:12.602437
578	sensor_rabano_2	20.73	64.58	72.13	1.60	6.48	1194.86	469.04	2025-11-10 17:31:12.603463
579	sensor_cilantro_1	22.71	68.80	79.35	1.77	6.52	1059.41	442.44	2025-11-10 17:31:12.604012
580	sensor_cilantro_2	21.38	66.47	64.20	1.70	6.70	1118.49	492.17	2025-11-10 17:31:12.604249
581	sensor_rabano_1	21.03	72.06	75.32	1.51	6.46	1113.49	483.33	2025-11-10 17:31:22.615982
582	sensor_rabano_2	22.91	60.78	73.68	1.45	6.52	1049.35	427.02	2025-11-10 17:31:22.616862
583	sensor_cilantro_1	20.87	77.05	62.60	1.93	6.50	1094.34	463.54	2025-11-10 17:31:22.617119
584	sensor_cilantro_2	21.99	67.98	74.40	2.00	6.58	1194.79	497.78	2025-11-10 17:31:22.617284
585	sensor_rabano_1	20.44	62.69	63.34	1.66	6.70	964.85	463.61	2025-11-10 17:31:32.638518
586	sensor_rabano_2	22.64	70.20	73.36	1.77	6.75	1076.38	460.69	2025-11-10 17:31:32.639404
587	sensor_cilantro_1	19.38	74.88	65.78	1.94	6.60	1151.55	465.95	2025-11-10 17:31:32.639654
588	sensor_cilantro_2	21.10	70.18	76.65	1.59	6.47	811.01	403.59	2025-11-10 17:31:32.639856
589	sensor_rabano_1	23.86	62.36	76.91	1.71	6.74	866.27	471.11	2025-11-10 17:31:42.651423
590	sensor_rabano_2	20.02	70.70	60.97	1.44	6.53	976.84	411.14	2025-11-10 17:31:42.652299
591	sensor_cilantro_1	21.02	63.16	61.26	1.69	6.52	1140.31	418.90	2025-11-10 17:31:42.652544
592	sensor_cilantro_2	20.33	67.98	65.08	1.50	6.72	864.45	448.16	2025-11-10 17:31:42.652849
593	sensor_rabano_1	23.96	66.31	61.31	1.58	6.70	1119.80	469.15	2025-11-10 17:31:52.664542
594	sensor_rabano_2	22.21	68.44	76.04	1.51	6.43	1020.48	430.35	2025-11-10 17:31:52.665359
595	sensor_cilantro_1	19.84	77.81	78.24	1.77	6.79	910.76	414.15	2025-11-10 17:31:52.665541
596	sensor_cilantro_2	22.60	76.41	64.02	1.78	6.68	963.20	447.69	2025-11-10 17:31:52.665694
597	sensor_rabano_1	21.66	59.59	69.35	1.73	6.58	1044.82	498.26	2025-11-10 17:32:02.676036
598	sensor_rabano_2	20.92	63.87	76.60	1.84	6.58	1151.38	484.45	2025-11-10 17:32:02.676815
599	sensor_cilantro_1	20.19	73.97	75.25	1.60	6.47	1191.21	453.57	2025-11-10 17:32:02.676997
600	sensor_cilantro_2	20.47	75.65	66.36	1.80	6.52	1018.53	455.24	2025-11-10 17:32:02.677139
601	sensor_rabano_1	23.77	63.45	79.13	1.67	6.75	993.78	444.89	2025-11-10 17:32:12.688894
602	sensor_rabano_2	22.53	62.52	75.33	1.74	6.44	925.19	475.58	2025-11-10 17:32:12.6897
603	sensor_cilantro_1	22.62	71.85	70.79	1.42	6.51	903.47	400.95	2025-11-10 17:32:12.689877
604	sensor_cilantro_2	20.64	65.52	77.36	1.80	6.41	830.59	432.87	2025-11-10 17:32:12.690011
605	sensor_rabano_1	20.91	61.44	60.21	1.67	6.45	1053.19	454.83	2025-11-10 17:32:22.701336
606	sensor_rabano_2	23.01	59.40	66.88	1.59	6.58	1167.33	447.77	2025-11-10 17:32:22.702037
607	sensor_cilantro_1	22.47	68.07	69.02	1.88	6.61	887.78	400.20	2025-11-10 17:32:22.702212
608	sensor_cilantro_2	21.99	74.78	68.38	1.98	6.60	991.19	414.76	2025-11-10 17:32:22.702347
609	sensor_rabano_1	21.79	62.95	61.85	1.66	6.80	866.04	476.41	2025-11-10 17:32:32.713673
610	sensor_rabano_2	21.69	67.77	71.80	1.65	6.58	842.52	407.49	2025-11-10 17:32:32.714408
611	sensor_cilantro_1	20.76	66.89	60.33	1.71	6.47	990.10	446.70	2025-11-10 17:32:32.714597
612	sensor_cilantro_2	22.36	63.34	63.34	1.83	6.77	813.93	485.22	2025-11-10 17:32:32.714751
613	sensor_rabano_1	23.66	71.46	79.29	1.41	6.78	937.71	491.79	2025-11-10 17:32:42.726515
614	sensor_rabano_2	23.31	58.60	64.30	1.58	6.51	901.46	486.37	2025-11-10 17:32:42.727445
615	sensor_cilantro_1	21.49	76.34	73.58	1.62	6.52	951.19	497.03	2025-11-10 17:32:42.727686
616	sensor_cilantro_2	22.50	77.54	61.87	1.71	6.62	1061.21	481.16	2025-11-10 17:32:42.727916
617	sensor_rabano_1	21.66	63.42	65.27	1.58	6.40	881.09	487.13	2025-11-10 17:32:52.739524
618	sensor_rabano_2	23.97	61.99	66.58	1.89	6.53	919.81	440.13	2025-11-10 17:32:52.740358
619	sensor_cilantro_1	20.71	65.60	61.94	1.90	6.60	1039.57	418.25	2025-11-10 17:32:52.740549
620	sensor_cilantro_2	19.46	66.01	67.16	1.43	6.58	861.73	493.16	2025-11-10 17:32:52.740713
621	sensor_rabano_1	23.61	64.91	70.44	1.46	6.47	946.65	450.68	2025-11-10 17:33:02.751462
622	sensor_rabano_2	21.74	72.98	78.81	1.85	6.64	830.00	479.03	2025-11-10 17:33:02.752148
623	sensor_cilantro_1	20.42	67.99	77.91	1.84	6.74	1106.99	421.70	2025-11-10 17:33:02.752334
624	sensor_cilantro_2	20.53	73.83	60.10	1.43	6.80	1140.26	464.39	2025-11-10 17:33:02.7524
625	sensor_rabano_1	20.80	66.92	66.89	1.84	6.67	977.02	445.53	2025-11-10 17:33:12.763313
626	sensor_rabano_2	20.43	57.84	72.94	1.55	6.55	1087.95	431.73	2025-11-10 17:33:12.764199
627	sensor_cilantro_1	20.35	77.19	69.33	1.93	6.75	1014.63	497.45	2025-11-10 17:33:12.764344
628	sensor_cilantro_2	19.93	64.02	74.37	1.98	6.47	950.84	474.78	2025-11-10 17:33:12.764406
629	sensor_rabano_1	22.30	62.95	77.73	1.74	6.53	920.89	415.78	2025-11-10 17:33:22.774855
630	sensor_rabano_2	20.20	64.28	77.45	1.96	6.66	811.57	450.56	2025-11-10 17:33:22.77582
631	sensor_cilantro_1	22.42	72.96	64.07	1.67	6.74	1032.28	419.75	2025-11-10 17:33:22.776098
632	sensor_cilantro_2	20.28	75.75	72.32	1.49	6.41	851.39	498.92	2025-11-10 17:33:22.776352
633	sensor_rabano_1	21.93	71.96	65.40	1.54	6.72	995.28	408.11	2025-11-10 17:33:32.786604
634	sensor_rabano_2	22.69	64.86	74.62	1.51	6.53	917.30	481.67	2025-11-10 17:33:32.787423
635	sensor_cilantro_1	22.28	63.73	68.64	1.93	6.56	1031.86	483.16	2025-11-10 17:33:32.787613
636	sensor_cilantro_2	20.67	64.01	63.97	1.96	6.65	1086.72	486.98	2025-11-10 17:33:32.787823
637	sensor_rabano_1	20.43	68.10	61.27	1.76	6.69	1091.63	447.17	2025-11-10 17:33:42.798942
638	sensor_rabano_2	20.57	58.23	60.67	1.75	6.64	907.11	425.62	2025-11-10 17:33:42.799838
639	sensor_cilantro_1	21.16	62.77	61.69	1.51	6.44	828.83	478.78	2025-11-10 17:33:42.800111
640	sensor_cilantro_2	19.85	70.02	70.60	1.60	6.78	1092.22	461.38	2025-11-10 17:33:42.800322
641	sensor_rabano_1	22.77	66.79	66.81	1.57	6.75	825.42	495.95	2025-11-10 17:33:52.811839
642	sensor_rabano_2	20.00	61.73	77.92	1.96	6.44	809.77	485.57	2025-11-10 17:33:52.812771
643	sensor_cilantro_1	19.57	75.56	68.71	1.58	6.62	1145.90	442.56	2025-11-10 17:33:52.813051
644	sensor_cilantro_2	22.74	75.61	72.08	1.83	6.58	813.32	418.48	2025-11-10 17:33:52.813265
645	sensor_rabano_1	20.71	57.58	67.03	1.82	6.75	856.07	454.94	2025-11-10 17:34:02.823707
646	sensor_rabano_2	22.70	61.11	72.99	1.69	6.48	1131.15	434.30	2025-11-10 17:34:02.824322
647	sensor_cilantro_1	19.51	67.33	77.98	1.63	6.46	951.20	421.20	2025-11-10 17:34:02.824404
648	sensor_cilantro_2	21.24	76.04	61.31	1.68	6.70	1164.63	432.80	2025-11-10 17:34:02.824463
649	sensor_rabano_1	23.45	71.03	79.15	1.66	6.47	1079.30	410.07	2025-11-10 17:34:12.8353
650	sensor_rabano_2	22.64	71.62	64.47	1.45	6.61	1151.06	431.15	2025-11-10 17:34:12.835862
651	sensor_cilantro_1	19.47	63.41	68.17	1.83	6.44	1012.42	475.12	2025-11-10 17:34:12.836054
652	sensor_cilantro_2	21.21	74.02	72.53	1.72	6.79	1125.79	476.21	2025-11-10 17:34:12.836272
653	sensor_rabano_1	20.34	68.51	62.48	1.66	6.54	1080.27	429.27	2025-11-10 17:34:22.84578
654	sensor_rabano_2	21.32	70.20	79.52	1.59	6.40	1088.79	420.44	2025-11-10 17:34:22.846497
655	sensor_cilantro_1	21.50	67.96	67.79	1.91	6.49	1110.65	436.11	2025-11-10 17:34:22.846704
656	sensor_cilantro_2	22.16	62.01	71.30	1.44	6.71	924.51	498.99	2025-11-10 17:34:22.846865
657	sensor_rabano_1	23.51	66.43	65.45	1.49	6.65	827.05	480.04	2025-11-10 17:34:32.858199
658	sensor_rabano_2	20.87	60.74	69.50	1.96	6.71	1069.41	431.87	2025-11-10 17:34:32.858974
659	sensor_cilantro_1	20.88	65.07	78.82	1.44	6.62	862.16	491.45	2025-11-10 17:34:32.859157
660	sensor_cilantro_2	20.62	69.88	77.86	1.55	6.48	1137.88	451.41	2025-11-10 17:34:32.859299
661	sensor_rabano_1	23.64	68.44	79.40	1.97	6.54	1196.45	427.48	2025-11-10 17:34:42.870932
662	sensor_rabano_2	22.99	59.84	61.79	1.75	6.65	1174.81	438.83	2025-11-10 17:34:42.871889
663	sensor_cilantro_1	22.32	73.08	61.34	1.64	6.41	1194.72	400.53	2025-11-10 17:34:42.872148
664	sensor_cilantro_2	22.52	65.11	78.09	1.57	6.54	1096.18	462.18	2025-11-10 17:34:42.872392
665	sensor_rabano_1	23.47	61.13	78.42	1.51	6.65	1070.85	418.31	2025-11-10 17:34:52.884147
666	sensor_rabano_2	20.93	67.08	63.07	1.55	6.43	1187.63	495.58	2025-11-10 17:34:52.884892
667	sensor_cilantro_1	20.69	73.81	60.87	1.61	6.50	888.39	405.52	2025-11-10 17:34:52.885077
668	sensor_cilantro_2	22.11	76.67	76.87	1.91	6.46	1191.41	480.71	2025-11-10 17:34:52.885218
669	sensor_rabano_1	23.80	71.24	70.74	1.83	6.59	1093.88	460.87	2025-11-10 17:35:02.895368
670	sensor_rabano_2	20.90	63.59	61.31	1.58	6.58	1000.94	431.88	2025-11-10 17:35:02.895936
671	sensor_cilantro_1	22.79	73.50	68.00	1.97	6.42	1018.34	499.33	2025-11-10 17:35:02.896046
672	sensor_cilantro_2	20.69	66.43	75.13	1.41	6.49	1101.87	454.04	2025-11-10 17:35:02.896105
673	sensor_rabano_1	22.17	64.53	76.09	1.91	6.71	877.17	450.95	2025-11-10 17:35:12.904412
674	sensor_rabano_2	21.03	69.54	66.55	1.74	6.43	1127.61	417.81	2025-11-10 17:35:12.905007
675	sensor_cilantro_1	20.97	77.87	73.22	1.47	6.57	1039.24	486.42	2025-11-10 17:35:12.905114
676	sensor_cilantro_2	20.26	71.98	69.85	1.61	6.63	1195.62	456.95	2025-11-10 17:35:12.905173
677	sensor_rabano_1	20.50	66.88	65.15	1.65	6.42	853.75	467.84	2025-11-10 17:35:22.916463
678	sensor_rabano_2	21.35	70.87	61.62	1.86	6.63	850.10	440.63	2025-11-10 17:35:22.917319
679	sensor_cilantro_1	19.82	77.71	68.79	1.44	6.71	864.40	487.16	2025-11-10 17:35:22.917505
680	sensor_cilantro_2	19.84	72.26	61.27	1.53	6.65	1111.64	434.19	2025-11-10 17:35:22.917701
681	sensor_rabano_1	21.79	64.64	67.82	1.42	6.41	942.97	474.11	2025-11-10 17:35:32.928071
682	sensor_rabano_2	21.14	69.48	73.45	1.44	6.53	1114.54	446.36	2025-11-10 17:35:32.928789
683	sensor_cilantro_1	20.40	70.61	69.00	1.70	6.58	1106.25	402.01	2025-11-10 17:35:32.92897
684	sensor_cilantro_2	19.18	65.87	63.84	1.50	6.77	1023.39	433.10	2025-11-10 17:35:32.929109
685	sensor_rabano_1	23.50	64.86	71.38	1.78	6.73	1199.68	474.54	2025-11-10 17:35:42.940114
686	sensor_rabano_2	22.11	71.80	68.52	1.53	6.53	1129.09	466.82	2025-11-10 17:35:42.940809
687	sensor_cilantro_1	19.27	69.85	64.12	1.47	6.79	860.26	448.08	2025-11-10 17:35:42.940922
688	sensor_cilantro_2	19.86	75.49	74.64	1.87	6.79	1147.65	475.44	2025-11-10 17:35:42.940981
689	sensor_rabano_1	21.63	57.03	79.53	1.61	6.62	1138.10	485.75	2025-11-10 17:35:52.952116
690	sensor_rabano_2	22.97	66.73	64.59	1.99	6.49	927.91	494.69	2025-11-10 17:35:52.953223
691	sensor_cilantro_1	21.66	64.08	73.36	1.61	6.55	901.07	485.97	2025-11-10 17:35:52.953544
692	sensor_cilantro_2	21.65	71.74	67.22	1.97	6.79	986.70	488.79	2025-11-10 17:35:52.953852
693	sensor_rabano_1	23.52	64.14	62.67	1.72	6.41	1045.00	424.44	2025-11-10 17:36:02.964664
694	sensor_rabano_2	20.27	66.50	71.36	1.74	6.75	1136.77	414.43	2025-11-10 17:36:02.965178
695	sensor_cilantro_1	21.88	62.22	60.69	1.94	6.48	836.98	418.23	2025-11-10 17:36:02.965261
696	sensor_cilantro_2	23.00	66.84	75.24	1.45	6.79	1072.03	469.15	2025-11-10 17:36:02.965319
697	sensor_rabano_1	23.55	60.89	78.59	1.76	6.64	1058.56	419.23	2025-11-10 17:36:12.976084
698	sensor_rabano_2	23.04	61.38	63.56	1.46	6.51	1052.23	428.48	2025-11-10 17:36:12.977037
699	sensor_cilantro_1	21.57	71.30	79.45	1.49	6.44	916.78	454.43	2025-11-10 17:36:12.977267
700	sensor_cilantro_2	20.58	77.34	75.76	1.85	6.79	1083.27	411.27	2025-11-10 17:36:12.97742
701	sensor_rabano_1	20.58	63.78	76.57	1.44	6.51	943.32	497.75	2025-11-10 17:36:22.988799
702	sensor_rabano_2	21.95	69.96	65.54	1.44	6.46	1023.23	439.61	2025-11-10 17:36:22.989604
703	sensor_cilantro_1	21.63	71.07	63.47	1.78	6.58	1023.29	446.43	2025-11-10 17:36:22.989807
704	sensor_cilantro_2	20.14	73.72	79.90	1.85	6.63	1123.58	450.81	2025-11-10 17:36:22.989959
705	sensor_rabano_1	20.30	62.39	76.52	1.69	6.48	1009.79	415.13	2025-11-10 17:36:33.008961
706	sensor_rabano_2	22.31	59.21	60.39	1.81	6.54	1143.41	412.53	2025-11-10 17:36:33.009719
707	sensor_cilantro_1	19.96	65.90	63.60	1.69	6.57	1184.18	402.47	2025-11-10 17:36:33.009976
708	sensor_cilantro_2	20.85	64.03	79.94	1.70	6.68	977.45	419.98	2025-11-10 17:36:33.010213
709	sensor_rabano_1	20.93	72.04	79.45	1.77	6.62	838.34	480.83	2025-11-10 17:36:43.02011
710	sensor_rabano_2	22.26	62.20	65.50	1.55	6.75	921.38	453.10	2025-11-10 17:36:43.020633
711	sensor_cilantro_1	20.77	69.94	66.00	1.78	6.56	803.24	482.14	2025-11-10 17:36:43.020799
712	sensor_cilantro_2	21.60	75.18	69.46	1.53	6.78	939.80	450.31	2025-11-10 17:36:43.020882
713	sensor_rabano_1	21.06	66.78	79.56	1.62	6.68	1197.76	454.35	2025-11-10 17:36:53.031216
714	sensor_rabano_2	21.97	66.71	75.62	1.66	6.66	878.81	461.54	2025-11-10 17:36:53.03199
715	sensor_cilantro_1	19.85	77.18	67.18	1.65	6.54	834.29	415.66	2025-11-10 17:36:53.032172
716	sensor_cilantro_2	20.44	70.40	64.59	1.96	6.55	1135.62	481.93	2025-11-10 17:36:53.032256
717	sensor_rabano_1	23.55	58.74	65.94	1.57	6.75	1107.57	481.48	2025-11-10 17:37:03.043435
718	sensor_rabano_2	22.96	64.45	68.69	1.52	6.44	1038.00	425.58	2025-11-10 17:37:03.04434
719	sensor_cilantro_1	20.38	66.97	71.36	1.79	6.63	1029.37	420.44	2025-11-10 17:37:03.044534
720	sensor_cilantro_2	22.46	65.95	74.38	1.61	6.54	898.52	440.24	2025-11-10 17:37:03.044689
721	sensor_rabano_1	23.66	66.03	77.17	1.49	6.62	924.55	408.37	2025-11-10 17:37:13.056376
722	sensor_rabano_2	23.10	67.05	71.14	1.61	6.41	997.38	416.16	2025-11-10 17:37:13.057214
723	sensor_cilantro_1	19.08	75.05	67.49	1.85	6.78	899.79	412.35	2025-11-10 17:37:13.057415
724	sensor_cilantro_2	21.48	74.62	69.96	1.97	6.67	928.31	448.57	2025-11-10 17:37:13.0576
725	sensor_rabano_1	20.21	68.46	75.50	1.73	6.71	947.69	409.73	2025-11-10 17:37:23.069166
726	sensor_rabano_2	20.17	65.52	77.18	1.89	6.56	1183.45	453.13	2025-11-10 17:37:23.069928
727	sensor_cilantro_1	20.92	69.05	71.07	1.53	6.68	1067.90	426.18	2025-11-10 17:37:23.07012
728	sensor_cilantro_2	19.51	62.83	60.11	1.74	6.71	806.00	479.45	2025-11-10 17:37:23.070264
729	sensor_rabano_1	20.33	59.84	77.79	1.89	6.58	1185.45	438.19	2025-11-10 17:37:33.081576
730	sensor_rabano_2	23.87	67.81	78.35	1.85	6.44	931.82	476.10	2025-11-10 17:37:33.082463
731	sensor_cilantro_1	20.72	72.90	68.87	1.94	6.78	928.36	451.29	2025-11-10 17:37:33.082708
732	sensor_cilantro_2	19.07	73.07	78.98	1.41	6.54	906.84	465.43	2025-11-10 17:37:33.082958
733	sensor_rabano_1	22.19	66.81	64.49	1.55	6.72	1150.94	412.54	2025-11-10 17:37:43.093206
734	sensor_rabano_2	21.22	57.49	77.08	1.87	6.51	939.59	407.27	2025-11-10 17:37:43.093769
735	sensor_cilantro_1	21.03	67.42	76.67	1.58	6.75	951.98	404.91	2025-11-10 17:37:43.093849
736	sensor_cilantro_2	19.51	68.21	78.93	1.81	6.68	1025.47	404.52	2025-11-10 17:37:43.093906
737	sensor_rabano_1	22.12	70.88	69.66	1.60	6.62	1157.24	459.42	2025-11-10 17:37:53.103836
738	sensor_rabano_2	23.02	59.07	79.04	1.54	6.77	1004.80	420.22	2025-11-10 17:37:53.10448
739	sensor_cilantro_1	20.23	63.83	61.72	1.57	6.72	908.32	409.35	2025-11-10 17:37:53.104593
740	sensor_cilantro_2	22.01	77.89	78.93	1.78	6.59	897.12	498.83	2025-11-10 17:37:53.104653
741	sensor_rabano_1	23.63	61.50	77.93	1.68	6.67	1065.47	444.85	2025-11-10 17:38:03.113105
742	sensor_rabano_2	20.17	58.73	71.83	1.73	6.66	924.89	409.16	2025-11-10 17:38:03.113593
743	sensor_cilantro_1	20.19	69.45	73.78	1.76	6.40	1160.08	460.88	2025-11-10 17:38:03.113681
744	sensor_cilantro_2	20.04	66.58	78.37	1.76	6.62	819.12	491.22	2025-11-10 17:38:03.11374
745	sensor_rabano_1	23.87	59.70	63.95	1.46	6.47	847.04	413.19	2025-11-10 17:38:48.002779
746	sensor_rabano_2	21.67	57.72	73.07	1.41	6.49	1150.30	482.11	2025-11-10 17:38:48.003234
747	sensor_cilantro_1	20.33	73.64	78.78	1.51	6.58	1067.95	439.13	2025-11-10 17:38:48.003315
748	sensor_cilantro_2	20.87	68.07	71.12	1.70	6.52	1051.39	408.10	2025-11-10 17:38:48.003373
749	sensor_rabano_1	20.13	64.52	62.17	1.99	6.59	987.73	450.63	2025-11-10 17:38:58.014847
750	sensor_rabano_2	22.15	61.40	62.00	1.46	6.44	938.29	407.90	2025-11-10 17:38:58.015606
751	sensor_cilantro_1	20.73	67.57	71.96	1.51	6.64	913.65	455.78	2025-11-10 17:38:58.015789
752	sensor_cilantro_2	22.95	65.13	64.89	1.51	6.75	892.47	422.43	2025-11-10 17:38:58.016037
753	sensor_rabano_1	21.91	65.21	61.29	1.97	6.43	1188.29	472.72	2025-11-10 17:39:08.027989
754	sensor_rabano_2	21.59	59.50	75.65	1.62	6.46	1149.82	498.66	2025-11-10 17:39:08.028857
755	sensor_cilantro_1	20.34	66.97	73.05	1.85	6.53	1128.39	470.07	2025-11-10 17:39:08.029041
756	sensor_cilantro_2	22.60	62.07	77.95	1.53	6.51	1160.14	459.51	2025-11-10 17:39:08.029296
757	sensor_rabano_1	21.87	57.06	70.99	1.70	6.78	1141.46	402.11	2025-11-10 17:39:18.040964
758	sensor_rabano_2	21.38	70.17	78.51	1.54	6.45	1105.31	409.73	2025-11-10 17:39:18.041815
759	sensor_cilantro_1	22.75	76.83	63.98	1.51	6.42	1164.83	434.10	2025-11-10 17:39:18.042006
760	sensor_cilantro_2	20.65	62.83	71.97	1.97	6.75	1173.26	410.72	2025-11-10 17:39:18.042209
761	sensor_rabano_1	20.58	71.72	77.23	1.70	6.73	1024.21	426.16	2025-11-10 17:39:28.053877
762	sensor_rabano_2	22.25	61.72	62.58	1.94	6.73	890.66	457.78	2025-11-10 17:39:28.054797
763	sensor_cilantro_1	19.53	73.51	64.65	1.73	6.73	1016.74	455.26	2025-11-10 17:39:28.055095
764	sensor_cilantro_2	21.43	63.26	60.39	1.67	6.69	1016.07	445.12	2025-11-10 17:39:28.055467
765	sensor_rabano_1	22.46	70.76	66.52	1.82	6.76	835.36	476.90	2025-11-10 17:39:38.066978
766	sensor_rabano_2	20.62	71.81	77.63	1.79	6.42	835.40	489.59	2025-11-10 17:39:38.068023
767	sensor_cilantro_1	22.68	70.49	76.89	1.59	6.79	824.86	498.50	2025-11-10 17:39:38.068333
768	sensor_cilantro_2	19.88	71.47	70.50	1.70	6.49	819.53	455.80	2025-11-10 17:39:38.068574
769	sensor_rabano_1	20.01	58.59	65.51	1.82	6.54	942.53	439.58	2025-11-10 17:39:48.079963
770	sensor_rabano_2	21.26	70.24	73.43	1.41	6.40	830.30	472.12	2025-11-10 17:39:48.080759
771	sensor_cilantro_1	20.43	68.96	77.82	1.49	6.60	1186.49	434.31	2025-11-10 17:39:48.080931
772	sensor_cilantro_2	19.32	69.79	62.81	1.62	6.44	1023.01	424.67	2025-11-10 17:39:48.081073
773	sensor_rabano_1	20.24	61.38	78.88	1.89	6.51	1108.49	425.99	2025-11-10 17:39:58.091256
774	sensor_rabano_2	20.90	69.96	69.90	1.97	6.73	832.06	433.14	2025-11-10 17:39:58.091981
775	sensor_cilantro_1	21.99	75.70	63.63	1.82	6.64	835.29	485.12	2025-11-10 17:39:58.092167
776	sensor_cilantro_2	20.19	71.28	69.09	1.49	6.66	1083.52	472.60	2025-11-10 17:39:58.092241
777	sensor_rabano_1	23.82	60.57	67.79	1.69	6.50	1023.95	408.05	2025-11-10 17:40:08.101943
778	sensor_rabano_2	20.35	59.96	70.55	1.99	6.54	1095.60	480.92	2025-11-10 17:40:08.102791
779	sensor_cilantro_1	19.89	69.21	73.91	1.83	6.60	888.93	425.85	2025-11-10 17:40:08.10298
780	sensor_cilantro_2	20.42	68.63	67.49	1.79	6.68	984.01	439.91	2025-11-10 17:40:08.103233
781	sensor_rabano_1	20.00	69.30	67.70	1.42	6.61	1057.33	469.33	2025-11-10 17:40:18.113786
782	sensor_rabano_2	21.49	64.41	71.59	1.56	6.79	1069.57	473.56	2025-11-10 17:40:18.114647
783	sensor_cilantro_1	19.23	71.17	65.78	1.95	6.50	1136.33	449.82	2025-11-10 17:40:18.114836
784	sensor_cilantro_2	22.71	66.88	76.22	1.72	6.45	894.48	443.40	2025-11-10 17:40:18.114981
785	sensor_rabano_1	20.89	57.02	73.49	1.45	6.65	1087.35	456.90	2025-11-10 17:40:28.125044
786	sensor_rabano_2	22.79	66.46	68.66	1.77	6.48	1066.70	492.51	2025-11-10 17:40:28.126094
787	sensor_cilantro_1	20.74	65.02	66.97	1.58	6.74	1079.94	451.69	2025-11-10 17:40:28.12641
788	sensor_cilantro_2	22.19	62.39	74.26	1.63	6.41	967.45	418.10	2025-11-10 17:40:28.126638
789	sensor_rabano_1	23.32	57.84	62.19	1.94	6.43	1167.24	447.82	2025-11-10 17:40:38.136223
790	sensor_rabano_2	22.88	58.05	71.92	1.82	6.71	919.95	482.23	2025-11-10 17:40:38.137052
791	sensor_cilantro_1	19.43	75.24	64.60	1.69	6.69	943.87	404.46	2025-11-10 17:40:38.137359
792	sensor_cilantro_2	20.62	65.02	64.70	1.88	6.51	1018.54	428.08	2025-11-10 17:40:38.13761
793	sensor_rabano_1	23.56	68.36	75.31	1.62	6.64	1036.19	409.07	2025-11-10 17:40:48.147611
794	sensor_rabano_2	22.11	69.58	71.37	1.64	6.65	1001.73	413.11	2025-11-10 17:40:48.148431
795	sensor_cilantro_1	20.97	72.55	65.53	1.85	6.71	1114.67	422.65	2025-11-10 17:40:48.148628
796	sensor_cilantro_2	22.94	75.13	60.28	1.80	6.63	1059.15	489.65	2025-11-10 17:40:48.148775
797	sensor_rabano_1	23.19	59.95	75.82	1.78	6.56	1036.98	459.57	2025-11-10 17:40:58.158867
798	sensor_rabano_2	20.99	59.79	66.18	1.43	6.78	884.07	477.79	2025-11-10 17:40:58.159612
799	sensor_cilantro_1	20.03	63.24	77.10	1.93	6.76	946.80	465.63	2025-11-10 17:40:58.159817
800	sensor_cilantro_2	21.96	64.25	75.77	2.00	6.64	879.27	491.31	2025-11-10 17:40:58.160074
801	sensor_rabano_1	21.45	71.02	78.01	1.61	6.66	867.29	499.25	2025-11-10 17:41:08.170733
802	sensor_rabano_2	20.50	69.43	74.19	1.95	6.47	864.21	488.61	2025-11-10 17:41:08.171641
803	sensor_cilantro_1	21.19	67.89	66.48	2.00	6.78	1168.80	460.49	2025-11-10 17:41:08.171927
804	sensor_cilantro_2	22.21	74.71	68.08	1.54	6.66	942.76	414.56	2025-11-10 17:41:08.172203
805	sensor_rabano_1	23.70	63.07	64.54	1.50	6.51	1199.06	429.70	2025-11-10 17:41:18.182184
806	sensor_rabano_2	22.86	60.92	72.81	1.84	6.73	838.29	404.85	2025-11-10 17:41:18.183044
807	sensor_cilantro_1	19.03	73.86	71.54	1.58	6.73	1076.28	456.54	2025-11-10 17:41:18.183309
808	sensor_cilantro_2	21.55	75.22	76.09	1.64	6.58	812.39	430.98	2025-11-10 17:41:18.18348
809	sensor_rabano_1	20.96	60.92	72.86	1.70	6.65	848.69	419.56	2025-11-10 17:41:28.193867
810	sensor_rabano_2	22.89	57.68	67.98	1.45	6.68	834.81	450.50	2025-11-10 17:41:28.194638
811	sensor_cilantro_1	21.37	64.76	62.60	1.66	6.73	1019.06	442.93	2025-11-10 17:41:28.194824
812	sensor_cilantro_2	22.15	63.91	77.35	1.48	6.57	1103.85	462.75	2025-11-10 17:41:28.194966
813	sensor_rabano_1	22.11	67.15	61.42	1.63	6.44	831.68	451.44	2025-11-10 17:41:38.215961
814	sensor_rabano_2	23.47	63.04	60.35	1.63	6.42	1061.69	449.98	2025-11-10 17:41:38.216902
815	sensor_cilantro_1	19.03	75.26	60.20	1.92	6.68	814.49	445.97	2025-11-10 17:41:38.217194
816	sensor_cilantro_2	21.52	70.39	69.84	1.46	6.69	962.91	455.95	2025-11-10 17:41:38.217455
817	sensor_rabano_1	22.69	67.77	78.34	1.56	6.57	913.74	453.77	2025-11-10 17:41:48.226077
818	sensor_rabano_2	20.85	70.48	71.88	1.91	6.64	1061.70	458.53	2025-11-10 17:41:48.226566
819	sensor_cilantro_1	22.33	65.41	74.40	1.96	6.51	990.78	468.11	2025-11-10 17:41:48.226647
820	sensor_cilantro_2	20.76	75.81	68.86	1.44	6.68	961.00	467.01	2025-11-10 17:41:48.226705
821	sensor_rabano_1	23.78	65.35	75.67	1.57	6.64	905.13	499.51	2025-11-10 17:41:58.236539
822	sensor_rabano_2	20.21	63.30	61.60	1.85	6.53	995.49	471.29	2025-11-10 17:41:58.237299
823	sensor_cilantro_1	22.41	70.13	75.05	1.47	6.57	872.73	494.17	2025-11-10 17:41:58.237484
824	sensor_cilantro_2	19.91	77.57	72.39	1.72	6.66	1034.19	424.28	2025-11-10 17:41:58.237626
825	sensor_rabano_1	23.43	66.23	71.67	1.85	6.54	1180.76	430.95	2025-11-10 17:42:08.245619
826	sensor_rabano_2	20.88	64.12	65.92	1.97	6.60	1156.55	465.61	2025-11-10 17:42:08.246127
827	sensor_cilantro_1	22.70	62.29	60.15	1.76	6.62	854.23	426.81	2025-11-10 17:42:08.246326
828	sensor_cilantro_2	21.40	62.60	62.68	1.57	6.71	1161.97	491.26	2025-11-10 17:42:08.246418
829	sensor_rabano_1	22.96	62.59	70.39	1.78	6.52	922.85	450.22	2025-11-10 17:42:18.25618
830	sensor_rabano_2	22.89	68.55	72.37	1.75	6.60	912.15	430.34	2025-11-10 17:42:18.257049
831	sensor_cilantro_1	19.91	62.47	66.87	1.93	6.58	845.68	472.25	2025-11-10 17:42:18.25729
832	sensor_cilantro_2	21.94	62.81	66.53	1.55	6.78	845.73	432.52	2025-11-10 17:42:18.25745
833	sensor_rabano_1	21.59	64.51	64.89	1.69	6.57	1029.14	414.19	2025-11-10 17:42:28.267279
834	sensor_rabano_2	21.26	61.92	63.04	1.89	6.64	1014.93	466.62	2025-11-10 17:42:28.268204
835	sensor_cilantro_1	22.17	63.75	69.90	1.69	6.41	1147.03	451.37	2025-11-10 17:42:28.26843
836	sensor_cilantro_2	20.85	63.90	73.98	1.84	6.62	926.65	429.49	2025-11-10 17:42:28.268585
837	sensor_rabano_1	21.88	64.05	74.21	1.46	6.56	1128.10	496.60	2025-11-10 17:42:38.278771
838	sensor_rabano_2	23.70	57.84	60.81	1.55	6.47	928.50	457.39	2025-11-10 17:42:38.279313
839	sensor_cilantro_1	20.05	68.60	78.33	1.91	6.62	1188.86	431.62	2025-11-10 17:42:38.279424
840	sensor_cilantro_2	20.28	73.23	64.18	2.00	6.59	1141.42	469.64	2025-11-10 17:42:38.279488
841	sensor_rabano_1	23.77	61.88	75.96	1.64	6.62	949.19	420.49	2025-11-10 17:42:48.288054
842	sensor_rabano_2	23.65	63.81	61.64	1.95	6.76	1016.89	428.88	2025-11-10 17:42:48.288638
843	sensor_cilantro_1	19.21	63.89	77.95	1.76	6.63	1068.29	458.91	2025-11-10 17:42:48.288753
844	sensor_cilantro_2	20.76	72.67	73.49	1.62	6.75	1097.97	480.78	2025-11-10 17:42:48.288813
845	sensor_rabano_1	22.97	70.00	67.57	1.78	6.75	1043.34	462.87	2025-11-10 17:42:58.298215
846	sensor_rabano_2	22.75	67.09	73.19	1.49	6.67	1189.26	476.10	2025-11-10 17:42:58.299019
847	sensor_cilantro_1	20.65	72.96	78.11	1.40	6.51	899.09	445.39	2025-11-10 17:42:58.299237
848	sensor_cilantro_2	20.58	68.00	77.23	1.94	6.80	937.99	410.54	2025-11-10 17:42:58.299384
849	sensor_rabano_1	22.44	65.64	66.48	1.45	6.55	1110.65	485.95	2025-11-10 17:43:08.307057
850	sensor_rabano_2	20.02	61.09	62.41	1.43	6.55	881.40	460.22	2025-11-10 17:43:08.307819
851	sensor_cilantro_1	22.94	72.91	65.79	1.65	6.48	1102.19	488.28	2025-11-10 17:43:08.307907
852	sensor_cilantro_2	22.76	69.50	72.82	1.61	6.71	1088.59	496.40	2025-11-10 17:43:08.307966
853	sensor_rabano_1	23.48	70.30	63.76	1.94	6.78	938.73	485.76	2025-11-10 17:43:18.317331
854	sensor_rabano_2	20.05	57.13	72.23	1.79	6.68	1073.89	401.55	2025-11-10 17:43:18.318167
855	sensor_cilantro_1	19.86	67.39	76.25	1.65	6.48	1065.99	436.09	2025-11-10 17:43:18.318353
856	sensor_cilantro_2	20.26	72.93	61.81	1.46	6.43	941.57	473.84	2025-11-10 17:43:18.318494
857	sensor_rabano_1	23.40	64.92	63.41	1.69	6.47	1176.90	498.08	2025-11-10 17:43:28.327849
858	sensor_rabano_2	23.08	67.52	76.81	1.59	6.75	1136.43	496.24	2025-11-10 17:43:28.328613
859	sensor_cilantro_1	22.77	69.62	61.75	1.58	6.45	830.96	414.55	2025-11-10 17:43:28.328838
860	sensor_cilantro_2	21.74	67.50	65.61	1.91	6.57	890.85	474.71	2025-11-10 17:43:28.328992
861	sensor_rabano_1	23.45	64.29	61.93	1.41	6.70	847.95	482.61	2025-11-10 17:43:38.339027
862	sensor_rabano_2	20.88	68.48	78.13	1.89	6.62	1183.99	434.84	2025-11-10 17:43:38.339802
863	sensor_cilantro_1	20.76	68.88	69.88	1.63	6.69	969.06	443.00	2025-11-10 17:43:38.339978
864	sensor_cilantro_2	22.83	77.28	75.89	1.74	6.68	981.43	455.39	2025-11-10 17:43:38.34019
865	sensor_rabano_1	21.90	71.49	69.40	1.98	6.50	896.32	424.81	2025-11-10 17:43:48.351086
866	sensor_rabano_2	22.20	57.13	79.56	1.94	6.78	955.55	422.36	2025-11-10 17:43:48.351702
867	sensor_cilantro_1	21.96	66.72	77.93	1.86	6.50	932.09	421.76	2025-11-10 17:43:48.351796
868	sensor_cilantro_2	21.30	66.76	65.56	1.69	6.68	952.68	491.13	2025-11-10 17:43:48.351854
869	sensor_rabano_1	20.07	71.13	62.36	1.83	6.51	1056.52	498.15	2025-11-10 17:43:58.362778
870	sensor_rabano_2	20.25	66.83	71.28	1.62	6.48	843.02	490.50	2025-11-10 17:43:58.363715
871	sensor_cilantro_1	20.70	71.53	75.13	1.70	6.65	837.60	406.55	2025-11-10 17:43:58.363923
872	sensor_cilantro_2	19.36	74.31	66.38	1.98	6.73	1014.03	420.70	2025-11-10 17:43:58.364006
873	sensor_rabano_1	23.26	71.52	70.70	1.65	6.55	999.99	498.88	2025-11-10 17:44:08.373713
874	sensor_rabano_2	23.67	65.83	67.27	1.80	6.46	920.83	475.87	2025-11-10 17:44:08.374564
875	sensor_cilantro_1	19.18	66.61	78.73	1.74	6.42	1093.07	432.38	2025-11-10 17:44:08.3748
876	sensor_cilantro_2	20.93	73.13	60.29	1.44	6.71	886.37	406.10	2025-11-10 17:44:08.374998
877	sensor_rabano_1	22.17	60.22	69.64	1.50	6.51	1177.40	401.06	2025-11-10 17:44:18.386618
878	sensor_rabano_2	21.40	70.76	75.44	1.84	6.65	1095.15	463.17	2025-11-10 17:44:18.387403
879	sensor_cilantro_1	21.23	69.96	65.75	1.60	6.64	844.69	409.32	2025-11-10 17:44:18.387634
880	sensor_cilantro_2	20.13	65.76	72.80	1.69	6.54	1022.26	425.91	2025-11-10 17:44:18.387796
881	sensor_rabano_1	22.08	65.60	74.04	1.94	6.47	1119.29	449.57	2025-11-10 17:44:28.3981
882	sensor_rabano_2	22.41	64.12	63.48	1.66	6.55	1159.95	459.00	2025-11-10 17:44:28.398758
883	sensor_cilantro_1	20.83	67.69	60.77	1.79	6.71	1119.84	458.42	2025-11-10 17:44:28.398865
884	sensor_cilantro_2	19.52	74.85	71.78	1.76	6.76	1061.60	494.13	2025-11-10 17:44:28.398925
885	sensor_rabano_1	21.40	67.31	67.39	1.75	6.43	1017.78	410.64	2025-11-10 17:44:38.409564
886	sensor_rabano_2	20.55	65.36	72.60	1.94	6.46	1025.65	472.23	2025-11-10 17:44:38.41007
887	sensor_cilantro_1	21.38	65.97	62.38	1.69	6.63	1131.90	439.21	2025-11-10 17:44:38.410283
888	sensor_cilantro_2	19.89	73.43	72.99	1.81	6.40	949.51	472.12	2025-11-10 17:44:38.410348
889	sensor_rabano_1	20.35	63.83	71.05	1.73	6.43	837.78	447.79	2025-11-10 17:44:48.420648
890	sensor_rabano_2	22.20	65.28	69.88	1.74	6.67	961.63	435.46	2025-11-10 17:44:48.421321
891	sensor_cilantro_1	19.54	69.85	64.57	1.49	6.70	1189.00	449.39	2025-11-10 17:44:48.421498
892	sensor_cilantro_2	21.28	74.41	71.64	1.58	6.48	930.61	427.83	2025-11-10 17:44:48.421673
893	sensor_rabano_1	22.87	69.98	63.53	1.40	6.80	1029.22	494.79	2025-11-10 17:44:58.43302
894	sensor_rabano_2	21.64	67.45	75.56	1.69	6.72	971.66	498.60	2025-11-10 17:44:58.43391
895	sensor_cilantro_1	22.77	73.16	75.82	1.64	6.58	1125.87	458.73	2025-11-10 17:44:58.434105
896	sensor_cilantro_2	21.66	71.17	72.02	1.71	6.71	1190.31	475.83	2025-11-10 17:44:58.434368
897	sensor_rabano_1	21.78	61.18	72.98	1.74	6.76	1036.57	420.20	2025-11-10 17:45:08.442862
898	sensor_rabano_2	21.02	72.16	68.05	1.52	6.48	1144.74	497.89	2025-11-10 17:45:08.443421
899	sensor_cilantro_1	19.29	64.82	77.24	1.91	6.43	1197.72	435.56	2025-11-10 17:45:08.443528
900	sensor_cilantro_2	20.55	67.14	63.19	1.84	6.61	927.01	453.25	2025-11-10 17:45:08.443601
901	sensor_rabano_1	20.44	68.09	79.92	1.98	6.46	862.94	442.41	2025-11-10 17:45:18.454632
902	sensor_rabano_2	21.66	70.22	64.09	1.43	6.77	992.85	464.25	2025-11-10 17:45:18.455561
903	sensor_cilantro_1	21.37	74.98	75.88	1.97	6.65	855.70	493.42	2025-11-10 17:45:18.455801
904	sensor_cilantro_2	22.16	77.48	62.62	1.71	6.70	1185.51	418.73	2025-11-10 17:45:18.45601
905	sensor_rabano_1	21.01	61.09	73.64	1.88	6.75	1125.75	486.57	2025-11-10 17:45:28.466332
906	sensor_rabano_2	21.31	59.51	73.18	1.80	6.56	1011.36	445.67	2025-11-10 17:45:28.467094
907	sensor_cilantro_1	22.41	68.20	60.66	1.55	6.58	829.41	408.13	2025-11-10 17:45:28.467284
908	sensor_cilantro_2	22.70	70.97	78.56	1.87	6.64	1039.22	431.39	2025-11-10 17:45:28.467428
909	sensor_rabano_1	22.70	69.67	71.47	1.42	6.48	1047.21	416.50	2025-11-10 17:45:38.477535
910	sensor_rabano_2	21.21	58.77	75.70	1.88	6.77	819.49	464.33	2025-11-10 17:45:38.478359
911	sensor_cilantro_1	22.25	67.66	72.68	1.98	6.64	1145.94	474.45	2025-11-10 17:45:38.478642
912	sensor_cilantro_2	22.27	75.97	65.27	1.78	6.49	1045.54	491.63	2025-11-10 17:45:38.478835
913	sensor_rabano_1	20.90	68.66	63.70	1.91	6.45	963.02	497.48	2025-11-10 17:45:48.488206
914	sensor_rabano_2	23.37	65.49	68.77	1.49	6.77	876.26	420.54	2025-11-10 17:45:48.488842
915	sensor_cilantro_1	21.42	70.02	64.63	1.73	6.56	1031.79	421.58	2025-11-10 17:45:48.488945
916	sensor_cilantro_2	19.07	72.47	62.73	1.50	6.54	1086.19	476.23	2025-11-10 17:45:48.489006
917	sensor_rabano_1	22.68	72.30	65.16	1.74	6.74	903.46	453.77	2025-11-10 17:45:58.499864
918	sensor_rabano_2	21.58	69.74	65.08	1.63	6.78	887.53	425.30	2025-11-10 17:45:58.500411
919	sensor_cilantro_1	22.61	76.92	64.25	1.94	6.76	992.56	454.86	2025-11-10 17:45:58.500519
920	sensor_cilantro_2	21.69	74.79	65.52	1.92	6.50	802.41	432.58	2025-11-10 17:45:58.500579
921	sensor_rabano_1	22.21	62.97	67.11	1.74	6.65	1147.06	499.76	2025-11-10 17:46:08.512529
922	sensor_rabano_2	20.17	71.07	60.10	1.74	6.52	877.85	416.56	2025-11-10 17:46:08.513108
923	sensor_cilantro_1	22.46	74.50	62.17	1.48	6.64	988.16	492.34	2025-11-10 17:46:08.51319
924	sensor_cilantro_2	20.07	66.71	72.58	1.60	6.46	1166.26	434.27	2025-11-10 17:46:08.513363
925	sensor_rabano_1	21.40	69.78	71.22	1.69	6.41	983.13	426.94	2025-11-10 17:46:18.524312
926	sensor_rabano_2	21.67	71.84	71.46	1.69	6.46	853.80	457.93	2025-11-10 17:46:18.525036
927	sensor_cilantro_1	19.77	63.26	65.26	1.96	6.56	1177.30	458.77	2025-11-10 17:46:18.525221
928	sensor_cilantro_2	20.69	63.00	61.12	1.91	6.55	1013.94	456.93	2025-11-10 17:46:18.52536
929	sensor_rabano_1	21.48	61.12	68.84	1.52	6.75	1017.97	477.64	2025-11-10 17:46:28.536766
930	sensor_rabano_2	23.64	65.14	70.28	1.43	6.65	1148.44	438.87	2025-11-10 17:46:28.53756
931	sensor_cilantro_1	20.45	77.13	76.39	1.83	6.43	1017.92	491.25	2025-11-10 17:46:28.537747
932	sensor_cilantro_2	20.45	69.27	78.86	2.00	6.41	1117.56	453.19	2025-11-10 17:46:28.537897
933	sensor_rabano_1	22.39	69.34	75.17	1.76	6.77	1052.95	439.67	2025-11-10 17:46:38.561405
934	sensor_rabano_2	21.84	65.64	76.92	1.74	6.73	1000.21	448.49	2025-11-10 17:46:38.56215
935	sensor_cilantro_1	22.00	66.16	77.37	1.63	6.56	1197.63	467.45	2025-11-10 17:46:38.562388
936	sensor_cilantro_2	21.74	76.78	79.82	1.84	6.65	946.87	453.67	2025-11-10 17:46:38.562539
937	sensor_rabano_1	21.49	58.33	60.82	1.97	6.64	884.88	457.40	2025-11-10 17:46:48.574137
938	sensor_rabano_2	21.11	59.56	78.77	1.66	6.43	825.14	492.15	2025-11-10 17:46:48.574892
939	sensor_cilantro_1	21.57	77.48	65.70	1.43	6.51	953.90	416.47	2025-11-10 17:46:48.575078
940	sensor_cilantro_2	22.02	75.54	63.61	1.77	6.60	1082.66	475.34	2025-11-10 17:46:48.575248
941	sensor_rabano_1	22.44	60.17	61.05	1.46	6.79	809.44	463.40	2025-11-10 17:46:58.585556
942	sensor_rabano_2	21.21	59.39	61.96	1.88	6.69	810.27	448.07	2025-11-10 17:46:58.58626
943	sensor_cilantro_1	19.25	72.73	76.84	1.57	6.49	802.89	428.24	2025-11-10 17:46:58.586435
944	sensor_cilantro_2	20.58	63.15	68.57	1.80	6.78	810.51	462.59	2025-11-10 17:46:58.586571
945	sensor_rabano_1	23.36	72.75	67.16	1.55	6.44	914.63	484.03	2025-11-10 17:47:08.598313
946	sensor_rabano_2	23.20	63.47	73.07	1.70	6.70	1109.21	426.61	2025-11-10 17:47:08.59933
947	sensor_cilantro_1	20.79	75.70	77.96	1.60	6.70	984.55	431.17	2025-11-10 17:47:08.599559
948	sensor_cilantro_2	19.03	69.60	78.24	1.73	6.44	1013.25	421.93	2025-11-10 17:47:08.599719
949	sensor_rabano_1	22.61	71.24	76.33	1.85	6.43	839.14	443.75	2025-11-10 17:47:19.19494
950	sensor_rabano_2	20.71	67.30	66.72	1.53	6.76	1156.15	431.51	2025-11-10 17:47:19.195654
951	sensor_cilantro_1	19.76	64.17	66.38	1.43	6.76	925.14	412.65	2025-11-10 17:47:19.195783
952	sensor_cilantro_2	19.54	64.89	77.80	1.45	6.61	957.64	439.11	2025-11-10 17:47:19.195976
953	sensor_rabano_1	21.07	60.42	61.82	1.89	6.61	1182.11	444.25	2025-11-10 17:47:29.207657
954	sensor_rabano_2	22.42	61.23	70.10	1.86	6.59	1089.77	400.43	2025-11-10 17:47:29.208605
955	sensor_cilantro_1	20.24	69.95	74.50	1.71	6.57	915.12	495.37	2025-11-10 17:47:29.208816
956	sensor_cilantro_2	19.26	70.26	72.47	1.82	6.59	865.15	450.98	2025-11-10 17:47:29.209012
957	sensor_rabano_1	23.90	65.89	64.69	1.74	6.42	1197.04	415.52	2025-11-10 17:47:39.22036
958	sensor_rabano_2	22.13	63.00	63.78	1.96	6.50	1195.13	414.24	2025-11-10 17:47:39.221364
959	sensor_cilantro_1	21.83	73.94	75.46	1.73	6.59	1069.36	406.20	2025-11-10 17:47:39.22162
960	sensor_cilantro_2	22.50	77.51	60.34	1.46	6.75	893.66	453.81	2025-11-10 17:47:39.221823
961	sensor_rabano_1	23.31	70.51	72.39	1.95	6.72	1001.73	408.28	2025-11-10 17:47:49.233757
962	sensor_rabano_2	21.18	59.20	66.29	1.75	6.67	966.02	450.64	2025-11-10 17:47:49.234573
963	sensor_cilantro_1	21.89	70.01	74.81	1.53	6.74	895.92	492.37	2025-11-10 17:47:49.234762
964	sensor_cilantro_2	21.92	74.92	66.18	1.73	6.50	862.68	494.20	2025-11-10 17:47:49.234961
965	sensor_rabano_1	21.02	68.60	63.75	1.75	6.72	1130.52	435.55	2025-11-10 17:47:59.246359
966	sensor_rabano_2	23.36	64.11	78.16	1.54	6.66	1186.51	461.73	2025-11-10 17:47:59.247054
967	sensor_cilantro_1	20.41	67.37	79.77	1.75	6.59	874.01	421.15	2025-11-10 17:47:59.247224
968	sensor_cilantro_2	21.42	75.49	67.36	1.90	6.78	1050.40	469.88	2025-11-10 17:47:59.24736
969	sensor_rabano_1	22.26	72.51	68.84	1.51	6.60	917.28	480.53	2025-11-10 17:48:09.256616
970	sensor_rabano_2	23.81	57.71	67.37	1.53	6.43	1099.40	451.16	2025-11-10 17:48:09.257085
971	sensor_cilantro_1	22.66	77.43	63.09	1.96	6.63	918.46	490.89	2025-11-10 17:48:09.257261
972	sensor_cilantro_2	21.33	68.62	76.89	1.40	6.64	921.26	457.81	2025-11-10 17:48:09.257325
973	sensor_rabano_1	20.97	57.93	73.44	1.58	6.45	1063.73	494.21	2025-11-10 17:48:19.268132
974	sensor_rabano_2	23.36	65.22	78.68	1.74	6.57	990.41	457.79	2025-11-10 17:48:19.268955
975	sensor_cilantro_1	19.58	69.76	63.75	1.83	6.70	976.68	448.69	2025-11-10 17:48:19.269191
976	sensor_cilantro_2	20.17	72.23	73.69	1.63	6.69	1037.40	415.06	2025-11-10 17:48:19.269386
977	sensor_rabano_1	21.15	59.78	63.41	1.95	6.74	992.46	415.60	2025-11-10 17:48:29.278546
978	sensor_rabano_2	23.84	71.54	77.90	1.86	6.45	854.00	422.17	2025-11-10 17:48:29.279186
979	sensor_cilantro_1	19.72	64.93	71.51	1.57	6.78	1021.68	496.02	2025-11-10 17:48:29.279291
980	sensor_cilantro_2	19.63	66.34	66.52	1.52	6.42	1159.63	483.08	2025-11-10 17:48:29.279351
981	sensor_rabano_1	20.71	60.24	68.99	1.77	6.55	894.32	448.28	2025-11-10 17:48:39.29081
982	sensor_rabano_2	22.80	61.33	64.07	1.53	6.53	812.31	484.68	2025-11-10 17:48:39.291674
983	sensor_cilantro_1	22.02	68.17	62.12	1.85	6.69	975.52	433.35	2025-11-10 17:48:39.291866
984	sensor_cilantro_2	20.08	77.67	62.72	1.54	6.49	863.00	476.48	2025-11-10 17:48:39.292091
985	sensor_rabano_1	20.39	69.39	69.04	1.57	6.76	914.64	419.18	2025-11-10 17:48:49.303843
986	sensor_rabano_2	20.04	59.37	79.72	1.92	6.59	1038.40	470.58	2025-11-10 17:48:49.304609
987	sensor_cilantro_1	20.76	69.12	66.94	1.84	6.51	1054.67	417.97	2025-11-10 17:48:49.304782
988	sensor_cilantro_2	20.56	71.46	69.09	1.70	6.73	1083.44	470.16	2025-11-10 17:48:49.304973
989	sensor_rabano_1	22.59	71.88	64.69	1.69	6.52	1154.05	483.01	2025-11-10 17:48:59.316525
990	sensor_rabano_2	22.03	58.66	78.00	1.92	6.50	1175.85	409.62	2025-11-10 17:48:59.31725
991	sensor_cilantro_1	20.61	74.77	64.11	1.89	6.67	1056.86	495.98	2025-11-10 17:48:59.317337
992	sensor_cilantro_2	20.56	75.73	68.73	1.84	6.67	1146.12	444.69	2025-11-10 17:48:59.3174
993	sensor_rabano_1	20.46	72.82	67.54	1.98	6.49	1153.11	461.27	2025-11-10 17:49:09.328873
994	sensor_rabano_2	20.14	59.27	76.28	1.72	6.71	1009.49	472.94	2025-11-10 17:49:09.329729
995	sensor_cilantro_1	20.88	69.42	79.15	1.61	6.76	1028.03	427.90	2025-11-10 17:49:09.329928
996	sensor_cilantro_2	21.55	71.96	72.28	1.46	6.49	945.31	498.67	2025-11-10 17:49:09.330083
997	sensor_rabano_1	23.54	68.13	76.61	1.42	6.73	1111.81	454.38	2025-11-10 17:49:19.338905
998	sensor_rabano_2	21.32	67.20	79.36	1.79	6.61	889.08	436.09	2025-11-10 17:49:19.339364
999	sensor_cilantro_1	22.34	63.24	62.08	1.84	6.54	1111.28	480.08	2025-11-10 17:49:19.33944
1000	sensor_cilantro_2	21.68	64.00	61.24	1.64	6.79	848.58	460.39	2025-11-10 17:49:19.339496
1001	sensor_rabano_1	20.41	69.16	78.44	1.99	6.61	991.21	463.93	2025-11-10 17:49:29.34791
1002	sensor_rabano_2	23.77	58.43	75.02	1.93	6.66	897.45	422.38	2025-11-10 17:49:29.348388
1003	sensor_cilantro_1	22.41	66.85	67.11	1.65	6.52	1187.03	417.99	2025-11-10 17:49:29.348467
1004	sensor_cilantro_2	20.18	69.12	72.36	1.64	6.69	1123.50	407.28	2025-11-10 17:49:29.348524
1005	sensor_rabano_1	22.38	67.15	75.65	2.00	6.71	959.29	408.73	2025-11-10 17:49:39.359337
1006	sensor_rabano_2	22.82	68.88	68.16	1.94	6.59	836.03	457.80	2025-11-10 17:49:39.360054
1007	sensor_cilantro_1	22.65	64.60	70.38	1.96	6.76	960.64	465.69	2025-11-10 17:49:39.360223
1008	sensor_cilantro_2	22.22	62.21	68.00	1.97	6.49	907.94	425.64	2025-11-10 17:49:39.360359
1009	sensor_rabano_1	20.49	71.16	77.50	1.72	6.78	810.88	431.54	2025-11-10 17:49:49.369578
1010	sensor_rabano_2	23.86	63.05	65.22	1.55	6.64	808.50	459.01	2025-11-10 17:49:49.370019
1011	sensor_cilantro_1	19.97	70.99	67.34	1.88	6.76	1088.92	491.18	2025-11-10 17:49:49.370097
1012	sensor_cilantro_2	22.92	65.23	77.55	1.86	6.56	1089.99	430.38	2025-11-10 17:49:49.370151
1013	sensor_rabano_1	21.08	70.14	62.25	1.47	6.67	840.33	422.45	2025-11-10 17:49:59.381481
1014	sensor_rabano_2	20.99	68.79	65.93	1.51	6.45	1124.19	432.79	2025-11-10 17:49:59.38236
1015	sensor_cilantro_1	21.85	69.83	61.69	1.48	6.49	828.01	405.34	2025-11-10 17:49:59.38256
1016	sensor_cilantro_2	21.22	74.62	70.35	1.61	6.79	980.83	426.79	2025-11-10 17:49:59.382706
1017	sensor_rabano_1	23.41	60.53	62.25	1.42	6.58	927.19	411.68	2025-11-10 17:50:09.393034
1018	sensor_rabano_2	22.03	64.50	75.75	1.87	6.76	1124.03	440.01	2025-11-10 17:50:09.393825
1019	sensor_cilantro_1	19.40	71.59	65.95	1.49	6.46	1101.89	439.58	2025-11-10 17:50:09.394083
1020	sensor_cilantro_2	20.65	74.35	70.91	1.82	6.56	1018.80	462.15	2025-11-10 17:50:09.394245
1021	sensor_rabano_1	20.47	69.04	67.02	1.99	6.65	886.36	454.09	2025-11-10 17:50:19.404882
1022	sensor_rabano_2	21.85	71.39	77.95	1.92	6.58	1154.08	433.70	2025-11-10 17:50:19.405603
1023	sensor_cilantro_1	21.01	63.50	77.91	1.96	6.48	825.21	440.88	2025-11-10 17:50:19.405781
1024	sensor_cilantro_2	19.62	71.16	79.77	1.60	6.63	1029.86	416.51	2025-11-10 17:50:19.405852
1025	sensor_rabano_1	20.65	71.31	66.15	1.68	6.64	845.61	402.52	2025-11-10 17:50:29.417543
1026	sensor_rabano_2	22.74	66.49	74.05	1.47	6.68	1180.69	492.76	2025-11-10 17:50:29.418071
1027	sensor_cilantro_1	20.63	73.87	71.10	1.64	6.62	1005.73	423.33	2025-11-10 17:50:29.418156
1028	sensor_cilantro_2	19.63	66.61	72.93	1.67	6.64	965.24	438.95	2025-11-10 17:50:29.418214
1029	sensor_rabano_1	20.89	71.96	78.81	1.61	6.71	1062.00	433.14	2025-11-10 17:50:39.429587
1030	sensor_rabano_2	21.31	69.44	62.44	1.80	6.56	916.53	446.90	2025-11-10 17:50:39.430417
1031	sensor_cilantro_1	19.71	75.06	69.29	1.78	6.45	982.77	422.01	2025-11-10 17:50:39.430604
1032	sensor_cilantro_2	20.11	72.34	69.77	1.89	6.77	1185.75	465.44	2025-11-10 17:50:39.430746
1033	sensor_rabano_1	22.47	60.94	78.34	1.54	6.43	1139.33	403.88	2025-11-10 17:50:49.439872
1034	sensor_rabano_2	22.36	61.10	63.20	1.95	6.59	945.66	473.79	2025-11-10 17:50:49.440388
1035	sensor_cilantro_1	21.45	67.94	79.38	1.87	6.77	1051.46	441.38	2025-11-10 17:50:49.440471
1036	sensor_cilantro_2	21.50	68.68	64.12	1.56	6.47	949.66	434.09	2025-11-10 17:50:49.44053
1037	sensor_rabano_1	21.48	61.66	76.25	1.45	6.46	968.80	409.24	2025-11-10 17:50:59.4483
1038	sensor_rabano_2	20.58	59.40	62.10	1.50	6.62	884.00	460.47	2025-11-10 17:50:59.448909
1039	sensor_cilantro_1	20.63	66.07	65.10	1.52	6.71	976.42	463.35	2025-11-10 17:50:59.449313
1040	sensor_cilantro_2	21.97	70.14	68.30	1.56	6.42	879.69	453.38	2025-11-10 17:50:59.449603
1041	sensor_rabano_1	20.23	63.20	60.61	1.98	6.62	981.28	433.86	2025-11-10 17:51:09.461984
1042	sensor_rabano_2	20.03	59.66	76.53	1.58	6.67	819.15	475.75	2025-11-10 17:51:09.462929
1043	sensor_cilantro_1	22.19	65.46	75.92	1.94	6.60	961.77	495.89	2025-11-10 17:51:09.463271
1044	sensor_cilantro_2	22.19	62.86	77.34	1.58	6.60	919.40	499.38	2025-11-10 17:51:09.46351
1045	sensor_rabano_1	23.69	72.72	69.33	1.44	6.76	1161.26	447.06	2025-11-10 17:51:19.474957
1046	sensor_rabano_2	23.58	59.45	63.76	1.47	6.55	1038.93	467.18	2025-11-10 17:51:19.475673
1047	sensor_cilantro_1	19.22	68.32	79.57	1.81	6.58	807.79	477.63	2025-11-10 17:51:19.475859
1048	sensor_cilantro_2	22.78	76.27	77.03	1.58	6.80	947.27	455.21	2025-11-10 17:51:19.476012
1049	sensor_rabano_1	23.81	61.67	76.19	1.44	6.72	1020.83	457.21	2025-11-10 17:51:29.487675
1050	sensor_rabano_2	20.10	72.75	73.24	1.53	6.76	1024.90	479.00	2025-11-10 17:51:29.488674
1051	sensor_cilantro_1	20.88	70.72	71.60	1.69	6.44	1068.95	446.23	2025-11-10 17:51:29.488955
1052	sensor_cilantro_2	20.62	66.99	67.12	1.88	6.76	827.67	469.99	2025-11-10 17:51:29.489227
1053	sensor_rabano_1	21.44	58.14	77.06	1.60	6.54	987.81	423.48	2025-11-10 17:51:39.509079
1054	sensor_rabano_2	22.09	67.62	70.80	1.52	6.44	1174.05	458.58	2025-11-10 17:51:39.509689
1055	sensor_cilantro_1	20.00	65.03	62.63	1.88	6.68	1032.22	471.13	2025-11-10 17:51:39.509774
1056	sensor_cilantro_2	19.41	75.80	75.66	1.93	6.79	1010.44	489.47	2025-11-10 17:51:39.509831
1057	sensor_rabano_1	20.83	60.88	68.57	1.43	6.65	1078.06	442.84	2025-11-10 17:51:49.519968
1058	sensor_rabano_2	23.49	72.86	64.87	2.00	6.55	1155.37	491.42	2025-11-10 17:51:49.520984
1059	sensor_cilantro_1	22.00	63.07	71.66	1.86	6.77	1029.30	491.49	2025-11-10 17:51:49.521225
1060	sensor_cilantro_2	21.37	75.73	61.63	1.54	6.57	1114.81	439.15	2025-11-10 17:51:49.521397
1061	sensor_rabano_1	20.94	64.47	67.98	1.65	6.65	866.34	440.15	2025-11-10 17:51:59.530797
1062	sensor_rabano_2	22.17	70.09	68.47	1.88	6.64	839.50	441.32	2025-11-10 17:51:59.531459
1063	sensor_cilantro_1	20.89	76.79	69.67	1.46	6.40	832.88	497.00	2025-11-10 17:51:59.531564
1064	sensor_cilantro_2	21.80	70.09	78.50	1.61	6.48	1010.98	425.72	2025-11-10 17:51:59.531624
1065	sensor_rabano_1	23.59	73.00	70.81	1.67	6.63	1028.88	472.49	2025-11-10 17:52:09.541812
1066	sensor_rabano_2	22.75	60.66	62.10	1.95	6.55	858.15	401.02	2025-11-10 17:52:09.542597
1067	sensor_cilantro_1	19.88	68.97	64.23	1.97	6.57	1118.20	484.07	2025-11-10 17:52:09.5427
1068	sensor_cilantro_2	20.75	62.39	73.19	1.55	6.48	1178.95	471.35	2025-11-10 17:52:09.542759
1069	sensor_rabano_1	20.13	59.88	69.84	1.61	6.52	1084.33	413.26	2025-11-10 17:52:19.551816
1070	sensor_rabano_2	21.85	66.32	73.74	1.75	6.75	1058.44	490.31	2025-11-10 17:52:19.55263
1071	sensor_cilantro_1	19.96	73.93	77.38	1.71	6.78	953.48	419.86	2025-11-10 17:52:19.552814
1072	sensor_cilantro_2	21.92	62.54	67.20	2.00	6.62	876.25	491.15	2025-11-10 17:52:19.552969
1073	sensor_rabano_1	22.52	68.32	67.40	1.85	6.51	801.10	411.56	2025-11-10 17:52:29.56205
1074	sensor_rabano_2	23.34	60.68	68.74	1.54	6.56	1189.35	427.71	2025-11-10 17:52:29.562881
1075	sensor_cilantro_1	21.50	71.20	65.42	1.55	6.52	852.19	458.45	2025-11-10 17:52:29.563176
1076	sensor_cilantro_2	21.65	70.13	76.29	1.49	6.57	903.22	497.57	2025-11-10 17:52:29.563413
1077	sensor_rabano_1	22.19	63.19	73.91	1.73	6.56	1138.11	403.50	2025-11-10 17:52:39.574608
1078	sensor_rabano_2	21.28	65.24	67.06	1.65	6.75	1056.11	445.58	2025-11-10 17:52:39.575542
1079	sensor_cilantro_1	22.83	66.65	79.70	1.62	6.50	1195.62	454.28	2025-11-10 17:52:39.575713
1080	sensor_cilantro_2	21.28	63.03	76.48	1.85	6.79	1085.52	400.12	2025-11-10 17:52:39.575779
1081	sensor_rabano_1	22.36	59.06	77.05	1.52	6.57	1030.63	476.42	2025-11-10 17:53:02.360067
1082	sensor_rabano_2	23.85	69.29	74.06	1.63	6.71	811.90	424.96	2025-11-10 17:53:02.360877
1083	sensor_cilantro_1	22.49	64.31	64.30	1.71	6.70	888.17	465.06	2025-11-10 17:53:02.361068
1084	sensor_cilantro_2	20.63	76.96	63.75	1.78	6.50	1004.91	404.67	2025-11-10 17:53:02.361221
1085	sensor_rabano_1	23.83	60.67	61.32	1.76	6.63	1170.34	410.05	2025-11-10 17:53:12.371628
1086	sensor_rabano_2	20.31	62.80	72.34	1.98	6.58	1180.53	462.16	2025-11-10 17:53:12.372268
1087	sensor_cilantro_1	19.81	70.88	75.16	1.84	6.68	1033.82	439.05	2025-11-10 17:53:12.372505
1088	sensor_cilantro_2	20.28	75.49	69.45	1.65	6.52	813.22	455.00	2025-11-10 17:53:12.372686
1089	sensor_rabano_1	21.86	65.94	60.79	1.46	6.51	1129.19	433.18	2025-11-10 17:53:22.381371
1090	sensor_rabano_2	20.27	61.89	74.91	1.81	6.75	825.70	498.63	2025-11-10 17:53:22.381859
1091	sensor_cilantro_1	21.57	77.98	64.80	1.86	6.72	984.99	475.78	2025-11-10 17:53:22.381939
1092	sensor_cilantro_2	19.12	65.49	68.34	1.75	6.47	911.45	453.13	2025-11-10 17:53:22.381994
1093	sensor_rabano_1	20.58	64.24	66.61	1.87	6.43	965.62	459.98	2025-12-05 17:24:18.259105
1094	sensor_rabano_2	22.36	69.40	68.58	1.82	6.56	1100.03	472.94	2025-12-05 17:24:18.265644
1095	sensor_cilantro_1	21.23	77.71	72.11	1.41	6.59	844.00	457.24	2025-12-05 17:24:18.265892
1096	sensor_cilantro_2	20.80	72.74	69.58	1.92	6.49	831.75	422.91	2025-12-05 17:24:18.266047
1097	sensor_rabano_1	21.02	71.88	74.22	1.93	6.73	809.22	491.15	2025-12-05 17:24:28.275886
1098	sensor_rabano_2	20.15	64.67	69.13	1.64	6.79	1127.81	483.95	2025-12-05 17:24:28.276678
1099	sensor_cilantro_1	19.51	71.24	65.41	1.75	6.80	898.13	456.15	2025-12-05 17:24:28.276865
1100	sensor_cilantro_2	19.69	62.64	76.46	1.96	6.52	1187.35	430.68	2025-12-05 17:24:28.277009
1101	sensor_rabano_1	23.67	61.97	62.37	1.86	6.72	1081.96	416.42	2025-12-05 17:24:38.288488
1102	sensor_rabano_2	20.26	59.59	74.50	1.40	6.76	1109.20	403.14	2025-12-05 17:24:38.289329
1103	sensor_cilantro_1	20.19	63.37	64.80	1.81	6.72	1089.07	449.15	2025-12-05 17:24:38.289513
1104	sensor_cilantro_2	21.72	71.41	73.26	1.51	6.43	932.82	439.65	2025-12-05 17:24:38.289657
1105	sensor_rabano_1	21.38	70.52	77.15	1.63	6.69	959.87	436.70	2025-12-05 17:24:48.300535
1106	sensor_rabano_2	21.10	69.06	71.76	1.45	6.55	1096.54	416.39	2025-12-05 17:24:48.301278
1107	sensor_cilantro_1	21.78	70.01	65.72	1.94	6.69	1142.02	426.38	2025-12-05 17:24:48.301385
1108	sensor_cilantro_2	20.21	67.47	78.94	1.92	6.44	1048.01	413.87	2025-12-05 17:24:48.30145
1109	sensor_rabano_1	22.57	71.84	78.30	1.67	6.44	1186.80	451.05	2025-12-05 17:24:58.310336
1110	sensor_rabano_2	22.06	63.39	68.63	1.46	6.57	892.37	442.33	2025-12-05 17:24:58.310976
1111	sensor_cilantro_1	20.34	71.94	67.39	1.52	6.42	1186.90	499.04	2025-12-05 17:24:58.311081
1112	sensor_cilantro_2	20.46	67.52	63.20	1.97	6.54	1038.49	448.94	2025-12-05 17:24:58.311144
1113	sensor_rabano_1	23.84	59.26	65.69	1.51	6.78	1185.85	424.54	2025-12-05 17:25:08.322195
1114	sensor_rabano_2	20.94	69.20	75.66	1.61	6.51	957.28	453.84	2025-12-05 17:25:08.322973
1115	sensor_cilantro_1	20.36	65.56	75.06	1.78	6.68	1143.30	448.79	2025-12-05 17:25:08.323172
1116	sensor_cilantro_2	21.89	65.89	74.94	1.42	6.60	802.36	445.76	2025-12-05 17:25:08.323325
1117	sensor_rabano_1	22.07	63.64	61.67	1.68	6.68	832.59	418.43	2025-12-05 17:25:18.332833
1118	sensor_rabano_2	23.41	70.04	76.90	1.56	6.80	1005.26	459.63	2025-12-05 17:25:18.333555
1119	sensor_cilantro_1	22.02	72.68	63.71	1.64	6.56	1140.92	440.28	2025-12-05 17:25:18.333732
1120	sensor_cilantro_2	19.12	74.21	74.61	1.70	6.53	1098.24	498.00	2025-12-05 17:25:18.333871
1121	sensor_rabano_1	23.51	64.95	70.48	1.92	6.54	1113.71	415.70	2025-12-05 17:25:20.869289
1122	sensor_rabano_2	23.67	64.90	67.64	1.91	6.59	1178.38	457.28	2025-12-05 17:25:20.870422
1123	sensor_cilantro_1	21.00	75.30	79.21	1.88	6.51	880.64	488.29	2025-12-05 17:25:20.870877
1124	sensor_cilantro_2	20.45	74.89	75.67	1.60	6.78	837.87	420.28	2025-12-05 17:25:20.871444
1125	sensor_rabano_1	20.74	63.99	67.22	1.93	6.65	836.97	494.43	2025-12-05 17:25:28.3459
1126	sensor_rabano_2	21.74	70.84	73.93	1.94	6.53	879.39	428.45	2025-12-05 17:25:28.346677
1127	sensor_cilantro_1	21.81	66.32	78.64	1.58	6.61	1053.30	480.40	2025-12-05 17:25:28.348677
1128	sensor_cilantro_2	22.64	74.42	79.53	1.46	6.49	928.34	485.26	2025-12-05 17:25:28.348906
1129	sensor_rabano_1	21.31	67.00	75.69	1.92	6.44	810.88	456.44	2025-12-05 17:25:38.359175
1130	sensor_rabano_2	23.71	60.03	65.07	1.68	6.47	920.94	434.06	2025-12-05 17:25:38.360014
1131	sensor_cilantro_1	21.15	72.02	76.09	1.64	6.66	806.56	497.29	2025-12-05 17:25:38.360266
1132	sensor_cilantro_2	21.45	68.47	64.76	1.91	6.70	1101.35	435.86	2025-12-05 17:25:38.360481
1133	sensor_rabano_1	23.71	58.99	67.38	2.00	6.50	1115.21	441.83	2025-12-05 17:25:48.372088
1134	sensor_rabano_2	21.17	66.51	78.40	1.98	6.57	806.13	459.32	2025-12-05 17:25:48.372882
1135	sensor_cilantro_1	22.05	66.76	76.46	1.60	6.57	1071.28	421.46	2025-12-05 17:25:48.373055
1136	sensor_cilantro_2	22.59	71.70	61.90	1.40	6.40	1048.76	450.90	2025-12-05 17:25:48.373269
1137	sensor_rabano_1	21.58	70.27	61.66	1.81	6.76	1141.14	474.81	2025-12-05 17:25:58.385157
1138	sensor_rabano_2	21.17	61.30	78.67	1.86	6.42	889.05	425.15	2025-12-05 17:25:58.386001
1139	sensor_cilantro_1	20.20	73.34	76.76	1.50	6.64	1021.95	446.63	2025-12-05 17:25:58.386198
1140	sensor_cilantro_2	20.52	74.42	64.45	1.92	6.64	966.14	481.89	2025-12-05 17:25:58.386812
1141	sensor_rabano_1	21.04	61.48	78.99	1.90	6.60	1050.15	459.24	2025-12-05 17:26:08.399582
1142	sensor_rabano_2	22.20	57.56	64.97	1.86	6.59	1091.35	482.37	2025-12-05 17:26:08.40036
1143	sensor_cilantro_1	22.08	72.97	61.06	1.95	6.63	1068.29	491.40	2025-12-05 17:26:08.400549
1144	sensor_cilantro_2	19.20	62.42	76.17	2.00	6.58	964.54	487.08	2025-12-05 17:26:08.400694
1145	sensor_rabano_1	20.05	63.11	68.98	1.90	6.51	932.65	485.43	2025-12-05 17:28:30.478541
1146	sensor_rabano_2	20.86	62.08	76.88	1.59	6.74	1173.17	423.10	2025-12-05 17:28:30.487479
1147	sensor_cilantro_1	21.46	71.52	60.49	1.93	6.55	956.36	411.00	2025-12-05 17:28:30.487889
1148	sensor_cilantro_2	19.39	68.71	68.41	1.62	6.61	851.60	436.90	2025-12-05 17:28:30.488271
1149	sensor_rabano_1	21.35	70.91	65.00	1.65	6.75	1128.54	476.73	2025-12-05 17:28:40.499633
1150	sensor_rabano_2	23.12	61.00	60.22	1.79	6.77	889.63	463.00	2025-12-05 17:28:40.500124
1151	sensor_cilantro_1	22.49	69.23	76.27	1.98	6.78	1120.59	487.50	2025-12-05 17:28:40.500215
1152	sensor_cilantro_2	19.71	75.86	65.93	1.52	6.46	1122.20	453.57	2025-12-05 17:28:40.500276
1153	sensor_rabano_1	21.10	69.14	60.69	1.61	6.56	1098.81	476.97	2025-12-05 17:28:50.510086
1154	sensor_rabano_2	20.04	61.09	63.78	1.42	6.62	1101.36	476.87	2025-12-05 17:28:50.510759
1155	sensor_cilantro_1	19.56	74.39	72.64	1.65	6.56	850.39	433.69	2025-12-05 17:28:50.510878
1156	sensor_cilantro_2	19.64	67.53	67.91	1.72	6.69	1077.95	479.12	2025-12-05 17:28:50.510937
1157	sensor_rabano_1	23.83	69.64	68.83	1.47	6.75	1047.58	467.59	2025-12-05 17:29:00.520963
1158	sensor_rabano_2	23.68	62.07	61.12	1.45	6.43	934.46	400.22	2025-12-05 17:29:00.521804
1159	sensor_cilantro_1	22.95	69.88	78.04	1.91	6.50	991.92	499.01	2025-12-05 17:29:00.521984
1160	sensor_cilantro_2	22.72	64.96	76.95	1.77	6.67	949.66	434.52	2025-12-05 17:29:00.52215
1161	sensor_rabano_1	23.81	64.70	60.47	1.42	6.71	1106.24	437.61	2025-12-05 17:29:10.530886
1162	sensor_rabano_2	22.96	57.62	61.82	1.43	6.79	1108.19	424.71	2025-12-05 17:29:10.53141
1163	sensor_cilantro_1	22.52	72.44	67.51	1.45	6.70	1012.28	481.85	2025-12-05 17:29:10.531496
1164	sensor_cilantro_2	22.41	76.46	75.98	1.41	6.44	1071.87	438.45	2025-12-05 17:29:10.531554
1165	sensor_rabano_1	22.54	72.97	70.70	1.75	6.44	1121.69	444.86	2025-12-05 17:29:20.542479
1166	sensor_rabano_2	20.99	67.64	60.14	1.62	6.58	804.94	427.69	2025-12-05 17:29:20.543032
1167	sensor_cilantro_1	21.23	70.74	72.67	1.71	6.61	883.79	485.79	2025-12-05 17:29:20.543206
1168	sensor_cilantro_2	21.36	75.33	60.72	1.71	6.43	1199.29	478.15	2025-12-05 17:29:20.543376
1169	sensor_rabano_1	22.27	61.50	70.35	1.49	6.53	1098.62	442.62	2025-12-05 17:29:30.554551
1170	sensor_rabano_2	21.51	65.09	65.82	1.78	6.48	1156.16	426.68	2025-12-05 17:29:30.555415
1171	sensor_cilantro_1	21.46	74.59	70.23	1.78	6.40	1022.28	497.32	2025-12-05 17:29:30.555695
1172	sensor_cilantro_2	19.23	73.43	71.79	1.64	6.73	995.15	460.00	2025-12-05 17:29:30.555848
1173	sensor_rabano_1	23.63	63.55	60.74	1.47	6.51	876.43	479.60	2025-12-05 17:29:40.567598
1174	sensor_rabano_2	21.22	61.21	63.04	1.65	6.77	996.85	422.04	2025-12-05 17:29:40.568181
1175	sensor_cilantro_1	19.46	69.22	72.47	1.51	6.68	1038.43	497.27	2025-12-05 17:29:40.568359
1176	sensor_cilantro_2	21.28	77.51	69.69	1.49	6.58	917.83	471.17	2025-12-05 17:29:40.568533
1177	sensor_rabano_1	23.77	62.32	61.81	1.75	6.44	830.65	412.87	2025-12-05 17:29:50.579912
1178	sensor_rabano_2	21.94	71.73	79.61	1.43	6.71	1142.86	445.59	2025-12-05 17:29:50.580809
1179	sensor_cilantro_1	21.58	73.39	65.08	1.61	6.47	882.55	472.62	2025-12-05 17:29:50.581095
1180	sensor_cilantro_2	20.56	63.58	69.48	1.86	6.48	1104.61	468.94	2025-12-05 17:29:50.581351
1181	sensor_rabano_1	20.65	69.97	68.06	1.96	6.61	866.65	403.34	2025-12-05 17:30:00.592866
1182	sensor_rabano_2	21.83	58.07	61.71	1.91	6.65	944.65	490.01	2025-12-05 17:30:00.593751
1183	sensor_cilantro_1	19.47	69.05	74.06	1.86	6.79	855.41	490.87	2025-12-05 17:30:00.594014
1184	sensor_cilantro_2	20.39	66.25	66.47	1.64	6.44	844.29	462.09	2025-12-05 17:30:00.594249
1185	sensor_rabano_1	21.60	58.41	69.16	1.84	6.71	1149.71	495.12	2025-12-05 17:30:10.604465
1186	sensor_rabano_2	20.89	66.49	63.90	1.85	6.76	1102.01	412.98	2025-12-05 17:30:10.605192
1187	sensor_cilantro_1	22.55	72.49	62.26	1.44	6.77	1055.72	449.78	2025-12-05 17:30:10.605453
1188	sensor_cilantro_2	20.29	73.00	67.84	1.44	6.73	983.09	409.32	2025-12-05 17:30:10.605615
1189	sensor_rabano_1	22.31	69.30	73.40	1.67	6.50	1070.89	414.99	2025-12-05 17:30:20.617371
1190	sensor_rabano_2	20.23	67.24	68.16	1.91	6.46	1087.84	436.01	2025-12-05 17:30:20.618338
1191	sensor_cilantro_1	22.71	75.86	76.95	1.65	6.79	1179.56	413.64	2025-12-05 17:30:20.618667
1192	sensor_cilantro_2	19.83	64.97	75.92	1.88	6.47	865.17	422.64	2025-12-05 17:30:20.618878
1193	sensor_rabano_1	23.18	67.78	70.48	1.95	6.71	869.99	465.34	2025-12-05 17:30:30.63083
1194	sensor_rabano_2	23.67	69.67	60.34	1.92	6.53	812.78	448.14	2025-12-05 17:30:30.631611
1195	sensor_cilantro_1	21.97	68.60	66.55	1.98	6.69	1059.70	487.34	2025-12-05 17:30:30.631788
1196	sensor_cilantro_2	19.28	68.21	78.64	1.62	6.63	982.87	457.34	2025-12-05 17:30:30.631926
1197	sensor_rabano_1	22.63	59.21	66.36	1.59	6.45	1049.62	479.58	2025-12-05 17:30:40.642723
1198	sensor_rabano_2	21.86	67.22	61.93	1.50	6.51	1109.23	407.31	2025-12-05 17:30:40.643218
1199	sensor_cilantro_1	20.30	66.88	62.66	1.73	6.53	929.86	487.10	2025-12-05 17:30:40.643384
1200	sensor_cilantro_2	21.71	62.04	74.88	1.47	6.45	1052.91	488.28	2025-12-05 17:30:40.643447
1201	sensor_rabano_1	20.66	62.80	74.15	1.50	6.46	1028.84	402.07	2025-12-05 17:30:50.65112
1202	sensor_rabano_2	23.78	57.47	66.81	1.41	6.71	993.87	466.09	2025-12-05 17:30:50.652159
1203	sensor_cilantro_1	21.64	63.58	67.83	1.70	6.63	1093.03	483.16	2025-12-05 17:30:50.65225
1204	sensor_cilantro_2	20.94	74.53	61.44	1.60	6.70	1036.54	450.60	2025-12-05 17:30:50.652308
1205	sensor_rabano_1	20.39	68.88	60.33	1.93	6.59	951.60	496.57	2025-12-05 17:31:00.661941
1206	sensor_rabano_2	21.78	71.25	70.66	1.96	6.64	1041.88	467.56	2025-12-05 17:31:00.662761
1207	sensor_cilantro_1	19.10	64.97	73.53	1.60	6.41	983.98	481.53	2025-12-05 17:31:00.662943
1208	sensor_cilantro_2	22.93	74.74	66.58	1.60	6.55	1095.83	440.55	2025-12-05 17:31:00.663107
1209	sensor_rabano_1	22.45	59.04	66.48	1.43	6.56	930.57	441.33	2025-12-05 17:31:10.674645
1210	sensor_rabano_2	23.82	57.97	69.79	1.63	6.42	984.27	469.17	2025-12-05 17:31:10.675454
1211	sensor_cilantro_1	22.60	64.63	66.08	1.78	6.51	881.96	427.02	2025-12-05 17:31:10.67571
1212	sensor_cilantro_2	22.95	65.96	71.04	1.92	6.65	1046.00	458.99	2025-12-05 17:31:10.675905
1213	sensor_rabano_1	21.78	72.23	69.45	1.59	6.77	869.09	479.76	2025-12-05 17:31:20.686423
1214	sensor_rabano_2	20.49	65.82	66.60	1.54	6.65	825.79	491.36	2025-12-05 17:31:20.687301
1215	sensor_cilantro_1	21.95	74.11	68.81	1.50	6.79	844.28	462.93	2025-12-05 17:31:20.687564
1216	sensor_cilantro_2	19.08	75.44	64.63	1.83	6.76	1126.09	425.01	2025-12-05 17:31:20.687797
1217	sensor_rabano_1	20.29	62.10	64.66	1.61	6.73	1197.80	477.18	2025-12-05 17:31:30.699627
1218	sensor_rabano_2	20.21	71.04	63.94	1.68	6.53	1135.60	476.87	2025-12-05 17:31:30.700606
1219	sensor_cilantro_1	21.31	67.82	67.40	1.86	6.72	801.19	490.26	2025-12-05 17:31:30.70084
1220	sensor_cilantro_2	20.37	71.39	63.92	1.85	6.59	881.18	429.32	2025-12-05 17:31:30.701011
1221	sensor_rabano_1	20.97	71.30	70.64	1.57	6.42	800.80	464.65	2025-12-05 17:31:40.711338
1222	sensor_rabano_2	21.33	67.89	75.86	1.68	6.63	824.20	492.09	2025-12-05 17:31:40.71218
1223	sensor_cilantro_1	22.01	65.92	67.65	1.58	6.47	993.98	477.73	2025-12-05 17:31:40.712365
1224	sensor_cilantro_2	22.51	72.56	73.54	1.63	6.71	853.32	425.28	2025-12-05 17:31:40.712509
1225	sensor_rabano_1	23.65	72.72	64.50	1.77	6.79	820.66	480.20	2025-12-05 17:31:50.721481
1226	sensor_rabano_2	22.80	61.03	72.68	1.67	6.41	962.78	479.48	2025-12-05 17:31:50.722044
1227	sensor_cilantro_1	21.32	76.02	69.15	1.63	6.53	1163.10	495.48	2025-12-05 17:31:50.722176
1228	sensor_cilantro_2	20.94	68.90	61.09	1.69	6.61	944.25	469.96	2025-12-05 17:31:50.722276
1229	sensor_rabano_1	20.73	63.31	65.96	1.76	6.79	1095.50	429.04	2025-12-05 17:32:00.730094
1230	sensor_rabano_2	22.07	64.09	78.21	1.42	6.63	944.24	490.32	2025-12-05 17:32:00.730647
1231	sensor_cilantro_1	21.66	72.00	75.34	1.43	6.57	1050.85	430.37	2025-12-05 17:32:00.73077
1232	sensor_cilantro_2	20.46	62.14	69.29	1.68	6.59	896.31	407.09	2025-12-05 17:32:00.730857
1233	sensor_rabano_1	20.69	61.12	69.40	1.74	6.45	1135.49	441.54	2025-12-05 17:32:10.738817
1234	sensor_rabano_2	21.19	71.95	73.18	1.77	6.66	846.93	468.71	2025-12-05 17:32:10.739305
1235	sensor_cilantro_1	22.48	73.80	70.48	1.50	6.48	1181.00	467.13	2025-12-05 17:32:10.739409
1236	sensor_cilantro_2	22.87	68.37	65.34	1.72	6.40	1010.66	431.74	2025-12-05 17:32:10.739484
1237	sensor_rabano_1	20.81	62.76	78.47	1.58	6.51	833.58	489.81	2025-12-05 17:32:20.751118
1238	sensor_rabano_2	23.80	64.21	60.49	1.71	6.53	1107.12	443.05	2025-12-05 17:32:20.75207
1239	sensor_cilantro_1	19.17	73.88	64.05	1.48	6.55	832.92	439.52	2025-12-05 17:32:20.752162
1240	sensor_cilantro_2	20.90	77.61	76.57	1.57	6.76	1050.19	404.21	2025-12-05 17:32:20.75222
1241	sensor_rabano_1	23.39	67.87	64.18	1.64	6.67	952.26	475.79	2025-12-05 17:32:30.763879
1242	sensor_rabano_2	22.59	62.74	61.12	1.76	6.52	1056.76	426.74	2025-12-05 17:32:30.76507
1243	sensor_cilantro_1	19.24	75.23	67.15	1.50	6.62	861.36	400.99	2025-12-05 17:32:30.765352
1244	sensor_cilantro_2	19.23	65.50	60.75	1.81	6.75	1141.42	493.72	2025-12-05 17:32:30.765552
1245	sensor_rabano_1	23.07	68.20	64.44	1.62	6.53	992.13	448.40	2025-12-05 17:32:40.776928
1246	sensor_rabano_2	22.94	67.96	79.43	1.81	6.74	1055.46	419.21	2025-12-05 17:32:40.777723
1247	sensor_cilantro_1	20.12	71.10	79.51	1.44	6.50	819.80	414.63	2025-12-05 17:32:40.777899
1248	sensor_cilantro_2	21.82	72.67	64.97	1.55	6.72	914.58	445.13	2025-12-05 17:32:40.778073
1249	sensor_rabano_1	20.45	59.62	74.21	1.44	6.68	1177.51	494.94	2025-12-05 17:32:50.78834
1250	sensor_rabano_2	23.40	66.49	64.13	1.67	6.76	912.92	402.65	2025-12-05 17:32:50.789192
1251	sensor_cilantro_1	19.95	62.82	76.59	1.58	6.51	1101.36	426.93	2025-12-05 17:32:50.789378
1252	sensor_cilantro_2	21.14	73.22	79.11	1.92	6.78	1022.47	465.60	2025-12-05 17:32:50.789521
1253	sensor_rabano_1	22.66	70.23	60.25	1.57	6.47	853.92	426.08	2025-12-05 17:33:00.801196
1254	sensor_rabano_2	21.99	67.95	79.59	1.93	6.80	1190.76	452.18	2025-12-05 17:33:00.801965
1255	sensor_cilantro_1	21.97	72.84	67.84	1.57	6.44	971.30	456.33	2025-12-05 17:33:00.80217
1256	sensor_cilantro_2	19.16	73.04	65.70	1.44	6.42	1088.07	487.91	2025-12-05 17:33:00.802319
1257	sensor_rabano_1	21.39	58.21	79.91	1.74	6.58	1191.85	416.76	2025-12-05 17:33:10.814318
1258	sensor_rabano_2	23.99	67.18	78.89	1.95	6.72	886.24	451.57	2025-12-05 17:33:10.815102
1259	sensor_cilantro_1	21.81	77.37	70.30	1.97	6.71	1008.96	424.74	2025-12-05 17:33:10.815329
1260	sensor_cilantro_2	22.84	65.59	63.38	1.78	6.75	821.78	414.27	2025-12-05 17:33:10.815487
1261	sensor_rabano_1	23.25	66.07	67.85	1.47	6.71	958.84	430.69	2025-12-05 17:33:20.825989
1262	sensor_rabano_2	23.89	59.58	79.23	1.94	6.57	1129.77	478.71	2025-12-05 17:33:20.826829
1263	sensor_cilantro_1	19.00	62.29	62.07	1.51	6.63	854.41	476.15	2025-12-05 17:33:20.826937
1264	sensor_cilantro_2	21.24	73.79	73.90	1.87	6.44	830.12	417.31	2025-12-05 17:33:20.827099
1265	sensor_rabano_1	21.80	60.26	74.92	1.97	6.57	852.33	452.01	2025-12-05 17:33:30.835922
1266	sensor_rabano_2	22.51	67.68	79.80	1.55	6.73	1187.70	471.57	2025-12-05 17:33:30.836402
1267	sensor_cilantro_1	22.44	63.34	60.79	1.52	6.51	813.02	416.63	2025-12-05 17:33:30.836494
1268	sensor_cilantro_2	21.04	68.05	65.90	1.78	6.68	898.99	447.55	2025-12-05 17:33:30.836553
1269	sensor_rabano_1	20.24	67.15	74.54	1.97	6.45	851.60	421.73	2025-12-05 17:33:40.856429
1270	sensor_rabano_2	22.71	66.02	61.38	1.76	6.68	899.56	431.79	2025-12-05 17:33:40.857218
1271	sensor_cilantro_1	23.00	74.45	69.92	1.62	6.53	1102.34	448.20	2025-12-05 17:33:40.857395
1272	sensor_cilantro_2	22.20	67.05	75.94	1.64	6.55	808.31	406.85	2025-12-05 17:33:40.857534
1273	sensor_rabano_1	21.67	70.48	62.96	1.52	6.45	955.65	425.88	2025-12-05 17:33:50.866302
1274	sensor_rabano_2	21.00	61.30	69.47	1.45	6.60	822.46	421.57	2025-12-05 17:33:50.866921
1275	sensor_cilantro_1	19.92	64.73	69.21	1.53	6.56	944.37	498.60	2025-12-05 17:33:50.867082
1276	sensor_cilantro_2	19.62	66.81	74.18	1.95	6.47	944.24	453.16	2025-12-05 17:33:50.867163
1277	sensor_rabano_1	20.90	63.33	75.84	1.68	6.70	1015.03	444.82	2025-12-05 17:34:00.878593
1278	sensor_rabano_2	21.76	72.47	66.73	1.44	6.69	903.33	436.38	2025-12-05 17:34:00.879539
1279	sensor_cilantro_1	22.25	69.53	64.89	1.55	6.47	991.08	473.52	2025-12-05 17:34:00.879839
1280	sensor_cilantro_2	20.18	73.65	78.03	1.75	6.50	1170.76	434.54	2025-12-05 17:34:00.880002
1281	sensor_rabano_1	22.53	69.62	64.06	1.52	6.67	1149.11	428.74	2025-12-05 17:34:10.890641
1282	sensor_rabano_2	22.53	59.59	69.88	1.56	6.70	1133.62	407.37	2025-12-05 17:34:10.891444
1283	sensor_cilantro_1	20.55	71.67	70.62	1.84	6.52	887.53	441.47	2025-12-05 17:34:10.891666
1284	sensor_cilantro_2	20.38	72.51	79.82	1.71	6.61	882.33	431.94	2025-12-05 17:34:10.89186
1285	sensor_rabano_1	22.98	64.95	61.32	1.46	6.67	1099.28	436.64	2025-12-05 17:34:20.901852
1286	sensor_rabano_2	23.32	63.67	68.97	1.42	6.75	835.65	472.21	2025-12-05 17:34:20.902342
1287	sensor_cilantro_1	21.29	75.30	72.15	1.49	6.62	1077.47	464.47	2025-12-05 17:34:20.902422
1288	sensor_cilantro_2	20.87	72.48	63.15	1.82	6.41	972.90	415.38	2025-12-05 17:34:20.902479
1289	sensor_rabano_1	21.55	67.13	71.38	1.58	6.65	1190.96	467.89	2025-12-05 17:34:30.915071
1290	sensor_rabano_2	23.53	67.60	76.03	1.63	6.64	986.27	413.84	2025-12-05 17:34:30.915839
1291	sensor_cilantro_1	21.66	77.19	62.50	1.67	6.51	908.00	415.21	2025-12-05 17:34:30.916038
1292	sensor_cilantro_2	22.42	73.38	69.96	1.68	6.57	996.02	450.79	2025-12-05 17:34:30.916186
1293	sensor_rabano_1	22.52	68.48	67.38	1.53	6.49	823.74	467.27	2025-12-05 17:34:40.926475
1294	sensor_rabano_2	20.50	59.34	69.94	1.49	6.69	856.32	488.27	2025-12-05 17:34:40.927205
1295	sensor_cilantro_1	19.12	73.09	77.89	1.64	6.49	820.71	404.55	2025-12-05 17:34:40.927387
1296	sensor_cilantro_2	22.40	69.89	62.48	1.56	6.66	989.74	410.63	2025-12-05 17:34:40.927527
1297	sensor_rabano_1	22.54	60.39	65.75	1.78	6.40	1007.06	468.54	2025-12-05 17:34:50.939064
1298	sensor_rabano_2	20.48	65.66	79.36	1.43	6.61	1133.99	462.09	2025-12-05 17:34:50.939894
1299	sensor_cilantro_1	21.01	76.61	66.25	1.87	6.41	1151.41	489.21	2025-12-05 17:34:50.9401
1300	sensor_cilantro_2	19.53	67.20	74.01	1.64	6.49	1186.63	433.27	2025-12-05 17:34:50.940253
1301	sensor_rabano_1	20.62	68.93	79.57	1.94	6.62	1022.71	461.66	2025-12-05 17:35:00.951003
1302	sensor_rabano_2	20.43	69.52	72.80	1.60	6.61	1027.61	484.11	2025-12-05 17:35:00.951917
1303	sensor_cilantro_1	20.16	72.35	69.86	1.57	6.75	1040.80	495.58	2025-12-05 17:35:00.95212
1304	sensor_cilantro_2	21.57	62.26	63.43	1.97	6.49	982.12	482.04	2025-12-05 17:35:00.95227
1305	sensor_rabano_1	22.58	60.38	65.46	1.55	6.77	1185.41	412.17	2025-12-05 17:35:10.962238
1306	sensor_rabano_2	20.02	61.62	77.23	1.58	6.44	1000.76	465.91	2025-12-05 17:35:10.963026
1307	sensor_cilantro_1	20.05	66.85	72.49	1.97	6.71	985.38	466.06	2025-12-05 17:35:10.96322
1308	sensor_cilantro_2	19.51	73.54	66.18	1.50	6.40	809.19	462.19	2025-12-05 17:35:10.963291
1309	sensor_rabano_1	23.97	62.58	72.95	1.92	6.56	1095.73	480.45	2025-12-05 17:35:20.974701
1310	sensor_rabano_2	23.81	59.69	75.26	1.43	6.72	926.66	428.62	2025-12-05 17:35:20.975513
1311	sensor_cilantro_1	22.55	64.53	79.08	1.62	6.58	1056.25	470.74	2025-12-05 17:35:20.9757
1312	sensor_cilantro_2	22.66	64.91	62.54	1.67	6.53	1147.01	434.55	2025-12-05 17:35:20.975844
1313	sensor_rabano_1	22.32	62.74	75.19	1.49	6.76	959.86	473.68	2025-12-05 17:35:30.987306
1314	sensor_rabano_2	21.33	72.49	70.67	1.70	6.45	931.06	494.69	2025-12-05 17:35:30.988171
1315	sensor_cilantro_1	20.77	77.87	78.82	1.55	6.53	952.71	478.05	2025-12-05 17:35:30.988391
1316	sensor_cilantro_2	21.59	65.36	72.83	1.86	6.59	1151.81	459.14	2025-12-05 17:35:30.988546
1317	sensor_rabano_1	21.91	66.24	76.42	1.99	6.71	865.68	418.78	2025-12-05 17:35:40.99883
1318	sensor_rabano_2	23.64	72.80	73.35	1.72	6.65	1089.82	453.42	2025-12-05 17:35:40.999666
1319	sensor_cilantro_1	21.05	76.10	68.77	1.90	6.71	947.59	434.31	2025-12-05 17:35:40.999851
1320	sensor_cilantro_2	20.98	75.13	69.50	1.99	6.71	1003.23	466.87	2025-12-05 17:35:40.999999
1321	sensor_rabano_1	20.78	66.85	61.17	1.94	6.48	819.60	442.20	2025-12-05 17:35:51.01151
1322	sensor_rabano_2	22.87	63.82	76.10	1.73	6.50	920.60	471.69	2025-12-05 17:35:51.012263
1323	sensor_cilantro_1	19.97	66.42	70.40	1.56	6.47	1128.12	496.79	2025-12-05 17:35:51.012454
1324	sensor_cilantro_2	20.62	73.93	79.97	1.54	6.51	1036.16	433.43	2025-12-05 17:35:51.012598
1325	sensor_rabano_1	20.81	64.31	73.67	1.42	6.64	1061.10	418.31	2025-12-05 17:36:01.023963
1326	sensor_rabano_2	21.57	72.20	61.16	1.64	6.46	1113.93	462.72	2025-12-05 17:36:01.024784
1327	sensor_cilantro_1	20.95	66.30	64.88	1.67	6.75	924.52	495.40	2025-12-05 17:36:01.024963
1328	sensor_cilantro_2	22.63	75.79	78.49	1.86	6.47	1078.52	456.01	2025-12-05 17:36:01.025109
1329	sensor_rabano_1	23.45	60.53	75.31	1.51	6.55	1022.25	456.23	2025-12-05 17:36:11.035691
1330	sensor_rabano_2	22.10	70.80	79.83	1.53	6.78	1110.28	491.08	2025-12-05 17:36:11.036599
1331	sensor_cilantro_1	21.95	74.64	76.71	1.70	6.67	1052.37	488.39	2025-12-05 17:36:11.036833
1332	sensor_cilantro_2	22.02	67.00	78.09	1.53	6.72	1144.32	451.46	2025-12-05 17:36:11.037028
1333	sensor_rabano_1	22.27	69.75	69.49	1.99	6.79	1037.97	402.84	2025-12-05 17:36:21.047216
1334	sensor_rabano_2	22.41	68.39	73.31	1.43	6.53	1074.16	412.51	2025-12-05 17:36:21.048068
1335	sensor_cilantro_1	20.41	66.42	66.19	1.63	6.50	1129.34	410.35	2025-12-05 17:36:21.048347
1336	sensor_cilantro_2	22.83	70.62	65.40	1.59	6.66	1155.70	475.36	2025-12-05 17:36:21.048545
1337	sensor_rabano_1	21.40	70.37	77.01	1.54	6.75	1132.32	443.60	2025-12-05 17:36:31.058758
1338	sensor_rabano_2	21.32	69.57	71.45	1.65	6.55	882.56	480.07	2025-12-05 17:36:31.059681
1339	sensor_cilantro_1	21.41	65.69	71.34	1.88	6.64	1150.57	459.54	2025-12-05 17:36:31.05987
1340	sensor_cilantro_2	20.00	68.55	67.20	1.86	6.62	973.92	489.57	2025-12-05 17:36:31.060021
1341	sensor_rabano_1	22.38	65.55	76.53	1.68	6.58	1052.20	418.01	2025-12-05 17:36:41.07039
1342	sensor_rabano_2	22.56	71.34	62.20	1.40	6.70	838.78	427.09	2025-12-05 17:36:41.071212
1343	sensor_cilantro_1	21.41	71.86	74.26	1.91	6.62	1164.71	457.37	2025-12-05 17:36:41.071488
1344	sensor_cilantro_2	20.22	64.78	70.56	1.77	6.62	967.26	431.91	2025-12-05 17:36:41.071702
1345	sensor_rabano_1	23.26	72.05	61.55	1.62	6.79	842.60	450.35	2025-12-05 17:36:51.082964
1346	sensor_rabano_2	20.48	61.52	70.27	1.80	6.44	879.00	430.39	2025-12-05 17:36:51.0838
1347	sensor_cilantro_1	21.78	77.27	67.88	1.72	6.46	808.30	489.52	2025-12-05 17:36:51.083983
1348	sensor_cilantro_2	21.60	76.49	62.88	1.86	6.49	920.70	413.14	2025-12-05 17:36:51.084126
1349	sensor_rabano_1	23.18	65.23	67.72	1.43	6.76	961.60	495.04	2025-12-05 17:37:01.096074
1350	sensor_rabano_2	22.57	64.18	65.41	1.98	6.69	1095.42	414.26	2025-12-05 17:37:01.096849
1351	sensor_cilantro_1	19.41	73.57	68.34	1.73	6.43	969.26	419.55	2025-12-05 17:37:01.097038
1352	sensor_cilantro_2	22.52	63.48	62.94	1.94	6.66	1109.51	459.61	2025-12-05 17:37:01.097536
1353	sensor_rabano_1	20.01	58.27	79.19	1.52	6.68	1166.94	430.41	2025-12-05 17:37:11.108614
1354	sensor_rabano_2	21.58	58.22	67.22	1.91	6.41	876.83	487.14	2025-12-05 17:37:11.109584
1355	sensor_cilantro_1	22.72	65.05	68.12	1.83	6.69	809.42	408.66	2025-12-05 17:37:11.109806
1356	sensor_cilantro_2	21.16	70.02	71.34	1.81	6.70	1042.20	443.41	2025-12-05 17:37:11.109997
1357	sensor_rabano_1	21.64	57.90	72.76	2.00	6.41	1042.68	479.20	2025-12-05 17:37:21.121979
1358	sensor_rabano_2	23.02	62.36	63.67	1.97	6.49	1154.76	450.56	2025-12-05 17:37:21.123185
1359	sensor_cilantro_1	20.89	68.68	63.80	1.61	6.45	1175.04	429.56	2025-12-05 17:37:21.123459
1360	sensor_cilantro_2	22.18	66.78	66.77	1.91	6.41	852.95	470.14	2025-12-05 17:37:21.123621
1361	sensor_rabano_1	22.09	67.50	68.70	1.55	6.62	1159.68	488.44	2025-12-05 17:37:31.135044
1362	sensor_rabano_2	21.71	70.30	76.71	1.81	6.71	925.23	404.36	2025-12-05 17:37:31.135858
1363	sensor_cilantro_1	20.65	73.53	73.22	1.81	6.63	889.94	482.77	2025-12-05 17:37:31.136101
1364	sensor_cilantro_2	20.82	72.91	70.20	1.57	6.52	960.58	405.01	2025-12-05 17:37:31.136268
1365	sensor_rabano_1	21.90	59.19	78.75	1.96	6.41	1193.19	472.07	2025-12-05 17:37:41.145916
1366	sensor_rabano_2	22.82	68.47	64.93	1.48	6.57	917.59	483.03	2025-12-05 17:37:41.146993
1367	sensor_cilantro_1	19.42	64.03	61.76	2.00	6.76	1089.18	407.65	2025-12-05 17:37:41.147279
1368	sensor_cilantro_2	22.42	70.80	71.88	1.41	6.49	820.14	465.75	2025-12-05 17:37:41.147461
1369	sensor_rabano_1	23.89	70.43	76.77	1.73	6.76	965.41	448.03	2025-12-05 17:37:51.157952
1370	sensor_rabano_2	22.95	71.61	61.38	1.96	6.52	1116.40	401.56	2025-12-05 17:37:51.158818
1371	sensor_cilantro_1	20.61	70.37	79.76	1.94	6.43	1109.38	486.95	2025-12-05 17:37:51.159066
1372	sensor_cilantro_2	21.14	64.06	66.11	1.47	6.61	1068.51	416.02	2025-12-05 17:37:51.159231
1373	sensor_rabano_1	23.96	60.65	77.42	1.71	6.64	836.25	479.14	2025-12-05 17:38:01.170655
1374	sensor_rabano_2	21.52	71.12	72.04	1.75	6.80	1089.17	472.13	2025-12-05 17:38:01.171227
1375	sensor_cilantro_1	22.45	66.74	61.68	1.63	6.65	1172.94	430.78	2025-12-05 17:38:01.17148
1376	sensor_cilantro_2	22.64	73.64	76.34	1.65	6.44	939.97	438.89	2025-12-05 17:38:01.171568
1377	sensor_rabano_1	20.97	62.18	70.07	1.54	6.67	962.58	414.45	2025-12-05 17:38:11.179483
1378	sensor_rabano_2	20.32	66.26	75.26	1.89	6.44	1137.84	412.21	2025-12-05 17:38:11.180187
1379	sensor_cilantro_1	21.40	66.07	61.30	1.43	6.44	1163.85	426.07	2025-12-05 17:38:11.180293
1380	sensor_cilantro_2	21.46	64.77	67.97	1.71	6.71	1189.31	408.83	2025-12-05 17:38:11.180353
1381	sensor_rabano_1	21.37	70.80	60.06	1.42	6.68	1096.44	475.07	2025-12-05 17:38:21.189419
1382	sensor_rabano_2	21.03	63.06	69.85	1.68	6.64	946.93	424.70	2025-12-05 17:38:21.189935
1383	sensor_cilantro_1	21.97	63.10	70.47	1.80	6.63	872.64	428.10	2025-12-05 17:38:21.190032
1384	sensor_cilantro_2	21.96	72.77	70.15	1.53	6.41	836.04	464.86	2025-12-05 17:38:21.190093
1385	sensor_rabano_1	23.76	66.30	61.00	1.77	6.66	855.55	456.28	2025-12-05 17:38:31.199189
1386	sensor_rabano_2	22.87	72.17	62.64	1.48	6.73	831.24	476.31	2025-12-05 17:38:31.199964
1387	sensor_cilantro_1	19.79	73.69	72.93	1.86	6.79	1120.73	466.95	2025-12-05 17:38:31.20016
1388	sensor_cilantro_2	21.55	62.44	61.61	1.67	6.51	1064.86	401.62	2025-12-05 17:38:31.200302
1389	sensor_rabano_1	20.29	66.28	79.75	1.43	6.75	836.41	487.53	2025-12-05 17:38:41.218573
1390	sensor_rabano_2	20.02	64.51	79.35	1.74	6.49	1146.08	473.72	2025-12-05 17:38:41.219627
1391	sensor_cilantro_1	22.19	74.80	65.35	1.80	6.73	858.64	435.89	2025-12-05 17:38:41.219898
1392	sensor_cilantro_2	20.97	66.71	66.98	1.73	6.76	940.00	494.48	2025-12-05 17:38:41.220172
1393	sensor_rabano_1	23.19	60.18	76.03	1.64	6.62	1048.09	400.11	2025-12-05 17:38:51.233012
1394	sensor_rabano_2	20.50	68.48	73.02	1.94	6.48	815.46	456.99	2025-12-05 17:38:51.233776
1395	sensor_cilantro_1	20.27	65.81	79.37	1.72	6.44	986.66	484.13	2025-12-05 17:38:51.23395
1396	sensor_cilantro_2	20.42	68.63	71.56	1.68	6.50	877.84	413.31	2025-12-05 17:38:51.234104
1397	sensor_rabano_1	21.44	59.89	79.10	1.81	6.78	1119.52	453.80	2025-12-05 17:39:01.243504
1398	sensor_rabano_2	23.26	70.16	71.62	1.45	6.52	1062.99	451.62	2025-12-05 17:39:01.244281
1399	sensor_cilantro_1	21.84	71.16	77.74	1.68	6.45	873.78	441.86	2025-12-05 17:39:01.244459
1400	sensor_cilantro_2	20.43	62.06	78.98	1.56	6.71	1006.97	438.93	2025-12-05 17:39:01.244605
1401	sensor_rabano_1	22.30	63.76	60.03	1.69	6.56	1151.15	440.11	2025-12-05 17:39:11.254486
1402	sensor_rabano_2	20.93	71.13	78.45	1.89	6.43	1012.16	414.27	2025-12-05 17:39:11.255039
1403	sensor_cilantro_1	22.85	64.11	71.07	1.54	6.54	916.90	484.59	2025-12-05 17:39:11.255171
1404	sensor_cilantro_2	22.35	64.71	60.40	1.46	6.75	1153.04	421.77	2025-12-05 17:39:11.255257
1405	sensor_rabano_1	22.25	62.22	62.58	1.75	6.64	1079.62	468.69	2025-12-05 17:39:21.264102
1406	sensor_rabano_2	24.00	61.48	78.11	1.53	6.52	1163.60	488.95	2025-12-05 17:39:21.264625
1407	sensor_cilantro_1	19.57	72.33	62.65	1.49	6.41	832.85	408.67	2025-12-05 17:39:21.264709
1408	sensor_cilantro_2	21.08	63.15	71.75	1.63	6.57	900.87	491.96	2025-12-05 17:39:21.264765
1409	sensor_rabano_1	23.90	66.17	65.59	1.81	6.45	887.67	480.91	2025-12-05 17:39:31.274331
1410	sensor_rabano_2	20.21	64.71	74.08	1.73	6.46	1074.92	482.90	2025-12-05 17:39:31.274939
1411	sensor_cilantro_1	21.42	76.21	69.11	1.83	6.65	1051.43	415.26	2025-12-05 17:39:31.275199
1412	sensor_cilantro_2	19.77	72.58	72.35	1.81	6.70	923.84	448.97	2025-12-05 17:39:31.275353
1413	sensor_rabano_1	22.26	60.21	61.31	1.56	6.47	926.66	404.60	2025-12-05 17:39:41.285938
1414	sensor_rabano_2	23.68	59.76	75.26	1.67	6.51	1153.60	461.90	2025-12-05 17:39:41.286814
1415	sensor_cilantro_1	20.05	71.26	65.68	1.65	6.41	1052.06	429.55	2025-12-05 17:39:41.287086
1416	sensor_cilantro_2	22.18	72.35	71.32	1.96	6.60	1122.99	466.79	2025-12-05 17:39:41.287312
1417	sensor_rabano_1	20.37	62.00	78.19	1.50	6.41	1176.91	474.93	2025-12-05 17:39:51.298276
1418	sensor_rabano_2	23.35	57.63	67.74	1.71	6.64	1184.69	413.50	2025-12-05 17:39:51.29913
1419	sensor_cilantro_1	22.27	68.72	71.90	1.75	6.42	853.63	498.08	2025-12-05 17:39:51.299324
1420	sensor_cilantro_2	20.24	69.12	61.58	1.66	6.48	946.26	483.24	2025-12-05 17:39:51.299468
1421	sensor_rabano_1	23.39	70.91	77.43	1.51	6.80	1076.06	459.55	2025-12-05 17:40:01.311471
1422	sensor_rabano_2	20.95	67.92	60.99	1.75	6.59	914.63	443.17	2025-12-05 17:40:01.312883
1423	sensor_cilantro_1	20.41	69.71	71.68	1.72	6.54	866.88	451.10	2025-12-05 17:40:01.313346
1424	sensor_cilantro_2	20.52	62.46	63.93	1.72	6.58	1004.09	415.16	2025-12-05 17:40:01.313545
1425	sensor_rabano_1	23.48	71.75	77.17	1.51	6.45	1090.52	484.96	2025-12-05 17:40:11.32327
1426	sensor_rabano_2	22.99	69.46	62.23	1.40	6.41	1113.26	483.85	2025-12-05 17:40:11.324147
1427	sensor_cilantro_1	22.84	74.09	79.06	1.57	6.78	1198.14	486.66	2025-12-05 17:40:11.324459
1428	sensor_cilantro_2	19.23	69.17	70.26	1.56	6.41	1099.22	449.17	2025-12-05 17:40:11.324669
1429	sensor_rabano_1	20.03	61.70	75.66	1.95	6.40	1020.18	479.84	2025-12-05 17:40:21.334036
1430	sensor_rabano_2	23.44	58.42	65.62	1.83	6.42	1062.78	436.87	2025-12-05 17:40:21.334733
1431	sensor_cilantro_1	20.42	64.62	61.51	1.45	6.67	1198.23	442.86	2025-12-05 17:40:21.334838
1432	sensor_cilantro_2	21.54	77.98	65.58	1.47	6.60	936.22	477.77	2025-12-05 17:40:21.334898
1433	sensor_rabano_1	22.79	59.66	79.16	1.59	6.80	1110.67	404.52	2025-12-05 17:40:31.346216
1434	sensor_rabano_2	23.67	58.86	76.41	1.62	6.61	1106.80	449.40	2025-12-05 17:40:31.347091
1435	sensor_cilantro_1	19.40	68.40	69.92	1.52	6.55	1172.35	478.80	2025-12-05 17:40:31.34729
1436	sensor_cilantro_2	22.97	66.41	65.42	1.97	6.76	998.71	452.08	2025-12-05 17:40:31.347438
1437	sensor_rabano_1	20.21	57.14	67.33	1.93	6.45	1153.63	474.14	2025-12-05 17:40:41.358591
1438	sensor_rabano_2	22.09	65.89	67.18	1.62	6.77	989.83	473.63	2025-12-05 17:40:41.359306
1439	sensor_cilantro_1	22.62	76.36	73.76	1.90	6.40	1129.40	430.66	2025-12-05 17:40:41.35944
1440	sensor_cilantro_2	20.21	68.34	71.41	1.59	6.77	877.56	453.70	2025-12-05 17:40:41.359509
1441	sensor_rabano_1	23.39	62.69	67.50	1.40	6.42	869.45	414.69	2025-12-05 17:40:51.366849
1442	sensor_rabano_2	20.26	60.85	60.94	1.62	6.58	1054.07	418.15	2025-12-05 17:40:51.367395
1443	sensor_cilantro_1	19.36	62.99	74.80	1.52	6.54	1153.31	484.54	2025-12-05 17:40:51.367482
1444	sensor_cilantro_2	21.36	67.76	76.48	1.48	6.45	881.52	454.50	2025-12-05 17:40:51.367537
1445	sensor_rabano_1	22.69	59.77	74.75	1.47	6.71	1126.20	464.54	2025-12-05 17:41:01.379492
1446	sensor_rabano_2	20.60	72.01	68.38	1.86	6.48	1057.00	426.07	2025-12-05 17:41:01.38028
1447	sensor_cilantro_1	20.49	62.31	61.17	1.54	6.75	1014.75	417.45	2025-12-05 17:41:01.38047
1448	sensor_cilantro_2	19.82	62.47	75.69	1.59	6.56	1164.03	465.08	2025-12-05 17:41:01.380613
1449	sensor_rabano_1	20.66	72.47	72.30	1.80	6.41	1110.59	414.10	2025-12-05 17:41:11.39391
1450	sensor_rabano_2	21.06	59.53	75.04	1.46	6.62	972.14	462.66	2025-12-05 17:41:11.394801
1451	sensor_cilantro_1	22.78	73.38	76.17	1.70	6.42	1075.03	488.41	2025-12-05 17:41:11.395084
1452	sensor_cilantro_2	20.94	77.40	70.64	1.57	6.63	1188.25	439.14	2025-12-05 17:41:11.395287
1453	sensor_rabano_1	20.01	61.06	69.98	1.54	6.52	961.88	436.18	2025-12-05 17:41:21.407227
1454	sensor_rabano_2	21.31	66.15	64.89	1.65	6.60	962.68	447.40	2025-12-05 17:41:21.408084
1455	sensor_cilantro_1	19.01	73.05	73.90	1.63	6.64	808.78	425.57	2025-12-05 17:41:21.408326
1456	sensor_cilantro_2	21.70	70.23	68.72	1.52	6.61	1137.51	401.20	2025-12-05 17:41:21.408483
1457	sensor_rabano_1	23.44	59.17	75.08	1.69	6.62	945.07	492.11	2025-12-05 17:41:31.419569
1458	sensor_rabano_2	21.55	64.20	67.47	1.59	6.42	1005.94	431.26	2025-12-05 17:41:31.420471
1459	sensor_cilantro_1	22.31	69.31	69.99	1.42	6.47	1151.75	419.13	2025-12-05 17:41:31.420585
1460	sensor_cilantro_2	21.54	62.78	76.88	1.60	6.53	838.69	456.39	2025-12-05 17:41:31.420874
1461	sensor_rabano_1	20.11	63.57	76.30	1.88	6.68	940.44	487.87	2025-12-05 17:41:41.432865
1462	sensor_rabano_2	21.03	66.67	72.02	1.42	6.55	1073.00	416.44	2025-12-05 17:41:41.434332
1463	sensor_cilantro_1	20.51	67.47	60.36	1.94	6.47	946.71	481.39	2025-12-05 17:41:41.434633
1464	sensor_cilantro_2	21.91	70.78	60.78	1.78	6.44	810.00	444.72	2025-12-05 17:41:41.434802
1465	sensor_rabano_1	22.21	62.46	69.57	1.76	6.41	969.80	448.80	2025-12-05 17:41:51.443826
1466	sensor_rabano_2	21.26	60.30	76.13	1.72	6.79	1096.08	446.67	2025-12-05 17:41:51.444465
1467	sensor_cilantro_1	20.24	64.01	74.66	1.63	6.49	961.44	497.46	2025-12-05 17:41:51.444573
1468	sensor_cilantro_2	19.77	65.79	65.10	1.63	6.43	1071.10	411.00	2025-12-05 17:41:51.444632
1469	sensor_rabano_1	23.44	69.75	66.48	1.50	6.45	1109.27	413.26	2025-12-05 17:42:01.456214
1470	sensor_rabano_2	21.64	68.25	65.93	1.57	6.47	997.41	413.04	2025-12-05 17:42:01.457104
1471	sensor_cilantro_1	19.41	65.05	62.30	1.47	6.46	1150.52	491.45	2025-12-05 17:42:01.457298
1472	sensor_cilantro_2	20.21	67.00	78.14	2.00	6.61	823.24	496.46	2025-12-05 17:42:01.457439
1473	sensor_rabano_1	20.64	70.90	64.11	1.66	6.41	924.86	484.19	2025-12-05 17:42:11.469747
1474	sensor_rabano_2	23.14	68.94	73.49	1.72	6.55	867.43	483.18	2025-12-05 17:42:11.470544
1475	sensor_cilantro_1	20.27	62.80	65.65	1.90	6.58	970.72	482.46	2025-12-05 17:42:11.470779
1476	sensor_cilantro_2	20.78	72.85	79.15	1.91	6.56	1108.85	400.85	2025-12-05 17:42:11.47094
1477	sensor_rabano_1	23.44	61.07	65.00	1.87	6.53	1096.41	425.32	2025-12-05 17:42:21.482455
1478	sensor_rabano_2	23.52	64.51	70.26	1.91	6.69	1126.19	435.43	2025-12-05 17:42:21.483218
1479	sensor_cilantro_1	19.02	65.38	64.93	1.63	6.74	1120.62	414.27	2025-12-05 17:42:21.483396
1480	sensor_cilantro_2	21.99	67.33	63.30	1.87	6.41	1090.64	405.74	2025-12-05 17:42:21.483533
1481	sensor_rabano_1	22.60	68.80	71.14	1.84	6.59	1031.61	469.04	2025-12-05 17:42:31.494583
1482	sensor_rabano_2	20.59	67.90	65.51	1.91	6.77	875.37	459.61	2025-12-05 17:42:31.495359
1483	sensor_cilantro_1	21.48	69.61	77.72	1.44	6.79	1191.11	439.04	2025-12-05 17:42:31.495537
1484	sensor_cilantro_2	22.50	72.01	67.75	1.86	6.65	1105.45	468.17	2025-12-05 17:42:31.495621
1485	sensor_rabano_1	21.87	68.02	60.40	1.81	6.76	1019.27	426.47	2025-12-05 17:42:41.507827
1486	sensor_rabano_2	23.77	66.29	71.97	1.61	6.72	980.64	451.26	2025-12-05 17:42:41.509258
1487	sensor_cilantro_1	19.69	67.35	64.47	1.54	6.58	1068.36	474.08	2025-12-05 17:42:41.50963
1488	sensor_cilantro_2	22.44	73.72	78.96	1.78	6.46	827.69	477.34	2025-12-05 17:42:41.50985
1489	sensor_rabano_1	20.22	59.71	60.32	1.57	6.49	817.09	429.55	2025-12-05 17:42:51.521639
1490	sensor_rabano_2	23.63	67.94	79.87	1.75	6.73	817.33	419.43	2025-12-05 17:42:51.522453
1491	sensor_cilantro_1	21.42	73.82	67.80	1.54	6.56	949.71	463.10	2025-12-05 17:42:51.522973
1492	sensor_cilantro_2	22.65	70.37	67.28	1.95	6.48	936.72	480.27	2025-12-05 17:42:51.523265
1493	sensor_rabano_1	21.07	68.43	66.09	1.69	6.67	1040.92	409.61	2025-12-05 17:43:01.534365
1494	sensor_rabano_2	23.02	59.73	73.91	1.90	6.53	825.53	429.17	2025-12-05 17:43:01.534997
1495	sensor_cilantro_1	19.13	76.93	69.29	1.93	6.61	955.23	441.66	2025-12-05 17:43:01.535091
1496	sensor_cilantro_2	19.64	62.22	69.26	1.92	6.64	949.95	416.52	2025-12-05 17:43:01.535147
1497	sensor_rabano_1	21.14	64.11	61.04	1.76	6.79	824.39	439.43	2025-12-05 17:43:11.545206
1498	sensor_rabano_2	21.44	69.44	72.86	1.64	6.73	1052.96	485.67	2025-12-05 17:43:11.545953
1499	sensor_cilantro_1	19.54	67.94	79.24	1.77	6.57	946.89	458.94	2025-12-05 17:43:11.546193
1500	sensor_cilantro_2	21.72	63.78	64.97	1.96	6.54	922.10	441.28	2025-12-05 17:43:11.546355
1501	sensor_rabano_1	20.10	69.73	66.48	1.92	6.77	809.88	421.39	2025-12-05 17:43:21.557963
1502	sensor_rabano_2	21.55	67.12	79.74	1.50	6.65	1021.12	493.01	2025-12-05 17:43:21.558898
1503	sensor_cilantro_1	22.44	71.46	78.42	1.72	6.44	1075.46	423.74	2025-12-05 17:43:21.559143
1504	sensor_cilantro_2	21.74	65.70	66.89	1.84	6.59	1016.63	422.50	2025-12-05 17:43:21.559339
1505	sensor_rabano_1	23.38	69.04	70.34	2.00	6.70	1137.76	487.99	2025-12-05 17:43:31.570863
1506	sensor_rabano_2	20.50	57.37	69.40	1.83	6.72	1182.74	417.13	2025-12-05 17:43:31.571726
1507	sensor_cilantro_1	21.72	66.70	73.25	1.74	6.47	1191.49	479.31	2025-12-05 17:43:31.572107
1508	sensor_cilantro_2	21.70	70.85	65.89	1.60	6.77	1168.22	466.65	2025-12-05 17:43:31.572461
1509	sensor_rabano_1	23.16	61.08	71.35	1.45	6.76	835.40	419.19	2025-12-05 17:43:41.597463
1510	sensor_rabano_2	21.91	59.31	63.83	1.47	6.70	983.24	463.53	2025-12-05 17:43:41.598251
1511	sensor_cilantro_1	20.55	63.83	63.80	1.99	6.60	852.80	404.35	2025-12-05 17:43:41.598478
1512	sensor_cilantro_2	21.63	74.48	65.35	1.72	6.54	1039.62	401.96	2025-12-05 17:43:41.59864
1513	sensor_rabano_1	20.43	57.79	71.93	1.80	6.52	946.08	452.86	2025-12-05 17:43:51.610884
1514	sensor_rabano_2	21.23	64.86	62.71	1.68	6.68	890.28	416.40	2025-12-05 17:43:51.611731
1515	sensor_cilantro_1	21.53	69.62	77.29	1.91	6.48	881.07	485.63	2025-12-05 17:43:51.611964
1516	sensor_cilantro_2	19.26	63.68	64.72	1.98	6.72	884.49	432.30	2025-12-05 17:43:51.612187
1517	sensor_rabano_1	23.37	61.25	75.27	1.77	6.41	811.80	401.97	2025-12-05 17:44:01.623745
1518	sensor_rabano_2	23.27	70.22	71.01	1.44	6.80	948.27	414.37	2025-12-05 17:44:01.624782
1519	sensor_cilantro_1	21.37	72.03	62.14	1.92	6.62	915.07	470.06	2025-12-05 17:44:01.62517
1520	sensor_cilantro_2	22.73	76.44	69.07	1.48	6.59	820.37	498.06	2025-12-05 17:44:01.625405
1521	sensor_rabano_1	23.47	66.65	75.61	1.96	6.43	1040.47	454.92	2025-12-05 17:44:11.635094
1522	sensor_rabano_2	23.56	67.79	76.79	1.53	6.42	1101.61	458.58	2025-12-05 17:44:11.635774
1523	sensor_cilantro_1	19.68	71.77	75.53	1.53	6.46	1100.85	465.28	2025-12-05 17:44:11.63595
1524	sensor_cilantro_2	20.16	62.53	67.12	1.91	6.75	800.31	419.72	2025-12-05 17:44:11.636115
1525	sensor_rabano_1	21.76	62.89	65.47	1.72	6.54	1081.25	456.39	2025-12-05 17:44:21.645434
1526	sensor_rabano_2	20.72	60.65	67.61	1.98	6.70	864.61	445.10	2025-12-05 17:44:21.646258
1527	sensor_cilantro_1	20.98	74.00	78.13	1.86	6.45	1081.79	485.97	2025-12-05 17:44:21.646349
1528	sensor_cilantro_2	21.05	67.89	62.86	1.41	6.76	1187.62	465.06	2025-12-05 17:44:21.646406
1529	sensor_rabano_1	22.82	67.83	78.08	1.66	6.72	1137.49	497.08	2025-12-05 17:44:31.657902
1530	sensor_rabano_2	21.93	67.47	68.98	1.82	6.50	920.58	460.82	2025-12-05 17:44:31.658878
1531	sensor_cilantro_1	19.22	77.47	75.62	1.90	6.72	1197.61	466.78	2025-12-05 17:44:31.659185
1532	sensor_cilantro_2	19.34	72.24	73.70	1.82	6.47	925.45	468.06	2025-12-05 17:44:31.659518
1533	sensor_rabano_1	23.34	63.43	72.90	1.71	6.80	860.40	432.27	2025-12-05 17:44:41.671872
1534	sensor_rabano_2	20.78	63.36	78.02	1.98	6.56	940.82	467.60	2025-12-05 17:44:41.672769
1535	sensor_cilantro_1	20.90	63.93	68.85	1.62	6.45	1002.62	482.40	2025-12-05 17:44:41.672997
1536	sensor_cilantro_2	20.97	63.70	61.56	1.91	6.74	987.51	431.34	2025-12-05 17:44:41.673213
1537	sensor_rabano_1	20.78	66.37	75.78	1.86	6.74	1105.63	425.84	2025-12-05 17:44:51.686191
1538	sensor_rabano_2	20.06	57.27	61.53	1.44	6.44	906.05	463.47	2025-12-05 17:44:51.686928
1539	sensor_cilantro_1	22.76	77.83	61.29	1.56	6.60	1000.06	468.57	2025-12-05 17:44:51.687118
1540	sensor_cilantro_2	20.64	65.52	63.62	1.78	6.55	1199.72	492.23	2025-12-05 17:44:51.687263
1541	sensor_rabano_1	20.51	66.79	71.39	1.63	6.59	958.66	476.00	2025-12-05 17:45:01.699009
1542	sensor_rabano_2	20.13	63.76	68.76	1.69	6.76	1019.07	450.43	2025-12-05 17:45:01.699822
1543	sensor_cilantro_1	19.76	63.32	78.78	1.78	6.75	917.89	453.91	2025-12-05 17:45:01.699933
1544	sensor_cilantro_2	19.56	76.49	64.22	1.67	6.80	883.95	447.58	2025-12-05 17:45:01.699996
1545	sensor_rabano_1	22.36	61.39	70.40	1.59	6.74	832.46	481.52	2025-12-05 17:45:11.708273
1546	sensor_rabano_2	22.20	70.74	62.28	1.67	6.53	1022.68	431.23	2025-12-05 17:45:11.709214
1547	sensor_cilantro_1	20.56	66.75	69.65	1.94	6.41	869.61	474.13	2025-12-05 17:45:11.70964
1548	sensor_cilantro_2	22.91	66.08	63.69	1.59	6.70	1056.16	460.21	2025-12-05 17:45:11.709913
1549	sensor_rabano_1	20.07	71.04	77.68	1.40	6.56	897.19	488.26	2025-12-05 17:45:21.722439
1550	sensor_rabano_2	20.54	62.25	79.73	1.46	6.45	905.70	434.21	2025-12-05 17:45:21.723263
1551	sensor_cilantro_1	19.57	64.92	65.59	1.57	6.77	1106.13	425.65	2025-12-05 17:45:21.723455
1552	sensor_cilantro_2	19.62	62.74	76.76	1.62	6.72	1118.41	449.93	2025-12-05 17:45:21.723599
1553	sensor_rabano_1	22.95	63.33	67.07	1.51	6.43	1114.24	410.55	2025-12-05 17:45:31.73475
1554	sensor_rabano_2	21.11	68.03	63.04	1.65	6.62	882.74	491.74	2025-12-05 17:45:31.735345
1555	sensor_cilantro_1	21.04	62.04	70.06	1.65	6.61	1102.90	401.75	2025-12-05 17:45:31.735596
1556	sensor_cilantro_2	22.18	74.79	75.54	1.82	6.61	987.21	483.72	2025-12-05 17:45:31.735752
1557	sensor_rabano_1	20.90	64.88	76.69	1.46	6.64	1077.82	485.27	2025-12-05 17:45:41.746608
1558	sensor_rabano_2	23.26	67.20	64.96	1.53	6.73	1060.10	489.01	2025-12-05 17:45:41.747401
1559	sensor_cilantro_1	21.07	64.25	64.38	1.85	6.42	938.04	448.13	2025-12-05 17:45:41.747592
1560	sensor_cilantro_2	22.35	73.33	60.94	1.99	6.41	1045.84	416.69	2025-12-05 17:45:41.747734
1561	sensor_rabano_1	22.00	62.30	79.22	1.99	6.77	882.34	432.23	2025-12-05 17:45:51.759713
1562	sensor_rabano_2	21.62	60.24	75.30	1.92	6.73	1092.16	403.62	2025-12-05 17:45:51.760582
1563	sensor_cilantro_1	20.62	68.06	60.61	1.91	6.67	1017.17	471.72	2025-12-05 17:45:51.760785
1564	sensor_cilantro_2	22.27	73.51	69.46	1.88	6.42	1001.46	428.53	2025-12-05 17:45:51.760936
1565	sensor_rabano_1	21.47	69.37	64.42	1.76	6.45	1098.45	415.87	2025-12-05 17:46:01.773065
1566	sensor_rabano_2	22.75	60.23	75.68	1.65	6.73	951.78	416.12	2025-12-05 17:46:01.774476
1567	sensor_cilantro_1	20.31	73.58	79.62	1.57	6.65	1126.22	483.87	2025-12-05 17:46:01.774869
1568	sensor_cilantro_2	20.17	62.43	65.62	1.47	6.49	872.14	447.01	2025-12-05 17:46:01.775237
1569	sensor_rabano_1	21.06	63.80	66.99	1.79	6.64	1171.48	462.29	2025-12-05 17:46:11.784713
1570	sensor_rabano_2	20.88	60.30	66.21	1.69	6.44	867.60	417.39	2025-12-05 17:46:11.785525
1571	sensor_cilantro_1	19.85	70.62	65.97	1.58	6.72	857.76	452.22	2025-12-05 17:46:11.785717
1572	sensor_cilantro_2	22.60	64.86	68.83	1.91	6.46	1107.84	484.21	2025-12-05 17:46:11.785856
1573	sensor_rabano_1	23.31	64.85	73.63	1.91	6.56	809.44	462.48	2025-12-05 17:46:21.796736
1574	sensor_rabano_2	20.01	67.41	73.93	1.54	6.68	1164.69	498.38	2025-12-05 17:46:21.797481
1575	sensor_cilantro_1	20.77	64.81	77.56	1.61	6.59	1059.58	488.20	2025-12-05 17:46:21.797673
1576	sensor_cilantro_2	19.22	76.00	68.05	1.97	6.68	1029.99	490.55	2025-12-05 17:46:21.797818
1577	sensor_rabano_1	22.97	69.73	64.36	1.56	6.58	1030.34	472.07	2025-12-05 17:46:31.810795
1578	sensor_rabano_2	22.47	64.03	75.31	1.65	6.76	922.62	454.06	2025-12-05 17:46:31.811651
1579	sensor_cilantro_1	21.06	70.47	77.29	1.99	6.77	962.79	488.94	2025-12-05 17:46:31.811843
1580	sensor_cilantro_2	20.85	70.07	67.98	1.49	6.53	1164.38	427.23	2025-12-05 17:46:31.811998
1581	sensor_rabano_1	21.12	62.78	66.40	1.70	6.77	852.28	492.50	2025-12-05 17:46:41.822229
1582	sensor_rabano_2	22.34	71.03	76.23	1.90	6.46	1151.94	400.86	2025-12-05 17:46:41.823625
1583	sensor_cilantro_1	22.87	67.87	66.81	1.67	6.54	1051.22	459.77	2025-12-05 17:46:41.823899
1584	sensor_cilantro_2	19.64	70.78	78.28	1.80	6.46	1113.67	408.59	2025-12-05 17:46:41.824081
1585	sensor_rabano_1	21.14	64.01	64.84	1.46	6.78	1109.47	482.80	2025-12-05 17:46:51.835635
1586	sensor_rabano_2	23.31	61.09	60.97	1.64	6.49	1033.88	450.98	2025-12-05 17:46:51.836387
1587	sensor_cilantro_1	19.94	68.38	71.90	1.42	6.60	929.52	428.43	2025-12-05 17:46:51.836608
1588	sensor_cilantro_2	22.74	75.78	62.78	1.55	6.50	931.73	483.88	2025-12-05 17:46:51.836766
1589	sensor_rabano_1	23.95	66.86	70.86	1.94	6.73	1159.84	440.76	2025-12-05 17:47:01.848655
1590	sensor_rabano_2	20.86	59.50	64.88	1.56	6.59	815.36	416.10	2025-12-05 17:47:01.849479
1591	sensor_cilantro_1	22.11	67.17	79.42	1.94	6.79	1161.71	419.07	2025-12-05 17:47:01.84967
1592	sensor_cilantro_2	20.99	71.28	67.85	1.99	6.67	951.40	461.74	2025-12-05 17:47:01.849813
1593	sensor_rabano_1	23.59	66.78	76.22	1.94	6.46	936.41	407.19	2025-12-05 17:47:11.860819
1594	sensor_rabano_2	20.21	58.03	71.05	1.70	6.55	1097.36	412.00	2025-12-05 17:47:11.861683
1595	sensor_cilantro_1	21.16	72.39	79.57	1.49	6.41	1194.24	464.91	2025-12-05 17:47:11.86187
1596	sensor_cilantro_2	19.93	74.69	73.55	1.45	6.44	1101.49	423.24	2025-12-05 17:47:11.86207
1597	sensor_rabano_1	21.26	64.71	75.01	1.58	6.46	864.98	494.20	2025-12-05 17:47:21.874368
1598	sensor_rabano_2	23.16	69.42	67.30	1.84	6.55	883.70	422.04	2025-12-05 17:47:21.875195
1599	sensor_cilantro_1	20.57	75.33	76.77	1.50	6.48	907.38	453.34	2025-12-05 17:47:21.875422
1600	sensor_cilantro_2	19.83	72.82	73.79	1.47	6.70	1127.49	477.28	2025-12-05 17:47:21.875585
1601	sensor_rabano_1	22.61	59.32	73.62	1.77	6.56	891.95	406.34	2025-12-05 17:47:31.887584
1602	sensor_rabano_2	21.75	65.15	70.23	1.86	6.57	1011.60	463.95	2025-12-05 17:47:31.888901
1603	sensor_cilantro_1	19.50	64.48	61.47	1.67	6.60	828.46	431.61	2025-12-05 17:47:31.889213
1604	sensor_cilantro_2	21.45	65.03	78.23	1.65	6.46	906.16	475.48	2025-12-05 17:47:31.889425
1605	sensor_rabano_1	20.19	66.63	72.22	1.80	6.58	894.82	445.36	2025-12-05 17:47:41.899488
1606	sensor_rabano_2	22.85	67.04	73.62	1.68	6.62	909.09	484.47	2025-12-05 17:47:41.900147
1607	sensor_cilantro_1	22.78	65.84	72.34	1.77	6.65	1074.70	495.19	2025-12-05 17:47:41.900399
1608	sensor_cilantro_2	20.39	65.82	78.51	1.85	6.55	891.84	413.81	2025-12-05 17:47:41.900553
1609	sensor_rabano_1	22.91	61.74	72.12	1.95	6.60	1044.32	433.65	2025-12-05 17:47:51.908741
1610	sensor_rabano_2	22.40	69.50	68.44	1.66	6.64	960.81	468.48	2025-12-05 17:47:51.90938
1611	sensor_cilantro_1	19.89	75.64	70.97	1.52	6.78	1122.45	409.58	2025-12-05 17:47:51.909557
1612	sensor_cilantro_2	19.13	75.90	77.64	1.65	6.57	969.91	431.71	2025-12-05 17:47:51.909638
1613	sensor_rabano_1	21.24	61.13	64.05	1.74	6.58	889.13	448.02	2025-12-05 17:48:01.918292
1614	sensor_rabano_2	20.53	61.49	70.38	1.74	6.46	1039.29	414.26	2025-12-05 17:48:01.919296
1615	sensor_cilantro_1	21.30	65.97	65.61	1.65	6.66	956.75	461.40	2025-12-05 17:48:01.919673
1616	sensor_cilantro_2	22.61	74.06	69.15	1.72	6.53	1092.41	408.07	2025-12-05 17:48:01.920006
1617	sensor_rabano_1	23.09	72.51	68.49	1.81	6.59	845.78	498.14	2025-12-05 17:48:11.930822
1618	sensor_rabano_2	22.90	70.91	70.21	1.59	6.48	1156.42	482.99	2025-12-05 17:48:11.931739
1619	sensor_cilantro_1	21.52	70.64	77.44	1.97	6.54	947.02	406.09	2025-12-05 17:48:11.932009
1620	sensor_cilantro_2	20.89	64.60	65.87	1.84	6.79	1135.22	470.54	2025-12-05 17:48:11.932272
1621	sensor_rabano_1	20.64	63.03	74.40	1.41	6.43	967.67	440.80	2025-12-05 17:48:21.94499
1622	sensor_rabano_2	21.87	58.93	78.52	1.52	6.75	840.82	406.92	2025-12-05 17:48:21.945862
1623	sensor_cilantro_1	22.26	67.68	61.24	1.61	6.42	823.57	493.42	2025-12-05 17:48:21.946099
1624	sensor_cilantro_2	22.83	77.59	71.17	1.73	6.50	851.89	429.42	2025-12-05 17:48:21.946259
1625	sensor_rabano_1	21.74	61.32	72.00	1.83	6.44	817.31	409.02	2025-12-05 17:48:31.958071
1626	sensor_rabano_2	20.01	60.34	76.20	1.59	6.47	828.85	457.41	2025-12-05 17:48:31.958872
1627	sensor_cilantro_1	20.61	65.70	74.43	1.76	6.57	815.49	401.42	2025-12-05 17:48:31.959074
1628	sensor_cilantro_2	20.69	68.16	61.95	1.57	6.59	835.62	403.12	2025-12-05 17:48:31.959229
1629	sensor_rabano_1	22.22	64.27	64.66	1.86	6.62	1123.21	469.75	2025-12-05 17:48:41.983256
1630	sensor_rabano_2	20.20	68.56	68.48	1.80	6.41	857.36	403.43	2025-12-05 17:48:41.984658
1631	sensor_cilantro_1	20.02	70.97	70.93	1.54	6.42	1188.53	403.34	2025-12-05 17:48:41.985036
1632	sensor_cilantro_2	21.67	69.26	71.74	1.82	6.72	964.82	447.22	2025-12-05 17:48:41.985299
1633	sensor_rabano_1	20.69	67.70	62.00	1.64	6.76	997.33	486.61	2025-12-05 17:48:51.995425
1634	sensor_rabano_2	21.91	70.37	75.54	1.43	6.74	1134.60	407.37	2025-12-05 17:48:51.996218
1635	sensor_cilantro_1	21.99	62.95	71.29	1.63	6.65	937.50	409.40	2025-12-05 17:48:51.996385
1636	sensor_cilantro_2	19.16	66.72	68.46	1.87	6.46	993.56	427.08	2025-12-05 17:48:51.996467
1637	sensor_rabano_1	21.30	64.79	78.85	1.75	6.50	1017.26	457.41	2025-12-05 17:49:02.008567
1638	sensor_rabano_2	23.05	61.53	65.50	1.47	6.79	834.72	450.31	2025-12-05 17:49:02.009446
1639	sensor_cilantro_1	22.65	64.08	66.90	1.84	6.79	917.14	402.75	2025-12-05 17:49:02.009634
1640	sensor_cilantro_2	21.66	68.14	63.62	1.65	6.41	1146.66	480.60	2025-12-05 17:49:02.009776
1641	sensor_rabano_1	21.87	68.46	74.72	1.64	6.78	866.63	477.62	2025-12-05 17:49:12.022041
1642	sensor_rabano_2	22.83	67.65	61.07	1.80	6.65	993.87	481.17	2025-12-05 17:49:12.022828
1643	sensor_cilantro_1	20.97	66.00	61.53	1.53	6.77	1019.49	465.47	2025-12-05 17:49:12.023019
1644	sensor_cilantro_2	21.16	62.55	62.30	1.62	6.54	847.63	457.42	2025-12-05 17:49:12.023402
1645	sensor_rabano_1	22.70	59.69	77.78	1.70	6.80	948.41	496.09	2025-12-05 17:49:22.035759
1646	sensor_rabano_2	23.63	61.39	70.52	1.62	6.73	984.51	447.79	2025-12-05 17:49:22.036526
1647	sensor_cilantro_1	19.34	65.50	68.04	1.83	6.69	1011.42	427.62	2025-12-05 17:49:22.036708
1648	sensor_cilantro_2	22.56	73.64	73.11	1.43	6.45	976.79	451.36	2025-12-05 17:49:22.036849
1649	sensor_rabano_1	21.60	60.80	71.89	1.88	6.46	1076.88	480.62	2025-12-05 17:49:32.049132
1650	sensor_rabano_2	23.18	70.24	79.15	1.83	6.61	1129.06	405.44	2025-12-05 17:49:32.050556
1651	sensor_cilantro_1	20.37	76.31	61.53	1.95	6.53	1175.82	447.08	2025-12-05 17:49:32.050837
1652	sensor_cilantro_2	19.47	70.75	72.89	1.72	6.48	990.20	418.72	2025-12-05 17:49:32.051102
1653	sensor_rabano_1	20.03	69.04	71.93	1.62	6.53	968.84	495.74	2025-12-05 17:49:42.061377
1654	sensor_rabano_2	21.18	66.38	77.27	1.49	6.71	1125.23	427.74	2025-12-05 17:49:42.062364
1655	sensor_cilantro_1	22.00	69.19	61.28	1.83	6.57	974.96	456.38	2025-12-05 17:49:42.062709
1656	sensor_cilantro_2	22.56	70.62	75.16	1.73	6.64	909.30	426.92	2025-12-05 17:49:42.062889
1657	sensor_rabano_1	20.73	58.17	60.93	1.82	6.59	924.62	485.98	2025-12-05 17:49:52.074618
1658	sensor_rabano_2	23.72	62.92	61.86	1.68	6.55	895.00	453.95	2025-12-05 17:49:52.075365
1659	sensor_cilantro_1	19.82	71.01	79.57	1.53	6.62	981.55	485.13	2025-12-05 17:49:52.075543
1660	sensor_cilantro_2	20.59	67.42	69.38	1.53	6.47	1035.41	496.21	2025-12-05 17:49:52.075685
1661	sensor_rabano_1	23.07	65.46	62.78	1.45	6.52	974.15	419.51	2025-12-05 17:50:02.087813
1662	sensor_rabano_2	22.00	59.93	77.14	1.50	6.67	937.22	439.72	2025-12-05 17:50:02.088593
1663	sensor_cilantro_1	19.39	67.89	79.44	1.64	6.73	875.69	453.67	2025-12-05 17:50:02.088702
1664	sensor_cilantro_2	21.68	71.50	70.55	1.55	6.69	854.80	407.69	2025-12-05 17:50:02.088765
1665	sensor_rabano_1	20.62	63.16	70.99	1.49	6.48	904.59	423.62	2025-12-05 17:50:12.100349
1666	sensor_rabano_2	20.11	65.08	69.59	1.60	6.53	835.72	436.53	2025-12-05 17:50:12.101214
1667	sensor_cilantro_1	22.99	64.01	79.73	1.66	6.50	877.97	475.78	2025-12-05 17:50:12.101449
1668	sensor_cilantro_2	22.24	71.49	61.76	1.76	6.75	1062.61	406.32	2025-12-05 17:50:12.101611
1669	sensor_rabano_1	22.63	68.38	72.72	1.87	6.41	1145.16	452.56	2025-12-05 17:50:22.112016
1670	sensor_rabano_2	20.68	65.02	71.58	1.62	6.79	1005.94	496.34	2025-12-05 17:50:22.112981
1671	sensor_cilantro_1	19.72	62.59	71.48	1.52	6.74	821.33	402.31	2025-12-05 17:50:22.113287
1672	sensor_cilantro_2	21.46	77.92	64.27	1.63	6.57	806.33	414.80	2025-12-05 17:50:22.113569
1673	sensor_rabano_1	23.59	66.16	61.37	1.93	6.70	1127.84	442.13	2025-12-05 17:50:32.125798
1674	sensor_rabano_2	20.25	58.18	66.66	1.94	6.53	971.63	433.26	2025-12-05 17:50:32.126737
1675	sensor_cilantro_1	21.13	73.34	67.02	1.58	6.77	800.50	425.46	2025-12-05 17:50:32.126973
1676	sensor_cilantro_2	20.67	69.43	79.51	1.81	6.44	978.75	435.32	2025-12-05 17:50:32.127238
1677	sensor_rabano_1	21.55	57.08	71.43	1.99	6.78	864.01	401.73	2025-12-05 17:50:42.139495
1678	sensor_rabano_2	21.67	67.85	60.64	1.73	6.44	1007.67	481.34	2025-12-05 17:50:42.140326
1679	sensor_cilantro_1	22.68	72.01	60.41	1.94	6.60	1081.13	460.96	2025-12-05 17:50:42.14052
1680	sensor_cilantro_2	22.17	71.79	67.21	1.83	6.54	1127.00	480.15	2025-12-05 17:50:42.140668
1681	sensor_rabano_1	23.84	66.92	63.36	1.91	6.40	811.99	492.15	2025-12-05 17:50:52.152841
1682	sensor_rabano_2	22.94	70.07	71.31	1.73	6.79	1043.43	409.91	2025-12-05 17:50:52.153762
1683	sensor_cilantro_1	20.57	73.77	75.76	1.93	6.62	1098.37	447.49	2025-12-05 17:50:52.154072
1684	sensor_cilantro_2	22.83	64.24	71.41	1.84	6.57	1151.45	472.97	2025-12-05 17:50:52.154293
1685	sensor_rabano_1	23.68	67.25	66.92	1.82	6.78	800.58	462.86	2025-12-05 17:51:02.16667
1686	sensor_rabano_2	22.99	67.73	64.89	1.82	6.59	802.25	434.53	2025-12-05 17:51:02.167458
1687	sensor_cilantro_1	22.49	64.35	70.76	1.55	6.49	1177.47	406.75	2025-12-05 17:51:02.167648
1688	sensor_cilantro_2	22.68	70.89	64.38	1.43	6.55	808.34	477.33	2025-12-05 17:51:02.167796
1689	sensor_rabano_1	21.09	61.46	68.55	1.75	6.69	888.87	472.16	2025-12-05 17:51:12.179003
1690	sensor_rabano_2	20.51	69.67	74.98	1.78	6.76	1129.02	478.20	2025-12-05 17:51:12.180201
1691	sensor_cilantro_1	19.15	65.00	66.90	1.67	6.72	1061.21	412.25	2025-12-05 17:51:12.180419
1692	sensor_cilantro_2	20.10	73.34	72.47	1.90	6.47	813.74	488.66	2025-12-05 17:51:12.180581
1693	sensor_rabano_1	23.11	60.92	75.63	1.74	6.45	847.45	423.00	2025-12-05 17:51:22.191562
1694	sensor_rabano_2	21.92	59.36	74.73	1.43	6.74	1056.19	443.54	2025-12-05 17:51:22.192166
1695	sensor_cilantro_1	21.32	63.26	72.43	1.62	6.49	981.90	420.20	2025-12-05 17:51:22.192273
1696	sensor_cilantro_2	21.27	75.53	65.45	1.77	6.61	916.21	496.48	2025-12-05 17:51:22.192333
1697	sensor_rabano_1	20.53	67.72	66.80	1.58	6.66	855.25	473.44	2025-12-05 17:51:32.202617
1698	sensor_rabano_2	22.48	72.48	67.22	1.77	6.71	936.69	478.35	2025-12-05 17:51:32.203252
1699	sensor_cilantro_1	22.01	73.12	68.24	1.47	6.60	925.34	403.57	2025-12-05 17:51:32.203501
1700	sensor_cilantro_2	22.41	76.48	65.13	1.92	6.50	1160.06	458.70	2025-12-05 17:51:32.203595
1701	sensor_rabano_1	20.41	68.76	68.75	1.81	6.60	1132.88	413.82	2025-12-05 17:51:42.21579
1702	sensor_rabano_2	21.57	67.64	78.21	1.95	6.67	1017.65	428.18	2025-12-05 17:51:42.216573
1703	sensor_cilantro_1	19.45	76.24	64.56	1.91	6.53	922.56	483.75	2025-12-05 17:51:42.21675
1704	sensor_cilantro_2	22.28	77.76	73.32	1.71	6.68	1122.89	408.90	2025-12-05 17:51:42.21689
1705	sensor_rabano_1	22.71	62.19	69.24	1.90	6.72	935.99	433.60	2025-12-05 17:51:52.229072
1706	sensor_rabano_2	21.26	58.84	78.20	1.64	6.66	1029.02	436.29	2025-12-05 17:51:52.229952
1707	sensor_cilantro_1	22.10	75.07	75.04	1.48	6.40	944.88	430.10	2025-12-05 17:51:52.230197
1708	sensor_cilantro_2	20.57	65.78	77.21	1.59	6.60	945.71	427.61	2025-12-05 17:51:52.230357
1709	sensor_rabano_1	22.70	72.37	78.28	1.52	6.70	858.33	454.26	2025-12-05 17:52:02.242309
1710	sensor_rabano_2	23.42	59.74	73.61	1.93	6.67	1185.49	451.15	2025-12-05 17:52:02.243521
1711	sensor_cilantro_1	20.03	64.89	73.97	1.95	6.50	927.74	467.55	2025-12-05 17:52:02.243876
1712	sensor_cilantro_2	21.64	76.96	62.63	1.73	6.74	846.24	413.80	2025-12-05 17:52:02.244181
1713	sensor_rabano_1	21.15	67.48	73.97	1.91	6.50	913.66	453.64	2025-12-05 17:52:12.256294
1714	sensor_rabano_2	22.78	58.52	68.22	1.85	6.43	1048.43	457.97	2025-12-05 17:52:12.257324
1715	sensor_cilantro_1	19.89	62.45	68.52	1.59	6.51	1102.48	490.38	2025-12-05 17:52:12.257572
1716	sensor_cilantro_2	21.15	62.45	73.13	1.98	6.58	885.86	488.27	2025-12-05 17:52:12.257809
1717	sensor_rabano_1	21.96	70.46	70.61	1.64	6.46	1007.07	480.94	2025-12-05 17:52:22.269767
1718	sensor_rabano_2	20.09	71.08	60.38	1.98	6.48	800.22	415.33	2025-12-05 17:52:22.270922
1719	sensor_cilantro_1	19.70	73.73	75.56	1.73	6.73	916.23	483.46	2025-12-05 17:52:22.271241
1720	sensor_cilantro_2	19.04	64.14	61.07	1.50	6.59	843.75	440.15	2025-12-05 17:52:22.271495
1721	sensor_rabano_1	22.33	62.93	69.16	1.63	6.73	1020.78	485.03	2025-12-05 17:52:32.28324
1722	sensor_rabano_2	22.00	62.77	79.26	1.44	6.79	1183.57	446.79	2025-12-05 17:52:32.284092
1723	sensor_cilantro_1	19.45	72.48	68.37	1.58	6.57	861.94	451.95	2025-12-05 17:52:32.284287
1724	sensor_cilantro_2	21.51	67.99	62.98	1.84	6.47	983.06	460.18	2025-12-05 17:52:32.284439
1725	sensor_rabano_1	22.85	66.84	67.91	1.85	6.61	899.46	409.82	2025-12-05 17:52:42.296488
1726	sensor_rabano_2	22.50	70.63	70.11	1.80	6.48	876.71	492.74	2025-12-05 17:52:42.297302
1727	sensor_cilantro_1	22.21	75.93	67.46	1.49	6.61	1131.96	467.96	2025-12-05 17:52:42.297606
1728	sensor_cilantro_2	21.44	66.80	74.98	1.87	6.65	1129.23	438.21	2025-12-05 17:52:42.297784
1729	sensor_rabano_1	20.07	61.87	60.94	1.74	6.66	1106.48	490.76	2025-12-05 17:52:52.308346
1730	sensor_rabano_2	21.77	60.23	71.60	1.76	6.69	1041.69	419.31	2025-12-05 17:52:52.30956
1731	sensor_cilantro_1	19.63	76.44	64.20	1.49	6.75	1157.02	489.08	2025-12-05 17:52:52.309761
1732	sensor_cilantro_2	21.55	75.69	79.49	1.80	6.59	852.68	464.37	2025-12-05 17:52:52.309905
1733	sensor_rabano_1	23.96	71.32	74.66	1.82	6.69	950.27	430.61	2025-12-05 17:53:02.32181
1734	sensor_rabano_2	20.74	63.51	64.56	1.64	6.59	935.82	482.21	2025-12-05 17:53:02.322574
1735	sensor_cilantro_1	20.83	73.19	62.43	1.96	6.49	1069.91	451.14	2025-12-05 17:53:02.3228
1736	sensor_cilantro_2	20.89	69.68	75.95	1.85	6.72	1013.08	450.91	2025-12-05 17:53:02.323074
1737	sensor_rabano_1	22.37	71.82	76.64	1.54	6.42	828.84	446.26	2025-12-05 17:53:12.334399
1738	sensor_rabano_2	20.29	70.55	60.56	1.84	6.64	852.37	483.89	2025-12-05 17:53:12.334879
1739	sensor_cilantro_1	19.64	76.28	70.70	1.59	6.59	967.43	464.70	2025-12-05 17:53:12.334959
1740	sensor_cilantro_2	22.54	63.96	61.28	1.87	6.48	1104.57	451.65	2025-12-05 17:53:12.335015
1741	sensor_rabano_1	22.86	70.54	69.39	1.67	6.50	1184.65	427.91	2025-12-05 17:53:22.346479
1742	sensor_rabano_2	21.93	69.74	76.66	1.81	6.66	922.67	471.51	2025-12-05 17:53:22.347234
1743	sensor_cilantro_1	19.36	72.79	76.70	1.42	6.46	934.11	480.56	2025-12-05 17:53:22.347426
1744	sensor_cilantro_2	19.59	69.04	66.57	1.59	6.45	1039.97	415.51	2025-12-05 17:53:22.347579
1745	sensor_rabano_1	23.95	57.25	66.55	1.82	6.65	1138.36	457.83	2025-12-05 17:53:32.358252
1746	sensor_rabano_2	23.63	61.86	71.43	1.85	6.48	1026.73	483.88	2025-12-05 17:53:32.359305
1747	sensor_cilantro_1	21.14	67.47	67.25	1.93	6.67	884.95	428.65	2025-12-05 17:53:32.359579
1748	sensor_cilantro_2	19.30	70.53	71.21	1.85	6.77	819.37	484.01	2025-12-05 17:53:32.359745
1749	sensor_rabano_1	21.75	65.67	71.66	1.61	6.65	961.84	426.04	2025-12-05 17:53:42.376984
1750	sensor_rabano_2	22.05	68.58	60.34	1.48	6.60	1194.75	452.63	2025-12-05 17:53:42.377742
1751	sensor_cilantro_1	21.16	70.56	66.02	1.82	6.48	1088.03	454.45	2025-12-05 17:53:42.377848
1752	sensor_cilantro_2	20.94	67.23	79.70	1.53	6.55	1055.48	412.10	2025-12-05 17:53:42.377908
1753	sensor_rabano_1	23.16	69.64	62.52	1.93	6.77	1111.55	457.57	2025-12-05 17:53:52.389378
1754	sensor_rabano_2	21.48	57.07	62.31	1.66	6.56	1123.47	499.82	2025-12-05 17:53:52.390523
1755	sensor_cilantro_1	21.38	76.87	72.59	1.85	6.44	811.88	461.67	2025-12-05 17:53:52.390707
1756	sensor_cilantro_2	22.84	68.25	77.30	1.71	6.76	1057.90	471.69	2025-12-05 17:53:52.390844
1757	sensor_rabano_1	20.65	64.00	73.01	1.98	6.66	1023.50	424.31	2025-12-05 17:54:02.402658
1758	sensor_rabano_2	21.54	61.46	74.22	1.58	6.42	918.16	488.33	2025-12-05 17:54:02.403431
1759	sensor_cilantro_1	21.49	70.02	73.88	1.47	6.54	1183.23	411.89	2025-12-05 17:54:02.403688
1760	sensor_cilantro_2	19.10	73.77	68.74	1.69	6.80	849.55	441.71	2025-12-05 17:54:02.403843
1761	sensor_rabano_1	21.10	63.93	67.95	1.71	6.58	1098.44	450.28	2025-12-05 17:54:12.415623
1762	sensor_rabano_2	23.05	57.84	64.92	1.72	6.59	1116.37	410.41	2025-12-05 17:54:12.416454
1763	sensor_cilantro_1	19.16	72.16	61.88	1.71	6.52	1072.07	459.87	2025-12-05 17:54:12.416623
1764	sensor_cilantro_2	22.08	71.03	74.66	1.92	6.54	1111.35	486.77	2025-12-05 17:54:12.416688
1765	sensor_rabano_1	20.53	65.01	60.33	1.97	6.63	870.38	463.60	2025-12-05 17:54:22.428494
1766	sensor_rabano_2	20.56	60.01	76.68	1.97	6.63	1188.21	413.23	2025-12-05 17:54:22.429031
1767	sensor_cilantro_1	19.86	72.31	63.13	1.54	6.49	1103.27	450.87	2025-12-05 17:54:22.429116
1768	sensor_cilantro_2	19.85	73.31	67.42	1.77	6.52	960.65	432.15	2025-12-05 17:54:22.429174
1769	sensor_rabano_1	22.32	60.22	76.38	1.55	6.64	1155.47	419.89	2025-12-05 17:54:32.437556
1770	sensor_rabano_2	22.87	64.63	61.65	1.81	6.46	1067.25	475.53	2025-12-05 17:54:32.438335
1771	sensor_cilantro_1	19.47	73.26	72.84	1.73	6.53	1139.80	433.81	2025-12-05 17:54:32.438434
1772	sensor_cilantro_2	22.82	71.40	72.45	1.95	6.43	859.78	421.94	2025-12-05 17:54:32.438499
1773	sensor_rabano_1	20.93	62.10	64.17	1.83	6.56	1170.96	464.88	2025-12-05 17:54:42.446787
1774	sensor_rabano_2	22.54	70.81	70.99	1.76	6.70	987.21	489.23	2025-12-05 17:54:42.447374
1775	sensor_cilantro_1	20.38	68.44	62.51	1.58	6.71	841.13	405.96	2025-12-05 17:54:42.447545
1776	sensor_cilantro_2	21.41	76.16	76.73	1.67	6.69	1068.88	425.95	2025-12-05 17:54:42.447626
1777	sensor_rabano_1	22.84	62.89	72.85	1.80	6.67	1030.92	427.66	2025-12-05 17:54:52.458252
1778	sensor_rabano_2	20.43	63.16	64.48	1.49	6.44	844.99	444.94	2025-12-05 17:54:52.459094
1779	sensor_cilantro_1	21.26	64.98	78.63	1.63	6.66	987.38	498.74	2025-12-05 17:54:52.459286
1780	sensor_cilantro_2	19.82	68.14	78.85	1.83	6.64	1177.42	486.93	2025-12-05 17:54:52.459432
1781	sensor_rabano_1	20.02	72.25	76.04	1.44	6.76	1111.53	401.24	2025-12-05 17:55:02.469007
1782	sensor_rabano_2	20.07	57.92	71.70	1.97	6.76	1199.00	407.95	2025-12-05 17:55:02.470112
1783	sensor_cilantro_1	21.46	66.47	78.94	1.58	6.58	906.73	480.48	2025-12-05 17:55:02.470476
1784	sensor_cilantro_2	22.49	77.09	67.13	1.92	6.54	1087.46	499.17	2025-12-05 17:55:02.470571
1785	sensor_rabano_1	23.64	61.22	72.71	1.71	6.55	1134.93	473.60	2025-12-05 17:55:12.481518
1786	sensor_rabano_2	23.67	57.16	67.92	1.44	6.69	916.16	410.79	2025-12-05 17:55:12.482024
1787	sensor_cilantro_1	20.57	64.64	74.55	1.63	6.76	1060.20	429.99	2025-12-05 17:55:12.482106
1788	sensor_cilantro_2	19.85	66.16	61.80	1.49	6.71	869.95	481.03	2025-12-05 17:55:12.482161
1789	sensor_rabano_1	20.30	58.41	67.65	1.48	6.54	1123.85	408.00	2025-12-05 17:55:22.494239
1790	sensor_rabano_2	23.39	72.63	69.66	1.91	6.65	1177.18	453.54	2025-12-05 17:55:22.495031
1791	sensor_cilantro_1	22.87	72.93	72.35	1.82	6.46	1025.60	492.77	2025-12-05 17:55:22.495222
1792	sensor_cilantro_2	21.00	76.58	72.13	1.52	6.50	887.19	435.92	2025-12-05 17:55:22.495364
1793	sensor_rabano_1	23.09	60.24	73.28	1.68	6.59	990.44	477.09	2025-12-05 17:55:32.50744
1794	sensor_rabano_2	21.92	72.40	73.45	1.79	6.76	922.06	423.47	2025-12-05 17:55:32.508224
1795	sensor_cilantro_1	19.19	75.97	79.59	1.90	6.43	1188.38	443.64	2025-12-05 17:55:32.50845
1796	sensor_cilantro_2	20.33	67.80	75.77	1.60	6.71	847.99	415.82	2025-12-05 17:55:32.508611
1797	sensor_rabano_1	21.89	64.66	72.62	1.71	6.51	1140.30	481.10	2025-12-05 17:55:42.520463
1798	sensor_rabano_2	21.72	67.45	77.12	1.79	6.65	977.40	443.59	2025-12-05 17:55:42.521335
1799	sensor_cilantro_1	22.52	70.09	72.45	1.62	6.73	892.75	462.34	2025-12-05 17:55:42.521565
1800	sensor_cilantro_2	22.05	64.46	79.55	1.73	6.65	889.02	448.38	2025-12-05 17:55:42.521728
1801	sensor_rabano_1	21.91	60.24	72.60	1.50	6.78	967.63	416.69	2025-12-05 17:55:52.533762
1802	sensor_rabano_2	22.88	58.26	71.87	1.66	6.70	1091.45	427.96	2025-12-05 17:55:52.535464
1803	sensor_cilantro_1	22.64	71.64	60.27	1.83	6.55	888.52	445.89	2025-12-05 17:55:52.53586
1804	sensor_cilantro_2	22.08	72.84	64.83	1.91	6.40	1036.62	430.96	2025-12-05 17:55:52.536023
1805	sensor_rabano_1	22.52	72.06	74.93	1.57	6.67	816.63	466.89	2025-12-05 17:56:02.544971
1806	sensor_rabano_2	20.83	67.78	73.64	1.99	6.73	1042.35	414.80	2025-12-05 17:56:02.545595
1807	sensor_cilantro_1	20.32	65.37	70.79	1.97	6.68	870.59	495.38	2025-12-05 17:56:02.545691
1808	sensor_cilantro_2	20.45	67.71	77.11	1.91	6.59	966.42	439.82	2025-12-05 17:56:02.545751
1809	sensor_rabano_1	20.58	59.19	71.55	1.93	6.74	1106.18	414.05	2025-12-05 17:56:12.557326
1810	sensor_rabano_2	22.85	57.04	69.41	1.53	6.78	1112.74	483.78	2025-12-05 17:56:12.558163
1811	sensor_cilantro_1	20.21	66.66	73.39	1.56	6.44	1044.04	402.41	2025-12-05 17:56:12.558392
1812	sensor_cilantro_2	22.02	72.95	60.62	1.62	6.43	1010.95	427.86	2025-12-05 17:56:12.558586
1813	sensor_rabano_1	22.81	66.64	72.52	1.57	6.65	939.10	449.71	2025-12-05 17:56:22.570675
1814	sensor_rabano_2	21.73	71.41	66.33	1.60	6.62	1000.89	447.58	2025-12-05 17:56:22.571512
1815	sensor_cilantro_1	22.48	73.10	72.34	1.64	6.70	1102.87	463.64	2025-12-05 17:56:22.5717
1816	sensor_cilantro_2	22.73	73.14	67.30	1.77	6.56	1052.14	416.32	2025-12-05 17:56:22.571846
1817	sensor_rabano_1	21.56	60.69	70.53	1.58	6.56	901.87	470.80	2025-12-05 17:56:32.582962
1818	sensor_rabano_2	23.87	72.73	77.42	1.58	6.42	1072.34	413.13	2025-12-05 17:56:32.583809
1819	sensor_cilantro_1	22.87	72.18	70.26	2.00	6.48	993.47	466.80	2025-12-05 17:56:32.584088
1820	sensor_cilantro_2	20.80	73.02	70.02	1.99	6.65	986.98	481.06	2025-12-05 17:56:32.584301
1821	sensor_rabano_1	22.67	61.28	62.94	1.92	6.77	848.91	479.12	2025-12-05 17:56:42.596192
1822	sensor_rabano_2	22.03	61.90	60.42	1.46	6.44	826.06	492.17	2025-12-05 17:56:42.597013
1823	sensor_cilantro_1	19.61	75.85	76.11	1.80	6.51	1049.03	498.52	2025-12-05 17:56:42.597219
1824	sensor_cilantro_2	22.95	62.41	70.92	1.97	6.65	1023.20	434.25	2025-12-05 17:56:42.597398
1825	sensor_rabano_1	21.31	67.57	72.84	1.89	6.49	1071.95	493.87	2025-12-05 17:56:52.607327
1826	sensor_rabano_2	21.93	69.19	65.64	1.99	6.56	1033.80	472.43	2025-12-05 17:56:52.607942
1827	sensor_cilantro_1	20.41	76.91	61.09	1.70	6.49	831.35	424.64	2025-12-05 17:56:52.608041
1828	sensor_cilantro_2	20.04	71.84	78.27	1.46	6.42	988.18	454.44	2025-12-05 17:56:52.608102
1829	sensor_rabano_1	22.23	66.87	63.14	1.45	6.69	805.04	476.43	2025-12-05 17:57:02.619091
1830	sensor_rabano_2	23.36	69.70	75.14	1.56	6.44	886.70	425.62	2025-12-05 17:57:02.619692
1831	sensor_cilantro_1	20.04	74.88	67.57	1.56	6.55	1017.68	414.27	2025-12-05 17:57:02.619773
1832	sensor_cilantro_2	19.29	68.35	73.34	1.66	6.52	1188.32	444.83	2025-12-05 17:57:02.619829
1833	sensor_rabano_1	22.35	72.44	65.48	1.51	6.59	1034.61	494.85	2025-12-05 17:57:12.629386
1834	sensor_rabano_2	20.70	63.28	73.39	1.73	6.69	1081.11	441.77	2025-12-05 17:57:12.630851
1835	sensor_cilantro_1	21.18	66.68	67.55	1.69	6.73	1199.45	455.65	2025-12-05 17:57:12.631237
1836	sensor_cilantro_2	22.98	75.44	62.07	1.58	6.48	855.12	484.22	2025-12-05 17:57:12.631742
1837	sensor_rabano_1	20.73	66.67	65.87	1.74	6.47	1015.03	435.15	2025-12-05 17:57:22.642103
1838	sensor_rabano_2	22.21	64.59	63.21	1.42	6.43	1154.26	400.58	2025-12-05 17:57:22.642769
1839	sensor_cilantro_1	21.03	77.27	77.21	1.62	6.80	883.59	407.57	2025-12-05 17:57:22.642944
1840	sensor_cilantro_2	19.39	74.90	69.74	1.95	6.64	1153.14	452.47	2025-12-05 17:57:22.643038
1841	sensor_rabano_1	21.57	62.61	74.59	1.40	6.50	881.94	465.44	2025-12-05 17:57:32.653675
1842	sensor_rabano_2	20.75	59.79	74.58	1.53	6.73	1143.40	401.04	2025-12-05 17:57:32.65448
1843	sensor_cilantro_1	22.61	73.59	60.01	1.70	6.54	1049.94	497.70	2025-12-05 17:57:32.654676
1844	sensor_cilantro_2	21.83	75.83	67.33	1.58	6.52	1177.06	498.72	2025-12-05 17:57:32.654824
1845	sensor_rabano_1	21.16	69.41	72.60	1.79	6.68	993.48	403.06	2025-12-05 17:57:42.667206
1846	sensor_rabano_2	21.60	68.98	66.27	1.75	6.44	1061.13	458.16	2025-12-05 17:57:42.667943
1847	sensor_cilantro_1	22.83	68.02	64.32	1.61	6.53	889.28	498.47	2025-12-05 17:57:42.668144
1848	sensor_cilantro_2	22.95	72.15	67.38	1.83	6.79	939.93	482.59	2025-12-05 17:57:42.668288
1849	sensor_rabano_1	22.59	66.60	74.29	1.58	6.41	830.91	476.78	2025-12-05 17:57:52.680312
1850	sensor_rabano_2	21.98	70.79	73.41	1.62	6.71	981.18	419.57	2025-12-05 17:57:52.681223
1851	sensor_cilantro_1	22.14	74.12	60.13	1.88	6.41	877.04	466.88	2025-12-05 17:57:52.681404
1852	sensor_cilantro_2	21.64	73.29	79.04	1.50	6.65	810.02	490.62	2025-12-05 17:57:52.681545
1853	sensor_rabano_1	23.47	65.26	66.82	1.60	6.49	827.98	458.65	2025-12-05 17:58:02.692646
1854	sensor_rabano_2	20.80	61.71	78.91	1.91	6.57	820.60	471.55	2025-12-05 17:58:02.693423
1855	sensor_cilantro_1	22.09	69.32	76.08	1.58	6.78	979.22	431.42	2025-12-05 17:58:02.693612
1856	sensor_cilantro_2	19.84	64.11	65.46	1.52	6.66	1080.98	422.88	2025-12-05 17:58:02.693678
1857	sensor_rabano_1	21.43	65.97	66.33	1.64	6.66	1159.07	450.83	2025-12-05 17:58:12.70505
1858	sensor_rabano_2	21.29	61.60	78.41	1.86	6.47	1157.84	457.40	2025-12-05 17:58:12.705907
1859	sensor_cilantro_1	19.42	73.16	70.28	1.73	6.68	887.54	422.38	2025-12-05 17:58:12.706185
1860	sensor_cilantro_2	19.84	69.87	69.05	1.72	6.58	995.83	406.47	2025-12-05 17:58:12.706337
1861	sensor_rabano_1	21.96	59.34	63.16	1.89	6.61	1028.55	402.93	2025-12-05 17:58:22.717059
1862	sensor_rabano_2	21.08	60.65	76.52	1.73	6.54	1188.38	490.39	2025-12-05 17:58:22.717843
1863	sensor_cilantro_1	22.00	63.35	77.74	1.89	6.67	1120.85	487.35	2025-12-05 17:58:22.718078
1864	sensor_cilantro_2	21.78	65.10	74.05	1.78	6.79	1040.75	462.15	2025-12-05 17:58:22.718247
1865	sensor_rabano_1	21.44	63.17	79.61	1.78	6.70	1054.73	430.06	2025-12-05 17:58:32.728469
1866	sensor_rabano_2	22.62	64.21	77.06	1.67	6.59	1103.56	481.47	2025-12-05 17:58:32.729396
1867	sensor_cilantro_1	20.91	73.31	67.28	1.54	6.55	819.52	459.57	2025-12-05 17:58:32.729574
1868	sensor_cilantro_2	19.41	64.83	73.06	1.80	6.66	1140.92	412.29	2025-12-05 17:58:32.729714
1869	sensor_rabano_1	23.74	64.66	76.33	1.54	6.56	894.02	491.37	2025-12-05 17:58:42.753305
1870	sensor_rabano_2	23.64	72.55	79.15	1.54	6.66	982.24	468.36	2025-12-05 17:58:42.754042
1871	sensor_cilantro_1	19.07	70.84	64.05	1.50	6.52	892.55	496.61	2025-12-05 17:58:42.754243
1872	sensor_cilantro_2	20.04	62.32	65.17	1.91	6.54	895.31	415.52	2025-12-05 17:58:42.754384
1873	sensor_rabano_1	20.19	69.87	62.80	1.49	6.76	980.10	456.64	2025-12-05 17:58:52.764063
1874	sensor_rabano_2	22.05	72.74	74.00	1.93	6.64	864.45	484.13	2025-12-05 17:58:52.764828
1875	sensor_cilantro_1	19.51	69.16	64.66	1.99	6.67	807.00	476.56	2025-12-05 17:58:52.764932
1876	sensor_cilantro_2	22.50	77.30	79.14	1.41	6.53	908.49	453.18	2025-12-05 17:58:52.764998
1877	sensor_rabano_1	23.01	71.54	70.55	1.47	6.61	1066.84	499.30	2025-12-05 17:59:02.774633
1878	sensor_rabano_2	21.45	65.02	61.76	1.53	6.70	929.38	421.34	2025-12-05 17:59:02.775486
1879	sensor_cilantro_1	22.50	75.30	66.70	1.41	6.78	1031.75	499.02	2025-12-05 17:59:02.775838
1880	sensor_cilantro_2	19.53	66.82	75.28	1.43	6.47	1123.81	466.46	2025-12-05 17:59:02.776226
1881	sensor_rabano_1	21.87	57.54	71.78	1.44	6.70	897.59	415.71	2025-12-05 17:59:12.787979
1882	sensor_rabano_2	20.72	57.08	61.37	1.80	6.44	1196.48	429.42	2025-12-05 17:59:12.789134
1883	sensor_cilantro_1	22.99	69.69	60.45	1.68	6.63	1162.66	488.75	2025-12-05 17:59:12.789372
1884	sensor_cilantro_2	21.63	75.76	66.03	1.46	6.45	889.04	408.43	2025-12-05 17:59:12.789574
1885	sensor_rabano_1	21.97	64.49	76.81	1.45	6.53	1192.53	453.63	2025-12-05 17:59:22.801721
1886	sensor_rabano_2	20.24	65.10	60.71	1.57	6.48	1112.20	479.40	2025-12-05 17:59:22.802392
1887	sensor_cilantro_1	21.09	68.61	68.84	1.98	6.45	1112.12	494.63	2025-12-05 17:59:22.802567
1888	sensor_cilantro_2	21.56	67.99	79.65	1.40	6.46	1090.19	415.28	2025-12-05 17:59:22.80265
1889	sensor_rabano_1	22.44	67.36	69.55	1.95	6.48	1116.70	496.91	2025-12-05 17:59:32.810483
1890	sensor_rabano_2	22.13	70.06	79.28	1.91	6.54	1112.97	464.21	2025-12-05 17:59:32.811025
1891	sensor_cilantro_1	20.17	66.89	79.08	1.97	6.46	986.23	401.16	2025-12-05 17:59:32.811112
1892	sensor_cilantro_2	20.21	76.06	78.06	1.69	6.75	1137.43	483.03	2025-12-05 17:59:32.811169
1893	sensor_rabano_1	23.01	66.91	60.58	1.73	6.44	875.02	437.29	2025-12-05 17:59:42.820781
1894	sensor_rabano_2	20.68	62.90	70.62	1.53	6.42	1184.69	477.74	2025-12-05 17:59:42.821604
1895	sensor_cilantro_1	22.57	73.13	62.07	1.60	6.43	1170.10	496.32	2025-12-05 17:59:42.821821
1896	sensor_cilantro_2	21.28	76.12	74.36	1.60	6.72	1184.76	475.30	2025-12-05 17:59:42.822012
1897	sensor_rabano_1	21.15	57.27	74.58	1.44	6.58	852.31	446.45	2025-12-05 17:59:52.833919
1898	sensor_rabano_2	23.35	57.37	62.87	1.91	6.58	1178.63	447.19	2025-12-05 17:59:52.834792
1899	sensor_cilantro_1	19.53	66.14	72.16	1.85	6.56	937.08	411.16	2025-12-05 17:59:52.83499
1900	sensor_cilantro_2	21.54	67.35	75.15	1.55	6.75	942.81	465.74	2025-12-05 17:59:52.835149
1901	sensor_rabano_1	20.07	69.67	69.86	1.46	6.61	1172.35	451.58	2025-12-05 18:00:02.844267
1902	sensor_rabano_2	22.15	57.97	60.41	2.00	6.70	1129.00	459.39	2025-12-05 18:00:02.845098
1903	sensor_cilantro_1	19.73	77.30	63.31	1.94	6.52	1050.56	491.27	2025-12-05 18:00:02.845335
1904	sensor_cilantro_2	19.28	67.33	65.48	1.63	6.53	954.40	460.48	2025-12-05 18:00:02.845531
1905	sensor_rabano_1	22.69	60.16	63.43	1.46	6.47	1150.98	473.58	2025-12-05 18:00:12.856626
1906	sensor_rabano_2	20.98	60.61	61.51	1.85	6.57	1057.90	489.69	2025-12-05 18:00:12.858034
1907	sensor_cilantro_1	20.04	62.53	63.75	1.69	6.78	843.28	484.06	2025-12-05 18:00:12.858363
1908	sensor_cilantro_2	21.77	73.26	66.80	1.43	6.65	853.83	464.38	2025-12-05 18:00:12.858634
1909	sensor_rabano_1	20.61	58.98	77.13	1.47	6.67	805.81	431.04	2025-12-05 18:00:22.869953
1910	sensor_rabano_2	23.27	68.90	61.16	1.88	6.64	924.39	429.16	2025-12-05 18:00:22.870772
1911	sensor_cilantro_1	22.16	75.90	61.11	1.75	6.44	1028.25	464.78	2025-12-05 18:00:22.870873
1912	sensor_cilantro_2	20.09	76.59	67.15	1.44	6.40	856.38	436.79	2025-12-05 18:00:22.870932
1913	sensor_rabano_1	22.10	69.70	62.08	1.56	6.65	933.18	452.79	2025-12-05 18:00:32.878952
1914	sensor_rabano_2	21.43	57.38	62.88	1.79	6.42	990.87	475.56	2025-12-05 18:00:32.879481
1915	sensor_cilantro_1	20.62	63.79	62.49	1.90	6.59	833.07	476.57	2025-12-05 18:00:32.879566
1916	sensor_cilantro_2	22.59	74.76	69.32	2.00	6.56	865.76	458.63	2025-12-05 18:00:32.879626
1917	sensor_rabano_1	20.04	72.05	70.16	1.55	6.59	869.70	459.96	2025-12-05 18:00:42.88908
1918	sensor_rabano_2	20.62	60.59	64.22	1.57	6.70	964.76	474.72	2025-12-05 18:00:42.890194
1919	sensor_cilantro_1	21.35	72.56	75.60	1.52	6.49	903.24	417.36	2025-12-05 18:00:42.890414
1920	sensor_cilantro_2	22.72	63.49	69.27	1.50	6.60	1194.29	432.35	2025-12-05 18:00:42.890497
1921	sensor_rabano_1	21.95	57.93	67.80	1.93	6.46	842.56	474.10	2025-12-05 18:00:52.899378
1922	sensor_rabano_2	20.35	72.11	75.66	1.68	6.76	928.95	488.02	2025-12-05 18:00:52.899983
1923	sensor_cilantro_1	22.76	64.27	74.71	1.99	6.47	1177.26	431.61	2025-12-05 18:00:52.900161
1924	sensor_cilantro_2	19.15	66.30	62.36	1.57	6.57	1082.26	496.84	2025-12-05 18:00:52.900243
1925	sensor_rabano_1	21.12	67.66	64.74	1.64	6.71	1044.65	402.02	2025-12-05 18:01:02.909874
1926	sensor_rabano_2	23.23	65.17	66.26	1.54	6.57	1176.13	408.06	2025-12-05 18:01:02.910403
1927	sensor_cilantro_1	19.46	66.75	67.96	1.61	6.44	841.56	478.64	2025-12-05 18:01:02.910484
1928	sensor_cilantro_2	21.56	69.91	63.74	1.65	6.40	1098.09	466.69	2025-12-05 18:01:02.910542
1929	sensor_rabano_1	22.57	67.51	68.05	1.92	6.63	969.38	404.74	2025-12-05 18:01:12.922361
1930	sensor_rabano_2	20.82	67.44	71.94	1.84	6.55	825.66	488.67	2025-12-05 18:01:12.923308
1931	sensor_cilantro_1	22.07	75.63	68.15	1.92	6.75	945.65	428.46	2025-12-05 18:01:12.923536
1932	sensor_cilantro_2	21.71	64.40	68.52	1.72	6.58	1093.30	488.95	2025-12-05 18:01:12.923695
1933	sensor_rabano_1	20.69	59.05	65.57	1.44	6.79	905.50	403.02	2025-12-05 18:01:22.933506
1934	sensor_rabano_2	21.52	68.23	64.90	1.62	6.62	1155.56	485.65	2025-12-05 18:01:22.934028
1935	sensor_cilantro_1	19.60	77.93	72.95	1.85	6.49	850.92	430.71	2025-12-05 18:01:22.934182
1936	sensor_cilantro_2	21.18	65.00	67.57	1.96	6.47	826.80	402.21	2025-12-05 18:01:22.934332
1937	sensor_rabano_1	21.87	64.03	78.15	1.76	6.73	824.86	402.82	2025-12-05 18:01:32.945455
1938	sensor_rabano_2	21.13	70.89	67.52	1.42	6.41	886.91	461.92	2025-12-05 18:01:32.946214
1939	sensor_cilantro_1	21.87	71.00	69.86	1.95	6.68	854.53	437.02	2025-12-05 18:01:32.946394
1940	sensor_cilantro_2	21.62	72.26	63.37	1.97	6.62	989.20	499.37	2025-12-05 18:01:32.946536
1941	sensor_rabano_1	23.11	57.54	77.90	1.63	6.76	868.77	456.86	2025-12-05 18:01:42.958586
1942	sensor_rabano_2	22.49	60.29	65.55	1.41	6.71	851.96	436.92	2025-12-05 18:01:42.9592
1943	sensor_cilantro_1	19.16	63.30	68.48	1.61	6.42	1012.18	468.01	2025-12-05 18:01:42.959312
1944	sensor_cilantro_2	20.72	69.90	68.30	1.57	6.46	1185.18	426.97	2025-12-05 18:01:42.959373
1945	sensor_rabano_1	21.99	64.42	68.30	1.85	6.40	917.25	467.48	2025-12-05 18:01:52.968487
1946	sensor_rabano_2	22.15	62.91	64.06	1.74	6.44	819.82	492.44	2025-12-05 18:01:52.969726
1947	sensor_cilantro_1	20.00	64.32	74.20	1.54	6.50	845.71	453.01	2025-12-05 18:01:52.970097
1948	sensor_cilantro_2	20.86	70.07	63.30	2.00	6.72	800.40	477.09	2025-12-05 18:01:52.970391
1949	sensor_rabano_1	21.77	62.51	67.37	1.58	6.79	947.17	407.33	2025-12-05 18:02:02.981022
1950	sensor_rabano_2	20.34	68.09	76.81	1.62	6.47	821.39	428.01	2025-12-05 18:02:02.98232
1951	sensor_cilantro_1	21.73	68.01	75.62	2.00	6.76	1099.95	426.59	2025-12-05 18:02:02.982603
1952	sensor_cilantro_2	22.27	74.25	60.28	1.53	6.71	875.14	441.31	2025-12-05 18:02:02.982876
1953	sensor_rabano_1	23.36	58.17	79.32	1.66	6.59	67.78	486.47	2025-12-05 19:00:44.277387
1954	sensor_rabano_2	23.23	61.05	63.36	1.81	6.67	103.86	482.57	2025-12-05 19:00:44.277995
1955	sensor_cilantro_1	20.82	64.43	73.03	1.74	6.65	112.01	493.94	2025-12-05 19:00:44.278099
1956	sensor_cilantro_2	20.31	65.41	77.40	1.89	6.73	170.86	436.21	2025-12-05 19:00:44.278155
1957	sensor_rabano_1	21.88	70.68	78.88	1.77	6.55	164.43	496.98	2025-12-05 19:00:54.303277
1958	sensor_rabano_2	23.24	57.23	60.90	1.83	6.73	186.08	488.68	2025-12-05 19:00:54.304733
1959	sensor_cilantro_1	22.03	62.55	72.67	1.54	6.45	108.97	437.41	2025-12-05 19:00:54.305154
1960	sensor_cilantro_2	19.63	62.15	60.90	1.71	6.74	195.59	469.05	2025-12-05 19:00:54.305449
1961	sensor_rabano_1	22.76	65.38	62.21	1.53	6.49	132.01	435.36	2025-12-05 19:01:04.315929
1962	sensor_rabano_2	20.14	57.85	67.11	1.58	6.48	83.12	441.52	2025-12-05 19:01:04.316564
1963	sensor_cilantro_1	21.33	65.51	61.87	1.83	6.76	104.45	424.05	2025-12-05 19:01:04.316744
1964	sensor_cilantro_2	21.32	72.39	72.53	1.94	6.46	123.20	425.22	2025-12-05 19:01:04.31681
1965	sensor_rabano_1	22.16	59.32	65.18	1.50	6.51	151.18	473.97	2025-12-05 19:01:14.32575
1966	sensor_rabano_2	23.40	62.03	75.01	1.82	6.54	70.88	424.02	2025-12-05 19:01:14.326343
1967	sensor_cilantro_1	19.01	65.67	76.73	1.64	6.73	146.90	479.24	2025-12-05 19:01:14.326513
1968	sensor_cilantro_2	20.50	66.96	68.74	1.46	6.63	118.67	427.66	2025-12-05 19:01:14.326601
1969	sensor_rabano_1	20.70	67.34	71.10	1.71	6.45	115.05	405.56	2025-12-05 19:01:24.335079
1970	sensor_rabano_2	20.84	60.23	60.83	1.77	6.79	140.99	463.72	2025-12-05 19:01:24.335615
1971	sensor_cilantro_1	21.03	69.74	71.83	1.80	6.60	54.38	495.11	2025-12-05 19:01:24.335706
1972	sensor_cilantro_2	21.60	66.17	63.28	1.49	6.53	128.25	468.13	2025-12-05 19:01:24.335763
1973	sensor_rabano_1	20.10	64.17	77.64	1.53	6.78	179.65	486.31	2025-12-05 19:01:34.34452
1974	sensor_rabano_2	22.16	69.45	65.69	1.52	6.47	92.93	420.97	2025-12-05 19:01:34.345101
1975	sensor_cilantro_1	22.64	76.56	76.50	1.52	6.69	129.19	466.98	2025-12-05 19:01:34.345198
1976	sensor_cilantro_2	21.51	72.06	73.93	1.48	6.57	95.33	403.61	2025-12-05 19:01:34.345258
1977	sensor_rabano_1	22.94	64.65	78.92	1.97	6.68	63.41	494.93	2025-12-05 19:01:44.35404
1978	sensor_rabano_2	20.04	71.70	77.93	1.69	6.46	189.56	449.02	2025-12-05 19:01:44.355331
1979	sensor_cilantro_1	19.28	74.24	72.36	1.45	6.40	179.94	421.76	2025-12-05 19:01:44.355525
1980	sensor_cilantro_2	19.75	62.58	65.85	1.89	6.50	92.08	458.63	2025-12-05 19:01:44.355609
1981	sensor_rabano_1	21.93	67.89	64.61	1.74	6.77	159.97	492.13	2025-12-05 19:01:54.365862
1982	sensor_rabano_2	23.05	61.49	69.27	1.77	6.76	124.08	411.36	2025-12-05 19:01:54.366691
1983	sensor_cilantro_1	20.95	70.20	66.40	1.42	6.68	148.40	440.15	2025-12-05 19:01:54.366916
1984	sensor_cilantro_2	19.71	66.72	74.65	1.97	6.46	160.47	406.85	2025-12-05 19:01:54.367078
1985	sensor_rabano_1	21.67	62.13	75.65	1.96	6.47	174.55	468.32	2025-12-05 19:02:04.378167
1986	sensor_rabano_2	20.48	69.30	62.16	1.99	6.66	195.88	470.57	2025-12-05 19:02:04.378856
1987	sensor_cilantro_1	22.18	77.94	66.52	1.43	6.72	190.34	403.50	2025-12-05 19:02:04.378967
1988	sensor_cilantro_2	22.28	72.14	60.14	1.72	6.44	170.79	485.20	2025-12-05 19:02:04.379029
1989	sensor_rabano_1	23.71	65.39	60.14	1.81	6.48	106.77	405.32	2025-12-05 19:02:14.389694
1990	sensor_rabano_2	20.60	67.12	77.11	1.67	6.58	183.34	489.78	2025-12-05 19:02:14.390593
1991	sensor_cilantro_1	22.14	63.22	61.09	1.56	6.70	55.36	457.72	2025-12-05 19:02:14.390834
1992	sensor_cilantro_2	22.22	65.60	62.85	1.87	6.74	176.22	469.13	2025-12-05 19:02:14.390986
1993	sensor_rabano_1	21.62	72.24	73.83	1.82	6.51	123.63	431.69	2025-12-05 19:02:24.402637
1994	sensor_rabano_2	23.25	70.87	69.34	1.84	6.56	189.87	443.41	2025-12-05 19:02:24.403613
1995	sensor_cilantro_1	20.77	70.61	71.36	1.53	6.47	102.42	466.71	2025-12-05 19:02:24.403904
1996	sensor_cilantro_2	20.82	65.88	72.37	1.86	6.58	88.65	430.04	2025-12-05 19:02:24.404105
1997	sensor_rabano_1	21.91	71.13	63.00	1.96	6.55	193.04	473.36	2025-12-05 19:02:28.798721
1998	sensor_rabano_2	21.80	66.45	63.92	1.65	6.59	123.19	460.00	2025-12-05 19:02:28.799589
1999	sensor_cilantro_1	21.95	75.55	79.93	1.91	6.54	73.83	465.80	2025-12-05 19:02:28.800042
2000	sensor_cilantro_2	22.81	69.38	76.43	1.97	6.75	55.76	485.15	2025-12-05 19:02:28.800588
2001	sensor_rabano_1	23.88	65.63	65.77	1.84	6.77	153.37	441.91	2025-12-05 19:02:38.808531
2002	sensor_rabano_2	20.47	68.36	68.93	1.66	6.67	57.28	455.12	2025-12-05 19:02:38.809119
2003	sensor_cilantro_1	20.39	66.12	69.06	1.46	6.72	153.90	474.09	2025-12-05 19:02:38.809201
2004	sensor_cilantro_2	21.50	72.23	79.89	1.99	6.48	147.94	446.26	2025-12-05 19:02:38.809257
2005	sensor_rabano_1	21.79	68.08	67.91	1.56	6.49	166.88	430.47	2025-12-05 19:02:48.819511
2006	sensor_rabano_2	23.98	71.53	78.85	1.96	6.71	153.89	474.14	2025-12-05 19:02:48.820098
2007	sensor_cilantro_1	22.01	73.64	66.08	1.60	6.61	98.00	451.18	2025-12-05 19:02:48.820239
2008	sensor_cilantro_2	20.87	63.28	61.22	1.61	6.48	127.68	401.72	2025-12-05 19:02:48.82034
2009	sensor_rabano_1	20.04	63.63	71.07	1.58	6.56	80.61	413.17	2025-12-05 19:02:58.829213
2010	sensor_rabano_2	23.20	69.28	62.66	1.95	6.40	190.42	421.74	2025-12-05 19:02:58.829722
2011	sensor_cilantro_1	20.39	66.85	78.41	1.94	6.73	61.74	464.69	2025-12-05 19:02:58.829803
2012	sensor_cilantro_2	20.84	77.72	76.32	1.71	6.43	84.69	488.70	2025-12-05 19:02:58.829859
2013	sensor_rabano_1	20.50	61.70	63.73	1.41	6.77	136.63	428.37	2025-12-05 19:03:08.841177
2014	sensor_rabano_2	22.24	66.78	78.55	1.58	6.61	72.65	483.71	2025-12-05 19:03:08.841921
2015	sensor_cilantro_1	21.00	68.95	61.09	1.76	6.44	191.60	499.56	2025-12-05 19:03:08.842099
2016	sensor_cilantro_2	20.24	69.42	66.61	1.57	6.78	100.64	437.12	2025-12-05 19:03:08.842239
2017	sensor_rabano_1	21.60	69.23	70.40	1.99	6.56	56.38	491.18	2025-12-05 19:03:18.853451
2018	sensor_rabano_2	22.78	70.73	77.31	1.71	6.57	129.62	469.25	2025-12-05 19:03:18.854288
2019	sensor_cilantro_1	20.18	68.27	76.03	1.72	6.76	62.96	447.98	2025-12-05 19:03:18.854575
2020	sensor_cilantro_2	21.44	75.07	63.48	1.90	6.65	53.51	417.56	2025-12-05 19:03:18.854776
2021	sensor_rabano_1	22.58	61.11	67.84	1.56	6.40	64.51	461.81	2025-12-05 19:03:28.863534
2022	sensor_rabano_2	21.22	58.67	77.60	1.95	6.78	52.55	471.05	2025-12-05 19:03:28.864656
2023	sensor_cilantro_1	21.73	62.64	64.72	1.76	6.49	192.53	465.42	2025-12-05 19:03:28.865043
2024	sensor_cilantro_2	20.66	68.95	70.23	1.67	6.44	105.55	438.90	2025-12-05 19:03:28.865313
2025	sensor_rabano_1	21.58	61.26	77.64	1.74	6.41	147.95	448.53	2025-12-05 19:03:38.877198
2026	sensor_rabano_2	21.87	66.16	64.23	1.90	6.54	131.36	477.87	2025-12-05 19:03:38.878033
2027	sensor_cilantro_1	20.71	66.42	76.29	1.80	6.67	117.73	440.71	2025-12-05 19:03:38.878336
2028	sensor_cilantro_2	20.60	70.42	67.71	1.58	6.56	165.55	485.34	2025-12-05 19:03:38.878589
2029	sensor_rabano_1	20.18	69.13	73.08	1.70	6.80	83.74	474.51	2025-12-05 19:03:48.888975
2030	sensor_rabano_2	23.40	59.87	64.50	1.97	6.78	81.64	442.67	2025-12-05 19:03:48.889491
2031	sensor_cilantro_1	19.81	62.86	76.92	1.91	6.70	81.02	496.36	2025-12-05 19:03:48.889586
2032	sensor_cilantro_2	20.61	68.65	76.17	1.86	6.65	90.11	401.54	2025-12-05 19:03:48.889642
2033	sensor_rabano_1	23.11	68.86	61.24	1.74	6.70	117.96	452.27	2025-12-05 19:03:58.90191
2034	sensor_rabano_2	22.07	59.71	66.20	1.87	6.47	121.14	439.82	2025-12-05 19:03:58.902716
2035	sensor_cilantro_1	21.58	64.62	67.01	1.82	6.42	75.84	407.79	2025-12-05 19:03:58.9029
2036	sensor_cilantro_2	19.08	67.33	66.70	1.72	6.76	57.58	470.57	2025-12-05 19:03:58.903048
2037	sensor_rabano_1	20.40	61.00	75.79	1.41	6.71	196.70	436.14	2025-12-05 19:04:08.914763
2038	sensor_rabano_2	20.60	58.92	69.41	1.92	6.55	191.02	426.57	2025-12-05 19:04:08.915911
2039	sensor_cilantro_1	20.69	71.04	75.88	1.71	6.54	192.06	446.50	2025-12-05 19:04:08.916165
2040	sensor_cilantro_2	20.82	67.30	77.98	1.99	6.49	181.55	469.79	2025-12-05 19:04:08.916318
2041	sensor_rabano_1	22.66	63.19	78.31	1.81	6.75	105.94	461.80	2025-12-05 19:04:18.927013
2042	sensor_rabano_2	23.68	72.57	77.35	1.91	6.63	144.05	435.04	2025-12-05 19:04:18.927967
2043	sensor_cilantro_1	19.28	62.98	73.03	1.41	6.45	100.23	455.07	2025-12-05 19:04:18.928157
2044	sensor_cilantro_2	19.16	64.26	78.71	1.90	6.56	50.22	400.19	2025-12-05 19:04:18.928307
2045	sensor_rabano_1	21.75	68.63	64.89	1.58	6.77	185.78	456.87	2025-12-05 19:04:28.939973
2046	sensor_rabano_2	22.27	57.19	60.05	1.59	6.49	156.16	488.39	2025-12-05 19:04:28.940608
2047	sensor_cilantro_1	22.65	68.54	73.83	1.92	6.51	196.05	400.83	2025-12-05 19:04:28.940796
2048	sensor_cilantro_2	20.07	76.29	78.44	1.95	6.51	129.52	455.78	2025-12-05 19:04:28.940879
2049	sensor_rabano_1	23.22	68.54	61.66	1.61	6.53	65.27	412.18	2025-12-05 19:04:38.952337
2050	sensor_rabano_2	23.63	69.34	60.66	1.96	6.66	117.71	441.29	2025-12-05 19:04:38.952874
2051	sensor_cilantro_1	20.72	63.41	67.59	1.87	6.71	160.35	425.84	2025-12-05 19:04:38.952962
2052	sensor_cilantro_2	22.36	74.14	70.70	1.71	6.62	86.00	404.43	2025-12-05 19:04:38.953019
2053	sensor_rabano_1	21.54	62.04	71.05	1.75	6.44	140.10	452.98	2025-12-05 19:04:48.964943
2054	sensor_rabano_2	21.68	59.17	78.50	1.50	6.77	165.25	411.46	2025-12-05 19:04:48.965871
2055	sensor_cilantro_1	21.74	68.39	75.16	1.65	6.41	103.67	490.30	2025-12-05 19:04:48.966101
2056	sensor_cilantro_2	19.67	76.13	60.46	1.58	6.67	159.31	493.53	2025-12-05 19:04:48.966281
2057	sensor_rabano_1	21.13	67.65	69.32	1.44	6.67	87.59	492.28	2025-12-09 21:11:36.560931
2058	sensor_rabano_2	23.92	72.16	71.13	1.79	6.70	110.65	483.53	2025-12-09 21:11:36.575612
2059	sensor_cilantro_1	20.96	77.02	71.51	1.66	6.48	132.21	445.85	2025-12-09 21:11:36.576771
2060	sensor_cilantro_2	19.58	66.79	79.21	1.53	6.56	108.86	420.50	2025-12-09 21:11:36.578235
2061	sensor_rabano_1	21.20	69.51	75.96	1.50	6.59	126.41	480.91	2025-12-09 21:11:46.601731
2062	sensor_rabano_2	22.50	58.40	71.64	1.95	6.40	187.00	413.56	2025-12-09 21:11:46.603379
2063	sensor_cilantro_1	21.80	67.06	60.01	1.87	6.70	171.82	471.65	2025-12-09 21:11:46.60382
2064	sensor_cilantro_2	19.15	71.28	65.62	1.83	6.62	70.91	442.10	2025-12-09 21:11:46.604051
2065	sensor_rabano_1	22.94	57.51	67.63	1.65	6.54	149.56	436.90	2025-12-09 21:11:56.63025
2066	sensor_rabano_2	23.27	63.77	78.11	1.87	6.62	79.23	476.93	2025-12-09 21:11:56.632765
2067	sensor_cilantro_1	20.64	67.15	64.22	1.94	6.47	194.75	423.44	2025-12-09 21:11:56.633303
2068	sensor_cilantro_2	20.47	71.23	75.53	1.49	6.69	149.47	449.08	2025-12-09 21:11:56.633706
2069	sensor_rabano_1	23.93	58.78	72.34	1.46	6.73	92.94	431.05	2025-12-09 21:12:06.660036
2070	sensor_rabano_2	22.99	59.93	63.15	1.53	6.63	94.62	417.88	2025-12-09 21:12:06.662001
2071	sensor_cilantro_1	20.62	68.93	78.44	1.88	6.68	113.82	442.34	2025-12-09 21:12:06.662586
2072	sensor_cilantro_2	22.68	75.15	65.11	1.55	6.48	101.62	457.64	2025-12-09 21:12:06.663144
2073	sensor_rabano_1	23.76	59.27	78.40	1.86	6.41	121.34	416.67	2025-12-09 21:12:16.684325
2074	sensor_rabano_2	22.04	62.57	73.67	1.98	6.65	75.38	450.40	2025-12-09 21:12:16.685759
2075	sensor_cilantro_1	20.50	62.98	74.37	1.45	6.80	146.72	433.58	2025-12-09 21:12:16.686089
2076	sensor_cilantro_2	19.25	76.03	79.66	1.98	6.78	117.58	430.60	2025-12-09 21:12:16.686271
2077	sensor_rabano_1	22.03	67.21	70.20	1.94	6.58	150.55	441.12	2025-12-09 21:12:26.698879
2078	sensor_rabano_2	21.22	66.04	78.10	1.78	6.62	175.33	474.70	2025-12-09 21:12:26.699794
2079	sensor_cilantro_1	21.49	74.19	63.87	1.50	6.54	82.23	465.97	2025-12-09 21:12:26.700025
2080	sensor_cilantro_2	22.66	73.58	67.68	1.67	6.74	65.35	477.46	2025-12-09 21:12:26.70019
2081	sensor_rabano_1	22.15	57.94	69.46	1.45	6.56	62.79	433.61	2025-12-09 21:12:36.724302
2082	sensor_rabano_2	21.90	72.80	61.41	1.56	6.64	62.52	481.89	2025-12-09 21:12:36.725838
2083	sensor_cilantro_1	22.01	74.69	73.49	1.54	6.48	67.15	402.56	2025-12-09 21:12:36.72618
2084	sensor_cilantro_2	20.93	62.10	65.90	1.49	6.62	64.96	415.29	2025-12-09 21:12:36.726454
2085	sensor_rabano_1	23.43	69.54	73.39	1.79	6.76	198.65	443.65	2025-12-09 21:12:46.751243
2086	sensor_rabano_2	21.07	67.33	60.56	1.52	6.75	181.97	426.19	2025-12-09 21:12:46.753081
2087	sensor_cilantro_1	22.45	71.41	75.76	1.56	6.79	164.08	409.56	2025-12-09 21:12:46.753403
2088	sensor_cilantro_2	21.79	65.10	61.74	1.48	6.48	194.21	487.12	2025-12-09 21:12:46.753679
2089	sensor_rabano_1	21.34	58.49	62.55	1.99	6.63	62.73	432.41	2025-12-09 21:12:56.778058
2090	sensor_rabano_2	22.55	59.90	79.38	1.92	6.57	161.50	491.51	2025-12-09 21:12:56.779494
2091	sensor_cilantro_1	21.98	65.17	79.11	1.81	6.73	68.21	434.25	2025-12-09 21:12:56.779955
2092	sensor_cilantro_2	22.58	74.90	69.65	1.95	6.72	153.66	429.86	2025-12-09 21:12:56.780251
2093	sensor_rabano_1	23.05	63.48	75.32	1.82	6.52	100.50	410.09	2025-12-09 21:13:06.806117
2094	sensor_rabano_2	21.07	62.32	62.02	1.59	6.49	157.02	429.84	2025-12-09 21:13:06.807671
2095	sensor_cilantro_1	21.24	76.24	75.05	1.77	6.44	132.40	488.29	2025-12-09 21:13:06.807864
2096	sensor_cilantro_2	22.08	67.25	66.05	1.46	6.47	184.51	457.27	2025-12-09 21:13:06.807995
2097	sensor_rabano_1	21.59	62.71	74.53	1.47	6.70	167.76	455.05	2025-12-09 21:13:16.845391
2098	sensor_rabano_2	22.06	63.61	67.34	1.70	6.43	176.33	451.90	2025-12-09 21:13:16.849361
2099	sensor_cilantro_1	22.50	69.98	78.81	1.68	6.45	91.10	422.94	2025-12-09 21:13:16.850329
2100	sensor_cilantro_2	19.54	68.20	73.17	2.00	6.55	173.01	464.60	2025-12-09 21:13:16.851122
2101	sensor_rabano_1	23.11	64.68	68.50	1.90	6.64	83.99	405.51	2025-12-09 21:55:43.530003
2102	sensor_rabano_2	23.59	70.03	65.29	1.52	6.74	53.07	424.41	2025-12-09 21:55:43.557083
2103	sensor_cilantro_1	19.48	67.37	74.59	1.58	6.59	180.93	498.41	2025-12-09 21:55:43.557479
2104	sensor_cilantro_2	21.58	74.29	64.08	1.79	6.69	89.68	487.27	2025-12-09 21:55:43.557694
2105	sensor_rabano_1	21.48	59.52	78.83	1.73	6.44	175.22	412.14	2025-12-09 21:55:53.571504
2106	sensor_rabano_2	22.09	64.12	61.14	1.49	6.60	90.45	435.79	2025-12-09 21:55:53.572255
2107	sensor_cilantro_1	21.25	75.98	79.96	1.54	6.41	162.72	486.06	2025-12-09 21:55:53.57242
2108	sensor_cilantro_2	21.95	76.26	77.94	1.44	6.57	119.78	480.20	2025-12-09 21:55:53.572513
2134	sensor_rabano_1	23.23	67.69	60.67	1.40	6.47	101.62	451.45	2025-12-09 21:58:34.98303
2135	sensor_rabano_2	23.40	58.72	69.37	1.45	6.56	92.81	458.28	2025-12-09 21:58:34.989674
2136	sensor_cilantro_1	19.05	74.81	65.78	1.46	6.58	161.98	478.81	2025-12-09 21:58:34.990018
2137	sensor_cilantro_2	21.00	67.26	78.88	1.67	6.50	158.63	486.68	2025-12-09 21:58:34.99054
2138	sensor_rabano_1	23.50	71.02	75.98	1.43	6.61	163.14	431.11	2025-12-09 21:58:45.001313
2139	sensor_rabano_2	21.07	69.53	60.33	1.67	6.48	90.37	408.44	2025-12-09 21:58:45.002095
2140	sensor_cilantro_1	20.41	73.53	72.25	1.90	6.44	68.57	400.81	2025-12-09 21:58:45.002287
2141	sensor_cilantro_2	20.36	64.76	62.61	1.97	6.46	164.75	439.94	2025-12-09 21:58:45.00244
2142	sensor_rabano_1	23.07	66.69	74.61	1.83	6.65	162.72	450.99	2025-12-09 21:58:55.013091
2143	sensor_rabano_2	21.93	73.00	75.36	1.48	6.59	148.28	458.11	2025-12-09 21:58:55.01399
2144	sensor_cilantro_1	21.28	65.75	69.42	1.49	6.46	181.36	468.46	2025-12-09 21:58:55.014188
2145	sensor_cilantro_2	21.15	77.40	65.31	1.65	6.74	155.20	441.40	2025-12-09 21:58:55.014333
2146	sensor_rabano_1	23.40	70.23	63.47	1.48	6.43	81.13	464.58	2025-12-09 21:59:05.026757
2147	sensor_rabano_2	23.63	65.22	73.98	1.66	6.49	158.79	426.25	2025-12-09 21:59:05.029064
2148	sensor_cilantro_1	19.20	77.57	64.84	1.64	6.75	88.92	486.80	2025-12-09 21:59:05.029401
2149	sensor_cilantro_2	19.86	71.35	73.86	1.75	6.76	196.82	459.45	2025-12-09 21:59:05.029581
2150	sensor_rabano_1	22.34	64.48	76.16	1.85	6.71	105.29	428.84	2025-12-09 21:59:15.041167
2151	sensor_rabano_2	21.15	67.20	79.97	1.53	6.62	193.08	467.05	2025-12-09 21:59:15.041876
2152	sensor_cilantro_1	22.04	74.32	62.98	1.42	6.77	194.44	454.43	2025-12-09 21:59:15.042135
2153	sensor_cilantro_2	19.88	75.52	74.56	1.44	6.64	108.63	455.71	2025-12-09 21:59:15.042293
2154	sensor_rabano_1	23.97	71.48	74.30	1.75	6.76	172.56	439.11	2025-12-09 21:59:25.053961
2155	sensor_rabano_2	20.69	66.94	70.21	1.40	6.56	142.16	482.08	2025-12-09 21:59:25.054816
2156	sensor_cilantro_1	19.73	76.37	62.97	1.49	6.42	57.84	409.86	2025-12-09 21:59:25.055068
2157	sensor_cilantro_2	22.34	71.60	71.91	1.67	6.68	170.79	488.75	2025-12-09 21:59:25.055217
2158	sensor_rabano_1	21.85	68.99	76.03	1.84	6.79	51.08	496.59	2025-12-09 21:59:35.066887
2159	sensor_rabano_2	22.71	68.36	68.38	1.54	6.49	180.74	425.17	2025-12-09 21:59:35.067717
2160	sensor_cilantro_1	21.25	68.31	73.24	1.49	6.62	68.17	498.01	2025-12-09 21:59:35.067923
2161	sensor_cilantro_2	22.83	77.13	77.38	1.45	6.76	54.58	459.84	2025-12-09 21:59:35.068071
2162	sensor_rabano_1	20.47	59.44	73.00	1.55	6.50	186.53	479.36	2025-12-09 21:59:45.079844
2163	sensor_rabano_2	21.50	65.94	75.49	1.84	6.42	53.24	449.39	2025-12-09 21:59:45.080655
2164	sensor_cilantro_1	22.25	67.83	79.27	1.48	6.53	146.81	419.71	2025-12-09 21:59:45.080887
2165	sensor_cilantro_2	19.08	72.70	64.95	1.78	6.76	167.58	435.32	2025-12-09 21:59:45.081045
2166	sensor_rabano_1	21.93	71.16	73.81	1.51	6.71	162.25	471.48	2025-12-09 21:59:55.091104
2167	sensor_rabano_2	23.61	60.11	75.45	1.41	6.62	51.24	426.50	2025-12-09 21:59:55.091934
2168	sensor_cilantro_1	21.00	66.75	60.13	1.46	6.56	150.30	467.61	2025-12-09 21:59:55.092163
2169	sensor_cilantro_2	22.85	66.04	63.18	1.92	6.48	91.77	403.21	2025-12-09 21:59:55.09231
2170	sensor_rabano_1	21.21	57.34	79.30	1.44	6.66	148.83	497.20	2025-12-09 22:00:05.104556
2171	sensor_rabano_2	20.40	71.45	73.49	1.94	6.59	57.86	454.59	2025-12-09 22:00:05.105389
2172	sensor_cilantro_1	19.57	64.23	75.75	1.79	6.52	106.55	460.59	2025-12-09 22:00:05.105633
2173	sensor_cilantro_2	22.01	77.99	79.89	1.52	6.59	74.60	464.15	2025-12-09 22:00:05.105856
2174	sensor_rabano_1	23.77	60.21	74.00	1.62	6.40	141.91	413.73	2025-12-09 22:00:15.117629
2175	sensor_rabano_2	20.98	69.78	72.12	1.40	6.69	116.97	408.09	2025-12-09 22:00:15.118555
2176	sensor_cilantro_1	19.06	62.10	67.79	1.56	6.67	158.21	489.68	2025-12-09 22:00:15.118805
2177	sensor_cilantro_2	21.66	76.16	67.57	1.76	6.62	112.94	422.90	2025-12-09 22:00:15.11897
2178	sensor_rabano_1	23.35	68.93	69.40	1.96	6.80	99.78	499.30	2025-12-09 22:00:25.130228
2179	sensor_rabano_2	22.85	60.33	65.46	1.98	6.56	84.45	461.13	2025-12-09 22:00:25.13105
2180	sensor_cilantro_1	20.51	71.77	67.10	1.64	6.54	113.19	415.97	2025-12-09 22:00:25.131241
2181	sensor_cilantro_2	22.05	71.30	61.32	1.78	6.42	147.56	456.20	2025-12-09 22:00:25.131387
2182	sensor_rabano_1	22.86	65.16	62.46	1.50	6.53	150.46	491.44	2025-12-09 22:00:35.141011
2183	sensor_rabano_2	21.55	72.54	68.12	1.97	6.70	183.74	464.71	2025-12-09 22:00:35.141874
2184	sensor_cilantro_1	19.29	68.04	62.86	1.49	6.46	83.31	433.56	2025-12-09 22:00:35.14224
2185	sensor_cilantro_2	21.06	68.41	76.49	1.62	6.63	181.10	474.64	2025-12-09 22:00:35.142493
2186	sensor_rabano_1	21.25	65.33	68.07	1.52	6.46	133.54	412.31	2025-12-09 22:00:45.154022
2187	sensor_rabano_2	23.92	71.09	78.59	1.90	6.46	122.26	472.79	2025-12-09 22:00:45.15476
2188	sensor_cilantro_1	20.50	77.59	60.11	1.90	6.71	102.91	409.34	2025-12-09 22:00:45.154866
2189	sensor_cilantro_2	19.46	77.97	67.54	1.53	6.47	111.47	442.08	2025-12-09 22:00:45.154922
2190	sensor_rabano_1	23.42	61.61	78.79	1.71	6.64	122.79	479.64	2025-12-09 22:00:55.165216
2191	sensor_rabano_2	23.97	62.49	69.27	1.64	6.75	150.26	469.25	2025-12-09 22:00:55.165785
2192	sensor_cilantro_1	20.16	77.52	71.63	1.55	6.46	94.36	423.68	2025-12-09 22:00:55.165874
2193	sensor_cilantro_2	21.29	67.86	69.82	1.93	6.58	192.88	477.21	2025-12-09 22:00:55.16593
2194	sensor_rabano_1	22.97	71.50	67.58	1.88	6.77	130.29	435.13	2025-12-09 22:01:05.176482
2195	sensor_rabano_2	21.65	58.54	78.69	1.73	6.50	137.13	497.37	2025-12-09 22:01:05.177164
2196	sensor_cilantro_1	22.87	74.76	63.37	2.00	6.42	129.14	484.39	2025-12-09 22:01:05.177271
2197	sensor_cilantro_2	21.88	65.20	66.85	1.41	6.48	182.31	455.43	2025-12-09 22:01:05.177331
2198	sensor_rabano_1	23.98	68.56	60.40	1.93	6.69	159.92	406.44	2025-12-09 22:01:15.189749
2199	sensor_rabano_2	20.08	60.27	76.60	1.84	6.47	141.87	410.47	2025-12-09 22:01:15.190616
2200	sensor_cilantro_1	22.45	74.88	78.05	2.00	6.48	111.56	412.74	2025-12-09 22:01:15.190902
2201	sensor_cilantro_2	22.30	73.24	72.79	1.50	6.56	140.75	496.77	2025-12-09 22:01:15.19106
2202	sensor_rabano_1	22.25	62.88	76.76	1.92	6.72	66.21	473.78	2025-12-09 22:01:25.203406
2203	sensor_rabano_2	22.76	71.10	60.53	1.80	6.72	130.07	400.12	2025-12-09 22:01:25.204135
2204	sensor_cilantro_1	21.82	69.82	74.72	1.80	6.50	87.09	454.68	2025-12-09 22:01:25.204324
2205	sensor_cilantro_2	19.69	67.98	73.87	1.83	6.66	50.74	480.45	2025-12-09 22:01:25.204388
2206	sensor_rabano_1	23.42	62.51	67.86	1.93	6.42	105.74	496.38	2025-12-09 22:01:35.216136
2207	sensor_rabano_2	20.97	59.79	73.16	1.53	6.60	116.93	458.80	2025-12-09 22:01:35.216939
2208	sensor_cilantro_1	20.97	74.16	61.81	1.97	6.46	96.99	445.85	2025-12-09 22:01:35.217123
2209	sensor_cilantro_2	20.17	76.32	70.53	1.65	6.52	77.33	445.41	2025-12-09 22:01:35.217187
2210	sensor_rabano_1	20.79	58.42	77.98	1.51	6.77	119.31	493.06	2025-12-09 22:01:45.229042
2211	sensor_rabano_2	23.61	64.33	73.44	1.44	6.43	60.71	494.52	2025-12-09 22:01:45.229998
2212	sensor_cilantro_1	19.06	76.86	73.70	1.58	6.58	150.75	423.50	2025-12-09 22:01:45.23019
2213	sensor_cilantro_2	19.65	70.75	61.74	1.88	6.70	151.38	408.59	2025-12-09 22:01:45.230335
2214	sensor_rabano_1	22.48	71.03	67.92	1.70	6.53	83.72	441.45	2025-12-09 22:01:55.240361
2215	sensor_rabano_2	23.82	58.08	63.92	1.64	6.61	91.56	477.55	2025-12-09 22:01:55.24116
2216	sensor_cilantro_1	22.60	68.25	71.31	1.47	6.50	70.31	438.18	2025-12-09 22:01:55.241345
2217	sensor_cilantro_2	21.09	71.79	70.77	1.90	6.42	165.81	475.32	2025-12-09 22:01:55.241494
2218	sensor_rabano_1	22.40	58.01	67.21	1.87	6.79	124.61	480.19	2025-12-09 22:02:05.253127
2219	sensor_rabano_2	21.94	67.94	79.65	1.85	6.51	113.09	496.08	2025-12-09 22:02:05.253646
2220	sensor_cilantro_1	20.60	76.81	76.08	1.43	6.66	123.88	469.71	2025-12-09 22:02:05.253845
2221	sensor_cilantro_2	19.17	74.58	73.04	1.46	6.53	81.56	494.66	2025-12-09 22:02:05.25402
2222	sensor_rabano_1	21.06	57.16	71.01	1.71	6.46	184.04	420.47	2025-12-09 22:02:15.264147
2223	sensor_rabano_2	21.49	61.72	60.41	1.49	6.78	52.12	418.02	2025-12-09 22:02:15.264931
2224	sensor_cilantro_1	19.05	71.64	74.53	1.67	6.69	186.90	498.12	2025-12-09 22:02:15.265107
2225	sensor_cilantro_2	21.04	67.27	76.90	1.56	6.56	160.25	462.87	2025-12-09 22:02:15.265247
2226	sensor_rabano_1	22.74	70.79	78.65	1.47	6.73	134.43	430.81	2025-12-09 22:02:25.277262
2227	sensor_rabano_2	20.03	57.76	66.02	1.69	6.45	127.97	425.94	2025-12-09 22:02:25.278954
2228	sensor_cilantro_1	22.84	63.77	74.30	1.75	6.74	71.92	459.55	2025-12-09 22:02:25.279469
2229	sensor_cilantro_2	21.43	65.49	64.63	1.43	6.59	198.55	478.77	2025-12-09 22:02:25.279702
2230	sensor_rabano_1	23.00	70.50	66.10	1.45	6.79	88.91	405.23	2025-12-09 22:02:35.290376
2231	sensor_rabano_2	23.24	61.79	79.96	1.92	6.50	129.12	475.03	2025-12-09 22:02:35.2913
2232	sensor_cilantro_1	20.39	70.52	71.42	1.83	6.67	103.63	418.14	2025-12-09 22:02:35.291526
2233	sensor_cilantro_2	20.48	68.00	72.68	1.52	6.59	81.67	479.56	2025-12-09 22:02:35.291728
2234	sensor_rabano_1	22.53	66.75	60.09	1.96	6.46	178.86	484.39	2025-12-09 22:02:45.304196
2235	sensor_rabano_2	20.78	67.31	70.75	1.82	6.49	158.14	410.40	2025-12-09 22:02:45.305027
2236	sensor_cilantro_1	23.00	65.85	76.80	1.78	6.63	66.11	442.57	2025-12-09 22:02:45.305253
2237	sensor_cilantro_2	19.39	64.41	61.55	1.92	6.56	178.25	439.28	2025-12-09 22:02:45.30541
2238	sensor_rabano_1	20.62	59.53	61.39	1.52	6.66	51.22	464.49	2025-12-09 22:02:55.316307
2239	sensor_rabano_2	20.02	72.35	62.36	1.95	6.71	96.07	404.90	2025-12-09 22:02:55.317196
2240	sensor_cilantro_1	21.33	73.17	72.49	1.77	6.63	135.30	445.63	2025-12-09 22:02:55.317383
2241	sensor_cilantro_2	19.19	65.18	69.33	1.56	6.55	66.55	415.77	2025-12-09 22:02:55.317532
2242	sensor_rabano_1	23.21	70.98	70.51	1.91	6.46	50.42	411.48	2025-12-09 22:03:05.32872
2243	sensor_rabano_2	22.40	62.50	70.43	1.57	6.58	98.35	485.87	2025-12-09 22:03:05.329501
2244	sensor_cilantro_1	19.29	74.10	61.34	1.70	6.55	59.37	499.05	2025-12-09 22:03:05.329862
2245	sensor_cilantro_2	19.31	74.94	61.97	1.57	6.73	181.70	400.81	2025-12-09 22:03:05.330136
2246	sensor_rabano_1	20.81	59.77	74.59	2.00	6.47	93.41	458.07	2025-12-09 22:03:15.34062
2247	sensor_rabano_2	21.37	61.88	73.07	1.90	6.66	174.10	492.12	2025-12-09 22:03:15.341474
2248	sensor_cilantro_1	20.94	69.22	66.22	1.42	6.78	89.01	459.96	2025-12-09 22:03:15.341663
2249	sensor_cilantro_2	21.10	73.47	69.36	1.84	6.67	197.57	448.42	2025-12-09 22:03:15.342106
2250	sensor_rabano_1	22.92	71.12	65.65	1.52	6.62	83.55	431.91	2025-12-09 22:03:25.354215
2251	sensor_rabano_2	21.65	63.58	60.69	1.53	6.45	64.05	421.17	2025-12-09 22:03:25.355074
2252	sensor_cilantro_1	19.21	69.80	67.27	1.91	6.78	163.44	405.71	2025-12-09 22:03:25.355262
2253	sensor_cilantro_2	22.05	76.57	78.18	1.82	6.44	187.72	428.83	2025-12-09 22:03:25.355405
2254	sensor_rabano_1	21.09	59.47	63.08	1.51	6.46	126.04	448.09	2025-12-09 22:03:35.367513
2255	sensor_rabano_2	20.62	71.42	73.75	1.43	6.55	152.70	474.60	2025-12-09 22:03:35.368485
2256	sensor_cilantro_1	21.74	74.38	63.52	1.89	6.68	192.04	475.87	2025-12-09 22:03:35.368673
2257	sensor_cilantro_2	19.05	66.94	70.23	1.61	6.43	120.08	448.56	2025-12-09 22:03:35.368829
2258	sensor_rabano_1	23.81	59.96	65.68	1.94	6.66	98.29	459.82	2025-12-09 22:03:45.393685
2259	sensor_rabano_2	22.36	61.15	63.92	1.91	6.45	86.86	472.28	2025-12-09 22:03:45.394528
2260	sensor_cilantro_1	21.93	71.00	79.25	1.84	6.63	174.92	420.65	2025-12-09 22:03:45.394718
2261	sensor_cilantro_2	19.20	64.80	68.47	1.80	6.51	196.11	419.75	2025-12-09 22:03:45.394868
2262	sensor_rabano_1	20.66	70.53	68.66	1.54	6.75	156.31	446.36	2025-12-09 22:03:55.405747
2263	sensor_rabano_2	22.99	60.50	68.19	1.41	6.76	117.39	410.53	2025-12-09 22:03:55.406256
2264	sensor_cilantro_1	22.45	67.37	75.35	1.68	6.60	91.73	424.47	2025-12-09 22:03:55.40643
2265	sensor_cilantro_2	21.23	72.98	61.88	1.99	6.51	170.46	485.44	2025-12-09 22:03:55.406499
2266	sensor_rabano_1	21.57	62.99	70.89	1.55	6.62	111.04	415.63	2025-12-09 22:04:05.416503
2267	sensor_rabano_2	22.89	72.94	74.86	1.42	6.62	73.22	492.01	2025-12-09 22:04:05.417754
2268	sensor_cilantro_1	19.12	77.79	73.00	1.44	6.70	67.68	462.50	2025-12-09 22:04:05.417982
2269	sensor_cilantro_2	21.58	76.63	62.41	1.89	6.56	57.37	471.89	2025-12-09 22:04:05.418221
2270	sensor_rabano_1	22.80	69.87	64.42	2.00	6.48	175.40	498.08	2025-12-09 22:04:15.428465
2271	sensor_rabano_2	20.49	64.83	63.63	1.62	6.76	164.48	476.01	2025-12-09 22:04:15.429407
2272	sensor_cilantro_1	20.13	67.13	65.31	1.49	6.49	166.90	400.50	2025-12-09 22:04:15.42963
2273	sensor_cilantro_2	19.34	67.72	73.92	1.99	6.56	112.82	488.95	2025-12-09 22:04:15.429828
2274	sensor_rabano_1	23.44	70.34	64.20	1.85	6.66	82.52	494.44	2025-12-09 22:04:25.44117
2275	sensor_rabano_2	21.46	69.06	63.74	1.99	6.52	91.65	468.36	2025-12-09 22:04:25.441947
2276	sensor_cilantro_1	21.76	65.11	68.93	1.94	6.47	154.18	471.48	2025-12-09 22:04:25.442172
2277	sensor_cilantro_2	22.20	66.66	71.79	1.95	6.68	192.47	475.46	2025-12-09 22:04:25.442407
2278	sensor_rabano_1	23.39	63.61	79.37	1.51	6.74	162.35	490.25	2025-12-09 22:04:35.452125
2279	sensor_rabano_2	20.19	62.29	73.85	1.52	6.52	187.27	438.21	2025-12-09 22:04:35.452895
2280	sensor_cilantro_1	20.55	71.75	63.72	1.60	6.72	82.94	400.93	2025-12-09 22:04:35.453087
2281	sensor_cilantro_2	20.72	73.08	63.92	1.70	6.47	81.76	438.68	2025-12-09 22:04:35.453154
2282	sensor_rabano_1	21.85	72.94	70.90	1.81	6.41	195.66	488.33	2025-12-09 22:04:45.463466
2283	sensor_rabano_2	20.40	67.04	63.04	1.89	6.70	196.60	439.25	2025-12-09 22:04:45.464276
2284	sensor_cilantro_1	22.53	69.54	63.50	1.41	6.56	155.41	487.90	2025-12-09 22:04:45.464463
2285	sensor_cilantro_2	20.94	66.68	78.94	1.86	6.66	99.32	409.62	2025-12-09 22:04:45.464602
2286	sensor_rabano_1	23.06	69.66	67.53	1.57	6.55	110.93	450.58	2025-12-09 22:04:55.477031
2287	sensor_rabano_2	20.40	59.96	64.99	1.70	6.67	114.00	446.35	2025-12-09 22:04:55.47792
2288	sensor_cilantro_1	20.46	68.26	75.69	1.97	6.49	163.29	461.56	2025-12-09 22:04:55.478107
2289	sensor_cilantro_2	21.78	69.78	76.16	1.65	6.70	114.67	420.23	2025-12-09 22:04:55.478249
2290	sensor_rabano_1	23.28	71.96	65.08	1.69	6.58	151.27	445.74	2025-12-09 22:05:05.48934
2291	sensor_rabano_2	22.87	66.51	67.75	1.42	6.41	182.83	496.44	2025-12-09 22:05:05.490426
2292	sensor_cilantro_1	19.93	62.72	65.57	1.60	6.53	142.72	405.72	2025-12-09 22:05:05.490553
2293	sensor_cilantro_2	22.49	64.17	61.13	1.60	6.54	52.27	431.31	2025-12-09 22:05:05.490613
2294	sensor_rabano_1	20.10	60.26	74.41	1.52	6.73	165.63	443.95	2025-12-09 22:05:15.500177
2295	sensor_rabano_2	20.28	58.85	66.46	1.84	6.73	94.96	468.21	2025-12-09 22:05:15.500695
2296	sensor_cilantro_1	20.54	66.00	61.30	1.80	6.41	96.02	442.84	2025-12-09 22:05:15.500782
2297	sensor_cilantro_2	22.94	73.37	64.26	1.43	6.54	90.00	412.40	2025-12-09 22:05:15.500841
2298	sensor_rabano_1	22.82	57.75	77.38	1.78	6.47	123.86	472.39	2025-12-09 22:05:25.511344
2299	sensor_rabano_2	23.67	69.63	74.76	2.00	6.41	126.49	489.47	2025-12-09 22:05:25.511839
2300	sensor_cilantro_1	19.43	72.57	79.66	1.94	6.42	141.37	442.76	2025-12-09 22:05:25.512032
2301	sensor_cilantro_2	19.76	70.35	78.15	1.95	6.50	91.05	465.99	2025-12-09 22:05:25.512099
2302	sensor_rabano_1	22.75	70.76	75.10	1.75	6.51	174.39	485.71	2025-12-09 22:05:35.522934
2303	sensor_rabano_2	22.42	60.49	64.20	1.64	6.67	62.44	454.43	2025-12-09 22:05:35.52367
2304	sensor_cilantro_1	21.00	66.99	78.27	1.60	6.68	133.18	482.73	2025-12-09 22:05:35.523788
2305	sensor_cilantro_2	22.69	67.14	73.73	1.80	6.41	122.36	417.47	2025-12-09 22:05:35.523848
2306	sensor_rabano_1	20.97	59.42	60.01	1.63	6.68	76.30	475.68	2025-12-09 22:05:45.533867
2307	sensor_rabano_2	20.39	57.53	69.69	1.95	6.51	97.05	412.88	2025-12-09 22:05:45.534725
2308	sensor_cilantro_1	21.57	70.84	69.25	1.83	6.73	93.34	419.48	2025-12-09 22:05:45.534929
2309	sensor_cilantro_2	19.63	77.47	78.27	1.80	6.77	132.70	467.57	2025-12-09 22:05:45.535073
2310	sensor_rabano_1	21.89	57.30	69.88	1.81	6.75	154.53	483.38	2025-12-09 22:05:55.546525
2311	sensor_rabano_2	23.29	67.02	74.12	1.73	6.64	95.37	467.94	2025-12-09 22:05:55.547331
2312	sensor_cilantro_1	19.83	77.58	77.15	1.49	6.56	191.33	428.82	2025-12-09 22:05:55.547506
2313	sensor_cilantro_2	21.48	68.57	75.04	1.87	6.48	113.10	473.93	2025-12-09 22:05:55.547649
2314	sensor_rabano_1	24.00	63.12	77.50	1.85	6.53	68.26	407.80	2025-12-09 22:06:05.559875
2315	sensor_rabano_2	22.32	57.11	69.02	1.45	6.59	88.39	469.01	2025-12-09 22:06:05.561199
2316	sensor_cilantro_1	22.75	74.54	68.16	1.41	6.42	122.90	459.70	2025-12-09 22:06:05.561528
2317	sensor_cilantro_2	21.09	75.92	62.11	1.95	6.44	183.75	440.27	2025-12-09 22:06:05.561912
2318	sensor_rabano_1	22.83	57.87	71.91	1.56	6.40	55.75	487.90	2025-12-09 22:06:15.574284
2319	sensor_rabano_2	23.54	70.97	64.99	1.97	6.66	53.65	411.60	2025-12-09 22:06:15.575025
2320	sensor_cilantro_1	20.28	72.54	69.51	1.63	6.71	62.77	424.07	2025-12-09 22:06:15.575198
2321	sensor_cilantro_2	19.99	63.58	78.17	1.45	6.49	68.56	444.10	2025-12-09 22:06:15.575374
2322	sensor_rabano_1	20.26	63.30	79.73	1.66	6.76	66.40	497.13	2025-12-09 22:06:25.587247
2323	sensor_rabano_2	20.34	69.52	73.22	1.62	6.48	99.02	456.97	2025-12-09 22:06:25.587987
2324	sensor_cilantro_1	20.45	73.16	67.82	1.63	6.80	182.58	488.93	2025-12-09 22:06:25.588163
2325	sensor_cilantro_2	21.08	73.00	76.04	1.59	6.61	64.19	450.03	2025-12-09 22:06:25.588298
2326	sensor_rabano_1	20.93	60.48	70.15	1.47	6.45	157.15	429.91	2025-12-09 22:06:35.60019
2327	sensor_rabano_2	23.74	71.11	66.83	1.51	6.62	166.11	423.94	2025-12-09 22:06:35.600975
2328	sensor_cilantro_1	19.10	72.32	62.38	1.70	6.65	163.13	485.63	2025-12-09 22:06:35.601201
2329	sensor_cilantro_2	20.18	62.53	72.88	1.55	6.61	86.01	428.03	2025-12-09 22:06:35.601362
2330	sensor_rabano_1	20.75	66.02	67.04	1.87	6.61	128.97	424.20	2025-12-09 22:06:45.613331
2331	sensor_rabano_2	21.29	69.13	76.52	1.89	6.70	116.14	401.60	2025-12-09 22:06:45.613902
2332	sensor_cilantro_1	20.99	70.28	77.40	1.75	6.74	129.80	409.81	2025-12-09 22:06:45.614078
2333	sensor_cilantro_2	21.89	64.36	76.49	1.62	6.69	144.56	481.13	2025-12-09 22:06:45.614139
2334	sensor_rabano_1	21.26	67.66	79.48	1.53	6.54	77.26	448.35	2025-12-09 22:06:55.623882
2335	sensor_rabano_2	21.07	59.43	74.10	1.69	6.69	107.32	493.13	2025-12-09 22:06:55.624871
2336	sensor_cilantro_1	19.32	77.22	76.66	1.83	6.46	111.29	451.50	2025-12-09 22:06:55.625155
2337	sensor_cilantro_2	20.77	63.75	60.83	1.60	6.52	61.07	489.27	2025-12-09 22:06:55.625356
2338	sensor_rabano_1	21.90	60.51	64.12	1.43	6.69	89.86	494.17	2025-12-09 22:07:05.636989
2339	sensor_rabano_2	20.86	71.01	60.80	1.68	6.60	132.49	429.12	2025-12-09 22:07:05.637857
2340	sensor_cilantro_1	21.79	77.62	68.12	1.88	6.59	173.81	473.40	2025-12-09 22:07:05.638084
2341	sensor_cilantro_2	21.08	62.41	61.40	1.53	6.70	58.01	466.76	2025-12-09 22:07:05.638229
2342	sensor_rabano_1	21.25	58.45	61.15	1.57	6.53	52.07	415.67	2025-12-09 22:07:15.649208
2343	sensor_rabano_2	23.79	70.41	70.03	1.72	6.59	146.96	472.85	2025-12-09 22:07:15.649727
2344	sensor_cilantro_1	22.80	72.49	75.70	1.76	6.70	176.32	464.73	2025-12-09 22:07:15.649902
2345	sensor_cilantro_2	20.58	74.14	67.23	1.96	6.74	59.49	464.07	2025-12-09 22:07:15.649983
2346	sensor_rabano_1	22.83	72.71	65.29	1.49	6.44	111.11	499.55	2025-12-09 22:07:25.658917
2347	sensor_rabano_2	21.31	61.19	76.71	1.64	6.53	64.41	442.25	2025-12-09 22:07:25.659419
2348	sensor_cilantro_1	21.74	63.32	68.50	1.42	6.57	120.22	433.29	2025-12-09 22:07:25.659503
2349	sensor_cilantro_2	22.58	76.24	60.19	1.75	6.55	135.80	437.63	2025-12-09 22:07:25.659557
2350	sensor_rabano_1	21.88	60.46	60.44	1.79	6.49	160.42	477.93	2025-12-09 22:07:35.670711
2351	sensor_rabano_2	20.44	69.19	72.55	1.82	6.66	121.15	470.77	2025-12-09 22:07:35.671528
2352	sensor_cilantro_1	20.31	74.91	60.95	1.78	6.77	169.33	469.53	2025-12-09 22:07:35.671918
2353	sensor_cilantro_2	21.91	63.42	67.05	1.91	6.63	190.64	481.63	2025-12-09 22:07:35.672239
2354	sensor_rabano_1	22.02	67.86	79.04	1.41	6.61	136.13	421.21	2025-12-09 22:07:45.683782
2355	sensor_rabano_2	20.56	72.98	63.57	1.87	6.79	71.97	448.09	2025-12-09 22:07:45.684493
2356	sensor_cilantro_1	22.34	70.35	71.34	1.78	6.60	112.00	445.58	2025-12-09 22:07:45.684669
2357	sensor_cilantro_2	20.05	77.58	67.47	1.58	6.76	113.26	405.43	2025-12-09 22:07:45.684818
2358	sensor_rabano_1	21.91	72.12	69.66	1.72	6.70	129.65	478.24	2025-12-09 22:07:55.694138
2359	sensor_rabano_2	21.09	62.04	75.81	1.86	6.46	160.61	417.75	2025-12-09 22:07:55.694656
2360	sensor_cilantro_1	21.82	66.52	79.52	1.81	6.41	156.07	441.57	2025-12-09 22:07:55.694823
2361	sensor_cilantro_2	22.10	62.04	75.98	1.64	6.50	169.16	488.97	2025-12-09 22:07:55.694903
2362	sensor_rabano_1	22.59	72.38	61.82	1.65	6.59	160.64	405.84	2025-12-09 22:08:05.706281
2363	sensor_rabano_2	22.39	71.44	67.88	1.92	6.79	146.21	441.57	2025-12-09 22:08:05.707209
2364	sensor_cilantro_1	19.44	70.14	68.25	1.46	6.65	91.87	461.43	2025-12-09 22:08:05.707488
2365	sensor_cilantro_2	22.02	64.99	79.60	1.56	6.41	188.61	498.84	2025-12-09 22:08:05.707641
2366	sensor_rabano_1	21.51	59.50	78.60	1.74	6.46	88.79	406.59	2025-12-09 22:08:15.716849
2367	sensor_rabano_2	21.13	59.06	68.51	1.68	6.76	65.86	403.06	2025-12-09 22:08:15.717463
2368	sensor_cilantro_1	21.18	73.03	63.23	1.97	6.76	112.16	467.50	2025-12-09 22:08:15.717565
2369	sensor_cilantro_2	22.45	73.80	74.84	1.40	6.54	137.43	460.32	2025-12-09 22:08:15.717624
2370	sensor_rabano_1	21.93	72.06	68.45	1.58	6.41	107.97	419.65	2025-12-09 22:08:25.729205
2371	sensor_rabano_2	22.95	71.76	74.72	1.93	6.63	109.07	401.49	2025-12-09 22:08:25.729977
2372	sensor_cilantro_1	21.91	63.10	69.93	1.61	6.44	111.39	425.59	2025-12-09 22:08:25.730199
2373	sensor_cilantro_2	20.34	62.41	67.83	1.70	6.44	136.99	440.84	2025-12-09 22:08:25.730357
2374	sensor_rabano_1	20.51	58.15	65.63	1.49	6.50	128.26	409.48	2025-12-09 22:08:35.740404
2375	sensor_rabano_2	22.16	70.48	60.47	1.52	6.78	131.27	416.31	2025-12-09 22:08:35.741169
2376	sensor_cilantro_1	21.76	66.33	74.18	1.97	6.72	159.63	407.07	2025-12-09 22:08:35.741354
2377	sensor_cilantro_2	22.76	68.24	61.50	1.63	6.48	71.25	447.57	2025-12-09 22:08:35.741491
2378	sensor_rabano_1	20.18	63.46	61.20	1.98	6.55	160.80	415.26	2025-12-09 22:08:45.758601
2379	sensor_rabano_2	23.19	59.22	75.83	1.94	6.53	136.67	494.92	2025-12-09 22:08:45.759286
2380	sensor_cilantro_1	21.65	74.59	77.35	1.51	6.46	55.65	473.53	2025-12-09 22:08:45.759388
2381	sensor_cilantro_2	22.08	66.71	67.14	1.99	6.41	196.52	490.08	2025-12-09 22:08:45.759445
2382	sensor_rabano_1	22.57	58.02	65.02	1.63	6.78	84.55	404.81	2025-12-09 22:08:55.770893
2383	sensor_rabano_2	22.12	63.09	76.34	1.65	6.74	127.65	405.73	2025-12-09 22:08:55.771653
2384	sensor_cilantro_1	22.49	75.16	75.14	1.66	6.76	193.42	445.91	2025-12-09 22:08:55.771761
2385	sensor_cilantro_2	19.02	69.07	67.03	1.51	6.44	94.34	479.54	2025-12-09 22:08:55.771991
2386	sensor_rabano_1	21.88	68.98	68.77	1.54	6.53	103.67	474.44	2025-12-09 22:09:05.779526
2387	sensor_rabano_2	23.87	64.78	78.66	1.47	6.69	146.08	425.88	2025-12-09 22:09:05.779967
2388	sensor_cilantro_1	21.55	76.68	63.92	1.66	6.62	60.26	484.89	2025-12-09 22:09:05.780044
2389	sensor_cilantro_2	21.16	70.59	71.21	1.97	6.72	175.53	491.82	2025-12-09 22:09:05.780096
2390	sensor_rabano_1	23.94	67.33	61.39	1.84	6.43	164.93	405.35	2025-12-09 22:09:15.791197
2391	sensor_rabano_2	23.23	59.51	61.20	1.59	6.59	72.72	472.03	2025-12-09 22:09:15.791678
2392	sensor_cilantro_1	19.02	65.86	76.05	1.78	6.54	168.11	423.26	2025-12-09 22:09:15.791816
2393	sensor_cilantro_2	19.62	65.21	65.62	1.48	6.66	61.15	498.70	2025-12-09 22:09:15.791904
2394	sensor_rabano_1	23.77	65.76	72.69	1.97	6.65	169.88	411.04	2025-12-09 22:09:25.803176
2395	sensor_rabano_2	22.22	66.89	63.33	1.85	6.72	168.88	430.63	2025-12-09 22:09:25.803942
2396	sensor_cilantro_1	20.33	64.09	76.17	1.76	6.74	74.48	443.65	2025-12-09 22:09:25.804169
2397	sensor_cilantro_2	22.78	62.50	76.25	1.60	6.47	144.12	412.95	2025-12-09 22:09:25.804316
2398	sensor_rabano_1	23.67	72.51	67.25	1.64	6.46	81.44	459.29	2025-12-09 22:09:35.814597
2399	sensor_rabano_2	20.97	59.77	72.62	1.48	6.61	114.31	484.12	2025-12-09 22:09:35.815435
2400	sensor_cilantro_1	19.62	66.80	70.35	1.44	6.58	168.31	437.58	2025-12-09 22:09:35.815621
2401	sensor_cilantro_2	20.29	63.89	75.90	1.80	6.53	157.06	421.53	2025-12-09 22:09:35.815772
2402	sensor_rabano_1	21.55	71.29	67.74	1.71	6.47	60.20	472.34	2025-12-09 22:09:45.827503
2403	sensor_rabano_2	21.97	66.62	79.29	1.55	6.64	100.09	406.27	2025-12-09 22:09:45.828289
2404	sensor_cilantro_1	21.64	76.51	63.59	1.44	6.44	191.45	423.32	2025-12-09 22:09:45.828473
2405	sensor_cilantro_2	22.73	63.41	71.76	1.84	6.80	159.70	487.93	2025-12-09 22:09:45.828614
2406	sensor_rabano_1	21.56	71.78	60.88	1.42	6.47	153.27	420.99	2025-12-09 22:09:55.837883
2407	sensor_rabano_2	23.84	61.31	77.35	1.47	6.47	171.49	485.55	2025-12-09 22:09:55.838442
2408	sensor_cilantro_1	21.56	69.05	70.64	1.90	6.73	111.92	411.80	2025-12-09 22:09:55.838532
2409	sensor_cilantro_2	21.79	66.31	69.19	1.77	6.65	111.54	420.51	2025-12-09 22:09:55.83859
2410	sensor_rabano_1	21.72	59.82	79.34	1.96	6.42	118.12	483.18	2025-12-09 22:10:05.848629
2411	sensor_rabano_2	22.85	61.57	64.45	1.87	6.47	186.21	402.66	2025-12-09 22:10:05.849422
2412	sensor_cilantro_1	20.26	66.48	67.40	1.69	6.41	93.12	489.48	2025-12-09 22:10:05.849605
2413	sensor_cilantro_2	21.06	64.40	63.85	1.76	6.62	142.57	485.70	2025-12-09 22:10:05.849804
2414	sensor_rabano_1	21.13	61.80	72.01	1.87	6.55	167.27	466.84	2025-12-09 22:10:15.861702
2415	sensor_rabano_2	22.87	68.65	73.20	1.93	6.47	80.72	407.63	2025-12-09 22:10:15.862536
2416	sensor_cilantro_1	21.93	63.00	67.69	1.42	6.53	93.44	409.88	2025-12-09 22:10:15.862724
2417	sensor_cilantro_2	19.78	67.23	67.11	1.65	6.59	76.13	464.03	2025-12-09 22:10:15.862953
2418	sensor_rabano_1	21.06	68.94	72.21	1.56	6.51	60.56	490.23	2025-12-09 22:10:25.874826
2419	sensor_rabano_2	20.39	61.86	79.28	2.00	6.75	159.21	416.71	2025-12-09 22:10:25.875594
2420	sensor_cilantro_1	20.79	72.77	69.35	1.56	6.52	176.32	460.44	2025-12-09 22:10:25.875796
2421	sensor_cilantro_2	22.51	63.53	64.42	1.57	6.70	135.89	446.36	2025-12-09 22:10:25.875938
2422	sensor_rabano_1	23.21	60.42	61.38	1.60	6.41	110.80	439.18	2025-12-09 22:10:35.885141
2423	sensor_rabano_2	23.63	71.52	62.10	1.48	6.77	171.18	407.04	2025-12-09 22:10:35.885776
2424	sensor_cilantro_1	22.24	69.81	68.56	1.76	6.74	180.50	491.02	2025-12-09 22:10:35.885962
2425	sensor_cilantro_2	22.93	74.22	71.32	1.92	6.47	72.69	465.66	2025-12-09 22:10:35.886024
2426	sensor_rabano_1	21.86	67.88	61.59	1.45	6.48	71.09	452.43	2025-12-09 22:10:45.897508
2427	sensor_rabano_2	21.19	70.17	77.57	1.46	6.73	197.69	441.86	2025-12-09 22:10:45.898305
2428	sensor_cilantro_1	19.60	70.04	69.18	1.72	6.52	115.71	418.43	2025-12-09 22:10:45.898492
2429	sensor_cilantro_2	20.71	64.41	67.82	1.95	6.49	105.08	494.85	2025-12-09 22:10:45.898634
2430	sensor_rabano_1	21.70	62.40	66.60	1.78	6.63	64.19	464.68	2025-12-09 22:10:55.909859
2431	sensor_rabano_2	23.07	63.39	63.14	1.51	6.48	121.45	444.48	2025-12-09 22:10:55.910659
2432	sensor_cilantro_1	22.63	74.89	75.06	1.86	6.49	88.06	402.02	2025-12-09 22:10:55.910936
2433	sensor_cilantro_2	19.68	76.60	72.04	1.95	6.42	168.26	460.67	2025-12-09 22:10:55.911157
2434	sensor_rabano_1	20.99	69.23	61.87	1.54	6.64	198.92	487.20	2025-12-09 22:11:05.921377
2435	sensor_rabano_2	23.71	57.49	78.19	1.81	6.59	50.57	471.47	2025-12-09 22:11:05.922265
2436	sensor_cilantro_1	21.13	75.70	65.85	1.98	6.78	184.41	478.34	2025-12-09 22:11:05.922513
2437	sensor_cilantro_2	19.44	69.41	62.02	1.66	6.43	162.32	438.55	2025-12-09 22:11:05.922689
2438	sensor_rabano_1	21.39	64.18	63.22	1.72	6.62	192.33	403.62	2025-12-09 22:11:15.933366
2439	sensor_rabano_2	22.09	70.45	74.76	1.48	6.68	165.19	447.37	2025-12-09 22:11:15.934005
2440	sensor_cilantro_1	20.40	72.05	66.70	1.98	6.46	162.29	412.71	2025-12-09 22:11:15.934175
2441	sensor_cilantro_2	19.99	73.55	62.61	1.49	6.43	191.00	474.38	2025-12-09 22:11:15.934254
2442	sensor_rabano_1	22.15	65.71	62.57	1.77	6.64	187.27	402.53	2025-12-09 22:11:25.945603
2443	sensor_rabano_2	22.38	67.60	60.97	1.94	6.58	186.40	496.18	2025-12-09 22:11:25.94637
2444	sensor_cilantro_1	22.59	69.49	67.44	1.69	6.42	110.86	466.19	2025-12-09 22:11:25.946545
2445	sensor_cilantro_2	22.77	68.57	67.25	1.79	6.62	161.71	470.97	2025-12-09 22:11:25.946682
2446	sensor_rabano_1	23.56	59.42	77.05	1.64	6.44	141.88	410.31	2025-12-09 22:11:35.955934
2447	sensor_rabano_2	22.72	66.93	62.10	1.78	6.78	177.60	457.53	2025-12-09 22:11:35.956675
2448	sensor_cilantro_1	22.96	75.52	67.51	1.98	6.52	181.27	468.13	2025-12-09 22:11:35.956835
2449	sensor_cilantro_2	22.26	75.39	64.49	1.72	6.53	79.66	404.18	2025-12-09 22:11:35.956916
2450	sensor_rabano_1	20.01	57.36	70.65	1.88	6.43	170.99	441.52	2025-12-09 22:11:45.966351
2451	sensor_rabano_2	23.82	64.20	73.02	1.51	6.49	145.26	452.34	2025-12-09 22:11:45.966887
2452	sensor_cilantro_1	21.00	63.41	66.84	1.68	6.58	102.14	439.97	2025-12-09 22:11:45.96698
2453	sensor_cilantro_2	21.32	72.43	68.12	1.53	6.78	113.20	488.87	2025-12-09 22:11:45.967038
2454	sensor_rabano_1	23.23	68.72	65.23	1.87	6.63	130.68	466.42	2025-12-09 22:11:55.978293
2455	sensor_rabano_2	20.53	58.27	73.32	1.77	6.77	101.43	441.87	2025-12-09 22:11:55.979024
2456	sensor_cilantro_1	21.58	66.79	61.96	1.68	6.69	155.05	424.50	2025-12-09 22:11:55.97921
2457	sensor_cilantro_2	20.42	70.75	69.84	1.58	6.45	93.50	443.52	2025-12-09 22:11:55.979352
2458	sensor_rabano_1	20.21	61.98	68.53	1.94	6.48	99.95	483.08	2025-12-09 22:12:05.988795
2459	sensor_rabano_2	21.95	63.59	74.90	1.89	6.54	63.55	463.43	2025-12-09 22:12:05.989552
2460	sensor_cilantro_1	20.31	65.46	68.00	1.54	6.44	177.64	454.84	2025-12-09 22:12:05.989735
2461	sensor_cilantro_2	19.36	71.49	74.50	1.48	6.73	168.36	403.62	2025-12-09 22:12:05.989963
2462	sensor_rabano_1	20.53	65.06	76.30	1.91	6.72	87.53	421.83	2025-12-09 22:12:16.001482
2463	sensor_rabano_2	23.95	67.77	62.93	1.65	6.73	108.61	429.36	2025-12-09 22:12:16.00219
2464	sensor_cilantro_1	20.96	67.52	61.11	1.88	6.76	111.01	472.16	2025-12-09 22:12:16.002291
2465	sensor_cilantro_2	22.05	69.93	68.85	1.94	6.65	150.66	473.53	2025-12-09 22:12:16.002349
2466	sensor_rabano_1	20.22	71.68	73.62	1.82	6.52	142.63	417.70	2025-12-09 22:12:26.011414
2467	sensor_rabano_2	23.22	62.97	77.97	1.60	6.44	158.89	486.49	2025-12-09 22:12:26.011943
2468	sensor_cilantro_1	19.88	66.38	68.27	1.61	6.48	152.20	408.43	2025-12-09 22:12:26.012114
2469	sensor_cilantro_2	19.02	70.15	79.23	1.69	6.41	59.24	442.16	2025-12-09 22:12:26.012195
2470	sensor_rabano_1	20.66	60.74	74.41	1.63	6.64	66.23	477.85	2025-12-09 22:12:36.022169
2471	sensor_rabano_2	22.59	72.88	78.31	1.77	6.68	150.23	476.73	2025-12-09 22:12:36.022851
2472	sensor_cilantro_1	21.38	76.89	75.90	1.40	6.66	60.20	406.93	2025-12-09 22:12:36.023108
2473	sensor_cilantro_2	19.94	69.35	70.39	1.55	6.59	53.27	439.51	2025-12-09 22:12:36.023261
2474	sensor_rabano_1	22.02	71.36	60.69	1.60	6.50	64.99	426.35	2025-12-09 22:12:46.034731
2475	sensor_rabano_2	22.40	68.44	65.63	1.41	6.49	89.84	455.45	2025-12-09 22:12:46.035551
2476	sensor_cilantro_1	21.70	66.30	76.95	1.43	6.49	108.72	481.88	2025-12-09 22:12:46.035803
2477	sensor_cilantro_2	20.67	62.24	61.14	1.46	6.71	99.73	425.23	2025-12-09 22:12:46.035966
2478	sensor_rabano_1	23.80	60.86	68.32	1.91	6.70	102.04	475.64	2025-12-09 22:12:56.047492
2479	sensor_rabano_2	23.26	70.31	68.65	1.48	6.74	113.12	484.08	2025-12-09 22:12:56.048205
2480	sensor_cilantro_1	19.26	65.48	63.20	1.73	6.68	148.34	489.55	2025-12-09 22:12:56.048381
2481	sensor_cilantro_2	22.20	65.52	61.82	1.71	6.72	80.47	467.63	2025-12-09 22:12:56.048517
2482	sensor_rabano_1	23.20	66.80	68.29	1.47	6.58	198.62	425.00	2025-12-09 22:13:06.05828
2483	sensor_rabano_2	21.35	70.15	70.70	1.96	6.43	195.43	497.43	2025-12-09 22:13:06.059161
2484	sensor_cilantro_1	20.15	63.27	62.84	1.88	6.45	188.15	458.37	2025-12-09 22:13:06.059399
2485	sensor_cilantro_2	19.74	77.65	73.77	1.71	6.80	167.83	409.59	2025-12-09 22:13:06.059554
2486	sensor_rabano_1	22.03	69.86	62.72	1.67	6.48	138.16	433.40	2025-12-09 22:13:16.070812
2487	sensor_rabano_2	20.94	65.79	68.53	1.41	6.64	141.58	472.13	2025-12-09 22:13:16.07154
2488	sensor_cilantro_1	19.43	76.71	76.89	1.48	6.74	67.75	451.31	2025-12-09 22:13:16.071722
2489	sensor_cilantro_2	22.85	67.98	61.21	1.46	6.51	64.89	482.85	2025-12-09 22:13:16.071869
2490	sensor_rabano_1	22.24	64.48	72.61	1.51	6.47	146.82	465.28	2025-12-09 22:13:26.082949
2491	sensor_rabano_2	23.45	64.80	72.17	1.49	6.46	70.43	482.98	2025-12-09 22:13:26.083878
2492	sensor_cilantro_1	21.44	77.50	62.18	1.80	6.56	73.26	452.73	2025-12-09 22:13:26.084143
2493	sensor_cilantro_2	19.07	75.81	64.53	1.82	6.61	173.21	415.58	2025-12-09 22:13:26.084349
2494	sensor_rabano_1	20.64	61.78	76.18	1.64	6.53	121.06	477.24	2025-12-09 22:13:36.09471
2495	sensor_rabano_2	23.98	58.55	63.98	1.63	6.52	199.85	456.64	2025-12-09 22:13:36.095535
2496	sensor_cilantro_1	22.14	69.79	61.17	1.82	6.64	68.89	495.55	2025-12-09 22:13:36.095726
2497	sensor_cilantro_2	20.16	74.06	72.72	1.59	6.63	84.70	496.53	2025-12-09 22:13:36.09597
2498	sensor_rabano_1	23.79	67.39	68.12	1.40	6.74	134.70	469.12	2025-12-09 22:13:46.117969
2499	sensor_rabano_2	22.88	60.18	77.68	1.42	6.53	64.82	437.29	2025-12-09 22:13:46.118834
2500	sensor_cilantro_1	20.49	72.65	77.27	1.97	6.68	150.65	436.79	2025-12-09 22:13:46.119063
2501	sensor_cilantro_2	22.18	65.76	75.93	1.58	6.67	154.11	468.75	2025-12-09 22:13:46.119206
2502	sensor_rabano_1	22.30	60.84	62.09	1.48	6.67	70.53	426.71	2025-12-09 22:13:56.128865
2503	sensor_rabano_2	22.89	69.16	66.19	1.46	6.60	67.67	426.14	2025-12-09 22:13:56.129565
2504	sensor_cilantro_1	20.47	62.45	65.97	1.89	6.71	182.11	426.83	2025-12-09 22:13:56.129734
2505	sensor_cilantro_2	21.69	74.56	74.41	1.98	6.50	194.17	444.01	2025-12-09 22:13:56.129817
2506	sensor_rabano_1	23.10	72.01	73.39	1.79	6.63	129.59	430.11	2025-12-09 22:14:06.138243
2507	sensor_rabano_2	21.69	67.99	79.29	1.62	6.55	81.50	417.00	2025-12-09 22:14:06.139009
2508	sensor_cilantro_1	22.05	77.99	76.61	1.75	6.80	142.24	448.42	2025-12-09 22:14:06.139179
2509	sensor_cilantro_2	22.40	67.91	66.29	1.72	6.66	126.89	457.35	2025-12-09 22:14:06.139258
2510	sensor_rabano_1	21.15	66.62	66.75	1.83	6.62	92.00	446.10	2025-12-09 22:14:16.150682
2511	sensor_rabano_2	20.03	67.34	68.64	1.46	6.75	182.45	415.11	2025-12-09 22:14:16.151531
2512	sensor_cilantro_1	20.43	70.22	61.31	1.98	6.63	152.32	405.33	2025-12-09 22:14:16.151719
2513	sensor_cilantro_2	21.79	76.25	68.64	1.46	6.58	190.38	450.45	2025-12-09 22:14:16.151874
2514	sensor_rabano_1	22.76	63.88	68.25	1.41	6.50	138.69	425.09	2025-12-09 22:14:26.16354
2515	sensor_rabano_2	23.23	62.22	69.91	1.92	6.67	197.41	477.89	2025-12-09 22:14:26.164322
2516	sensor_cilantro_1	22.50	76.02	68.56	1.57	6.47	72.86	457.81	2025-12-09 22:14:26.164502
2517	sensor_cilantro_2	21.04	69.23	66.50	1.84	6.70	179.94	403.41	2025-12-09 22:14:26.164638
2518	sensor_rabano_1	21.63	66.72	68.23	1.84	6.79	124.70	408.02	2025-12-09 22:14:36.175154
2519	sensor_rabano_2	21.26	60.30	72.33	1.67	6.40	186.42	472.10	2025-12-09 22:14:36.175938
2520	sensor_cilantro_1	22.56	63.97	75.73	1.65	6.68	109.06	410.35	2025-12-09 22:14:36.176171
2521	sensor_cilantro_2	22.11	64.21	74.35	1.42	6.50	123.12	475.35	2025-12-09 22:14:36.176321
2522	sensor_rabano_1	22.45	69.89	64.05	1.43	6.42	67.32	447.67	2025-12-09 22:14:46.185968
2523	sensor_rabano_2	21.09	59.21	60.93	1.91	6.42	81.96	436.54	2025-12-09 22:14:46.186472
2524	sensor_cilantro_1	21.95	77.68	73.82	1.71	6.60	137.04	432.88	2025-12-09 22:14:46.186553
2525	sensor_cilantro_2	20.63	65.54	69.84	1.47	6.70	54.00	446.33	2025-12-09 22:14:46.186611
2526	sensor_rabano_1	23.44	59.13	77.19	1.76	6.69	155.76	496.05	2025-12-09 22:14:56.198136
2527	sensor_rabano_2	23.56	68.78	74.51	1.60	6.43	119.85	460.19	2025-12-09 22:14:56.198975
2528	sensor_cilantro_1	19.90	74.90	72.04	1.76	6.68	78.04	458.05	2025-12-09 22:14:56.199163
2529	sensor_cilantro_2	22.35	75.40	67.62	1.41	6.45	135.02	459.89	2025-12-09 22:14:56.199302
2530	sensor_rabano_1	23.07	71.29	67.37	1.46	6.60	145.15	492.74	2025-12-09 22:15:06.209445
2531	sensor_rabano_2	23.57	57.60	63.65	1.53	6.49	134.44	491.45	2025-12-09 22:15:06.210238
2532	sensor_cilantro_1	21.92	67.85	75.07	1.81	6.59	85.91	448.06	2025-12-09 22:15:06.210423
2533	sensor_cilantro_2	20.35	72.90	63.93	1.75	6.62	61.53	446.10	2025-12-09 22:15:06.210562
2534	sensor_rabano_1	21.55	67.17	60.26	1.94	6.78	100.84	420.32	2025-12-09 22:15:16.222141
2535	sensor_rabano_2	20.15	69.92	65.89	1.52	6.64	174.14	495.96	2025-12-09 22:15:16.222984
2536	sensor_cilantro_1	22.37	72.62	64.83	2.00	6.48	168.94	480.36	2025-12-09 22:15:16.223167
2537	sensor_cilantro_2	21.37	64.81	73.21	1.81	6.52	109.78	481.68	2025-12-09 22:15:16.223307
2538	sensor_rabano_1	21.82	69.12	62.12	1.55	6.43	170.68	402.50	2025-12-09 22:15:26.233812
2539	sensor_rabano_2	20.22	72.44	63.63	1.50	6.61	72.24	498.64	2025-12-09 22:15:26.234628
2540	sensor_cilantro_1	22.51	74.63	73.65	1.52	6.49	194.49	426.14	2025-12-09 22:15:26.234848
2541	sensor_cilantro_2	22.10	62.53	77.27	1.99	6.74	110.63	496.65	2025-12-09 22:15:26.234994
2542	sensor_rabano_1	22.19	69.63	69.21	1.45	6.69	182.46	457.40	2025-12-09 22:15:36.245209
2543	sensor_rabano_2	22.78	63.11	68.06	1.74	6.59	71.86	452.76	2025-12-09 22:15:36.245978
2544	sensor_cilantro_1	20.58	69.63	67.64	1.93	6.58	83.39	402.54	2025-12-09 22:15:36.246207
2545	sensor_cilantro_2	21.51	77.27	64.62	1.70	6.46	104.82	453.83	2025-12-09 22:15:36.246363
2546	sensor_rabano_1	21.54	71.93	75.22	1.81	6.68	113.71	479.04	2025-12-09 22:15:46.257687
2547	sensor_rabano_2	23.06	63.81	64.56	1.96	6.55	157.38	481.62	2025-12-09 22:15:46.258448
2548	sensor_cilantro_1	19.79	66.13	64.52	1.69	6.62	195.31	496.08	2025-12-09 22:15:46.25863
2549	sensor_cilantro_2	22.22	69.11	74.77	1.72	6.60	71.39	434.52	2025-12-09 22:15:46.258781
2550	sensor_rabano_1	22.68	69.40	69.96	1.65	6.60	156.97	480.83	2025-12-09 22:15:56.269583
2551	sensor_rabano_2	20.63	70.61	63.91	1.61	6.66	64.05	429.11	2025-12-09 22:15:56.270453
2552	sensor_cilantro_1	19.73	63.10	62.68	1.44	6.71	109.09	435.85	2025-12-09 22:15:56.27064
2553	sensor_cilantro_2	20.52	67.12	63.54	1.89	6.52	109.12	441.62	2025-12-09 22:15:56.27079
2554	sensor_rabano_1	22.60	71.70	73.72	1.41	6.42	173.66	475.27	2025-12-09 22:16:06.280791
2555	sensor_rabano_2	20.74	69.52	60.66	1.75	6.45	164.56	470.44	2025-12-09 22:16:06.281623
2556	sensor_cilantro_1	21.70	70.96	79.37	1.53	6.56	198.96	408.85	2025-12-09 22:16:06.281819
2557	sensor_cilantro_2	21.51	77.84	66.75	1.52	6.57	95.52	438.30	2025-12-09 22:16:06.282024
2558	sensor_rabano_1	20.51	67.15	72.64	1.98	6.46	140.62	419.87	2025-12-09 22:16:16.293682
2559	sensor_rabano_2	23.28	69.49	60.66	1.61	6.70	125.23	448.92	2025-12-09 22:16:16.294527
2560	sensor_cilantro_1	21.50	63.46	65.79	1.96	6.77	137.41	419.36	2025-12-09 22:16:16.294717
2561	sensor_cilantro_2	19.91	68.79	61.45	2.00	6.46	99.40	498.51	2025-12-09 22:16:16.29486
2562	sensor_rabano_1	21.73	61.03	65.30	1.90	6.71	92.76	459.56	2025-12-09 22:16:26.306243
2563	sensor_rabano_2	23.49	64.66	61.26	1.85	6.65	117.76	437.81	2025-12-09 22:16:26.307069
2564	sensor_cilantro_1	20.79	70.66	78.58	1.86	6.59	133.46	444.42	2025-12-09 22:16:26.307261
2565	sensor_cilantro_2	20.44	75.96	65.11	1.95	6.58	170.18	481.28	2025-12-09 22:16:26.307409
2566	sensor_rabano_1	21.95	57.51	66.89	1.41	6.61	177.29	462.20	2025-12-09 22:16:36.319168
2567	sensor_rabano_2	20.07	64.28	61.98	1.53	6.79	172.26	492.21	2025-12-09 22:16:36.319995
2568	sensor_cilantro_1	19.76	69.74	73.81	1.82	6.75	82.20	424.26	2025-12-09 22:16:36.320181
2569	sensor_cilantro_2	20.30	69.26	75.15	1.58	6.67	152.41	473.50	2025-12-09 22:16:36.320327
2570	sensor_rabano_1	22.97	68.97	69.98	1.61	6.61	130.45	435.32	2025-12-09 22:16:46.330166
2571	sensor_rabano_2	22.70	63.78	62.59	1.63	6.51	82.59	457.07	2025-12-09 22:16:46.331167
2572	sensor_cilantro_1	20.51	69.67	60.38	1.70	6.53	153.99	423.73	2025-12-09 22:16:46.331513
2573	sensor_cilantro_2	20.52	77.93	72.76	1.84	6.42	176.59	417.15	2025-12-09 22:16:46.331759
2574	sensor_rabano_1	21.16	60.12	61.11	1.68	6.46	55.11	483.65	2025-12-09 22:16:56.343279
2575	sensor_rabano_2	21.62	67.26	77.03	1.94	6.55	180.22	450.50	2025-12-09 22:16:56.34407
2576	sensor_cilantro_1	21.53	64.34	62.59	1.42	6.44	192.13	462.23	2025-12-09 22:16:56.34426
2577	sensor_cilantro_2	19.89	74.95	66.71	1.80	6.63	188.48	401.44	2025-12-09 22:16:56.344471
2578	sensor_rabano_1	22.70	69.51	66.91	1.89	6.79	66.12	437.47	2025-12-09 22:17:06.356398
2579	sensor_rabano_2	23.36	72.58	62.63	1.44	6.51	86.45	442.81	2025-12-09 22:17:06.357329
2580	sensor_cilantro_1	19.13	72.21	75.78	1.42	6.50	91.78	445.23	2025-12-09 22:17:06.357502
2581	sensor_cilantro_2	21.00	71.94	74.95	1.99	6.53	92.57	421.12	2025-12-09 22:17:06.357657
2582	sensor_rabano_1	20.07	59.68	77.39	1.79	6.70	173.55	410.11	2025-12-09 22:17:16.368825
2583	sensor_rabano_2	22.70	58.37	69.53	1.48	6.55	191.78	477.94	2025-12-09 22:17:16.369599
2584	sensor_cilantro_1	21.81	66.15	71.15	1.59	6.77	153.72	405.61	2025-12-09 22:17:16.369773
2585	sensor_cilantro_2	22.54	67.70	76.17	1.99	6.43	61.33	428.14	2025-12-09 22:17:16.369923
2586	sensor_rabano_1	20.39	65.30	68.32	1.87	6.41	158.14	431.96	2025-12-09 22:17:26.378617
2587	sensor_rabano_2	23.28	68.79	64.94	1.77	6.59	150.83	481.82	2025-12-09 22:17:26.379256
2588	sensor_cilantro_1	20.38	63.66	68.71	1.53	6.75	191.80	451.15	2025-12-09 22:17:26.379359
2589	sensor_cilantro_2	20.81	76.96	70.72	1.90	6.56	152.81	431.90	2025-12-09 22:17:26.379416
2590	sensor_rabano_1	20.51	72.24	71.68	1.70	6.41	148.10	404.73	2025-12-09 22:17:36.39057
2591	sensor_rabano_2	20.73	67.17	75.76	1.97	6.72	128.65	405.80	2025-12-09 22:17:36.39111
2592	sensor_cilantro_1	20.95	77.87	67.39	1.40	6.59	122.78	460.99	2025-12-09 22:17:36.391199
2593	sensor_cilantro_2	21.81	70.84	72.88	1.50	6.71	100.03	498.30	2025-12-09 22:17:36.391255
2594	sensor_rabano_1	22.25	60.16	77.75	1.86	6.54	131.31	477.01	2025-12-09 22:17:46.402177
2595	sensor_rabano_2	23.41	67.26	69.12	1.91	6.53	52.28	420.34	2025-12-09 22:17:46.402962
2596	sensor_cilantro_1	19.07	69.90	71.22	1.84	6.47	124.81	461.20	2025-12-09 22:17:46.403182
2597	sensor_cilantro_2	22.44	66.35	70.89	1.84	6.53	92.98	469.36	2025-12-09 22:17:46.403336
2598	sensor_rabano_1	23.04	63.80	68.02	1.84	6.43	191.44	427.11	2025-12-09 22:17:56.414769
2599	sensor_rabano_2	22.94	59.71	68.77	1.40	6.48	60.89	447.34	2025-12-09 22:17:56.415824
2600	sensor_cilantro_1	19.88	68.48	68.61	1.63	6.64	190.59	484.31	2025-12-09 22:17:56.416084
2601	sensor_cilantro_2	22.11	67.50	67.29	1.45	6.52	110.10	472.73	2025-12-09 22:17:56.416176
2602	sensor_rabano_1	20.42	72.86	63.21	1.85	6.50	78.33	470.91	2025-12-09 22:18:06.427648
2603	sensor_rabano_2	21.42	61.98	63.55	1.44	6.64	158.02	473.25	2025-12-09 22:18:06.428397
2604	sensor_cilantro_1	19.20	68.72	66.95	1.92	6.53	193.26	415.07	2025-12-09 22:18:06.428574
2605	sensor_cilantro_2	19.08	64.78	68.28	1.50	6.75	155.94	481.01	2025-12-09 22:18:06.428717
2606	sensor_rabano_1	21.06	69.80	71.18	1.46	6.64	182.28	460.06	2025-12-09 22:18:16.439517
2607	sensor_rabano_2	23.15	63.08	61.10	1.50	6.70	106.01	431.60	2025-12-09 22:18:16.440232
2608	sensor_cilantro_1	22.97	74.73	65.20	1.80	6.47	153.85	429.72	2025-12-09 22:18:16.440408
2609	sensor_cilantro_2	22.26	69.18	76.65	1.83	6.44	189.59	459.33	2025-12-09 22:18:16.440544
2610	sensor_rabano_1	23.04	72.56	71.40	1.61	6.49	71.97	405.78	2025-12-09 22:18:26.450979
2611	sensor_rabano_2	23.54	66.58	61.68	1.77	6.49	77.96	460.57	2025-12-09 22:18:26.451913
2612	sensor_cilantro_1	19.86	71.97	62.91	1.94	6.45	71.11	495.58	2025-12-09 22:18:26.452177
2613	sensor_cilantro_2	22.11	62.29	66.31	1.68	6.45	128.48	482.81	2025-12-09 22:18:26.452333
2614	sensor_rabano_1	20.44	61.83	61.28	1.43	6.52	140.01	498.34	2025-12-09 22:18:36.464321
2615	sensor_rabano_2	23.68	62.81	69.37	1.56	6.68	188.93	419.60	2025-12-09 22:18:36.465192
2616	sensor_cilantro_1	20.25	73.63	69.93	1.77	6.72	156.45	488.86	2025-12-09 22:18:36.465434
2617	sensor_cilantro_2	20.09	77.41	77.35	1.66	6.60	81.63	428.91	2025-12-09 22:18:36.465601
2618	sensor_rabano_1	22.04	62.54	64.63	1.95	6.76	73.18	465.75	2025-12-09 22:18:46.488669
2619	sensor_rabano_2	20.37	70.63	79.91	1.54	6.42	54.67	476.36	2025-12-09 22:18:46.489389
2620	sensor_cilantro_1	20.96	67.57	60.17	1.82	6.59	141.63	439.29	2025-12-09 22:18:46.489559
2621	sensor_cilantro_2	22.04	72.94	64.17	1.86	6.60	135.65	408.07	2025-12-09 22:18:46.489701
2622	sensor_rabano_1	22.14	60.06	73.55	1.98	6.49	75.79	422.31	2025-12-09 22:18:56.501484
2623	sensor_rabano_2	21.27	65.93	77.49	1.66	6.75	71.36	460.22	2025-12-09 22:18:56.502291
2624	sensor_cilantro_1	20.18	74.52	71.39	1.43	6.45	158.71	484.48	2025-12-09 22:18:56.502515
2625	sensor_cilantro_2	19.11	71.13	75.85	1.63	6.60	115.33	408.77	2025-12-09 22:18:56.50267
2626	sensor_rabano_1	23.16	59.03	63.52	1.45	6.59	113.74	469.36	2025-12-09 22:19:06.512515
2627	sensor_rabano_2	21.66	64.94	60.68	1.82	6.63	143.49	450.16	2025-12-09 22:19:06.513281
2628	sensor_cilantro_1	20.94	65.57	78.06	1.43	6.72	125.97	403.82	2025-12-09 22:19:06.513466
2629	sensor_cilantro_2	19.68	69.19	61.50	1.70	6.51	180.09	479.57	2025-12-09 22:19:06.513608
2630	sensor_rabano_1	21.65	64.25	65.08	1.69	6.52	78.68	481.28	2025-12-09 22:19:16.525377
2631	sensor_rabano_2	21.19	66.73	75.91	1.47	6.63	138.42	407.05	2025-12-09 22:19:16.526094
2632	sensor_cilantro_1	19.09	69.15	70.98	1.52	6.59	154.22	430.91	2025-12-09 22:19:16.526267
2633	sensor_cilantro_2	22.13	70.32	64.92	1.74	6.63	100.36	400.56	2025-12-09 22:19:16.526404
2634	sensor_rabano_1	22.67	65.08	65.60	1.92	6.78	96.62	453.81	2025-12-09 22:19:26.538047
2635	sensor_rabano_2	22.36	63.48	77.59	1.80	6.59	137.64	476.17	2025-12-09 22:19:26.538905
2636	sensor_cilantro_1	22.94	73.14	73.17	1.64	6.47	171.26	477.24	2025-12-09 22:19:26.539135
2637	sensor_cilantro_2	20.64	74.30	66.95	1.78	6.44	184.10	421.84	2025-12-09 22:19:26.539284
2638	sensor_rabano_1	21.97	65.33	73.66	1.72	6.57	87.37	410.78	2025-12-09 22:19:36.550572
2639	sensor_rabano_2	22.05	68.41	79.95	1.52	6.46	111.43	477.16	2025-12-09 22:19:36.551537
2640	sensor_cilantro_1	19.19	70.12	67.23	1.56	6.53	130.24	474.18	2025-12-09 22:19:36.551667
2641	sensor_cilantro_2	20.28	67.40	78.97	1.97	6.71	131.59	469.15	2025-12-09 22:19:36.551733
2642	sensor_rabano_1	23.30	64.94	74.13	1.51	6.78	173.05	492.76	2025-12-09 22:19:46.562516
2643	sensor_rabano_2	23.76	59.50	66.33	1.52	6.59	115.47	464.01	2025-12-09 22:19:46.563179
2644	sensor_cilantro_1	22.45	64.36	70.44	1.74	6.52	69.99	441.93	2025-12-09 22:19:46.563281
2645	sensor_cilantro_2	19.01	71.56	64.79	1.45	6.51	76.65	467.96	2025-12-09 22:19:46.563339
2646	sensor_rabano_1	22.12	69.21	77.15	1.61	6.45	117.40	475.41	2025-12-09 22:19:56.57314
2647	sensor_rabano_2	21.59	66.32	62.36	1.92	6.61	175.20	478.60	2025-12-09 22:19:56.573756
2648	sensor_cilantro_1	22.90	68.87	78.21	1.58	6.41	133.62	477.83	2025-12-09 22:19:56.573839
2649	sensor_cilantro_2	22.92	68.11	68.78	1.85	6.74	62.43	438.97	2025-12-09 22:19:56.573894
2650	sensor_rabano_1	23.21	67.58	75.13	1.48	6.51	67.85	443.91	2025-12-09 22:20:06.585333
2651	sensor_rabano_2	22.89	60.04	62.04	1.65	6.69	88.99	464.19	2025-12-09 22:20:06.586352
2652	sensor_cilantro_1	19.31	63.38	67.76	1.64	6.57	115.51	451.00	2025-12-09 22:20:06.58687
2653	sensor_cilantro_2	22.79	64.37	70.42	1.66	6.66	61.42	467.43	2025-12-09 22:20:06.587129
2654	sensor_rabano_1	21.17	66.99	68.96	1.44	6.45	54.12	485.27	2025-12-09 22:20:16.5988
2655	sensor_rabano_2	22.92	66.33	73.59	1.55	6.43	71.80	405.64	2025-12-09 22:20:16.599603
2656	sensor_cilantro_1	20.45	76.43	74.39	1.61	6.58	106.96	443.15	2025-12-09 22:20:16.5998
2657	sensor_cilantro_2	21.66	74.48	79.86	1.74	6.78	52.64	428.56	2025-12-09 22:20:16.599953
2658	sensor_rabano_1	20.78	69.70	72.95	1.82	6.51	119.01	499.63	2025-12-09 22:20:26.608865
2659	sensor_rabano_2	23.27	70.98	79.15	1.73	6.74	192.68	434.86	2025-12-09 22:20:26.609345
2660	sensor_cilantro_1	20.84	70.10	73.56	1.60	6.51	177.79	458.68	2025-12-09 22:20:26.609581
2661	sensor_cilantro_2	20.59	65.82	67.89	1.90	6.49	132.79	471.64	2025-12-09 22:20:26.609873
2662	sensor_rabano_1	21.30	72.46	73.04	1.69	6.43	94.64	469.97	2025-12-09 22:20:36.619327
2663	sensor_rabano_2	23.96	68.36	64.49	1.64	6.70	127.26	464.09	2025-12-09 22:20:36.619972
2664	sensor_cilantro_1	22.88	71.48	72.25	1.84	6.60	145.82	434.46	2025-12-09 22:20:36.620142
2665	sensor_cilantro_2	22.03	65.17	76.60	1.46	6.77	190.82	437.16	2025-12-09 22:20:36.620221
2666	sensor_rabano_1	23.04	66.28	79.57	1.63	6.66	161.33	441.58	2025-12-09 22:20:46.631381
2667	sensor_rabano_2	22.46	66.87	78.91	1.49	6.45	186.63	446.91	2025-12-09 22:20:46.632136
2668	sensor_cilantro_1	19.48	66.13	68.34	1.80	6.56	152.90	446.25	2025-12-09 22:20:46.632322
2669	sensor_cilantro_2	21.29	62.56	78.64	1.59	6.79	174.96	498.45	2025-12-09 22:20:46.632463
2670	sensor_rabano_1	21.52	65.46	70.90	1.99	6.49	173.77	436.29	2025-12-09 22:20:56.643425
2671	sensor_rabano_2	22.59	65.60	79.10	1.66	6.80	145.79	439.13	2025-12-09 22:20:56.644175
2672	sensor_cilantro_1	21.12	64.58	63.91	1.81	6.66	148.74	461.15	2025-12-09 22:20:56.644347
2673	sensor_cilantro_2	20.54	68.22	68.53	1.60	6.78	95.21	433.85	2025-12-09 22:20:56.644483
2674	sensor_rabano_1	22.43	72.26	62.23	1.80	6.65	102.66	453.44	2025-12-09 22:21:06.65606
2675	sensor_rabano_2	23.00	72.49	76.28	1.70	6.56	161.18	435.90	2025-12-09 22:21:06.656849
2676	sensor_cilantro_1	20.34	77.92	70.67	1.90	6.79	87.44	447.79	2025-12-09 22:21:06.65705
2677	sensor_cilantro_2	20.26	64.11	64.21	1.52	6.73	94.35	424.47	2025-12-09 22:21:06.657192
2678	sensor_rabano_1	22.27	57.66	79.61	1.63	6.41	160.21	400.78	2025-12-09 22:21:16.667769
2679	sensor_rabano_2	23.57	65.81	71.65	1.73	6.63	169.88	402.32	2025-12-09 22:21:16.668434
2680	sensor_cilantro_1	19.86	70.06	73.23	1.89	6.57	196.03	403.87	2025-12-09 22:21:16.668521
2681	sensor_cilantro_2	19.72	69.39	73.57	1.86	6.59	93.19	401.10	2025-12-09 22:21:16.668575
2682	sensor_rabano_1	23.54	70.59	60.32	1.90	6.63	65.18	476.02	2025-12-09 22:21:26.679766
2683	sensor_rabano_2	22.44	60.29	73.87	1.95	6.47	155.85	495.26	2025-12-09 22:21:26.680479
2684	sensor_cilantro_1	22.33	68.38	65.11	1.91	6.45	78.24	482.98	2025-12-09 22:21:26.68065
2685	sensor_cilantro_2	20.32	73.61	74.68	1.83	6.65	74.82	442.09	2025-12-09 22:21:26.680847
2686	sensor_rabano_1	20.05	71.91	79.43	1.90	6.67	139.64	487.35	2025-12-09 22:21:36.692484
2687	sensor_rabano_2	22.50	71.85	66.54	1.73	6.72	104.95	411.82	2025-12-09 22:21:36.693211
2688	sensor_cilantro_1	19.43	73.84	66.60	1.53	6.71	148.83	407.36	2025-12-09 22:21:36.693386
2689	sensor_cilantro_2	20.46	69.34	68.39	1.85	6.78	146.74	484.57	2025-12-09 22:21:36.693521
2690	sensor_rabano_1	23.91	71.17	75.28	1.94	6.75	60.77	442.48	2025-12-09 22:21:46.702457
2691	sensor_rabano_2	21.61	69.87	79.87	1.62	6.47	176.05	463.33	2025-12-09 22:21:46.703084
2692	sensor_cilantro_1	19.23	64.68	69.62	1.43	6.59	110.27	424.16	2025-12-09 22:21:46.703394
2693	sensor_cilantro_2	22.61	68.06	75.98	1.85	6.70	195.37	419.43	2025-12-09 22:21:46.703653
2694	sensor_rabano_1	21.65	61.81	72.30	1.50	6.55	182.37	490.98	2025-12-09 22:21:56.714726
2695	sensor_rabano_2	23.16	57.01	75.46	1.89	6.65	184.25	463.11	2025-12-09 22:21:56.715622
2696	sensor_cilantro_1	21.80	71.05	73.93	1.46	6.52	194.65	453.51	2025-12-09 22:21:56.715873
2697	sensor_cilantro_2	20.39	68.02	64.46	1.44	6.52	106.01	452.06	2025-12-09 22:21:56.716122
2698	sensor_rabano_1	20.63	66.19	78.53	1.42	6.71	179.79	400.59	2025-12-09 22:22:06.726916
2699	sensor_rabano_2	21.04	60.94	74.99	1.75	6.65	60.49	420.00	2025-12-09 22:22:06.727628
2700	sensor_cilantro_1	22.90	65.96	78.41	1.95	6.75	116.44	418.49	2025-12-09 22:22:06.727825
2701	sensor_cilantro_2	20.65	68.66	62.08	1.68	6.50	101.27	469.04	2025-12-09 22:22:06.728068
2702	sensor_rabano_1	20.91	61.26	75.64	1.94	6.75	133.67	474.35	2025-12-09 22:22:16.739524
2703	sensor_rabano_2	20.01	68.13	61.05	1.62	6.78	158.17	477.77	2025-12-09 22:22:16.740251
2704	sensor_cilantro_1	20.43	70.49	62.51	1.83	6.54	141.11	495.72	2025-12-09 22:22:16.74042
2705	sensor_cilantro_2	19.60	74.01	64.89	1.97	6.55	111.61	475.71	2025-12-09 22:22:16.740556
2706	sensor_rabano_1	20.55	60.38	72.90	1.42	6.49	88.29	472.54	2025-12-09 22:22:26.753061
2707	sensor_rabano_2	23.53	63.53	63.13	1.85	6.54	127.41	445.46	2025-12-09 22:22:26.753619
2708	sensor_cilantro_1	19.71	67.42	60.44	1.74	6.72	150.27	450.48	2025-12-09 22:22:26.753731
2709	sensor_cilantro_2	19.61	76.29	75.96	1.69	6.75	66.12	441.31	2025-12-09 22:22:26.753864
2710	sensor_rabano_1	20.46	71.91	61.90	1.91	6.56	84.47	419.49	2025-12-09 22:22:36.765866
2711	sensor_rabano_2	22.22	69.08	72.16	1.85	6.57	68.20	401.83	2025-12-09 22:22:36.766719
2712	sensor_cilantro_1	20.34	63.24	73.56	1.62	6.78	128.30	445.83	2025-12-09 22:22:36.766954
2713	sensor_cilantro_2	20.37	62.86	75.27	1.87	6.52	129.24	442.07	2025-12-09 22:22:36.767114
2714	sensor_rabano_1	23.47	61.62	69.55	1.59	6.65	53.86	443.29	2025-12-09 22:22:46.778603
2715	sensor_rabano_2	23.68	70.01	76.61	1.81	6.65	180.34	450.96	2025-12-09 22:22:46.779556
2716	sensor_cilantro_1	22.69	70.51	64.63	1.71	6.41	74.67	491.77	2025-12-09 22:22:46.779913
2717	sensor_cilantro_2	19.16	70.45	61.40	1.78	6.49	112.73	430.95	2025-12-09 22:22:46.780166
2718	sensor_rabano_1	21.40	62.07	62.08	1.81	6.47	165.45	457.82	2025-12-09 22:22:56.790447
2719	sensor_rabano_2	23.87	60.30	77.54	1.57	6.60	106.45	458.43	2025-12-09 22:22:56.791333
2720	sensor_cilantro_1	20.62	73.42	71.05	1.50	6.45	82.66	495.85	2025-12-09 22:22:56.791518
2721	sensor_cilantro_2	19.56	67.62	73.53	1.90	6.60	127.42	469.71	2025-12-09 22:22:56.79166
2722	sensor_rabano_1	23.36	61.41	62.99	2.00	6.41	184.28	414.91	2025-12-09 22:23:06.803815
2723	sensor_rabano_2	23.37	59.55	74.80	1.86	6.73	166.03	415.89	2025-12-09 22:23:06.804766
2724	sensor_cilantro_1	20.47	74.71	61.20	1.77	6.51	65.79	421.32	2025-12-09 22:23:06.805022
2725	sensor_cilantro_2	20.70	63.67	71.60	1.60	6.77	192.55	490.02	2025-12-09 22:23:06.805182
2726	sensor_rabano_1	22.59	67.52	71.06	1.43	6.73	174.55	471.80	2025-12-09 22:23:16.816792
2727	sensor_rabano_2	20.49	63.08	79.90	1.45	6.57	92.46	460.10	2025-12-09 22:23:16.817725
2728	sensor_cilantro_1	19.14	76.69	61.82	1.46	6.45	168.87	428.59	2025-12-09 22:23:16.817989
2729	sensor_cilantro_2	19.61	62.01	75.14	1.92	6.54	52.86	420.13	2025-12-09 22:23:16.818077
2730	sensor_rabano_1	21.13	67.11	73.78	1.42	6.53	61.61	458.21	2025-12-09 22:23:26.828906
2731	sensor_rabano_2	21.53	60.97	77.80	1.82	6.56	106.63	413.91	2025-12-09 22:23:26.8298
2732	sensor_cilantro_1	20.74	77.18	68.88	1.70	6.66	128.53	488.09	2025-12-09 22:23:26.830062
2733	sensor_cilantro_2	20.23	62.85	71.09	1.91	6.48	111.67	499.59	2025-12-09 22:23:26.830153
2734	sensor_rabano_1	20.32	62.07	79.23	1.56	6.45	175.04	434.52	2025-12-09 22:23:36.841272
2735	sensor_rabano_2	23.50	61.37	75.90	1.70	6.42	166.64	404.17	2025-12-09 22:23:36.842054
2736	sensor_cilantro_1	19.10	71.84	72.59	1.61	6.53	61.90	408.98	2025-12-09 22:23:36.842239
2737	sensor_cilantro_2	21.86	75.75	65.26	1.75	6.77	108.29	438.32	2025-12-09 22:23:36.842383
2738	sensor_rabano_1	21.39	58.94	73.48	1.85	6.79	66.88	435.76	2025-12-09 22:23:46.862445
2739	sensor_rabano_2	21.05	68.15	78.75	1.75	6.54	184.12	433.02	2025-12-09 22:23:46.862926
2740	sensor_cilantro_1	19.83	73.54	79.13	1.51	6.50	174.16	484.73	2025-12-09 22:23:46.863097
2741	sensor_cilantro_2	21.31	73.14	68.02	1.80	6.77	97.97	468.63	2025-12-09 22:23:46.863159
2742	sensor_rabano_1	23.44	60.84	76.07	1.45	6.49	197.97	432.49	2025-12-09 22:23:56.874087
2743	sensor_rabano_2	21.49	57.92	69.45	1.71	6.62	89.73	464.05	2025-12-09 22:23:56.875119
2744	sensor_cilantro_1	21.95	71.72	60.03	1.51	6.61	187.69	485.39	2025-12-09 22:23:56.875362
2745	sensor_cilantro_2	22.84	64.12	76.04	1.95	6.54	111.13	440.85	2025-12-09 22:23:56.875565
2746	sensor_rabano_1	21.98	68.32	72.09	1.99	6.43	177.01	428.26	2025-12-09 22:24:06.88595
2747	sensor_rabano_2	20.85	69.19	72.63	1.44	6.51	178.80	432.73	2025-12-09 22:24:06.886748
2748	sensor_cilantro_1	20.61	72.06	69.97	1.94	6.77	120.53	481.22	2025-12-09 22:24:06.886996
2749	sensor_cilantro_2	20.22	69.29	71.57	1.95	6.55	67.96	461.97	2025-12-09 22:24:06.887141
2750	sensor_rabano_1	22.30	60.65	65.65	1.93	6.57	197.56	464.17	2025-12-09 22:24:16.897683
2751	sensor_rabano_2	20.65	59.63	61.91	1.72	6.73	109.84	496.30	2025-12-09 22:24:16.898436
2752	sensor_cilantro_1	19.58	77.51	71.69	1.58	6.41	98.27	452.42	2025-12-09 22:24:16.898527
2753	sensor_cilantro_2	21.72	67.68	66.50	1.62	6.78	82.75	431.17	2025-12-09 22:24:16.898584
2754	sensor_rabano_1	21.20	71.19	61.37	1.64	6.45	66.11	400.80	2025-12-09 22:24:26.909754
2755	sensor_rabano_2	21.94	71.64	60.81	1.84	6.45	147.82	452.59	2025-12-09 22:24:26.91053
2756	sensor_cilantro_1	21.20	73.75	65.75	1.86	6.69	78.04	468.29	2025-12-09 22:24:26.910717
2757	sensor_cilantro_2	21.18	68.62	77.97	1.68	6.52	137.33	477.36	2025-12-09 22:24:26.910872
2758	sensor_rabano_1	22.22	60.35	69.68	1.58	6.77	51.72	403.90	2025-12-09 22:24:36.92184
2759	sensor_rabano_2	22.84	59.83	64.55	1.97	6.72	63.37	416.04	2025-12-09 22:24:36.92259
2760	sensor_cilantro_1	22.05	69.06	64.68	1.82	6.48	114.80	442.69	2025-12-09 22:24:36.922743
2761	sensor_cilantro_2	20.18	68.55	75.07	1.52	6.55	183.72	458.74	2025-12-09 22:24:36.922868
2762	sensor_rabano_1	22.71	58.61	78.37	1.45	6.61	144.92	425.80	2025-12-09 22:24:46.934305
2763	sensor_rabano_2	22.99	59.92	74.40	1.69	6.71	132.48	474.42	2025-12-09 22:24:46.935149
2764	sensor_cilantro_1	21.97	73.50	77.03	1.59	6.66	97.91	410.34	2025-12-09 22:24:46.935373
2765	sensor_cilantro_2	22.63	75.69	77.22	1.47	6.47	184.94	497.87	2025-12-09 22:24:46.935587
2766	sensor_rabano_1	20.64	65.26	75.21	1.66	6.70	144.81	465.85	2025-12-09 22:24:56.945891
2767	sensor_rabano_2	23.84	66.57	70.30	1.95	6.43	137.38	491.20	2025-12-09 22:24:56.946637
2768	sensor_cilantro_1	20.92	69.60	72.67	1.44	6.70	56.45	409.39	2025-12-09 22:24:56.94682
2769	sensor_cilantro_2	21.98	67.09	60.06	1.82	6.68	179.72	413.70	2025-12-09 22:24:56.946981
2770	sensor_rabano_1	23.13	64.74	61.10	1.73	6.60	197.01	454.26	2025-12-09 22:25:06.957318
2771	sensor_rabano_2	21.66	72.96	60.00	1.45	6.54	190.29	474.62	2025-12-09 22:25:06.958161
2772	sensor_cilantro_1	22.30	69.26	66.94	1.56	6.63	189.63	498.53	2025-12-09 22:25:06.958349
2773	sensor_cilantro_2	20.32	75.29	79.58	1.55	6.57	175.39	456.21	2025-12-09 22:25:06.958486
2774	sensor_rabano_1	21.72	71.05	79.89	1.69	6.79	145.29	496.67	2025-12-09 22:25:16.968648
2775	sensor_rabano_2	22.13	67.69	73.47	1.72	6.43	138.11	458.57	2025-12-09 22:25:16.969466
2776	sensor_cilantro_1	19.27	71.93	78.18	1.75	6.74	169.01	497.35	2025-12-09 22:25:16.969662
2777	sensor_cilantro_2	22.02	65.83	72.31	1.69	6.71	134.86	447.70	2025-12-09 22:25:16.969826
2778	sensor_rabano_1	23.85	57.59	74.69	1.63	6.61	110.17	418.83	2025-12-09 22:25:26.979007
2779	sensor_rabano_2	20.12	61.76	67.18	1.92	6.48	61.99	412.92	2025-12-09 22:25:26.979511
2780	sensor_cilantro_1	22.64	71.60	76.17	1.47	6.64	155.19	417.99	2025-12-09 22:25:26.979593
2781	sensor_cilantro_2	19.59	77.29	60.81	1.95	6.77	63.86	456.57	2025-12-09 22:25:26.979647
2782	sensor_rabano_1	20.59	63.42	73.41	1.66	6.50	84.32	452.20	2025-12-09 22:25:36.989654
2783	sensor_rabano_2	20.10	65.84	65.34	1.74	6.63	117.36	485.92	2025-12-09 22:25:36.990339
2784	sensor_cilantro_1	22.09	65.23	62.85	1.60	6.61	76.49	463.26	2025-12-09 22:25:36.990442
2785	sensor_cilantro_2	19.76	70.92	61.93	1.71	6.58	188.85	428.15	2025-12-09 22:25:36.9905
2786	sensor_rabano_1	23.36	72.86	63.28	1.65	6.53	171.71	425.19	2025-12-09 23:21:38.539246
2787	sensor_rabano_2	23.90	66.15	69.20	1.89	6.61	53.51	427.47	2025-12-09 23:21:38.541009
2788	sensor_cilantro_1	19.00	67.79	74.41	1.58	6.51	81.09	451.25	2025-12-09 23:21:38.541235
2789	sensor_cilantro_2	21.19	69.00	71.69	1.72	6.66	148.49	436.20	2025-12-09 23:21:38.541402
2790	sensor_rabano_1	23.58	58.64	66.44	1.80	6.76	199.14	426.21	2025-12-09 23:21:48.551572
2791	sensor_rabano_2	23.86	66.81	67.54	1.59	6.43	89.38	496.45	2025-12-09 23:21:48.552448
2792	sensor_cilantro_1	20.76	73.08	76.98	1.83	6.62	119.79	454.44	2025-12-09 23:21:48.552626
2793	sensor_cilantro_2	19.03	71.89	77.39	1.69	6.58	70.34	452.72	2025-12-09 23:21:48.552834
2794	sensor_rabano_1	23.45	61.90	62.56	1.91	6.76	91.22	425.24	2025-12-09 23:21:58.563309
2795	sensor_rabano_2	21.58	70.23	62.30	1.98	6.79	191.07	404.04	2025-12-09 23:21:58.564137
2796	sensor_cilantro_1	19.10	70.42	75.33	1.83	6.55	55.65	482.95	2025-12-09 23:21:58.564349
2797	sensor_cilantro_2	20.92	76.12	76.46	1.83	6.61	75.66	418.97	2025-12-09 23:21:58.564497
2798	sensor_rabano_1	22.97	66.51	71.19	1.58	6.75	138.20	453.37	2025-12-09 23:22:08.575786
2799	sensor_rabano_2	23.52	59.69	77.83	1.52	6.58	169.79	451.80	2025-12-09 23:22:08.576793
2800	sensor_cilantro_1	22.57	62.31	67.21	1.45	6.48	193.59	451.38	2025-12-09 23:22:08.576941
2801	sensor_cilantro_2	22.28	66.66	69.53	1.85	6.44	115.34	442.97	2025-12-09 23:22:08.577011
2802	sensor_rabano_1	22.06	59.45	76.18	1.73	6.79	128.14	437.32	2025-12-09 23:22:18.588749
2803	sensor_rabano_2	20.87	58.48	62.83	1.56	6.71	154.34	405.09	2025-12-09 23:22:18.589549
2804	sensor_cilantro_1	22.58	70.71	79.07	1.53	6.59	79.67	479.81	2025-12-09 23:22:18.589824
2805	sensor_cilantro_2	20.09	68.60	72.33	1.54	6.58	170.36	428.50	2025-12-09 23:22:18.590024
2806	sensor_rabano_1	23.87	61.39	72.81	1.83	6.45	155.71	413.13	2025-12-09 23:22:28.601713
2807	sensor_rabano_2	21.65	61.11	61.88	1.72	6.59	51.85	435.87	2025-12-09 23:22:28.602586
2808	sensor_cilantro_1	19.81	71.56	78.78	1.54	6.46	99.48	412.42	2025-12-09 23:22:28.602839
2809	sensor_cilantro_2	20.53	75.31	69.90	1.49	6.79	71.65	421.66	2025-12-09 23:22:28.603007
2810	sensor_rabano_1	20.65	67.27	67.46	1.59	6.69	189.28	448.06	2025-12-09 23:22:38.614836
2811	sensor_rabano_2	20.42	59.05	67.42	1.50	6.73	148.52	455.39	2025-12-09 23:22:38.615907
2812	sensor_cilantro_1	21.99	73.40	65.36	1.52	6.58	177.48	461.27	2025-12-09 23:22:38.616154
2813	sensor_cilantro_2	20.25	72.73	69.87	1.49	6.58	182.47	435.40	2025-12-09 23:22:38.61625
2814	sensor_rabano_1	23.59	59.77	63.18	1.99	6.65	104.30	468.56	2025-12-09 23:22:48.627465
2815	sensor_rabano_2	23.62	68.34	60.11	1.66	6.67	155.19	405.97	2025-12-09 23:22:48.628048
2816	sensor_cilantro_1	19.05	65.00	66.44	1.78	6.79	197.57	446.88	2025-12-09 23:22:48.628136
2817	sensor_cilantro_2	20.00	70.71	63.93	1.70	6.43	173.67	432.15	2025-12-09 23:22:48.628202
2818	sensor_rabano_1	23.78	69.91	60.94	1.96	6.55	99.60	456.59	2025-12-09 23:22:58.639458
2819	sensor_rabano_2	22.41	57.70	70.37	1.75	6.53	194.99	470.20	2025-12-09 23:22:58.64097
2820	sensor_cilantro_1	19.61	68.02	70.08	1.44	6.79	149.39	437.26	2025-12-09 23:22:58.641196
2821	sensor_cilantro_2	20.12	69.99	62.80	1.40	6.57	105.74	431.59	2025-12-09 23:22:58.641271
2822	sensor_rabano_1	23.42	63.54	62.59	1.95	6.52	193.88	473.96	2025-12-09 23:23:08.652371
2823	sensor_rabano_2	23.77	61.69	62.65	1.95	6.50	103.67	409.52	2025-12-09 23:23:08.653259
2824	sensor_cilantro_1	22.35	77.39	66.27	1.66	6.46	192.40	467.51	2025-12-09 23:23:08.653496
2825	sensor_cilantro_2	19.32	63.01	69.37	1.41	6.47	78.68	413.66	2025-12-09 23:23:08.65372
2826	sensor_rabano_1	20.79	69.05	62.83	1.54	6.53	112.57	407.83	2025-12-09 23:23:18.6656
2827	sensor_rabano_2	20.39	69.27	71.89	1.61	6.44	98.53	477.95	2025-12-09 23:23:18.666466
2828	sensor_cilantro_1	19.75	63.22	62.02	1.71	6.79	140.59	438.50	2025-12-09 23:23:18.666657
2829	sensor_cilantro_2	21.73	69.57	65.86	1.87	6.43	173.91	477.73	2025-12-09 23:23:18.666864
2830	sensor_rabano_1	21.46	61.93	74.99	1.93	6.69	153.41	451.45	2025-12-09 23:23:28.67845
2831	sensor_rabano_2	22.68	70.63	64.10	1.68	6.49	92.67	403.48	2025-12-09 23:23:28.679219
2832	sensor_cilantro_1	21.75	63.37	70.33	1.75	6.65	148.67	414.73	2025-12-09 23:23:28.679398
2833	sensor_cilantro_2	20.31	62.35	77.86	1.88	6.55	127.36	423.96	2025-12-09 23:23:28.679538
2834	sensor_rabano_1	20.59	62.83	76.23	1.94	6.57	198.38	406.10	2025-12-09 23:23:38.689837
2835	sensor_rabano_2	21.08	72.69	65.87	1.96	6.71	56.71	468.17	2025-12-09 23:23:38.690635
2836	sensor_cilantro_1	21.04	67.52	69.05	1.76	6.78	52.77	450.41	2025-12-09 23:23:38.690825
2837	sensor_cilantro_2	21.14	71.57	69.52	1.50	6.49	196.84	404.96	2025-12-09 23:23:38.690976
2838	sensor_rabano_1	23.88	66.07	75.48	1.96	6.46	111.56	413.13	2025-12-09 23:23:48.702538
2839	sensor_rabano_2	23.32	59.79	73.27	1.70	6.77	71.64	495.85	2025-12-09 23:23:48.703447
2840	sensor_cilantro_1	22.64	75.01	79.75	1.45	6.79	142.91	403.63	2025-12-09 23:23:48.70364
2841	sensor_cilantro_2	20.58	71.42	69.79	1.67	6.58	181.28	460.92	2025-12-09 23:23:48.703812
2842	sensor_rabano_1	21.73	64.64	77.88	1.78	6.68	186.93	422.04	2025-12-09 23:23:58.714984
2843	sensor_rabano_2	23.03	69.72	64.35	1.46	6.73	64.40	461.14	2025-12-09 23:23:58.715827
2844	sensor_cilantro_1	21.28	69.68	60.98	1.51	6.75	178.23	492.07	2025-12-09 23:23:58.716019
2845	sensor_cilantro_2	20.51	76.53	72.56	1.95	6.56	93.18	406.13	2025-12-09 23:23:58.716166
2846	sensor_rabano_1	23.89	69.01	67.86	1.85	6.64	189.12	457.16	2025-12-09 23:24:08.725488
2847	sensor_rabano_2	20.03	66.20	68.12	1.77	6.55	88.07	451.29	2025-12-09 23:24:08.726469
2848	sensor_cilantro_1	21.14	63.17	64.85	1.92	6.48	70.70	460.15	2025-12-09 23:24:08.726677
2849	sensor_cilantro_2	20.18	68.15	73.06	1.53	6.56	136.24	405.41	2025-12-09 23:24:08.726885
2850	sensor_rabano_1	21.14	59.24	69.35	1.61	6.73	186.78	452.27	2025-12-09 23:24:18.738447
2851	sensor_rabano_2	22.64	58.04	68.41	1.89	6.59	149.18	459.70	2025-12-09 23:24:18.739273
2852	sensor_cilantro_1	21.88	69.23	69.67	1.96	6.78	108.77	458.92	2025-12-09 23:24:18.739482
2853	sensor_cilantro_2	21.45	69.21	75.92	1.62	6.67	93.56	412.10	2025-12-09 23:24:18.739662
2854	sensor_rabano_1	20.77	64.17	63.05	1.77	6.75	107.84	488.20	2025-12-09 23:24:28.749157
2855	sensor_rabano_2	20.12	68.37	64.52	1.94	6.55	76.53	468.46	2025-12-09 23:24:28.749687
2856	sensor_cilantro_1	19.05	76.56	64.10	1.73	6.74	85.75	454.46	2025-12-09 23:24:28.749772
2857	sensor_cilantro_2	22.43	71.76	71.83	1.68	6.70	179.41	491.48	2025-12-09 23:24:28.749831
2858	sensor_rabano_1	23.63	69.60	75.85	1.70	6.63	87.92	439.00	2025-12-09 23:24:38.760261
2859	sensor_rabano_2	22.07	68.11	74.69	1.90	6.63	71.14	457.95	2025-12-09 23:24:38.761144
2860	sensor_cilantro_1	19.54	74.71	67.63	1.67	6.47	191.16	435.92	2025-12-09 23:24:38.761374
2861	sensor_cilantro_2	22.33	69.89	66.24	1.70	6.70	174.65	489.76	2025-12-09 23:24:38.761541
2862	sensor_rabano_1	20.91	62.02	72.19	1.74	6.72	99.50	427.03	2025-12-09 23:24:48.773796
2863	sensor_rabano_2	20.15	65.42	63.31	1.52	6.54	187.66	416.62	2025-12-09 23:24:48.774687
2864	sensor_cilantro_1	20.08	70.54	67.83	1.77	6.62	104.70	495.15	2025-12-09 23:24:48.774931
2865	sensor_cilantro_2	19.86	65.78	67.90	1.51	6.41	75.40	447.24	2025-12-09 23:24:48.775189
2866	sensor_rabano_1	23.47	58.12	60.08	1.65	6.42	143.19	426.96	2025-12-09 23:24:58.785486
2867	sensor_rabano_2	21.99	69.68	66.14	1.94	6.72	173.27	464.91	2025-12-09 23:24:58.786432
2868	sensor_cilantro_1	19.51	67.70	78.85	1.82	6.53	194.63	457.60	2025-12-09 23:24:58.786632
2869	sensor_cilantro_2	22.59	70.35	71.11	1.99	6.50	73.92	406.06	2025-12-09 23:24:58.786863
2870	sensor_rabano_1	23.83	58.12	66.25	1.76	6.77	62.72	409.44	2025-12-09 23:25:08.798158
2871	sensor_rabano_2	21.49	69.13	74.33	1.69	6.57	100.31	476.82	2025-12-09 23:25:08.798948
2872	sensor_cilantro_1	21.04	76.25	76.37	1.46	6.40	179.56	419.24	2025-12-09 23:25:08.799135
2873	sensor_cilantro_2	20.56	64.37	61.20	1.97	6.62	62.83	402.19	2025-12-09 23:25:08.79928
2874	sensor_rabano_1	23.17	58.48	61.49	1.54	6.70	102.94	417.31	2025-12-09 23:25:18.810819
2875	sensor_rabano_2	23.54	65.10	63.18	1.41	6.52	117.07	454.78	2025-12-09 23:25:18.811657
2876	sensor_cilantro_1	21.44	70.27	63.14	1.57	6.55	130.67	458.40	2025-12-09 23:25:18.811857
2877	sensor_cilantro_2	21.98	64.05	67.39	1.59	6.49	149.98	437.11	2025-12-09 23:25:18.812077
2878	sensor_rabano_1	23.38	57.23	72.96	1.77	6.69	89.08	461.42	2025-12-09 23:25:28.821512
2879	sensor_rabano_2	23.83	61.61	79.71	1.99	6.67	162.36	435.98	2025-12-09 23:25:28.822159
2880	sensor_cilantro_1	22.10	71.76	78.30	1.76	6.76	100.77	419.34	2025-12-09 23:25:28.822263
2881	sensor_cilantro_2	22.79	73.67	65.05	1.70	6.68	59.48	494.93	2025-12-09 23:25:28.822324
2882	sensor_rabano_1	22.03	64.22	73.77	1.52	6.76	149.70	424.38	2025-12-09 23:25:38.831947
2883	sensor_rabano_2	22.65	72.72	64.58	1.77	6.45	93.14	481.43	2025-12-09 23:25:38.832724
2884	sensor_cilantro_1	21.12	68.32	68.20	1.92	6.52	190.06	462.37	2025-12-09 23:25:38.832908
2885	sensor_cilantro_2	21.56	65.13	62.22	1.96	6.56	106.30	415.94	2025-12-09 23:25:38.83305
2886	sensor_rabano_1	23.49	67.44	76.66	1.45	6.75	81.93	408.44	2025-12-09 23:25:48.843668
2887	sensor_rabano_2	20.40	60.56	70.31	1.49	6.50	70.74	435.89	2025-12-09 23:25:48.84448
2888	sensor_cilantro_1	21.71	75.89	73.98	1.51	6.70	181.74	467.45	2025-12-09 23:25:48.844743
2889	sensor_cilantro_2	21.16	70.36	71.71	1.50	6.60	84.18	473.12	2025-12-09 23:25:48.844909
2890	sensor_rabano_1	23.33	68.03	64.48	1.99	6.51	170.28	481.29	2025-12-09 23:25:58.856283
2891	sensor_rabano_2	23.24	58.97	69.47	1.87	6.56	53.06	441.42	2025-12-09 23:25:58.85719
2892	sensor_cilantro_1	21.27	63.84	60.37	1.82	6.51	164.55	469.18	2025-12-09 23:25:58.857416
2893	sensor_cilantro_2	19.22	68.35	62.58	1.72	6.54	82.91	496.26	2025-12-09 23:25:58.857625
2894	sensor_rabano_1	21.82	67.88	73.55	1.55	6.71	171.98	430.71	2025-12-09 23:26:08.867913
2895	sensor_rabano_2	22.33	62.41	79.43	1.82	6.67	148.88	456.19	2025-12-09 23:26:08.868616
2896	sensor_cilantro_1	20.40	68.22	73.06	1.52	6.47	192.77	443.76	2025-12-09 23:26:08.868717
2897	sensor_cilantro_2	22.25	72.83	77.81	1.84	6.44	173.85	410.64	2025-12-09 23:26:08.868776
2898	sensor_rabano_1	20.49	63.05	68.57	1.68	6.53	68.76	448.81	2025-12-09 23:26:18.880281
2899	sensor_rabano_2	22.32	57.75	74.53	1.61	6.70	196.65	454.73	2025-12-09 23:26:18.881071
2900	sensor_cilantro_1	20.55	75.17	67.93	1.42	6.43	198.71	482.72	2025-12-09 23:26:18.881257
2901	sensor_cilantro_2	20.00	77.65	79.95	1.53	6.47	63.29	427.89	2025-12-09 23:26:18.881398
2902	sensor_rabano_1	21.78	71.83	75.51	1.63	6.71	112.16	418.11	2025-12-09 23:26:28.892713
2903	sensor_rabano_2	21.08	71.50	62.71	1.79	6.76	73.32	419.99	2025-12-09 23:26:28.893542
2904	sensor_cilantro_1	19.10	73.82	79.03	1.86	6.76	131.46	439.13	2025-12-09 23:26:28.89379
2905	sensor_cilantro_2	20.50	69.31	74.64	1.63	6.55	106.15	487.58	2025-12-09 23:26:28.893992
2906	sensor_rabano_1	23.88	61.23	70.46	2.00	6.52	113.71	429.33	2025-12-09 23:26:38.905852
2907	sensor_rabano_2	22.77	63.34	70.56	1.72	6.66	83.34	434.73	2025-12-09 23:26:38.906685
2908	sensor_cilantro_1	19.48	67.85	71.59	1.84	6.61	131.23	497.17	2025-12-09 23:26:38.906874
2909	sensor_cilantro_2	22.73	68.36	69.29	1.45	6.73	121.36	402.29	2025-12-09 23:26:38.907015
2910	sensor_rabano_1	23.16	58.71	71.34	1.62	6.52	84.17	441.08	2025-12-09 23:26:48.933567
2911	sensor_rabano_2	23.36	69.09	71.45	1.47	6.61	196.95	442.17	2025-12-09 23:26:48.934464
2912	sensor_cilantro_1	22.44	72.79	65.34	1.73	6.67	71.81	454.29	2025-12-09 23:26:48.934659
2913	sensor_cilantro_2	19.35	65.66	76.62	1.68	6.61	52.31	474.94	2025-12-09 23:26:48.934884
2914	sensor_rabano_1	21.56	63.17	63.42	1.82	6.73	112.36	443.94	2025-12-09 23:26:58.946691
2915	sensor_rabano_2	23.04	59.31	71.44	1.73	6.67	127.09	487.19	2025-12-09 23:26:58.947505
2916	sensor_cilantro_1	22.62	62.47	67.58	1.45	6.51	56.87	446.50	2025-12-09 23:26:58.947748
2917	sensor_cilantro_2	19.09	71.11	71.37	1.67	6.69	53.15	472.63	2025-12-09 23:26:58.947958
2918	sensor_rabano_1	21.11	59.18	68.11	1.49	6.45	75.32	485.54	2025-12-09 23:27:08.959036
2919	sensor_rabano_2	22.75	59.13	72.62	1.41	6.53	126.13	425.48	2025-12-09 23:27:08.959772
2920	sensor_cilantro_1	21.46	73.95	71.81	1.60	6.42	96.54	417.78	2025-12-09 23:27:08.959951
2921	sensor_cilantro_2	20.96	69.42	73.66	1.91	6.47	55.00	446.05	2025-12-09 23:27:08.960034
2922	sensor_rabano_1	22.51	57.15	74.74	1.56	6.75	86.37	448.75	2025-12-09 23:27:18.971025
2923	sensor_rabano_2	22.79	60.53	79.82	1.71	6.70	52.77	482.76	2025-12-09 23:27:18.971937
2924	sensor_cilantro_1	21.86	67.25	65.82	1.42	6.56	77.06	429.26	2025-12-09 23:27:18.972212
2925	sensor_cilantro_2	20.19	71.29	77.71	1.59	6.57	117.43	411.35	2025-12-09 23:27:18.97242
2926	sensor_rabano_1	20.16	65.19	68.51	1.84	6.58	113.12	473.03	2025-12-09 23:27:28.984072
2927	sensor_rabano_2	23.90	58.97	76.35	1.46	6.69	151.46	492.87	2025-12-09 23:27:28.984865
2928	sensor_cilantro_1	19.31	70.07	62.79	1.79	6.76	83.01	470.32	2025-12-09 23:27:28.985048
2929	sensor_cilantro_2	21.14	74.05	76.38	1.93	6.66	171.89	420.49	2025-12-09 23:27:28.985191
2930	sensor_rabano_1	20.68	69.38	74.89	1.51	6.53	90.83	414.60	2025-12-09 23:27:38.995372
2931	sensor_rabano_2	22.06	64.78	70.98	1.71	6.48	73.09	466.50	2025-12-09 23:27:38.996129
2932	sensor_cilantro_1	21.99	72.89	78.10	1.44	6.45	86.94	428.36	2025-12-09 23:27:38.996304
2933	sensor_cilantro_2	19.78	62.37	68.32	1.91	6.42	119.75	497.74	2025-12-09 23:27:38.996443
2934	sensor_rabano_1	22.40	61.02	68.51	1.73	6.78	109.98	436.30	2025-12-09 23:27:49.008052
2935	sensor_rabano_2	23.01	58.65	61.62	1.94	6.63	145.46	427.12	2025-12-09 23:27:49.008835
2936	sensor_cilantro_1	19.40	70.05	68.73	1.42	6.60	94.75	440.45	2025-12-09 23:27:49.009021
2937	sensor_cilantro_2	20.82	76.50	77.40	1.89	6.48	93.81	456.06	2025-12-09 23:27:49.009162
2938	sensor_rabano_1	22.98	57.71	79.69	1.53	6.41	95.57	477.16	2025-12-09 23:27:59.019336
2939	sensor_rabano_2	22.91	69.22	71.99	1.95	6.56	150.35	409.71	2025-12-09 23:27:59.020126
2940	sensor_cilantro_1	20.63	69.91	70.34	1.96	6.41	143.44	489.15	2025-12-09 23:27:59.020317
2941	sensor_cilantro_2	19.88	69.31	65.60	1.52	6.47	77.52	400.32	2025-12-09 23:27:59.020462
2942	sensor_rabano_1	20.25	58.31	79.09	1.50	6.60	156.83	454.86	2025-12-09 23:28:09.030498
2943	sensor_rabano_2	23.81	59.34	65.97	1.81	6.77	97.71	413.44	2025-12-09 23:28:09.031399
2944	sensor_cilantro_1	22.48	63.93	76.49	1.98	6.47	112.97	449.19	2025-12-09 23:28:09.03159
2945	sensor_cilantro_2	22.12	66.77	78.75	1.54	6.68	51.87	419.52	2025-12-09 23:28:09.031842
2946	sensor_rabano_1	20.25	69.07	61.32	1.98	6.74	149.46	443.71	2025-12-09 23:28:19.043749
2947	sensor_rabano_2	20.93	66.49	72.99	1.90	6.78	118.79	485.35	2025-12-09 23:28:19.044553
2948	sensor_cilantro_1	21.13	63.24	64.26	1.76	6.67	58.49	415.35	2025-12-09 23:28:19.044798
2949	sensor_cilantro_2	19.67	63.12	75.08	1.49	6.80	171.70	464.28	2025-12-09 23:28:19.045
2950	sensor_rabano_1	22.81	59.47	73.06	1.75	6.79	123.06	473.03	2025-12-09 23:28:29.056819
2951	sensor_rabano_2	23.08	61.01	60.00	1.76	6.51	177.33	417.09	2025-12-09 23:28:29.05758
2952	sensor_cilantro_1	20.08	76.03	71.84	1.41	6.77	60.48	483.36	2025-12-09 23:28:29.057738
2953	sensor_cilantro_2	20.05	77.26	65.83	1.61	6.44	180.66	433.30	2025-12-09 23:28:29.057809
2954	sensor_rabano_1	21.43	71.23	73.40	1.51	6.59	185.26	471.68	2025-12-09 23:28:39.067885
2955	sensor_rabano_2	21.68	68.29	79.48	1.68	6.55	113.71	495.72	2025-12-09 23:28:39.068757
2956	sensor_cilantro_1	21.47	64.95	65.01	1.93	6.72	161.92	481.13	2025-12-09 23:28:39.068946
2957	sensor_cilantro_2	22.43	69.03	64.89	1.74	6.65	93.06	493.50	2025-12-09 23:28:39.069095
2958	sensor_rabano_1	21.73	58.15	69.83	1.95	6.48	173.19	451.81	2025-12-09 23:28:49.080817
2959	sensor_rabano_2	22.79	59.28	61.57	1.53	6.73	88.97	470.10	2025-12-09 23:28:49.081605
2960	sensor_cilantro_1	20.44	68.55	73.25	1.82	6.71	63.45	419.93	2025-12-09 23:28:49.081842
2961	sensor_cilantro_2	20.80	75.16	73.49	1.73	6.52	165.42	451.21	2025-12-09 23:28:49.081991
2962	sensor_rabano_1	20.72	57.71	79.80	1.96	6.64	92.54	415.58	2025-12-09 23:28:59.093637
2963	sensor_rabano_2	22.62	60.51	67.31	1.67	6.49	60.21	495.52	2025-12-09 23:28:59.09444
2964	sensor_cilantro_1	19.15	76.07	77.43	1.74	6.69	115.13	479.23	2025-12-09 23:28:59.094615
2965	sensor_cilantro_2	21.74	64.03	77.49	1.45	6.62	153.92	457.54	2025-12-09 23:28:59.094778
2966	sensor_rabano_1	20.64	57.49	79.08	1.42	6.69	134.65	451.25	2025-12-09 23:29:09.104818
2967	sensor_rabano_2	23.42	58.85	70.95	1.74	6.50	95.29	498.66	2025-12-09 23:29:09.105772
2968	sensor_cilantro_1	22.76	73.87	66.12	1.63	6.78	174.93	457.18	2025-12-09 23:29:09.106052
2969	sensor_cilantro_2	21.92	73.54	77.88	1.68	6.70	63.86	447.26	2025-12-09 23:29:09.106337
2970	sensor_rabano_1	23.83	62.21	62.38	1.98	6.76	140.85	437.46	2025-12-09 23:29:19.11686
2971	sensor_rabano_2	20.66	62.61	70.63	1.71	6.41	64.29	410.59	2025-12-09 23:29:19.117709
2972	sensor_cilantro_1	21.09	73.83	60.09	1.94	6.54	50.44	417.56	2025-12-09 23:29:19.117985
2973	sensor_cilantro_2	22.13	68.76	63.25	1.95	6.77	170.48	472.86	2025-12-09 23:29:19.118149
2974	sensor_rabano_1	20.17	67.00	61.38	1.89	6.61	180.41	453.91	2025-12-09 23:29:29.128491
2975	sensor_rabano_2	22.81	65.63	76.11	1.58	6.71	138.06	496.74	2025-12-09 23:29:29.129334
2976	sensor_cilantro_1	21.09	66.95	72.14	1.86	6.77	69.60	490.73	2025-12-09 23:29:29.129509
2977	sensor_cilantro_2	22.15	71.59	75.04	1.70	6.46	83.38	432.42	2025-12-09 23:29:29.129667
2978	sensor_rabano_1	22.86	67.03	78.64	1.40	6.55	122.49	429.01	2025-12-09 23:29:39.139475
2979	sensor_rabano_2	20.86	70.01	60.32	1.65	6.77	120.35	486.16	2025-12-09 23:29:39.140339
2980	sensor_cilantro_1	21.40	62.44	72.18	1.95	6.67	177.80	448.52	2025-12-09 23:29:39.140529
2981	sensor_cilantro_2	19.63	75.75	68.51	1.97	6.79	83.79	435.49	2025-12-09 23:29:39.140683
2982	sensor_rabano_1	22.18	63.82	79.43	1.43	6.65	140.57	430.83	2025-12-09 23:29:49.150971
2983	sensor_rabano_2	22.95	61.39	63.89	1.86	6.51	180.77	469.43	2025-12-09 23:29:49.151935
2984	sensor_cilantro_1	21.01	62.55	67.20	1.82	6.47	65.96	415.26	2025-12-09 23:29:49.152169
2985	sensor_cilantro_2	21.10	62.65	62.61	1.50	6.77	143.50	493.51	2025-12-09 23:29:49.152322
2986	sensor_rabano_1	20.67	61.89	78.04	1.56	6.57	151.26	469.60	2025-12-09 23:29:59.16367
2987	sensor_rabano_2	22.28	67.85	61.59	1.87	6.53	147.41	480.54	2025-12-09 23:29:59.164809
2988	sensor_cilantro_1	20.13	68.18	75.77	1.65	6.61	76.22	493.33	2025-12-09 23:29:59.165096
2989	sensor_cilantro_2	19.15	76.41	74.82	1.42	6.50	107.67	436.25	2025-12-09 23:29:59.165308
2990	sensor_rabano_1	21.65	67.71	72.61	1.43	6.76	169.67	476.04	2025-12-09 23:30:09.176272
2991	sensor_rabano_2	22.16	71.31	66.63	1.73	6.61	145.07	432.76	2025-12-09 23:30:09.177159
2992	sensor_cilantro_1	19.64	68.90	64.95	1.87	6.65	175.97	433.83	2025-12-09 23:30:09.177389
2993	sensor_cilantro_2	20.31	73.70	72.01	1.65	6.71	133.60	462.48	2025-12-09 23:30:09.177588
2994	sensor_rabano_1	20.64	57.60	71.63	1.95	6.64	91.32	496.89	2025-12-09 23:30:19.189215
2995	sensor_rabano_2	22.25	69.35	62.62	1.85	6.70	122.54	457.44	2025-12-09 23:30:19.190081
2996	sensor_cilantro_1	22.44	72.57	64.56	1.81	6.55	155.49	400.44	2025-12-09 23:30:19.190423
2997	sensor_cilantro_2	22.92	66.44	68.46	1.99	6.58	127.71	418.69	2025-12-09 23:30:19.19059
2998	sensor_rabano_1	23.64	71.10	69.58	1.79	6.56	72.00	481.71	2025-12-09 23:30:29.200825
2999	sensor_rabano_2	22.91	64.33	60.60	1.65	6.58	199.02	423.60	2025-12-09 23:30:29.201689
3000	sensor_cilantro_1	20.82	66.08	63.06	1.86	6.77	99.46	469.39	2025-12-09 23:30:29.201959
3001	sensor_cilantro_2	20.41	74.07	79.33	1.84	6.77	56.10	437.66	2025-12-09 23:30:29.202222
3002	sensor_rabano_1	21.63	58.46	68.60	1.71	6.50	103.51	472.69	2025-12-09 23:30:39.210002
3003	sensor_rabano_2	22.71	72.62	78.19	1.70	6.52	92.33	448.08	2025-12-09 23:30:39.210587
3004	sensor_cilantro_1	19.47	68.27	65.64	1.54	6.51	56.49	493.53	2025-12-09 23:30:39.210669
3005	sensor_cilantro_2	21.10	76.49	79.62	1.52	6.40	187.04	475.92	2025-12-09 23:30:39.210724
3006	sensor_rabano_1	22.10	62.78	73.39	1.94	6.62	80.36	422.53	2025-12-09 23:30:49.220617
3007	sensor_rabano_2	23.07	65.23	68.49	1.56	6.44	160.77	438.35	2025-12-09 23:30:49.221444
3008	sensor_cilantro_1	20.45	77.71	60.11	1.51	6.79	83.65	442.37	2025-12-09 23:30:49.221636
3009	sensor_cilantro_2	22.05	70.54	71.71	1.93	6.69	130.99	483.69	2025-12-09 23:30:49.221791
3010	sensor_rabano_1	23.20	62.04	69.33	1.80	6.76	179.99	470.65	2025-12-09 23:30:59.231811
3011	sensor_rabano_2	23.69	59.49	61.39	1.86	6.65	196.31	469.56	2025-12-09 23:30:59.232408
3012	sensor_cilantro_1	19.90	74.76	79.18	1.97	6.64	109.94	496.15	2025-12-09 23:30:59.232722
3013	sensor_cilantro_2	21.11	69.83	65.60	1.91	6.72	184.07	447.67	2025-12-09 23:30:59.232925
3014	sensor_rabano_1	21.93	59.90	67.04	1.77	6.53	136.52	423.08	2025-12-09 23:31:09.243275
3015	sensor_rabano_2	22.55	63.18	60.94	1.67	6.78	73.29	406.65	2025-12-09 23:31:09.244061
3016	sensor_cilantro_1	20.73	77.13	65.77	1.46	6.75	105.45	413.55	2025-12-09 23:31:09.244253
3017	sensor_cilantro_2	19.94	68.29	65.97	1.94	6.53	137.00	411.78	2025-12-09 23:31:09.2444
3018	sensor_rabano_1	20.82	61.70	71.30	1.61	6.69	62.79	418.46	2025-12-09 23:31:19.254299
3019	sensor_rabano_2	21.67	71.43	62.06	1.55	6.69	158.20	449.47	2025-12-09 23:31:19.255087
3020	sensor_cilantro_1	21.51	73.93	62.60	1.72	6.69	52.90	414.34	2025-12-09 23:31:19.255263
3021	sensor_cilantro_2	21.50	77.37	61.14	1.72	6.44	166.50	458.26	2025-12-09 23:31:19.255401
3022	sensor_rabano_1	22.84	69.26	64.94	1.98	6.41	99.67	429.43	2025-12-09 23:31:29.266179
3023	sensor_rabano_2	22.99	61.66	62.42	1.57	6.71	172.21	487.42	2025-12-09 23:31:29.266865
3024	sensor_cilantro_1	19.97	74.38	64.36	1.84	6.55	91.22	443.70	2025-12-09 23:31:29.267049
3025	sensor_cilantro_2	20.09	71.71	74.90	1.89	6.45	128.40	400.84	2025-12-09 23:31:29.267113
3026	sensor_rabano_1	23.45	61.79	61.68	1.65	6.58	126.02	422.59	2025-12-09 23:31:39.27757
3027	sensor_rabano_2	22.05	58.85	71.39	1.60	6.50	109.45	427.54	2025-12-09 23:31:39.278458
3028	sensor_cilantro_1	21.44	74.86	61.87	1.41	6.47	159.45	405.85	2025-12-09 23:31:39.278643
3029	sensor_cilantro_2	22.54	65.29	65.86	1.86	6.47	68.96	482.67	2025-12-09 23:31:39.278799
3030	sensor_rabano_1	21.39	70.37	78.97	1.86	6.60	135.95	443.70	2025-12-09 23:31:49.303499
3031	sensor_rabano_2	21.49	60.12	63.56	1.49	6.42	79.17	419.75	2025-12-09 23:31:49.304162
3032	sensor_cilantro_1	22.31	63.93	68.49	1.68	6.74	198.76	445.48	2025-12-09 23:31:49.304402
3033	sensor_cilantro_2	20.40	65.92	61.34	1.70	6.51	69.40	463.83	2025-12-09 23:31:49.304579
3034	sensor_rabano_1	20.94	60.95	69.30	1.82	6.76	140.81	456.77	2025-12-09 23:31:59.31485
3035	sensor_rabano_2	22.89	67.58	64.54	1.78	6.74	154.17	444.40	2025-12-09 23:31:59.315669
3036	sensor_cilantro_1	21.66	67.31	79.68	1.83	6.51	105.99	473.10	2025-12-09 23:31:59.31587
3037	sensor_cilantro_2	21.27	64.92	75.94	1.61	6.63	148.39	413.46	2025-12-09 23:31:59.316021
3038	sensor_rabano_1	21.82	66.96	65.99	1.94	6.47	85.38	414.49	2025-12-09 23:32:09.326312
3039	sensor_rabano_2	23.02	65.29	69.24	1.71	6.64	125.20	466.59	2025-12-09 23:32:09.327109
3040	sensor_cilantro_1	19.61	66.12	75.77	1.67	6.72	81.14	406.35	2025-12-09 23:32:09.327293
3041	sensor_cilantro_2	19.58	75.34	73.92	1.60	6.73	182.74	492.02	2025-12-09 23:32:09.327436
3042	sensor_rabano_1	21.48	70.90	61.83	1.99	6.45	99.33	406.60	2025-12-09 23:32:19.337688
3043	sensor_rabano_2	20.50	57.28	69.31	1.55	6.45	79.30	495.13	2025-12-09 23:32:19.338547
3044	sensor_cilantro_1	20.78	71.84	68.96	1.82	6.70	159.19	408.74	2025-12-09 23:32:19.338747
3045	sensor_cilantro_2	20.66	74.90	63.46	1.82	6.44	83.75	406.15	2025-12-09 23:32:19.338959
3046	sensor_rabano_1	22.74	66.60	77.76	1.45	6.68	140.98	422.15	2025-12-09 23:32:29.350483
3047	sensor_rabano_2	21.52	69.57	62.85	1.41	6.49	119.32	483.69	2025-12-09 23:32:29.351284
3048	sensor_cilantro_1	22.52	66.91	63.76	1.48	6.72	182.48	467.37	2025-12-09 23:32:29.351463
3049	sensor_cilantro_2	19.83	73.77	76.58	1.78	6.42	183.00	460.98	2025-12-09 23:32:29.351604
3050	sensor_rabano_1	20.61	61.90	78.70	1.84	6.68	121.19	437.69	2025-12-09 23:32:39.362386
3051	sensor_rabano_2	23.27	70.97	72.27	1.84	6.47	191.60	412.05	2025-12-09 23:32:39.36335
3052	sensor_cilantro_1	21.94	75.34	71.29	1.66	6.57	79.46	419.06	2025-12-09 23:32:39.363509
3053	sensor_cilantro_2	19.04	75.56	70.21	1.45	6.76	162.21	435.27	2025-12-09 23:32:39.363571
3054	sensor_rabano_1	20.38	65.40	77.51	1.79	6.48	96.20	499.79	2025-12-09 23:32:49.373524
3055	sensor_rabano_2	22.97	70.16	60.84	1.46	6.65	97.83	484.27	2025-12-09 23:32:49.374396
3056	sensor_cilantro_1	21.75	73.37	79.05	1.91	6.43	72.05	450.34	2025-12-09 23:32:49.374582
3057	sensor_cilantro_2	19.18	72.85	65.89	1.74	6.43	189.15	457.95	2025-12-09 23:32:49.374738
3058	sensor_rabano_1	21.73	68.64	71.08	1.57	6.63	115.16	498.61	2025-12-09 23:32:59.386204
3059	sensor_rabano_2	21.95	71.59	64.39	1.70	6.43	68.56	497.82	2025-12-09 23:32:59.386779
3060	sensor_cilantro_1	20.85	69.61	73.15	1.63	6.75	171.33	448.39	2025-12-09 23:32:59.386957
3061	sensor_cilantro_2	20.06	74.29	73.24	1.75	6.79	123.91	449.25	2025-12-09 23:32:59.387042
3062	sensor_rabano_1	22.91	64.68	77.82	1.72	6.53	174.35	482.18	2025-12-09 23:33:09.396364
3063	sensor_rabano_2	22.54	61.33	67.33	1.51	6.47	86.87	492.92	2025-12-09 23:33:09.397012
3064	sensor_cilantro_1	19.35	70.98	74.10	1.74	6.45	77.16	444.22	2025-12-09 23:33:09.397114
3065	sensor_cilantro_2	21.96	76.32	76.99	1.48	6.57	149.50	417.26	2025-12-09 23:33:09.397175
3066	sensor_rabano_1	21.28	65.30	72.63	1.46	6.56	95.43	442.39	2025-12-09 23:33:19.409002
3067	sensor_rabano_2	21.77	58.23	60.05	1.96	6.72	122.95	458.31	2025-12-09 23:33:19.409916
3068	sensor_cilantro_1	22.49	76.28	62.93	1.58	6.45	121.87	462.19	2025-12-09 23:33:19.410107
3069	sensor_cilantro_2	21.51	68.92	61.95	1.82	6.45	169.72	409.98	2025-12-09 23:33:19.410251
3070	sensor_rabano_1	21.72	72.24	77.68	1.97	6.54	194.51	423.53	2025-12-09 23:33:29.419483
3071	sensor_rabano_2	22.65	62.11	75.00	1.64	6.50	110.86	401.11	2025-12-09 23:33:29.42009
3072	sensor_cilantro_1	22.19	76.24	73.79	1.94	6.67	80.13	423.39	2025-12-09 23:33:29.420195
3073	sensor_cilantro_2	22.83	67.22	68.63	1.48	6.55	189.05	463.18	2025-12-09 23:33:29.420257
3074	sensor_rabano_1	22.54	66.64	61.34	1.98	6.59	80.14	485.58	2025-12-09 23:33:39.429593
3075	sensor_rabano_2	23.54	62.21	69.35	1.40	6.58	103.06	464.30	2025-12-09 23:33:39.43051
3076	sensor_cilantro_1	19.71	64.12	79.16	1.68	6.77	148.12	403.72	2025-12-09 23:33:39.430761
3077	sensor_cilantro_2	19.75	76.24	71.49	1.60	6.63	199.60	478.46	2025-12-09 23:33:39.430961
3078	sensor_rabano_1	21.20	71.36	66.58	1.47	6.47	131.40	421.36	2025-12-09 23:33:49.441115
3079	sensor_rabano_2	21.84	71.42	66.57	1.85	6.52	68.60	457.57	2025-12-09 23:33:49.441959
3080	sensor_cilantro_1	21.49	62.63	72.91	1.41	6.52	165.96	425.55	2025-12-09 23:33:49.442212
3081	sensor_cilantro_2	22.16	66.71	76.98	1.85	6.74	67.81	458.59	2025-12-09 23:33:49.442415
3082	sensor_rabano_1	22.11	71.50	69.88	1.57	6.54	56.88	489.08	2025-12-09 23:33:59.453887
3083	sensor_rabano_2	23.68	58.37	72.08	1.69	6.80	58.90	485.25	2025-12-09 23:33:59.454808
3084	sensor_cilantro_1	20.08	63.77	65.29	1.83	6.71	104.75	460.82	2025-12-09 23:33:59.455145
3085	sensor_cilantro_2	20.84	66.60	68.34	1.49	6.64	186.44	401.52	2025-12-09 23:33:59.455383
3086	sensor_rabano_1	23.00	64.01	76.41	1.43	6.60	198.12	454.13	2025-12-09 23:34:09.464924
3087	sensor_rabano_2	23.26	70.00	68.58	1.91	6.55	66.64	498.31	2025-12-09 23:34:09.465607
3088	sensor_cilantro_1	22.81	73.22	61.59	1.80	6.72	95.73	442.96	2025-12-09 23:34:09.465724
3089	sensor_cilantro_2	22.67	72.03	76.53	1.87	6.41	95.79	472.37	2025-12-09 23:34:09.465784
3090	sensor_rabano_1	23.27	72.66	68.65	1.43	6.76	126.25	486.60	2025-12-09 23:34:19.473303
3091	sensor_rabano_2	22.58	61.01	71.82	1.42	6.43	78.30	414.89	2025-12-09 23:34:19.473916
3092	sensor_cilantro_1	22.58	70.56	72.62	1.72	6.78	176.35	466.42	2025-12-09 23:34:19.474054
3093	sensor_cilantro_2	19.49	73.94	71.73	1.85	6.60	135.37	408.11	2025-12-09 23:34:19.474175
3094	sensor_rabano_1	21.32	60.67	61.42	1.43	6.49	63.68	406.36	2025-12-09 23:34:29.486028
3095	sensor_rabano_2	21.81	71.03	72.02	1.70	6.74	70.14	454.30	2025-12-09 23:34:29.486966
3096	sensor_cilantro_1	22.23	70.22	72.35	1.91	6.75	84.13	410.05	2025-12-09 23:34:29.487191
3097	sensor_cilantro_2	21.14	73.29	67.98	1.61	6.47	127.24	412.43	2025-12-09 23:34:29.487353
3098	sensor_rabano_1	22.10	68.99	79.56	1.42	6.48	58.54	431.36	2025-12-09 23:34:39.498761
3099	sensor_rabano_2	22.24	72.69	77.66	1.93	6.65	126.90	461.02	2025-12-09 23:34:39.499542
3100	sensor_cilantro_1	21.55	67.05	62.91	1.98	6.74	163.66	481.78	2025-12-09 23:34:39.499794
3101	sensor_cilantro_2	20.08	68.79	66.21	1.69	6.70	131.94	411.03	2025-12-09 23:34:39.500007
3102	sensor_rabano_1	20.59	68.16	63.80	1.57	6.52	137.54	476.79	2025-12-09 23:34:49.510323
3103	sensor_rabano_2	21.44	61.33	67.03	1.90	6.76	199.71	432.33	2025-12-09 23:34:49.511142
3104	sensor_cilantro_1	22.65	71.52	61.44	1.59	6.40	158.52	420.58	2025-12-09 23:34:49.511333
3105	sensor_cilantro_2	19.89	72.22	63.52	1.98	6.65	154.76	496.48	2025-12-09 23:34:49.511477
3106	sensor_rabano_1	20.10	64.59	72.88	1.44	6.70	86.22	408.18	2025-12-09 23:34:59.520851
3107	sensor_rabano_2	20.55	61.96	65.24	1.96	6.41	109.01	420.71	2025-12-09 23:34:59.52185
3108	sensor_cilantro_1	20.40	73.81	66.39	1.92	6.51	193.86	491.05	2025-12-09 23:34:59.522115
3109	sensor_cilantro_2	20.09	69.54	71.32	1.96	6.76	112.29	454.17	2025-12-09 23:34:59.522277
3110	sensor_rabano_1	21.16	65.28	62.97	1.85	6.58	147.53	455.82	2025-12-09 23:35:09.533778
3111	sensor_rabano_2	23.22	70.77	78.85	1.87	6.48	142.99	487.55	2025-12-09 23:35:09.534577
3112	sensor_cilantro_1	19.02	69.02	69.03	1.55	6.42	142.63	488.92	2025-12-09 23:35:09.534768
3113	sensor_cilantro_2	20.33	70.67	70.66	1.42	6.61	103.44	444.25	2025-12-09 23:35:09.534916
3114	sensor_rabano_1	23.40	68.31	74.70	1.67	6.42	102.36	405.51	2025-12-09 23:35:19.546644
3115	sensor_rabano_2	23.10	67.16	75.69	1.70	6.47	129.61	428.12	2025-12-09 23:35:19.547435
3116	sensor_cilantro_1	22.82	66.59	78.27	1.86	6.55	62.28	404.63	2025-12-09 23:35:19.547614
3117	sensor_cilantro_2	22.76	76.26	77.94	1.42	6.51	97.90	461.23	2025-12-09 23:35:19.547768
3118	sensor_rabano_1	23.54	68.40	63.29	1.60	6.47	134.62	456.54	2025-12-09 23:35:29.559458
3119	sensor_rabano_2	21.05	60.08	73.61	1.40	6.44	60.29	491.14	2025-12-09 23:35:29.560379
3120	sensor_cilantro_1	20.84	67.76	75.51	1.50	6.75	159.30	492.25	2025-12-09 23:35:29.560559
3121	sensor_cilantro_2	20.67	62.70	76.34	1.52	6.41	120.40	444.01	2025-12-09 23:35:29.560747
3122	sensor_rabano_1	21.75	59.01	79.53	1.57	6.51	128.96	463.33	2025-12-09 23:35:39.571518
3123	sensor_rabano_2	20.61	64.02	76.79	1.67	6.52	50.50	459.77	2025-12-09 23:35:39.572637
3124	sensor_cilantro_1	20.02	72.12	62.53	1.52	6.73	193.81	412.98	2025-12-09 23:35:39.572902
3125	sensor_cilantro_2	21.16	73.56	60.45	1.42	6.76	142.28	498.04	2025-12-09 23:35:39.573107
3126	sensor_rabano_1	21.75	58.72	74.29	1.85	6.52	110.50	497.50	2025-12-09 23:35:49.584727
3127	sensor_rabano_2	20.90	68.58	67.25	1.87	6.48	82.74	466.22	2025-12-09 23:35:49.585531
3128	sensor_cilantro_1	20.75	72.52	67.02	1.57	6.45	114.18	437.89	2025-12-09 23:35:49.585729
3129	sensor_cilantro_2	20.00	73.24	77.15	1.86	6.69	179.90	432.48	2025-12-09 23:35:49.585883
3130	sensor_rabano_1	23.75	60.59	75.86	1.55	6.74	112.03	458.33	2025-12-09 23:35:59.597777
3131	sensor_rabano_2	20.61	65.76	63.95	1.77	6.65	109.81	430.74	2025-12-09 23:35:59.598656
3132	sensor_cilantro_1	22.12	69.50	61.11	1.97	6.80	114.13	484.93	2025-12-09 23:35:59.598893
3133	sensor_cilantro_2	21.39	71.69	74.38	1.42	6.62	140.10	477.18	2025-12-09 23:35:59.599055
3134	sensor_rabano_1	23.30	62.42	79.01	1.49	6.40	193.02	424.09	2025-12-09 23:36:09.609891
3135	sensor_rabano_2	21.33	67.57	68.10	1.68	6.68	107.50	480.50	2025-12-09 23:36:09.610692
3136	sensor_cilantro_1	20.44	70.72	78.26	1.78	6.64	96.88	425.91	2025-12-09 23:36:09.610802
3137	sensor_cilantro_2	21.95	63.35	60.04	1.45	6.57	61.63	478.67	2025-12-09 23:36:09.610862
3138	sensor_rabano_1	23.17	61.35	64.28	1.40	6.46	122.35	426.03	2025-12-09 23:36:19.622296
3139	sensor_rabano_2	23.45	60.81	63.05	1.81	6.50	149.39	437.94	2025-12-09 23:36:19.623035
3140	sensor_cilantro_1	21.38	63.68	75.14	1.52	6.74	72.36	485.62	2025-12-09 23:36:19.623209
3141	sensor_cilantro_2	19.65	67.38	77.05	1.68	6.50	128.91	489.96	2025-12-09 23:36:19.623349
3142	sensor_rabano_1	20.73	61.06	71.30	1.72	6.62	186.53	442.27	2025-12-09 23:36:29.634596
3143	sensor_rabano_2	20.71	63.36	72.38	1.97	6.56	92.67	405.62	2025-12-09 23:36:29.63549
3144	sensor_cilantro_1	20.65	69.29	63.40	1.68	6.77	72.42	465.44	2025-12-09 23:36:29.635725
3145	sensor_cilantro_2	21.13	63.71	67.19	1.47	6.48	76.70	447.26	2025-12-09 23:36:29.635987
3146	sensor_rabano_1	20.97	66.56	72.88	1.66	6.67	199.79	482.11	2025-12-09 23:36:39.64771
3147	sensor_rabano_2	22.70	69.59	79.94	1.64	6.49	155.20	459.82	2025-12-09 23:36:39.648571
3148	sensor_cilantro_1	22.61	72.44	75.75	1.92	6.69	86.60	419.46	2025-12-09 23:36:39.648862
3149	sensor_cilantro_2	22.33	74.10	63.36	1.61	6.55	166.29	415.04	2025-12-09 23:36:39.649015
3150	sensor_rabano_1	20.35	72.56	79.03	1.65	6.74	127.65	482.45	2025-12-09 23:36:49.673953
3151	sensor_rabano_2	20.53	68.29	65.34	1.45	6.46	140.92	466.64	2025-12-09 23:36:49.674805
3152	sensor_cilantro_1	22.24	77.85	79.57	2.00	6.43	112.36	402.27	2025-12-09 23:36:49.674993
3153	sensor_cilantro_2	22.94	63.78	64.93	1.58	6.49	179.38	491.25	2025-12-09 23:36:49.675137
3154	sensor_rabano_1	22.45	67.08	70.72	1.70	6.76	189.58	475.61	2025-12-09 23:36:59.686685
3155	sensor_rabano_2	21.52	67.65	78.43	1.44	6.61	118.47	428.07	2025-12-09 23:36:59.687501
3156	sensor_cilantro_1	22.14	75.03	69.93	1.70	6.59	190.72	430.11	2025-12-09 23:36:59.687706
3157	sensor_cilantro_2	20.37	68.93	65.42	1.53	6.65	77.93	493.73	2025-12-09 23:36:59.687863
3158	sensor_rabano_1	23.63	59.02	79.50	1.72	6.50	193.26	499.52	2025-12-09 23:37:09.699632
3159	sensor_rabano_2	22.33	57.94	79.63	1.85	6.65	107.84	455.67	2025-12-09 23:37:09.700535
3160	sensor_cilantro_1	22.19	68.22	70.55	1.63	6.51	156.69	491.52	2025-12-09 23:37:09.700796
3161	sensor_cilantro_2	19.04	69.49	62.83	1.45	6.75	139.06	411.10	2025-12-09 23:37:09.701001
3162	sensor_rabano_1	20.67	58.32	62.07	1.54	6.75	82.15	485.12	2025-12-09 23:37:19.712614
3163	sensor_rabano_2	22.77	71.34	66.03	1.78	6.52	171.91	485.50	2025-12-09 23:37:19.71343
3164	sensor_cilantro_1	22.61	69.51	69.37	1.51	6.80	171.65	453.31	2025-12-09 23:37:19.713607
3165	sensor_cilantro_2	22.22	77.04	62.95	1.88	6.61	127.31	487.74	2025-12-09 23:37:19.713759
3166	sensor_rabano_1	23.07	58.29	64.00	1.94	6.76	74.38	490.10	2025-12-09 23:37:29.725617
3167	sensor_rabano_2	23.64	63.99	67.29	1.65	6.72	61.16	482.69	2025-12-09 23:37:29.726507
3168	sensor_cilantro_1	19.83	75.83	73.06	1.81	6.43	168.67	449.73	2025-12-09 23:37:29.726615
3169	sensor_cilantro_2	21.25	66.09	68.17	1.95	6.42	136.08	431.02	2025-12-09 23:37:29.726814
3170	sensor_rabano_1	21.26	66.53	65.51	1.65	6.68	174.04	401.23	2025-12-09 23:37:39.737407
3171	sensor_rabano_2	20.39	66.07	63.79	1.62	6.46	51.91	421.74	2025-12-09 23:37:39.73823
3172	sensor_cilantro_1	19.80	65.63	63.16	1.76	6.77	106.16	439.00	2025-12-09 23:37:39.738455
3173	sensor_cilantro_2	21.45	76.45	63.16	1.78	6.42	64.62	450.42	2025-12-09 23:37:39.73866
3174	sensor_rabano_1	23.47	71.67	73.51	1.82	6.69	155.57	484.60	2025-12-09 23:37:49.750309
3175	sensor_rabano_2	23.27	57.27	77.05	1.53	6.41	97.90	415.79	2025-12-09 23:37:49.751113
3176	sensor_cilantro_1	21.61	76.69	70.78	1.86	6.53	145.42	467.47	2025-12-09 23:37:49.7513
3177	sensor_cilantro_2	19.93	70.31	61.55	1.82	6.40	103.30	489.95	2025-12-09 23:37:49.751512
3178	sensor_rabano_1	20.08	58.93	61.09	1.77	6.42	131.43	410.00	2025-12-09 23:37:59.763357
3179	sensor_rabano_2	22.42	70.72	78.58	1.41	6.61	120.42	498.73	2025-12-09 23:37:59.76437
3180	sensor_cilantro_1	19.47	73.05	65.18	1.51	6.68	192.61	400.43	2025-12-09 23:37:59.764601
3181	sensor_cilantro_2	21.61	73.36	66.82	1.75	6.51	79.55	438.26	2025-12-09 23:37:59.764878
3182	sensor_rabano_1	22.03	67.51	75.50	1.94	6.74	64.73	463.09	2025-12-09 23:38:09.775873
3183	sensor_rabano_2	22.22	59.75	61.00	1.97	6.77	138.74	451.99	2025-12-09 23:38:09.776595
3184	sensor_cilantro_1	19.82	77.32	69.47	1.61	6.45	189.19	432.00	2025-12-09 23:38:09.776775
3185	sensor_cilantro_2	22.78	77.82	68.34	1.42	6.68	157.41	446.62	2025-12-09 23:38:09.77688
3186	sensor_rabano_1	21.19	70.45	68.86	1.51	6.79	140.68	464.33	2025-12-09 23:38:19.78623
3187	sensor_rabano_2	20.96	61.51	68.68	1.65	6.49	117.34	495.57	2025-12-09 23:38:19.78672
3188	sensor_cilantro_1	21.06	66.74	78.80	1.87	6.77	175.21	415.47	2025-12-09 23:38:19.7868
3189	sensor_cilantro_2	19.33	69.86	68.87	1.81	6.78	106.24	419.01	2025-12-09 23:38:19.786855
3190	sensor_rabano_1	20.40	65.90	70.05	1.70	6.64	121.14	403.70	2025-12-09 23:38:29.798869
3191	sensor_rabano_2	22.63	66.90	72.69	1.98	6.44	196.48	497.22	2025-12-09 23:38:29.799721
3192	sensor_cilantro_1	22.77	74.00	78.31	1.50	6.54	110.23	405.03	2025-12-09 23:38:29.79997
3193	sensor_cilantro_2	20.50	74.05	62.58	1.81	6.48	99.17	400.61	2025-12-09 23:38:29.800139
3194	sensor_rabano_1	22.82	64.24	60.76	1.95	6.67	133.65	458.30	2025-12-09 23:38:39.812278
3195	sensor_rabano_2	23.61	71.59	61.90	1.45	6.49	85.85	464.45	2025-12-09 23:38:39.81312
3196	sensor_cilantro_1	20.28	75.38	77.21	1.74	6.75	54.58	400.69	2025-12-09 23:38:39.813315
3197	sensor_cilantro_2	20.94	65.79	66.96	1.60	6.62	165.04	433.66	2025-12-09 23:38:39.813461
3198	sensor_rabano_1	21.60	65.80	61.37	1.71	6.52	97.76	495.59	2025-12-09 23:38:49.825992
3199	sensor_rabano_2	22.58	62.76	61.77	1.98	6.66	168.64	456.99	2025-12-09 23:38:49.827259
3200	sensor_cilantro_1	22.86	63.30	65.46	1.61	6.78	162.89	474.33	2025-12-09 23:38:49.827472
3201	sensor_cilantro_2	19.32	63.08	63.59	1.94	6.42	160.97	425.61	2025-12-09 23:38:49.827617
3202	sensor_rabano_1	21.28	65.62	79.27	1.98	6.65	162.14	494.35	2025-12-09 23:38:59.838718
3203	sensor_rabano_2	20.44	71.45	72.53	2.00	6.54	154.14	402.75	2025-12-09 23:38:59.840042
3204	sensor_cilantro_1	19.85	65.24	79.77	1.46	6.77	115.26	488.78	2025-12-09 23:38:59.840371
3205	sensor_cilantro_2	21.15	68.60	74.05	1.56	6.58	160.46	448.06	2025-12-09 23:38:59.840642
3206	sensor_rabano_1	20.86	62.99	77.61	1.47	6.63	151.37	472.45	2025-12-09 23:39:09.852663
3207	sensor_rabano_2	22.56	72.77	76.10	1.88	6.80	192.43	403.27	2025-12-09 23:39:09.853471
3208	sensor_cilantro_1	22.07	68.42	76.67	1.59	6.50	133.99	497.74	2025-12-09 23:39:09.853653
3209	sensor_cilantro_2	21.16	76.69	73.22	1.97	6.56	108.43	483.66	2025-12-09 23:39:09.853817
3210	sensor_rabano_1	22.03	65.53	72.75	1.96	6.66	157.46	455.18	2025-12-09 23:39:19.866274
3211	sensor_rabano_2	22.46	58.43	63.95	1.80	6.44	90.77	489.50	2025-12-09 23:39:19.867133
3212	sensor_cilantro_1	19.09	72.56	69.83	1.41	6.60	121.05	478.60	2025-12-09 23:39:19.867323
3213	sensor_cilantro_2	22.00	76.13	70.40	1.88	6.41	172.54	454.20	2025-12-09 23:39:19.867468
3214	sensor_rabano_1	21.03	69.13	70.30	1.62	6.56	196.68	420.63	2025-12-09 23:39:29.879744
3215	sensor_rabano_2	22.25	65.94	65.35	1.77	6.53	161.06	434.27	2025-12-09 23:39:29.880663
3216	sensor_cilantro_1	19.95	64.76	66.13	1.50	6.50	182.12	494.40	2025-12-09 23:39:29.880865
3217	sensor_cilantro_2	22.04	77.48	68.60	1.68	6.63	197.51	409.57	2025-12-09 23:39:29.881014
3218	sensor_rabano_1	22.85	60.96	79.49	1.98	6.42	120.92	450.37	2025-12-09 23:39:39.892059
3219	sensor_rabano_2	21.83	70.57	62.26	1.98	6.41	90.48	448.26	2025-12-09 23:39:39.89295
3220	sensor_cilantro_1	21.41	73.23	60.22	1.43	6.53	196.62	491.61	2025-12-09 23:39:39.893135
3221	sensor_cilantro_2	21.52	67.81	60.35	1.60	6.62	52.92	460.35	2025-12-09 23:39:39.89329
3222	sensor_rabano_1	22.22	70.87	68.74	1.48	6.51	90.87	437.31	2025-12-09 23:39:49.904517
3223	sensor_rabano_2	20.45	59.76	63.86	1.51	6.64	118.36	412.51	2025-12-09 23:39:49.905809
3224	sensor_cilantro_1	21.76	72.34	76.66	1.86	6.52	102.73	479.80	2025-12-09 23:39:49.906222
3225	sensor_cilantro_2	22.48	69.64	77.00	1.74	6.65	183.42	405.04	2025-12-09 23:39:49.906631
3226	sensor_rabano_1	21.04	57.28	62.23	1.64	6.69	115.76	420.41	2025-12-09 23:39:59.918545
3227	sensor_rabano_2	20.16	67.45	79.98	1.82	6.61	180.30	480.67	2025-12-09 23:39:59.919485
3228	sensor_cilantro_1	21.99	71.54	77.29	1.56	6.75	114.65	467.75	2025-12-09 23:39:59.91974
3229	sensor_cilantro_2	22.64	63.15	62.50	1.45	6.68	198.27	445.63	2025-12-09 23:39:59.919916
3230	sensor_rabano_1	20.16	70.19	63.37	1.90	6.63	162.97	417.51	2025-12-09 23:40:09.93067
3231	sensor_rabano_2	22.39	64.19	70.62	1.70	6.65	180.59	442.40	2025-12-09 23:40:09.931447
3232	sensor_cilantro_1	19.71	74.10	67.62	1.67	6.57	60.16	471.00	2025-12-09 23:40:09.931631
3233	sensor_cilantro_2	21.53	74.67	76.33	1.97	6.64	106.32	422.77	2025-12-09 23:40:09.931785
3234	sensor_rabano_1	23.48	66.98	79.25	1.75	6.51	112.37	485.54	2025-12-09 23:40:19.942546
3235	sensor_rabano_2	21.66	70.08	67.64	1.71	6.60	145.38	464.96	2025-12-09 23:40:19.943563
3236	sensor_cilantro_1	22.77	74.96	71.99	1.78	6.63	164.61	402.63	2025-12-09 23:40:19.943742
3237	sensor_cilantro_2	22.86	68.47	71.86	1.92	6.57	123.82	416.15	2025-12-09 23:40:19.943805
3238	sensor_rabano_1	20.02	66.03	70.23	1.47	6.80	138.28	405.06	2025-12-09 23:40:29.955388
3239	sensor_rabano_2	20.90	69.82	73.36	1.86	6.45	73.20	431.22	2025-12-09 23:40:29.956204
3240	sensor_cilantro_1	21.94	64.98	63.35	1.73	6.46	102.16	442.45	2025-12-09 23:40:29.956427
3241	sensor_cilantro_2	21.93	77.78	61.07	1.47	6.57	109.73	474.72	2025-12-09 23:40:29.956582
3242	sensor_rabano_1	20.01	65.08	76.98	1.91	6.63	172.13	445.08	2025-12-09 23:40:39.968146
3243	sensor_rabano_2	20.92	57.66	72.56	1.71	6.55	90.16	414.00	2025-12-09 23:40:39.96898
3244	sensor_cilantro_1	20.74	77.36	70.58	1.67	6.76	146.96	418.32	2025-12-09 23:40:39.969171
3245	sensor_cilantro_2	22.65	64.06	79.97	1.88	6.48	85.73	443.31	2025-12-09 23:40:39.969319
3246	sensor_rabano_1	22.57	67.67	61.79	1.94	6.47	69.44	421.39	2025-12-09 23:40:49.979193
3247	sensor_rabano_2	23.96	71.07	79.10	1.90	6.60	174.83	440.37	2025-12-09 23:40:49.980017
3248	sensor_cilantro_1	20.58	74.42	72.07	2.00	6.79	114.76	499.63	2025-12-09 23:40:49.980211
3249	sensor_cilantro_2	21.58	72.65	76.04	1.45	6.48	182.79	490.31	2025-12-09 23:40:49.980362
3250	sensor_rabano_1	23.72	60.92	66.75	1.58	6.77	173.01	400.48	2025-12-09 23:40:59.992297
3251	sensor_rabano_2	20.38	72.13	66.51	1.65	6.47	93.71	455.41	2025-12-09 23:40:59.992924
3252	sensor_cilantro_1	20.16	68.25	79.68	1.79	6.53	103.82	404.87	2025-12-09 23:40:59.993083
3253	sensor_cilantro_2	20.74	69.78	69.10	1.86	6.60	100.10	474.41	2025-12-09 23:40:59.99315
3254	sensor_rabano_1	20.22	60.55	64.15	1.63	6.61	50.39	483.86	2025-12-09 23:41:10.004296
3255	sensor_rabano_2	20.17	65.52	76.42	1.57	6.73	60.57	409.28	2025-12-09 23:41:10.005108
3256	sensor_cilantro_1	20.47	76.38	76.79	1.40	6.57	90.76	470.67	2025-12-09 23:41:10.005295
3257	sensor_cilantro_2	21.86	70.66	73.94	1.83	6.50	119.96	482.50	2025-12-09 23:41:10.005446
3258	sensor_rabano_1	20.44	71.02	79.87	1.77	6.66	184.90	434.12	2025-12-09 23:41:20.016549
3259	sensor_rabano_2	21.06	68.46	78.11	1.72	6.64	176.07	462.10	2025-12-09 23:41:20.017333
3260	sensor_cilantro_1	19.04	71.27	62.52	1.82	6.43	111.21	430.15	2025-12-09 23:41:20.01744
3261	sensor_cilantro_2	21.94	67.68	78.45	1.71	6.79	199.71	404.51	2025-12-09 23:41:20.017501
3262	sensor_rabano_1	23.40	69.70	62.57	1.71	6.60	114.07	430.06	2025-12-09 23:41:30.02849
3263	sensor_rabano_2	23.55	64.61	79.53	1.56	6.63	74.51	430.42	2025-12-09 23:41:30.029293
3264	sensor_cilantro_1	20.86	69.04	66.93	1.60	6.62	90.42	460.00	2025-12-09 23:41:30.029465
3265	sensor_cilantro_2	22.79	71.88	72.76	1.75	6.44	159.23	485.91	2025-12-09 23:41:30.029603
3266	sensor_rabano_1	22.06	65.33	74.24	1.91	6.73	156.59	486.23	2025-12-09 23:41:40.040661
3267	sensor_rabano_2	23.25	64.64	72.22	1.62	6.72	187.91	428.74	2025-12-09 23:41:40.041528
3268	sensor_cilantro_1	19.58	77.65	73.83	1.69	6.73	89.51	485.34	2025-12-09 23:41:40.041731
3269	sensor_cilantro_2	21.88	69.12	62.04	1.98	6.47	164.49	448.62	2025-12-09 23:41:40.041882
3270	sensor_rabano_1	20.64	68.85	73.91	1.69	6.53	146.91	417.59	2025-12-09 23:41:50.067946
3271	sensor_rabano_2	22.08	61.97	63.74	1.68	6.59	151.02	412.86	2025-12-09 23:41:50.068752
3272	sensor_cilantro_1	22.53	77.46	66.50	1.88	6.69	184.48	408.67	2025-12-09 23:41:50.068937
3273	sensor_cilantro_2	22.60	72.03	72.74	1.40	6.78	72.13	410.50	2025-12-09 23:41:50.069081
3274	sensor_rabano_1	23.96	66.02	77.64	1.95	6.56	179.12	484.27	2025-12-09 23:42:00.08143
3275	sensor_rabano_2	22.53	66.28	60.56	1.49	6.50	180.18	463.82	2025-12-09 23:42:00.082205
3276	sensor_cilantro_1	19.24	71.22	70.80	1.90	6.70	196.60	451.55	2025-12-09 23:42:00.082387
3277	sensor_cilantro_2	20.12	70.38	61.38	1.72	6.66	56.70	485.38	2025-12-09 23:42:00.082527
3278	sensor_rabano_1	22.34	65.65	78.56	1.88	6.48	159.48	402.38	2025-12-09 23:42:10.094738
3279	sensor_rabano_2	20.17	57.59	71.60	1.46	6.61	54.21	473.27	2025-12-09 23:42:10.095608
3280	sensor_cilantro_1	22.34	67.33	71.44	1.74	6.67	97.25	441.68	2025-12-09 23:42:10.095871
3281	sensor_cilantro_2	20.37	67.13	72.55	1.82	6.53	157.10	450.27	2025-12-09 23:42:10.096082
3282	sensor_rabano_1	23.60	60.38	63.30	1.73	6.51	141.76	473.01	2025-12-09 23:42:20.105394
3283	sensor_rabano_2	21.22	57.36	68.66	1.58	6.55	91.70	469.36	2025-12-09 23:42:20.106228
3284	sensor_cilantro_1	22.63	70.28	64.57	1.50	6.45	94.10	476.34	2025-12-09 23:42:20.107033
3285	sensor_cilantro_2	20.26	75.46	68.35	1.85	6.80	128.62	496.16	2025-12-09 23:42:20.1073
3286	sensor_rabano_1	21.94	72.88	75.08	1.59	6.71	114.66	441.89	2025-12-09 23:42:30.118137
3287	sensor_rabano_2	23.19	60.95	70.87	1.76	6.56	138.06	450.33	2025-12-09 23:42:30.119058
3288	sensor_cilantro_1	22.08	74.26	76.02	1.88	6.41	179.45	476.00	2025-12-09 23:42:30.11925
3289	sensor_cilantro_2	20.43	63.50	70.91	1.55	6.41	139.57	447.86	2025-12-09 23:42:30.119396
3290	sensor_rabano_1	22.28	68.77	74.79	1.77	6.57	59.41	417.55	2025-12-09 23:42:40.131318
3291	sensor_rabano_2	21.17	59.04	73.41	1.47	6.79	139.38	489.68	2025-12-09 23:42:40.132169
3292	sensor_cilantro_1	22.87	62.38	64.01	1.83	6.59	67.01	459.39	2025-12-09 23:42:40.132362
3293	sensor_cilantro_2	22.66	69.60	79.98	1.67	6.63	166.34	427.42	2025-12-09 23:42:40.132506
3294	sensor_rabano_1	23.20	57.90	77.74	1.75	6.75	121.46	455.86	2025-12-09 23:42:50.145044
3295	sensor_rabano_2	20.81	60.21	72.65	1.84	6.51	182.72	449.13	2025-12-09 23:42:50.145666
3296	sensor_cilantro_1	20.39	63.36	76.84	1.44	6.55	157.33	410.75	2025-12-09 23:42:50.145758
3297	sensor_cilantro_2	22.98	75.05	61.94	1.63	6.45	62.05	456.09	2025-12-09 23:42:50.145814
3298	sensor_rabano_1	23.81	60.44	79.08	1.55	6.52	175.11	424.33	2025-12-09 23:43:00.155924
3299	sensor_rabano_2	22.12	69.56	73.83	1.73	6.73	162.74	432.67	2025-12-09 23:43:00.15664
3300	sensor_cilantro_1	19.95	74.38	78.89	1.82	6.52	82.30	472.02	2025-12-09 23:43:00.156815
3301	sensor_cilantro_2	21.10	72.56	77.18	1.72	6.67	141.54	423.40	2025-12-09 23:43:00.156902
3302	sensor_rabano_1	21.60	65.26	61.59	1.51	6.58	93.78	491.07	2025-12-09 23:43:10.168221
3303	sensor_rabano_2	22.56	70.58	79.89	1.60	6.61	184.79	472.30	2025-12-09 23:43:10.168971
3304	sensor_cilantro_1	19.79	72.82	63.18	1.89	6.70	83.57	400.68	2025-12-09 23:43:10.169147
3305	sensor_cilantro_2	19.34	71.84	78.83	1.46	6.66	119.69	470.01	2025-12-09 23:43:10.16929
3306	sensor_rabano_1	23.33	65.47	72.24	1.61	6.58	182.90	439.84	2025-12-09 23:46:02.507493
3307	sensor_rabano_2	21.09	59.81	72.47	1.42	6.56	166.57	444.81	2025-12-09 23:46:02.508905
3308	sensor_cilantro_1	19.50	68.03	63.59	1.68	6.65	172.57	499.78	2025-12-09 23:46:02.509376
3309	sensor_cilantro_2	20.17	68.91	62.47	1.57	6.57	98.36	458.65	2025-12-09 23:46:02.509727
3310	sensor_rabano_1	22.90	70.58	61.91	1.79	6.51	151.37	409.47	2025-12-09 23:46:12.521453
3311	sensor_rabano_2	20.56	67.14	71.19	1.94	6.71	83.53	413.04	2025-12-09 23:46:12.522066
3312	sensor_cilantro_1	20.82	70.47	78.58	1.93	6.48	112.24	493.55	2025-12-09 23:46:12.52218
3313	sensor_cilantro_2	22.65	63.08	76.70	1.60	6.58	69.92	474.00	2025-12-09 23:46:12.522246
3314	sensor_rabano_1	20.95	63.55	65.47	1.42	6.58	56.28	420.64	2025-12-09 23:46:22.531969
3315	sensor_rabano_2	20.52	69.14	69.35	1.68	6.48	124.80	418.64	2025-12-09 23:46:22.532789
3316	sensor_cilantro_1	21.33	64.36	73.80	1.73	6.71	181.55	485.15	2025-12-09 23:46:22.532976
3317	sensor_cilantro_2	22.39	77.63	72.54	1.80	6.56	72.78	499.49	2025-12-09 23:46:22.533122
3318	sensor_rabano_1	23.51	67.95	62.77	1.86	6.73	76.63	425.72	2025-12-09 23:46:32.543474
3319	sensor_rabano_2	20.41	58.03	68.70	1.85	6.73	65.27	410.21	2025-12-09 23:46:32.544324
3320	sensor_cilantro_1	19.41	73.18	75.81	1.51	6.61	178.06	462.48	2025-12-09 23:46:32.544515
3321	sensor_cilantro_2	19.18	65.41	74.51	1.73	6.64	60.60	488.23	2025-12-09 23:46:32.54467
3322	sensor_rabano_1	22.97	66.19	74.29	1.97	6.64	83.27	494.16	2025-12-09 23:46:42.554538
3323	sensor_rabano_2	22.40	71.20	68.90	1.93	6.60	90.03	435.60	2025-12-09 23:46:42.55547
3324	sensor_cilantro_1	20.51	73.37	79.57	1.86	6.62	195.39	493.45	2025-12-09 23:46:42.55568
3325	sensor_cilantro_2	19.71	63.73	70.10	1.55	6.72	64.16	457.21	2025-12-09 23:46:42.556017
3326	sensor_rabano_1	22.30	69.32	69.18	1.52	6.53	76.87	419.39	2025-12-09 23:46:52.566678
3327	sensor_rabano_2	22.37	58.41	71.65	1.53	6.44	95.33	438.09	2025-12-09 23:46:52.567572
3328	sensor_cilantro_1	21.35	68.88	68.26	1.43	6.64	134.22	469.66	2025-12-09 23:46:52.567778
3329	sensor_cilantro_2	19.10	69.96	60.76	1.73	6.43	185.00	453.86	2025-12-09 23:46:52.567924
3330	sensor_rabano_1	20.59	68.80	60.68	1.78	6.42	81.10	464.06	2025-12-09 23:47:02.579475
3331	sensor_rabano_2	23.28	58.41	65.59	1.59	6.67	109.52	485.47	2025-12-09 23:47:02.580296
3332	sensor_cilantro_1	20.61	71.90	73.99	1.97	6.47	127.90	430.68	2025-12-09 23:47:02.580476
3333	sensor_cilantro_2	21.65	75.04	74.47	1.75	6.43	172.40	421.60	2025-12-09 23:47:02.580631
3334	sensor_rabano_1	23.10	68.78	79.31	1.47	6.65	74.04	438.34	2025-12-09 23:47:12.590143
3335	sensor_rabano_2	20.55	65.92	69.86	1.62	6.44	135.36	419.48	2025-12-09 23:47:12.591329
3336	sensor_cilantro_1	22.92	63.85	77.53	1.43	6.59	161.08	460.59	2025-12-09 23:47:12.591419
3337	sensor_cilantro_2	22.93	62.37	63.63	1.95	6.70	89.06	408.86	2025-12-09 23:47:12.591481
3338	sensor_rabano_1	21.99	70.74	65.20	1.67	6.75	92.88	494.00	2025-12-09 23:47:22.601418
3339	sensor_rabano_2	20.30	58.94	79.62	1.73	6.69	163.34	416.91	2025-12-09 23:47:22.602127
3340	sensor_cilantro_1	21.54	73.44	71.62	1.75	6.56	137.81	402.21	2025-12-09 23:47:22.602307
3341	sensor_cilantro_2	19.97	71.08	61.28	1.60	6.72	154.11	467.89	2025-12-09 23:47:22.60247
3342	sensor_rabano_1	22.54	57.15	75.24	1.98	6.61	185.40	462.03	2025-12-09 23:47:32.613686
3343	sensor_rabano_2	22.13	63.49	78.82	1.91	6.69	176.97	455.09	2025-12-09 23:47:32.614486
3344	sensor_cilantro_1	22.79	72.43	79.77	1.91	6.61	103.98	435.87	2025-12-09 23:47:32.614766
3345	sensor_cilantro_2	20.38	74.38	69.75	1.67	6.74	159.07	441.91	2025-12-09 23:47:32.614932
3346	sensor_rabano_1	21.56	65.48	63.27	1.40	6.40	104.52	406.70	2025-12-09 23:47:42.626121
3347	sensor_rabano_2	22.36	62.87	67.74	1.96	6.60	83.67	475.44	2025-12-09 23:47:42.626917
3348	sensor_cilantro_1	20.65	76.16	70.53	1.57	6.49	98.48	484.82	2025-12-09 23:47:42.627142
3349	sensor_cilantro_2	22.41	67.02	65.21	1.89	6.74	141.02	484.00	2025-12-09 23:47:42.627303
3350	sensor_rabano_1	20.33	72.37	67.13	1.84	6.59	127.04	428.45	2025-12-09 23:47:52.638107
3351	sensor_rabano_2	21.74	72.73	79.70	1.91	6.74	56.11	410.52	2025-12-09 23:47:52.638878
3352	sensor_cilantro_1	20.68	66.69	62.62	1.74	6.76	55.09	457.92	2025-12-09 23:47:52.63906
3353	sensor_cilantro_2	20.91	73.70	75.91	1.98	6.44	77.43	443.00	2025-12-09 23:47:52.639203
3354	sensor_rabano_1	21.29	64.50	69.37	1.70	6.78	190.17	487.90	2025-12-09 23:48:02.650611
3355	sensor_rabano_2	20.54	62.16	68.99	1.83	6.58	50.01	456.14	2025-12-09 23:48:02.651472
3356	sensor_cilantro_1	20.56	75.94	64.70	1.97	6.44	85.07	483.38	2025-12-09 23:48:02.651666
3357	sensor_cilantro_2	19.62	74.51	75.06	1.76	6.73	102.16	439.86	2025-12-09 23:48:02.65188
3358	sensor_rabano_1	22.19	66.72	71.13	1.57	6.62	60.89	484.49	2025-12-09 23:48:12.66355
3359	sensor_rabano_2	23.53	70.65	71.40	1.68	6.64	52.33	455.82	2025-12-09 23:48:12.664356
3360	sensor_cilantro_1	21.77	71.88	74.71	1.73	6.79	52.71	483.03	2025-12-09 23:48:12.664532
3361	sensor_cilantro_2	21.68	74.81	71.76	1.63	6.48	179.04	482.26	2025-12-09 23:48:12.664736
3362	sensor_rabano_1	20.32	63.66	63.82	1.59	6.72	134.15	475.82	2025-12-09 23:48:22.675343
3363	sensor_rabano_2	20.85	70.91	76.77	1.92	6.80	59.40	467.46	2025-12-09 23:48:22.676145
3364	sensor_cilantro_1	21.31	71.31	67.75	1.57	6.41	123.97	411.14	2025-12-09 23:48:22.676332
3365	sensor_cilantro_2	21.60	70.89	64.77	1.80	6.62	129.77	491.50	2025-12-09 23:48:22.676487
3366	sensor_rabano_1	22.16	62.78	67.86	1.72	6.58	107.02	430.93	2025-12-09 23:48:32.68666
3367	sensor_rabano_2	20.41	62.23	73.18	1.94	6.51	191.32	407.86	2025-12-09 23:48:32.687504
3368	sensor_cilantro_1	22.90	68.45	71.01	1.84	6.45	158.75	432.27	2025-12-09 23:48:32.687765
3369	sensor_cilantro_2	19.97	67.75	74.82	1.42	6.43	61.15	445.19	2025-12-09 23:48:32.68797
3370	sensor_rabano_1	20.68	72.88	71.22	1.80	6.60	67.18	405.71	2025-12-09 23:48:42.698403
3371	sensor_rabano_2	23.23	70.60	61.69	1.45	6.41	73.80	409.23	2025-12-09 23:48:42.699197
3372	sensor_cilantro_1	22.69	77.36	68.55	1.83	6.59	187.35	482.98	2025-12-09 23:48:42.699387
3373	sensor_cilantro_2	20.12	64.70	68.88	1.99	6.55	110.27	418.48	2025-12-09 23:48:42.699533
3374	sensor_rabano_1	21.38	59.73	62.65	1.98	6.54	56.47	419.66	2025-12-09 23:48:52.70963
3375	sensor_rabano_2	22.81	62.46	65.69	1.81	6.61	51.29	418.83	2025-12-09 23:48:52.710456
3376	sensor_cilantro_1	22.36	77.91	63.05	1.82	6.72	70.50	458.55	2025-12-09 23:48:52.710649
3377	sensor_cilantro_2	22.10	63.28	76.38	1.82	6.48	54.67	457.29	2025-12-09 23:48:52.710802
3378	sensor_rabano_1	23.04	64.25	78.36	1.49	6.76	131.92	420.32	2025-12-09 23:49:02.720825
3379	sensor_rabano_2	21.94	71.41	70.16	1.56	6.53	115.41	428.89	2025-12-09 23:49:02.721646
3380	sensor_cilantro_1	19.89	73.83	65.98	1.70	6.79	124.03	499.91	2025-12-09 23:49:02.721829
3381	sensor_cilantro_2	22.33	73.28	66.94	1.41	6.49	162.97	405.41	2025-12-09 23:49:02.72197
3382	sensor_rabano_1	23.04	59.02	75.80	1.74	6.52	188.35	423.05	2025-12-09 23:49:12.732385
3383	sensor_rabano_2	22.02	60.93	78.51	1.61	6.50	179.63	466.80	2025-12-09 23:49:12.733055
3384	sensor_cilantro_1	21.96	64.47	73.69	1.86	6.53	193.83	490.16	2025-12-09 23:49:12.733227
3385	sensor_cilantro_2	19.66	66.97	78.62	1.92	6.51	123.70	454.37	2025-12-09 23:49:12.733309
3386	sensor_rabano_1	21.31	60.66	77.97	1.44	6.58	66.40	423.07	2025-12-09 23:49:22.74425
3387	sensor_rabano_2	20.06	57.46	72.45	1.43	6.67	113.52	489.50	2025-12-09 23:49:22.745163
3388	sensor_cilantro_1	20.70	64.63	73.36	1.63	6.57	163.90	443.63	2025-12-09 23:49:22.745352
3389	sensor_cilantro_2	22.98	62.36	69.34	1.75	6.78	105.81	420.21	2025-12-09 23:49:22.745501
3390	sensor_rabano_1	22.59	60.89	77.31	1.59	6.76	84.06	433.05	2025-12-09 23:49:32.757375
3391	sensor_rabano_2	22.31	60.04	77.25	1.51	6.73	167.72	436.13	2025-12-09 23:49:32.758143
3392	sensor_cilantro_1	20.35	71.23	68.55	1.88	6.42	113.21	489.74	2025-12-09 23:49:32.758325
3393	sensor_cilantro_2	20.01	71.47	65.08	1.71	6.57	174.16	402.21	2025-12-09 23:49:32.758465
3394	sensor_rabano_1	22.22	68.93	67.73	1.82	6.57	67.44	421.19	2025-12-09 23:49:42.768774
3395	sensor_rabano_2	20.83	68.88	71.27	1.65	6.59	50.91	451.04	2025-12-09 23:49:42.769666
3396	sensor_cilantro_1	21.72	73.51	79.36	1.78	6.50	75.76	499.11	2025-12-09 23:49:42.769861
3397	sensor_cilantro_2	20.52	62.98	61.77	1.80	6.77	52.31	485.69	2025-12-09 23:49:42.770009
3398	sensor_rabano_1	21.23	65.36	63.08	1.72	6.76	62.40	430.04	2025-12-09 23:49:52.781232
3399	sensor_rabano_2	21.02	60.39	72.31	1.41	6.67	165.10	442.77	2025-12-09 23:49:52.78209
3400	sensor_cilantro_1	19.38	69.41	73.39	1.49	6.43	121.34	447.44	2025-12-09 23:49:52.782278
3401	sensor_cilantro_2	20.69	72.30	78.17	1.50	6.71	118.17	407.26	2025-12-09 23:49:52.782443
3402	sensor_rabano_1	20.95	65.25	64.65	1.84	6.79	182.90	420.13	2025-12-09 23:50:02.792676
3403	sensor_rabano_2	20.73	70.40	66.31	1.51	6.79	98.10	418.56	2025-12-09 23:50:02.793561
3404	sensor_cilantro_1	21.90	68.98	67.91	1.95	6.45	136.15	431.51	2025-12-09 23:50:02.793826
3405	sensor_cilantro_2	22.30	74.80	62.55	1.73	6.49	51.59	447.02	2025-12-09 23:50:02.79406
3406	sensor_rabano_1	22.31	68.86	68.73	1.99	6.73	164.26	408.63	2025-12-09 23:50:12.802049
3407	sensor_rabano_2	23.43	58.66	76.89	1.71	6.41	101.08	438.00	2025-12-09 23:50:12.802854
3408	sensor_cilantro_1	21.53	64.57	60.60	1.53	6.62	168.08	433.68	2025-12-09 23:50:12.803073
3409	sensor_cilantro_2	20.15	75.56	74.07	1.86	6.61	94.90	494.94	2025-12-09 23:50:12.803181
3410	sensor_rabano_1	22.90	61.71	67.52	1.53	6.65	179.87	410.19	2025-12-09 23:50:22.814998
3411	sensor_rabano_2	23.31	69.81	62.86	1.57	6.61	176.75	495.63	2025-12-09 23:50:22.815815
3412	sensor_cilantro_1	19.39	70.41	79.31	1.90	6.65	70.95	414.43	2025-12-09 23:50:22.816044
3413	sensor_cilantro_2	19.70	76.46	65.19	1.45	6.55	56.01	488.80	2025-12-09 23:50:22.816133
3414	sensor_rabano_1	21.72	57.76	65.17	1.48	6.54	51.19	474.93	2025-12-09 23:50:32.825387
3415	sensor_rabano_2	23.74	72.66	66.40	1.49	6.50	96.23	458.37	2025-12-09 23:50:32.825996
3416	sensor_cilantro_1	20.43	71.49	73.85	1.66	6.61	122.98	477.51	2025-12-09 23:50:32.82617
3417	sensor_cilantro_2	22.25	67.35	78.07	1.93	6.52	195.67	416.60	2025-12-09 23:50:32.826254
3418	sensor_rabano_1	23.78	57.70	71.69	1.75	6.65	145.46	439.86	2025-12-09 23:50:42.835117
3419	sensor_rabano_2	22.62	67.87	78.41	1.65	6.59	61.56	407.51	2025-12-09 23:50:42.836019
3420	sensor_cilantro_1	20.05	71.27	79.10	1.89	6.46	157.54	469.65	2025-12-09 23:50:42.836263
3421	sensor_cilantro_2	20.61	66.77	76.63	1.51	6.41	123.66	418.75	2025-12-09 23:50:42.836417
3422	sensor_rabano_1	20.21	61.18	67.42	1.64	6.67	127.71	416.81	2025-12-09 23:50:52.847291
3423	sensor_rabano_2	21.24	61.85	63.68	1.79	6.44	55.31	400.06	2025-12-09 23:50:52.848192
3424	sensor_cilantro_1	19.24	73.72	62.14	1.67	6.52	114.03	490.70	2025-12-09 23:50:52.848398
3425	sensor_cilantro_2	19.25	67.16	71.47	1.60	6.59	153.13	449.00	2025-12-09 23:50:52.84854
3426	sensor_rabano_1	21.31	61.45	69.91	1.68	6.67	72.86	451.16	2025-12-09 23:51:02.858685
3427	sensor_rabano_2	21.12	70.57	60.36	1.75	6.53	72.42	457.07	2025-12-09 23:51:02.859499
3428	sensor_cilantro_1	19.17	64.91	75.04	1.81	6.51	148.97	449.52	2025-12-09 23:51:02.859606
3429	sensor_cilantro_2	20.03	77.02	67.40	1.74	6.57	100.36	476.10	2025-12-09 23:51:02.859765
3430	sensor_rabano_1	20.41	67.86	75.88	1.97	6.47	65.56	476.31	2025-12-09 23:51:27.758366
3431	sensor_rabano_2	23.65	63.15	64.19	1.62	6.55	193.98	466.13	2025-12-09 23:51:27.758973
3432	sensor_cilantro_1	19.52	71.90	75.48	1.92	6.71	155.44	414.65	2025-12-09 23:51:27.759084
3433	sensor_cilantro_2	21.36	68.06	75.75	1.72	6.57	179.53	420.18	2025-12-09 23:51:27.759144
3434	sensor_rabano_1	21.65	66.92	61.27	1.62	6.41	60.69	487.22	2025-12-09 23:51:37.771152
3435	sensor_rabano_2	23.49	61.55	62.32	1.42	6.43	187.08	436.35	2025-12-09 23:51:37.772302
3436	sensor_cilantro_1	23.00	69.95	69.33	1.66	6.52	158.83	466.22	2025-12-09 23:51:37.772505
3437	sensor_cilantro_2	20.02	74.03	66.21	1.91	6.72	137.09	469.58	2025-12-09 23:51:37.772734
3438	sensor_rabano_1	22.80	62.19	70.43	1.51	6.45	169.67	459.96	2025-12-09 23:51:47.784437
3439	sensor_rabano_2	20.05	59.47	68.39	1.48	6.45	198.83	494.05	2025-12-09 23:51:47.785463
3440	sensor_cilantro_1	20.01	62.43	61.38	1.77	6.56	191.66	452.86	2025-12-09 23:51:47.785751
3441	sensor_cilantro_2	22.29	74.18	64.98	1.62	6.68	75.00	455.51	2025-12-09 23:51:47.785982
3442	sensor_rabano_1	20.51	58.19	62.13	1.90	6.60	117.13	461.70	2025-12-09 23:51:57.796206
3443	sensor_rabano_2	22.16	58.64	76.49	1.79	6.65	50.98	488.69	2025-12-09 23:51:57.796718
3444	sensor_cilantro_1	20.73	75.52	73.32	1.85	6.67	192.74	466.56	2025-12-09 23:51:57.796806
3445	sensor_cilantro_2	21.63	75.43	69.69	1.84	6.45	155.39	425.51	2025-12-09 23:51:57.796865
3446	sensor_rabano_1	20.43	60.75	64.59	1.96	6.55	60.70	429.34	2025-12-09 23:52:07.80673
3447	sensor_rabano_2	23.35	66.44	70.19	1.88	6.66	157.50	473.96	2025-12-09 23:52:07.807552
3448	sensor_cilantro_1	20.39	69.27	70.47	1.49	6.71	184.91	461.76	2025-12-09 23:52:07.807779
3449	sensor_cilantro_2	20.70	77.90	69.09	1.43	6.66	89.69	482.75	2025-12-09 23:52:07.807926
3450	sensor_rabano_1	22.59	71.50	66.67	1.67	6.59	139.32	419.69	2025-12-09 23:52:17.819365
3451	sensor_rabano_2	23.62	71.21	69.95	1.86	6.52	60.62	455.03	2025-12-09 23:52:17.821006
3452	sensor_cilantro_1	21.22	64.58	76.99	1.80	6.60	131.23	442.61	2025-12-09 23:52:17.821145
3453	sensor_cilantro_2	20.25	77.84	75.43	1.72	6.55	180.80	482.96	2025-12-09 23:52:17.82121
3454	sensor_rabano_1	20.33	67.35	66.03	1.42	6.64	161.65	470.63	2025-12-09 23:52:27.83117
3455	sensor_rabano_2	23.91	59.20	62.68	1.74	6.44	70.19	456.23	2025-12-09 23:52:27.83196
3456	sensor_cilantro_1	19.85	75.32	67.36	1.79	6.43	159.74	402.07	2025-12-09 23:52:27.832186
3457	sensor_cilantro_2	19.29	76.87	79.83	1.50	6.52	169.43	489.56	2025-12-09 23:52:27.832344
3458	sensor_rabano_1	21.28	61.81	66.73	1.62	6.60	156.96	472.97	2025-12-09 23:52:37.842675
3459	sensor_rabano_2	23.19	57.86	68.24	1.49	6.43	109.34	445.97	2025-12-09 23:52:37.843508
3460	sensor_cilantro_1	22.30	62.67	75.30	1.84	6.58	157.73	491.86	2025-12-09 23:52:37.843704
3461	sensor_cilantro_2	20.28	65.16	76.65	1.64	6.56	169.17	483.38	2025-12-09 23:52:37.843861
3462	sensor_rabano_1	23.41	66.97	72.14	1.83	6.52	75.97	404.44	2025-12-09 23:52:47.855195
3463	sensor_rabano_2	20.13	59.60	65.06	1.74	6.75	84.45	485.05	2025-12-09 23:52:47.855975
3464	sensor_cilantro_1	20.44	65.15	74.13	1.87	6.52	87.80	423.74	2025-12-09 23:52:47.856152
3465	sensor_cilantro_2	19.82	70.00	68.53	1.79	6.43	138.32	461.15	2025-12-09 23:52:47.856295
3466	sensor_rabano_1	20.10	70.09	67.92	1.56	6.42	93.45	481.34	2025-12-09 23:52:57.867171
3467	sensor_rabano_2	21.14	60.38	72.17	1.97	6.60	116.83	489.12	2025-12-09 23:52:57.86802
3468	sensor_cilantro_1	20.80	73.23	61.61	1.47	6.45	175.44	426.30	2025-12-09 23:52:57.868202
3469	sensor_cilantro_2	20.36	62.43	60.50	1.95	6.74	67.84	483.67	2025-12-09 23:52:57.868361
3470	sensor_rabano_1	23.40	64.18	66.82	1.75	6.47	102.74	433.77	2025-12-09 23:53:07.878923
3471	sensor_rabano_2	22.65	71.59	69.41	1.86	6.75	155.88	404.38	2025-12-09 23:53:07.879714
3472	sensor_cilantro_1	22.02	66.21	69.09	1.97	6.70	199.96	447.59	2025-12-09 23:53:07.879894
3473	sensor_cilantro_2	22.59	68.54	66.17	1.48	6.68	113.21	484.96	2025-12-09 23:53:07.880049
3474	sensor_rabano_1	22.59	59.64	63.41	1.45	6.58	155.40	468.56	2025-12-09 23:53:17.891596
3475	sensor_rabano_2	22.07	69.61	62.10	1.54	6.56	195.78	425.70	2025-12-09 23:53:17.892466
3476	sensor_cilantro_1	20.37	63.09	77.90	1.88	6.71	164.02	479.86	2025-12-09 23:53:17.892666
3477	sensor_cilantro_2	21.08	77.36	65.54	1.72	6.53	88.63	416.97	2025-12-09 23:53:17.892943
3478	sensor_rabano_1	23.92	57.80	62.71	1.96	6.67	86.20	477.61	2025-12-09 23:53:27.903128
3479	sensor_rabano_2	21.00	58.56	76.03	1.80	6.61	149.58	440.66	2025-12-09 23:53:27.904008
3480	sensor_cilantro_1	20.98	75.21	72.42	1.76	6.69	134.94	407.25	2025-12-09 23:53:27.904235
3481	sensor_cilantro_2	19.90	67.71	63.68	1.49	6.47	77.27	495.24	2025-12-09 23:53:27.904404
3482	sensor_rabano_1	21.94	71.32	65.98	1.92	6.65	162.60	427.32	2025-12-09 23:53:37.916054
3483	sensor_rabano_2	20.88	72.07	60.19	1.50	6.56	120.36	414.45	2025-12-09 23:53:37.91691
3484	sensor_cilantro_1	21.31	62.27	74.85	1.52	6.47	77.39	479.52	2025-12-09 23:53:37.917137
3485	sensor_cilantro_2	21.55	67.97	68.47	1.58	6.62	83.24	441.28	2025-12-09 23:53:37.917298
3486	sensor_rabano_1	23.67	69.41	77.12	1.91	6.49	99.91	443.63	2025-12-09 23:53:47.92833
3487	sensor_rabano_2	23.57	71.93	75.87	1.58	6.77	62.47	479.18	2025-12-09 23:53:47.929146
3488	sensor_cilantro_1	20.24	62.26	67.64	1.98	6.65	124.41	473.78	2025-12-09 23:53:47.929371
3489	sensor_cilantro_2	21.66	70.17	62.15	1.44	6.74	68.76	497.62	2025-12-09 23:53:47.929578
3490	sensor_rabano_1	21.87	62.06	79.32	1.88	6.67	94.72	440.56	2025-12-09 23:53:57.94007
3491	sensor_rabano_2	21.18	64.07	71.28	1.40	6.52	162.46	494.03	2025-12-09 23:53:57.940821
3492	sensor_cilantro_1	20.99	77.44	79.40	1.56	6.54	125.43	471.90	2025-12-09 23:53:57.940998
3493	sensor_cilantro_2	19.01	67.22	71.63	1.55	6.55	118.88	491.60	2025-12-09 23:53:57.941137
3494	sensor_rabano_1	21.07	61.22	67.16	1.73	6.45	134.11	484.83	2025-12-09 23:54:07.952422
3495	sensor_rabano_2	22.34	59.13	66.39	1.64	6.72	165.11	454.70	2025-12-09 23:54:07.953174
3496	sensor_cilantro_1	19.47	75.73	72.95	1.91	6.43	150.77	417.84	2025-12-09 23:54:07.953349
3497	sensor_cilantro_2	20.19	64.55	61.83	1.42	6.62	65.80	486.66	2025-12-09 23:54:07.953488
3498	sensor_rabano_1	22.57	71.70	66.00	1.45	6.44	101.12	458.43	2025-12-09 23:54:17.964599
3499	sensor_rabano_2	21.25	62.93	78.00	1.76	6.74	198.66	494.05	2025-12-09 23:54:17.965441
3500	sensor_cilantro_1	20.20	72.86	77.61	1.89	6.44	179.07	430.02	2025-12-09 23:54:17.965618
3501	sensor_cilantro_2	22.07	63.98	70.87	1.42	6.62	84.03	479.44	2025-12-09 23:54:17.965836
3502	sensor_rabano_1	21.83	60.09	71.06	1.52	6.72	107.27	496.18	2025-12-09 23:54:27.976491
3503	sensor_rabano_2	20.29	69.29	60.49	1.95	6.55	148.13	424.53	2025-12-09 23:54:27.977361
3504	sensor_cilantro_1	22.79	72.87	76.78	1.89	6.75	92.45	485.10	2025-12-09 23:54:27.977544
3505	sensor_cilantro_2	21.20	75.25	71.33	1.79	6.58	157.07	424.35	2025-12-09 23:54:27.977757
3506	sensor_rabano_1	20.54	62.87	67.80	1.77	6.58	183.22	407.81	2025-12-09 23:54:37.989408
3507	sensor_rabano_2	21.90	71.09	74.25	1.51	6.78	198.37	488.23	2025-12-09 23:54:37.990406
3508	sensor_cilantro_1	22.23	66.47	71.90	1.67	6.65	121.76	454.24	2025-12-09 23:54:37.990678
3509	sensor_cilantro_2	22.20	68.96	69.88	1.56	6.62	66.77	487.97	2025-12-09 23:54:37.990944
3510	sensor_rabano_1	23.63	70.28	71.16	1.84	6.75	192.58	497.14	2025-12-09 23:54:48.002671
3511	sensor_rabano_2	20.55	72.51	62.22	1.88	6.42	85.90	424.80	2025-12-09 23:54:48.003475
3512	sensor_cilantro_1	20.86	62.94	62.65	1.49	6.73	73.27	444.40	2025-12-09 23:54:48.003662
3513	sensor_cilantro_2	20.58	77.23	71.11	1.76	6.54	165.04	409.64	2025-12-09 23:54:48.003859
3514	sensor_rabano_1	22.76	58.43	66.56	1.97	6.45	97.72	442.78	2025-12-09 23:54:58.011756
3515	sensor_rabano_2	20.94	70.33	67.71	1.86	6.70	182.49	408.91	2025-12-09 23:54:58.0124
3516	sensor_cilantro_1	22.55	75.97	77.56	1.97	6.69	164.77	412.68	2025-12-09 23:54:58.012506
3517	sensor_cilantro_2	21.26	66.48	77.91	1.81	6.78	70.98	474.23	2025-12-09 23:54:58.012567
3518	sensor_rabano_1	20.64	60.33	76.83	1.70	6.41	176.33	490.81	2025-12-09 23:55:08.024252
3519	sensor_rabano_2	21.77	57.25	67.35	1.87	6.69	86.82	466.99	2025-12-09 23:55:08.025061
3520	sensor_cilantro_1	19.31	71.11	69.97	1.93	6.54	151.92	494.85	2025-12-09 23:55:08.025254
3521	sensor_cilantro_2	20.75	74.58	69.79	1.47	6.55	84.07	403.44	2025-12-09 23:55:08.025397
3522	sensor_rabano_1	22.41	71.34	65.13	1.41	6.40	115.70	476.57	2025-12-09 23:55:18.036966
3523	sensor_rabano_2	21.68	69.43	79.91	1.62	6.66	51.48	459.09	2025-12-09 23:55:18.037833
3524	sensor_cilantro_1	22.20	67.69	69.17	1.73	6.58	155.00	473.16	2025-12-09 23:55:18.038024
3525	sensor_cilantro_2	22.00	72.34	63.95	1.48	6.58	157.55	428.25	2025-12-09 23:55:18.038172
3526	sensor_rabano_1	22.86	71.10	65.68	1.52	6.73	115.42	401.22	2025-12-09 23:55:28.047357
3527	sensor_rabano_2	20.29	64.69	62.02	1.60	6.69	142.86	483.53	2025-12-09 23:55:28.048102
3528	sensor_cilantro_1	20.42	62.52	62.13	1.59	6.55	75.46	436.54	2025-12-09 23:55:28.048327
3529	sensor_cilantro_2	21.72	67.76	79.37	1.99	6.59	198.09	477.57	2025-12-09 23:55:28.048537
3530	sensor_rabano_1	22.72	65.78	67.24	1.45	6.48	111.72	467.94	2025-12-09 23:55:38.060201
3531	sensor_rabano_2	22.70	58.11	60.23	1.60	6.42	95.86	454.53	2025-12-09 23:55:38.060986
3532	sensor_cilantro_1	21.07	72.57	61.07	1.55	6.47	72.02	404.20	2025-12-09 23:55:38.061215
3533	sensor_cilantro_2	21.89	62.37	71.10	1.43	6.72	77.03	467.92	2025-12-09 23:55:38.061425
3534	sensor_rabano_1	20.51	68.92	64.53	1.92	6.63	164.56	494.56	2025-12-09 23:55:48.073328
3535	sensor_rabano_2	21.22	67.72	72.63	1.83	6.74	164.04	437.39	2025-12-09 23:55:48.074112
3536	sensor_cilantro_1	22.20	71.58	69.37	1.61	6.69	158.76	400.12	2025-12-09 23:55:48.074341
3537	sensor_cilantro_2	20.91	71.65	64.76	1.56	6.62	149.22	407.46	2025-12-09 23:55:48.074501
3538	sensor_rabano_1	20.42	63.80	62.75	1.42	6.51	134.91	458.01	2025-12-09 23:55:58.084985
3539	sensor_rabano_2	20.25	65.65	74.52	1.98	6.62	189.20	435.45	2025-12-09 23:55:58.085851
3540	sensor_cilantro_1	19.71	68.36	71.97	1.99	6.63	191.40	422.71	2025-12-09 23:55:58.086086
3541	sensor_cilantro_2	20.45	65.12	65.81	1.67	6.53	111.95	404.88	2025-12-09 23:55:58.086238
3542	sensor_rabano_1	20.40	61.70	61.97	1.52	6.69	65.84	436.06	2025-12-09 23:56:08.097807
3543	sensor_rabano_2	23.59	68.56	68.65	1.46	6.50	134.42	462.59	2025-12-09 23:56:08.098628
3544	sensor_cilantro_1	20.60	74.71	68.44	1.42	6.69	62.59	474.05	2025-12-09 23:56:08.098833
3545	sensor_cilantro_2	20.85	73.04	64.98	1.83	6.48	167.79	469.23	2025-12-09 23:56:08.098983
3546	sensor_rabano_1	21.73	62.63	73.91	1.87	6.47	192.07	460.22	2025-12-09 23:56:18.164641
3547	sensor_rabano_2	20.71	68.93	67.69	1.64	6.74	146.03	471.92	2025-12-09 23:56:18.16551
3548	sensor_cilantro_1	21.06	62.67	78.07	1.77	6.66	105.44	431.55	2025-12-09 23:56:18.165707
3549	sensor_cilantro_2	19.72	67.49	62.30	1.76	6.67	114.40	460.42	2025-12-09 23:56:18.16586
3550	sensor_rabano_1	20.65	72.57	71.27	1.63	6.46	167.45	441.14	2025-12-09 23:56:28.175802
3551	sensor_rabano_2	21.46	67.96	76.38	1.48	6.73	117.73	402.69	2025-12-09 23:56:28.176664
3552	sensor_cilantro_1	20.70	67.93	68.46	1.46	6.54	143.23	440.14	2025-12-09 23:56:28.176977
3553	sensor_cilantro_2	19.20	72.00	60.28	1.73	6.49	142.29	499.64	2025-12-09 23:56:28.177156
3554	sensor_rabano_1	22.71	62.87	66.89	1.62	6.75	105.11	480.27	2025-12-09 23:56:38.188076
3555	sensor_rabano_2	20.09	66.81	78.86	1.78	6.65	85.77	445.34	2025-12-09 23:56:38.188934
3556	sensor_cilantro_1	22.78	63.30	60.62	1.49	6.80	105.06	425.59	2025-12-09 23:56:38.189112
3557	sensor_cilantro_2	21.13	72.96	62.29	1.40	6.43	71.99	431.14	2025-12-09 23:56:38.189195
3558	sensor_rabano_1	23.14	69.62	66.08	1.41	6.59	168.98	410.31	2025-12-09 23:56:48.200295
3559	sensor_rabano_2	22.24	61.28	77.14	1.82	6.52	157.73	495.30	2025-12-09 23:56:48.201055
3560	sensor_cilantro_1	20.00	67.12	67.60	1.77	6.65	139.16	409.57	2025-12-09 23:56:48.201225
3561	sensor_cilantro_2	22.86	72.28	78.88	1.57	6.54	80.14	499.71	2025-12-09 23:56:48.201362
3562	sensor_rabano_1	22.75	60.79	73.71	1.63	6.42	111.11	429.38	2025-12-09 23:56:58.2111
3563	sensor_rabano_2	23.89	65.07	74.68	1.97	6.77	91.00	451.54	2025-12-09 23:56:58.211933
3564	sensor_cilantro_1	22.46	76.17	65.39	1.81	6.73	131.19	408.16	2025-12-09 23:56:58.212119
3565	sensor_cilantro_2	21.67	62.41	73.20	1.65	6.52	159.69	466.92	2025-12-09 23:56:58.212262
3566	sensor_rabano_1	20.50	59.35	64.42	1.91	6.53	140.06	458.05	2025-12-09 23:57:08.221892
3567	sensor_rabano_2	21.96	62.76	76.37	1.65	6.63	177.83	496.28	2025-12-09 23:57:08.222482
3568	sensor_cilantro_1	21.23	63.22	78.47	1.99	6.40	156.54	484.25	2025-12-09 23:57:08.222617
3569	sensor_cilantro_2	20.22	68.56	63.57	1.85	6.52	126.17	448.26	2025-12-09 23:57:08.222717
3570	sensor_rabano_1	23.01	62.08	62.64	1.61	6.75	192.95	451.84	2025-12-09 23:57:18.230329
3571	sensor_rabano_2	22.14	57.05	77.81	1.87	6.61	196.77	408.17	2025-12-09 23:57:18.23091
3572	sensor_cilantro_1	21.37	70.45	63.35	1.65	6.40	57.95	403.14	2025-12-09 23:57:18.231017
3573	sensor_cilantro_2	19.95	70.94	70.25	1.46	6.42	149.79	425.78	2025-12-09 23:57:18.231077
3574	sensor_rabano_1	22.45	66.17	67.74	1.84	6.71	148.96	479.63	2025-12-09 23:57:28.258892
3575	sensor_rabano_2	21.45	60.01	63.64	1.74	6.57	84.21	486.32	2025-12-09 23:57:28.259793
3576	sensor_cilantro_1	21.18	74.98	79.94	1.98	6.51	65.93	438.38	2025-12-09 23:57:28.260028
3577	sensor_cilantro_2	21.57	77.56	64.27	1.67	6.61	189.48	436.56	2025-12-09 23:57:28.260179
3578	sensor_rabano_1	23.35	57.39	72.70	1.67	6.63	86.98	484.71	2025-12-09 23:57:38.270041
3579	sensor_rabano_2	21.61	66.20	78.29	1.80	6.64	80.90	440.13	2025-12-09 23:57:38.270897
3580	sensor_cilantro_1	21.96	69.58	65.76	1.92	6.70	141.05	439.04	2025-12-09 23:57:38.271086
3581	sensor_cilantro_2	22.28	77.82	63.98	1.60	6.41	133.11	438.67	2025-12-09 23:57:38.271236
3582	sensor_rabano_1	23.60	71.23	67.28	1.89	6.60	184.01	420.38	2025-12-09 23:57:48.282686
3583	sensor_rabano_2	21.57	66.49	76.22	1.89	6.62	177.86	483.71	2025-12-09 23:57:48.283643
3584	sensor_cilantro_1	22.08	77.14	71.38	1.60	6.69	78.05	474.48	2025-12-09 23:57:48.283903
3585	sensor_cilantro_2	20.61	63.17	64.07	1.88	6.67	67.73	489.12	2025-12-09 23:57:48.284085
3586	sensor_rabano_1	21.72	69.49	77.68	1.86	6.52	126.62	424.66	2025-12-09 23:57:58.294375
3587	sensor_rabano_2	20.88	66.09	60.94	1.72	6.79	54.02	464.01	2025-12-09 23:57:58.295189
3588	sensor_cilantro_1	19.23	71.41	74.84	1.48	6.67	115.75	413.90	2025-12-09 23:57:58.295377
3589	sensor_cilantro_2	22.51	65.69	68.75	1.95	6.43	76.39	496.70	2025-12-09 23:57:58.295519
3590	sensor_rabano_1	22.11	65.76	60.21	1.85	6.60	56.94	407.13	2025-12-09 23:58:08.305795
3591	sensor_rabano_2	22.57	58.81	76.08	1.67	6.79	139.60	486.06	2025-12-09 23:58:08.30664
3592	sensor_cilantro_1	22.95	68.95	79.22	1.40	6.63	99.06	499.73	2025-12-09 23:58:08.306915
3593	sensor_cilantro_2	22.01	66.14	63.71	1.65	6.65	65.84	450.37	2025-12-09 23:58:08.30709
3594	sensor_rabano_1	23.03	61.37	69.46	1.93	6.40	85.27	479.39	2025-12-09 23:58:18.318764
3595	sensor_rabano_2	23.94	67.73	70.63	1.93	6.40	146.61	480.43	2025-12-09 23:58:18.319553
3596	sensor_cilantro_1	22.54	75.30	61.18	1.77	6.48	181.95	416.45	2025-12-09 23:58:18.319799
3597	sensor_cilantro_2	22.52	73.77	79.90	1.62	6.44	166.00	423.96	2025-12-09 23:58:18.319959
3598	sensor_rabano_1	23.43	67.05	76.66	1.90	6.54	134.74	449.88	2025-12-09 23:58:28.330096
3599	sensor_rabano_2	20.99	61.12	69.99	1.62	6.58	141.28	422.04	2025-12-09 23:58:28.330695
3600	sensor_cilantro_1	19.13	72.71	61.05	1.57	6.56	170.54	469.73	2025-12-09 23:58:28.330875
3601	sensor_cilantro_2	21.19	67.78	75.74	1.99	6.63	70.01	445.32	2025-12-09 23:58:28.331056
3602	sensor_rabano_1	23.74	68.30	72.73	1.52	6.68	152.05	487.27	2025-12-09 23:58:38.342194
3603	sensor_rabano_2	21.92	68.91	79.76	1.72	6.71	110.29	438.53	2025-12-09 23:58:38.342986
3604	sensor_cilantro_1	22.67	75.06	67.01	1.80	6.66	98.82	408.71	2025-12-09 23:58:38.343167
3605	sensor_cilantro_2	20.32	68.54	65.81	1.99	6.68	177.93	462.91	2025-12-09 23:58:38.343308
3606	sensor_rabano_1	21.70	70.71	69.21	1.46	6.77	75.75	444.85	2025-12-09 23:58:48.353096
3607	sensor_rabano_2	22.09	72.88	67.50	1.44	6.68	111.23	407.70	2025-12-09 23:58:48.353694
3608	sensor_cilantro_1	20.19	72.87	62.24	1.80	6.52	168.59	414.17	2025-12-09 23:58:48.353787
3609	sensor_cilantro_2	19.14	64.40	77.04	1.65	6.41	119.14	437.41	2025-12-09 23:58:48.35385
3610	sensor_rabano_1	21.10	72.25	74.67	1.47	6.71	114.87	470.85	2025-12-09 23:58:58.36321
3611	sensor_rabano_2	23.74	69.85	77.88	1.71	6.51	88.08	497.58	2025-12-09 23:58:58.364212
3612	sensor_cilantro_1	19.53	63.82	65.46	1.47	6.61	56.58	481.58	2025-12-09 23:58:58.364444
3613	sensor_cilantro_2	22.89	65.98	78.09	1.42	6.43	127.38	462.39	2025-12-09 23:58:58.364644
3614	sensor_rabano_1	22.45	62.31	61.64	1.65	6.61	149.28	418.19	2025-12-09 23:59:08.375554
3615	sensor_rabano_2	23.95	58.34	77.24	1.70	6.54	100.38	471.88	2025-12-09 23:59:08.37646
3616	sensor_cilantro_1	22.75	72.88	70.65	1.50	6.58	160.57	497.68	2025-12-09 23:59:08.376663
3617	sensor_cilantro_2	22.21	62.66	71.15	1.76	6.54	190.66	479.03	2025-12-09 23:59:08.376923
3618	sensor_rabano_1	23.63	65.02	68.71	1.78	6.74	197.64	424.07	2025-12-09 23:59:18.452372
3619	sensor_rabano_2	22.49	70.40	63.87	1.91	6.69	66.67	447.47	2025-12-09 23:59:18.459008
3620	sensor_cilantro_1	21.81	70.30	75.22	1.61	6.48	149.68	442.42	2025-12-09 23:59:18.460008
3621	sensor_cilantro_2	22.49	73.32	68.11	1.76	6.50	188.52	482.53	2025-12-09 23:59:18.460285
3622	sensor_rabano_1	22.44	72.94	62.87	1.88	6.76	164.03	431.81	2025-12-09 23:59:28.471991
3623	sensor_rabano_2	23.07	69.07	61.91	1.80	6.66	151.90	438.19	2025-12-09 23:59:28.473087
3624	sensor_cilantro_1	22.60	74.59	63.72	1.46	6.48	186.13	433.07	2025-12-09 23:59:28.473462
3625	sensor_cilantro_2	22.89	63.55	67.07	1.86	6.63	175.17	483.34	2025-12-09 23:59:28.473739
3626	sensor_rabano_1	23.50	70.10	70.61	1.83	6.67	90.25	434.81	2025-12-09 23:59:38.484731
3627	sensor_rabano_2	23.41	60.33	64.48	1.72	6.75	151.43	421.68	2025-12-09 23:59:38.485676
3628	sensor_cilantro_1	19.19	72.50	73.64	1.53	6.43	162.28	403.66	2025-12-09 23:59:38.486009
3629	sensor_cilantro_2	19.09	72.49	72.97	1.53	6.73	79.52	472.56	2025-12-09 23:59:38.486187
3630	sensor_rabano_1	21.72	65.87	60.71	1.41	6.74	170.06	489.54	2025-12-09 23:59:48.51388
3631	sensor_rabano_2	22.13	62.39	68.41	1.45	6.58	70.53	442.10	2025-12-09 23:59:48.517163
3632	sensor_cilantro_1	19.91	71.87	72.24	1.71	6.43	166.69	434.51	2025-12-09 23:59:48.518029
3633	sensor_cilantro_2	19.94	77.29	60.98	1.51	6.71	115.27	483.02	2025-12-09 23:59:48.51872
3634	sensor_rabano_1	20.74	67.68	71.25	1.83	6.60	121.75	479.05	2025-12-09 23:59:58.543695
3635	sensor_rabano_2	20.98	58.56	78.48	1.45	6.69	184.13	449.50	2025-12-09 23:59:58.545473
3636	sensor_cilantro_1	20.35	66.58	65.75	1.52	6.58	128.63	427.25	2025-12-09 23:59:58.545917
3637	sensor_cilantro_2	21.15	67.54	73.69	1.82	6.66	95.65	406.24	2025-12-09 23:59:58.546144
3638	sensor_rabano_1	21.31	62.16	78.30	1.99	6.59	183.81	482.81	2025-12-10 00:00:08.558155
3639	sensor_rabano_2	22.90	70.38	63.07	1.69	6.54	55.66	419.33	2025-12-10 00:00:08.559003
3640	sensor_cilantro_1	20.36	67.41	63.17	1.42	6.60	101.51	415.38	2025-12-10 00:00:08.559239
3641	sensor_cilantro_2	21.33	68.37	67.73	1.54	6.78	196.91	479.09	2025-12-10 00:00:08.559406
3642	sensor_rabano_1	23.83	57.39	68.66	1.91	6.53	191.38	487.75	2025-12-10 00:00:18.577791
3643	sensor_rabano_2	20.05	62.77	76.41	1.45	6.56	100.95	460.64	2025-12-10 00:00:18.57934
3644	sensor_cilantro_1	21.47	76.38	66.35	1.44	6.67	126.95	405.61	2025-12-10 00:00:18.579891
3645	sensor_cilantro_2	19.64	72.16	69.89	1.84	6.80	77.06	455.98	2025-12-10 00:00:18.580655
3646	sensor_rabano_1	22.39	68.86	64.14	1.64	6.44	152.93	467.26	2025-12-10 00:00:28.600188
3647	sensor_rabano_2	23.98	58.29	65.99	1.65	6.50	156.34	483.02	2025-12-10 00:00:28.601716
3648	sensor_cilantro_1	22.61	63.49	70.30	1.94	6.75	192.01	426.66	2025-12-10 00:00:28.602211
3649	sensor_cilantro_2	19.97	65.05	68.19	1.72	6.59	65.73	403.13	2025-12-10 00:00:28.602542
3650	sensor_rabano_1	23.42	61.62	60.38	1.55	6.48	143.33	481.82	2025-12-10 00:00:38.628508
3651	sensor_rabano_2	20.70	66.17	67.62	1.70	6.73	70.58	492.58	2025-12-10 00:00:38.630092
3652	sensor_cilantro_1	20.44	74.65	74.57	1.46	6.42	178.31	494.53	2025-12-10 00:00:38.630488
3653	sensor_cilantro_2	20.94	69.62	63.28	1.81	6.50	159.59	483.34	2025-12-10 00:00:38.630905
3654	sensor_rabano_1	21.05	66.61	65.60	1.44	6.51	55.22	480.33	2025-12-10 00:00:48.655941
3655	sensor_rabano_2	22.77	59.48	74.10	1.74	6.79	160.02	487.38	2025-12-10 00:00:48.656703
3656	sensor_cilantro_1	20.58	74.42	65.18	1.51	6.61	114.14	403.75	2025-12-10 00:00:48.656802
3657	sensor_cilantro_2	19.83	67.68	75.33	1.91	6.58	198.97	449.58	2025-12-10 00:00:48.656862
3658	sensor_rabano_1	21.71	57.10	78.51	1.94	6.74	99.25	428.40	2025-12-10 00:00:58.677122
3659	sensor_rabano_2	22.02	66.25	70.76	1.96	6.63	121.96	487.39	2025-12-10 00:00:58.679012
3660	sensor_cilantro_1	22.54	62.06	77.73	1.83	6.75	71.59	469.40	2025-12-10 00:00:58.679423
3661	sensor_cilantro_2	20.32	76.25	69.52	1.54	6.46	123.64	439.18	2025-12-10 00:00:58.67959
3662	sensor_rabano_1	20.58	71.23	70.47	1.72	6.78	189.81	444.60	2025-12-10 00:01:08.705093
3663	sensor_rabano_2	21.53	72.21	73.98	1.51	6.63	50.90	469.05	2025-12-10 00:01:08.706961
3664	sensor_cilantro_1	21.73	74.83	63.88	1.94	6.40	118.16	471.25	2025-12-10 00:01:08.707519
3665	sensor_cilantro_2	21.94	75.43	62.47	1.51	6.70	186.45	410.78	2025-12-10 00:01:08.708088
3666	sensor_rabano_1	23.02	62.41	62.77	1.82	6.80	64.09	449.32	2025-12-10 00:01:18.814091
3667	sensor_rabano_2	23.39	70.04	67.74	1.43	6.60	187.51	410.90	2025-12-10 00:01:18.815755
3668	sensor_cilantro_1	20.00	72.19	74.34	1.60	6.56	124.23	454.87	2025-12-10 00:01:18.816268
3669	sensor_cilantro_2	19.41	66.00	71.88	1.87	6.51	150.22	432.31	2025-12-10 00:01:18.816665
3670	sensor_rabano_1	22.12	65.70	63.43	1.54	6.76	182.10	464.93	2025-12-10 00:01:28.840306
3671	sensor_rabano_2	22.06	63.65	61.86	1.72	6.55	196.57	412.67	2025-12-10 00:01:28.841684
3672	sensor_cilantro_1	22.22	63.94	76.07	1.94	6.56	138.81	416.45	2025-12-10 00:01:28.842216
3673	sensor_cilantro_2	19.15	74.42	67.23	1.60	6.76	121.54	447.06	2025-12-10 00:01:28.842694
3674	sensor_rabano_1	21.91	57.59	72.86	1.91	6.47	160.80	485.40	2025-12-10 00:01:38.863894
3675	sensor_rabano_2	22.01	71.46	71.50	1.55	6.77	114.94	445.89	2025-12-10 00:01:38.865579
3676	sensor_cilantro_1	20.00	68.11	75.28	1.95	6.48	164.10	463.65	2025-12-10 00:01:38.866224
3677	sensor_cilantro_2	22.20	73.87	69.07	1.46	6.73	123.36	401.20	2025-12-10 00:01:38.866502
3678	sensor_rabano_1	21.48	61.00	63.70	1.64	6.53	93.87	440.04	2025-12-10 00:01:48.881244
3679	sensor_rabano_2	21.09	70.44	70.57	1.52	6.59	195.98	402.96	2025-12-10 00:01:48.882092
3680	sensor_cilantro_1	20.28	73.18	77.21	1.47	6.45	160.71	475.21	2025-12-10 00:01:48.88227
3681	sensor_cilantro_2	20.40	68.04	72.03	1.71	6.60	102.92	413.73	2025-12-10 00:01:48.88237
3682	sensor_rabano_1	23.41	66.79	71.76	1.98	6.43	171.16	449.98	2025-12-10 00:01:58.895487
3683	sensor_rabano_2	20.66	57.87	72.28	1.80	6.66	132.35	428.49	2025-12-10 00:01:58.896494
3684	sensor_cilantro_1	22.04	62.68	65.12	1.56	6.58	124.96	467.40	2025-12-10 00:01:58.89676
3685	sensor_cilantro_2	19.06	67.77	74.45	1.87	6.57	116.50	453.59	2025-12-10 00:01:58.897077
3686	sensor_rabano_1	20.27	61.78	66.63	1.44	6.79	61.73	401.00	2025-12-10 00:02:08.922087
3687	sensor_rabano_2	22.03	65.83	60.80	1.64	6.76	113.36	423.56	2025-12-10 00:02:08.92371
3688	sensor_cilantro_1	22.28	72.50	71.55	1.85	6.69	144.69	461.31	2025-12-10 00:02:08.924234
3689	sensor_cilantro_2	20.78	69.19	76.40	1.95	6.44	74.05	411.37	2025-12-10 00:02:08.924471
3690	sensor_rabano_1	23.41	66.69	79.86	1.72	6.70	103.28	431.53	2025-12-10 00:02:18.947093
3691	sensor_rabano_2	20.44	67.28	60.92	1.47	6.54	80.93	466.11	2025-12-10 00:02:18.949217
3692	sensor_cilantro_1	21.87	72.61	76.23	1.67	6.80	95.77	436.82	2025-12-10 00:02:18.949829
3693	sensor_cilantro_2	22.44	68.48	69.62	1.76	6.68	154.49	415.60	2025-12-10 00:02:18.950461
3694	sensor_rabano_1	23.35	59.90	63.41	1.55	6.50	114.90	454.87	2025-12-10 00:02:28.976136
3695	sensor_rabano_2	20.05	67.06	73.84	1.50	6.60	162.45	410.29	2025-12-10 00:02:28.977504
3696	sensor_cilantro_1	19.75	68.30	68.93	1.85	6.56	154.98	429.80	2025-12-10 00:02:28.977901
3697	sensor_cilantro_2	20.11	73.08	64.13	1.72	6.66	103.50	410.15	2025-12-10 00:02:28.978365
3698	sensor_rabano_1	20.64	67.61	75.38	1.45	6.53	174.66	491.04	2025-12-10 00:02:38.996706
3699	sensor_rabano_2	23.90	72.26	77.18	1.53	6.45	192.09	412.94	2025-12-10 00:02:38.997856
3700	sensor_cilantro_1	21.99	74.23	67.80	1.59	6.74	73.51	404.19	2025-12-10 00:02:38.99814
3701	sensor_cilantro_2	22.85	66.51	73.62	1.50	6.73	185.24	464.08	2025-12-10 00:02:38.998356
3702	sensor_rabano_1	23.75	63.08	62.08	1.51	6.66	125.54	443.72	2025-12-10 00:02:49.021165
3703	sensor_rabano_2	23.01	58.67	78.94	1.85	6.65	75.49	491.06	2025-12-10 00:02:49.022552
3704	sensor_cilantro_1	21.08	76.62	61.70	1.68	6.66	88.53	452.56	2025-12-10 00:02:49.023033
3705	sensor_cilantro_2	20.44	63.52	77.42	1.57	6.46	102.13	426.78	2025-12-10 00:02:49.023333
3706	sensor_rabano_1	22.46	58.51	69.80	1.73	6.41	144.52	406.09	2025-12-10 00:02:59.03517
3707	sensor_rabano_2	20.37	70.99	62.12	1.76	6.63	56.04	425.79	2025-12-10 00:02:59.036101
3708	sensor_cilantro_1	21.83	77.67	68.50	1.82	6.41	87.18	492.29	2025-12-10 00:02:59.036373
3709	sensor_cilantro_2	21.65	75.06	75.40	1.59	6.78	75.43	471.17	2025-12-10 00:02:59.036539
3710	sensor_rabano_1	23.54	60.24	66.79	1.58	6.47	173.12	477.39	2025-12-10 00:03:09.05704
3711	sensor_rabano_2	23.84	68.22	66.11	1.61	6.56	133.30	478.47	2025-12-10 00:03:09.058906
3712	sensor_cilantro_1	20.83	70.83	78.08	1.65	6.60	134.98	436.38	2025-12-10 00:03:09.059502
3713	sensor_cilantro_2	20.46	67.28	66.29	1.41	6.49	113.57	414.04	2025-12-10 00:03:09.059996
3714	sensor_rabano_1	20.34	60.81	62.61	1.54	6.63	196.04	417.48	2025-12-10 00:03:19.086936
3715	sensor_rabano_2	20.01	59.43	72.03	1.91	6.61	184.19	467.19	2025-12-10 00:03:19.088569
3716	sensor_cilantro_1	22.09	74.41	69.38	1.63	6.52	110.32	491.65	2025-12-10 00:03:19.089099
3717	sensor_cilantro_2	20.26	62.95	72.36	1.77	6.66	167.81	412.79	2025-12-10 00:03:19.089489
3718	sensor_rabano_1	22.38	59.04	66.94	1.71	6.42	62.91	492.00	2025-12-10 00:03:29.103655
3719	sensor_rabano_2	22.39	60.33	78.33	1.58	6.51	168.42	496.90	2025-12-10 00:03:29.104886
3720	sensor_cilantro_1	19.33	74.74	60.29	1.46	6.66	121.17	416.45	2025-12-10 00:03:29.105206
3721	sensor_cilantro_2	21.20	63.75	69.78	1.97	6.78	113.63	484.73	2025-12-10 00:03:29.105425
3722	sensor_rabano_1	20.56	59.17	63.59	1.57	6.46	197.24	478.02	2025-12-10 00:03:39.116235
3723	sensor_rabano_2	23.94	62.55	78.50	1.91	6.51	156.92	472.01	2025-12-10 00:03:39.117075
3724	sensor_cilantro_1	22.45	76.86	60.70	1.92	6.71	58.30	430.92	2025-12-10 00:03:39.117273
3725	sensor_cilantro_2	19.58	77.47	71.78	1.79	6.73	163.86	499.68	2025-12-10 00:03:39.117496
3726	sensor_rabano_1	23.90	70.53	66.29	1.83	6.48	86.48	417.47	2025-12-10 00:03:49.139611
3727	sensor_rabano_2	22.81	72.17	60.39	1.71	6.53	83.10	480.45	2025-12-10 00:03:49.141528
3728	sensor_cilantro_1	21.35	67.18	69.41	1.55	6.66	144.01	462.56	2025-12-10 00:03:49.142095
3729	sensor_cilantro_2	19.44	65.31	68.37	1.50	6.42	76.91	478.43	2025-12-10 00:03:49.142303
3730	sensor_rabano_1	20.83	60.85	74.71	1.71	6.44	117.28	433.07	2025-12-10 00:03:59.164538
3731	sensor_rabano_2	23.59	59.65	62.93	1.78	6.47	178.66	408.43	2025-12-10 00:03:59.166189
3732	sensor_cilantro_1	20.52	63.40	68.98	1.44	6.48	159.39	445.73	2025-12-10 00:03:59.166638
3733	sensor_cilantro_2	20.32	76.49	68.90	1.56	6.68	196.67	426.18	2025-12-10 00:03:59.167012
3734	sensor_rabano_1	22.33	68.27	69.65	1.94	6.55	118.80	469.43	2025-12-10 00:04:09.19134
3735	sensor_rabano_2	21.43	58.84	62.00	1.73	6.44	97.06	470.98	2025-12-10 00:04:09.193164
3736	sensor_cilantro_1	22.28	66.60	72.22	1.43	6.52	118.52	484.60	2025-12-10 00:04:09.193461
3737	sensor_cilantro_2	20.47	73.56	75.88	1.62	6.60	68.50	420.20	2025-12-10 00:04:09.193608
3738	sensor_rabano_1	23.31	69.69	71.51	1.93	6.40	67.48	420.12	2025-12-10 00:04:19.204589
3739	sensor_rabano_2	20.28	70.45	70.41	1.72	6.68	74.90	473.35	2025-12-10 00:04:19.205492
3740	sensor_cilantro_1	20.58	62.99	61.85	1.88	6.58	54.00	494.16	2025-12-10 00:04:19.205745
3741	sensor_cilantro_2	22.92	65.12	79.14	1.76	6.42	142.66	447.68	2025-12-10 00:04:19.205951
3742	sensor_rabano_1	22.39	70.38	73.38	1.53	6.68	137.30	457.02	2025-12-10 00:04:29.227798
3743	sensor_rabano_2	23.65	72.52	74.69	1.76	6.51	55.41	437.19	2025-12-10 00:04:29.229239
3744	sensor_cilantro_1	21.45	65.09	70.54	1.41	6.80	121.64	427.77	2025-12-10 00:04:29.229588
3745	sensor_cilantro_2	20.53	72.91	76.03	1.65	6.61	175.36	432.61	2025-12-10 00:04:29.230167
3746	sensor_rabano_1	21.12	59.99	70.59	1.68	6.56	136.16	451.21	2025-12-10 00:04:39.250894
3747	sensor_rabano_2	20.76	63.90	64.66	1.72	6.78	128.36	408.07	2025-12-10 00:04:39.25205
3748	sensor_cilantro_1	19.03	75.37	61.27	1.52	6.46	108.18	460.01	2025-12-10 00:04:39.252239
3749	sensor_cilantro_2	19.81	75.89	61.64	1.69	6.72	167.82	407.53	2025-12-10 00:04:39.252368
3750	sensor_rabano_1	21.57	72.93	66.71	1.81	6.67	192.08	436.82	2025-12-10 00:04:49.275125
3751	sensor_rabano_2	20.44	67.19	66.55	1.40	6.47	61.33	423.96	2025-12-10 00:04:49.276354
3752	sensor_cilantro_1	19.15	63.07	66.04	1.57	6.47	93.51	448.52	2025-12-10 00:04:49.276788
3753	sensor_cilantro_2	20.18	76.56	63.81	1.62	6.52	91.08	429.51	2025-12-10 00:04:49.277058
3754	sensor_rabano_1	20.73	61.15	65.41	1.72	6.41	170.78	494.24	2025-12-10 00:04:59.288135
3755	sensor_rabano_2	20.77	69.57	78.00	1.61	6.55	150.71	466.05	2025-12-10 00:04:59.289105
3756	sensor_cilantro_1	20.31	67.82	74.78	1.42	6.72	184.48	495.28	2025-12-10 00:04:59.289319
3757	sensor_cilantro_2	20.30	70.47	76.11	1.71	6.64	70.62	421.22	2025-12-10 00:04:59.289497
3758	sensor_rabano_1	21.33	58.51	77.22	1.47	6.65	146.05	486.76	2025-12-10 00:05:09.311333
3759	sensor_rabano_2	21.05	60.23	78.62	1.65	6.73	113.97	428.71	2025-12-10 00:05:09.312387
3760	sensor_cilantro_1	20.59	74.19	75.72	1.73	6.59	77.23	445.97	2025-12-10 00:05:09.312581
3761	sensor_cilantro_2	21.81	77.02	73.61	1.46	6.65	142.78	482.62	2025-12-10 00:05:09.312746
3762	sensor_rabano_1	20.83	66.83	79.82	2.00	6.69	115.69	477.43	2025-12-10 00:05:19.33368
3763	sensor_rabano_2	22.57	64.41	63.87	1.53	6.49	184.06	417.21	2025-12-10 00:05:19.335558
3764	sensor_cilantro_1	21.28	67.17	73.11	1.82	6.76	131.63	486.31	2025-12-10 00:05:19.335979
3765	sensor_cilantro_2	19.49	71.74	63.17	1.46	6.79	73.98	438.85	2025-12-10 00:05:19.33617
3766	sensor_rabano_1	22.07	63.89	78.97	1.58	6.50	145.74	435.62	2025-12-10 00:05:29.359074
3767	sensor_rabano_2	23.80	61.22	66.87	1.42	6.58	123.88	453.50	2025-12-10 00:05:29.360506
3768	sensor_cilantro_1	21.05	68.85	76.48	1.80	6.53	91.44	492.74	2025-12-10 00:05:29.360911
3769	sensor_cilantro_2	22.72	69.96	63.05	1.84	6.77	56.22	478.51	2025-12-10 00:05:29.361288
3770	sensor_rabano_1	23.31	67.73	75.87	1.94	6.46	92.53	420.58	2025-12-10 00:05:39.386145
3771	sensor_rabano_2	22.83	72.10	67.16	1.62	6.51	63.28	456.91	2025-12-10 00:05:39.387809
3772	sensor_cilantro_1	21.75	66.67	63.89	1.49	6.66	130.07	449.75	2025-12-10 00:05:39.388314
3773	sensor_cilantro_2	20.57	66.75	74.55	1.60	6.46	172.25	455.28	2025-12-10 00:05:39.388718
3774	sensor_rabano_1	23.27	66.59	61.33	1.86	6.77	142.61	425.08	2025-12-10 00:05:49.398721
3775	sensor_rabano_2	21.09	60.00	71.53	1.97	6.75	193.28	460.47	2025-12-10 00:05:49.399538
3776	sensor_cilantro_1	22.82	75.83	72.76	1.56	6.47	147.37	420.05	2025-12-10 00:05:49.399774
3777	sensor_cilantro_2	19.89	66.16	76.96	1.91	6.50	86.96	482.94	2025-12-10 00:05:49.400022
3778	sensor_rabano_1	21.36	59.13	74.69	1.60	6.44	165.98	485.41	2025-12-10 00:05:59.412398
3779	sensor_rabano_2	20.73	63.58	62.24	1.70	6.69	136.52	469.73	2025-12-10 00:05:59.413271
3780	sensor_cilantro_1	22.60	68.19	74.36	1.87	6.41	72.39	445.57	2025-12-10 00:05:59.413467
3781	sensor_cilantro_2	22.68	75.02	62.51	1.72	6.64	144.19	463.34	2025-12-10 00:05:59.413628
3782	sensor_rabano_1	20.75	57.63	74.00	1.49	6.45	195.52	451.54	2025-12-10 00:06:09.437766
3783	sensor_rabano_2	21.86	66.82	63.51	1.78	6.79	180.14	486.36	2025-12-10 00:06:09.439684
3784	sensor_cilantro_1	20.26	74.73	68.61	1.52	6.46	91.82	425.09	2025-12-10 00:06:09.440248
3785	sensor_cilantro_2	21.54	75.14	73.25	1.50	6.72	195.74	404.77	2025-12-10 00:06:09.44066
3786	sensor_rabano_1	23.26	68.51	76.70	1.75	6.74	92.23	412.44	2025-12-10 00:06:19.586994
3787	sensor_rabano_2	20.17	64.55	63.94	1.66	6.61	174.16	465.10	2025-12-10 00:06:19.587678
3788	sensor_cilantro_1	19.80	69.06	63.01	1.74	6.77	70.95	448.85	2025-12-10 00:06:19.587879
3789	sensor_cilantro_2	20.65	64.38	67.59	1.74	6.62	68.95	460.85	2025-12-10 00:06:19.587997
3790	sensor_rabano_1	22.63	70.09	72.38	1.72	6.46	818.45	424.20	2025-12-10 10:42:12.518807
3791	sensor_rabano_2	22.20	61.07	65.24	2.00	6.77	1035.38	499.75	2025-12-10 10:42:12.524707
3792	sensor_cilantro_1	22.60	66.92	77.78	1.54	6.53	804.40	499.15	2025-12-10 10:42:12.525051
3793	sensor_cilantro_2	20.34	72.16	76.01	2.00	6.55	817.14	428.62	2025-12-10 10:42:12.525252
3794	sensor_rabano_1	21.34	65.88	63.21	1.98	6.45	807.96	424.93	2025-12-10 10:42:22.536116
3795	sensor_rabano_2	20.46	60.20	62.32	1.66	6.50	1085.23	412.55	2025-12-10 10:42:22.537188
3796	sensor_cilantro_1	22.19	74.14	63.87	1.44	6.54	1028.40	481.90	2025-12-10 10:42:22.537434
3797	sensor_cilantro_2	21.62	69.69	75.71	1.63	6.42	970.59	413.96	2025-12-10 10:42:22.537713
3798	sensor_rabano_1	22.25	71.99	68.26	1.74	6.54	832.30	454.96	2025-12-10 10:42:32.548199
3799	sensor_rabano_2	20.75	62.57	76.95	1.59	6.49	1148.98	445.84	2025-12-10 10:42:32.549041
3800	sensor_cilantro_1	21.14	73.58	78.41	1.73	6.54	1035.05	458.56	2025-12-10 10:42:32.549225
3801	sensor_cilantro_2	21.08	62.82	63.23	1.93	6.74	1015.62	480.24	2025-12-10 10:42:32.549438
3802	sensor_rabano_1	23.86	72.76	60.79	1.94	6.41	946.68	460.51	2025-12-10 10:42:42.55974
3803	sensor_rabano_2	21.86	65.79	72.03	1.80	6.61	939.26	480.45	2025-12-10 10:42:42.560595
3804	sensor_cilantro_1	20.31	69.25	69.08	1.76	6.51	975.36	478.63	2025-12-10 10:42:42.56081
3805	sensor_cilantro_2	20.21	65.99	70.08	1.50	6.65	1028.43	496.96	2025-12-10 10:42:42.561015
3806	sensor_rabano_1	21.79	68.98	67.36	1.64	6.77	865.00	482.34	2025-12-10 10:42:52.571254
3807	sensor_rabano_2	20.41	68.53	62.78	1.90	6.75	1196.08	406.67	2025-12-10 10:42:52.572072
3808	sensor_cilantro_1	20.40	77.27	75.24	1.49	6.55	882.16	497.17	2025-12-10 10:42:52.572249
3809	sensor_cilantro_2	21.55	76.56	78.30	1.93	6.72	1084.27	428.26	2025-12-10 10:42:52.572453
3810	sensor_rabano_1	23.84	59.20	64.54	1.76	6.68	816.74	446.71	2025-12-10 10:43:02.582938
3811	sensor_rabano_2	21.39	57.86	79.10	1.66	6.63	808.66	438.56	2025-12-10 10:43:02.583679
3812	sensor_cilantro_1	21.12	65.04	61.18	1.45	6.61	1168.11	423.22	2025-12-10 10:43:02.583907
3813	sensor_cilantro_2	22.75	74.61	75.89	1.97	6.53	1189.90	462.86	2025-12-10 10:43:02.584064
3814	sensor_rabano_1	20.38	62.51	77.71	1.44	6.64	857.00	490.94	2025-12-10 10:43:12.594172
3815	sensor_rabano_2	20.68	58.40	61.61	1.86	6.75	971.15	441.39	2025-12-10 10:43:12.594952
3816	sensor_cilantro_1	20.89	63.61	77.45	1.54	6.76	1001.29	446.64	2025-12-10 10:43:12.595138
3817	sensor_cilantro_2	19.92	76.21	71.40	1.80	6.71	872.71	416.66	2025-12-10 10:43:12.595288
3818	sensor_rabano_1	23.40	61.77	71.02	1.55	6.48	966.44	461.79	2025-12-10 10:43:22.602873
3819	sensor_rabano_2	20.34	58.13	69.32	1.80	6.61	884.85	416.08	2025-12-10 10:43:22.603367
3820	sensor_cilantro_1	22.52	62.75	66.04	1.80	6.64	861.89	424.65	2025-12-10 10:43:22.603447
3821	sensor_cilantro_2	19.61	77.37	68.95	1.62	6.77	942.42	440.56	2025-12-10 10:43:22.603503
3822	sensor_rabano_1	21.45	58.55	69.79	1.60	6.64	1045.62	495.91	2025-12-10 10:43:32.613187
3823	sensor_rabano_2	20.85	64.84	64.80	1.49	6.42	1162.89	442.60	2025-12-10 10:43:32.614002
3824	sensor_cilantro_1	22.96	77.83	70.79	1.87	6.49	1183.26	405.58	2025-12-10 10:43:32.614178
3825	sensor_cilantro_2	21.48	71.33	72.56	1.66	6.57	805.63	485.95	2025-12-10 10:43:32.614336
3826	sensor_rabano_1	22.72	62.75	75.92	1.90	6.64	809.98	446.04	2025-12-10 10:43:42.624345
3827	sensor_rabano_2	21.81	58.03	70.18	1.49	6.65	1167.86	463.98	2025-12-10 10:43:42.625174
3828	sensor_cilantro_1	21.43	67.12	71.93	1.42	6.49	977.28	469.15	2025-12-10 10:43:42.625375
3829	sensor_cilantro_2	19.12	63.65	60.82	1.65	6.47	803.00	445.96	2025-12-10 10:43:42.625524
3830	sensor_rabano_1	22.04	68.34	72.54	1.49	6.65	993.35	495.41	2025-12-10 16:43:51.545963
3831	sensor_rabano_2	20.71	65.03	73.63	1.78	6.53	846.85	489.06	2025-12-10 16:43:51.546743
3832	sensor_cilantro_1	20.09	76.61	72.72	1.44	6.48	1037.08	415.99	2025-12-10 16:43:51.546929
3833	sensor_cilantro_2	21.66	76.34	63.94	1.80	6.64	865.72	410.47	2025-12-10 16:43:51.547075
3834	sensor_rabano_1	21.77	64.21	67.73	1.41	6.79	905.48	448.33	2025-12-10 16:44:01.632351
3835	sensor_rabano_2	20.56	64.13	71.28	1.83	6.41	829.82	452.85	2025-12-10 16:44:01.632925
3836	sensor_cilantro_1	21.17	62.05	66.61	1.71	6.64	1120.51	464.46	2025-12-10 16:44:01.633007
3837	sensor_cilantro_2	20.26	71.51	72.48	1.95	6.64	1044.62	401.48	2025-12-10 16:44:01.633069
3838	sensor_rabano_1	20.20	72.11	67.06	1.69	6.79	1010.50	409.45	2025-12-10 16:44:11.641354
3839	sensor_rabano_2	23.37	72.89	60.90	1.46	6.52	1093.47	475.57	2025-12-10 16:44:11.641842
3840	sensor_cilantro_1	22.27	66.78	72.10	1.78	6.69	965.62	450.69	2025-12-10 16:44:11.641925
3841	sensor_cilantro_2	20.89	77.96	79.17	1.47	6.55	1187.32	408.83	2025-12-10 16:44:11.641981
3842	sensor_rabano_1	21.54	72.81	61.25	1.55	6.51	1127.14	404.28	2025-12-10 16:44:22.643792
3843	sensor_rabano_2	22.85	62.87	71.93	1.66	6.80	838.58	488.77	2025-12-10 16:44:22.64479
3844	sensor_cilantro_1	21.94	65.77	64.09	1.74	6.52	1187.85	406.85	2025-12-10 16:44:22.645159
3845	sensor_cilantro_2	21.75	73.79	60.32	1.81	6.64	1037.58	482.50	2025-12-10 16:44:22.645414
3846	sensor_rabano_1	22.56	59.86	79.06	1.67	6.64	884.54	480.86	2025-12-10 16:44:32.655591
3847	sensor_rabano_2	22.21	63.40	73.19	1.81	6.57	1082.88	463.48	2025-12-10 16:44:32.656699
3848	sensor_cilantro_1	19.84	72.63	67.56	1.89	6.53	1036.85	468.10	2025-12-10 16:44:32.657068
3849	sensor_cilantro_2	22.50	62.85	72.34	1.81	6.50	1133.82	469.27	2025-12-10 16:44:32.657341
3850	sensor_rabano_1	23.53	70.74	61.54	1.96	6.55	1184.67	466.39	2025-12-10 16:44:42.667759
3851	sensor_rabano_2	22.53	62.99	72.83	1.47	6.66	853.98	422.61	2025-12-10 16:44:42.668573
3852	sensor_cilantro_1	19.51	74.81	64.00	1.98	6.77	1092.81	411.00	2025-12-10 16:44:42.669224
3853	sensor_cilantro_2	22.07	75.70	75.45	1.84	6.56	1187.68	467.07	2025-12-10 16:44:42.669403
3854	sensor_rabano_1	21.18	67.79	79.18	1.46	6.52	1183.59	421.18	2025-12-10 16:44:52.679552
3855	sensor_rabano_2	23.09	66.23	77.05	1.44	6.74	1150.73	408.50	2025-12-10 16:44:52.680475
3856	sensor_cilantro_1	19.31	75.15	79.33	1.84	6.46	1117.72	466.29	2025-12-10 16:44:52.680642
3857	sensor_cilantro_2	21.11	68.11	68.44	1.72	6.72	961.25	452.38	2025-12-10 16:44:52.680795
3858	sensor_rabano_1	22.76	58.29	74.39	1.94	6.59	801.73	418.42	2025-12-10 16:45:02.690857
3859	sensor_rabano_2	21.14	71.33	74.15	1.47	6.43	1125.69	481.36	2025-12-10 16:45:02.691649
3860	sensor_cilantro_1	19.20	68.52	77.39	1.66	6.62	1198.19	440.68	2025-12-10 16:45:02.691857
3861	sensor_cilantro_2	22.15	62.53	78.59	1.43	6.64	801.93	494.77	2025-12-10 16:45:02.692006
3862	sensor_rabano_1	20.02	61.78	76.38	1.42	6.61	1030.98	483.21	2025-12-10 16:45:12.704748
3863	sensor_rabano_2	20.45	59.38	68.86	1.84	6.59	859.93	489.66	2025-12-10 16:45:12.705589
3864	sensor_cilantro_1	20.99	77.07	65.36	1.72	6.40	1125.11	458.77	2025-12-10 16:45:12.705839
3865	sensor_cilantro_2	19.43	68.78	73.20	1.70	6.46	1133.13	412.34	2025-12-10 16:45:12.70607
3866	sensor_rabano_1	22.83	64.47	74.01	1.57	6.52	1184.06	449.68	2025-12-10 16:45:22.716026
3867	sensor_rabano_2	23.86	64.53	61.07	1.47	6.69	1093.22	480.15	2025-12-10 16:45:22.716891
3868	sensor_cilantro_1	22.28	73.22	73.90	1.53	6.70	874.28	470.92	2025-12-10 16:45:22.717132
3869	sensor_cilantro_2	19.97	62.66	78.39	1.66	6.54	963.27	420.92	2025-12-10 16:45:22.717295
3870	sensor_rabano_1	21.89	57.10	61.06	1.81	6.60	931.54	424.97	2025-12-10 16:45:32.726923
3871	sensor_rabano_2	23.32	67.25	63.74	1.75	6.50	1155.01	457.91	2025-12-10 16:45:32.727807
3872	sensor_cilantro_1	19.11	73.63	78.73	1.88	6.69	879.87	422.91	2025-12-10 16:45:32.728059
3873	sensor_cilantro_2	20.19	69.79	61.95	1.66	6.70	1062.72	439.32	2025-12-10 16:45:32.728266
3874	sensor_rabano_1	20.29	61.01	68.30	1.78	6.54	1173.51	432.16	2025-12-10 16:45:42.73985
3875	sensor_rabano_2	20.52	65.31	76.48	1.48	6.67	887.32	454.45	2025-12-10 16:45:42.740829
3876	sensor_cilantro_1	21.29	73.81	68.55	1.81	6.75	974.00	433.97	2025-12-10 16:45:42.741104
3877	sensor_cilantro_2	20.40	62.98	72.97	1.72	6.71	944.28	496.69	2025-12-10 16:45:42.741306
3878	sensor_rabano_1	23.42	57.14	61.11	1.84	6.52	969.25	438.46	2025-12-10 16:45:52.750018
3879	sensor_rabano_2	22.62	64.99	74.60	1.54	6.41	988.59	419.89	2025-12-10 16:45:52.750786
3880	sensor_cilantro_1	22.62	76.29	76.77	1.57	6.74	883.69	472.59	2025-12-10 16:45:52.75096
3881	sensor_cilantro_2	22.48	64.82	65.83	1.75	6.48	1155.31	433.52	2025-12-10 16:45:52.751042
3882	sensor_rabano_1	22.55	69.97	79.93	1.41	6.60	1063.23	440.22	2025-12-10 16:46:02.762772
3883	sensor_rabano_2	22.85	60.21	74.52	1.40	6.43	861.13	494.06	2025-12-10 16:46:02.763643
3884	sensor_cilantro_1	22.93	66.37	66.83	1.65	6.51	834.89	437.36	2025-12-10 16:46:02.763848
3885	sensor_cilantro_2	21.69	72.04	68.80	1.95	6.74	917.33	454.27	2025-12-10 16:46:02.763989
3886	sensor_rabano_1	22.12	62.11	79.79	1.90	6.73	1051.92	429.65	2025-12-10 16:46:12.775689
3887	sensor_rabano_2	23.38	69.34	72.74	1.61	6.71	1176.08	406.75	2025-12-10 16:46:12.776544
3888	sensor_cilantro_1	19.24	62.27	77.90	1.83	6.62	1095.58	414.96	2025-12-10 16:46:12.776828
3889	sensor_cilantro_2	19.24	75.87	61.56	1.90	6.46	934.99	487.77	2025-12-10 16:46:12.777059
3890	sensor_rabano_1	20.03	60.60	63.89	1.55	6.51	942.50	454.07	2025-12-10 16:46:22.787516
3891	sensor_rabano_2	20.35	65.50	65.61	1.70	6.55	1020.16	456.68	2025-12-10 16:46:22.788318
3892	sensor_cilantro_1	20.24	73.16	67.79	1.48	6.61	986.72	434.50	2025-12-10 16:46:22.788506
3893	sensor_cilantro_2	20.08	76.44	76.60	1.79	6.65	835.66	472.01	2025-12-10 16:46:22.788648
3894	sensor_rabano_1	21.31	61.17	71.77	1.42	6.75	1135.70	438.72	2025-12-10 16:46:32.799073
3895	sensor_rabano_2	20.41	69.83	66.59	1.49	6.57	993.39	469.31	2025-12-10 16:46:32.79987
3896	sensor_cilantro_1	21.80	65.14	73.62	1.76	6.62	1148.77	427.31	2025-12-10 16:46:32.800056
3897	sensor_cilantro_2	20.19	69.82	74.97	1.76	6.53	961.12	429.95	2025-12-10 16:46:32.800198
3898	sensor_rabano_1	21.77	61.00	64.47	1.52	6.42	892.34	456.78	2025-12-10 16:46:42.810438
3899	sensor_rabano_2	22.34	72.01	73.35	1.66	6.55	1118.23	478.29	2025-12-10 16:46:42.811221
3900	sensor_cilantro_1	21.11	66.96	75.56	1.53	6.75	821.52	413.69	2025-12-10 16:46:42.811407
3901	sensor_cilantro_2	21.35	71.27	68.23	1.83	6.48	1037.64	490.62	2025-12-10 16:46:42.81155
3902	sensor_rabano_1	20.58	70.14	64.83	1.92	6.79	956.08	428.66	2025-12-10 16:46:52.821891
3903	sensor_rabano_2	22.78	69.84	79.35	1.68	6.53	968.63	436.64	2025-12-10 16:46:52.822696
3904	sensor_cilantro_1	20.13	62.27	65.59	1.50	6.79	1075.41	458.42	2025-12-10 16:46:52.822886
3905	sensor_cilantro_2	19.58	65.58	71.80	1.71	6.57	919.45	445.98	2025-12-10 16:46:52.823081
3906	sensor_rabano_1	21.60	61.41	75.80	1.77	6.60	1104.71	429.34	2025-12-10 16:47:02.833079
3907	sensor_rabano_2	22.88	61.67	73.32	1.83	6.65	901.97	455.43	2025-12-10 16:47:02.833861
3908	sensor_cilantro_1	21.62	73.58	73.13	1.68	6.74	1029.94	447.44	2025-12-10 16:47:02.834085
3909	sensor_cilantro_2	22.51	73.82	62.25	2.00	6.74	867.28	473.27	2025-12-10 16:47:02.834238
3910	sensor_rabano_1	20.93	69.26	70.29	1.66	6.61	947.39	438.99	2025-12-10 16:47:12.843326
3911	sensor_rabano_2	23.27	69.03	61.25	1.67	6.66	1060.65	452.46	2025-12-10 16:47:12.843845
3912	sensor_cilantro_1	20.72	65.45	68.45	1.72	6.41	876.25	423.05	2025-12-10 16:47:12.844085
3913	sensor_cilantro_2	19.12	65.68	63.46	1.54	6.68	838.93	444.49	2025-12-10 16:47:12.84426
3914	sensor_rabano_1	22.80	62.80	79.58	1.87	6.60	1081.06	495.40	2025-12-10 16:47:22.854773
3915	sensor_rabano_2	23.76	58.51	62.41	1.53	6.66	1144.44	453.41	2025-12-10 16:47:22.855617
3916	sensor_cilantro_1	20.85	65.92	64.16	1.53	6.55	1030.25	452.63	2025-12-10 16:47:22.85581
3917	sensor_cilantro_2	21.43	77.69	61.72	1.93	6.79	1023.24	461.27	2025-12-10 16:47:22.855948
3918	sensor_rabano_1	20.93	71.50	75.48	1.94	6.79	900.75	452.26	2025-12-10 16:47:32.864783
3919	sensor_rabano_2	23.14	60.16	61.35	1.60	6.46	1159.73	432.17	2025-12-10 16:47:32.865289
3920	sensor_cilantro_1	19.75	72.29	77.20	1.71	6.63	878.03	456.79	2025-12-10 16:47:32.865375
3921	sensor_cilantro_2	21.91	70.68	79.59	1.73	6.53	992.28	434.44	2025-12-10 16:47:32.865432
3922	sensor_rabano_1	23.25	68.16	61.92	1.83	6.49	890.62	488.94	2025-12-10 16:47:42.87637
3923	sensor_rabano_2	23.82	62.54	64.34	1.88	6.54	1056.90	493.80	2025-12-10 16:47:42.877155
3924	sensor_cilantro_1	21.33	75.61	67.45	1.95	6.65	909.72	446.69	2025-12-10 16:47:42.877341
3925	sensor_cilantro_2	20.90	70.76	66.83	1.83	6.70	959.67	476.53	2025-12-10 16:47:42.877486
3926	sensor_rabano_1	21.29	58.57	71.97	1.83	6.53	866.16	454.78	2025-12-10 16:47:52.888709
3927	sensor_rabano_2	23.06	67.87	75.46	1.51	6.52	966.95	455.73	2025-12-10 16:47:52.889615
3928	sensor_cilantro_1	19.69	76.48	74.92	1.88	6.54	1015.43	456.61	2025-12-10 16:47:52.889872
3929	sensor_cilantro_2	22.85	70.03	65.99	1.48	6.68	1178.47	445.78	2025-12-10 16:47:52.890086
3930	sensor_rabano_1	23.57	63.35	66.39	1.58	6.46	840.93	418.04	2025-12-10 16:48:22.567943
3931	sensor_rabano_2	22.77	69.72	67.59	1.80	6.80	1083.87	469.67	2025-12-10 16:48:22.569211
3932	sensor_cilantro_1	22.33	69.66	77.28	1.51	6.75	927.42	417.71	2025-12-10 16:48:22.569658
3933	sensor_cilantro_2	19.99	69.09	78.54	1.61	6.65	1064.95	400.87	2025-12-10 16:48:22.570135
3934	sensor_rabano_1	21.87	57.98	69.73	1.75	6.63	1102.31	465.12	2025-12-10 16:48:32.584089
3935	sensor_rabano_2	21.56	61.24	67.67	1.84	6.56	904.68	434.21	2025-12-10 16:48:32.585425
3936	sensor_cilantro_1	22.80	66.35	68.47	1.87	6.69	925.64	486.39	2025-12-10 16:48:32.585859
3937	sensor_cilantro_2	22.63	77.45	74.64	1.55	6.64	884.75	439.11	2025-12-10 16:48:32.586201
3938	sensor_rabano_1	22.48	71.45	63.65	1.50	6.73	868.60	485.51	2025-12-10 16:48:42.595011
3939	sensor_rabano_2	21.15	61.80	75.24	1.64	6.61	1153.94	477.35	2025-12-10 16:48:42.595499
3940	sensor_cilantro_1	22.53	69.77	75.54	1.75	6.53	996.58	434.71	2025-12-10 16:48:42.595587
3941	sensor_cilantro_2	21.99	76.31	76.44	1.99	6.78	1068.67	419.91	2025-12-10 16:48:42.59565
3942	sensor_rabano_1	23.11	57.73	78.70	1.69	6.66	802.81	408.51	2025-12-10 16:48:52.60742
3943	sensor_rabano_2	23.79	63.22	75.53	1.85	6.45	932.66	404.27	2025-12-10 16:48:52.608328
3944	sensor_cilantro_1	22.82	63.28	68.67	1.56	6.66	1117.21	473.23	2025-12-10 16:48:52.608595
3945	sensor_cilantro_2	20.13	69.17	77.77	1.68	6.61	1136.15	482.64	2025-12-10 16:48:52.608793
3946	sensor_rabano_1	23.04	65.49	63.23	1.62	6.70	887.02	426.98	2025-12-10 16:49:02.675005
3947	sensor_rabano_2	23.78	57.64	61.72	1.61	6.72	1142.73	423.04	2025-12-10 16:49:02.675814
3948	sensor_cilantro_1	21.31	63.46	70.69	1.65	6.78	1050.92	428.47	2025-12-10 16:49:02.676006
3949	sensor_cilantro_2	20.72	77.58	65.01	1.84	6.55	964.37	415.36	2025-12-10 16:49:02.676152
3950	sensor_rabano_1	21.75	62.20	69.59	1.92	6.61	984.69	412.22	2025-12-10 16:49:12.68604
3951	sensor_rabano_2	22.97	66.31	79.99	1.43	6.61	1001.17	417.16	2025-12-10 16:49:12.68683
3952	sensor_cilantro_1	22.64	66.75	77.64	1.41	6.55	812.07	433.49	2025-12-10 16:49:12.687054
3953	sensor_cilantro_2	22.20	64.91	79.37	1.69	6.48	823.93	429.56	2025-12-10 16:49:12.687212
3954	sensor_rabano_1	23.96	65.71	72.68	1.48	6.64	974.44	432.80	2025-12-10 16:49:22.697736
3955	sensor_rabano_2	20.13	66.66	71.64	1.87	6.43	1097.72	455.66	2025-12-10 16:49:22.698538
3956	sensor_cilantro_1	21.84	63.76	69.35	1.88	6.42	980.49	448.37	2025-12-10 16:49:22.698728
3957	sensor_cilantro_2	22.51	68.90	67.24	1.85	6.62	1075.78	482.06	2025-12-10 16:49:22.698876
3958	sensor_rabano_1	20.57	64.26	73.50	1.46	6.48	1178.42	455.94	2025-12-10 16:49:33.454419
3959	sensor_rabano_2	21.87	66.62	71.74	1.48	6.60	1142.88	496.34	2025-12-10 16:49:33.45528
3960	sensor_cilantro_1	22.65	68.99	60.50	1.63	6.63	1190.75	464.88	2025-12-10 16:49:33.455453
3961	sensor_cilantro_2	19.48	65.17	71.29	1.44	6.69	1192.14	459.35	2025-12-10 16:49:33.45569
3962	sensor_rabano_1	23.88	60.21	63.13	1.77	6.67	1040.03	489.41	2025-12-10 16:49:43.464303
3963	sensor_rabano_2	23.13	65.23	67.27	1.44	6.76	847.08	447.66	2025-12-10 16:49:43.464826
3964	sensor_cilantro_1	21.66	71.63	77.38	1.61	6.68	873.72	412.25	2025-12-10 16:49:43.464914
3965	sensor_cilantro_2	20.47	67.36	65.15	1.93	6.69	831.57	455.68	2025-12-10 16:49:43.464973
3966	sensor_rabano_1	21.76	69.03	68.41	1.99	6.55	855.10	411.86	2025-12-10 16:49:53.47644
3967	sensor_rabano_2	22.50	62.91	62.26	1.70	6.67	985.71	477.53	2025-12-10 16:49:53.477284
3968	sensor_cilantro_1	20.00	68.84	78.30	1.49	6.76	879.40	411.22	2025-12-10 16:49:53.477486
3969	sensor_cilantro_2	21.66	74.28	69.03	1.86	6.59	986.87	472.48	2025-12-10 16:49:53.477646
3970	sensor_rabano_1	22.41	64.69	69.58	1.84	6.76	1199.92	408.52	2025-12-10 16:50:04.498658
3971	sensor_rabano_2	22.55	60.41	74.89	1.42	6.44	919.05	472.24	2025-12-10 16:50:04.499562
3972	sensor_cilantro_1	19.60	72.74	70.44	1.78	6.59	949.35	474.99	2025-12-10 16:50:04.499829
3973	sensor_cilantro_2	19.79	67.07	60.85	1.53	6.73	852.03	487.57	2025-12-10 16:50:04.499986
3974	sensor_rabano_1	22.76	63.13	66.42	1.43	6.53	992.34	464.02	2025-12-10 16:50:14.509915
3975	sensor_rabano_2	20.28	59.51	72.84	1.53	6.58	926.21	481.95	2025-12-10 16:50:14.510689
3976	sensor_cilantro_1	20.33	63.46	78.67	1.95	6.67	1061.10	461.24	2025-12-10 16:50:14.51092
3977	sensor_cilantro_2	20.56	65.50	70.58	1.74	6.80	1162.30	447.09	2025-12-10 16:50:14.511068
3978	sensor_rabano_1	22.19	62.70	77.56	1.84	6.52	808.41	471.27	2025-12-10 16:50:24.52278
3979	sensor_rabano_2	20.12	68.38	72.42	1.75	6.78	1115.89	400.99	2025-12-10 16:50:24.523618
3980	sensor_cilantro_1	21.37	66.26	78.66	1.71	6.72	1154.96	465.24	2025-12-10 16:50:24.523898
3981	sensor_cilantro_2	22.47	66.08	67.76	1.69	6.50	1143.10	482.40	2025-12-10 16:50:24.524064
3982	sensor_rabano_1	22.75	63.45	65.61	1.63	6.41	920.78	475.43	2025-12-10 16:50:34.534216
3983	sensor_rabano_2	23.47	62.77	64.33	1.48	6.42	1118.55	496.60	2025-12-10 16:50:34.534957
3984	sensor_cilantro_1	20.23	76.10	79.12	1.99	6.49	964.63	416.26	2025-12-10 16:50:34.535144
3985	sensor_cilantro_2	19.22	65.64	70.44	1.55	6.72	1159.30	437.89	2025-12-10 16:50:34.53529
3986	sensor_rabano_1	22.46	63.74	61.59	1.49	6.56	851.92	455.51	2025-12-10 16:50:44.547107
3987	sensor_rabano_2	21.78	68.43	65.25	1.57	6.55	972.29	426.56	2025-12-10 16:50:44.548007
3988	sensor_cilantro_1	22.99	76.01	63.29	1.73	6.42	1112.69	475.42	2025-12-10 16:50:44.548196
3989	sensor_cilantro_2	19.76	76.14	71.12	1.79	6.56	966.14	491.14	2025-12-10 16:50:44.548338
3990	sensor_rabano_1	20.49	60.70	76.37	1.49	6.75	925.38	463.39	2025-12-10 16:50:54.56017
3991	sensor_rabano_2	23.22	62.82	74.51	1.58	6.51	1027.92	400.54	2025-12-10 16:50:54.560961
3992	sensor_cilantro_1	19.29	66.53	74.21	1.74	6.63	1037.56	461.86	2025-12-10 16:50:54.56115
3993	sensor_cilantro_2	22.98	68.12	66.99	1.75	6.68	1160.19	418.72	2025-12-10 16:50:54.561295
3994	sensor_rabano_1	20.40	66.74	75.28	1.79	6.72	1194.20	480.42	2025-12-10 16:51:04.571506
3995	sensor_rabano_2	20.96	66.16	71.46	1.80	6.63	1097.00	434.37	2025-12-10 16:51:04.572348
3996	sensor_cilantro_1	21.13	64.74	74.47	1.64	6.75	800.25	409.59	2025-12-10 16:51:04.572548
3997	sensor_cilantro_2	19.51	66.75	78.88	1.47	6.70	964.93	403.72	2025-12-10 16:51:04.572778
3998	sensor_rabano_1	20.05	67.36	67.97	1.41	6.74	922.38	432.40	2025-12-10 16:51:14.583776
3999	sensor_rabano_2	20.34	69.34	77.86	1.81	6.68	915.87	478.30	2025-12-10 16:51:14.58441
4000	sensor_cilantro_1	19.74	65.75	73.36	1.47	6.44	933.30	442.10	2025-12-10 16:51:14.584522
4001	sensor_cilantro_2	19.40	71.23	69.46	1.57	6.43	1177.41	401.24	2025-12-10 16:51:14.584583
4002	sensor_rabano_1	20.94	70.05	60.79	1.83	6.67	810.04	407.19	2025-12-10 16:51:24.595212
4003	sensor_rabano_2	22.31	72.29	60.89	1.88	6.61	932.43	445.69	2025-12-10 16:51:24.595988
4004	sensor_cilantro_1	22.05	67.16	63.67	1.67	6.77	975.70	441.47	2025-12-10 16:51:24.596213
4005	sensor_cilantro_2	21.06	64.22	60.20	1.64	6.75	1007.34	471.52	2025-12-10 16:51:24.596367
4006	sensor_rabano_1	20.05	71.43	67.16	1.95	6.54	923.40	443.28	2025-12-10 16:51:34.606808
4007	sensor_rabano_2	22.46	67.34	67.22	1.63	6.52	1168.15	499.50	2025-12-10 16:51:34.607656
4008	sensor_cilantro_1	22.49	74.40	77.26	1.90	6.73	919.79	439.25	2025-12-10 16:51:34.60802
4009	sensor_cilantro_2	22.93	65.06	66.31	1.71	6.55	1072.38	493.85	2025-12-10 16:51:34.608281
4010	sensor_rabano_1	21.85	70.92	65.17	1.50	6.64	805.10	429.29	2025-12-10 16:51:44.618402
4011	sensor_rabano_2	21.54	59.44	73.60	1.46	6.49	865.76	481.62	2025-12-10 16:51:44.619244
4012	sensor_cilantro_1	20.00	72.33	64.60	1.69	6.58	1155.38	490.21	2025-12-10 16:51:44.619433
4013	sensor_cilantro_2	22.42	77.19	66.10	1.54	6.65	987.59	441.19	2025-12-10 16:51:44.619638
4014	sensor_rabano_1	20.55	60.48	79.09	1.62	6.58	1061.82	464.61	2025-12-10 16:51:54.631151
4015	sensor_rabano_2	20.38	65.55	65.37	1.98	6.52	1175.81	491.35	2025-12-10 16:51:54.632065
4016	sensor_cilantro_1	21.92	71.64	65.23	1.76	6.41	1054.44	414.95	2025-12-10 16:51:54.632337
4017	sensor_cilantro_2	19.93	62.35	75.61	1.45	6.78	951.55	450.85	2025-12-10 16:51:54.632483
4018	sensor_rabano_1	20.90	60.14	60.86	1.79	6.74	1107.12	401.82	2025-12-10 16:52:04.641438
4019	sensor_rabano_2	22.85	60.42	68.81	1.51	6.62	1080.55	407.57	2025-12-10 16:52:04.642103
4020	sensor_cilantro_1	19.42	77.42	75.33	1.44	6.64	867.95	442.28	2025-12-10 16:52:04.642212
4021	sensor_cilantro_2	21.51	71.20	62.24	1.57	6.48	1074.37	404.37	2025-12-10 16:52:04.642273
4022	sensor_rabano_1	22.78	68.56	71.22	1.77	6.42	1143.78	495.45	2025-12-10 16:52:14.650687
4023	sensor_rabano_2	21.54	69.55	66.37	1.93	6.80	928.58	482.71	2025-12-10 16:52:14.651207
4024	sensor_cilantro_1	19.26	63.73	71.56	1.45	6.73	963.89	414.21	2025-12-10 16:52:14.651287
4025	sensor_cilantro_2	22.05	71.21	63.69	1.76	6.52	1118.32	467.90	2025-12-10 16:52:14.651343
4026	sensor_rabano_1	20.92	60.22	74.10	1.70	6.67	889.75	456.38	2025-12-10 16:52:24.662479
4027	sensor_rabano_2	22.10	70.07	75.18	1.81	6.70	974.52	404.54	2025-12-10 16:52:24.663244
4028	sensor_cilantro_1	20.21	62.25	78.17	1.43	6.59	804.02	495.01	2025-12-10 16:52:24.66342
4029	sensor_cilantro_2	19.99	76.55	75.53	1.50	6.52	1066.00	440.58	2025-12-10 16:52:24.663569
4030	sensor_rabano_1	23.95	70.23	74.73	1.98	6.57	999.24	442.59	2025-12-10 16:52:34.673298
4031	sensor_rabano_2	23.67	66.16	60.11	1.65	6.41	1140.90	431.16	2025-12-10 16:52:34.674271
4032	sensor_cilantro_1	21.42	76.59	77.47	1.65	6.57	989.74	499.00	2025-12-10 16:52:34.674468
4033	sensor_cilantro_2	22.65	65.47	61.99	1.55	6.69	1126.60	407.42	2025-12-10 16:52:34.674675
4034	sensor_rabano_1	20.25	67.80	72.66	1.68	6.41	1150.22	435.88	2025-12-10 16:52:44.684797
4035	sensor_rabano_2	23.67	57.37	66.45	1.83	6.62	1093.39	419.43	2025-12-10 16:52:44.685354
4036	sensor_cilantro_1	21.42	72.11	78.01	1.85	6.41	808.63	475.04	2025-12-10 16:52:44.685431
4037	sensor_cilantro_2	21.56	72.99	70.73	1.42	6.58	1148.21	400.49	2025-12-10 16:52:44.685487
4038	sensor_rabano_1	21.59	70.09	77.82	1.82	6.69	1010.90	448.65	2025-12-10 16:52:54.694989
4039	sensor_rabano_2	23.13	60.61	65.18	1.82	6.71	1152.94	435.52	2025-12-10 16:52:54.695507
4040	sensor_cilantro_1	19.32	67.40	62.81	1.80	6.60	931.12	480.95	2025-12-10 16:52:54.695594
4041	sensor_cilantro_2	19.68	71.09	61.40	1.87	6.65	1120.06	400.77	2025-12-10 16:52:54.695652
4042	sensor_rabano_1	22.01	66.56	61.82	1.43	6.51	1034.56	432.83	2025-12-10 16:53:04.70344
4043	sensor_rabano_2	22.29	59.45	65.57	1.56	6.71	944.85	460.39	2025-12-10 16:53:04.704057
4044	sensor_cilantro_1	22.54	68.74	61.66	1.83	6.47	881.28	404.19	2025-12-10 16:53:04.704161
4045	sensor_cilantro_2	22.57	65.97	69.53	1.70	6.53	969.19	404.40	2025-12-10 16:53:04.704221
4046	sensor_rabano_1	22.06	68.04	73.94	1.45	6.68	1171.00	421.74	2025-12-10 16:53:14.71457
4047	sensor_rabano_2	23.76	62.56	70.51	1.55	6.71	945.71	430.18	2025-12-10 16:53:14.715369
4048	sensor_cilantro_1	21.85	65.33	61.50	1.90	6.57	1133.11	441.89	2025-12-10 16:53:14.715555
4049	sensor_cilantro_2	20.11	70.01	66.40	1.60	6.47	1132.03	467.78	2025-12-10 16:53:14.71577
4050	sensor_rabano_1	20.51	61.34	67.21	1.87	6.57	849.78	456.16	2025-12-10 16:53:24.727498
4051	sensor_rabano_2	21.65	63.69	79.06	1.87	6.42	966.39	422.89	2025-12-10 16:53:24.728043
4052	sensor_cilantro_1	22.44	73.26	68.77	1.95	6.58	861.92	447.04	2025-12-10 16:53:24.728161
4053	sensor_cilantro_2	20.71	65.17	68.36	1.82	6.75	917.05	449.50	2025-12-10 16:53:24.728241
4054	sensor_rabano_1	21.49	62.27	75.74	1.94	6.49	1033.24	456.30	2025-12-10 16:53:34.738747
4055	sensor_rabano_2	22.91	62.67	63.57	1.41	6.54	1069.60	450.32	2025-12-10 16:53:34.739571
4056	sensor_cilantro_1	21.96	63.73	71.96	1.80	6.74	1097.08	497.05	2025-12-10 16:53:34.739752
4057	sensor_cilantro_2	21.40	68.80	61.55	1.89	6.68	825.69	402.91	2025-12-10 16:53:34.739892
4058	sensor_rabano_1	23.22	68.48	77.90	1.66	6.71	893.70	472.36	2025-12-10 16:53:44.749331
4059	sensor_rabano_2	22.80	70.19	75.54	1.55	6.77	999.73	430.20	2025-12-10 16:53:44.750161
4060	sensor_cilantro_1	21.55	75.52	75.42	1.99	6.51	836.05	421.71	2025-12-10 16:53:44.75047
4061	sensor_cilantro_2	21.38	77.39	66.27	1.67	6.49	1056.48	431.76	2025-12-10 16:53:44.750804
4062	sensor_rabano_1	22.85	69.72	60.77	1.76	6.44	835.42	407.57	2025-12-10 16:53:54.763248
4063	sensor_rabano_2	22.89	57.60	64.06	1.59	6.56	1086.02	406.34	2025-12-10 16:53:54.763812
4064	sensor_cilantro_1	21.20	77.63	62.14	1.60	6.64	816.30	421.53	2025-12-10 16:53:54.763927
4065	sensor_cilantro_2	22.83	64.62	64.81	1.89	6.46	1048.45	451.79	2025-12-10 16:53:54.763988
4066	sensor_rabano_1	22.47	71.01	61.16	1.49	6.71	883.08	470.72	2025-12-10 16:54:04.839341
4067	sensor_rabano_2	23.51	66.64	73.01	1.72	6.64	1089.70	429.11	2025-12-10 16:54:04.840151
4068	sensor_cilantro_1	22.89	67.72	71.13	1.44	6.54	872.24	456.39	2025-12-10 16:54:04.840327
4069	sensor_cilantro_2	19.21	71.84	61.92	1.61	6.47	952.71	467.25	2025-12-10 16:54:04.840464
4070	sensor_rabano_1	23.94	62.90	71.68	1.66	6.72	893.76	445.29	2025-12-10 16:54:14.849409
4071	sensor_rabano_2	21.56	69.27	67.95	1.70	6.77	944.10	464.30	2025-12-10 16:54:14.849915
4072	sensor_cilantro_1	22.79	63.20	61.56	1.57	6.56	1023.83	494.73	2025-12-10 16:54:14.849998
4073	sensor_cilantro_2	22.22	69.10	64.25	1.71	6.77	938.38	477.73	2025-12-10 16:54:14.850055
4074	sensor_rabano_1	22.82	58.99	76.52	1.89	6.78	979.99	459.34	2025-12-10 16:54:24.860095
4075	sensor_rabano_2	21.03	70.31	77.48	1.63	6.47	824.58	418.76	2025-12-10 16:54:24.861108
4076	sensor_cilantro_1	21.92	74.10	79.92	1.81	6.55	1081.27	412.50	2025-12-10 16:54:24.861454
4077	sensor_cilantro_2	20.31	72.84	70.13	1.52	6.43	966.47	467.03	2025-12-10 16:54:24.861683
4078	sensor_rabano_1	22.19	72.95	61.88	1.59	6.69	981.72	422.93	2025-12-10 16:54:34.87391
4079	sensor_rabano_2	21.79	66.62	66.05	1.66	6.49	1156.23	491.67	2025-12-10 16:54:34.874716
4080	sensor_cilantro_1	22.57	70.59	61.84	1.60	6.61	1050.71	499.17	2025-12-10 16:54:34.874895
4081	sensor_cilantro_2	21.76	72.04	60.58	1.78	6.51	846.15	448.79	2025-12-10 16:54:34.875036
4082	sensor_rabano_1	21.90	65.10	76.67	1.98	6.54	1075.83	425.54	2025-12-10 16:54:44.885141
4083	sensor_rabano_2	21.08	60.16	64.52	1.71	6.66	1168.06	487.93	2025-12-10 16:54:44.885929
4084	sensor_cilantro_1	20.07	66.78	68.85	1.61	6.57	1116.31	430.72	2025-12-10 16:54:44.88612
4085	sensor_cilantro_2	21.11	73.92	65.92	1.66	6.72	1008.07	471.58	2025-12-10 16:54:44.886263
4086	sensor_rabano_1	21.17	61.03	64.78	1.76	6.72	815.78	441.44	2025-12-10 16:54:54.89739
4087	sensor_rabano_2	22.73	60.48	76.68	1.47	6.41	1137.28	439.51	2025-12-10 16:54:54.898135
4088	sensor_cilantro_1	22.17	69.60	62.77	1.86	6.51	1059.56	467.25	2025-12-10 16:54:54.898304
4089	sensor_cilantro_2	20.79	74.65	79.14	1.96	6.43	1062.30	483.56	2025-12-10 16:54:54.898437
4090	sensor_rabano_1	23.88	60.26	79.51	1.82	6.67	818.30	448.71	2025-12-10 16:55:04.909131
4091	sensor_rabano_2	23.04	63.15	60.48	1.98	6.56	839.54	456.04	2025-12-10 16:55:04.910135
4092	sensor_cilantro_1	21.34	75.55	79.24	1.97	6.62	1030.49	454.16	2025-12-10 16:55:04.91053
4093	sensor_cilantro_2	20.35	67.43	60.01	1.96	6.48	972.63	416.14	2025-12-10 16:55:04.910792
4094	sensor_rabano_1	21.58	63.90	72.87	1.53	6.49	1097.35	411.69	2025-12-10 16:55:14.920935
4095	sensor_rabano_2	21.21	61.29	74.35	1.96	6.72	961.63	475.09	2025-12-10 16:55:14.921646
4096	sensor_cilantro_1	22.84	76.61	70.48	1.70	6.47	921.61	408.16	2025-12-10 16:55:14.92187
4097	sensor_cilantro_2	20.21	63.10	61.95	1.41	6.68	910.01	456.87	2025-12-10 16:55:14.922015
4098	sensor_rabano_1	23.87	71.58	65.30	1.81	6.57	905.37	403.74	2025-12-10 16:55:24.933506
4099	sensor_rabano_2	20.03	66.75	68.55	1.99	6.44	1021.34	487.60	2025-12-10 16:55:24.934393
4100	sensor_cilantro_1	20.32	69.44	78.30	1.88	6.50	1067.68	468.77	2025-12-10 16:55:24.93464
4101	sensor_cilantro_2	19.95	66.72	66.44	1.58	6.58	881.00	413.84	2025-12-10 16:55:24.934844
4102	sensor_rabano_1	21.72	59.55	77.68	1.76	6.47	958.64	489.68	2025-12-10 16:55:34.94397
4103	sensor_rabano_2	21.63	66.97	77.84	1.80	6.49	1075.19	448.23	2025-12-10 16:55:34.944458
4104	sensor_cilantro_1	21.42	65.48	72.50	1.94	6.52	939.49	497.75	2025-12-10 16:55:34.944613
4105	sensor_cilantro_2	21.77	73.65	63.66	1.90	6.60	800.18	451.13	2025-12-10 16:55:34.944696
4106	sensor_rabano_1	20.83	57.81	78.54	1.71	6.43	929.75	412.71	2025-12-10 16:55:44.952683
4107	sensor_rabano_2	22.75	65.45	63.80	1.72	6.59	954.18	490.14	2025-12-10 16:55:44.9537
4108	sensor_cilantro_1	19.21	64.24	70.03	1.90	6.43	1188.13	400.74	2025-12-10 16:55:44.95403
4109	sensor_cilantro_2	19.12	67.70	75.87	1.52	6.51	1138.00	492.68	2025-12-10 16:55:44.954119
4110	sensor_rabano_1	23.28	65.01	72.61	1.72	6.63	1070.11	413.85	2025-12-10 16:55:54.961569
4111	sensor_rabano_2	21.38	66.21	71.47	1.66	6.55	837.91	454.78	2025-12-10 16:55:54.962143
4112	sensor_cilantro_1	22.68	63.14	74.91	1.98	6.62	896.32	467.04	2025-12-10 16:55:54.962236
4113	sensor_cilantro_2	22.07	63.91	74.47	1.42	6.59	1126.99	474.00	2025-12-10 16:55:54.962293
4114	sensor_rabano_1	22.46	64.52	76.71	1.82	6.47	996.92	408.40	2025-12-10 16:56:04.972404
4115	sensor_rabano_2	23.49	68.16	72.61	1.94	6.69	1088.16	444.07	2025-12-10 16:56:04.973263
4116	sensor_cilantro_1	19.24	64.75	78.78	1.81	6.76	1057.64	404.38	2025-12-10 16:56:04.973456
4117	sensor_cilantro_2	20.40	64.68	60.52	1.61	6.73	959.10	470.49	2025-12-10 16:56:04.973734
4118	sensor_rabano_1	20.09	58.28	64.49	1.58	6.61	814.08	438.68	2025-12-10 16:56:14.981324
4119	sensor_rabano_2	22.64	61.53	68.05	1.69	6.75	803.95	473.45	2025-12-10 16:56:14.981786
4120	sensor_cilantro_1	22.82	73.27	72.31	1.79	6.59	975.17	476.02	2025-12-10 16:56:14.981888
4121	sensor_cilantro_2	21.05	70.22	71.33	1.61	6.69	852.45	458.54	2025-12-10 16:56:14.981945
4122	sensor_rabano_1	20.68	69.77	68.79	1.63	6.80	933.98	466.71	2025-12-10 16:56:24.992971
4123	sensor_rabano_2	21.81	68.01	65.78	1.76	6.49	1107.98	482.26	2025-12-10 16:56:24.993767
4124	sensor_cilantro_1	20.85	68.49	68.44	1.89	6.52	838.36	445.47	2025-12-10 16:56:24.993967
4125	sensor_cilantro_2	19.72	71.88	78.19	1.47	6.71	838.74	417.10	2025-12-10 16:56:24.994113
4126	sensor_rabano_1	22.09	70.26	72.30	1.52	6.53	875.44	456.49	2025-12-10 16:56:35.004399
4127	sensor_rabano_2	21.41	72.02	62.45	1.96	6.71	1015.46	414.64	2025-12-10 16:56:35.005376
4128	sensor_cilantro_1	21.14	67.17	66.20	1.50	6.68	1046.97	458.84	2025-12-10 16:56:35.00564
4129	sensor_cilantro_2	19.57	75.06	72.62	1.58	6.42	1150.45	430.82	2025-12-10 16:56:35.005823
4130	sensor_rabano_1	22.66	68.80	62.24	1.48	6.42	1164.29	414.44	2025-12-10 16:56:45.01667
4131	sensor_rabano_2	23.82	71.90	68.70	1.94	6.53	989.94	418.40	2025-12-10 16:56:45.017415
4132	sensor_cilantro_1	21.12	66.00	77.49	1.70	6.62	1005.87	441.53	2025-12-10 16:56:45.017649
4133	sensor_cilantro_2	19.86	62.10	75.85	1.60	6.46	860.68	490.41	2025-12-10 16:56:45.017966
4134	sensor_rabano_1	23.78	66.25	79.79	1.56	6.76	1120.99	498.25	2025-12-10 16:56:55.027887
4135	sensor_rabano_2	23.74	69.40	70.76	1.64	6.53	997.13	484.28	2025-12-10 16:56:55.028689
4136	sensor_cilantro_1	21.75	66.64	75.21	1.78	6.62	907.99	496.50	2025-12-10 16:56:55.028872
4137	sensor_cilantro_2	21.50	67.68	60.33	1.51	6.72	988.87	492.14	2025-12-10 16:56:55.029012
4138	sensor_rabano_1	21.02	64.57	65.41	1.95	6.42	975.44	446.19	2025-12-10 16:57:05.039314
4139	sensor_rabano_2	22.91	66.29	79.39	1.97	6.62	1014.22	410.95	2025-12-10 16:57:05.040242
4140	sensor_cilantro_1	21.27	69.48	78.96	1.83	6.45	1012.77	476.76	2025-12-10 16:57:05.040472
4141	sensor_cilantro_2	20.05	66.63	68.74	1.83	6.41	1022.79	468.85	2025-12-10 16:57:05.040863
4142	sensor_rabano_1	22.37	70.43	68.09	1.73	6.58	846.30	413.99	2025-12-10 16:57:15.050553
4143	sensor_rabano_2	23.41	63.84	77.74	1.92	6.64	1165.59	408.90	2025-12-10 16:57:15.051262
4144	sensor_cilantro_1	20.13	68.34	64.82	1.94	6.70	944.17	433.80	2025-12-10 16:57:15.051389
4145	sensor_cilantro_2	19.09	63.97	65.90	1.72	6.63	926.29	471.34	2025-12-10 16:57:15.051472
4146	sensor_rabano_1	23.76	58.32	61.68	1.60	6.51	929.18	449.57	2025-12-10 16:57:25.061454
4147	sensor_rabano_2	22.73	68.15	60.09	1.64	6.48	1186.98	416.10	2025-12-10 16:57:25.062242
4148	sensor_cilantro_1	19.29	65.46	73.65	1.45	6.65	1175.72	492.31	2025-12-10 16:57:25.062427
4149	sensor_cilantro_2	22.31	65.09	79.17	1.95	6.73	825.22	488.74	2025-12-10 16:57:25.06258
4150	sensor_rabano_1	22.00	71.46	60.44	1.58	6.79	937.27	470.14	2025-12-10 16:57:35.07106
4151	sensor_rabano_2	20.09	62.09	69.33	1.51	6.56	942.86	460.86	2025-12-10 16:57:35.071794
4152	sensor_cilantro_1	22.63	72.52	68.74	1.83	6.78	877.55	442.93	2025-12-10 16:57:35.071944
4153	sensor_cilantro_2	20.64	72.64	64.84	1.80	6.72	1025.71	446.59	2025-12-10 16:57:35.072009
4154	sensor_rabano_1	20.42	57.13	73.33	1.75	6.54	853.49	401.63	2025-12-10 16:57:45.08181
4155	sensor_rabano_2	23.34	66.16	64.50	1.48	6.76	1058.15	427.99	2025-12-10 16:57:45.082621
4156	sensor_cilantro_1	22.05	67.28	64.86	1.66	6.58	937.46	449.70	2025-12-10 16:57:45.082845
4157	sensor_cilantro_2	19.92	68.75	60.04	1.96	6.60	1169.47	433.97	2025-12-10 16:57:45.083
4158	sensor_rabano_1	22.50	57.09	68.45	1.62	6.44	950.32	465.81	2025-12-10 16:57:55.093421
4159	sensor_rabano_2	22.59	71.46	67.41	1.67	6.55	833.29	483.60	2025-12-10 16:57:55.094221
4160	sensor_cilantro_1	21.68	73.67	74.65	1.80	6.75	975.83	409.67	2025-12-10 16:57:55.09445
4161	sensor_cilantro_2	22.69	62.87	60.75	1.71	6.79	1009.39	434.20	2025-12-10 16:57:55.094674
4162	sensor_rabano_1	21.25	66.44	60.61	1.99	6.66	1196.06	478.12	2025-12-10 16:58:05.104749
4163	sensor_rabano_2	22.17	65.33	68.61	1.94	6.68	1006.04	411.68	2025-12-10 16:58:05.105519
4164	sensor_cilantro_1	21.81	76.25	73.21	1.76	6.68	929.35	481.62	2025-12-10 16:58:05.105707
4165	sensor_cilantro_2	20.75	66.70	63.94	1.72	6.41	818.01	484.89	2025-12-10 16:58:05.105846
4166	sensor_rabano_1	21.61	64.22	77.89	1.63	6.53	1026.23	458.22	2025-12-10 16:58:15.116298
4167	sensor_rabano_2	23.47	58.89	74.95	1.80	6.70	958.25	418.96	2025-12-10 16:58:15.117102
4168	sensor_cilantro_1	19.83	65.77	66.21	1.44	6.43	1051.78	482.16	2025-12-10 16:58:15.117291
4169	sensor_cilantro_2	19.03	69.11	70.55	1.58	6.48	1065.37	435.79	2025-12-10 16:58:15.117435
4170	sensor_rabano_1	21.62	71.14	75.48	1.78	6.50	1183.95	401.60	2025-12-10 16:58:25.129152
4171	sensor_rabano_2	22.12	70.60	68.02	1.82	6.78	859.99	497.67	2025-12-10 16:58:25.129908
4172	sensor_cilantro_1	19.57	74.94	60.35	1.93	6.44	860.46	486.13	2025-12-10 16:58:25.130087
4173	sensor_cilantro_2	21.43	62.98	71.42	1.47	6.73	1190.19	426.88	2025-12-10 16:58:25.130229
4174	sensor_rabano_1	20.12	69.04	62.20	1.45	6.53	863.54	439.28	2025-12-10 16:58:35.140659
4175	sensor_rabano_2	20.35	59.25	69.83	1.92	6.79	988.04	420.16	2025-12-10 16:58:35.14173
4176	sensor_cilantro_1	22.30	71.33	66.58	1.88	6.53	1072.12	478.44	2025-12-10 16:58:35.142005
4177	sensor_cilantro_2	22.12	65.95	74.09	1.45	6.79	892.10	477.56	2025-12-10 16:58:35.142217
4178	sensor_rabano_1	22.17	71.01	67.64	1.67	6.72	861.54	496.10	2025-12-10 16:58:45.152559
4179	sensor_rabano_2	23.00	61.93	67.32	1.45	6.46	804.08	454.43	2025-12-10 16:58:45.153309
4180	sensor_cilantro_1	21.97	77.29	73.34	1.80	6.72	1126.14	444.34	2025-12-10 16:58:45.153481
4181	sensor_cilantro_2	19.40	63.72	79.71	1.64	6.78	1172.08	420.65	2025-12-10 16:58:45.153628
4182	sensor_rabano_1	20.17	66.46	68.47	1.73	6.41	874.04	435.70	2025-12-10 16:58:55.160986
4183	sensor_rabano_2	23.05	58.80	77.56	1.63	6.79	985.49	469.85	2025-12-10 16:58:55.161452
4184	sensor_cilantro_1	20.63	64.43	67.85	1.59	6.69	996.66	480.08	2025-12-10 16:58:55.16154
4185	sensor_cilantro_2	22.06	74.36	67.15	1.88	6.60	1177.43	470.46	2025-12-10 16:58:55.161598
4186	sensor_rabano_1	21.72	70.00	64.66	1.55	6.48	1129.41	426.74	2025-12-10 16:59:05.222863
4187	sensor_rabano_2	23.73	68.31	68.76	1.73	6.72	1012.31	418.25	2025-12-10 16:59:05.223438
4188	sensor_cilantro_1	22.59	77.88	72.01	1.69	6.68	898.15	485.76	2025-12-10 16:59:05.22362
4189	sensor_cilantro_2	22.06	70.81	68.90	1.80	6.41	865.03	482.55	2025-12-10 16:59:05.223704
4190	sensor_rabano_1	20.28	67.17	69.16	1.84	6.62	1064.61	428.24	2025-12-10 16:59:15.231204
4191	sensor_rabano_2	21.53	65.61	71.49	1.48	6.72	865.07	483.54	2025-12-10 16:59:15.23179
4192	sensor_cilantro_1	20.26	69.80	74.62	1.63	6.51	821.31	455.91	2025-12-10 16:59:15.231958
4193	sensor_cilantro_2	22.61	74.59	68.48	1.58	6.61	1149.79	493.05	2025-12-10 16:59:15.232041
4194	sensor_rabano_1	22.39	65.00	67.22	1.68	6.44	858.71	478.89	2025-12-10 16:59:25.243335
4195	sensor_rabano_2	22.43	67.94	76.72	1.44	6.59	1108.54	444.13	2025-12-10 16:59:25.244172
4196	sensor_cilantro_1	20.40	74.53	76.21	1.43	6.78	1056.89	424.33	2025-12-10 16:59:25.244378
4197	sensor_cilantro_2	19.78	77.14	74.79	1.75	6.58	965.38	478.49	2025-12-10 16:59:25.244532
4198	sensor_rabano_1	20.84	61.01	76.25	1.72	6.54	1078.90	472.48	2025-12-10 16:59:35.254345
4199	sensor_rabano_2	20.76	70.05	65.96	1.43	6.62	810.90	419.15	2025-12-10 16:59:35.255125
4200	sensor_cilantro_1	19.07	67.52	72.48	1.96	6.50	1144.08	454.56	2025-12-10 16:59:35.255309
4201	sensor_cilantro_2	20.16	69.31	66.63	1.68	6.55	1199.22	471.72	2025-12-10 16:59:35.255451
4202	sensor_rabano_1	21.28	59.34	67.32	1.44	6.66	1187.40	442.09	2025-12-10 16:59:45.263219
4203	sensor_rabano_2	21.87	68.32	69.53	1.98	6.60	1199.96	471.08	2025-12-10 16:59:45.263674
4204	sensor_cilantro_1	20.29	72.24	64.30	1.99	6.74	1184.16	477.33	2025-12-10 16:59:45.263759
4205	sensor_cilantro_2	22.31	70.32	66.35	1.95	6.63	1126.69	418.77	2025-12-10 16:59:45.263815
4206	sensor_rabano_1	21.52	60.62	79.63	1.51	6.61	887.70	416.11	2025-12-10 16:59:55.274551
4207	sensor_rabano_2	22.37	64.42	72.66	1.60	6.48	903.44	444.80	2025-12-10 16:59:55.27536
4208	sensor_cilantro_1	19.66	62.62	64.81	1.61	6.45	960.51	478.43	2025-12-10 16:59:55.27562
4209	sensor_cilantro_2	19.56	67.35	68.69	1.75	6.67	1138.16	484.56	2025-12-10 16:59:55.275883
4210	sensor_rabano_1	22.14	63.26	70.63	1.61	6.71	1141.45	485.50	2025-12-10 17:00:05.287696
4211	sensor_rabano_2	23.68	72.87	64.75	1.80	6.40	859.99	480.48	2025-12-10 17:00:05.288585
4212	sensor_cilantro_1	22.30	63.24	69.60	1.92	6.70	1087.30	411.39	2025-12-10 17:00:05.288819
4213	sensor_cilantro_2	21.11	73.92	73.01	1.75	6.51	1013.05	416.85	2025-12-10 17:00:05.28897
4214	sensor_rabano_1	23.02	59.85	79.80	1.67	6.51	1049.25	405.93	2025-12-10 17:00:15.297806
4215	sensor_rabano_2	23.30	58.20	64.45	1.87	6.53	1010.59	475.63	2025-12-10 17:00:15.298664
4216	sensor_cilantro_1	20.79	67.04	71.78	1.92	6.51	1182.91	460.79	2025-12-10 17:00:15.298894
4217	sensor_cilantro_2	20.45	74.38	75.21	1.49	6.51	1133.38	423.23	2025-12-10 17:00:15.299103
4218	sensor_rabano_1	21.98	57.49	67.74	1.46	6.70	1061.44	412.46	2025-12-10 17:00:25.309656
4219	sensor_rabano_2	23.85	62.98	60.91	1.90	6.52	1167.18	422.36	2025-12-10 17:00:25.310529
4220	sensor_cilantro_1	20.38	71.53	67.36	1.72	6.46	940.95	462.42	2025-12-10 17:00:25.310778
4221	sensor_cilantro_2	22.58	68.86	75.86	1.73	6.46	987.96	461.69	2025-12-10 17:00:25.310987
4222	sensor_rabano_1	20.38	62.61	73.32	1.67	6.71	817.69	443.03	2025-12-10 17:00:35.322975
4223	sensor_rabano_2	21.15	67.82	71.81	1.47	6.66	896.43	406.48	2025-12-10 17:00:35.323761
4224	sensor_cilantro_1	21.50	64.47	74.29	1.41	6.78	1070.95	486.15	2025-12-10 17:00:35.323988
4225	sensor_cilantro_2	22.61	69.86	62.55	1.80	6.55	970.42	466.80	2025-12-10 17:00:35.324144
4226	sensor_rabano_1	20.34	69.62	66.12	1.71	6.64	830.27	486.35	2025-12-10 17:00:45.334632
4227	sensor_rabano_2	23.71	72.05	62.66	1.43	6.76	873.64	467.46	2025-12-10 17:00:45.33555
4228	sensor_cilantro_1	21.40	62.46	66.95	1.45	6.75	810.42	450.60	2025-12-10 17:00:45.335755
4229	sensor_cilantro_2	22.14	65.48	75.61	1.45	6.42	857.96	426.44	2025-12-10 17:00:45.335903
4230	sensor_rabano_1	20.25	61.56	67.63	1.42	6.47	1185.80	456.76	2025-12-10 17:00:55.348567
4231	sensor_rabano_2	20.22	71.72	66.50	1.78	6.77	835.48	448.78	2025-12-10 17:00:55.349651
4232	sensor_cilantro_1	20.30	69.28	73.14	1.99	6.60	1195.64	468.67	2025-12-10 17:00:55.349848
4233	sensor_cilantro_2	21.75	62.09	62.61	1.49	6.68	865.80	439.86	2025-12-10 17:00:55.349995
4234	sensor_rabano_1	21.04	71.91	79.75	1.82	6.44	1083.86	425.50	2025-12-10 17:01:05.357657
4235	sensor_rabano_2	21.62	69.26	78.62	1.78	6.59	969.16	459.53	2025-12-10 17:01:05.358151
4236	sensor_cilantro_1	20.04	67.66	67.04	1.83	6.64	1029.92	405.07	2025-12-10 17:01:05.358237
4237	sensor_cilantro_2	22.01	74.82	72.13	1.57	6.48	1092.97	476.95	2025-12-10 17:01:05.358294
4238	sensor_rabano_1	23.22	71.11	78.79	1.40	6.47	1009.68	453.77	2025-12-10 17:01:15.366172
4239	sensor_rabano_2	21.83	59.56	69.58	1.73	6.68	993.70	419.68	2025-12-10 17:01:15.366672
4240	sensor_cilantro_1	19.80	74.35	73.47	1.46	6.69	1030.80	477.11	2025-12-10 17:01:15.366761
4241	sensor_cilantro_2	21.06	64.68	71.52	1.51	6.78	953.35	435.91	2025-12-10 17:01:15.366817
4242	sensor_rabano_1	23.20	68.72	73.28	1.55	6.70	964.33	488.40	2025-12-10 17:01:25.375814
4243	sensor_rabano_2	22.57	58.01	68.40	1.66	6.68	808.54	441.70	2025-12-10 17:01:25.376486
4244	sensor_cilantro_1	20.21	70.31	66.08	1.56	6.49	874.71	409.97	2025-12-10 17:01:25.376584
4245	sensor_cilantro_2	19.22	74.07	74.93	1.56	6.47	1132.09	418.06	2025-12-10 17:01:25.376641
4246	sensor_rabano_1	22.54	64.10	77.69	1.57	6.58	1095.18	449.06	2025-12-10 17:01:35.385702
4247	sensor_rabano_2	20.24	66.16	66.83	1.47	6.68	823.87	436.53	2025-12-10 17:01:35.386295
4248	sensor_cilantro_1	21.18	73.76	66.20	1.66	6.54	960.06	472.27	2025-12-10 17:01:35.386375
4249	sensor_cilantro_2	20.24	77.39	68.94	1.43	6.53	1130.26	436.12	2025-12-10 17:01:35.386432
4250	sensor_rabano_1	20.23	67.64	72.73	1.77	6.54	1034.13	462.88	2025-12-10 17:01:45.396875
4251	sensor_rabano_2	22.07	67.11	60.20	1.85	6.46	846.54	454.53	2025-12-10 17:01:45.397683
4252	sensor_cilantro_1	21.10	73.96	69.83	1.47	6.47	806.41	407.27	2025-12-10 17:01:45.397864
4253	sensor_cilantro_2	20.78	62.07	63.22	1.98	6.50	963.14	446.89	2025-12-10 17:01:45.398001
4254	sensor_rabano_1	22.17	65.23	77.19	1.49	6.61	1065.08	455.84	2025-12-10 17:01:55.407443
4255	sensor_rabano_2	22.94	72.91	66.64	1.96	6.54	1090.87	401.36	2025-12-10 17:01:55.408169
4256	sensor_cilantro_1	22.93	64.30	66.62	1.69	6.66	1115.96	472.06	2025-12-10 17:01:55.408275
4257	sensor_cilantro_2	19.31	70.81	74.28	1.67	6.52	1031.94	433.56	2025-12-10 17:01:55.408333
4258	sensor_rabano_1	20.36	59.63	67.57	1.65	6.40	1162.05	462.68	2025-12-10 17:02:05.415822
4259	sensor_rabano_2	23.54	63.29	64.65	1.53	6.50	1065.01	429.46	2025-12-10 17:02:05.416442
4260	sensor_cilantro_1	20.16	66.37	71.51	1.44	6.71	1050.20	474.66	2025-12-10 17:02:05.416553
4261	sensor_cilantro_2	19.04	62.70	63.91	1.52	6.44	1074.17	460.18	2025-12-10 17:02:05.416693
4262	sensor_rabano_1	22.55	61.15	73.36	1.43	6.63	1162.69	489.24	2025-12-10 17:02:15.426395
4263	sensor_rabano_2	23.53	57.22	75.66	1.90	6.61	1163.16	451.38	2025-12-10 17:02:15.427305
4264	sensor_cilantro_1	19.48	65.03	68.32	1.73	6.74	1022.03	483.14	2025-12-10 17:02:15.4275
4265	sensor_cilantro_2	20.49	76.56	63.15	1.89	6.72	953.12	496.35	2025-12-10 17:02:15.427663
4266	sensor_rabano_1	21.45	68.41	71.93	1.45	6.78	872.77	418.00	2025-12-10 17:02:25.437314
4267	sensor_rabano_2	23.63	67.75	66.63	1.89	6.41	836.01	466.48	2025-12-10 17:02:25.438183
4268	sensor_cilantro_1	20.34	73.02	75.77	1.85	6.79	982.87	404.99	2025-12-10 17:02:25.438411
4269	sensor_cilantro_2	20.17	67.01	74.74	1.89	6.43	1052.50	490.91	2025-12-10 17:02:25.438574
4270	sensor_rabano_1	20.82	70.71	76.01	1.74	6.42	986.45	419.76	2025-12-10 17:02:35.448382
4271	sensor_rabano_2	20.59	59.45	70.83	1.59	6.69	889.14	492.47	2025-12-10 17:02:35.449281
4272	sensor_cilantro_1	21.26	77.71	65.68	1.68	6.72	1198.23	471.81	2025-12-10 17:02:35.449472
4273	sensor_cilantro_2	19.48	62.69	71.90	1.52	6.40	876.50	459.44	2025-12-10 17:02:35.449721
4274	sensor_rabano_1	21.76	68.84	62.77	1.50	6.75	1004.71	487.79	2025-12-10 17:02:45.459258
4275	sensor_rabano_2	21.82	61.74	73.62	1.60	6.66	1001.10	493.79	2025-12-10 17:02:45.459756
4276	sensor_cilantro_1	21.16	73.40	78.42	1.55	6.70	945.58	451.23	2025-12-10 17:02:45.459843
4277	sensor_cilantro_2	19.96	63.59	62.53	1.67	6.54	865.33	482.94	2025-12-10 17:02:45.459901
4278	sensor_rabano_1	21.25	61.52	77.08	1.49	6.45	923.56	492.18	2025-12-10 17:02:55.47027
4279	sensor_rabano_2	23.40	66.88	79.32	1.66	6.51	1058.39	412.59	2025-12-10 17:02:55.471113
4280	sensor_cilantro_1	22.38	64.82	70.51	1.62	6.61	945.19	477.03	2025-12-10 17:02:55.471309
4281	sensor_cilantro_2	22.09	67.71	74.81	1.88	6.78	951.95	427.29	2025-12-10 17:02:55.471459
4282	sensor_rabano_1	21.87	72.44	63.94	1.93	6.40	894.47	470.85	2025-12-10 17:03:05.479191
4283	sensor_rabano_2	20.29	72.73	65.68	1.97	6.60	1124.61	448.06	2025-12-10 17:03:05.479781
4284	sensor_cilantro_1	20.27	70.08	64.73	1.60	6.56	1088.73	487.59	2025-12-10 17:03:05.479888
4285	sensor_cilantro_2	21.16	63.23	73.02	1.99	6.53	890.80	478.10	2025-12-10 17:03:05.479947
4286	sensor_rabano_1	22.12	69.22	72.32	1.72	6.57	943.56	401.37	2025-12-10 17:03:15.489877
4287	sensor_rabano_2	20.86	70.84	66.36	1.60	6.65	1060.09	443.77	2025-12-10 17:03:15.490726
4288	sensor_cilantro_1	20.32	62.89	61.21	1.52	6.58	873.51	410.47	2025-12-10 17:03:15.490951
4289	sensor_cilantro_2	20.09	62.68	61.23	1.75	6.55	883.46	494.69	2025-12-10 17:03:15.491107
4290	sensor_rabano_1	21.78	70.85	74.65	1.72	6.53	1138.85	436.69	2025-12-10 17:03:25.49862
4291	sensor_rabano_2	23.87	67.76	77.18	1.66	6.67	872.41	493.37	2025-12-10 17:03:25.499096
4292	sensor_cilantro_1	22.02	77.30	66.02	1.84	6.56	1155.72	423.47	2025-12-10 17:03:25.499175
4293	sensor_cilantro_2	22.21	62.11	75.55	1.59	6.43	981.97	471.64	2025-12-10 17:03:25.499232
4294	sensor_rabano_1	20.16	65.16	64.11	1.62	6.49	1167.91	463.36	2025-12-10 17:03:35.507098
4295	sensor_rabano_2	21.00	60.99	72.02	1.46	6.67	1179.05	474.16	2025-12-10 17:03:35.507578
4296	sensor_cilantro_1	21.63	72.58	62.44	1.58	6.63	973.56	401.75	2025-12-10 17:03:35.507662
4297	sensor_cilantro_2	19.43	75.22	61.08	1.97	6.65	896.12	472.45	2025-12-10 17:03:35.50772
4298	sensor_rabano_1	21.00	72.09	79.16	1.79	6.51	915.20	438.72	2025-12-10 17:03:45.51669
4299	sensor_rabano_2	22.54	65.47	74.25	1.49	6.47	917.90	459.02	2025-12-10 17:03:45.517408
4300	sensor_cilantro_1	21.02	64.56	65.38	1.48	6.57	1067.47	436.02	2025-12-10 17:03:45.517523
4301	sensor_cilantro_2	21.30	75.20	76.48	1.51	6.61	854.54	492.40	2025-12-10 17:03:45.51767
4302	sensor_rabano_1	21.35	61.68	72.42	1.80	6.46	931.48	463.21	2025-12-10 17:03:55.528274
4303	sensor_rabano_2	22.49	67.22	75.63	1.65	6.67	874.95	441.78	2025-12-10 17:03:55.529105
4304	sensor_cilantro_1	19.53	68.94	79.54	1.70	6.43	844.88	463.59	2025-12-10 17:03:55.529294
4305	sensor_cilantro_2	22.62	69.85	60.84	1.50	6.70	809.48	460.22	2025-12-10 17:03:55.529438
4306	sensor_rabano_1	20.90	69.19	72.12	1.71	6.78	991.44	410.81	2025-12-10 17:06:33.323372
4307	sensor_rabano_2	21.12	65.98	67.10	1.50	6.54	1006.70	408.80	2025-12-10 17:06:33.324209
4308	sensor_cilantro_1	20.37	71.95	65.55	1.58	6.79	1138.41	474.09	2025-12-10 17:06:33.324408
4309	sensor_cilantro_2	21.44	69.35	78.38	1.75	6.75	1143.86	484.34	2025-12-10 17:06:33.324622
4310	sensor_rabano_1	20.92	60.10	66.34	1.79	6.70	898.76	462.16	2025-12-10 17:06:43.334986
4311	sensor_rabano_2	21.43	60.80	63.59	1.41	6.47	987.65	450.61	2025-12-10 17:06:43.335789
4312	sensor_cilantro_1	21.98	66.61	74.30	2.00	6.77	820.02	499.42	2025-12-10 17:06:43.335977
4313	sensor_cilantro_2	19.95	67.30	68.65	1.55	6.49	873.37	450.31	2025-12-10 17:06:43.336129
4314	sensor_rabano_1	21.25	65.47	64.71	1.84	6.72	860.41	467.44	2025-12-10 17:06:53.345773
4315	sensor_rabano_2	23.93	66.39	79.00	1.47	6.52	1011.39	420.94	2025-12-10 17:06:53.346561
4316	sensor_cilantro_1	21.03	67.67	72.99	1.52	6.59	973.74	439.13	2025-12-10 17:06:53.346783
4317	sensor_cilantro_2	22.97	67.93	65.72	1.46	6.56	1005.36	464.08	2025-12-10 17:06:53.346977
4318	sensor_rabano_1	22.75	61.80	70.99	1.44	6.65	1175.80	480.63	2025-12-10 17:07:03.355502
4319	sensor_rabano_2	22.09	60.91	78.85	1.43	6.74	932.98	496.32	2025-12-10 17:07:03.356233
4320	sensor_cilantro_1	19.17	67.17	61.55	1.84	6.73	972.02	450.63	2025-12-10 17:07:03.356526
4321	sensor_cilantro_2	20.42	73.38	79.47	1.49	6.46	983.03	455.64	2025-12-10 17:07:03.356747
4322	sensor_rabano_1	21.75	57.55	72.25	1.70	6.68	1144.28	484.08	2025-12-10 17:07:13.365734
4323	sensor_rabano_2	23.58	61.52	77.03	1.45	6.54	1126.70	432.55	2025-12-10 17:07:13.366359
4324	sensor_cilantro_1	19.67	68.68	69.02	1.42	6.72	1156.44	400.09	2025-12-10 17:07:13.366527
4325	sensor_cilantro_2	20.90	75.67	71.76	1.72	6.64	1196.24	435.70	2025-12-10 17:07:13.366609
4326	sensor_rabano_1	23.07	69.53	61.37	1.54	6.73	889.68	409.59	2025-12-10 17:07:23.373754
4327	sensor_rabano_2	22.96	67.46	69.00	1.84	6.56	1048.45	446.84	2025-12-10 17:07:23.374248
4328	sensor_cilantro_1	21.60	68.03	60.35	1.99	6.74	1047.33	491.71	2025-12-10 17:07:23.374331
4329	sensor_cilantro_2	21.01	76.50	67.76	1.47	6.51	1042.00	487.47	2025-12-10 17:07:23.374389
4330	sensor_rabano_1	22.69	62.77	74.34	1.63	6.73	947.66	499.22	2025-12-10 17:07:33.38533
4331	sensor_rabano_2	23.12	58.67	68.43	1.56	6.76	842.92	487.92	2025-12-10 17:07:33.386134
4332	sensor_cilantro_1	21.36	75.80	74.64	1.77	6.52	950.09	478.36	2025-12-10 17:07:33.386388
4333	sensor_cilantro_2	19.09	71.80	72.30	1.81	6.62	887.28	496.50	2025-12-10 17:07:33.386553
4334	sensor_rabano_1	22.99	68.90	71.04	1.49	6.46	1050.93	497.19	2025-12-10 17:07:43.394322
4335	sensor_rabano_2	21.03	71.51	64.48	1.68	6.60	968.46	436.01	2025-12-10 17:07:43.394814
4336	sensor_cilantro_1	19.19	70.99	61.42	1.73	6.75	1152.89	442.27	2025-12-10 17:07:43.394894
4337	sensor_cilantro_2	21.01	69.96	62.57	1.54	6.44	900.78	495.49	2025-12-10 17:07:43.39495
4338	sensor_rabano_1	22.24	64.86	66.20	1.47	6.56	975.91	487.29	2025-12-10 17:07:53.40491
4339	sensor_rabano_2	20.96	72.00	74.59	1.86	6.59	915.89	492.76	2025-12-10 17:07:53.405695
4340	sensor_cilantro_1	21.61	68.29	67.97	1.50	6.71	1043.84	407.34	2025-12-10 17:07:53.40593
4341	sensor_cilantro_2	21.15	66.40	68.11	1.81	6.75	802.32	410.89	2025-12-10 17:07:53.406087
4342	sensor_rabano_1	20.41	57.76	79.46	1.97	6.42	1092.57	414.38	2025-12-10 17:08:03.416478
4343	sensor_rabano_2	21.89	72.92	67.73	1.42	6.72	1148.47	494.23	2025-12-10 17:08:03.417272
4344	sensor_cilantro_1	21.92	76.53	60.30	1.60	6.60	1054.58	465.63	2025-12-10 17:08:03.417492
4345	sensor_cilantro_2	19.89	68.13	76.28	1.51	6.54	875.13	412.04	2025-12-10 17:08:03.417657
4346	sensor_rabano_1	23.10	72.63	77.09	1.69	6.75	1112.44	441.94	2025-12-10 17:08:13.42836
4347	sensor_rabano_2	24.00	70.43	68.88	1.97	6.42	969.07	430.81	2025-12-10 17:08:13.429193
4348	sensor_cilantro_1	22.16	62.02	77.43	1.47	6.74	1110.97	405.15	2025-12-10 17:08:13.429476
4349	sensor_cilantro_2	19.03	64.69	78.70	1.90	6.52	1070.33	411.64	2025-12-10 17:08:13.429694
4350	sensor_rabano_1	20.41	72.70	62.29	1.80	6.61	852.68	433.85	2025-12-10 17:08:23.439443
4351	sensor_rabano_2	22.76	60.30	63.23	1.73	6.74	955.94	429.27	2025-12-10 17:08:23.440125
4352	sensor_cilantro_1	20.10	73.80	63.61	1.74	6.72	1093.91	499.95	2025-12-10 17:08:23.440236
4353	sensor_cilantro_2	19.93	66.42	76.20	1.76	6.77	842.27	463.13	2025-12-10 17:08:23.440299
4354	sensor_rabano_1	21.55	65.35	60.58	1.53	6.41	909.06	496.71	2025-12-10 17:08:33.449913
4355	sensor_rabano_2	23.95	70.40	73.82	1.46	6.56	1158.34	439.90	2025-12-10 17:08:33.450796
4356	sensor_cilantro_1	20.30	74.13	62.65	1.79	6.60	1143.23	411.79	2025-12-10 17:08:33.451011
4357	sensor_cilantro_2	22.33	73.55	65.77	1.68	6.45	1063.66	460.36	2025-12-10 17:08:33.451162
4358	sensor_rabano_1	21.57	57.67	72.96	1.81	6.60	908.58	416.06	2025-12-10 17:08:43.461551
4359	sensor_rabano_2	22.22	66.57	64.06	1.49	6.44	1181.20	466.51	2025-12-10 17:08:43.462352
4360	sensor_cilantro_1	22.60	73.50	66.64	1.97	6.73	1065.86	435.07	2025-12-10 17:08:43.462584
4361	sensor_cilantro_2	22.82	76.79	76.31	1.69	6.59	824.16	412.26	2025-12-10 17:08:43.462783
4362	sensor_rabano_1	20.84	67.64	79.97	1.47	6.51	1091.59	465.60	2025-12-10 17:08:53.473941
4363	sensor_rabano_2	20.05	69.08	74.55	1.87	6.65	1008.46	443.69	2025-12-10 17:08:53.474507
4364	sensor_cilantro_1	20.42	75.17	73.28	1.59	6.77	1165.11	443.65	2025-12-10 17:08:53.474685
4365	sensor_cilantro_2	20.73	73.80	63.68	1.94	6.56	867.91	448.31	2025-12-10 17:08:53.474843
4366	sensor_rabano_1	23.68	70.84	77.50	1.84	6.51	813.67	416.24	2025-12-10 17:09:03.484988
4367	sensor_rabano_2	23.47	70.39	73.59	1.84	6.78	800.78	463.08	2025-12-10 17:09:03.485795
4368	sensor_cilantro_1	22.63	67.04	71.04	1.80	6.77	1153.85	422.28	2025-12-10 17:09:03.485983
4369	sensor_cilantro_2	21.93	75.13	63.27	2.00	6.55	1101.90	443.08	2025-12-10 17:09:03.486139
4370	sensor_rabano_1	21.96	64.32	62.72	1.60	6.70	924.02	480.19	2025-12-10 17:09:13.552458
4371	sensor_rabano_2	20.02	62.62	75.46	2.00	6.48	1052.45	470.67	2025-12-10 17:09:13.553438
4372	sensor_cilantro_1	19.65	66.98	63.44	1.87	6.42	853.05	467.07	2025-12-10 17:09:13.553671
4373	sensor_cilantro_2	20.12	73.59	61.94	1.68	6.69	896.42	463.22	2025-12-10 17:09:13.553821
4374	sensor_rabano_1	22.40	66.63	71.94	1.83	6.69	1000.97	409.52	2025-12-10 17:09:23.564128
4375	sensor_rabano_2	22.44	72.35	71.32	1.79	6.60	801.35	452.60	2025-12-10 17:09:23.565102
4376	sensor_cilantro_1	20.90	76.72	69.73	1.82	6.49	1061.92	413.06	2025-12-10 17:09:23.56531
4377	sensor_cilantro_2	19.06	72.32	64.22	1.90	6.75	930.74	489.13	2025-12-10 17:09:23.565596
4378	sensor_rabano_1	21.03	63.89	72.66	1.68	6.55	1008.60	494.28	2025-12-10 17:09:33.573581
4379	sensor_rabano_2	22.63	65.82	78.04	1.91	6.64	923.82	410.97	2025-12-10 17:09:33.5741
4380	sensor_cilantro_1	19.40	76.19	72.56	1.58	6.49	922.62	412.02	2025-12-10 17:09:33.574185
4381	sensor_cilantro_2	22.63	70.70	63.79	1.72	6.67	913.27	466.49	2025-12-10 17:09:33.574358
4382	sensor_rabano_1	22.94	65.74	75.58	1.65	6.72	988.61	471.46	2025-12-10 17:09:43.585004
4383	sensor_rabano_2	23.23	60.24	77.69	1.68	6.47	951.80	492.85	2025-12-10 17:09:43.585969
4384	sensor_cilantro_1	19.58	66.74	77.94	1.99	6.63	958.65	453.31	2025-12-10 17:09:43.586228
4385	sensor_cilantro_2	21.16	77.80	76.27	1.55	6.53	1078.31	424.67	2025-12-10 17:09:43.586394
4386	sensor_rabano_1	21.07	59.01	61.06	1.74	6.64	1123.74	437.80	2025-12-10 17:09:53.596885
4387	sensor_rabano_2	21.47	62.41	78.24	1.48	6.55	1180.40	480.90	2025-12-10 17:09:53.597664
4388	sensor_cilantro_1	19.13	66.17	63.26	1.41	6.45	1045.99	417.54	2025-12-10 17:09:53.59795
4389	sensor_cilantro_2	19.66	76.11	76.56	1.90	6.72	1066.05	427.71	2025-12-10 17:09:53.598234
4390	sensor_rabano_1	22.62	63.81	73.00	1.46	6.61	857.94	494.49	2025-12-10 17:10:03.610281
4391	sensor_rabano_2	21.51	60.52	62.23	1.84	6.42	1071.74	466.92	2025-12-10 17:10:03.611163
4392	sensor_cilantro_1	19.86	73.94	62.13	1.85	6.61	1038.75	497.54	2025-12-10 17:10:03.611475
4393	sensor_cilantro_2	19.89	73.61	69.08	1.68	6.79	1175.67	476.86	2025-12-10 17:10:03.611693
4394	sensor_rabano_1	22.23	70.02	68.60	2.00	6.71	1179.11	428.33	2025-12-10 17:10:13.621926
4395	sensor_rabano_2	23.04	61.30	65.09	1.83	6.65	1010.97	497.81	2025-12-10 17:10:13.622741
4396	sensor_cilantro_1	19.98	68.06	62.16	1.90	6.58	1057.34	481.04	2025-12-10 17:10:13.622933
4397	sensor_cilantro_2	20.76	70.38	61.66	1.81	6.65	1196.11	491.73	2025-12-10 17:10:13.623078
4398	sensor_rabano_1	22.36	69.51	68.37	1.77	6.59	804.64	455.81	2025-12-10 17:10:23.635146
4399	sensor_rabano_2	22.44	61.82	65.10	1.51	6.69	875.42	436.63	2025-12-10 17:10:23.63606
4400	sensor_cilantro_1	22.37	64.54	60.38	1.57	6.57	917.34	478.59	2025-12-10 17:10:23.636249
4401	sensor_cilantro_2	20.25	72.07	79.92	1.51	6.69	1032.80	446.66	2025-12-10 17:10:23.636491
4402	sensor_rabano_1	22.24	68.70	69.24	1.57	6.66	1150.07	497.02	2025-12-10 17:10:33.64673
4403	sensor_rabano_2	23.58	65.09	76.07	1.70	6.53	1086.06	427.98	2025-12-10 17:10:33.647472
4404	sensor_cilantro_1	22.05	63.34	67.30	1.93	6.62	853.69	445.74	2025-12-10 17:10:33.647771
4405	sensor_cilantro_2	19.38	71.93	77.07	1.50	6.54	850.82	463.93	2025-12-10 17:10:33.648014
4406	sensor_rabano_1	22.00	72.41	71.52	1.70	6.57	1124.04	449.06	2025-12-10 17:10:43.658352
4407	sensor_rabano_2	21.00	59.07	61.75	1.46	6.59	1058.90	451.11	2025-12-10 17:10:43.659235
4408	sensor_cilantro_1	22.80	67.12	60.46	1.74	6.41	1132.97	461.90	2025-12-10 17:10:43.659698
4409	sensor_cilantro_2	21.04	77.29	68.82	1.63	6.75	1067.32	485.06	2025-12-10 17:10:43.65994
4410	sensor_rabano_1	22.10	63.12	62.62	1.47	6.72	981.28	420.92	2025-12-10 17:10:53.670188
4411	sensor_rabano_2	22.41	64.40	61.13	1.96	6.40	878.90	434.29	2025-12-10 17:10:53.670999
4412	sensor_cilantro_1	19.99	73.36	77.07	1.82	6.72	1096.75	447.40	2025-12-10 17:10:53.671105
4413	sensor_cilantro_2	21.57	71.71	62.78	1.73	6.66	890.34	483.29	2025-12-10 17:10:53.671163
4414	sensor_rabano_1	22.30	67.69	74.74	1.53	6.51	910.40	430.85	2025-12-10 17:11:03.681399
4415	sensor_rabano_2	22.02	63.40	73.24	1.73	6.53	816.96	482.62	2025-12-10 17:11:03.682212
4416	sensor_cilantro_1	20.48	72.30	72.61	1.45	6.50	949.63	400.51	2025-12-10 17:11:03.682473
4417	sensor_cilantro_2	20.89	63.61	60.83	1.43	6.68	1091.70	408.87	2025-12-10 17:11:03.682673
4418	sensor_rabano_1	22.50	66.30	66.19	1.94	6.68	1155.81	468.56	2025-12-10 17:11:13.692588
4419	sensor_rabano_2	22.03	71.61	60.99	1.80	6.55	1024.11	444.03	2025-12-10 17:11:13.693376
4420	sensor_cilantro_1	19.76	67.71	65.28	1.51	6.41	881.84	454.05	2025-12-10 17:11:13.693561
4421	sensor_cilantro_2	22.09	67.19	78.22	1.51	6.52	823.74	479.68	2025-12-10 17:11:13.693713
4422	sensor_rabano_1	22.76	72.69	69.72	1.89	6.65	1057.13	406.53	2025-12-10 17:11:23.703744
4423	sensor_rabano_2	21.73	67.22	65.20	1.65	6.50	995.23	496.90	2025-12-10 17:11:23.704564
4424	sensor_cilantro_1	21.20	71.64	75.92	1.49	6.41	824.10	435.06	2025-12-10 17:11:23.70479
4425	sensor_cilantro_2	19.72	75.66	63.67	1.78	6.70	1076.42	417.95	2025-12-10 17:11:23.70495
4426	sensor_rabano_1	22.71	68.80	79.75	1.80	6.55	1173.76	470.67	2025-12-10 17:11:33.715393
4427	sensor_rabano_2	21.15	64.01	79.90	1.93	6.56	1105.29	403.19	2025-12-10 17:11:33.716288
4428	sensor_cilantro_1	22.48	66.55	72.49	1.56	6.70	893.85	456.04	2025-12-10 17:11:33.716488
4429	sensor_cilantro_2	19.36	76.92	66.05	1.74	6.78	1110.33	477.14	2025-12-10 17:11:33.716632
4430	sensor_rabano_1	20.18	60.23	64.25	1.65	6.58	1187.38	409.24	2025-12-10 17:11:43.728195
4431	sensor_rabano_2	23.66	65.79	68.46	1.79	6.63	1001.03	470.00	2025-12-10 17:11:43.729142
4432	sensor_cilantro_1	22.48	75.34	70.30	1.93	6.51	1127.42	457.52	2025-12-10 17:11:43.729343
4433	sensor_cilantro_2	21.52	66.66	60.85	1.58	6.42	1144.88	420.90	2025-12-10 17:11:43.729566
4434	sensor_rabano_1	22.32	60.12	74.48	1.42	6.72	981.91	433.72	2025-12-10 17:11:53.740769
4435	sensor_rabano_2	23.68	67.21	61.06	1.64	6.44	1188.06	492.10	2025-12-10 17:11:53.741577
4436	sensor_cilantro_1	21.31	62.15	75.03	1.98	6.56	1144.20	435.70	2025-12-10 17:11:53.741788
4437	sensor_cilantro_2	22.32	62.69	79.68	1.89	6.55	925.60	408.07	2025-12-10 17:11:53.741941
4438	sensor_rabano_1	22.95	57.16	61.91	1.99	6.65	892.22	495.07	2025-12-10 17:12:03.752302
4439	sensor_rabano_2	21.87	66.18	64.84	1.94	6.63	963.54	401.54	2025-12-10 17:12:03.753106
4440	sensor_cilantro_1	21.37	63.48	73.10	1.86	6.43	1005.50	490.95	2025-12-10 17:12:03.753287
4441	sensor_cilantro_2	20.58	74.99	65.14	1.77	6.40	1197.06	428.33	2025-12-10 17:12:03.753429
4442	sensor_rabano_1	22.02	58.65	62.98	1.55	6.69	1058.31	464.88	2025-12-10 17:12:13.762265
4443	sensor_rabano_2	22.04	60.77	69.29	1.94	6.69	1015.08	410.10	2025-12-10 17:12:13.76316
4444	sensor_cilantro_1	21.09	62.87	79.73	1.80	6.62	931.13	443.64	2025-12-10 17:12:13.763265
4445	sensor_cilantro_2	20.58	67.95	68.43	1.72	6.61	875.13	417.51	2025-12-10 17:12:13.763338
4446	sensor_rabano_1	22.20	64.78	74.57	1.77	6.53	959.70	458.43	2025-12-10 17:12:23.772874
4447	sensor_rabano_2	21.66	62.93	69.86	1.79	6.68	1057.80	461.84	2025-12-10 17:12:23.773573
4448	sensor_cilantro_1	19.26	65.26	65.57	1.54	6.74	1138.79	479.63	2025-12-10 17:12:23.773744
4449	sensor_cilantro_2	21.07	67.57	78.26	1.43	6.55	907.79	419.61	2025-12-10 17:12:23.773897
4450	sensor_rabano_1	20.59	63.61	61.13	1.68	6.73	947.79	412.73	2025-12-10 17:12:33.7832
4451	sensor_rabano_2	20.00	58.02	71.16	1.49	6.43	803.54	405.78	2025-12-10 17:12:33.783755
4452	sensor_cilantro_1	19.36	73.46	66.16	1.99	6.56	1024.55	436.32	2025-12-10 17:12:33.783887
4453	sensor_cilantro_2	19.90	63.91	71.19	1.78	6.49	1089.07	447.45	2025-12-10 17:12:33.783953
4454	sensor_rabano_1	22.24	67.37	79.96	1.74	6.46	933.12	489.04	2025-12-10 17:12:43.793823
4455	sensor_rabano_2	20.81	70.46	75.04	1.77	6.49	1179.17	467.07	2025-12-10 17:12:43.794724
4456	sensor_cilantro_1	20.62	62.99	61.00	1.44	6.75	928.55	435.80	2025-12-10 17:12:43.794908
4457	sensor_cilantro_2	20.72	73.44	60.47	1.68	6.55	1084.36	412.61	2025-12-10 17:12:43.795051
4458	sensor_rabano_1	20.59	70.48	76.40	1.86	6.76	1065.59	418.09	2025-12-10 17:12:53.804653
4459	sensor_rabano_2	23.47	61.03	76.49	1.65	6.79	934.69	497.83	2025-12-10 17:12:53.805299
4460	sensor_cilantro_1	22.63	76.03	60.46	1.87	6.47	1082.04	407.68	2025-12-10 17:12:53.805486
4461	sensor_cilantro_2	20.55	75.97	74.87	1.89	6.45	1110.53	446.90	2025-12-10 17:12:53.805562
4462	sensor_rabano_1	21.43	72.02	78.57	1.53	6.62	1162.31	406.31	2025-12-10 17:13:03.815032
4463	sensor_rabano_2	22.05	63.67	61.48	1.51	6.70	1095.61	490.59	2025-12-10 17:13:03.815611
4464	sensor_cilantro_1	19.52	64.49	67.49	1.90	6.77	1190.34	417.75	2025-12-10 17:13:03.815721
4465	sensor_cilantro_2	21.43	75.84	76.55	1.95	6.56	895.08	413.47	2025-12-10 17:13:03.815777
4466	sensor_rabano_1	21.40	71.15	70.42	1.81	6.74	1034.82	477.13	2025-12-10 17:13:13.823254
4467	sensor_rabano_2	22.25	59.96	66.74	1.57	6.74	1169.22	427.41	2025-12-10 17:13:13.823893
4468	sensor_cilantro_1	21.49	63.52	63.07	1.75	6.47	836.55	408.13	2025-12-10 17:13:13.823997
4469	sensor_cilantro_2	20.12	73.68	63.54	1.48	6.75	991.12	473.70	2025-12-10 17:13:13.824053
4470	sensor_rabano_1	21.18	63.98	66.64	1.54	6.70	1060.36	491.15	2025-12-10 17:13:23.833673
4471	sensor_rabano_2	23.12	67.53	67.29	1.69	6.67	1112.35	410.67	2025-12-10 17:13:23.834428
4472	sensor_cilantro_1	20.72	65.24	72.73	1.78	6.44	1060.01	428.59	2025-12-10 17:13:23.834605
4473	sensor_cilantro_2	21.34	67.80	66.20	1.50	6.57	1166.37	446.91	2025-12-10 17:13:23.834743
4474	sensor_rabano_1	21.74	61.74	61.92	1.69	6.47	1111.50	414.89	2025-12-10 17:13:33.844373
4475	sensor_rabano_2	22.17	66.90	79.07	1.41	6.56	1023.29	454.63	2025-12-10 17:13:33.845098
4476	sensor_cilantro_1	19.53	71.12	70.64	1.42	6.73	884.72	416.16	2025-12-10 17:13:33.845299
4477	sensor_cilantro_2	22.94	62.00	79.31	1.47	6.64	842.48	488.79	2025-12-10 17:13:33.845509
4478	sensor_rabano_1	22.82	72.51	62.44	1.71	6.56	1023.81	482.96	2025-12-10 17:13:43.853388
4479	sensor_rabano_2	23.17	59.49	77.19	1.65	6.69	1152.83	433.53	2025-12-10 17:13:43.854103
4480	sensor_cilantro_1	19.33	77.82	78.63	1.62	6.76	1112.44	444.24	2025-12-10 17:13:43.854493
4481	sensor_cilantro_2	22.00	73.56	71.42	1.69	6.79	989.81	431.84	2025-12-10 17:13:43.854767
4482	sensor_rabano_1	20.41	62.70	63.23	1.97	6.46	1077.64	466.99	2025-12-10 17:13:53.864225
4483	sensor_rabano_2	22.83	71.50	67.09	1.57	6.63	1125.55	427.97	2025-12-10 17:13:53.864892
4484	sensor_cilantro_1	22.71	67.51	75.83	1.52	6.54	954.23	465.08	2025-12-10 17:13:53.864999
4485	sensor_cilantro_2	21.73	62.28	68.19	1.41	6.56	938.36	492.75	2025-12-10 17:13:53.865058
4486	sensor_rabano_1	21.36	62.43	75.47	1.51	6.48	988.74	430.28	2025-12-10 17:14:04.443674
4487	sensor_rabano_2	23.53	67.36	74.00	1.92	6.79	1081.46	480.55	2025-12-10 17:14:04.444333
4488	sensor_cilantro_1	19.56	66.49	69.14	1.44	6.52	1132.82	460.83	2025-12-10 17:14:04.444441
4489	sensor_cilantro_2	20.63	67.16	64.89	1.88	6.79	1029.09	488.93	2025-12-10 17:14:04.444502
4490	sensor_rabano_1	20.70	62.86	75.15	1.67	6.50	1046.93	429.10	2025-12-10 17:14:14.513765
4491	sensor_rabano_2	22.56	65.64	69.39	1.50	6.57	1055.58	458.06	2025-12-10 17:14:14.514436
4492	sensor_cilantro_1	20.43	69.16	75.21	1.42	6.47	946.39	413.49	2025-12-10 17:14:14.514572
4493	sensor_cilantro_2	22.65	75.12	69.61	1.57	6.45	1167.09	404.50	2025-12-10 17:14:14.514636
4494	sensor_rabano_1	21.43	66.39	76.61	1.42	6.68	801.23	481.97	2025-12-10 17:14:24.523815
4495	sensor_rabano_2	22.58	57.43	73.17	1.45	6.42	907.42	482.36	2025-12-10 17:14:24.524348
4496	sensor_cilantro_1	19.42	77.49	71.92	1.80	6.66	1012.35	472.83	2025-12-10 17:14:24.524612
4497	sensor_cilantro_2	20.39	74.22	77.89	1.67	6.43	1100.31	417.86	2025-12-10 17:14:24.524703
4498	sensor_rabano_1	20.43	72.12	67.06	1.61	6.74	993.68	402.77	2025-12-10 17:14:34.531696
4499	sensor_rabano_2	20.42	66.07	73.85	1.89	6.75	926.61	472.36	2025-12-10 17:14:34.532266
4500	sensor_cilantro_1	19.68	72.75	66.01	1.69	6.58	852.27	418.50	2025-12-10 17:14:34.532441
4501	sensor_cilantro_2	19.41	67.18	61.02	1.55	6.69	1033.51	498.19	2025-12-10 17:14:34.532522
4502	sensor_rabano_1	21.00	68.46	77.18	1.63	6.49	929.56	401.51	2025-12-10 17:14:44.542515
4503	sensor_rabano_2	20.69	63.79	61.15	1.85	6.60	1127.05	476.88	2025-12-10 17:14:44.5436
4504	sensor_cilantro_1	21.67	72.14	71.94	1.91	6.52	841.13	486.64	2025-12-10 17:14:44.543948
4505	sensor_cilantro_2	20.29	62.08	74.97	1.54	6.55	885.28	445.94	2025-12-10 17:14:44.544258
4506	sensor_rabano_1	20.35	59.08	65.20	1.46	6.79	1022.24	458.35	2025-12-10 17:14:54.554633
4507	sensor_rabano_2	20.63	70.20	67.99	1.72	6.70	931.96	439.07	2025-12-10 17:14:54.555319
4508	sensor_cilantro_1	19.62	67.31	76.43	1.58	6.41	846.53	474.72	2025-12-10 17:14:54.555607
4509	sensor_cilantro_2	20.78	67.56	67.44	1.80	6.50	1013.44	420.96	2025-12-10 17:14:54.555766
4510	sensor_rabano_1	23.09	58.67	64.66	1.92	6.58	936.27	483.02	2025-12-10 17:15:04.56581
4511	sensor_rabano_2	22.91	64.36	61.84	2.00	6.70	958.87	411.05	2025-12-10 17:15:04.566668
4512	sensor_cilantro_1	22.88	76.85	77.02	1.93	6.51	840.51	474.73	2025-12-10 17:15:04.566861
4513	sensor_cilantro_2	22.06	76.75	65.07	1.74	6.49	1038.09	417.52	2025-12-10 17:15:04.567013
4514	sensor_rabano_1	20.63	68.66	79.29	1.61	6.51	862.55	495.44	2025-12-10 17:15:14.577399
4515	sensor_rabano_2	21.90	64.96	61.40	1.49	6.67	1101.40	460.07	2025-12-10 17:15:14.57819
4516	sensor_cilantro_1	22.68	66.64	66.53	1.73	6.76	1097.03	461.35	2025-12-10 17:15:14.578376
4517	sensor_cilantro_2	22.98	73.69	79.10	1.60	6.57	1004.44	444.53	2025-12-10 17:15:14.578522
4518	sensor_rabano_1	23.18	72.81	62.00	1.68	6.49	996.62	436.55	2025-12-10 17:15:24.588353
4519	sensor_rabano_2	20.66	61.70	77.81	1.53	6.78	950.68	412.91	2025-12-10 17:15:24.589168
4520	sensor_cilantro_1	20.25	72.33	78.47	1.72	6.60	968.56	463.15	2025-12-10 17:15:24.589402
4521	sensor_cilantro_2	19.89	74.70	68.11	1.73	6.69	1023.04	418.46	2025-12-10 17:15:24.589561
4522	sensor_rabano_1	20.76	70.52	76.58	1.69	6.53	1065.24	474.02	2025-12-10 17:15:34.600641
4523	sensor_rabano_2	20.58	63.18	65.34	1.96	6.41	806.25	422.55	2025-12-10 17:15:34.601269
4524	sensor_cilantro_1	19.41	75.37	67.37	1.79	6.71	1102.15	447.46	2025-12-10 17:15:34.601441
4525	sensor_cilantro_2	22.18	72.69	79.06	1.68	6.68	1156.23	440.51	2025-12-10 17:15:34.601525
4526	sensor_rabano_1	21.67	62.46	70.91	1.40	6.64	1062.62	413.57	2025-12-10 17:15:44.611673
4527	sensor_rabano_2	21.30	69.75	67.43	1.58	6.71	904.26	466.06	2025-12-10 17:15:44.612339
4528	sensor_cilantro_1	22.49	75.52	72.63	1.92	6.43	888.69	475.53	2025-12-10 17:15:44.612522
4529	sensor_cilantro_2	19.43	63.45	74.42	1.73	6.76	1137.23	472.65	2025-12-10 17:15:44.612605
4530	sensor_rabano_1	21.84	63.65	62.74	1.77	6.40	1176.91	454.37	2025-12-10 17:15:54.620114
4531	sensor_rabano_2	20.76	70.06	79.91	1.87	6.62	1191.66	493.22	2025-12-10 17:15:54.620812
4532	sensor_cilantro_1	19.37	74.86	62.76	1.94	6.63	1070.90	451.22	2025-12-10 17:15:54.620903
4533	sensor_cilantro_2	19.46	73.32	67.29	1.71	6.41	950.15	482.69	2025-12-10 17:15:54.62096
4534	sensor_rabano_1	21.56	69.29	65.11	1.41	6.76	1177.70	453.62	2025-12-10 17:16:04.63099
4535	sensor_rabano_2	21.36	67.57	69.10	1.72	6.80	1044.15	480.84	2025-12-10 17:16:04.631983
4536	sensor_cilantro_1	21.17	68.92	61.66	1.78	6.51	1080.64	478.57	2025-12-10 17:16:04.632206
4537	sensor_cilantro_2	19.79	76.96	64.59	1.82	6.59	1179.43	459.89	2025-12-10 17:16:04.632371
4538	sensor_rabano_1	21.77	68.09	71.85	1.45	6.56	815.29	440.16	2025-12-10 17:16:14.640444
4539	sensor_rabano_2	21.68	65.46	68.91	1.58	6.57	805.71	474.76	2025-12-10 17:16:14.640956
4540	sensor_cilantro_1	20.67	74.70	76.00	1.47	6.42	1069.27	495.97	2025-12-10 17:16:14.641045
4541	sensor_cilantro_2	19.55	62.19	65.85	1.78	6.72	940.24	423.34	2025-12-10 17:16:14.641186
4542	sensor_rabano_1	22.55	63.10	74.45	1.58	6.64	862.41	449.18	2025-12-10 17:16:24.648213
4543	sensor_rabano_2	21.98	62.50	72.47	1.90	6.45	968.99	449.17	2025-12-10 17:16:24.648875
4544	sensor_cilantro_1	21.72	76.06	70.40	1.44	6.55	1192.18	438.93	2025-12-10 17:16:24.648988
4545	sensor_cilantro_2	20.86	71.98	71.82	1.61	6.70	844.61	459.01	2025-12-10 17:16:24.649053
4546	sensor_rabano_1	23.04	61.71	61.29	1.91	6.71	1089.63	410.26	2025-12-10 17:16:34.658107
4547	sensor_rabano_2	22.07	67.19	70.52	1.81	6.80	911.65	418.28	2025-12-10 17:16:34.658714
4548	sensor_cilantro_1	21.13	64.21	66.75	1.65	6.50	1068.02	403.16	2025-12-10 17:16:34.658796
4549	sensor_cilantro_2	20.50	72.75	68.68	1.71	6.55	1052.02	412.24	2025-12-10 17:16:34.658852
4550	sensor_rabano_1	22.70	58.73	73.86	1.65	6.50	968.45	489.07	2025-12-10 17:16:44.669298
4551	sensor_rabano_2	20.97	60.96	74.73	1.67	6.42	1012.94	424.55	2025-12-10 17:16:44.670306
4552	sensor_cilantro_1	22.84	73.97	72.28	1.92	6.57	1060.57	481.77	2025-12-10 17:16:44.670618
4553	sensor_cilantro_2	19.66	62.59	71.56	1.45	6.57	914.22	484.54	2025-12-10 17:16:44.670788
4554	sensor_rabano_1	23.46	59.44	71.76	1.79	6.77	1003.82	490.24	2025-12-10 17:16:54.678395
4555	sensor_rabano_2	21.55	72.16	67.64	1.53	6.76	905.05	416.92	2025-12-10 17:16:54.678997
4556	sensor_cilantro_1	22.32	69.12	74.53	1.82	6.67	979.10	427.59	2025-12-10 17:16:54.679095
4557	sensor_cilantro_2	20.44	74.05	71.74	1.67	6.58	860.42	404.17	2025-12-10 17:16:54.679154
4558	sensor_rabano_1	22.99	64.39	76.43	1.53	6.59	942.23	465.44	2025-12-10 17:17:04.687341
4559	sensor_rabano_2	22.21	65.49	74.58	1.51	6.80	1003.08	492.70	2025-12-10 17:17:04.688019
4560	sensor_cilantro_1	22.23	67.57	60.22	1.48	6.55	866.02	456.15	2025-12-10 17:17:04.688129
4561	sensor_cilantro_2	22.61	63.00	61.83	1.66	6.66	838.72	477.96	2025-12-10 17:17:04.688189
4562	sensor_rabano_1	20.60	72.82	66.26	1.54	6.73	1034.24	411.35	2025-12-10 17:17:14.69793
4563	sensor_rabano_2	20.33	65.05	69.39	1.83	6.58	896.26	408.08	2025-12-10 17:17:14.699259
4564	sensor_cilantro_1	21.97	62.30	77.29	1.92	6.74	1151.98	420.28	2025-12-10 17:17:14.699517
4565	sensor_cilantro_2	22.46	72.57	79.13	1.41	6.75	1025.67	437.19	2025-12-10 17:17:14.699673
4566	sensor_rabano_1	22.39	70.74	78.35	1.94	6.68	1041.02	416.30	2025-12-10 17:17:24.70999
4567	sensor_rabano_2	22.11	67.33	73.19	1.75	6.68	834.78	478.70	2025-12-10 17:17:24.710861
4568	sensor_cilantro_1	22.22	73.44	68.56	1.81	6.50	1007.57	413.66	2025-12-10 17:17:24.711097
4569	sensor_cilantro_2	20.40	71.83	60.99	1.95	6.40	1145.64	474.96	2025-12-10 17:17:24.711255
4570	sensor_rabano_1	20.05	57.51	66.17	1.68	6.56	948.29	486.75	2025-12-10 17:17:34.720444
4571	sensor_rabano_2	22.85	66.44	64.07	1.77	6.75	1033.08	421.21	2025-12-10 17:17:34.721168
4572	sensor_cilantro_1	20.77	64.12	74.33	1.52	6.62	1117.20	422.03	2025-12-10 17:17:34.721343
4573	sensor_cilantro_2	22.99	73.71	79.31	1.93	6.63	859.31	425.89	2025-12-10 17:17:34.721486
4574	sensor_rabano_1	21.47	61.68	73.64	1.87	6.78	1057.05	494.42	2025-12-10 17:17:44.73199
4575	sensor_rabano_2	21.33	61.58	74.71	1.87	6.77	1146.70	492.80	2025-12-10 17:17:44.732855
4576	sensor_cilantro_1	22.69	68.99	60.47	1.54	6.63	1080.65	437.44	2025-12-10 17:17:44.733094
4577	sensor_cilantro_2	20.66	70.06	79.26	1.95	6.78	1166.69	483.57	2025-12-10 17:17:44.733355
4578	sensor_rabano_1	23.16	62.30	60.72	1.46	6.43	947.95	448.79	2025-12-10 17:17:54.744302
4579	sensor_rabano_2	23.39	71.94	68.79	1.67	6.57	1018.82	403.14	2025-12-10 17:17:54.745276
4580	sensor_cilantro_1	20.30	72.31	71.98	1.44	6.55	1008.26	401.77	2025-12-10 17:17:54.745501
4581	sensor_cilantro_2	22.75	63.85	71.75	1.69	6.63	1066.93	437.54	2025-12-10 17:17:54.745709
4582	sensor_rabano_1	20.95	57.20	74.83	1.76	6.76	915.05	497.40	2025-12-10 17:18:04.753393
4583	sensor_rabano_2	20.96	68.34	70.46	1.47	6.67	1004.89	480.81	2025-12-10 17:18:04.754013
4584	sensor_cilantro_1	21.80	70.51	76.01	1.75	6.54	1151.48	497.28	2025-12-10 17:18:04.754112
4585	sensor_cilantro_2	21.34	69.72	68.12	1.98	6.55	1010.56	453.90	2025-12-10 17:18:04.754171
4586	sensor_rabano_1	20.19	65.13	76.56	1.55	6.61	1033.78	415.34	2025-12-10 17:18:14.763968
4587	sensor_rabano_2	20.27	64.95	67.50	1.97	6.53	832.14	441.46	2025-12-10 17:18:14.764798
4588	sensor_cilantro_1	21.29	65.99	79.46	1.98	6.78	855.10	442.10	2025-12-10 17:18:14.764992
4589	sensor_cilantro_2	19.01	73.21	66.69	1.44	6.58	999.42	492.90	2025-12-10 17:18:14.765468
4590	sensor_rabano_1	22.22	70.21	60.87	1.84	6.45	1180.12	407.77	2025-12-10 17:18:24.773919
4591	sensor_rabano_2	22.13	64.92	60.22	1.40	6.54	1016.06	404.13	2025-12-10 17:18:24.774771
4592	sensor_cilantro_1	19.82	63.87	71.38	1.78	6.73	803.42	419.94	2025-12-10 17:18:24.775008
4593	sensor_cilantro_2	21.64	72.41	72.89	1.79	6.76	868.92	486.52	2025-12-10 17:18:24.775326
4594	sensor_rabano_1	23.36	59.86	73.73	1.71	6.51	1182.49	408.11	2025-12-10 17:18:34.783396
4595	sensor_rabano_2	22.86	63.92	67.02	1.63	6.47	1050.48	460.85	2025-12-10 17:18:34.783908
4596	sensor_cilantro_1	21.86	66.70	61.95	1.70	6.64	1040.18	474.06	2025-12-10 17:18:34.784001
4597	sensor_cilantro_2	20.15	64.98	74.92	1.46	6.74	998.03	454.13	2025-12-10 17:18:34.784059
4598	sensor_rabano_1	21.14	57.24	68.30	1.45	6.77	914.41	433.15	2025-12-10 17:18:44.793993
4599	sensor_rabano_2	20.60	65.53	71.62	1.85	6.79	1076.33	409.54	2025-12-10 17:18:44.794813
4600	sensor_cilantro_1	22.46	77.87	60.63	1.57	6.49	959.44	474.79	2025-12-10 17:18:44.794998
4601	sensor_cilantro_2	19.36	68.63	76.17	1.84	6.80	1017.19	459.60	2025-12-10 17:18:44.795161
4602	sensor_rabano_1	21.83	62.89	77.49	1.72	6.52	886.13	437.41	2025-12-10 17:18:54.804889
4603	sensor_rabano_2	22.31	60.77	78.41	1.82	6.64	1198.76	472.46	2025-12-10 17:18:54.805746
4604	sensor_cilantro_1	21.32	71.73	77.13	1.95	6.40	987.82	439.59	2025-12-10 17:18:54.805937
4605	sensor_cilantro_2	20.02	74.72	67.71	1.91	6.79	1050.03	468.38	2025-12-10 17:18:54.806147
4606	sensor_rabano_1	20.47	58.62	79.97	1.68	6.76	1132.18	420.50	2025-12-10 17:19:04.816918
4607	sensor_rabano_2	22.79	61.51	69.37	1.40	6.42	1157.59	446.02	2025-12-10 17:19:04.817771
4608	sensor_cilantro_1	20.29	68.26	64.07	1.85	6.71	1056.30	408.43	2025-12-10 17:19:04.817948
4609	sensor_cilantro_2	22.43	67.37	62.79	1.58	6.60	1047.11	450.17	2025-12-10 17:19:04.818102
4610	sensor_rabano_1	23.75	60.85	66.75	1.56	6.57	1032.55	477.41	2025-12-10 17:19:14.887701
4611	sensor_rabano_2	21.57	60.57	65.18	1.76	6.42	953.32	480.18	2025-12-10 17:19:14.88852
4612	sensor_cilantro_1	22.46	67.89	75.73	1.73	6.58	801.55	428.84	2025-12-10 17:19:14.888713
4613	sensor_cilantro_2	21.00	73.41	65.77	1.56	6.53	869.01	439.78	2025-12-10 17:19:14.888859
4614	sensor_rabano_1	22.17	68.94	66.86	1.43	6.78	1006.68	409.71	2025-12-10 17:19:24.898247
4615	sensor_rabano_2	21.12	71.46	73.26	1.94	6.67	1031.06	493.54	2025-12-10 17:19:24.899056
4616	sensor_cilantro_1	20.60	74.80	68.26	1.41	6.70	1117.87	493.37	2025-12-10 17:19:24.899288
4617	sensor_cilantro_2	19.26	64.62	76.62	1.52	6.63	903.11	452.52	2025-12-10 17:19:24.89948
4618	sensor_rabano_1	22.29	68.08	70.95	1.71	6.52	803.85	480.87	2025-12-10 17:19:34.909746
4619	sensor_rabano_2	22.52	64.90	60.49	1.91	6.56	1004.34	449.37	2025-12-10 17:19:34.910554
4620	sensor_cilantro_1	19.30	75.21	61.36	1.99	6.46	1145.59	437.82	2025-12-10 17:19:34.910732
4621	sensor_cilantro_2	20.54	66.66	64.51	1.87	6.50	1139.14	499.26	2025-12-10 17:19:34.910872
4622	sensor_rabano_1	23.08	60.28	74.62	1.55	6.74	851.54	452.21	2025-12-10 17:19:44.920081
4623	sensor_rabano_2	23.96	64.44	78.46	1.56	6.67	1063.84	420.97	2025-12-10 17:19:44.920584
4624	sensor_cilantro_1	21.82	64.56	73.11	1.46	6.63	815.30	488.45	2025-12-10 17:19:44.92067
4625	sensor_cilantro_2	20.30	71.05	68.21	1.77	6.56	1097.39	406.64	2025-12-10 17:19:44.920726
4626	sensor_rabano_1	23.71	72.99	64.15	1.57	6.62	1150.63	430.43	2025-12-10 17:19:54.931881
4627	sensor_rabano_2	23.52	65.38	75.50	1.44	6.42	1095.98	463.40	2025-12-10 17:19:54.932617
4628	sensor_cilantro_1	22.38	62.98	64.32	1.79	6.67	1024.44	462.84	2025-12-10 17:19:54.93279
4629	sensor_cilantro_2	20.45	66.34	67.49	1.42	6.50	870.76	421.38	2025-12-10 17:19:54.932942
4630	sensor_rabano_1	22.53	61.16	64.18	1.56	6.66	824.44	424.19	2025-12-10 17:20:04.942118
4631	sensor_rabano_2	23.26	69.58	79.06	1.88	6.66	1011.43	404.03	2025-12-10 17:20:04.942939
4632	sensor_cilantro_1	22.06	68.01	61.71	1.76	6.53	1066.27	403.09	2025-12-10 17:20:04.943177
4633	sensor_cilantro_2	20.40	69.96	69.95	1.56	6.73	1173.21	461.85	2025-12-10 17:20:04.943371
4634	sensor_rabano_1	21.26	72.79	68.90	1.73	6.51	1018.33	410.63	2025-12-10 17:20:14.953688
4635	sensor_rabano_2	20.80	58.92	76.32	1.82	6.75	1115.12	415.27	2025-12-10 17:20:14.954252
4636	sensor_cilantro_1	19.61	70.64	60.77	1.99	6.48	1059.64	428.87	2025-12-10 17:20:14.954452
4637	sensor_cilantro_2	19.78	75.88	76.30	1.97	6.55	1116.97	479.92	2025-12-10 17:20:14.954518
4638	sensor_rabano_1	22.92	72.71	60.47	1.53	6.59	1148.78	491.80	2025-12-10 17:20:24.964688
4639	sensor_rabano_2	22.42	59.52	76.50	1.71	6.48	1132.49	488.17	2025-12-10 17:20:24.965198
4640	sensor_cilantro_1	22.22	75.22	64.29	1.75	6.76	1028.54	438.79	2025-12-10 17:20:24.965286
4641	sensor_cilantro_2	19.64	62.50	65.02	1.63	6.49	1174.37	488.49	2025-12-10 17:20:24.965345
4642	sensor_rabano_1	21.49	58.14	64.30	1.80	6.58	832.28	453.86	2025-12-10 17:20:34.976669
4643	sensor_rabano_2	21.88	70.74	79.80	1.78	6.62	1055.96	421.69	2025-12-10 17:20:34.97725
4644	sensor_cilantro_1	22.34	77.14	70.64	1.97	6.62	1052.15	446.53	2025-12-10 17:20:34.97736
4645	sensor_cilantro_2	22.86	76.56	77.32	1.84	6.51	1090.21	476.49	2025-12-10 17:20:34.97742
4646	sensor_rabano_1	20.84	58.77	71.84	1.48	6.70	1135.92	432.93	2025-12-10 17:20:44.987469
4647	sensor_rabano_2	21.22	66.52	69.73	1.85	6.52	836.36	444.09	2025-12-10 17:20:44.988301
4648	sensor_cilantro_1	22.40	71.80	68.27	1.54	6.40	958.58	446.22	2025-12-10 17:20:44.988527
4649	sensor_cilantro_2	22.02	66.38	77.49	1.86	6.59	907.76	487.25	2025-12-10 17:20:44.988726
4650	sensor_rabano_1	20.35	59.24	67.93	1.61	6.49	895.82	419.37	2025-12-10 17:20:55.000523
4651	sensor_rabano_2	20.33	72.76	63.01	1.48	6.77	1049.91	431.97	2025-12-10 17:20:55.00138
4652	sensor_cilantro_1	20.09	77.19	76.59	1.82	6.69	1028.47	438.91	2025-12-10 17:20:55.001588
4653	sensor_cilantro_2	19.82	62.06	74.93	1.92	6.44	1036.41	450.42	2025-12-10 17:20:55.001742
4654	sensor_rabano_1	23.46	63.83	75.22	1.76	6.62	873.24	455.61	2025-12-10 17:21:05.013417
4655	sensor_rabano_2	21.61	57.86	75.06	1.48	6.48	938.65	498.28	2025-12-10 17:21:05.014215
4656	sensor_cilantro_1	21.06	66.56	70.12	1.61	6.43	998.14	492.84	2025-12-10 17:21:05.014397
4657	sensor_cilantro_2	19.92	75.19	61.68	1.92	6.57	976.76	470.79	2025-12-10 17:21:05.014537
4658	sensor_rabano_1	20.82	57.17	61.96	1.85	6.65	1085.66	453.66	2025-12-10 17:21:15.02532
4659	sensor_rabano_2	22.65	59.92	60.04	1.56	6.76	1023.70	456.03	2025-12-10 17:21:15.026179
4660	sensor_cilantro_1	21.75	73.52	66.48	1.67	6.40	956.56	441.47	2025-12-10 17:21:15.026419
4661	sensor_cilantro_2	20.25	62.88	78.60	1.53	6.68	829.37	498.42	2025-12-10 17:21:15.02662
4662	sensor_rabano_1	21.15	67.16	62.95	1.74	6.71	1070.09	406.11	2025-12-10 17:21:25.034747
4663	sensor_rabano_2	22.67	57.33	78.68	1.73	6.42	1105.94	409.66	2025-12-10 17:21:25.035248
4664	sensor_cilantro_1	19.84	65.59	74.34	1.55	6.52	1147.80	449.55	2025-12-10 17:21:25.035336
4665	sensor_cilantro_2	20.22	70.62	76.92	1.95	6.79	1104.80	469.13	2025-12-10 17:21:25.035393
4666	sensor_rabano_1	22.01	66.86	72.57	1.99	6.44	1153.75	489.15	2025-12-10 17:21:35.045627
4667	sensor_rabano_2	23.65	65.47	64.26	1.95	6.54	856.05	429.22	2025-12-10 17:21:35.046425
4668	sensor_cilantro_1	21.68	65.21	63.02	1.73	6.67	1086.52	412.29	2025-12-10 17:21:35.046534
4669	sensor_cilantro_2	19.41	62.09	77.05	1.62	6.69	975.68	407.08	2025-12-10 17:21:35.046593
4670	sensor_rabano_1	20.67	59.82	73.51	1.86	6.56	853.88	426.02	2025-12-10 17:21:45.057784
4671	sensor_rabano_2	22.10	62.98	76.97	1.89	6.79	841.27	416.86	2025-12-10 17:21:45.058638
4672	sensor_cilantro_1	21.11	77.06	73.31	1.83	6.52	906.98	469.78	2025-12-10 17:21:45.058827
4673	sensor_cilantro_2	22.14	75.67	62.82	1.95	6.80	1064.46	457.56	2025-12-10 17:21:45.05897
4674	sensor_rabano_1	22.88	57.22	75.35	1.73	6.58	812.79	495.00	2025-12-10 17:21:55.069195
4675	sensor_rabano_2	20.76	61.53	69.59	1.60	6.73	1058.00	459.04	2025-12-10 17:21:55.070147
4676	sensor_cilantro_1	20.42	63.90	79.99	1.66	6.43	1196.58	409.75	2025-12-10 17:21:55.070357
4677	sensor_cilantro_2	19.57	75.06	79.04	1.73	6.43	804.94	461.42	2025-12-10 17:21:55.070606
4678	sensor_rabano_1	20.09	69.06	72.10	1.69	6.47	922.13	407.68	2025-12-10 17:22:05.080889
4679	sensor_rabano_2	22.27	57.99	64.14	1.78	6.78	1045.96	456.52	2025-12-10 17:22:05.0819
4680	sensor_cilantro_1	22.30	76.72	69.49	1.58	6.44	854.16	419.22	2025-12-10 17:22:05.082154
4681	sensor_cilantro_2	22.22	71.64	68.39	1.98	6.75	1095.85	475.72	2025-12-10 17:22:05.082435
4682	sensor_rabano_1	22.34	61.65	73.72	1.79	6.71	945.83	411.49	2025-12-10 17:22:15.093023
4683	sensor_rabano_2	23.08	58.88	63.38	1.55	6.68	980.20	407.44	2025-12-10 17:22:15.093883
4684	sensor_cilantro_1	21.02	69.56	60.76	1.87	6.46	874.56	458.04	2025-12-10 17:22:15.094143
4685	sensor_cilantro_2	19.13	64.75	77.95	1.99	6.43	1031.80	415.97	2025-12-10 17:22:15.094319
4686	sensor_rabano_1	20.49	67.90	63.08	1.87	6.74	801.59	497.54	2025-12-10 17:22:25.104734
4687	sensor_rabano_2	20.13	60.92	77.38	1.59	6.48	965.38	415.21	2025-12-10 17:22:25.105589
4688	sensor_cilantro_1	19.53	68.61	69.47	1.61	6.56	903.89	447.01	2025-12-10 17:22:25.10578
4689	sensor_cilantro_2	20.60	64.68	76.41	1.57	6.59	967.50	408.11	2025-12-10 17:22:25.105927
4690	sensor_rabano_1	21.83	63.07	74.19	1.48	6.54	1101.60	471.93	2025-12-10 17:22:35.116717
4691	sensor_rabano_2	21.41	64.64	72.97	1.65	6.59	890.81	488.74	2025-12-10 17:22:35.11754
4692	sensor_cilantro_1	20.96	74.37	70.85	1.40	6.52	1160.23	476.46	2025-12-10 17:22:35.11776
4693	sensor_cilantro_2	21.95	65.83	71.74	1.95	6.53	970.20	425.50	2025-12-10 17:22:35.117848
4694	sensor_rabano_1	23.02	65.01	72.05	1.69	6.79	872.82	437.20	2025-12-10 17:22:45.127328
4695	sensor_rabano_2	21.47	70.89	65.21	1.96	6.60	1015.90	417.89	2025-12-10 17:22:45.128121
4696	sensor_cilantro_1	20.01	63.52	78.15	1.88	6.65	1180.30	469.89	2025-12-10 17:22:45.12831
4697	sensor_cilantro_2	21.76	72.61	67.17	1.83	6.48	800.10	434.84	2025-12-10 17:22:45.128393
4698	sensor_rabano_1	20.80	69.21	60.18	1.81	6.40	1117.71	484.92	2025-12-10 17:22:55.137732
4699	sensor_rabano_2	22.65	57.52	72.18	1.90	6.75	909.51	498.07	2025-12-10 17:22:55.138513
4700	sensor_cilantro_1	21.74	74.97	64.21	1.80	6.61	947.57	492.19	2025-12-10 17:22:55.138698
4701	sensor_cilantro_2	22.31	72.46	69.42	1.93	6.70	1101.07	483.48	2025-12-10 17:22:55.138856
4702	sensor_rabano_1	21.67	65.71	64.84	1.84	6.77	1079.94	431.93	2025-12-10 17:23:05.149202
4703	sensor_rabano_2	22.12	62.41	62.03	1.72	6.48	979.22	436.54	2025-12-10 17:23:05.150211
4704	sensor_cilantro_1	19.14	71.34	79.32	1.70	6.68	996.64	428.51	2025-12-10 17:23:05.150458
4705	sensor_cilantro_2	22.76	66.54	67.78	1.65	6.44	1154.49	448.96	2025-12-10 17:23:05.150672
4706	sensor_rabano_1	23.48	69.16	70.02	1.57	6.52	1196.35	492.35	2025-12-10 17:23:15.162666
4707	sensor_rabano_2	22.98	60.36	61.25	1.49	6.78	1031.83	404.46	2025-12-10 17:23:15.163546
4708	sensor_cilantro_1	20.24	77.33	65.82	1.75	6.76	806.03	439.51	2025-12-10 17:23:15.163756
4709	sensor_cilantro_2	19.22	72.25	67.95	1.54	6.75	909.41	444.95	2025-12-10 17:23:15.163905
4710	sensor_rabano_1	22.08	60.03	60.45	1.50	6.62	852.89	407.21	2025-12-10 17:23:25.174668
4711	sensor_rabano_2	23.24	66.45	77.35	1.83	6.76	888.38	478.44	2025-12-10 17:23:25.175466
4712	sensor_cilantro_1	21.04	63.07	63.77	1.96	6.78	1128.56	495.69	2025-12-10 17:23:25.175659
4713	sensor_cilantro_2	19.07	65.82	66.80	1.50	6.69	1064.40	418.96	2025-12-10 17:23:25.175805
4714	sensor_rabano_1	21.01	60.04	65.67	1.97	6.56	1057.19	432.46	2025-12-10 17:23:35.187119
4715	sensor_rabano_2	22.76	72.73	68.24	1.49	6.51	818.68	459.90	2025-12-10 17:23:35.187866
4716	sensor_cilantro_1	20.60	71.85	77.84	1.82	6.62	1192.91	479.77	2025-12-10 17:23:35.187972
4717	sensor_cilantro_2	21.89	62.74	68.38	1.97	6.55	851.64	451.75	2025-12-10 17:23:35.188044
4718	sensor_rabano_1	23.70	71.96	78.54	1.64	6.63	807.87	487.33	2025-12-10 17:23:45.197947
4719	sensor_rabano_2	21.53	65.57	72.04	1.45	6.66	1055.98	429.98	2025-12-10 17:23:45.198883
4720	sensor_cilantro_1	19.33	73.00	69.84	1.54	6.79	845.39	485.89	2025-12-10 17:23:45.199132
4721	sensor_cilantro_2	20.31	73.55	71.82	1.63	6.52	994.26	418.82	2025-12-10 17:23:45.199401
4722	sensor_rabano_1	20.08	65.16	62.77	1.73	6.65	850.99	454.27	2025-12-10 17:23:55.211018
4723	sensor_rabano_2	23.76	58.18	60.89	1.57	6.54	946.31	456.36	2025-12-10 17:23:55.211913
4724	sensor_cilantro_1	19.92	64.33	70.35	1.77	6.48	1162.08	495.50	2025-12-10 17:23:55.212159
4725	sensor_cilantro_2	20.90	64.40	64.57	1.57	6.53	931.83	416.93	2025-12-10 17:23:55.212361
4726	sensor_rabano_1	23.99	59.32	73.28	1.84	6.47	921.37	477.48	2025-12-10 17:24:05.222176
4727	sensor_rabano_2	22.79	58.65	66.03	1.61	6.47	897.65	467.54	2025-12-10 17:24:05.223042
4728	sensor_cilantro_1	20.76	73.70	65.31	1.90	6.42	1145.70	404.04	2025-12-10 17:24:05.223277
4729	sensor_cilantro_2	22.94	76.53	66.80	1.89	6.69	1056.96	485.22	2025-12-10 17:24:05.223477
4730	sensor_rabano_1	20.27	58.70	70.58	1.85	6.59	1005.00	480.13	2025-12-10 17:24:15.296871
4731	sensor_rabano_2	23.11	58.63	77.29	1.55	6.64	1115.19	413.90	2025-12-10 17:24:15.297713
4732	sensor_cilantro_1	19.49	73.09	62.99	1.78	6.43	1155.03	426.37	2025-12-10 17:24:15.297914
4733	sensor_cilantro_2	19.95	71.23	75.97	1.65	6.76	1101.61	412.96	2025-12-10 17:24:15.298077
4734	sensor_rabano_1	23.12	65.16	64.37	1.79	6.79	1025.40	460.22	2025-12-10 17:24:25.306412
4735	sensor_rabano_2	22.84	65.90	66.97	1.90	6.73	1062.36	458.75	2025-12-10 17:24:25.306963
4736	sensor_cilantro_1	22.27	67.36	70.96	1.51	6.44	949.14	406.77	2025-12-10 17:24:25.307063
4737	sensor_cilantro_2	21.11	71.44	71.68	1.57	6.74	1160.44	409.15	2025-12-10 17:24:25.307121
4738	sensor_rabano_1	23.11	59.84	78.02	1.62	6.49	1189.56	461.75	2025-12-10 17:24:35.316433
4739	sensor_rabano_2	23.54	65.64	76.23	1.88	6.73	1062.85	417.39	2025-12-10 17:24:35.316958
4740	sensor_cilantro_1	22.85	73.77	63.01	1.96	6.53	878.53	465.56	2025-12-10 17:24:35.317051
4741	sensor_cilantro_2	21.83	75.79	66.69	1.62	6.64	912.86	423.24	2025-12-10 17:24:35.317109
4742	sensor_rabano_1	21.82	65.38	75.34	1.62	6.78	1022.77	464.93	2025-12-10 17:24:45.326274
4743	sensor_rabano_2	21.53	65.95	62.16	1.91	6.72	1114.84	470.50	2025-12-10 17:24:45.327249
4744	sensor_cilantro_1	22.75	71.60	71.78	1.86	6.65	1034.44	494.55	2025-12-10 17:24:45.327553
4745	sensor_cilantro_2	22.92	75.03	79.64	1.51	6.60	900.18	441.11	2025-12-10 17:24:45.327704
4746	sensor_rabano_1	20.10	68.54	71.28	1.58	6.66	898.86	471.97	2025-12-10 17:24:55.335148
4747	sensor_rabano_2	20.49	66.96	69.08	1.55	6.57	948.09	464.43	2025-12-10 17:24:55.335724
4748	sensor_cilantro_1	21.19	67.82	74.73	2.00	6.48	854.83	495.78	2025-12-10 17:24:55.335817
4749	sensor_cilantro_2	19.98	70.22	65.31	1.88	6.54	1133.00	492.77	2025-12-10 17:24:55.335878
4750	sensor_rabano_1	21.42	58.72	79.40	1.89	6.51	847.74	474.55	2025-12-10 17:25:05.34367
4751	sensor_rabano_2	23.28	66.84	78.41	1.68	6.52	1104.71	452.47	2025-12-10 17:25:05.34449
4752	sensor_cilantro_1	20.39	62.31	61.06	1.74	6.65	995.69	487.00	2025-12-10 17:25:05.344842
4753	sensor_cilantro_2	20.41	75.61	65.36	1.93	6.68	1128.74	453.22	2025-12-10 17:25:05.345031
4754	sensor_rabano_1	21.86	61.82	63.92	1.42	6.46	1191.77	453.48	2025-12-10 17:25:15.355154
4755	sensor_rabano_2	20.23	71.30	68.58	1.91	6.78	938.76	449.92	2025-12-10 17:25:15.356137
4756	sensor_cilantro_1	20.57	70.58	64.31	1.42	6.77	1167.62	449.69	2025-12-10 17:25:15.35642
4757	sensor_cilantro_2	19.62	68.96	65.73	1.84	6.54	1090.34	408.86	2025-12-10 17:25:15.356584
4758	sensor_rabano_1	22.41	58.61	65.93	1.95	6.69	1109.95	467.56	2025-12-10 17:25:25.367158
4759	sensor_rabano_2	20.31	66.31	78.05	1.82	6.68	1038.13	409.08	2025-12-10 17:25:25.36802
4760	sensor_cilantro_1	22.74	75.55	65.87	1.93	6.77	815.92	410.52	2025-12-10 17:25:25.368259
4761	sensor_cilantro_2	19.70	71.64	61.38	1.53	6.64	1187.44	442.91	2025-12-10 17:25:25.36844
4762	sensor_rabano_1	23.59	60.12	67.65	1.60	6.43	1015.28	446.84	2025-12-10 17:25:35.378888
4763	sensor_rabano_2	23.69	58.63	72.03	1.72	6.62	1193.92	486.24	2025-12-10 17:25:35.379763
4764	sensor_cilantro_1	21.13	69.79	70.51	1.94	6.80	805.77	495.82	2025-12-10 17:25:35.379966
4765	sensor_cilantro_2	22.85	65.41	67.01	1.67	6.61	846.24	420.69	2025-12-10 17:25:35.380265
4766	sensor_rabano_1	21.24	69.72	79.70	1.70	6.49	1041.38	421.79	2025-12-10 17:25:45.390729
4767	sensor_rabano_2	22.18	68.19	69.86	1.64	6.68	860.26	468.72	2025-12-10 17:25:45.391607
4768	sensor_cilantro_1	19.62	74.72	63.98	1.95	6.47	982.03	412.42	2025-12-10 17:25:45.391846
4769	sensor_cilantro_2	20.07	72.76	73.21	1.47	6.63	861.43	464.24	2025-12-10 17:25:45.392094
4770	sensor_rabano_1	20.22	62.64	65.77	1.49	6.64	1158.62	407.63	2025-12-10 17:25:55.402431
4771	sensor_rabano_2	20.25	70.88	64.66	2.00	6.60	1100.43	417.77	2025-12-10 17:25:55.403248
4772	sensor_cilantro_1	22.20	73.95	62.82	1.91	6.66	951.25	467.35	2025-12-10 17:25:55.403442
4773	sensor_cilantro_2	22.15	65.77	63.00	1.56	6.60	1163.30	417.13	2025-12-10 17:25:55.403668
4774	sensor_rabano_1	21.31	60.13	61.58	1.85	6.72	1061.18	424.27	2025-12-10 17:26:05.412253
4775	sensor_rabano_2	23.84	64.83	77.66	1.87	6.79	806.75	479.74	2025-12-10 17:26:05.413335
4776	sensor_cilantro_1	19.52	66.84	74.83	1.64	6.77	1041.10	475.93	2025-12-10 17:26:05.413563
4777	sensor_cilantro_2	22.95	68.59	61.36	1.58	6.76	1098.53	415.35	2025-12-10 17:26:05.41372
4778	sensor_rabano_1	20.01	57.68	69.18	1.85	6.43	989.00	491.82	2025-12-10 17:26:15.42404
4779	sensor_rabano_2	20.20	58.66	69.93	1.89	6.51	1173.03	454.86	2025-12-10 17:26:15.425033
4780	sensor_cilantro_1	20.16	67.28	71.52	1.46	6.71	1194.47	441.59	2025-12-10 17:26:15.42529
4781	sensor_cilantro_2	22.80	63.83	71.61	1.49	6.49	927.80	456.14	2025-12-10 17:26:15.425443
4782	sensor_rabano_1	23.21	65.96	67.03	1.90	6.70	811.82	415.35	2025-12-10 17:26:25.436265
4783	sensor_rabano_2	23.57	72.76	70.69	1.87	6.71	843.26	411.05	2025-12-10 17:26:25.437259
4784	sensor_cilantro_1	19.93	74.79	74.13	1.52	6.70	1196.16	410.90	2025-12-10 17:26:25.437539
4785	sensor_cilantro_2	21.94	67.04	72.93	1.62	6.74	1119.39	467.95	2025-12-10 17:26:25.437697
4786	sensor_rabano_1	20.24	67.60	73.79	1.79	6.79	1083.39	438.75	2025-12-10 17:26:35.939307
4787	sensor_rabano_2	23.49	70.51	78.81	1.54	6.61	1095.14	422.39	2025-12-10 17:26:35.940103
4788	sensor_cilantro_1	21.17	74.44	68.82	1.60	6.45	1095.09	418.60	2025-12-10 17:26:35.940295
4789	sensor_cilantro_2	22.29	68.70	79.42	1.99	6.49	1121.73	469.81	2025-12-10 17:26:35.940439
4790	sensor_rabano_1	21.76	67.98	62.99	1.97	6.68	984.25	442.44	2025-12-10 17:26:45.95092
4791	sensor_rabano_2	23.91	71.74	65.16	1.52	6.43	1098.97	476.28	2025-12-10 17:26:45.951748
4792	sensor_cilantro_1	20.07	77.99	75.13	1.62	6.73	1034.69	432.34	2025-12-10 17:26:45.952179
4793	sensor_cilantro_2	19.27	77.53	70.71	1.87	6.64	1025.59	452.25	2025-12-10 17:26:45.952378
4794	sensor_rabano_1	21.81	60.47	64.12	1.46	6.80	1136.86	415.55	2025-12-10 17:26:55.963711
4795	sensor_rabano_2	22.86	67.74	60.94	1.61	6.64	1181.52	435.19	2025-12-10 17:26:55.9645
4796	sensor_cilantro_1	22.35	73.27	69.51	1.78	6.78	1126.64	489.02	2025-12-10 17:26:55.964689
4797	sensor_cilantro_2	22.57	72.17	63.05	1.62	6.51	1031.51	453.28	2025-12-10 17:26:55.964931
4798	sensor_rabano_1	21.24	70.36	73.53	1.97	6.50	1098.04	418.00	2025-12-10 17:27:05.975308
4799	sensor_rabano_2	21.49	62.66	79.41	1.41	6.72	861.35	418.86	2025-12-10 17:27:05.976158
4800	sensor_cilantro_1	19.71	66.10	72.61	1.74	6.76	1143.10	436.56	2025-12-10 17:27:05.976351
4801	sensor_cilantro_2	19.51	66.62	76.75	1.59	6.63	1128.92	436.39	2025-12-10 17:27:05.976497
4802	sensor_rabano_1	23.87	61.82	73.37	1.76	6.63	998.63	407.21	2025-12-10 17:27:15.985499
4803	sensor_rabano_2	21.79	68.90	76.33	1.78	6.57	1008.31	443.32	2025-12-10 17:27:15.985991
4804	sensor_cilantro_1	22.49	69.71	68.81	1.56	6.78	1164.59	400.41	2025-12-10 17:27:15.986075
4805	sensor_cilantro_2	19.02	63.82	64.66	1.50	6.49	1037.90	423.52	2025-12-10 17:27:15.98613
4806	sensor_rabano_1	21.12	66.43	77.34	1.91	6.68	1085.67	485.96	2025-12-10 17:27:25.996252
4807	sensor_rabano_2	23.64	68.27	74.14	1.48	6.77	915.60	474.72	2025-12-10 17:27:25.997083
4808	sensor_cilantro_1	20.61	69.78	79.87	1.81	6.49	997.22	441.23	2025-12-10 17:27:25.997311
4809	sensor_cilantro_2	22.30	66.26	79.77	1.54	6.68	969.45	405.63	2025-12-10 17:27:25.997473
4810	sensor_rabano_1	20.51	67.63	63.76	1.44	6.72	894.19	461.25	2025-12-10 17:27:36.00886
4811	sensor_rabano_2	21.76	61.33	74.42	1.60	6.55	931.02	473.13	2025-12-10 17:27:36.009597
4812	sensor_cilantro_1	19.16	76.41	66.89	1.50	6.52	861.52	427.21	2025-12-10 17:27:36.009795
4813	sensor_cilantro_2	19.35	75.45	79.06	1.47	6.41	936.31	485.28	2025-12-10 17:27:36.010009
4814	sensor_rabano_1	23.83	65.44	70.26	1.45	6.53	880.59	442.49	2025-12-10 17:27:46.020347
4815	sensor_rabano_2	23.05	59.20	76.39	1.88	6.73	1140.01	477.18	2025-12-10 17:27:46.02117
4816	sensor_cilantro_1	21.00	68.76	74.52	1.70	6.79	996.98	485.94	2025-12-10 17:27:46.021401
4817	sensor_cilantro_2	20.11	76.06	65.85	1.81	6.75	1006.23	464.82	2025-12-10 17:27:46.02156
4818	sensor_rabano_1	20.14	72.93	69.93	1.58	6.56	833.13	408.30	2025-12-10 17:27:56.031747
4819	sensor_rabano_2	23.85	64.40	68.01	1.53	6.60	1069.90	417.46	2025-12-10 17:27:56.032592
4820	sensor_cilantro_1	21.08	75.93	76.59	1.52	6.58	1119.48	444.78	2025-12-10 17:27:56.032875
4821	sensor_cilantro_2	21.48	69.34	63.90	1.81	6.59	1090.82	474.16	2025-12-10 17:27:56.033031
4822	sensor_rabano_1	21.11	61.75	75.46	1.79	6.52	971.06	420.98	2025-12-10 17:28:06.043511
4823	sensor_rabano_2	23.26	62.55	64.31	1.82	6.41	1136.13	471.13	2025-12-10 17:28:06.044392
4824	sensor_cilantro_1	21.99	62.86	69.97	1.97	6.48	909.13	445.39	2025-12-10 17:28:06.044573
4825	sensor_cilantro_2	22.61	74.41	73.49	1.70	6.41	840.91	452.38	2025-12-10 17:28:06.044796
4826	sensor_rabano_1	21.68	65.51	71.14	1.79	6.47	1027.20	468.02	2025-12-10 17:28:16.054099
4827	sensor_rabano_2	20.29	62.95	72.21	1.69	6.62	1056.71	424.35	2025-12-10 17:28:16.054635
4828	sensor_cilantro_1	20.00	66.62	69.63	1.92	6.64	1164.79	461.01	2025-12-10 17:28:16.054729
4829	sensor_cilantro_2	20.37	70.60	71.94	1.95	6.63	1045.35	452.00	2025-12-10 17:28:16.054789
4830	sensor_rabano_1	21.41	68.82	73.98	1.47	6.51	842.76	442.85	2025-12-10 17:28:26.064416
4831	sensor_rabano_2	21.07	69.70	74.63	1.57	6.76	1072.01	490.61	2025-12-10 17:28:26.065164
4832	sensor_cilantro_1	21.68	75.98	78.84	1.58	6.60	879.13	436.80	2025-12-10 17:28:26.065342
4833	sensor_cilantro_2	20.70	77.33	75.35	1.86	6.77	879.99	422.85	2025-12-10 17:28:26.065485
4834	sensor_rabano_1	23.75	67.60	60.24	1.69	6.45	1139.31	487.61	2025-12-10 17:28:36.077573
4835	sensor_rabano_2	20.93	63.36	62.62	1.57	6.44	1189.35	437.57	2025-12-10 17:28:36.078626
4836	sensor_cilantro_1	21.56	68.75	77.72	1.44	6.63	963.35	416.71	2025-12-10 17:28:36.078892
4837	sensor_cilantro_2	20.97	66.95	60.89	1.83	6.48	1117.10	468.78	2025-12-10 17:28:36.079097
4838	sensor_rabano_1	21.61	67.27	77.28	1.72	6.66	1162.56	456.46	2025-12-10 17:28:46.087883
4839	sensor_rabano_2	21.31	65.24	73.78	1.79	6.51	966.50	480.35	2025-12-10 17:28:46.088486
4840	sensor_cilantro_1	22.27	71.12	65.57	1.82	6.59	854.93	444.47	2025-12-10 17:28:46.088566
4841	sensor_cilantro_2	19.01	74.48	69.49	1.91	6.50	896.07	441.73	2025-12-10 17:28:46.088621
4842	sensor_rabano_1	23.77	69.96	62.61	1.53	6.75	863.28	450.55	2025-12-10 17:28:56.098097
4843	sensor_rabano_2	21.82	59.72	61.59	1.49	6.42	1137.49	464.04	2025-12-10 17:28:56.098861
4844	sensor_cilantro_1	20.26	68.53	60.05	1.41	6.77	1118.20	493.90	2025-12-10 17:28:56.099047
4845	sensor_cilantro_2	21.25	69.32	72.69	1.54	6.52	1143.42	452.90	2025-12-10 17:28:56.099192
4846	sensor_rabano_1	23.88	64.60	64.98	1.73	6.44	1064.72	478.27	2025-12-10 17:29:06.109565
4847	sensor_rabano_2	21.18	59.85	67.59	1.43	6.54	1155.98	475.08	2025-12-10 17:29:06.110516
4848	sensor_cilantro_1	22.03	73.94	75.01	1.96	6.48	1183.85	409.54	2025-12-10 17:29:06.110786
4849	sensor_cilantro_2	22.07	71.80	77.37	1.65	6.45	974.35	487.49	2025-12-10 17:29:06.111043
4850	sensor_rabano_1	22.79	57.24	69.83	1.42	6.46	1113.70	410.07	2025-12-10 17:29:16.182874
4851	sensor_rabano_2	21.93	69.44	64.20	1.48	6.76	1079.48	456.44	2025-12-10 17:29:16.183666
4852	sensor_cilantro_1	19.12	65.23	70.25	1.93	6.66	1199.06	424.65	2025-12-10 17:29:16.18392
4853	sensor_cilantro_2	21.25	75.06	76.01	1.78	6.54	898.80	426.01	2025-12-10 17:29:16.18408
4854	sensor_rabano_1	20.44	62.35	69.07	1.81	6.70	1055.08	432.04	2025-12-10 17:29:26.194568
4855	sensor_rabano_2	21.84	58.78	65.50	1.94	6.63	1046.18	453.79	2025-12-10 17:29:26.195333
4856	sensor_cilantro_1	22.20	66.26	75.11	1.80	6.76	1077.31	405.60	2025-12-10 17:29:26.195512
4857	sensor_cilantro_2	20.23	72.18	66.92	1.71	6.71	810.03	470.44	2025-12-10 17:29:26.195656
4858	sensor_rabano_1	20.09	61.31	79.98	1.90	6.78	1134.52	427.23	2025-12-10 17:29:36.205987
4859	sensor_rabano_2	23.02	63.12	77.80	1.59	6.70	1140.11	410.82	2025-12-10 17:29:36.206811
4860	sensor_cilantro_1	20.11	77.09	60.63	1.96	6.43	894.60	452.30	2025-12-10 17:29:36.207048
4861	sensor_cilantro_2	19.59	69.94	71.42	1.56	6.66	962.24	414.82	2025-12-10 17:29:36.207208
4862	sensor_rabano_1	22.81	72.62	74.84	1.81	6.78	842.52	452.63	2025-12-10 17:29:46.218003
4863	sensor_rabano_2	22.71	69.31	79.04	1.64	6.56	838.97	402.17	2025-12-10 17:29:46.218858
4864	sensor_cilantro_1	22.72	65.82	74.19	1.96	6.73	1127.79	482.02	2025-12-10 17:29:46.219128
4865	sensor_cilantro_2	21.88	64.72	63.06	1.53	6.52	830.97	445.37	2025-12-10 17:29:46.219381
4866	sensor_rabano_1	21.75	57.51	60.21	1.68	6.78	823.71	432.30	2025-12-10 17:29:56.23011
4867	sensor_rabano_2	23.62	62.19	68.75	1.64	6.77	1114.08	455.12	2025-12-10 17:29:56.231086
4868	sensor_cilantro_1	21.76	74.43	65.33	1.57	6.61	847.44	497.29	2025-12-10 17:29:56.231292
4869	sensor_cilantro_2	19.91	70.17	62.89	1.72	6.79	1007.48	405.58	2025-12-10 17:29:56.231441
4870	sensor_rabano_1	22.08	70.56	72.61	1.75	6.64	858.64	478.25	2025-12-10 17:30:06.241803
4871	sensor_rabano_2	20.66	65.63	74.81	1.73	6.68	813.38	422.36	2025-12-10 17:30:06.242673
4872	sensor_cilantro_1	20.46	72.04	74.39	1.73	6.43	899.79	460.96	2025-12-10 17:30:06.242946
4873	sensor_cilantro_2	22.02	72.70	76.73	1.64	6.58	1097.43	440.70	2025-12-10 17:30:06.243149
4874	sensor_rabano_1	21.45	66.88	78.08	1.97	6.63	1156.43	479.17	2025-12-10 17:30:16.252746
4875	sensor_rabano_2	23.18	64.42	74.38	1.81	6.48	1044.67	413.20	2025-12-10 17:30:16.253587
4876	sensor_cilantro_1	22.67	67.68	74.08	1.79	6.62	1110.77	451.01	2025-12-10 17:30:16.253834
4877	sensor_cilantro_2	22.83	70.44	73.12	1.57	6.74	801.06	473.30	2025-12-10 17:30:16.253993
4878	sensor_rabano_1	21.53	57.45	76.22	1.52	6.63	1174.57	464.57	2025-12-10 17:30:26.264843
4879	sensor_rabano_2	21.76	62.88	67.66	1.44	6.42	820.56	474.27	2025-12-10 17:30:26.265686
4880	sensor_cilantro_1	19.96	77.24	63.24	1.83	6.47	928.09	442.65	2025-12-10 17:30:26.26593
4881	sensor_cilantro_2	20.22	65.48	71.72	1.46	6.47	1005.74	430.47	2025-12-10 17:30:26.266097
4882	sensor_rabano_1	23.46	72.61	64.46	1.55	6.73	1101.83	445.71	2025-12-10 17:30:36.276489
4883	sensor_rabano_2	22.05	58.92	63.75	1.52	6.76	1016.73	480.45	2025-12-10 17:30:36.277346
4884	sensor_cilantro_1	20.03	68.01	63.24	1.78	6.50	945.37	453.53	2025-12-10 17:30:36.277536
4885	sensor_cilantro_2	22.25	74.81	79.68	1.41	6.68	1058.60	408.26	2025-12-10 17:30:36.277686
4886	sensor_rabano_1	22.22	64.73	75.11	1.88	6.69	951.69	422.49	2025-12-10 17:30:46.286619
4887	sensor_rabano_2	22.24	72.15	79.21	1.97	6.66	932.67	470.51	2025-12-10 17:30:46.287339
4888	sensor_cilantro_1	20.16	73.32	63.81	1.47	6.50	891.56	470.14	2025-12-10 17:30:46.287447
4889	sensor_cilantro_2	21.70	67.61	62.61	1.51	6.78	1145.21	420.48	2025-12-10 17:30:46.287506
4890	sensor_rabano_1	22.31	58.90	69.64	1.91	6.49	1134.15	498.33	2025-12-10 17:30:56.297344
4891	sensor_rabano_2	20.67	61.66	74.38	1.69	6.43	1072.03	437.73	2025-12-10 17:30:56.29817
4892	sensor_cilantro_1	21.59	75.41	72.51	1.93	6.65	1080.80	456.86	2025-12-10 17:30:56.29836
4893	sensor_cilantro_2	22.27	74.70	62.27	1.59	6.67	911.59	487.81	2025-12-10 17:30:56.298506
4894	sensor_rabano_1	20.06	71.45	76.53	1.91	6.56	853.54	478.66	2025-12-10 17:31:06.308878
4895	sensor_rabano_2	20.94	61.40	60.66	1.74	6.70	962.82	446.51	2025-12-10 17:31:06.309664
4896	sensor_cilantro_1	20.60	64.82	65.42	1.43	6.57	1172.78	484.32	2025-12-10 17:31:06.309898
4897	sensor_cilantro_2	20.53	72.16	75.47	1.73	6.74	857.14	475.23	2025-12-10 17:31:06.310061
4898	sensor_rabano_1	22.89	63.88	77.75	1.90	6.67	1043.87	442.04	2025-12-10 17:31:16.322207
4899	sensor_rabano_2	20.63	62.54	63.53	1.75	6.44	874.39	435.44	2025-12-10 17:31:16.322997
4900	sensor_cilantro_1	19.06	74.62	65.91	1.97	6.42	800.94	493.11	2025-12-10 17:31:16.323186
4901	sensor_cilantro_2	20.46	67.35	64.25	1.87	6.78	855.08	475.89	2025-12-10 17:31:16.32333
4902	sensor_rabano_1	20.75	63.44	65.34	1.77	6.54	1055.26	462.93	2025-12-10 17:31:26.334717
4903	sensor_rabano_2	21.51	71.94	66.61	1.85	6.43	1032.71	453.46	2025-12-10 17:31:26.335694
4904	sensor_cilantro_1	21.78	64.97	73.32	1.98	6.66	953.26	471.83	2025-12-10 17:31:26.335932
4905	sensor_cilantro_2	20.78	77.47	77.20	1.83	6.68	822.42	448.41	2025-12-10 17:31:26.336126
4906	sensor_rabano_1	21.31	62.72	62.05	1.50	6.50	1052.85	429.26	2025-12-10 17:31:36.344188
4907	sensor_rabano_2	23.51	64.16	69.64	1.47	6.73	1109.80	453.23	2025-12-10 17:31:36.344715
4908	sensor_cilantro_1	22.83	66.75	68.85	1.77	6.61	1104.20	432.48	2025-12-10 17:31:36.344805
4909	sensor_cilantro_2	21.24	74.36	75.54	1.96	6.43	943.65	493.24	2025-12-10 17:31:36.344863
4910	sensor_rabano_1	23.64	62.27	65.70	1.72	6.79	934.33	450.45	2025-12-10 17:31:46.354596
4911	sensor_rabano_2	20.35	61.47	68.91	1.98	6.46	1066.13	407.31	2025-12-10 17:31:46.355291
4912	sensor_cilantro_1	19.47	77.53	77.47	1.64	6.75	1078.36	450.13	2025-12-10 17:31:46.355398
4913	sensor_cilantro_2	21.96	70.74	71.06	1.42	6.50	1024.84	497.68	2025-12-10 17:31:46.355459
4914	sensor_rabano_1	22.59	63.97	70.26	1.68	6.54	1086.00	422.74	2025-12-10 17:31:56.366169
4915	sensor_rabano_2	20.75	63.02	74.10	1.69	6.46	886.52	434.19	2025-12-10 17:31:56.367
4916	sensor_cilantro_1	19.37	64.80	73.38	1.77	6.59	989.01	414.03	2025-12-10 17:31:56.367181
4917	sensor_cilantro_2	20.14	73.94	63.13	1.71	6.67	980.47	409.21	2025-12-10 17:31:56.367322
4918	sensor_rabano_1	20.09	71.07	72.98	1.68	6.61	971.85	403.83	2025-12-10 17:32:06.377577
4919	sensor_rabano_2	22.48	71.78	60.27	1.59	6.59	1180.47	422.48	2025-12-10 17:32:06.378506
4920	sensor_cilantro_1	20.14	75.33	63.80	1.77	6.79	964.06	407.53	2025-12-10 17:32:06.378704
4921	sensor_cilantro_2	22.60	67.96	69.77	1.76	6.41	1043.15	412.97	2025-12-10 17:32:06.378932
4922	sensor_rabano_1	22.14	61.62	69.95	1.55	6.46	1059.91	438.15	2025-12-10 17:32:16.389141
4923	sensor_rabano_2	23.69	62.55	71.98	1.42	6.53	830.76	469.70	2025-12-10 17:32:16.389889
4924	sensor_cilantro_1	20.62	72.18	61.49	1.53	6.72	805.36	416.53	2025-12-10 17:32:16.39008
4925	sensor_cilantro_2	22.70	73.83	70.76	1.66	6.52	911.50	448.00	2025-12-10 17:32:16.390233
4926	sensor_rabano_1	20.35	66.10	65.20	1.68	6.63	990.76	467.48	2025-12-10 17:32:26.400718
4927	sensor_rabano_2	22.84	57.98	76.41	1.51	6.68	1195.77	471.63	2025-12-10 17:32:26.401652
4928	sensor_cilantro_1	19.69	71.95	79.28	1.70	6.41	1151.79	430.80	2025-12-10 17:32:26.402017
4929	sensor_cilantro_2	19.29	76.10	75.49	1.98	6.77	1087.51	423.55	2025-12-10 17:32:26.402206
4930	sensor_rabano_1	21.29	58.56	60.79	1.43	6.59	1027.97	446.70	2025-12-10 17:32:36.41058
4931	sensor_rabano_2	21.36	70.61	78.96	1.84	6.80	900.80	431.38	2025-12-10 17:32:36.41127
4932	sensor_cilantro_1	22.84	71.94	64.90	1.77	6.47	836.20	428.56	2025-12-10 17:32:36.411458
4933	sensor_cilantro_2	21.26	64.24	77.35	1.94	6.48	1198.14	474.06	2025-12-10 17:32:36.411548
4934	sensor_rabano_1	22.12	60.10	78.86	1.70	6.54	1124.06	409.92	2025-12-10 17:32:46.419324
4935	sensor_rabano_2	22.83	72.59	68.01	1.97	6.52	992.85	451.69	2025-12-10 17:32:46.420018
4936	sensor_cilantro_1	20.02	72.13	60.44	1.73	6.71	1016.88	408.07	2025-12-10 17:32:46.420128
4937	sensor_cilantro_2	20.22	70.80	78.21	1.74	6.54	923.36	461.18	2025-12-10 17:32:46.42019
4938	sensor_rabano_1	22.26	71.79	71.29	1.50	6.45	898.16	432.54	2025-12-10 17:32:56.430479
4939	sensor_rabano_2	20.69	72.28	65.45	1.78	6.73	803.57	443.86	2025-12-10 17:32:56.431326
4940	sensor_cilantro_1	21.90	67.45	65.90	1.86	6.53	949.93	479.19	2025-12-10 17:32:56.431548
4941	sensor_cilantro_2	20.93	71.78	77.20	1.46	6.40	1128.13	448.80	2025-12-10 17:32:56.431901
4942	sensor_rabano_1	22.62	64.48	61.10	1.93	6.66	838.10	408.42	2025-12-10 17:33:06.443522
4943	sensor_rabano_2	20.24	65.86	77.71	1.73	6.74	887.58	457.53	2025-12-10 17:33:06.44439
4944	sensor_cilantro_1	20.01	66.97	69.06	1.54	6.42	1013.95	426.27	2025-12-10 17:33:06.444582
4945	sensor_cilantro_2	21.65	64.52	62.27	1.98	6.63	1141.88	427.92	2025-12-10 17:33:06.444735
4946	sensor_rabano_1	23.76	65.52	72.29	1.89	6.58	972.40	489.72	2025-12-10 17:33:16.455579
4947	sensor_rabano_2	22.10	63.08	62.19	1.82	6.54	807.29	430.08	2025-12-10 17:33:16.456518
4948	sensor_cilantro_1	22.93	66.50	77.07	1.53	6.63	977.43	493.15	2025-12-10 17:33:16.456721
4949	sensor_cilantro_2	19.30	74.34	60.67	1.89	6.62	1100.54	420.84	2025-12-10 17:33:16.45693
4950	sensor_rabano_1	22.58	58.39	78.62	1.75	6.50	920.39	477.89	2025-12-10 17:33:26.468084
4951	sensor_rabano_2	22.12	66.31	73.36	1.83	6.59	1146.90	475.85	2025-12-10 17:33:26.468685
4952	sensor_cilantro_1	20.40	63.07	60.61	1.65	6.75	872.77	430.56	2025-12-10 17:33:26.468806
4953	sensor_cilantro_2	20.36	67.70	69.79	1.53	6.46	975.58	436.56	2025-12-10 17:33:26.468868
4954	sensor_rabano_1	22.16	68.04	67.96	1.54	6.67	1056.53	421.87	2025-12-10 17:33:36.478733
4955	sensor_rabano_2	22.93	71.45	75.38	1.73	6.51	1197.58	412.85	2025-12-10 17:33:36.479721
4956	sensor_cilantro_1	19.82	65.56	77.27	1.71	6.52	1051.78	494.58	2025-12-10 17:33:36.480065
4957	sensor_cilantro_2	19.99	67.49	60.75	1.60	6.58	1149.96	450.66	2025-12-10 17:33:36.480339
4958	sensor_rabano_1	20.56	61.63	68.02	1.70	6.49	1146.87	457.15	2025-12-10 17:33:46.490923
4959	sensor_rabano_2	20.51	65.34	67.04	1.73	6.44	955.32	493.56	2025-12-10 17:33:46.49187
4960	sensor_cilantro_1	19.89	66.03	73.37	1.77	6.67	1023.33	489.04	2025-12-10 17:33:46.492099
4961	sensor_cilantro_2	20.60	69.79	74.67	1.61	6.50	999.45	400.05	2025-12-10 17:33:46.492262
4962	sensor_rabano_1	22.37	69.16	65.60	1.95	6.42	808.36	462.42	2025-12-10 17:33:56.50368
4963	sensor_rabano_2	20.92	71.66	65.74	1.55	6.75	920.08	454.75	2025-12-10 17:33:56.504523
4964	sensor_cilantro_1	22.53	73.92	68.61	1.95	6.58	1166.50	471.94	2025-12-10 17:33:56.50472
4965	sensor_cilantro_2	22.59	74.55	64.84	1.61	6.72	1079.92	440.52	2025-12-10 17:33:56.504878
4966	sensor_rabano_1	23.51	60.04	64.92	1.87	6.65	934.08	446.57	2025-12-10 17:34:06.513685
4967	sensor_rabano_2	20.27	66.69	74.36	1.86	6.48	940.29	406.79	2025-12-10 17:34:06.514197
4968	sensor_cilantro_1	20.67	69.26	64.51	1.92	6.56	835.07	496.09	2025-12-10 17:34:06.514281
4969	sensor_cilantro_2	21.02	75.97	71.49	1.77	6.79	1103.03	404.39	2025-12-10 17:34:06.514337
4970	sensor_rabano_1	20.18	63.62	68.09	1.77	6.72	920.52	436.64	2025-12-10 17:34:16.585328
4971	sensor_rabano_2	21.72	57.66	70.49	1.57	6.79	1096.62	445.15	2025-12-10 17:34:16.586127
4972	sensor_cilantro_1	21.66	66.62	68.60	1.41	6.55	899.36	485.08	2025-12-10 17:34:16.586315
4973	sensor_cilantro_2	21.26	64.45	70.96	1.84	6.57	1059.08	473.35	2025-12-10 17:34:16.586458
4974	sensor_rabano_1	22.32	59.35	77.75	1.88	6.69	1107.96	405.84	2025-12-10 17:34:26.596459
4975	sensor_rabano_2	21.09	57.07	65.04	1.57	6.69	942.02	435.52	2025-12-10 17:34:26.59726
4976	sensor_cilantro_1	19.20	76.93	60.32	1.48	6.49	1045.95	416.63	2025-12-10 17:34:26.597452
4977	sensor_cilantro_2	20.60	70.15	65.76	1.64	6.44	1057.28	408.27	2025-12-10 17:34:26.597761
4978	sensor_rabano_1	21.79	66.69	61.43	1.73	6.77	928.50	412.86	2025-12-10 17:34:36.609592
4979	sensor_rabano_2	23.05	69.26	69.28	2.00	6.77	1093.96	433.38	2025-12-10 17:34:36.610486
4980	sensor_cilantro_1	22.36	68.54	70.39	1.45	6.57	948.72	406.70	2025-12-10 17:34:36.610938
4981	sensor_cilantro_2	22.00	75.46	79.76	1.61	6.48	1132.53	432.65	2025-12-10 17:34:36.611314
4982	sensor_rabano_1	21.26	67.85	61.75	1.47	6.65	1060.15	440.48	2025-12-10 17:34:46.636062
4983	sensor_rabano_2	22.67	58.18	61.86	1.75	6.59	939.69	409.23	2025-12-10 17:34:46.637826
4984	sensor_cilantro_1	20.62	65.56	66.59	1.98	6.71	885.34	484.90	2025-12-10 17:34:46.638348
4985	sensor_cilantro_2	19.17	64.36	69.82	1.49	6.64	1002.90	454.41	2025-12-10 17:34:46.638745
4986	sensor_rabano_1	23.30	68.36	72.51	1.88	6.53	1099.44	416.44	2025-12-10 17:34:56.661371
4987	sensor_rabano_2	20.59	57.17	65.95	1.99	6.66	1005.39	463.28	2025-12-10 17:34:56.663504
4988	sensor_cilantro_1	21.38	77.14	78.79	1.64	6.50	945.42	452.25	2025-12-10 17:34:56.664062
4989	sensor_cilantro_2	21.53	67.02	70.71	1.92	6.77	885.16	403.34	2025-12-10 17:34:56.664503
4990	sensor_rabano_1	23.81	71.80	60.84	1.70	6.78	1117.89	449.30	2025-12-10 17:35:06.691464
4991	sensor_rabano_2	23.04	58.47	69.27	1.84	6.80	1067.73	444.75	2025-12-10 17:35:06.69365
4992	sensor_cilantro_1	19.77	66.90	74.49	1.89	6.77	1141.10	407.08	2025-12-10 17:35:06.694465
4993	sensor_cilantro_2	22.60	70.31	69.46	1.79	6.61	1118.54	485.61	2025-12-10 17:35:06.695156
4994	sensor_rabano_1	21.38	70.98	71.98	1.48	6.72	1112.25	458.19	2025-12-10 17:35:16.719994
4995	sensor_rabano_2	22.63	60.32	73.86	1.91	6.51	870.17	404.64	2025-12-10 17:35:16.721663
4996	sensor_cilantro_1	21.28	77.85	77.48	1.80	6.77	876.55	426.73	2025-12-10 17:35:16.722119
4997	sensor_cilantro_2	21.98	77.64	60.45	1.65	6.63	976.03	443.93	2025-12-10 17:35:16.722507
4998	sensor_rabano_1	22.18	66.53	73.58	1.49	6.80	881.96	400.90	2025-12-10 17:35:26.744083
4999	sensor_rabano_2	20.26	57.11	75.69	1.94	6.61	1150.79	410.43	2025-12-10 17:35:26.745751
5000	sensor_cilantro_1	21.87	65.95	79.54	1.68	6.80	1054.77	422.36	2025-12-10 17:35:26.746437
5001	sensor_cilantro_2	21.78	75.27	61.01	1.43	6.54	1056.42	413.89	2025-12-10 17:35:26.747157
5002	sensor_rabano_1	23.84	66.46	68.72	1.88	6.69	1026.59	459.62	2025-12-10 17:35:36.774405
5003	sensor_rabano_2	22.70	57.81	76.77	1.44	6.63	1153.37	401.11	2025-12-10 17:35:36.776355
5004	sensor_cilantro_1	22.90	71.86	73.63	1.84	6.43	1187.59	473.62	2025-12-10 17:35:36.776772
5005	sensor_cilantro_2	19.62	72.87	67.86	1.63	6.70	1112.15	410.03	2025-12-10 17:35:36.777236
5006	sensor_rabano_1	22.35	71.70	68.47	1.94	6.61	1086.64	493.95	2025-12-10 17:35:46.798299
5007	sensor_rabano_2	22.15	60.69	78.18	1.94	6.75	1045.69	439.47	2025-12-10 17:35:46.800243
5008	sensor_cilantro_1	19.76	70.84	65.38	1.49	6.72	866.58	452.08	2025-12-10 17:35:46.800723
5009	sensor_cilantro_2	22.99	69.69	71.69	1.40	6.59	1139.02	427.51	2025-12-10 17:35:46.801089
5010	sensor_rabano_1	22.10	63.59	70.42	1.91	6.74	1135.94	433.48	2025-12-10 17:35:56.825523
5011	sensor_rabano_2	21.45	68.04	61.69	1.63	6.67	861.17	403.95	2025-12-10 17:35:56.827068
5012	sensor_cilantro_1	21.93	76.09	66.17	1.79	6.46	1175.87	434.51	2025-12-10 17:35:56.82766
5013	sensor_cilantro_2	22.88	68.32	78.71	1.60	6.58	1099.94	481.62	2025-12-10 17:35:56.828002
5014	sensor_rabano_1	23.95	57.29	66.38	1.50	6.65	954.79	486.34	2025-12-10 17:36:06.848119
5015	sensor_rabano_2	23.26	72.36	60.16	1.90	6.48	893.57	465.68	2025-12-10 17:36:06.849377
5016	sensor_cilantro_1	22.92	76.40	76.64	1.89	6.58	1185.37	494.79	2025-12-10 17:36:06.849734
5017	sensor_cilantro_2	22.96	64.75	61.16	1.51	6.46	828.10	421.11	2025-12-10 17:36:06.849983
5018	sensor_rabano_1	22.27	66.00	71.19	1.45	6.41	1154.78	414.06	2025-12-10 17:36:16.870967
5019	sensor_rabano_2	21.26	63.24	63.76	1.66	6.78	1084.45	462.10	2025-12-10 17:36:16.8726
5020	sensor_cilantro_1	22.66	67.29	70.20	1.73	6.74	1168.03	455.85	2025-12-10 17:36:16.873055
5021	sensor_cilantro_2	20.52	70.57	71.53	1.47	6.46	940.80	436.04	2025-12-10 17:36:16.87334
5022	sensor_rabano_1	23.54	68.34	69.50	1.73	6.45	1015.47	468.45	2025-12-10 17:36:26.892842
5023	sensor_rabano_2	22.48	72.36	75.24	1.88	6.41	1031.81	427.90	2025-12-10 17:36:26.89407
5024	sensor_cilantro_1	22.35	71.20	78.26	1.80	6.74	825.29	435.00	2025-12-10 17:36:26.894408
5025	sensor_cilantro_2	22.24	64.38	79.10	1.83	6.67	834.41	422.02	2025-12-10 17:36:26.894659
5026	sensor_rabano_1	21.30	69.98	71.64	1.76	6.52	1060.25	465.05	2025-12-10 17:36:36.920244
5027	sensor_rabano_2	23.41	71.07	73.53	1.44	6.49	1120.81	448.40	2025-12-10 17:36:36.921739
5028	sensor_cilantro_1	21.95	62.20	60.44	1.95	6.62	865.44	445.98	2025-12-10 17:36:36.922447
5029	sensor_cilantro_2	22.27	70.38	76.76	1.60	6.51	1190.15	484.16	2025-12-10 17:36:36.922814
5030	sensor_rabano_1	20.32	72.80	66.30	1.80	6.51	951.91	463.99	2025-12-10 17:36:46.942758
5031	sensor_rabano_2	23.22	72.78	67.54	1.57	6.78	864.80	411.73	2025-12-10 17:36:46.943882
5032	sensor_cilantro_1	19.22	67.26	79.88	1.59	6.42	1191.13	412.58	2025-12-10 17:36:46.944163
5033	sensor_cilantro_2	21.40	71.60	63.23	1.41	6.65	1104.12	471.48	2025-12-10 17:36:46.94437
5034	sensor_rabano_1	23.89	68.54	61.78	1.92	6.52	1037.11	482.38	2025-12-10 17:36:56.967127
5035	sensor_rabano_2	22.41	68.39	75.34	1.85	6.41	1026.81	484.17	2025-12-10 17:36:56.968717
5036	sensor_cilantro_1	21.84	76.72	74.47	1.73	6.73	832.78	480.49	2025-12-10 17:36:56.969184
5037	sensor_cilantro_2	22.59	76.94	77.28	1.82	6.52	802.28	411.26	2025-12-10 17:36:56.969534
5038	sensor_rabano_1	21.17	69.55	75.88	1.90	6.70	1023.64	472.44	2025-12-10 17:37:06.989115
5039	sensor_rabano_2	21.50	63.62	61.37	1.69	6.67	1037.47	438.60	2025-12-10 17:37:06.99038
5040	sensor_cilantro_1	19.41	69.84	73.85	1.58	6.48	1017.88	473.23	2025-12-10 17:37:06.990754
5041	sensor_cilantro_2	21.01	71.71	74.44	1.93	6.75	1073.05	468.60	2025-12-10 17:37:06.991018
5042	sensor_rabano_1	20.56	60.65	60.12	1.41	6.68	1033.23	438.45	2025-12-10 17:37:17.01468
5043	sensor_rabano_2	20.01	63.70	67.54	1.63	6.41	959.05	418.29	2025-12-10 17:37:17.016799
5044	sensor_cilantro_1	21.21	77.35	60.60	1.43	6.78	1039.00	490.53	2025-12-10 17:37:17.017235
5045	sensor_cilantro_2	21.23	65.48	62.81	1.61	6.55	1150.13	481.10	2025-12-10 17:37:17.017456
5046	sensor_rabano_1	20.14	66.74	75.07	1.53	6.76	903.24	485.86	2025-12-10 17:37:27.053823
5047	sensor_rabano_2	20.03	64.95	67.70	1.60	6.70	985.31	408.44	2025-12-10 17:37:27.056152
5048	sensor_cilantro_1	19.08	75.54	68.80	1.93	6.63	1013.80	429.23	2025-12-10 17:37:27.056828
5049	sensor_cilantro_2	19.54	73.41	79.51	1.76	6.56	1197.42	498.86	2025-12-10 17:37:27.057392
5050	sensor_rabano_1	22.81	64.55	61.41	1.51	6.51	1026.49	429.65	2025-12-10 17:37:37.081001
5051	sensor_rabano_2	20.24	71.42	66.76	1.40	6.45	1103.77	422.24	2025-12-10 17:37:37.082761
5052	sensor_cilantro_1	22.17	72.45	64.84	1.49	6.62	1124.80	480.22	2025-12-10 17:37:37.083496
5053	sensor_cilantro_2	22.26	76.04	66.21	1.64	6.79	1193.53	465.01	2025-12-10 17:37:37.083996
5054	sensor_rabano_1	23.74	62.59	77.55	1.62	6.66	1194.44	455.36	2025-12-10 17:37:47.105239
5055	sensor_rabano_2	21.95	71.74	77.71	1.44	6.61	1024.18	437.30	2025-12-10 17:37:47.107256
5056	sensor_cilantro_1	19.52	66.58	67.11	1.48	6.60	949.36	433.19	2025-12-10 17:37:47.107743
5057	sensor_cilantro_2	19.24	66.01	68.78	1.59	6.44	1131.47	436.82	2025-12-10 17:37:47.108274
5058	sensor_rabano_1	20.80	70.53	71.07	1.81	6.41	866.63	440.20	2025-12-10 17:37:57.133555
5059	sensor_rabano_2	21.96	57.64	71.93	1.96	6.71	1168.04	405.46	2025-12-10 17:37:57.135785
5060	sensor_cilantro_1	22.48	68.55	69.28	1.65	6.72	1164.07	419.69	2025-12-10 17:37:57.136454
5061	sensor_cilantro_2	22.29	67.42	64.48	1.68	6.69	990.98	434.25	2025-12-10 17:37:57.136991
5062	sensor_rabano_1	22.06	66.05	79.32	1.68	6.46	916.49	411.64	2025-12-10 17:38:07.158929
5063	sensor_rabano_2	22.60	71.20	78.59	1.56	6.50	1016.26	432.52	2025-12-10 17:38:07.160436
5064	sensor_cilantro_1	21.27	72.30	71.30	1.94	6.77	1084.98	451.70	2025-12-10 17:38:07.160808
5065	sensor_cilantro_2	21.92	71.76	65.54	1.74	6.59	1005.48	453.36	2025-12-10 17:38:07.161233
5066	sensor_rabano_1	21.09	71.67	68.09	1.76	6.61	835.93	466.26	2025-12-10 17:38:17.189122
5067	sensor_rabano_2	23.43	57.20	64.91	1.44	6.68	995.89	481.75	2025-12-10 17:38:17.191092
5068	sensor_cilantro_1	21.23	69.44	74.26	1.63	6.45	948.67	420.73	2025-12-10 17:38:17.191653
5069	sensor_cilantro_2	22.81	68.71	66.15	1.85	6.73	809.21	433.40	2025-12-10 17:38:17.192168
5070	sensor_rabano_1	20.36	59.30	63.59	1.99	6.64	1023.61	453.81	2025-12-10 17:38:27.219241
5071	sensor_rabano_2	21.64	59.85	71.33	1.99	6.48	1144.58	450.53	2025-12-10 17:38:27.221007
5072	sensor_cilantro_1	20.22	71.65	66.51	1.94	6.78	887.60	408.25	2025-12-10 17:38:27.221593
5073	sensor_cilantro_2	19.23	63.70	72.26	1.55	6.47	893.88	482.39	2025-12-10 17:38:27.222092
5074	sensor_rabano_1	21.23	71.12	76.64	1.65	6.76	852.85	461.61	2025-12-10 17:38:37.249979
5075	sensor_rabano_2	20.90	71.55	74.72	1.71	6.48	808.75	486.16	2025-12-10 17:38:37.251942
5076	sensor_cilantro_1	22.80	66.51	73.54	1.71	6.53	977.47	461.98	2025-12-10 17:38:37.252562
5077	sensor_cilantro_2	20.14	70.06	72.54	1.59	6.67	921.54	478.42	2025-12-10 17:38:37.253823
5078	sensor_rabano_1	20.94	65.90	72.07	1.55	6.43	899.71	459.58	2025-12-10 17:38:47.273272
5079	sensor_rabano_2	22.91	58.79	73.10	1.63	6.71	1023.68	461.87	2025-12-10 17:38:47.274763
5080	sensor_cilantro_1	19.21	74.24	67.64	1.51	6.64	1119.35	471.94	2025-12-10 17:38:47.275244
5081	sensor_cilantro_2	22.60	63.32	61.67	1.57	6.67	910.63	491.72	2025-12-10 17:38:47.275568
5082	sensor_rabano_1	21.05	64.99	74.90	1.50	6.71	893.08	427.85	2025-12-10 17:38:57.294706
5083	sensor_rabano_2	20.20	72.82	76.04	1.87	6.79	1195.64	469.28	2025-12-10 17:38:57.296358
5084	sensor_cilantro_1	21.31	74.57	62.07	1.65	6.74	939.07	403.16	2025-12-10 17:38:57.29682
5085	sensor_cilantro_2	22.05	64.23	71.60	1.71	6.68	993.42	439.86	2025-12-10 17:38:57.297216
5086	sensor_rabano_1	20.48	59.70	79.33	1.41	6.48	1132.94	465.98	2025-12-10 17:39:07.322656
5087	sensor_rabano_2	20.51	61.92	62.09	1.46	6.65	986.17	411.13	2025-12-10 17:39:07.325214
5088	sensor_cilantro_1	20.03	65.58	64.22	1.73	6.65	1142.13	405.16	2025-12-10 17:39:07.325914
5089	sensor_cilantro_2	22.28	63.08	79.36	1.69	6.68	1189.61	427.88	2025-12-10 17:39:07.32662
5090	sensor_rabano_1	22.20	70.52	60.88	1.79	6.75	861.19	448.56	2025-12-10 17:39:17.559769
5091	sensor_rabano_2	22.27	68.85	66.31	1.77	6.71	956.82	499.86	2025-12-10 17:39:17.562122
5092	sensor_cilantro_1	19.91	66.81	64.76	1.51	6.59	1052.47	462.73	2025-12-10 17:39:17.562728
5093	sensor_cilantro_2	21.97	62.17	75.08	1.48	6.53	1122.18	413.22	2025-12-10 17:39:17.563266
5094	sensor_rabano_1	23.88	70.52	77.08	1.72	6.69	852.21	496.50	2025-12-10 17:39:27.586969
5095	sensor_rabano_2	20.28	58.59	74.71	1.78	6.45	1052.17	499.15	2025-12-10 17:39:27.588831
5096	sensor_cilantro_1	21.92	72.56	61.90	1.59	6.48	875.95	447.46	2025-12-10 17:39:27.589403
5097	sensor_cilantro_2	21.30	76.75	64.25	1.48	6.68	953.36	451.83	2025-12-10 17:39:27.589863
5098	sensor_rabano_1	21.04	70.93	72.54	1.56	6.48	970.40	469.55	2025-12-10 17:39:37.608469
5099	sensor_rabano_2	20.87	60.09	79.68	1.84	6.76	1132.08	455.56	2025-12-10 17:39:37.609826
5100	sensor_cilantro_1	21.54	74.66	78.48	1.51	6.40	1062.45	439.73	2025-12-10 17:39:37.610305
5101	sensor_cilantro_2	19.28	74.40	64.43	1.83	6.70	951.66	432.21	2025-12-10 17:39:37.610508
5102	sensor_rabano_1	22.86	62.73	76.31	1.51	6.76	1070.55	478.81	2025-12-10 17:39:47.633996
5103	sensor_rabano_2	20.97	63.84	76.24	1.72	6.71	1010.66	438.48	2025-12-10 17:39:47.636349
5104	sensor_cilantro_1	21.29	65.37	70.12	1.96	6.54	904.63	409.46	2025-12-10 17:39:47.636868
5105	sensor_cilantro_2	20.65	77.98	77.61	1.84	6.47	812.38	434.77	2025-12-10 17:39:47.637139
5106	sensor_rabano_1	23.02	61.46	74.28	1.52	6.54	1045.73	465.55	2025-12-10 17:39:57.660301
5107	sensor_rabano_2	22.23	64.14	78.23	1.48	6.75	804.61	447.48	2025-12-10 17:39:57.662531
5108	sensor_cilantro_1	22.75	69.80	79.33	1.64	6.58	1042.58	486.66	2025-12-10 17:39:57.66318
5109	sensor_cilantro_2	20.77	66.35	78.83	1.85	6.62	810.93	414.79	2025-12-10 17:39:57.663734
5110	sensor_rabano_1	21.16	69.71	76.18	1.48	6.57	1050.14	451.43	2025-12-10 17:40:07.689136
5111	sensor_rabano_2	20.73	71.07	66.91	1.99	6.44	1184.55	471.35	2025-12-10 17:40:07.690827
5112	sensor_cilantro_1	21.76	72.18	71.54	1.72	6.74	889.41	421.89	2025-12-10 17:40:07.691351
5113	sensor_cilantro_2	21.63	68.76	69.96	1.72	6.62	818.20	433.46	2025-12-10 17:40:07.691705
5114	sensor_rabano_1	21.77	70.09	72.43	1.82	6.53	1020.91	418.38	2025-12-10 17:40:17.714761
5115	sensor_rabano_2	22.77	61.90	67.02	1.76	6.56	967.12	458.87	2025-12-10 17:40:17.716406
5116	sensor_cilantro_1	19.86	66.73	66.59	1.75	6.79	906.57	464.41	2025-12-10 17:40:17.716909
5117	sensor_cilantro_2	22.96	73.87	68.97	1.94	6.70	1130.44	490.25	2025-12-10 17:40:17.7173
5118	sensor_rabano_1	23.90	65.99	63.92	1.65	6.79	1046.96	428.86	2025-12-10 17:40:27.738057
5119	sensor_rabano_2	21.10	61.34	64.88	1.69	6.45	906.48	488.92	2025-12-10 17:40:27.739899
5120	sensor_cilantro_1	21.23	62.07	63.61	1.52	6.41	1199.81	478.19	2025-12-10 17:40:27.740426
5121	sensor_cilantro_2	19.56	74.35	62.10	1.53	6.48	956.90	422.16	2025-12-10 17:40:27.74083
5122	sensor_rabano_1	20.69	64.30	69.93	1.71	6.76	1117.53	451.71	2025-12-10 17:40:37.765652
5123	sensor_rabano_2	20.77	62.17	67.75	1.48	6.77	905.84	440.62	2025-12-10 17:40:37.767893
5124	sensor_cilantro_1	22.71	69.60	67.02	1.73	6.65	938.49	401.50	2025-12-10 17:40:37.768649
5125	sensor_cilantro_2	22.75	72.13	78.01	1.68	6.68	1115.37	443.06	2025-12-10 17:40:37.769313
5126	sensor_rabano_1	23.91	63.04	73.58	1.46	6.50	812.87	499.49	2025-12-10 17:40:47.793345
5127	sensor_rabano_2	23.55	58.50	65.95	1.76	6.62	1107.71	454.63	2025-12-10 17:40:47.794785
5128	sensor_cilantro_1	20.61	66.42	68.85	1.41	6.44	1185.07	434.18	2025-12-10 17:40:47.795427
5129	sensor_cilantro_2	22.02	65.95	68.91	1.67	6.60	1114.22	453.91	2025-12-10 17:40:47.795856
5130	sensor_rabano_1	22.71	66.80	71.87	1.65	6.61	1055.00	422.08	2025-12-10 17:40:57.819524
5131	sensor_rabano_2	22.19	66.35	67.83	1.97	6.78	856.29	427.59	2025-12-10 17:40:57.821237
5132	sensor_cilantro_1	21.88	76.17	73.79	1.73	6.64	1182.67	495.67	2025-12-10 17:40:57.821655
5133	sensor_cilantro_2	20.63	66.60	68.72	1.65	6.76	931.72	453.58	2025-12-10 17:40:57.822104
5134	sensor_rabano_1	22.00	60.67	75.19	1.85	6.41	839.87	489.35	2025-12-10 17:41:07.845262
5135	sensor_rabano_2	22.10	67.59	78.29	1.67	6.42	1032.08	403.90	2025-12-10 17:41:07.846677
5136	sensor_cilantro_1	19.62	73.49	68.98	1.81	6.69	1191.57	429.32	2025-12-10 17:41:07.847112
5137	sensor_cilantro_2	19.24	68.59	79.95	1.96	6.60	1106.49	430.11	2025-12-10 17:41:07.847479
5138	sensor_rabano_1	22.29	72.95	62.05	1.84	6.55	969.83	463.58	2025-12-10 17:41:17.869207
5139	sensor_rabano_2	22.34	64.62	65.79	1.95	6.72	932.39	470.56	2025-12-10 17:41:17.870623
5140	sensor_cilantro_1	22.05	74.28	68.77	1.64	6.78	1118.14	424.66	2025-12-10 17:41:17.871149
5141	sensor_cilantro_2	19.55	73.92	67.21	1.76	6.66	1045.87	402.50	2025-12-10 17:41:17.871351
5142	sensor_rabano_1	23.46	61.81	62.28	1.43	6.58	1178.56	433.27	2025-12-10 17:41:27.892732
5143	sensor_rabano_2	20.00	58.28	67.03	1.70	6.69	882.72	433.27	2025-12-10 17:41:27.894199
5144	sensor_cilantro_1	21.72	65.53	73.84	1.58	6.60	1143.17	474.00	2025-12-10 17:41:27.894592
5145	sensor_cilantro_2	20.70	77.05	70.10	1.90	6.51	1085.78	498.36	2025-12-10 17:41:27.894918
5146	sensor_rabano_1	20.35	69.18	69.50	1.54	6.69	1150.27	453.99	2025-12-10 17:41:37.913317
5147	sensor_rabano_2	20.89	72.58	78.67	1.57	6.50	1158.48	431.50	2025-12-10 17:41:37.91462
5148	sensor_cilantro_1	22.07	63.77	62.29	1.70	6.47	944.39	449.54	2025-12-10 17:41:37.915019
5149	sensor_cilantro_2	22.44	66.80	60.42	1.92	6.61	1149.58	423.05	2025-12-10 17:41:37.915231
5150	sensor_rabano_1	20.25	71.36	74.68	1.68	6.52	1015.01	405.43	2025-12-10 17:41:47.941393
5151	sensor_rabano_2	22.73	60.01	70.37	1.58	6.70	803.40	427.56	2025-12-10 17:41:47.943259
5152	sensor_cilantro_1	20.68	67.90	66.83	1.58	6.56	1093.35	486.13	2025-12-10 17:41:47.943871
5153	sensor_cilantro_2	22.40	71.25	61.88	1.96	6.76	879.79	478.37	2025-12-10 17:41:47.944336
5154	sensor_rabano_1	20.55	57.37	69.75	1.56	6.71	1158.13	478.26	2025-12-10 17:41:57.965716
5155	sensor_rabano_2	20.07	72.19	63.12	1.66	6.71	1137.19	410.71	2025-12-10 17:41:57.967173
5156	sensor_cilantro_1	19.68	64.16	62.76	1.79	6.56	883.31	437.01	2025-12-10 17:41:57.967456
5157	sensor_cilantro_2	19.61	67.92	75.19	1.86	6.77	898.79	424.38	2025-12-10 17:41:57.967604
5158	sensor_rabano_1	22.84	66.22	60.26	1.61	6.41	1047.71	401.30	2025-12-10 17:42:07.99046
5159	sensor_rabano_2	22.47	67.54	65.45	1.80	6.42	1175.93	471.73	2025-12-10 17:42:07.992466
5160	sensor_cilantro_1	20.74	68.60	60.32	1.42	6.67	970.35	435.30	2025-12-10 17:42:07.992933
5161	sensor_cilantro_2	21.39	65.74	74.71	1.51	6.72	863.80	474.64	2025-12-10 17:42:07.993394
5162	sensor_rabano_1	21.25	68.54	74.49	1.64	6.69	990.27	436.22	2025-12-10 17:42:18.019275
5163	sensor_rabano_2	22.73	61.49	69.64	1.60	6.63	950.71	481.50	2025-12-10 17:42:18.020944
5164	sensor_cilantro_1	22.35	63.23	74.17	1.92	6.78	1119.34	451.93	2025-12-10 17:42:18.021496
5165	sensor_cilantro_2	20.77	74.61	74.99	1.97	6.53	873.43	401.17	2025-12-10 17:42:18.021958
5166	sensor_rabano_1	20.02	61.63	75.46	1.72	6.56	996.82	418.85	2025-12-10 17:42:28.044477
5167	sensor_rabano_2	20.51	68.91	63.47	1.92	6.76	1159.63	412.61	2025-12-10 17:42:28.046234
5168	sensor_cilantro_1	19.42	71.22	75.77	1.74	6.62	851.14	439.73	2025-12-10 17:42:28.046612
5169	sensor_cilantro_2	20.99	72.61	62.53	1.69	6.67	825.17	486.06	2025-12-10 17:42:28.046978
5170	sensor_rabano_1	23.90	71.50	68.36	1.73	6.62	998.00	488.57	2025-12-10 17:42:38.07099
5171	sensor_rabano_2	21.18	68.59	67.43	1.94	6.41	846.30	417.35	2025-12-10 17:42:38.072446
5172	sensor_cilantro_1	22.83	75.09	69.51	1.93	6.80	1113.01	423.81	2025-12-10 17:42:38.072899
5173	sensor_cilantro_2	21.70	70.66	72.92	1.76	6.79	1039.70	414.02	2025-12-10 17:42:38.073476
5174	sensor_rabano_1	20.58	57.33	77.50	1.70	6.77	1133.16	476.53	2025-12-10 17:42:48.095548
5175	sensor_rabano_2	23.11	70.25	61.65	1.57	6.65	1153.57	400.37	2025-12-10 17:42:48.096918
5176	sensor_cilantro_1	19.54	62.12	66.75	1.54	6.69	1021.41	415.31	2025-12-10 17:42:48.097232
5177	sensor_cilantro_2	22.99	70.19	79.00	1.66	6.41	1188.41	450.15	2025-12-10 17:42:48.0974
5178	sensor_rabano_1	20.15	58.51	68.21	1.80	6.51	1051.79	487.10	2025-12-10 17:42:58.126729
5179	sensor_rabano_2	21.67	65.04	60.40	1.61	6.79	1052.72	425.78	2025-12-10 17:42:58.12855
5180	sensor_cilantro_1	20.40	68.34	79.30	1.78	6.46	1070.54	466.23	2025-12-10 17:42:58.129165
5181	sensor_cilantro_2	19.42	68.06	67.34	1.42	6.41	890.68	415.62	2025-12-10 17:42:58.129669
5182	sensor_rabano_1	21.79	65.01	62.59	1.58	6.49	813.72	405.24	2025-12-10 17:43:08.156361
5183	sensor_rabano_2	22.93	69.19	71.74	1.90	6.41	803.39	457.01	2025-12-10 17:43:08.158306
5184	sensor_cilantro_1	20.01	67.91	74.30	1.48	6.62	975.97	449.43	2025-12-10 17:43:08.158837
5185	sensor_cilantro_2	22.17	70.46	62.22	1.54	6.52	820.05	482.40	2025-12-10 17:43:08.159335
5186	sensor_rabano_1	20.49	57.77	71.21	1.41	6.76	900.80	400.42	2025-12-10 17:43:18.183664
5187	sensor_rabano_2	23.67	68.90	79.41	1.91	6.72	833.20	447.84	2025-12-10 17:43:18.185353
5188	sensor_cilantro_1	19.38	63.39	62.61	2.00	6.46	1093.89	462.75	2025-12-10 17:43:18.185884
5189	sensor_cilantro_2	20.96	71.20	71.47	1.64	6.48	1106.35	438.98	2025-12-10 17:43:18.186655
5190	sensor_rabano_1	20.80	64.99	65.90	1.41	6.79	1137.18	411.88	2025-12-10 17:43:28.211912
5191	sensor_rabano_2	21.37	72.06	61.13	1.68	6.71	1037.55	427.94	2025-12-10 17:43:28.213898
5192	sensor_cilantro_1	19.48	69.86	66.46	1.78	6.50	807.37	481.72	2025-12-10 17:43:28.214654
5193	sensor_cilantro_2	22.13	63.17	77.81	1.73	6.71	918.98	417.08	2025-12-10 17:43:28.215043
5194	sensor_rabano_1	23.07	70.11	74.98	1.54	6.59	801.70	409.36	2025-12-10 17:43:38.237601
5195	sensor_rabano_2	23.65	64.56	61.70	1.82	6.62	920.88	424.60	2025-12-10 17:43:38.239221
5196	sensor_cilantro_1	21.14	66.83	70.73	1.55	6.73	971.44	415.53	2025-12-10 17:43:38.239671
5197	sensor_cilantro_2	20.97	66.56	73.73	1.98	6.77	806.45	463.70	2025-12-10 17:43:38.240007
5198	sensor_rabano_1	23.30	69.03	67.47	1.87	6.58	1119.27	498.87	2025-12-10 17:43:48.262953
5199	sensor_rabano_2	20.26	59.71	74.14	1.64	6.47	1110.98	445.60	2025-12-10 17:43:48.264551
5200	sensor_cilantro_1	22.58	63.07	66.13	1.68	6.66	808.04	442.85	2025-12-10 17:43:48.26497
5201	sensor_cilantro_2	20.81	69.01	72.86	1.75	6.67	1151.33	485.33	2025-12-10 17:43:48.265182
5202	sensor_rabano_1	22.31	60.58	69.51	1.90	6.43	1198.46	449.22	2025-12-10 17:43:58.284548
5203	sensor_rabano_2	21.58	60.02	75.94	1.48	6.40	846.76	417.19	2025-12-10 17:43:58.286102
5204	sensor_cilantro_1	21.22	75.04	71.94	1.56	6.51	832.46	488.97	2025-12-10 17:43:58.286508
5205	sensor_cilantro_2	22.40	62.99	73.00	1.86	6.61	1053.16	419.68	2025-12-10 17:43:58.28683
5206	sensor_rabano_1	23.74	63.31	63.41	1.97	6.77	1042.84	473.89	2025-12-10 17:44:08.308562
5207	sensor_rabano_2	22.04	61.79	75.37	1.61	6.79	805.97	489.49	2025-12-10 17:44:08.310415
5208	sensor_cilantro_1	22.36	69.15	65.81	1.49	6.65	959.85	452.75	2025-12-10 17:44:08.310914
5209	sensor_cilantro_2	20.74	65.88	73.78	1.80	6.73	1161.77	486.34	2025-12-10 17:44:08.311523
5239	sensor_rabano_1	22.84	64.97	64.98	1.89	6.60	126.11	404.53	2025-12-14 21:52:57.079063
5240	sensor_rabano_2	21.89	58.03	79.72	1.62	6.72	119.33	404.80	2025-12-14 21:52:57.094252
5241	sensor_cilantro_1	22.81	71.78	72.85	1.46	6.54	124.37	456.84	2025-12-14 21:52:57.094631
5242	sensor_cilantro_2	20.17	71.94	63.66	1.55	6.55	160.16	464.17	2025-12-14 21:52:57.094921
5243	sensor_rabano_1	21.18	72.85	66.35	1.89	6.64	71.50	470.65	2025-12-14 21:53:07.105381
5244	sensor_rabano_2	21.52	59.07	66.20	1.92	6.58	143.04	453.09	2025-12-14 21:53:07.106324
5245	sensor_cilantro_1	21.60	67.63	61.65	1.59	6.60	98.16	496.07	2025-12-14 21:53:07.106615
5246	sensor_cilantro_2	21.51	77.92	74.83	1.83	6.52	117.62	428.74	2025-12-14 21:53:07.106832
5247	sensor_rabano_1	21.35	63.33	66.77	1.70	6.66	70.15	402.01	2025-12-14 21:53:17.117785
5248	sensor_rabano_2	23.19	59.01	79.37	1.91	6.73	104.22	414.55	2025-12-14 21:53:17.118815
5249	sensor_cilantro_1	20.58	62.95	63.12	1.77	6.76	108.31	462.50	2025-12-14 21:53:17.119134
5250	sensor_cilantro_2	19.36	73.57	74.28	1.53	6.59	135.48	426.71	2025-12-14 21:53:17.119428
5251	sensor_rabano_1	20.68	72.50	77.40	1.65	6.71	149.05	468.79	2025-12-14 21:53:27.129897
5252	sensor_rabano_2	20.03	69.02	63.83	1.94	6.60	135.43	492.69	2025-12-14 21:53:27.130695
5253	sensor_cilantro_1	21.97	69.90	73.65	1.80	6.70	168.17	477.90	2025-12-14 21:53:27.130931
5254	sensor_cilantro_2	22.33	74.71	68.69	1.53	6.78	151.40	472.60	2025-12-14 21:53:27.1311
5255	sensor_rabano_1	22.92	58.87	63.23	1.92	6.46	138.41	481.39	2025-12-14 21:53:37.141778
5256	sensor_rabano_2	20.39	63.12	65.89	1.70	6.40	169.84	412.17	2025-12-14 21:53:37.142511
5257	sensor_cilantro_1	22.01	77.02	75.60	1.69	6.50	97.44	420.30	2025-12-14 21:53:37.142678
5258	sensor_cilantro_2	22.15	66.41	74.06	1.75	6.46	198.36	448.20	2025-12-14 21:53:37.142834
5259	sensor_rabano_1	22.10	65.90	74.62	1.55	6.40	141.00	481.06	2025-12-14 21:53:47.153534
5260	sensor_rabano_2	23.76	71.32	73.12	1.92	6.48	170.90	460.99	2025-12-14 21:53:47.15453
5261	sensor_cilantro_1	20.77	64.87	79.78	1.81	6.68	187.72	441.60	2025-12-14 21:53:47.154765
5262	sensor_cilantro_2	19.38	70.39	78.09	1.63	6.64	119.17	466.03	2025-12-14 21:53:47.154965
5263	sensor_rabano_1	21.31	58.73	65.62	1.97	6.64	161.49	498.29	2025-12-14 21:53:57.165635
5264	sensor_rabano_2	20.52	60.16	67.40	1.89	6.49	65.07	453.90	2025-12-14 21:53:57.166426
5265	sensor_cilantro_1	22.98	69.87	66.84	1.89	6.55	163.66	451.47	2025-12-14 21:53:57.166622
5266	sensor_cilantro_2	20.01	67.58	70.76	1.47	6.55	89.77	420.04	2025-12-14 21:53:57.166767
5267	sensor_rabano_1	21.71	70.74	76.62	1.47	6.44	100.72	468.03	2025-12-14 21:54:07.175321
5268	sensor_rabano_2	23.23	64.39	72.13	1.77	6.75	54.20	414.23	2025-12-14 21:54:07.176041
5269	sensor_cilantro_1	20.16	72.39	61.59	1.73	6.42	168.02	423.97	2025-12-14 21:54:07.17615
5270	sensor_cilantro_2	19.76	75.55	62.40	1.70	6.66	97.78	428.07	2025-12-14 21:54:07.17621
5271	sensor_rabano_1	21.33	58.23	79.61	1.41	6.66	175.52	412.68	2025-12-14 21:54:17.185716
5272	sensor_rabano_2	23.37	67.02	72.21	1.45	6.46	54.38	411.19	2025-12-14 21:54:17.186545
5273	sensor_cilantro_1	22.47	71.23	78.85	1.82	6.53	198.44	477.46	2025-12-14 21:54:17.18679
5274	sensor_cilantro_2	20.91	74.02	63.57	1.82	6.72	152.39	494.44	2025-12-14 21:54:17.186992
5275	sensor_rabano_1	21.77	71.26	70.47	1.71	6.59	120.92	455.75	2025-12-14 21:54:27.197779
5276	sensor_rabano_2	21.14	64.76	67.76	1.96	6.71	179.19	454.88	2025-12-14 21:54:27.198669
5277	sensor_cilantro_1	20.43	63.29	70.76	1.42	6.71	156.73	435.51	2025-12-14 21:54:27.198945
5278	sensor_cilantro_2	21.61	68.64	72.20	1.89	6.68	96.57	411.49	2025-12-14 21:54:27.199201
5279	sensor_rabano_1	20.08	69.27	78.25	1.63	6.59	177.86	486.10	2025-12-14 21:54:37.210027
5280	sensor_rabano_2	23.69	63.21	62.31	1.52	6.64	122.02	457.04	2025-12-14 21:54:37.210809
5281	sensor_cilantro_1	20.27	77.23	70.76	1.81	6.75	152.30	404.65	2025-12-14 21:54:37.210991
5282	sensor_cilantro_2	21.19	67.99	72.01	1.58	6.68	98.94	440.15	2025-12-14 21:54:37.211137
5283	sensor_rabano_1	22.30	61.79	65.08	1.70	6.66	115.50	410.30	2025-12-14 21:54:47.221932
5284	sensor_rabano_2	22.75	67.48	76.67	1.78	6.64	196.52	448.72	2025-12-14 21:54:47.222775
5285	sensor_cilantro_1	19.46	63.02	61.80	1.75	6.74	68.02	477.32	2025-12-14 21:54:47.223003
5286	sensor_cilantro_2	21.06	68.55	64.47	1.81	6.79	69.38	413.67	2025-12-14 21:54:47.223164
5287	sensor_rabano_1	20.62	59.24	76.55	1.82	6.46	110.70	405.64	2025-12-14 21:54:57.232881
5288	sensor_rabano_2	23.83	70.69	61.80	1.47	6.43	178.81	403.31	2025-12-14 21:54:57.233748
5289	sensor_cilantro_1	21.76	66.68	73.14	1.76	6.58	68.97	426.12	2025-12-14 21:54:57.233931
5290	sensor_cilantro_2	21.98	65.65	65.01	1.90	6.56	122.30	482.97	2025-12-14 21:54:57.23407
5291	sensor_rabano_1	21.13	68.05	69.15	1.76	6.41	152.20	474.62	2025-12-14 21:55:07.244894
5292	sensor_rabano_2	22.06	71.91	61.42	1.79	6.41	161.79	477.59	2025-12-14 21:55:07.24598
5293	sensor_cilantro_1	19.28	76.11	68.34	1.73	6.63	74.14	424.42	2025-12-14 21:55:07.246115
5294	sensor_cilantro_2	21.36	62.45	62.72	1.49	6.78	197.25	496.30	2025-12-14 21:55:07.246179
5295	sensor_rabano_1	22.10	62.30	61.14	1.73	6.64	131.87	487.38	2025-12-14 21:55:17.254767
5296	sensor_rabano_2	22.90	69.74	63.03	1.90	6.53	174.46	437.11	2025-12-14 21:55:17.255373
5297	sensor_cilantro_1	21.09	75.31	75.73	1.45	6.47	184.39	455.53	2025-12-14 21:55:17.25554
5298	sensor_cilantro_2	20.76	62.72	69.38	1.48	6.65	94.01	440.30	2025-12-14 21:55:17.255623
5299	sensor_rabano_1	20.50	60.75	75.18	1.44	6.67	167.18	496.92	2025-12-14 21:55:27.265839
5300	sensor_rabano_2	21.22	61.35	67.39	1.90	6.79	51.29	466.36	2025-12-14 21:55:27.266699
5301	sensor_cilantro_1	22.92	71.44	77.07	1.98	6.73	92.15	430.10	2025-12-14 21:55:27.266888
5302	sensor_cilantro_2	22.64	75.37	62.21	1.97	6.76	82.74	424.04	2025-12-14 21:55:27.267034
5303	sensor_rabano_1	23.29	57.89	78.25	1.78	6.74	180.12	492.93	2025-12-14 21:55:37.275111
5304	sensor_rabano_2	21.76	61.36	66.21	1.63	6.46	83.44	406.41	2025-12-14 21:55:37.275593
5305	sensor_cilantro_1	22.53	68.04	78.23	1.65	6.56	162.20	481.92	2025-12-14 21:55:37.275679
5306	sensor_cilantro_2	22.93	67.45	74.12	1.95	6.63	77.38	494.20	2025-12-14 21:55:37.276524
5307	sensor_rabano_1	21.31	63.08	73.66	1.95	6.52	135.13	429.89	2025-12-14 21:55:47.286858
5308	sensor_rabano_2	22.89	69.99	72.87	1.63	6.64	56.78	485.30	2025-12-14 21:55:47.287693
5309	sensor_cilantro_1	21.56	63.39	65.30	1.59	6.70	105.72	486.67	2025-12-14 21:55:47.287885
5310	sensor_cilantro_2	20.54	63.38	69.10	1.98	6.61	102.14	436.06	2025-12-14 21:55:47.288031
5311	sensor_rabano_1	21.52	64.61	71.74	1.80	6.56	77.09	448.79	2025-12-14 21:55:57.298765
5312	sensor_rabano_2	23.21	68.93	72.84	1.98	6.42	149.38	498.63	2025-12-14 21:55:57.299521
5313	sensor_cilantro_1	21.98	74.36	66.55	1.80	6.70	105.34	432.80	2025-12-14 21:55:57.299718
5314	sensor_cilantro_2	19.53	67.49	76.92	1.47	6.64	100.36	417.95	2025-12-14 21:55:57.299862
5315	sensor_rabano_1	22.81	60.46	62.26	1.71	6.75	121.00	477.47	2025-12-14 21:56:07.308668
5316	sensor_rabano_2	23.12	63.86	77.87	1.97	6.59	157.24	439.56	2025-12-14 21:56:07.30934
5317	sensor_cilantro_1	21.13	66.50	66.73	1.57	6.61	196.73	425.59	2025-12-14 21:56:07.309474
5318	sensor_cilantro_2	20.72	76.07	72.59	1.42	6.67	134.41	443.66	2025-12-14 21:56:07.309556
5319	sensor_rabano_1	22.58	66.29	73.63	1.69	6.44	64.89	489.92	2025-12-14 21:56:17.319213
5320	sensor_rabano_2	21.00	58.92	75.26	1.83	6.64	188.50	430.78	2025-12-14 21:56:17.319824
5321	sensor_cilantro_1	22.87	75.21	67.17	1.99	6.68	119.19	481.43	2025-12-14 21:56:17.319934
5322	sensor_cilantro_2	20.82	67.08	65.71	1.68	6.72	103.86	483.59	2025-12-14 21:56:17.319993
5323	sensor_rabano_1	21.87	59.20	79.74	1.47	6.80	101.95	418.72	2025-12-14 21:56:27.329737
5324	sensor_rabano_2	21.46	57.29	71.94	1.51	6.55	107.97	413.43	2025-12-14 21:56:27.33031
5325	sensor_cilantro_1	20.19	64.28	68.06	1.71	6.61	173.35	450.02	2025-12-14 21:56:27.330398
5326	sensor_cilantro_2	22.66	71.57	64.93	1.81	6.42	183.52	451.34	2025-12-14 21:56:27.330472
5327	sensor_rabano_1	20.41	66.70	75.69	1.72	6.65	110.54	417.95	2025-12-14 21:56:37.34091
5328	sensor_rabano_2	22.73	68.48	67.96	1.73	6.62	100.58	468.17	2025-12-14 21:56:37.341514
5329	sensor_cilantro_1	22.11	71.02	79.14	1.62	6.53	187.97	418.12	2025-12-14 21:56:37.341839
5330	sensor_cilantro_2	21.69	71.94	70.72	1.83	6.45	99.82	432.07	2025-12-14 21:56:37.342151
5331	sensor_rabano_1	22.61	59.41	73.56	1.42	6.60	152.79	489.90	2025-12-14 21:56:47.352309
5332	sensor_rabano_2	21.22	59.85	74.66	1.87	6.75	101.53	440.83	2025-12-14 21:56:47.353095
5333	sensor_cilantro_1	19.68	66.96	66.10	1.58	6.58	129.25	466.81	2025-12-14 21:56:47.353201
5334	sensor_cilantro_2	22.85	76.67	68.99	1.92	6.72	152.92	432.53	2025-12-14 21:56:47.353264
5335	sensor_rabano_1	23.61	59.29	64.77	1.52	6.53	86.35	498.40	2025-12-14 21:56:57.363706
5336	sensor_rabano_2	22.12	66.76	66.56	1.84	6.43	155.61	469.26	2025-12-14 21:56:57.364545
5337	sensor_cilantro_1	22.08	73.50	75.51	1.96	6.57	127.16	488.69	2025-12-14 21:56:57.364781
5338	sensor_cilantro_2	19.52	69.04	68.28	1.48	6.44	57.64	484.23	2025-12-14 21:56:57.36495
5339	sensor_rabano_1	20.89	61.75	74.46	1.63	6.76	115.77	413.91	2025-12-14 21:57:07.373332
5340	sensor_rabano_2	21.95	68.22	64.08	1.65	6.44	82.87	447.86	2025-12-14 21:57:07.374087
5341	sensor_cilantro_1	20.09	71.20	65.69	1.82	6.67	144.08	465.55	2025-12-14 21:57:07.374197
5342	sensor_cilantro_2	19.94	77.87	65.25	1.44	6.56	53.54	420.12	2025-12-14 21:57:07.374256
5343	sensor_rabano_1	23.15	69.54	60.07	1.69	6.55	129.94	480.63	2025-12-14 21:57:17.384682
5344	sensor_rabano_2	23.45	61.88	77.32	1.96	6.78	199.43	434.49	2025-12-14 21:57:17.385483
5345	sensor_cilantro_1	22.81	77.68	73.04	1.71	6.78	103.01	470.40	2025-12-14 21:57:17.385987
5346	sensor_cilantro_2	19.66	75.31	60.56	1.86	6.41	83.17	404.91	2025-12-14 21:57:17.386402
5347	sensor_rabano_1	23.41	71.72	61.92	1.94	6.58	61.07	491.08	2025-12-14 21:57:27.397498
5348	sensor_rabano_2	23.57	59.43	60.94	1.56	6.54	140.97	468.37	2025-12-14 21:57:27.398329
5349	sensor_cilantro_1	21.21	62.12	63.18	1.60	6.62	142.96	415.48	2025-12-14 21:57:27.398561
5350	sensor_cilantro_2	19.52	77.53	79.24	1.79	6.42	61.43	498.43	2025-12-14 21:57:27.398792
5351	sensor_rabano_1	22.75	64.41	67.04	1.78	6.55	159.15	464.78	2025-12-14 21:57:37.408188
5352	sensor_rabano_2	21.82	67.77	75.26	1.59	6.61	74.15	439.62	2025-12-14 21:57:37.408952
5353	sensor_cilantro_1	19.17	68.27	76.03	1.54	6.72	102.47	437.57	2025-12-14 21:57:37.40919
5354	sensor_cilantro_2	21.79	63.27	61.83	1.48	6.71	151.03	446.16	2025-12-14 21:57:37.409431
5355	sensor_rabano_1	20.18	60.19	72.62	1.75	6.59	186.34	400.63	2025-12-14 21:57:47.419375
5356	sensor_rabano_2	20.53	70.67	65.44	1.74	6.73	104.75	492.20	2025-12-14 21:57:47.420275
5357	sensor_cilantro_1	21.00	70.89	60.46	1.98	6.42	180.41	459.23	2025-12-14 21:57:47.420382
5358	sensor_cilantro_2	19.03	72.24	76.98	1.67	6.47	118.61	441.52	2025-12-14 21:57:47.420455
5359	sensor_rabano_1	20.72	57.21	60.46	1.61	6.80	126.41	447.11	2025-12-14 21:57:57.431366
5360	sensor_rabano_2	21.07	65.05	71.68	1.53	6.54	77.44	495.07	2025-12-14 21:57:57.43217
5361	sensor_cilantro_1	21.15	74.51	75.55	1.83	6.62	168.26	475.17	2025-12-14 21:57:57.43235
5362	sensor_cilantro_2	22.65	62.40	74.23	1.52	6.60	174.58	464.27	2025-12-14 21:57:57.432542
5363	sensor_rabano_1	23.07	64.85	74.32	1.80	6.78	73.56	428.99	2025-12-14 21:58:07.64045
5364	sensor_rabano_2	22.62	63.80	78.59	1.54	6.79	100.47	458.19	2025-12-14 21:58:07.641201
5365	sensor_cilantro_1	22.85	74.87	69.12	1.83	6.52	167.86	464.20	2025-12-14 21:58:07.641333
5366	sensor_cilantro_2	19.30	68.79	63.01	1.89	6.60	63.13	423.69	2025-12-14 21:58:07.641401
5367	sensor_rabano_1	20.31	66.57	75.37	1.54	6.41	183.87	458.37	2025-12-14 21:58:17.652356
5368	sensor_rabano_2	20.17	72.76	75.02	1.97	6.46	128.27	454.16	2025-12-14 21:58:17.653223
5369	sensor_cilantro_1	20.20	68.86	63.84	1.78	6.50	107.80	471.13	2025-12-14 21:58:17.65333
5370	sensor_cilantro_2	20.14	62.58	61.69	1.41	6.66	122.05	475.61	2025-12-14 21:58:17.653389
5371	sensor_rabano_1	23.32	69.36	63.37	1.47	6.56	75.28	446.71	2025-12-14 21:58:27.663567
5372	sensor_rabano_2	21.29	65.45	72.43	1.50	6.75	164.80	414.53	2025-12-14 21:58:27.664177
5373	sensor_cilantro_1	21.45	70.32	69.00	1.70	6.80	54.50	474.60	2025-12-14 21:58:27.664261
5374	sensor_cilantro_2	22.04	64.15	72.25	1.63	6.45	97.95	481.57	2025-12-14 21:58:27.664316
5375	sensor_rabano_1	20.50	70.82	78.91	1.89	6.68	120.02	431.83	2025-12-14 21:58:37.673555
5376	sensor_rabano_2	23.25	71.72	67.04	1.89	6.70	154.25	466.39	2025-12-14 21:58:37.674597
5377	sensor_cilantro_1	19.16	68.29	68.87	1.64	6.66	160.85	454.05	2025-12-14 21:58:37.674874
5378	sensor_cilantro_2	19.06	72.43	61.73	1.80	6.76	61.35	419.69	2025-12-14 21:58:37.675039
5379	sensor_rabano_1	20.96	57.10	78.59	1.51	6.55	128.79	491.64	2025-12-14 21:58:47.685773
5380	sensor_rabano_2	23.70	69.78	72.97	1.86	6.56	154.24	495.48	2025-12-14 21:58:47.686575
5381	sensor_cilantro_1	19.73	67.58	69.58	1.93	6.72	101.29	414.40	2025-12-14 21:58:47.686849
5382	sensor_cilantro_2	19.25	62.94	74.26	1.83	6.68	51.46	474.07	2025-12-14 21:58:47.687009
5383	sensor_rabano_1	21.29	61.87	79.59	1.75	6.43	130.34	485.06	2025-12-14 21:58:57.698253
5384	sensor_rabano_2	21.95	59.99	77.86	1.86	6.53	147.11	468.39	2025-12-14 21:58:57.699114
5385	sensor_cilantro_1	20.31	69.92	77.78	1.91	6.76	129.89	497.07	2025-12-14 21:58:57.699345
5386	sensor_cilantro_2	21.82	69.70	78.68	1.93	6.49	126.53	417.35	2025-12-14 21:58:57.699512
5387	sensor_rabano_1	22.65	68.88	73.34	1.42	6.67	118.78	476.35	2025-12-14 21:59:07.711109
5388	sensor_rabano_2	22.90	59.95	74.52	1.95	6.56	154.27	450.28	2025-12-14 21:59:07.711905
5389	sensor_cilantro_1	21.02	65.52	79.53	1.98	6.59	136.90	472.52	2025-12-14 21:59:07.712099
5390	sensor_cilantro_2	22.14	75.63	79.31	1.83	6.49	116.22	470.93	2025-12-14 21:59:07.71225
5391	sensor_rabano_1	22.54	61.49	75.28	1.72	6.71	122.66	409.74	2025-12-14 21:59:17.723184
5392	sensor_rabano_2	23.68	66.12	71.19	1.67	6.51	197.91	473.69	2025-12-14 21:59:17.724149
5393	sensor_cilantro_1	21.12	77.01	67.20	1.46	6.74	188.03	455.76	2025-12-14 21:59:17.724361
5394	sensor_cilantro_2	22.37	68.85	75.66	1.50	6.52	141.01	432.29	2025-12-14 21:59:17.724585
5395	sensor_rabano_1	23.48	58.93	65.46	1.87	6.66	191.95	494.08	2025-12-14 21:59:27.735198
5396	sensor_rabano_2	22.65	57.62	70.67	1.95	6.66	119.89	426.92	2025-12-14 21:59:27.736007
5397	sensor_cilantro_1	20.90	72.36	70.94	1.81	6.67	171.65	426.63	2025-12-14 21:59:27.736236
5398	sensor_cilantro_2	20.56	71.65	62.45	1.79	6.79	106.96	460.01	2025-12-14 21:59:27.736418
5399	sensor_rabano_1	21.63	63.76	73.60	1.48	6.76	66.88	484.05	2025-12-14 21:59:37.747556
5400	sensor_rabano_2	23.44	61.71	60.88	1.52	6.79	117.50	473.77	2025-12-14 21:59:37.748335
5401	sensor_cilantro_1	21.35	73.81	66.23	1.45	6.47	94.61	466.28	2025-12-14 21:59:37.748584
5402	sensor_cilantro_2	20.37	77.86	65.88	1.65	6.47	140.05	400.82	2025-12-14 21:59:37.748749
5403	sensor_rabano_1	22.60	66.22	75.09	1.59	6.53	79.89	443.11	2025-12-14 21:59:47.760206
5404	sensor_rabano_2	20.13	61.59	79.26	1.85	6.76	161.34	499.22	2025-12-14 21:59:47.761029
5405	sensor_cilantro_1	19.76	69.30	76.71	1.77	6.76	191.82	443.18	2025-12-14 21:59:47.761223
5406	sensor_cilantro_2	20.57	76.28	74.47	1.47	6.41	57.55	447.14	2025-12-14 21:59:47.761372
5407	sensor_rabano_1	22.21	69.84	77.23	1.50	6.80	177.62	470.33	2025-12-14 21:59:57.772494
5408	sensor_rabano_2	22.75	61.55	69.26	1.56	6.55	95.88	433.63	2025-12-14 21:59:57.773391
5409	sensor_cilantro_1	20.17	67.14	76.93	1.57	6.79	109.18	411.60	2025-12-14 21:59:57.773592
5410	sensor_cilantro_2	22.23	72.65	63.42	1.96	6.77	195.43	445.01	2025-12-14 21:59:57.773737
5411	sensor_rabano_1	23.34	66.61	68.04	1.45	6.62	105.99	452.88	2025-12-14 22:00:07.784381
5412	sensor_rabano_2	23.58	66.27	77.32	1.54	6.79	80.70	455.42	2025-12-14 22:00:07.78533
5413	sensor_cilantro_1	20.23	64.50	75.13	1.95	6.52	69.06	473.24	2025-12-14 22:00:07.785642
5414	sensor_cilantro_2	20.82	68.71	79.24	1.70	6.70	61.81	461.66	2025-12-14 22:00:07.785918
5415	sensor_rabano_1	21.06	71.15	74.17	1.85	6.71	181.93	476.68	2025-12-14 22:00:17.796648
5416	sensor_rabano_2	20.69	72.11	79.41	1.50	6.56	118.03	482.25	2025-12-14 22:00:17.797476
5417	sensor_cilantro_1	21.72	73.73	74.28	1.50	6.67	165.38	414.15	2025-12-14 22:00:17.797702
5418	sensor_cilantro_2	19.99	65.07	74.56	1.84	6.69	90.10	419.53	2025-12-14 22:00:17.797916
5419	sensor_rabano_1	23.31	72.54	68.31	1.76	6.73	68.42	425.94	2025-12-14 22:00:27.809376
5420	sensor_rabano_2	20.52	72.48	68.54	1.49	6.73	164.49	457.10	2025-12-14 22:00:27.810257
5421	sensor_cilantro_1	21.55	73.54	60.93	1.88	6.62	53.83	444.46	2025-12-14 22:00:27.810455
5422	sensor_cilantro_2	19.74	77.22	66.65	1.96	6.47	118.27	476.51	2025-12-14 22:00:27.810611
5423	sensor_rabano_1	22.54	68.54	68.07	1.44	6.67	82.69	459.22	2025-12-14 22:00:37.821489
5424	sensor_rabano_2	20.44	63.47	60.12	1.56	6.44	92.89	487.09	2025-12-14 22:00:37.822443
5425	sensor_cilantro_1	22.03	65.24	69.69	1.98	6.43	172.98	442.98	2025-12-14 22:00:37.82264
5426	sensor_cilantro_2	20.86	62.47	67.22	1.91	6.74	92.87	493.06	2025-12-14 22:00:37.822782
5427	sensor_rabano_1	21.21	69.91	68.58	2.00	6.68	154.24	489.14	2025-12-14 22:00:47.833806
5428	sensor_rabano_2	23.76	70.31	73.95	1.74	6.68	144.04	484.31	2025-12-14 22:00:47.834782
5429	sensor_cilantro_1	20.63	69.36	66.81	1.49	6.50	149.53	400.65	2025-12-14 22:00:47.835029
5430	sensor_cilantro_2	21.65	62.29	73.45	1.99	6.65	109.40	496.29	2025-12-14 22:00:47.835238
5431	sensor_rabano_1	21.26	60.69	79.82	1.78	6.45	190.83	411.82	2025-12-14 22:00:57.845424
5432	sensor_rabano_2	21.92	62.85	63.19	1.83	6.43	110.48	418.96	2025-12-14 22:00:57.846187
5433	sensor_cilantro_1	21.87	62.03	72.48	1.71	6.77	56.91	470.38	2025-12-14 22:00:57.846363
5434	sensor_cilantro_2	22.48	68.52	69.79	1.83	6.78	133.55	403.16	2025-12-14 22:00:57.846514
5435	sensor_rabano_1	21.60	64.39	68.32	2.00	6.70	125.76	439.68	2025-12-14 22:01:07.857435
5436	sensor_rabano_2	22.53	65.71	70.44	1.67	6.48	73.40	469.04	2025-12-14 22:01:07.858311
5437	sensor_cilantro_1	21.93	75.09	60.45	1.70	6.71	125.26	494.07	2025-12-14 22:01:07.858562
5438	sensor_cilantro_2	21.31	64.88	71.05	1.91	6.71	192.91	433.15	2025-12-14 22:01:07.858761
5439	sensor_rabano_1	21.91	67.39	75.63	1.68	6.41	107.00	493.19	2025-12-14 22:01:17.869446
5440	sensor_rabano_2	22.59	72.84	61.25	1.66	6.68	59.26	466.47	2025-12-14 22:01:17.870419
5441	sensor_cilantro_1	19.69	71.12	71.40	1.89	6.54	93.06	408.43	2025-12-14 22:01:17.870725
5442	sensor_cilantro_2	21.18	70.26	63.45	2.00	6.62	117.49	408.92	2025-12-14 22:01:17.87108
5443	sensor_rabano_1	23.25	64.68	66.76	1.84	6.78	177.43	440.76	2025-12-14 22:01:27.882261
5444	sensor_rabano_2	23.23	66.38	67.55	1.83	6.58	59.36	402.67	2025-12-14 22:01:27.883042
5445	sensor_cilantro_1	21.57	67.25	76.77	1.56	6.61	189.68	471.70	2025-12-14 22:01:27.883221
5446	sensor_cilantro_2	22.30	73.64	67.25	1.48	6.65	183.19	499.42	2025-12-14 22:01:27.88336
5447	sensor_rabano_1	22.68	71.69	72.42	1.60	6.66	185.03	451.32	2025-12-14 22:01:37.894234
5448	sensor_rabano_2	23.76	67.68	67.10	1.45	6.59	117.06	438.42	2025-12-14 22:01:37.895227
5449	sensor_cilantro_1	20.03	66.70	67.74	1.95	6.75	199.91	470.80	2025-12-14 22:01:37.895407
5450	sensor_cilantro_2	19.25	66.78	67.10	1.64	6.43	196.47	430.48	2025-12-14 22:01:37.895691
5451	sensor_rabano_1	21.32	64.47	71.52	1.92	6.79	185.76	488.42	2025-12-14 22:01:47.905027
5452	sensor_rabano_2	20.17	68.82	69.91	1.99	6.47	189.43	468.78	2025-12-14 22:01:47.9055
5453	sensor_cilantro_1	19.07	75.84	62.76	1.64	6.48	115.22	438.91	2025-12-14 22:01:47.905668
5454	sensor_cilantro_2	21.85	74.90	72.94	1.69	6.72	177.20	472.87	2025-12-14 22:01:47.905731
5455	sensor_rabano_1	20.03	61.63	66.18	1.87	6.58	182.47	453.54	2025-12-14 22:01:57.913335
5456	sensor_rabano_2	20.19	60.26	75.31	1.63	6.53	184.42	464.62	2025-12-14 22:01:57.913974
5457	sensor_cilantro_1	19.33	65.21	67.89	1.85	6.73	117.89	453.97	2025-12-14 22:01:57.914083
5458	sensor_cilantro_2	21.34	67.63	70.82	1.88	6.52	184.07	491.42	2025-12-14 22:01:57.914146
5459	sensor_rabano_1	20.72	69.54	77.24	1.99	6.40	90.93	400.01	2025-12-14 22:02:07.921779
5460	sensor_rabano_2	21.79	72.99	78.61	1.74	6.69	166.02	464.17	2025-12-14 22:02:07.922297
5461	sensor_cilantro_1	21.32	76.57	65.21	1.72	6.54	95.16	479.29	2025-12-14 22:02:07.922383
5462	sensor_cilantro_2	20.97	75.36	76.82	1.67	6.43	78.06	441.58	2025-12-14 22:02:07.922445
5463	sensor_rabano_1	20.02	70.17	68.83	1.95	6.43	141.70	463.58	2025-12-14 22:02:17.929637
5464	sensor_rabano_2	23.71	68.51	66.02	1.93	6.75	143.45	452.68	2025-12-14 22:02:17.930447
5465	sensor_cilantro_1	19.88	75.70	63.87	1.49	6.65	184.52	426.88	2025-12-14 22:02:17.930652
5466	sensor_cilantro_2	20.22	70.60	69.53	1.87	6.62	122.86	430.70	2025-12-14 22:02:17.930792
5467	sensor_rabano_1	20.01	70.45	78.12	1.67	6.73	141.34	440.40	2025-12-14 22:02:27.940495
5468	sensor_rabano_2	20.29	58.29	60.62	1.91	6.63	135.01	474.70	2025-12-14 22:02:27.941012
5469	sensor_cilantro_1	19.07	67.93	64.55	1.47	6.41	198.91	440.23	2025-12-14 22:02:27.941132
5470	sensor_cilantro_2	19.44	69.20	76.89	1.53	6.64	152.17	446.24	2025-12-14 22:02:27.941212
5471	sensor_rabano_1	20.24	57.61	72.00	1.55	6.45	132.18	498.00	2025-12-14 22:02:37.952463
5472	sensor_rabano_2	20.64	71.74	63.46	1.76	6.66	199.36	470.97	2025-12-14 22:02:37.953211
5473	sensor_cilantro_1	22.14	76.52	75.98	1.40	6.62	101.33	415.68	2025-12-14 22:02:37.953354
5474	sensor_cilantro_2	21.85	72.43	65.29	1.87	6.75	149.60	460.17	2025-12-14 22:02:37.953459
5475	sensor_rabano_1	21.92	60.60	60.64	1.90	6.49	70.84	492.21	2025-12-14 22:02:47.963303
5476	sensor_rabano_2	23.36	57.19	62.15	1.77	6.79	96.36	463.06	2025-12-14 22:02:47.964241
5477	sensor_cilantro_1	22.31	77.52	62.18	1.43	6.49	142.59	426.43	2025-12-14 22:02:47.964444
5478	sensor_cilantro_2	22.99	68.70	71.21	1.51	6.61	110.60	400.67	2025-12-14 22:02:47.964607
5479	sensor_rabano_1	21.71	64.06	64.16	1.85	6.77	173.70	435.83	2025-12-14 22:02:57.97437
5480	sensor_rabano_2	20.53	58.44	79.09	1.81	6.53	109.74	483.59	2025-12-14 22:02:57.975174
5481	sensor_cilantro_1	20.55	72.66	79.51	1.98	6.72	169.31	489.30	2025-12-14 22:02:57.975284
5482	sensor_cilantro_2	22.61	62.10	71.47	1.42	6.78	192.25	431.95	2025-12-14 22:02:57.975343
5483	sensor_rabano_1	23.09	61.89	66.19	1.44	6.41	64.74	432.69	2025-12-14 22:03:08.053174
5484	sensor_rabano_2	23.55	60.17	74.69	1.54	6.57	177.30	452.93	2025-12-14 22:03:08.053983
5485	sensor_cilantro_1	19.83	72.43	75.66	1.78	6.40	184.62	436.91	2025-12-14 22:03:08.054177
5486	sensor_cilantro_2	21.36	71.18	72.23	1.54	6.54	85.94	452.26	2025-12-14 22:03:08.054326
5487	sensor_rabano_1	20.71	61.38	66.69	1.45	6.47	78.48	406.61	2025-12-14 22:03:18.063783
5488	sensor_rabano_2	20.58	66.46	70.71	1.51	6.68	125.18	487.35	2025-12-14 22:03:18.064667
5489	sensor_cilantro_1	21.47	67.17	65.26	1.87	6.62	78.15	444.32	2025-12-14 22:03:18.064925
5490	sensor_cilantro_2	22.50	67.50	73.85	1.97	6.67	123.87	469.07	2025-12-14 22:03:18.065133
5491	sensor_rabano_1	21.05	59.30	78.50	1.49	6.68	61.62	429.28	2025-12-14 22:03:28.075443
5492	sensor_rabano_2	22.31	65.32	65.37	1.48	6.76	59.74	414.69	2025-12-14 22:03:28.076261
5493	sensor_cilantro_1	20.35	74.89	64.50	1.98	6.52	130.87	426.89	2025-12-14 22:03:28.076465
5494	sensor_cilantro_2	20.88	67.89	64.99	1.75	6.68	101.52	480.31	2025-12-14 22:03:28.076626
5495	sensor_rabano_1	23.71	64.94	65.08	1.84	6.66	126.34	428.10	2025-12-14 22:03:38.086949
5496	sensor_rabano_2	23.90	69.87	78.72	1.51	6.72	76.06	436.98	2025-12-14 22:03:38.087711
5497	sensor_cilantro_1	19.90	74.98	61.20	1.52	6.72	104.42	487.11	2025-12-14 22:03:38.087891
5498	sensor_cilantro_2	22.14	76.23	65.27	1.78	6.59	76.58	435.28	2025-12-14 22:03:38.088033
5499	sensor_rabano_1	22.44	71.22	77.89	1.42	6.68	197.10	436.58	2025-12-14 22:03:48.099712
5500	sensor_rabano_2	20.63	57.05	74.61	1.42	6.70	157.37	424.19	2025-12-14 22:03:48.100547
5501	sensor_cilantro_1	19.89	75.09	73.61	1.89	6.69	116.32	486.43	2025-12-14 22:03:48.10075
5502	sensor_cilantro_2	22.84	70.91	64.92	1.57	6.74	188.67	411.77	2025-12-14 22:03:48.100901
5503	sensor_rabano_1	23.86	59.62	79.55	1.54	6.74	91.06	487.32	2025-12-14 22:03:58.111865
5504	sensor_rabano_2	21.92	69.69	75.49	1.98	6.79	193.79	435.33	2025-12-14 22:03:58.112816
5505	sensor_cilantro_1	19.37	72.68	77.84	1.48	6.68	130.25	443.73	2025-12-14 22:03:58.113017
5506	sensor_cilantro_2	19.22	72.80	71.43	1.90	6.56	69.01	416.40	2025-12-14 22:03:58.113164
5507	sensor_rabano_1	23.41	61.70	68.52	1.92	6.49	134.23	415.16	2025-12-14 22:04:08.123852
5508	sensor_rabano_2	23.58	65.29	73.32	1.99	6.41	93.93	477.98	2025-12-14 22:04:08.124598
5509	sensor_cilantro_1	20.42	72.69	61.54	1.58	6.78	186.74	436.32	2025-12-14 22:04:08.12478
5510	sensor_cilantro_2	22.68	64.54	68.77	1.64	6.76	124.01	412.68	2025-12-14 22:04:08.124924
5511	sensor_rabano_1	22.64	70.24	79.16	1.83	6.41	187.17	419.57	2025-12-14 22:04:18.136113
5512	sensor_rabano_2	22.59	69.22	65.02	1.96	6.63	102.78	454.98	2025-12-14 22:04:18.137316
5513	sensor_cilantro_1	19.70	71.89	71.16	1.83	6.40	135.61	487.17	2025-12-14 22:04:18.137763
5514	sensor_cilantro_2	19.59	73.93	77.71	1.65	6.48	154.86	442.06	2025-12-14 22:04:18.137991
5515	sensor_rabano_1	21.07	59.56	61.75	1.98	6.42	71.64	454.05	2025-12-14 22:04:28.14953
5516	sensor_rabano_2	23.71	57.50	68.60	1.56	6.66	143.67	454.72	2025-12-14 22:04:28.150435
5517	sensor_cilantro_1	20.01	65.44	67.58	1.64	6.63	176.05	458.21	2025-12-14 22:04:28.150738
5518	sensor_cilantro_2	22.09	66.68	63.50	1.52	6.72	170.46	409.23	2025-12-14 22:04:28.150941
5519	sensor_rabano_1	22.79	62.59	68.55	1.82	6.47	129.07	456.19	2025-12-14 22:04:38.161806
5520	sensor_rabano_2	22.33	70.78	62.78	1.78	6.42	195.43	404.75	2025-12-14 22:04:38.16334
5521	sensor_cilantro_1	20.49	64.45	66.32	1.63	6.64	93.05	439.31	2025-12-14 22:04:38.163874
5522	sensor_cilantro_2	22.09	67.28	62.46	1.63	6.56	91.59	447.02	2025-12-14 22:04:38.164205
5523	sensor_rabano_1	22.99	63.15	61.08	1.64	6.58	75.15	448.95	2025-12-14 22:04:48.175243
5524	sensor_rabano_2	20.49	69.44	75.30	1.52	6.59	199.00	494.86	2025-12-14 22:04:48.17611
5525	sensor_cilantro_1	19.30	62.42	76.32	1.41	6.46	139.85	458.77	2025-12-14 22:04:48.176221
5526	sensor_cilantro_2	21.81	72.04	66.91	1.46	6.65	135.05	403.69	2025-12-14 22:04:48.17628
5527	sensor_rabano_1	23.32	59.88	69.35	1.70	6.66	59.61	437.87	2025-12-14 22:04:58.1857
5528	sensor_rabano_2	22.19	57.40	78.54	1.98	6.53	170.98	426.69	2025-12-14 22:04:58.186333
5529	sensor_cilantro_1	21.32	65.68	70.14	1.41	6.72	157.60	454.05	2025-12-14 22:04:58.186423
5530	sensor_cilantro_2	22.04	69.33	75.83	1.83	6.41	132.58	473.92	2025-12-14 22:04:58.186486
5531	sensor_rabano_1	20.77	57.90	60.57	1.87	6.77	83.22	466.28	2025-12-14 22:05:08.196814
5532	sensor_rabano_2	20.81	59.48	63.67	1.69	6.57	187.63	482.53	2025-12-14 22:05:08.197361
5533	sensor_cilantro_1	22.33	68.41	71.22	1.84	6.74	192.62	422.84	2025-12-14 22:05:08.197464
5534	sensor_cilantro_2	20.96	63.99	73.32	1.60	6.47	119.12	499.03	2025-12-14 22:05:08.197526
5535	sensor_rabano_1	23.45	71.37	73.25	1.48	6.66	92.89	405.33	2025-12-14 22:05:18.208381
5536	sensor_rabano_2	22.91	62.00	75.85	1.71	6.63	70.95	458.45	2025-12-14 22:05:18.209246
5537	sensor_cilantro_1	19.12	66.69	71.31	1.75	6.66	158.39	473.66	2025-12-14 22:05:18.209352
5538	sensor_cilantro_2	22.78	63.66	74.65	1.94	6.62	179.05	445.37	2025-12-14 22:05:18.209421
5539	sensor_rabano_1	23.56	59.91	74.19	1.89	6.72	63.27	463.73	2025-12-14 22:05:28.219671
5540	sensor_rabano_2	23.94	61.45	64.72	1.48	6.75	129.99	405.25	2025-12-14 22:05:28.220569
5541	sensor_cilantro_1	22.67	74.24	60.28	1.52	6.75	146.09	460.10	2025-12-14 22:05:28.220754
5542	sensor_cilantro_2	22.55	75.21	63.90	1.79	6.68	166.37	458.90	2025-12-14 22:05:28.220901
5543	sensor_rabano_1	23.67	63.45	73.24	1.83	6.72	94.17	400.37	2025-12-14 22:05:38.231541
5544	sensor_rabano_2	22.99	61.17	77.54	1.55	6.45	178.46	448.36	2025-12-14 22:05:38.232399
5545	sensor_cilantro_1	21.22	71.15	71.20	1.65	6.73	62.69	466.62	2025-12-14 22:05:38.232651
5546	sensor_cilantro_2	19.21	62.73	74.15	1.95	6.77	129.98	498.13	2025-12-14 22:05:38.232826
5547	sensor_rabano_1	21.88	66.81	78.85	1.97	6.50	119.56	446.38	2025-12-14 22:05:48.243721
5548	sensor_rabano_2	22.18	71.14	76.37	1.85	6.44	104.09	449.90	2025-12-14 22:05:48.244611
5549	sensor_cilantro_1	20.42	75.29	75.28	1.80	6.69	62.35	411.62	2025-12-14 22:05:48.244847
5550	sensor_cilantro_2	22.64	70.86	78.34	1.88	6.51	59.47	416.90	2025-12-14 22:05:48.244999
5551	sensor_rabano_1	23.02	69.38	77.35	1.87	6.79	183.61	457.83	2025-12-14 22:05:58.253371
5552	sensor_rabano_2	20.55	57.68	72.50	1.75	6.68	168.78	460.22	2025-12-14 22:05:58.253976
5553	sensor_cilantro_1	20.06	77.00	64.81	1.59	6.68	91.22	411.31	2025-12-14 22:05:58.254072
5554	sensor_cilantro_2	21.12	74.73	70.67	1.54	6.77	114.05	454.08	2025-12-14 22:05:58.254128
5555	sensor_rabano_1	23.06	69.28	73.50	1.78	6.69	190.31	413.30	2025-12-14 22:06:08.264105
5556	sensor_rabano_2	23.12	63.28	75.11	1.93	6.68	199.93	483.58	2025-12-14 22:06:08.265018
5557	sensor_cilantro_1	20.36	75.81	76.11	1.70	6.63	147.18	448.52	2025-12-14 22:06:08.265219
5558	sensor_cilantro_2	20.93	71.25	65.50	2.00	6.62	141.18	466.97	2025-12-14 22:06:08.265379
5559	sensor_rabano_1	22.55	66.38	64.22	1.59	6.63	65.78	436.98	2025-12-14 22:06:18.276072
5560	sensor_rabano_2	23.94	57.52	64.80	1.68	6.54	153.20	460.46	2025-12-14 22:06:18.276847
5561	sensor_cilantro_1	21.40	73.19	68.53	1.46	6.75	161.64	493.24	2025-12-14 22:06:18.277034
5562	sensor_cilantro_2	19.64	65.35	72.93	1.77	6.40	164.37	476.87	2025-12-14 22:06:18.277193
5563	sensor_rabano_1	21.99	59.35	67.05	1.67	6.59	133.24	401.68	2025-12-14 22:06:28.288674
5564	sensor_rabano_2	23.68	60.40	78.75	1.87	6.69	125.39	462.99	2025-12-14 22:06:28.289506
5565	sensor_cilantro_1	22.54	74.42	78.76	1.75	6.72	122.09	421.84	2025-12-14 22:06:28.289704
5566	sensor_cilantro_2	20.18	71.46	79.21	1.61	6.72	167.86	459.22	2025-12-14 22:06:28.289847
5567	sensor_rabano_1	21.14	63.99	65.11	1.76	6.48	198.68	417.62	2025-12-14 22:06:38.299454
5568	sensor_rabano_2	22.64	71.40	60.23	1.98	6.43	181.70	465.49	2025-12-14 22:06:38.299961
5569	sensor_cilantro_1	20.47	77.59	66.91	1.94	6.70	175.75	467.50	2025-12-14 22:06:38.300049
5570	sensor_cilantro_2	22.49	73.65	65.98	1.89	6.40	56.87	444.39	2025-12-14 22:06:38.300114
5571	sensor_rabano_1	21.67	70.81	64.58	1.82	6.67	187.70	414.39	2025-12-14 22:06:48.310505
5572	sensor_rabano_2	21.12	58.03	75.77	1.88	6.65	198.58	459.18	2025-12-14 22:06:48.311234
5573	sensor_cilantro_1	22.54	75.94	65.70	1.53	6.78	125.38	430.88	2025-12-14 22:06:48.311461
5574	sensor_cilantro_2	19.48	73.87	68.93	1.84	6.71	69.07	428.23	2025-12-14 22:06:48.311666
5575	sensor_rabano_1	23.21	72.13	63.75	1.70	6.70	152.96	443.94	2025-12-14 22:06:58.321814
5576	sensor_rabano_2	22.08	59.46	70.23	1.87	6.59	160.92	464.58	2025-12-14 22:06:58.32246
5577	sensor_cilantro_1	21.85	76.20	60.99	1.62	6.61	60.17	436.82	2025-12-14 22:06:58.322664
5578	sensor_cilantro_2	19.86	68.84	75.60	1.48	6.64	135.49	491.75	2025-12-14 22:06:58.322918
5579	sensor_rabano_1	20.49	72.37	79.51	1.60	6.62	146.20	479.03	2025-12-14 22:07:08.332919
5580	sensor_rabano_2	21.56	57.73	66.33	1.58	6.59	76.56	455.78	2025-12-14 22:07:08.333685
5581	sensor_cilantro_1	20.20	77.82	71.67	1.85	6.55	60.23	431.47	2025-12-14 22:07:08.333871
5582	sensor_cilantro_2	22.10	73.85	68.78	1.94	6.60	134.41	457.31	2025-12-14 22:07:08.334018
5583	sensor_rabano_1	23.19	66.59	64.37	1.98	6.47	170.18	429.84	2025-12-14 22:07:18.345214
5584	sensor_rabano_2	23.79	60.23	79.90	1.81	6.66	141.93	473.46	2025-12-14 22:07:18.346055
5585	sensor_cilantro_1	22.03	77.49	76.86	1.98	6.44	101.09	403.59	2025-12-14 22:07:18.346245
5586	sensor_cilantro_2	20.98	71.53	69.27	1.43	6.61	72.14	424.48	2025-12-14 22:07:18.346395
5587	sensor_rabano_1	20.41	62.89	68.86	1.72	6.79	104.12	443.48	2025-12-14 22:07:28.356365
5588	sensor_rabano_2	22.68	66.40	79.40	1.97	6.57	137.89	448.72	2025-12-14 22:07:28.357108
5589	sensor_cilantro_1	20.50	65.44	69.96	1.82	6.47	58.05	443.27	2025-12-14 22:07:28.357285
5590	sensor_cilantro_2	20.53	62.35	62.39	2.00	6.49	154.25	415.01	2025-12-14 22:07:28.357429
5591	sensor_rabano_1	22.76	70.83	69.82	1.48	6.47	73.87	484.19	2025-12-14 22:07:38.370385
5592	sensor_rabano_2	23.93	64.34	68.46	1.88	6.65	197.19	453.43	2025-12-14 22:07:38.371362
5593	sensor_cilantro_1	20.99	75.73	63.96	1.74	6.42	91.67	462.38	2025-12-14 22:07:38.371728
5594	sensor_cilantro_2	19.68	75.29	66.21	1.61	6.52	136.75	475.64	2025-12-14 22:07:38.37199
5595	sensor_rabano_1	21.04	58.12	73.34	1.45	6.42	180.25	446.12	2025-12-14 22:07:48.385555
5596	sensor_rabano_2	22.97	68.53	76.41	1.88	6.43	152.86	489.54	2025-12-14 22:07:48.386634
5597	sensor_cilantro_1	22.56	62.23	70.42	1.42	6.68	94.59	472.14	2025-12-14 22:07:48.386981
5598	sensor_cilantro_2	21.54	68.15	63.54	1.45	6.68	74.09	494.88	2025-12-14 22:07:48.38724
5599	sensor_rabano_1	20.68	69.99	73.22	1.60	6.63	110.14	452.90	2025-12-14 22:07:58.398773
5600	sensor_rabano_2	20.87	70.65	62.02	1.98	6.65	72.35	416.79	2025-12-14 22:07:58.399993
5601	sensor_cilantro_1	19.88	65.48	70.50	1.43	6.65	62.73	442.11	2025-12-14 22:07:58.400208
5602	sensor_cilantro_2	20.30	66.19	76.49	1.55	6.52	159.90	418.53	2025-12-14 22:07:58.400376
5603	sensor_rabano_1	21.90	66.28	76.15	1.73	6.60	60.55	432.58	2025-12-14 22:08:08.475673
5604	sensor_rabano_2	20.90	63.77	62.02	1.94	6.43	127.97	453.74	2025-12-14 22:08:08.47648
5605	sensor_cilantro_1	19.05	77.22	77.55	1.86	6.53	173.87	493.56	2025-12-14 22:08:08.476682
5606	sensor_cilantro_2	22.10	75.91	61.33	1.97	6.51	170.23	405.06	2025-12-14 22:08:08.476928
5607	sensor_rabano_1	22.70	69.51	78.10	1.86	6.50	168.66	492.55	2025-12-14 22:08:18.496558
5608	sensor_rabano_2	23.88	60.34	76.48	1.78	6.41	169.48	407.85	2025-12-14 22:08:18.497445
5609	sensor_cilantro_1	23.00	73.07	73.01	1.93	6.59	197.10	425.23	2025-12-14 22:08:18.4977
5610	sensor_cilantro_2	19.09	68.43	73.11	1.96	6.47	143.70	431.55	2025-12-14 22:08:18.497852
5611	sensor_rabano_1	21.05	64.91	68.78	1.62	6.48	156.19	452.32	2025-12-14 22:08:28.507912
5612	sensor_rabano_2	23.94	59.36	68.25	1.64	6.49	126.33	487.08	2025-12-14 22:08:28.508676
5613	sensor_cilantro_1	19.46	65.94	60.20	1.85	6.62	54.29	413.70	2025-12-14 22:08:28.508809
5614	sensor_cilantro_2	22.63	68.51	77.09	1.81	6.79	84.48	495.78	2025-12-14 22:08:28.508889
5615	sensor_rabano_1	23.32	65.52	63.72	1.88	6.74	110.26	442.96	2025-12-14 22:08:38.524312
5616	sensor_rabano_2	22.74	66.22	71.86	1.97	6.43	64.13	425.52	2025-12-14 22:08:38.525269
5617	sensor_cilantro_1	19.27	69.42	63.48	1.69	6.53	111.80	429.31	2025-12-14 22:08:38.525554
5618	sensor_cilantro_2	20.86	70.86	79.01	1.44	6.50	196.09	492.40	2025-12-14 22:08:38.525795
5619	sensor_rabano_1	21.98	70.82	78.36	1.91	6.66	54.38	466.37	2025-12-14 22:08:48.537882
5620	sensor_rabano_2	22.54	70.20	68.37	1.90	6.56	65.92	474.81	2025-12-14 22:08:48.538867
5621	sensor_cilantro_1	20.05	66.50	78.22	1.84	6.75	82.84	410.42	2025-12-14 22:08:48.539095
5622	sensor_cilantro_2	22.25	69.99	62.13	1.80	6.43	166.95	427.41	2025-12-14 22:08:48.539269
5623	sensor_rabano_1	22.50	69.41	66.36	1.65	6.56	189.57	490.16	2025-12-14 22:08:58.551179
5624	sensor_rabano_2	21.98	66.40	60.29	1.67	6.41	198.92	481.56	2025-12-14 22:08:58.551831
5625	sensor_cilantro_1	22.62	71.20	70.12	1.77	6.65	129.32	467.17	2025-12-14 22:08:58.551938
5626	sensor_cilantro_2	19.30	63.40	74.09	1.70	6.63	134.09	488.54	2025-12-14 22:08:58.552009
5627	sensor_rabano_1	21.46	71.72	63.72	1.47	6.63	153.92	402.40	2025-12-14 22:09:08.564139
5628	sensor_rabano_2	21.72	57.70	70.98	1.54	6.62	168.56	438.27	2025-12-14 22:09:08.564893
5629	sensor_cilantro_1	20.96	66.41	63.28	1.48	6.79	166.49	465.69	2025-12-14 22:09:08.565077
5630	sensor_cilantro_2	21.84	63.45	78.15	1.50	6.76	172.81	421.43	2025-12-14 22:09:08.565226
5631	sensor_rabano_1	21.70	69.98	67.82	1.98	6.64	120.59	470.26	2025-12-14 22:09:18.579822
5632	sensor_rabano_2	23.58	70.07	66.07	1.73	6.76	179.48	414.67	2025-12-14 22:09:18.580824
5633	sensor_cilantro_1	19.58	72.29	76.66	1.58	6.53	116.45	449.62	2025-12-14 22:09:18.581108
5634	sensor_cilantro_2	22.70	70.22	75.55	1.47	6.79	62.29	498.97	2025-12-14 22:09:18.581321
5635	sensor_rabano_1	21.18	64.08	73.75	1.64	6.58	145.72	431.59	2025-12-14 22:09:28.590925
5636	sensor_rabano_2	22.01	63.59	69.00	1.52	6.55	84.01	481.96	2025-12-14 22:09:28.591757
5637	sensor_cilantro_1	22.66	75.18	78.04	1.95	6.55	89.88	423.81	2025-12-14 22:09:28.591936
5638	sensor_cilantro_2	22.75	69.76	73.59	1.49	6.77	157.92	404.87	2025-12-14 22:09:28.592077
5639	sensor_rabano_1	21.52	63.87	60.71	1.50	6.58	190.41	465.53	2025-12-14 22:09:38.602002
5640	sensor_rabano_2	21.22	71.93	71.45	1.42	6.51	147.61	475.87	2025-12-14 22:09:38.60278
5641	sensor_cilantro_1	20.01	65.13	67.02	1.75	6.47	80.10	431.93	2025-12-14 22:09:38.60301
5642	sensor_cilantro_2	21.75	76.17	69.69	1.84	6.68	158.07	415.99	2025-12-14 22:09:38.60317
5643	sensor_rabano_1	20.69	63.41	62.84	1.82	6.48	52.75	496.36	2025-12-14 22:09:48.615062
5644	sensor_rabano_2	21.24	59.70	68.66	1.83	6.66	75.85	489.64	2025-12-14 22:09:48.615993
5645	sensor_cilantro_1	19.52	70.82	62.03	1.64	6.75	164.40	426.27	2025-12-14 22:09:48.616235
5646	sensor_cilantro_2	19.27	71.30	71.46	1.64	6.60	117.88	428.92	2025-12-14 22:09:48.616499
5647	sensor_rabano_1	23.19	70.69	72.21	1.59	6.72	114.59	438.10	2025-12-14 22:09:58.626297
5648	sensor_rabano_2	21.34	70.81	77.86	1.85	6.71	152.55	494.64	2025-12-14 22:09:58.626823
5649	sensor_cilantro_1	22.01	65.49	67.81	1.53	6.42	140.80	457.01	2025-12-14 22:09:58.626911
5650	sensor_cilantro_2	19.51	62.35	78.60	1.42	6.70	187.00	455.63	2025-12-14 22:09:58.626971
5651	sensor_rabano_1	20.79	70.67	68.27	1.62	6.57	71.84	461.07	2025-12-14 22:10:08.637251
5652	sensor_rabano_2	22.98	72.03	68.19	1.75	6.65	139.27	422.66	2025-12-14 22:10:08.638008
5653	sensor_cilantro_1	22.81	75.11	68.37	1.50	6.75	68.39	416.79	2025-12-14 22:10:08.638187
5654	sensor_cilantro_2	22.45	63.15	74.66	1.91	6.79	111.81	445.45	2025-12-14 22:10:08.638326
5655	sensor_rabano_1	20.32	68.32	65.42	1.53	6.50	58.34	419.39	2025-12-14 22:10:18.674642
5656	sensor_rabano_2	20.66	59.07	66.26	1.92	6.79	185.39	484.30	2025-12-14 22:10:18.67559
5657	sensor_cilantro_1	20.42	72.25	76.65	1.48	6.78	66.31	417.37	2025-12-14 22:10:18.675691
5658	sensor_cilantro_2	22.88	66.13	61.03	1.74	6.52	163.86	469.47	2025-12-14 22:10:18.675801
5659	sensor_rabano_1	23.44	69.35	74.10	2.00	6.64	141.00	459.09	2025-12-14 22:10:28.686799
5660	sensor_rabano_2	22.29	70.69	75.49	1.89	6.48	76.41	406.73	2025-12-14 22:10:28.687516
5661	sensor_cilantro_1	19.82	62.87	61.80	1.45	6.75	135.24	453.60	2025-12-14 22:10:28.687773
5662	sensor_cilantro_2	22.72	70.34	75.28	1.90	6.63	141.63	450.12	2025-12-14 22:10:28.687933
5663	sensor_rabano_1	23.23	69.56	65.93	1.53	6.67	188.46	421.46	2025-12-14 22:10:38.697968
5664	sensor_rabano_2	20.75	68.76	63.30	1.71	6.49	187.58	420.87	2025-12-14 22:10:38.698901
5665	sensor_cilantro_1	19.63	71.60	65.07	1.44	6.77	62.66	481.46	2025-12-14 22:10:38.699139
5666	sensor_cilantro_2	19.76	68.26	76.75	2.00	6.67	145.50	439.62	2025-12-14 22:10:38.699343
5667	sensor_rabano_1	22.36	57.53	72.97	1.70	6.46	60.97	485.62	2025-12-14 22:10:48.710018
5668	sensor_rabano_2	22.54	61.94	63.13	1.95	6.73	81.86	479.65	2025-12-14 22:10:48.71084
5669	sensor_cilantro_1	19.74	68.17	76.24	1.66	6.74	58.39	472.04	2025-12-14 22:10:48.711071
5670	sensor_cilantro_2	20.56	72.90	74.40	1.87	6.71	83.00	406.18	2025-12-14 22:10:48.711234
5671	sensor_rabano_1	20.29	58.62	73.24	1.89	6.76	149.67	468.65	2025-12-14 22:10:58.721634
5672	sensor_rabano_2	21.44	57.39	68.50	1.49	6.69	102.14	438.14	2025-12-14 22:10:58.722356
5673	sensor_cilantro_1	19.76	68.25	67.44	1.90	6.74	88.18	450.82	2025-12-14 22:10:58.722534
5674	sensor_cilantro_2	19.35	62.88	62.01	1.79	6.77	72.50	498.32	2025-12-14 22:10:58.722692
5675	sensor_rabano_1	23.43	70.48	66.08	1.90	6.53	175.06	431.99	2025-12-14 22:11:08.734203
5676	sensor_rabano_2	22.46	71.33	69.75	1.59	6.58	104.30	413.04	2025-12-14 22:11:08.735454
5677	sensor_cilantro_1	19.58	74.45	76.56	1.79	6.61	129.84	462.80	2025-12-14 22:11:08.735927
5678	sensor_cilantro_2	20.58	69.75	77.30	1.62	6.46	92.27	436.08	2025-12-14 22:11:08.736266
5679	sensor_rabano_1	23.63	71.23	79.47	1.63	6.40	100.08	418.81	2025-12-14 22:11:18.746265
5680	sensor_rabano_2	21.41	69.02	70.85	1.90	6.53	166.53	439.95	2025-12-14 22:11:18.747233
5681	sensor_cilantro_1	21.37	66.40	69.66	1.78	6.74	163.58	414.65	2025-12-14 22:11:18.74741
5682	sensor_cilantro_2	22.30	70.80	70.46	1.91	6.43	66.68	449.03	2025-12-14 22:11:18.747603
5683	sensor_rabano_1	23.91	58.50	71.41	1.81	6.44	110.87	482.59	2025-12-14 22:11:28.75877
5684	sensor_rabano_2	20.33	57.09	69.90	1.40	6.63	95.74	445.16	2025-12-14 22:11:28.759602
5685	sensor_cilantro_1	21.59	71.05	73.28	1.58	6.47	184.70	447.82	2025-12-14 22:11:28.759864
5686	sensor_cilantro_2	21.08	62.03	64.82	1.43	6.68	192.09	419.85	2025-12-14 22:11:28.759954
5687	sensor_rabano_1	22.22	66.13	68.46	1.44	6.51	153.26	499.02	2025-12-14 22:11:38.770744
5688	sensor_rabano_2	20.19	60.02	79.22	1.79	6.72	123.86	415.98	2025-12-14 22:11:38.771547
5689	sensor_cilantro_1	19.37	69.76	73.40	1.91	6.60	70.12	414.76	2025-12-14 22:11:38.771731
5690	sensor_cilantro_2	22.12	74.30	77.55	1.51	6.56	135.75	486.66	2025-12-14 22:11:38.771874
5691	sensor_rabano_1	20.19	68.87	77.51	1.98	6.77	161.67	488.30	2025-12-14 22:11:48.782971
5692	sensor_rabano_2	21.34	63.35	67.58	1.95	6.47	69.23	473.98	2025-12-14 22:11:48.784081
5693	sensor_cilantro_1	20.67	74.07	65.44	2.00	6.55	138.15	471.25	2025-12-14 22:11:48.784379
5694	sensor_cilantro_2	20.27	70.91	68.89	1.46	6.79	196.93	490.42	2025-12-14 22:11:48.784646
5695	sensor_rabano_1	20.26	71.78	60.86	1.50	6.70	141.12	460.71	2025-12-14 22:11:58.795554
5696	sensor_rabano_2	22.75	60.78	71.67	1.48	6.69	181.01	408.84	2025-12-14 22:11:58.796345
5697	sensor_cilantro_1	19.26	67.32	75.35	1.94	6.58	115.75	444.78	2025-12-14 22:11:58.796594
5698	sensor_cilantro_2	19.39	64.36	76.73	1.61	6.71	148.39	420.64	2025-12-14 22:11:58.796793
5699	sensor_rabano_1	22.88	63.37	64.07	1.93	6.53	147.97	427.85	2025-12-14 22:12:08.814098
5700	sensor_rabano_2	23.74	59.00	61.58	1.94	6.57	189.35	442.88	2025-12-14 22:12:08.814988
5701	sensor_cilantro_1	22.88	63.37	69.84	1.60	6.62	164.67	415.25	2025-12-14 22:12:08.81518
5702	sensor_cilantro_2	20.59	68.18	76.12	1.57	6.63	65.61	487.97	2025-12-14 22:12:08.815332
5703	sensor_rabano_1	21.31	63.90	78.76	1.67	6.56	144.25	470.54	2025-12-14 22:12:18.82607
5704	sensor_rabano_2	23.00	62.52	79.00	1.68	6.68	81.37	458.52	2025-12-14 22:12:18.826923
5705	sensor_cilantro_1	19.92	69.54	75.97	1.61	6.62	140.17	441.43	2025-12-14 22:12:18.827121
5706	sensor_cilantro_2	19.84	66.70	73.90	1.58	6.63	161.53	498.40	2025-12-14 22:12:18.827274
5707	sensor_rabano_1	21.71	62.48	62.30	1.57	6.77	60.86	445.72	2025-12-14 22:12:28.838185
5708	sensor_rabano_2	20.46	58.38	68.43	1.96	6.45	158.60	426.45	2025-12-14 22:12:28.838759
5709	sensor_cilantro_1	19.75	77.77	70.46	1.99	6.46	108.75	479.98	2025-12-14 22:12:28.838858
5710	sensor_cilantro_2	21.58	77.86	64.70	1.70	6.76	106.79	470.42	2025-12-14 22:12:28.838914
5711	sensor_rabano_1	23.16	70.00	70.21	1.41	6.60	77.07	465.58	2025-12-14 22:12:38.848244
5712	sensor_rabano_2	22.92	67.29	69.87	1.40	6.41	81.22	479.72	2025-12-14 22:12:38.849024
5713	sensor_cilantro_1	22.08	77.84	72.82	1.70	6.74	164.76	412.68	2025-12-14 22:12:38.849166
5714	sensor_cilantro_2	19.15	64.29	60.30	1.56	6.56	169.55	429.16	2025-12-14 22:12:38.84923
5715	sensor_rabano_1	21.62	61.90	68.78	1.89	6.70	80.22	448.08	2025-12-14 22:12:48.860755
5716	sensor_rabano_2	22.63	66.80	74.84	1.63	6.47	87.50	465.29	2025-12-14 22:12:48.861553
5717	sensor_cilantro_1	20.83	71.65	78.17	1.77	6.75	65.09	458.53	2025-12-14 22:12:48.861742
5718	sensor_cilantro_2	21.37	70.66	60.82	1.88	6.61	102.29	496.05	2025-12-14 22:12:48.86189
5719	sensor_rabano_1	22.28	57.92	67.72	1.74	6.69	88.04	452.57	2025-12-14 22:12:58.873672
5720	sensor_rabano_2	21.77	65.96	63.92	1.52	6.73	170.90	460.26	2025-12-14 22:12:58.874503
5721	sensor_cilantro_1	21.73	63.13	78.24	1.96	6.59	160.26	460.80	2025-12-14 22:12:58.874703
5722	sensor_cilantro_2	20.58	70.66	65.31	1.89	6.40	98.30	410.60	2025-12-14 22:12:58.874857
5723	sensor_rabano_1	22.05	70.15	62.71	1.55	6.55	87.18	497.25	2025-12-14 22:13:08.948539
5724	sensor_rabano_2	20.44	66.68	66.60	1.65	6.62	173.57	463.44	2025-12-14 22:13:08.949407
5725	sensor_cilantro_1	19.32	73.82	61.35	1.94	6.48	98.57	465.86	2025-12-14 22:13:08.949718
5726	sensor_cilantro_2	20.77	74.98	60.38	1.79	6.67	147.68	420.67	2025-12-14 22:13:08.949926
5727	sensor_rabano_1	20.52	65.96	62.08	1.60	6.41	111.52	482.70	2025-12-14 22:13:18.9617
5728	sensor_rabano_2	23.70	59.20	62.76	1.65	6.51	159.68	414.13	2025-12-14 22:13:18.962528
5729	sensor_cilantro_1	20.75	70.98	70.11	1.43	6.54	130.69	487.61	2025-12-14 22:13:18.962764
5730	sensor_cilantro_2	22.04	65.03	73.95	1.60	6.77	109.42	411.21	2025-12-14 22:13:18.962963
5731	sensor_rabano_1	22.97	62.01	60.42	1.46	6.66	121.69	458.17	2025-12-14 22:13:28.974721
5732	sensor_rabano_2	20.72	64.20	73.81	1.54	6.68	194.24	441.66	2025-12-14 22:13:28.975474
5733	sensor_cilantro_1	21.75	74.75	68.21	1.83	6.78	137.92	487.04	2025-12-14 22:13:28.975706
5734	sensor_cilantro_2	22.94	64.06	74.87	1.89	6.73	107.63	414.63	2025-12-14 22:13:28.975871
5735	sensor_rabano_1	20.77	57.57	71.48	1.81	6.47	61.28	486.33	2025-12-14 22:13:38.986852
5736	sensor_rabano_2	23.29	66.42	68.71	1.87	6.69	70.75	438.55	2025-12-14 22:13:38.987501
5737	sensor_cilantro_1	20.45	66.73	61.60	1.43	6.76	76.38	419.22	2025-12-14 22:13:38.987693
5738	sensor_cilantro_2	19.11	74.30	72.28	1.51	6.78	99.20	490.28	2025-12-14 22:13:38.987853
5739	sensor_rabano_1	22.38	68.42	75.57	1.51	6.46	194.29	428.97	2025-12-14 22:13:48.996199
5740	sensor_rabano_2	21.36	72.47	70.40	1.56	6.64	175.46	496.75	2025-12-14 22:13:48.996859
5741	sensor_cilantro_1	21.21	72.97	69.18	1.95	6.65	120.31	458.40	2025-12-14 22:13:48.997036
5742	sensor_cilantro_2	21.72	74.82	68.76	1.92	6.45	185.20	457.87	2025-12-14 22:13:48.997119
5743	sensor_rabano_1	20.55	61.02	67.27	1.77	6.68	192.50	463.07	2025-12-14 22:13:59.008405
5744	sensor_rabano_2	22.56	68.07	76.52	1.92	6.67	132.16	446.63	2025-12-14 22:13:59.009115
5745	sensor_cilantro_1	20.58	77.87	65.74	1.67	6.56	117.40	457.44	2025-12-14 22:13:59.009215
5746	sensor_cilantro_2	21.62	71.21	70.13	1.44	6.59	61.06	482.18	2025-12-14 22:13:59.009273
5747	sensor_rabano_1	21.82	71.25	73.32	1.55	6.75	150.34	498.70	2025-12-14 22:14:09.01731
5748	sensor_rabano_2	23.72	60.39	61.40	1.64	6.70	110.98	444.46	2025-12-14 22:14:09.017823
5749	sensor_cilantro_1	21.28	72.97	68.03	1.73	6.74	138.20	407.56	2025-12-14 22:14:09.017906
5750	sensor_cilantro_2	22.89	65.59	70.69	1.60	6.68	190.21	446.98	2025-12-14 22:14:09.017963
5751	sensor_rabano_1	21.36	66.87	66.50	1.63	6.61	124.58	422.01	2025-12-14 22:14:19.028212
5752	sensor_rabano_2	22.56	72.63	64.02	1.72	6.70	64.42	408.26	2025-12-14 22:14:19.029045
5753	sensor_cilantro_1	20.25	76.26	69.61	1.77	6.63	101.11	474.04	2025-12-14 22:14:19.029224
5754	sensor_cilantro_2	19.72	74.09	79.63	1.58	6.54	129.73	403.78	2025-12-14 22:14:19.029365
5755	sensor_rabano_1	21.29	72.02	79.50	1.71	6.72	88.11	464.19	2025-12-14 22:14:29.040073
5756	sensor_rabano_2	20.61	63.82	62.94	1.76	6.57	96.84	431.86	2025-12-14 22:14:29.041103
5757	sensor_cilantro_1	20.83	75.22	61.28	1.61	6.68	120.78	408.32	2025-12-14 22:14:29.041336
5758	sensor_cilantro_2	22.06	67.66	79.77	1.48	6.51	131.68	474.40	2025-12-14 22:14:29.041507
5759	sensor_rabano_1	21.09	62.25	78.22	1.59	6.57	52.91	466.60	2025-12-14 22:14:39.052368
5760	sensor_rabano_2	22.72	62.47	65.89	1.45	6.63	97.35	477.99	2025-12-14 22:14:39.053272
5761	sensor_cilantro_1	21.64	70.56	70.58	1.43	6.67	109.19	463.41	2025-12-14 22:14:39.053529
5762	sensor_cilantro_2	19.64	77.36	73.29	1.47	6.77	167.00	471.42	2025-12-14 22:14:39.05377
5763	sensor_rabano_1	21.81	67.18	70.46	1.67	6.67	199.47	482.66	2025-12-14 22:14:49.065294
5764	sensor_rabano_2	22.87	71.86	63.90	1.75	6.64	139.08	453.03	2025-12-14 22:14:49.06621
5765	sensor_cilantro_1	19.22	66.20	61.54	1.79	6.45	195.83	469.52	2025-12-14 22:14:49.066406
5766	sensor_cilantro_2	19.90	72.59	71.01	1.97	6.75	142.04	465.63	2025-12-14 22:14:49.066641
5767	sensor_rabano_1	21.99	58.00	79.22	1.94	6.66	92.54	497.82	2025-12-14 22:14:59.077331
5768	sensor_rabano_2	21.93	67.74	60.88	1.59	6.56	80.66	417.49	2025-12-14 22:14:59.078539
5769	sensor_cilantro_1	21.25	68.26	69.96	1.48	6.76	92.30	445.53	2025-12-14 22:14:59.078816
5770	sensor_cilantro_2	21.99	63.22	69.93	1.55	6.77	73.11	435.46	2025-12-14 22:14:59.079011
5771	sensor_rabano_1	23.50	72.75	78.29	1.45	6.49	87.21	408.78	2025-12-14 22:15:09.090192
5772	sensor_rabano_2	20.22	68.57	69.68	1.56	6.68	107.16	495.81	2025-12-14 22:15:09.091345
5773	sensor_cilantro_1	22.93	73.09	75.79	1.83	6.61	120.68	465.02	2025-12-14 22:15:09.091619
5774	sensor_cilantro_2	21.02	63.67	62.93	1.41	6.48	82.94	468.08	2025-12-14 22:15:09.091839
5775	sensor_rabano_1	23.70	60.96	60.31	1.94	6.61	196.73	468.98	2025-12-14 22:15:19.103439
5776	sensor_rabano_2	22.51	64.31	62.46	1.93	6.40	176.15	407.14	2025-12-14 22:15:19.104321
5777	sensor_cilantro_1	22.66	77.99	78.16	1.48	6.77	161.73	475.90	2025-12-14 22:15:19.104579
5778	sensor_cilantro_2	20.73	69.59	61.99	1.84	6.49	173.44	428.26	2025-12-14 22:15:19.104778
5779	sensor_rabano_1	23.35	67.89	78.40	1.58	6.49	148.14	480.45	2025-12-14 22:15:29.116184
5780	sensor_rabano_2	22.76	69.78	68.37	1.55	6.48	52.18	424.77	2025-12-14 22:15:29.117049
5781	sensor_cilantro_1	20.51	76.57	60.51	1.67	6.43	78.87	414.84	2025-12-14 22:15:29.117304
5782	sensor_cilantro_2	22.86	74.82	66.46	1.85	6.79	114.76	453.29	2025-12-14 22:15:29.117517
5783	sensor_rabano_1	21.58	68.20	77.22	1.58	6.65	126.98	499.54	2025-12-14 22:15:39.132054
5784	sensor_rabano_2	20.05	58.56	73.53	1.49	6.49	114.52	436.19	2025-12-14 22:15:39.133458
5785	sensor_cilantro_1	20.22	76.38	67.48	1.51	6.59	69.85	435.35	2025-12-14 22:15:39.133788
5786	sensor_cilantro_2	22.70	75.09	77.49	1.44	6.69	59.84	491.82	2025-12-14 22:15:39.134016
5787	sensor_rabano_1	22.50	58.29	66.61	1.46	6.65	95.40	492.76	2025-12-14 22:15:49.145352
5788	sensor_rabano_2	20.30	65.43	67.08	1.92	6.44	56.14	406.87	2025-12-14 22:15:49.146264
5789	sensor_cilantro_1	19.61	76.79	67.14	1.49	6.68	184.94	495.66	2025-12-14 22:15:49.146395
5790	sensor_cilantro_2	21.45	75.04	71.74	1.60	6.68	163.41	477.13	2025-12-14 22:15:49.146556
5791	sensor_rabano_1	20.19	59.84	72.76	1.47	6.71	82.15	442.79	2025-12-14 22:15:59.156818
5792	sensor_rabano_2	21.38	70.46	77.61	1.84	6.72	103.95	470.65	2025-12-14 22:15:59.157635
5793	sensor_cilantro_1	19.94	77.43	73.46	1.87	6.44	125.99	492.94	2025-12-14 22:15:59.157872
5794	sensor_cilantro_2	19.24	66.49	75.81	1.43	6.40	107.82	424.07	2025-12-14 22:15:59.158034
5795	sensor_rabano_1	21.03	69.38	78.95	1.69	6.77	124.76	468.43	2025-12-14 22:16:09.169261
5796	sensor_rabano_2	20.61	60.42	77.11	1.87	6.72	70.76	418.63	2025-12-14 22:16:09.170065
5797	sensor_cilantro_1	21.19	63.80	67.31	1.96	6.70	110.08	402.44	2025-12-14 22:16:09.170253
5798	sensor_cilantro_2	19.76	69.80	72.43	1.64	6.56	110.06	404.57	2025-12-14 22:16:09.1704
5799	sensor_rabano_1	20.94	57.28	62.42	1.48	6.71	197.02	449.81	2025-12-14 22:16:19.179537
5800	sensor_rabano_2	23.38	58.44	69.36	1.82	6.74	65.81	461.62	2025-12-14 22:16:19.180418
5801	sensor_cilantro_1	20.83	71.12	61.07	1.89	6.79	155.83	448.68	2025-12-14 22:16:19.180512
5802	sensor_cilantro_2	21.98	72.39	60.82	1.92	6.79	53.33	478.04	2025-12-14 22:16:19.18057
5803	sensor_rabano_1	20.55	68.90	67.75	1.67	6.65	191.40	478.10	2025-12-14 22:16:29.191134
5804	sensor_rabano_2	21.94	61.96	79.18	1.72	6.64	120.05	442.96	2025-12-14 22:16:29.191925
5805	sensor_cilantro_1	21.40	68.96	60.90	1.73	6.49	155.23	471.34	2025-12-14 22:16:29.192119
5806	sensor_cilantro_2	20.31	72.73	69.06	2.00	6.55	180.92	451.54	2025-12-14 22:16:29.192268
5807	sensor_rabano_1	21.36	59.61	73.04	1.55	6.52	130.19	400.20	2025-12-14 22:16:39.203305
5808	sensor_rabano_2	23.46	59.37	79.59	1.56	6.71	197.57	416.11	2025-12-14 22:16:39.204177
5809	sensor_cilantro_1	21.35	64.64	73.03	1.89	6.43	185.81	433.63	2025-12-14 22:16:39.204364
5810	sensor_cilantro_2	19.81	62.70	78.57	1.83	6.61	100.76	429.44	2025-12-14 22:16:39.204521
5811	sensor_rabano_1	22.33	69.61	68.25	1.59	6.44	89.11	446.80	2025-12-14 22:16:49.215406
5812	sensor_rabano_2	22.23	62.41	68.88	1.95	6.44	155.92	445.20	2025-12-14 22:16:49.216307
5813	sensor_cilantro_1	21.44	77.04	62.11	1.79	6.71	91.85	409.75	2025-12-14 22:16:49.216552
5814	sensor_cilantro_2	21.05	68.87	64.28	1.69	6.65	150.54	442.68	2025-12-14 22:16:49.216719
5815	sensor_rabano_1	22.89	59.39	60.45	1.96	6.52	66.15	462.97	2025-12-14 22:16:59.225393
5816	sensor_rabano_2	20.04	69.89	72.87	1.62	6.50	152.52	405.68	2025-12-14 22:16:59.226524
5817	sensor_cilantro_1	21.49	67.56	67.45	1.53	6.60	157.81	429.12	2025-12-14 22:16:59.226746
5818	sensor_cilantro_2	20.60	65.78	75.63	1.81	6.55	110.30	480.45	2025-12-14 22:16:59.226944
5819	sensor_rabano_1	22.38	63.02	66.05	1.54	6.73	89.43	497.74	2025-12-14 22:17:09.237946
5820	sensor_rabano_2	21.86	69.54	71.71	1.70	6.74	187.26	472.40	2025-12-14 22:17:09.238602
5821	sensor_cilantro_1	19.28	66.26	63.91	1.55	6.60	114.36	442.85	2025-12-14 22:17:09.238843
5822	sensor_cilantro_2	21.79	66.76	65.33	1.69	6.51	59.31	479.07	2025-12-14 22:17:09.239001
5823	sensor_rabano_1	23.80	68.59	65.23	1.41	6.69	136.10	426.01	2025-12-14 22:17:19.246985
5824	sensor_rabano_2	23.47	67.15	68.86	1.61	6.62	174.22	487.79	2025-12-14 22:17:19.247471
5825	sensor_cilantro_1	19.77	66.53	73.59	1.81	6.63	73.10	426.39	2025-12-14 22:17:19.247552
5826	sensor_cilantro_2	19.54	62.78	71.90	1.79	6.68	199.72	459.42	2025-12-14 22:17:19.247611
5827	sensor_rabano_1	21.46	72.85	78.21	1.87	6.51	174.01	494.71	2025-12-14 22:17:29.257539
5828	sensor_rabano_2	23.19	65.57	78.94	1.78	6.42	92.17	416.22	2025-12-14 22:17:29.258223
5829	sensor_cilantro_1	20.36	77.91	78.02	1.84	6.50	96.75	412.02	2025-12-14 22:17:29.258317
5830	sensor_cilantro_2	22.02	62.27	68.39	1.42	6.61	119.47	456.79	2025-12-14 22:17:29.258374
5831	sensor_rabano_1	21.71	69.43	66.95	1.43	6.53	84.74	410.55	2025-12-14 22:17:39.269502
5832	sensor_rabano_2	22.44	71.62	76.48	1.56	6.62	143.48	433.06	2025-12-14 22:17:39.270339
5833	sensor_cilantro_1	22.08	66.07	64.41	1.84	6.78	196.29	487.73	2025-12-14 22:17:39.270593
5834	sensor_cilantro_2	21.62	72.92	78.68	1.85	6.63	167.58	465.88	2025-12-14 22:17:39.270792
5835	sensor_rabano_1	23.25	57.41	61.03	1.88	6.78	194.16	410.24	2025-12-14 22:17:49.279699
5836	sensor_rabano_2	23.35	61.06	78.60	1.88	6.46	50.08	411.43	2025-12-14 22:17:49.280232
5837	sensor_cilantro_1	22.53	75.29	71.98	1.43	6.75	130.86	483.58	2025-12-14 22:17:49.280314
5838	sensor_cilantro_2	20.13	66.25	61.43	1.80	6.70	54.50	479.97	2025-12-14 22:17:49.28037
5839	sensor_rabano_1	21.40	65.81	75.79	1.97	6.45	90.62	407.18	2025-12-14 22:17:59.290344
5840	sensor_rabano_2	21.13	59.45	79.45	1.41	6.51	117.99	456.43	2025-12-14 22:17:59.291255
5841	sensor_cilantro_1	21.66	65.87	68.88	1.44	6.58	137.33	442.22	2025-12-14 22:17:59.29148
5842	sensor_cilantro_2	19.62	76.49	75.18	1.58	6.69	61.91	465.76	2025-12-14 22:17:59.291754
5843	sensor_rabano_1	21.52	67.43	79.96	1.46	6.79	86.29	423.05	2025-12-14 22:18:09.368569
5844	sensor_rabano_2	23.73	72.72	72.27	1.74	6.47	198.95	457.93	2025-12-14 22:18:09.369431
5845	sensor_cilantro_1	20.18	74.94	61.21	1.44	6.51	106.43	427.41	2025-12-14 22:18:09.369648
5846	sensor_cilantro_2	20.45	67.66	66.50	1.78	6.48	72.89	480.50	2025-12-14 22:18:09.369799
5847	sensor_rabano_1	20.43	70.27	73.90	1.88	6.79	51.89	418.17	2025-12-14 22:18:19.380126
5848	sensor_rabano_2	22.93	69.12	69.53	1.60	6.43	196.13	412.20	2025-12-14 22:18:19.380875
5849	sensor_cilantro_1	20.48	63.33	65.08	1.61	6.75	53.05	417.45	2025-12-14 22:18:19.381049
5850	sensor_cilantro_2	21.14	76.18	75.84	1.43	6.55	130.41	436.51	2025-12-14 22:18:19.381189
5851	sensor_rabano_1	23.52	61.59	69.00	1.49	6.63	197.05	422.10	2025-12-14 22:18:29.391846
5852	sensor_rabano_2	21.09	68.24	78.64	1.69	6.70	109.81	425.90	2025-12-14 22:18:29.392705
5853	sensor_cilantro_1	20.00	66.65	76.79	1.88	6.50	150.65	435.84	2025-12-14 22:18:29.39294
5854	sensor_cilantro_2	22.52	74.60	73.53	1.51	6.50	94.57	416.54	2025-12-14 22:18:29.393092
5855	sensor_rabano_1	22.71	60.22	66.83	1.48	6.78	142.43	490.41	2025-12-14 22:18:39.403717
5856	sensor_rabano_2	21.98	62.13	60.84	1.92	6.65	88.85	412.79	2025-12-14 22:18:39.404598
5857	sensor_cilantro_1	21.10	66.83	70.24	1.98	6.44	144.76	442.38	2025-12-14 22:18:39.404792
5858	sensor_cilantro_2	21.61	65.09	79.98	1.93	6.51	181.87	470.45	2025-12-14 22:18:39.404942
5859	sensor_rabano_1	22.89	68.92	66.58	1.62	6.42	75.57	423.51	2025-12-14 22:18:49.415811
5860	sensor_rabano_2	23.45	72.24	77.13	1.90	6.72	102.92	442.90	2025-12-14 22:18:49.416602
5861	sensor_cilantro_1	20.39	72.77	77.50	1.59	6.51	81.88	491.84	2025-12-14 22:18:49.416832
5862	sensor_cilantro_2	21.85	63.17	72.24	1.72	6.72	130.24	485.58	2025-12-14 22:18:49.417013
5863	sensor_rabano_1	20.72	60.20	67.92	1.43	6.60	185.01	496.19	2025-12-14 22:18:59.427448
5864	sensor_rabano_2	23.73	60.66	69.09	1.57	6.62	102.33	434.80	2025-12-14 22:18:59.428662
5865	sensor_cilantro_1	20.80	73.38	75.27	1.52	6.68	133.99	464.14	2025-12-14 22:18:59.428955
5866	sensor_cilantro_2	20.70	68.79	62.92	1.64	6.67	97.52	402.63	2025-12-14 22:18:59.429123
5867	sensor_rabano_1	23.35	69.89	66.38	1.48	6.72	196.94	472.64	2025-12-14 22:19:09.439422
5868	sensor_rabano_2	20.90	70.74	76.08	1.51	6.57	179.45	449.28	2025-12-14 22:19:09.440283
5869	sensor_cilantro_1	19.40	74.89	76.41	1.97	6.70	79.09	455.00	2025-12-14 22:19:09.440401
5870	sensor_cilantro_2	19.20	73.49	62.94	1.54	6.41	184.83	455.03	2025-12-14 22:19:09.440605
5871	sensor_rabano_1	23.42	58.96	72.94	1.49	6.72	90.38	476.89	2025-12-14 22:19:19.451098
5872	sensor_rabano_2	20.80	61.22	62.53	1.47	6.53	186.71	449.10	2025-12-14 22:19:19.451891
5873	sensor_cilantro_1	20.18	76.19	75.98	1.62	6.41	76.73	500.00	2025-12-14 22:19:19.452179
5874	sensor_cilantro_2	21.10	64.91	79.05	1.96	6.58	142.95	485.82	2025-12-14 22:19:19.4524
5875	sensor_rabano_1	22.30	66.72	72.19	1.58	6.62	81.05	458.16	2025-12-14 22:19:29.463278
5876	sensor_rabano_2	20.44	65.19	67.14	1.63	6.64	185.61	478.45	2025-12-14 22:19:29.464159
5877	sensor_cilantro_1	20.12	74.14	61.03	1.83	6.55	115.45	430.66	2025-12-14 22:19:29.46427
5878	sensor_cilantro_2	21.17	71.13	77.08	1.52	6.76	91.18	474.05	2025-12-14 22:19:29.46433
5879	sensor_rabano_1	22.82	68.63	74.46	1.79	6.66	72.44	447.61	2025-12-14 22:19:39.472757
5880	sensor_rabano_2	23.73	70.11	67.09	1.70	6.70	168.94	419.61	2025-12-14 22:19:39.473646
5881	sensor_cilantro_1	20.82	74.51	75.49	1.47	6.71	178.35	493.82	2025-12-14 22:19:39.473877
5882	sensor_cilantro_2	22.37	63.57	77.29	1.90	6.63	82.55	441.66	2025-12-14 22:19:39.474042
5883	sensor_rabano_1	20.69	72.74	62.48	1.73	6.63	131.51	470.18	2025-12-14 22:19:49.483357
5884	sensor_rabano_2	22.13	62.01	74.62	1.96	6.80	82.67	472.90	2025-12-14 22:19:49.484307
5885	sensor_cilantro_1	22.11	77.66	74.58	1.46	6.71	127.29	416.10	2025-12-14 22:19:49.484563
5886	sensor_cilantro_2	19.33	63.23	75.85	1.68	6.40	111.94	430.17	2025-12-14 22:19:49.484816
5887	sensor_rabano_1	22.71	64.15	65.11	1.41	6.45	85.10	487.23	2025-12-14 22:19:59.495704
5888	sensor_rabano_2	22.33	59.37	67.99	1.55	6.67	111.36	499.17	2025-12-14 22:19:59.496547
5889	sensor_cilantro_1	20.60	72.43	65.93	1.51	6.53	87.32	472.82	2025-12-14 22:19:59.496797
5890	sensor_cilantro_2	19.37	64.64	79.28	1.88	6.50	120.50	464.27	2025-12-14 22:19:59.496958
5891	sensor_rabano_1	20.56	59.67	69.87	1.64	6.66	57.92	488.26	2025-12-14 22:20:09.507628
5892	sensor_rabano_2	22.87	70.31	60.20	1.99	6.58	86.95	401.26	2025-12-14 22:20:09.508511
5893	sensor_cilantro_1	20.36	67.37	62.06	1.86	6.72	143.25	440.54	2025-12-14 22:20:09.508751
5894	sensor_cilantro_2	19.86	72.08	72.58	1.85	6.79	65.16	490.32	2025-12-14 22:20:09.508952
5895	sensor_rabano_1	20.25	66.33	73.12	1.50	6.57	185.71	431.32	2025-12-14 22:20:19.517377
5896	sensor_rabano_2	22.49	64.61	63.17	1.96	6.74	95.13	463.54	2025-12-14 22:20:19.518224
5897	sensor_cilantro_1	19.29	71.78	73.32	1.96	6.44	61.61	485.15	2025-12-14 22:20:19.518329
5898	sensor_cilantro_2	21.93	72.79	79.15	1.87	6.48	138.96	418.09	2025-12-14 22:20:19.518388
5899	sensor_rabano_1	21.87	72.69	60.09	1.46	6.52	134.78	432.58	2025-12-14 22:20:29.528262
5900	sensor_rabano_2	23.64	61.09	76.79	1.85	6.52	164.80	468.44	2025-12-14 22:20:29.529075
5901	sensor_cilantro_1	20.62	64.98	67.51	1.47	6.72	109.54	470.50	2025-12-14 22:20:29.529254
5902	sensor_cilantro_2	20.83	77.71	66.48	1.93	6.42	55.55	407.52	2025-12-14 22:20:29.529393
5903	sensor_rabano_1	22.03	69.68	61.33	1.42	6.76	51.74	495.73	2025-12-14 22:20:39.540473
5904	sensor_rabano_2	23.31	62.52	61.71	1.69	6.59	72.35	447.23	2025-12-14 22:20:39.54153
5905	sensor_cilantro_1	21.68	77.80	71.00	1.49	6.74	111.37	479.23	2025-12-14 22:20:39.541818
5906	sensor_cilantro_2	22.72	75.49	77.73	1.41	6.59	146.19	460.55	2025-12-14 22:20:39.542093
5907	sensor_rabano_1	22.22	70.98	75.00	1.60	6.75	63.43	465.26	2025-12-14 22:20:49.552864
5908	sensor_rabano_2	22.92	62.81	67.48	1.75	6.64	159.50	420.66	2025-12-14 22:20:49.553679
5909	sensor_cilantro_1	22.15	72.18	69.19	1.72	6.43	57.16	451.37	2025-12-14 22:20:49.553921
5910	sensor_cilantro_2	20.40	67.10	70.99	1.70	6.49	83.33	423.88	2025-12-14 22:20:49.554079
5911	sensor_rabano_1	21.68	71.25	73.47	1.96	6.66	162.49	444.24	2025-12-14 22:20:59.56502
5912	sensor_rabano_2	20.91	68.74	67.00	1.55	6.75	153.73	404.79	2025-12-14 22:20:59.566094
5913	sensor_cilantro_1	19.15	69.14	78.23	1.75	6.44	143.42	437.56	2025-12-14 22:20:59.566533
5914	sensor_cilantro_2	19.30	77.25	75.68	1.53	6.55	76.14	413.68	2025-12-14 22:20:59.56677
5915	sensor_rabano_1	20.93	61.96	73.40	1.43	6.41	135.05	470.89	2025-12-14 22:21:09.577853
5916	sensor_rabano_2	22.08	61.55	73.80	1.71	6.46	99.56	490.33	2025-12-14 22:21:09.578672
5917	sensor_cilantro_1	20.53	70.97	70.77	1.58	6.53	138.15	454.34	2025-12-14 22:21:09.578853
5918	sensor_cilantro_2	20.39	75.23	64.89	1.56	6.63	123.99	455.58	2025-12-14 22:21:09.578994
5919	sensor_rabano_1	23.41	65.73	70.95	1.61	6.75	162.07	468.03	2025-12-14 22:21:19.590469
5920	sensor_rabano_2	20.02	68.17	69.69	1.94	6.52	124.61	429.13	2025-12-14 22:21:19.591317
5921	sensor_cilantro_1	21.74	70.30	70.47	1.82	6.65	72.62	491.66	2025-12-14 22:21:19.591511
5922	sensor_cilantro_2	22.36	64.27	62.53	1.78	6.72	161.66	464.03	2025-12-14 22:21:19.591664
5923	sensor_rabano_1	20.08	68.12	73.37	1.72	6.55	73.53	484.30	2025-12-14 22:21:29.602657
5924	sensor_rabano_2	22.56	63.91	73.89	1.92	6.46	144.07	416.01	2025-12-14 22:21:29.603428
5925	sensor_cilantro_1	22.19	77.34	78.24	1.90	6.68	152.71	406.57	2025-12-14 22:21:29.60361
5926	sensor_cilantro_2	22.01	72.32	62.41	1.48	6.42	92.49	467.89	2025-12-14 22:21:29.60375
5927	sensor_rabano_1	20.16	68.65	63.55	1.93	6.77	108.81	492.80	2025-12-14 22:21:39.614761
5928	sensor_rabano_2	22.04	58.43	62.30	1.96	6.61	130.40	465.20	2025-12-14 22:21:39.615628
5929	sensor_cilantro_1	19.95	66.70	76.85	1.98	6.78	179.96	472.26	2025-12-14 22:21:39.615816
5930	sensor_cilantro_2	21.47	66.33	62.66	1.54	6.69	113.74	453.72	2025-12-14 22:21:39.615958
5931	sensor_rabano_1	20.74	69.84	65.50	1.86	6.78	147.35	460.90	2025-12-14 22:21:49.626433
5932	sensor_rabano_2	22.01	63.81	60.92	1.69	6.63	89.84	489.50	2025-12-14 22:21:49.627408
5933	sensor_cilantro_1	19.72	66.83	76.16	1.75	6.78	162.32	433.91	2025-12-14 22:21:49.627692
5934	sensor_cilantro_2	20.35	74.67	76.19	1.72	6.55	127.51	415.82	2025-12-14 22:21:49.627846
5935	sensor_rabano_1	22.50	65.38	78.69	1.80	6.52	66.38	427.49	2025-12-14 22:21:59.635742
5936	sensor_rabano_2	23.21	61.86	62.05	1.83	6.61	122.16	434.98	2025-12-14 22:21:59.636315
5937	sensor_cilantro_1	21.15	73.31	70.69	1.99	6.43	73.15	461.42	2025-12-14 22:21:59.636408
5938	sensor_cilantro_2	22.37	75.14	71.53	1.63	6.43	112.20	407.01	2025-12-14 22:21:59.636477
5939	sensor_rabano_1	22.22	59.57	67.71	1.70	6.57	113.17	452.05	2025-12-14 22:22:09.646932
5940	sensor_rabano_2	20.78	68.20	64.68	1.60	6.54	190.78	488.45	2025-12-14 22:22:09.647728
5941	sensor_cilantro_1	20.47	67.59	63.53	1.47	6.57	154.89	443.80	2025-12-14 22:22:09.647916
5942	sensor_cilantro_2	20.67	75.99	64.31	1.84	6.74	101.13	414.49	2025-12-14 22:22:09.64806
5943	sensor_rabano_1	21.98	67.38	66.56	1.48	6.49	165.14	498.86	2025-12-14 22:22:19.658945
5944	sensor_rabano_2	22.90	57.80	76.26	1.73	6.48	138.53	496.81	2025-12-14 22:22:19.659789
5945	sensor_cilantro_1	20.60	68.08	79.56	1.73	6.55	165.49	405.94	2025-12-14 22:22:19.659983
5946	sensor_cilantro_2	21.77	65.68	78.32	1.88	6.58	177.96	474.10	2025-12-14 22:22:19.660132
5947	sensor_rabano_1	20.58	68.57	64.66	1.87	6.49	105.53	419.73	2025-12-14 22:22:29.67166
5948	sensor_rabano_2	20.98	65.82	67.69	1.74	6.71	156.21	426.75	2025-12-14 22:22:29.672452
5949	sensor_cilantro_1	22.91	71.16	72.48	1.54	6.62	110.13	435.16	2025-12-14 22:22:29.672685
5950	sensor_cilantro_2	20.32	62.09	62.45	1.91	6.43	84.25	414.23	2025-12-14 22:22:29.672887
5951	sensor_rabano_1	22.09	68.21	79.41	1.81	6.51	129.55	423.70	2025-12-14 22:22:39.680758
5952	sensor_rabano_2	23.65	58.71	69.12	1.59	6.74	176.09	469.58	2025-12-14 22:22:39.681624
5953	sensor_cilantro_1	19.30	63.89	71.31	1.81	6.66	148.81	456.60	2025-12-14 22:22:39.681977
5954	sensor_cilantro_2	19.44	72.37	69.94	1.62	6.41	169.73	401.78	2025-12-14 22:22:39.682144
5955	sensor_rabano_1	20.04	64.67	69.88	1.95	6.70	128.51	468.03	2025-12-14 22:22:49.692648
5956	sensor_rabano_2	23.26	62.14	67.58	1.46	6.73	52.03	496.01	2025-12-14 22:22:49.69341
5957	sensor_cilantro_1	22.72	62.17	69.69	1.46	6.44	187.17	490.17	2025-12-14 22:22:49.693643
5958	sensor_cilantro_2	19.49	70.76	62.03	1.95	6.74	115.89	417.47	2025-12-14 22:22:49.693843
5959	sensor_rabano_1	22.29	69.33	67.95	1.97	6.43	130.65	473.53	2025-12-14 22:22:59.704411
5960	sensor_rabano_2	22.97	62.20	64.45	1.94	6.54	144.53	472.55	2025-12-14 22:22:59.704929
5961	sensor_cilantro_1	22.85	75.50	71.70	1.82	6.78	73.52	405.36	2025-12-14 22:22:59.705027
5962	sensor_cilantro_2	22.22	76.63	61.82	1.65	6.53	130.11	442.61	2025-12-14 22:22:59.705084
5963	sensor_rabano_1	20.77	71.41	60.37	1.59	6.58	109.94	439.98	2025-12-14 22:23:09.776479
5964	sensor_rabano_2	20.35	59.72	63.21	1.72	6.76	149.19	474.74	2025-12-14 22:23:09.777459
5965	sensor_cilantro_1	20.79	74.17	77.30	1.96	6.59	135.18	451.48	2025-12-14 22:23:09.777784
5966	sensor_cilantro_2	20.69	68.83	63.28	1.77	6.62	161.21	442.42	2025-12-14 22:23:09.7781
5967	sensor_rabano_1	20.02	64.57	72.92	1.59	6.78	59.20	431.59	2025-12-14 22:23:19.788043
5968	sensor_rabano_2	21.72	57.78	60.71	1.58	6.67	88.56	433.67	2025-12-14 22:23:19.788594
5969	sensor_cilantro_1	21.91	76.70	69.15	1.93	6.72	87.24	457.35	2025-12-14 22:23:19.788838
5970	sensor_cilantro_2	22.69	71.10	76.43	1.83	6.61	139.60	437.07	2025-12-14 22:23:19.788988
5971	sensor_rabano_1	20.65	66.00	64.74	1.97	6.41	184.61	455.58	2025-12-14 22:23:29.799193
5972	sensor_rabano_2	22.24	70.82	75.81	1.67	6.80	101.43	478.36	2025-12-14 22:23:29.800029
5973	sensor_cilantro_1	19.30	72.54	65.33	1.97	6.52	172.29	431.15	2025-12-14 22:23:29.800213
5974	sensor_cilantro_2	19.06	66.62	66.95	1.57	6.78	128.39	435.66	2025-12-14 22:23:29.800355
5975	sensor_rabano_1	20.82	58.38	76.41	1.56	6.75	67.52	453.92	2025-12-14 22:23:39.808979
5976	sensor_rabano_2	23.43	67.93	68.25	1.58	6.45	118.63	413.15	2025-12-14 22:23:39.809525
5977	sensor_cilantro_1	21.65	67.86	78.53	1.87	6.41	180.64	414.02	2025-12-14 22:23:39.809679
5978	sensor_cilantro_2	21.20	62.45	66.12	1.88	6.46	166.88	434.88	2025-12-14 22:23:39.809762
5979	sensor_rabano_1	21.65	67.93	73.90	1.58	6.67	124.38	403.69	2025-12-14 22:23:49.820568
5980	sensor_rabano_2	22.74	61.14	75.23	1.67	6.70	158.80	482.71	2025-12-14 22:23:49.82135
5981	sensor_cilantro_1	19.05	68.02	61.26	1.62	6.43	71.33	429.87	2025-12-14 22:23:49.821604
5982	sensor_cilantro_2	21.44	63.65	66.26	1.93	6.53	111.65	481.92	2025-12-14 22:23:49.821697
5983	sensor_rabano_1	23.24	62.46	77.57	1.85	6.41	142.58	464.11	2025-12-14 22:23:59.832128
5984	sensor_rabano_2	22.28	62.53	76.40	1.47	6.45	91.18	492.37	2025-12-14 22:23:59.83296
5985	sensor_cilantro_1	20.46	62.79	75.11	1.51	6.63	171.46	482.02	2025-12-14 22:23:59.833153
5986	sensor_cilantro_2	21.01	67.58	61.22	1.54	6.63	135.02	479.56	2025-12-14 22:23:59.833301
5987	sensor_rabano_1	20.70	69.96	68.22	1.74	6.69	96.36	428.86	2025-12-14 22:24:09.844073
5988	sensor_rabano_2	22.67	63.49	71.85	1.95	6.46	63.72	465.37	2025-12-14 22:24:09.844859
5989	sensor_cilantro_1	20.10	75.44	63.12	1.62	6.55	199.72	407.27	2025-12-14 22:24:09.845052
5990	sensor_cilantro_2	22.71	75.56	76.48	1.58	6.54	192.34	497.81	2025-12-14 22:24:09.845196
5991	sensor_rabano_1	22.91	71.85	67.08	1.49	6.68	180.47	408.10	2025-12-14 22:24:19.8546
5992	sensor_rabano_2	22.63	63.31	69.30	1.99	6.63	91.45	473.14	2025-12-14 22:24:19.855345
5993	sensor_cilantro_1	20.77	67.35	61.86	1.96	6.63	137.56	483.03	2025-12-14 22:24:19.855461
5994	sensor_cilantro_2	21.79	66.81	68.94	1.45	6.59	166.44	460.98	2025-12-14 22:24:19.855522
5995	sensor_rabano_1	22.46	66.38	70.34	1.42	6.73	143.97	477.58	2025-12-14 22:24:29.865494
5996	sensor_rabano_2	21.42	67.27	72.34	1.57	6.50	139.35	426.20	2025-12-14 22:24:29.866307
5997	sensor_cilantro_1	21.08	70.22	70.67	1.75	6.55	102.99	426.62	2025-12-14 22:24:29.866617
5998	sensor_cilantro_2	19.43	67.64	66.76	1.64	6.77	184.47	495.08	2025-12-14 22:24:29.866844
5999	sensor_rabano_1	21.55	59.24	76.37	1.93	6.59	152.72	475.75	2025-12-14 22:24:39.877535
6000	sensor_rabano_2	23.42	63.91	79.53	1.51	6.45	121.71	489.54	2025-12-14 22:24:39.878314
6001	sensor_cilantro_1	22.82	63.99	76.43	1.47	6.71	120.50	420.17	2025-12-14 22:24:39.878571
6002	sensor_cilantro_2	20.66	62.87	72.28	1.87	6.50	97.14	415.78	2025-12-14 22:24:39.87873
6003	sensor_rabano_1	20.65	62.27	74.43	1.78	6.69	88.75	481.07	2025-12-14 22:24:49.889728
6004	sensor_rabano_2	22.31	58.89	78.78	1.87	6.52	136.39	415.81	2025-12-14 22:24:49.890533
6005	sensor_cilantro_1	22.45	65.76	64.27	1.61	6.58	130.78	451.79	2025-12-14 22:24:49.89076
6006	sensor_cilantro_2	20.71	67.58	73.33	1.95	6.61	194.07	496.86	2025-12-14 22:24:49.890915
6007	sensor_rabano_1	21.05	69.57	62.01	1.79	6.75	188.73	408.03	2025-12-14 22:24:59.899269
6008	sensor_rabano_2	21.95	57.65	73.28	1.48	6.67	145.98	495.58	2025-12-14 22:24:59.899843
6009	sensor_cilantro_1	19.16	62.82	74.07	1.66	6.60	177.58	418.10	2025-12-14 22:24:59.900094
6010	sensor_cilantro_2	21.77	64.41	79.73	1.42	6.52	121.29	498.77	2025-12-14 22:24:59.900307
6011	sensor_rabano_1	23.90	58.97	76.74	1.65	6.67	169.26	489.68	2025-12-14 22:25:09.910798
6012	sensor_rabano_2	20.36	71.13	60.70	1.91	6.43	142.45	414.51	2025-12-14 22:25:09.911614
6013	sensor_cilantro_1	19.68	64.19	79.16	1.52	6.61	90.91	431.11	2025-12-14 22:25:09.911907
6014	sensor_cilantro_2	21.80	75.38	60.18	1.87	6.55	102.90	403.18	2025-12-14 22:25:09.911998
6015	sensor_rabano_1	22.60	72.37	68.09	1.87	6.67	168.10	458.64	2025-12-14 22:25:19.924293
6016	sensor_rabano_2	20.22	64.94	60.68	1.61	6.45	124.73	433.64	2025-12-14 22:25:19.925147
6017	sensor_cilantro_1	21.55	67.33	61.22	1.91	6.45	135.45	437.39	2025-12-14 22:25:19.925335
6018	sensor_cilantro_2	20.18	74.03	69.75	1.49	6.49	107.02	427.77	2025-12-14 22:25:19.925487
6019	sensor_rabano_1	22.32	67.43	63.87	1.94	6.77	64.28	473.74	2025-12-14 22:25:29.9358
6020	sensor_rabano_2	20.89	59.45	73.69	1.53	6.74	115.60	418.99	2025-12-14 22:25:29.936515
6021	sensor_cilantro_1	22.75	69.59	61.59	1.98	6.42	138.74	426.34	2025-12-14 22:25:29.936689
6022	sensor_cilantro_2	22.49	74.50	74.12	1.61	6.71	68.94	432.61	2025-12-14 22:25:29.936828
6023	sensor_rabano_1	21.27	59.82	77.69	1.77	6.62	75.88	442.09	2025-12-14 22:25:39.945429
6024	sensor_rabano_2	21.32	64.45	73.79	1.95	6.43	135.81	439.84	2025-12-14 22:25:39.946328
6025	sensor_cilantro_1	21.85	65.25	75.18	1.51	6.44	70.12	405.50	2025-12-14 22:25:39.946564
6026	sensor_cilantro_2	19.99	62.79	69.05	1.89	6.48	111.24	484.25	2025-12-14 22:25:39.946768
6027	sensor_rabano_1	23.41	69.69	68.06	1.51	6.57	78.93	425.01	2025-12-14 22:25:49.955144
6028	sensor_rabano_2	22.60	57.78	73.36	1.81	6.53	76.76	466.43	2025-12-14 22:25:49.955686
6029	sensor_cilantro_1	22.43	68.54	71.78	1.72	6.73	82.91	492.96	2025-12-14 22:25:49.955861
6030	sensor_cilantro_2	19.80	77.81	72.73	1.43	6.65	110.30	447.34	2025-12-14 22:25:49.955946
6031	sensor_rabano_1	23.15	64.50	68.83	1.87	6.48	129.91	458.95	2025-12-14 22:25:59.966376
6032	sensor_rabano_2	20.77	68.84	70.29	1.96	6.75	102.31	459.55	2025-12-14 22:25:59.967266
6033	sensor_cilantro_1	19.36	69.59	75.61	1.44	6.75	164.96	444.14	2025-12-14 22:25:59.967511
6034	sensor_cilantro_2	21.32	74.83	74.86	1.76	6.65	175.13	483.18	2025-12-14 22:25:59.967715
6035	sensor_rabano_1	23.34	70.54	73.11	1.85	6.75	94.56	430.83	2025-12-14 22:26:09.978508
6036	sensor_rabano_2	20.34	65.88	79.57	1.88	6.44	62.73	452.89	2025-12-14 22:26:09.979316
6037	sensor_cilantro_1	22.91	64.97	76.73	1.89	6.79	73.13	477.09	2025-12-14 22:26:09.979514
6038	sensor_cilantro_2	22.43	75.44	71.99	1.75	6.63	186.70	444.15	2025-12-14 22:26:09.979668
6039	sensor_rabano_1	23.84	71.97	69.52	1.50	6.41	78.96	403.06	2025-12-14 22:26:19.990765
6040	sensor_rabano_2	22.60	71.49	77.48	1.51	6.76	98.85	419.43	2025-12-14 22:26:19.991568
6041	sensor_cilantro_1	19.64	65.30	75.28	1.81	6.79	88.94	438.34	2025-12-14 22:26:19.991753
6042	sensor_cilantro_2	21.64	75.90	68.77	1.74	6.47	167.16	464.31	2025-12-14 22:26:19.9919
6043	sensor_rabano_1	20.16	69.49	78.74	1.98	6.70	142.48	490.22	2025-12-14 22:26:30.002332
6044	sensor_rabano_2	22.10	72.30	63.76	1.56	6.48	115.34	405.52	2025-12-14 22:26:30.003166
6045	sensor_cilantro_1	20.77	70.34	76.59	1.69	6.68	112.87	410.21	2025-12-14 22:26:30.003354
6046	sensor_cilantro_2	20.19	75.40	65.97	1.81	6.43	130.57	424.39	2025-12-14 22:26:30.003548
6047	sensor_rabano_1	21.15	60.48	63.90	1.98	6.43	94.50	404.24	2025-12-14 22:26:40.01421
6048	sensor_rabano_2	23.33	69.33	62.55	1.73	6.42	181.68	499.41	2025-12-14 22:26:40.015007
6049	sensor_cilantro_1	19.92	67.45	64.19	1.54	6.52	98.63	410.88	2025-12-14 22:26:40.015198
6050	sensor_cilantro_2	21.76	67.63	79.00	1.76	6.57	80.40	403.41	2025-12-14 22:26:40.015341
6051	sensor_rabano_1	22.18	71.83	74.34	1.89	6.51	82.64	443.09	2025-12-14 22:26:50.023603
6052	sensor_rabano_2	23.12	57.20	76.00	1.58	6.53	140.34	438.64	2025-12-14 22:26:50.024466
6053	sensor_cilantro_1	22.63	72.08	78.03	1.81	6.64	189.10	414.29	2025-12-14 22:26:50.02457
6054	sensor_cilantro_2	19.04	76.36	74.72	1.72	6.72	87.57	428.41	2025-12-14 22:26:50.024633
6055	sensor_rabano_1	22.52	59.57	64.02	1.45	6.48	69.72	461.73	2025-12-14 22:27:00.034948
6056	sensor_rabano_2	23.87	63.43	64.69	1.94	6.71	171.79	417.36	2025-12-14 22:27:00.035962
6057	sensor_cilantro_1	21.88	70.78	76.91	1.61	6.47	140.54	447.22	2025-12-14 22:27:00.036232
6058	sensor_cilantro_2	19.75	69.58	64.05	1.57	6.64	72.86	446.97	2025-12-14 22:27:00.036522
6059	sensor_rabano_1	20.89	67.25	69.07	1.75	6.62	193.72	490.97	2025-12-14 22:27:10.047175
6060	sensor_rabano_2	22.52	67.06	72.60	1.77	6.74	70.05	407.16	2025-12-14 22:27:10.047954
6061	sensor_cilantro_1	22.76	73.35	69.14	1.60	6.70	183.77	446.92	2025-12-14 22:27:10.048144
6062	sensor_cilantro_2	19.08	63.39	74.07	1.95	6.56	186.08	442.26	2025-12-14 22:27:10.048287
6063	sensor_rabano_1	20.41	68.58	69.39	1.49	6.44	101.56	431.44	2025-12-14 22:27:20.059472
6064	sensor_rabano_2	23.88	65.38	67.74	1.71	6.72	105.58	475.55	2025-12-14 22:27:20.060392
6065	sensor_cilantro_1	22.48	64.55	64.61	1.70	6.41	101.37	443.84	2025-12-14 22:27:20.060711
6066	sensor_cilantro_2	20.50	73.05	77.54	1.58	6.42	116.39	483.94	2025-12-14 22:27:20.060881
6067	sensor_rabano_1	23.89	65.32	78.92	1.92	6.46	158.76	482.49	2025-12-14 22:27:30.07069
6068	sensor_rabano_2	23.59	63.42	73.93	1.83	6.72	135.26	499.52	2025-12-14 22:27:30.071433
6069	sensor_cilantro_1	19.16	74.00	74.27	1.56	6.62	66.85	444.92	2025-12-14 22:27:30.071543
6070	sensor_cilantro_2	20.88	71.42	78.96	1.65	6.46	82.07	409.91	2025-12-14 22:27:30.071602
6071	sensor_rabano_1	22.27	69.92	67.66	1.62	6.67	109.01	429.09	2025-12-14 22:27:40.081988
6072	sensor_rabano_2	22.63	72.12	64.00	1.41	6.53	152.30	407.58	2025-12-14 22:27:40.082705
6073	sensor_cilantro_1	21.14	77.34	65.58	1.43	6.59	88.02	468.51	2025-12-14 22:27:40.082881
6074	sensor_cilantro_2	20.84	69.20	74.38	1.79	6.65	99.46	471.54	2025-12-14 22:27:40.083019
6075	sensor_rabano_1	22.02	60.82	61.50	1.62	6.68	109.43	426.07	2025-12-14 22:27:50.093943
6076	sensor_rabano_2	23.76	65.71	64.31	1.74	6.76	102.70	451.40	2025-12-14 22:27:50.094737
6077	sensor_cilantro_1	21.13	74.80	64.79	1.50	6.79	73.57	455.91	2025-12-14 22:27:50.094925
6078	sensor_cilantro_2	19.89	77.80	63.86	1.53	6.44	165.30	485.09	2025-12-14 22:27:50.09507
6079	sensor_rabano_1	21.07	65.88	68.71	1.89	6.49	138.90	416.22	2025-12-14 22:28:00.103047
6080	sensor_rabano_2	23.40	62.65	68.30	2.00	6.49	145.51	420.78	2025-12-14 22:28:00.104179
6081	sensor_cilantro_1	20.78	62.87	69.29	1.96	6.56	75.72	427.28	2025-12-14 22:28:00.104266
6082	sensor_cilantro_2	20.42	68.00	79.85	1.51	6.72	90.97	410.21	2025-12-14 22:28:00.104324
6083	sensor_rabano_1	20.57	60.27	66.90	1.68	6.43	50.32	475.09	2025-12-14 22:28:10.173622
6084	sensor_rabano_2	21.24	62.24	73.88	1.94	6.45	103.63	400.60	2025-12-14 22:28:10.17433
6085	sensor_cilantro_1	22.11	69.17	65.24	1.70	6.59	194.37	425.05	2025-12-14 22:28:10.174516
6086	sensor_cilantro_2	21.52	72.70	73.82	1.49	6.44	89.09	421.94	2025-12-14 22:28:10.174669
6087	sensor_rabano_1	22.39	67.21	70.53	1.73	6.62	181.51	492.24	2025-12-14 22:32:20.612759
6088	sensor_rabano_2	22.64	66.75	79.33	1.89	6.68	191.05	473.66	2025-12-14 22:32:20.613741
6089	sensor_cilantro_1	22.02	66.29	69.24	1.68	6.41	76.58	408.03	2025-12-14 22:32:20.613953
6090	sensor_cilantro_2	21.81	62.34	64.35	1.87	6.73	137.13	442.01	2025-12-14 22:32:20.614135
6091	sensor_rabano_1	20.09	71.88	71.37	1.65	6.48	198.90	431.90	2025-12-14 22:32:30.626629
6092	sensor_rabano_2	20.95	65.35	72.13	1.85	6.77	158.62	400.53	2025-12-14 22:32:30.627489
6093	sensor_cilantro_1	20.97	72.36	79.25	1.61	6.55	97.35	440.73	2025-12-14 22:32:30.627737
6094	sensor_cilantro_2	19.32	64.62	60.62	1.69	6.44	111.55	451.21	2025-12-14 22:32:30.627924
6095	sensor_rabano_1	20.58	67.32	64.88	1.82	6.45	189.44	491.09	2025-12-14 22:32:40.637962
6096	sensor_rabano_2	22.30	72.75	71.30	1.46	6.59	144.76	469.43	2025-12-14 22:32:40.639063
6097	sensor_cilantro_1	22.55	75.57	76.94	1.67	6.55	109.49	497.94	2025-12-14 22:32:40.639304
6098	sensor_cilantro_2	20.30	67.58	72.30	1.57	6.60	190.91	454.68	2025-12-14 22:32:40.639484
6099	sensor_rabano_1	20.78	63.43	64.96	1.66	6.60	64.92	416.46	2025-12-14 22:32:50.649512
6100	sensor_rabano_2	20.68	72.65	78.60	1.65	6.59	78.60	456.77	2025-12-14 22:32:50.650069
6101	sensor_cilantro_1	21.29	75.19	70.35	1.87	6.80	54.84	459.45	2025-12-14 22:32:50.650304
6102	sensor_cilantro_2	21.56	67.42	72.99	1.65	6.54	62.48	419.72	2025-12-14 22:32:50.650549
6103	sensor_rabano_1	22.81	71.88	64.10	1.99	6.59	50.27	446.31	2025-12-14 22:33:00.658955
6104	sensor_rabano_2	23.26	60.13	75.97	1.66	6.74	72.72	498.54	2025-12-14 22:33:00.659451
6105	sensor_cilantro_1	19.18	77.55	68.25	1.58	6.74	111.51	408.99	2025-12-14 22:33:00.659539
6106	sensor_cilantro_2	19.44	72.87	76.73	1.96	6.76	108.64	459.25	2025-12-14 22:33:00.659597
6107	sensor_rabano_1	23.99	67.77	74.13	1.71	6.58	61.10	412.53	2025-12-14 22:33:10.677315
6108	sensor_rabano_2	23.08	70.64	71.40	1.45	6.54	109.96	491.89	2025-12-14 22:33:10.678152
6109	sensor_cilantro_1	22.08	65.36	60.83	1.77	6.58	95.59	465.42	2025-12-14 22:33:10.678345
6110	sensor_cilantro_2	22.58	70.48	70.02	1.55	6.47	183.63	466.54	2025-12-14 22:33:10.678501
6111	sensor_rabano_1	21.65	68.21	74.27	1.85	6.52	66.09	407.29	2025-12-14 22:33:20.68677
6112	sensor_rabano_2	22.84	63.16	68.80	1.57	6.47	142.37	441.42	2025-12-14 22:33:20.68729
6113	sensor_cilantro_1	21.49	69.77	63.46	1.86	6.59	126.65	405.29	2025-12-14 22:33:20.687425
6114	sensor_cilantro_2	19.39	73.52	60.24	1.62	6.45	190.15	419.21	2025-12-14 22:33:20.68752
6115	sensor_rabano_1	22.38	69.05	60.58	1.56	6.69	65.24	490.94	2025-12-14 23:05:41.051102
6116	sensor_rabano_2	22.45	67.61	70.91	1.97	6.62	180.76	418.66	2025-12-14 23:05:41.051976
6117	sensor_cilantro_1	20.06	67.87	71.56	1.80	6.41	88.20	481.82	2025-12-14 23:05:41.052175
6118	sensor_cilantro_2	21.56	71.94	79.35	1.90	6.68	135.14	406.94	2025-12-14 23:05:41.052328
6119	sensor_rabano_1	22.01	68.80	73.14	1.58	6.69	177.82	468.34	2025-12-14 23:05:51.063397
6120	sensor_rabano_2	22.83	63.72	68.41	1.93	6.57	55.21	418.54	2025-12-14 23:05:51.064288
6121	sensor_cilantro_1	19.17	71.71	63.95	1.98	6.74	64.54	414.00	2025-12-14 23:05:51.064522
6122	sensor_cilantro_2	21.30	64.81	79.23	1.53	6.76	94.44	457.34	2025-12-14 23:05:51.064694
6123	sensor_rabano_1	22.81	60.34	65.57	1.62	6.50	127.65	475.99	2025-12-14 23:06:01.073454
6124	sensor_rabano_2	22.36	60.57	67.44	1.63	6.59	174.19	499.76	2025-12-14 23:06:01.074288
6125	sensor_cilantro_1	20.04	66.30	74.44	1.55	6.71	178.52	447.31	2025-12-14 23:06:01.07438
6126	sensor_cilantro_2	19.76	69.86	66.12	1.62	6.66	193.37	479.18	2025-12-14 23:06:01.074447
6127	sensor_rabano_1	23.11	66.94	66.56	1.69	6.51	134.64	461.82	2025-12-14 23:06:11.083523
6128	sensor_rabano_2	21.71	63.88	76.03	1.58	6.56	121.64	436.15	2025-12-14 23:06:11.084463
6129	sensor_cilantro_1	20.72	75.93	71.04	1.98	6.65	93.68	429.13	2025-12-14 23:06:11.084739
6130	sensor_cilantro_2	22.05	62.77	76.08	1.88	6.52	171.15	455.77	2025-12-14 23:06:11.084944
6131	sensor_rabano_1	23.93	68.75	66.01	1.44	6.45	58.21	468.96	2025-12-14 23:06:21.096417
6132	sensor_rabano_2	20.77	69.77	75.70	1.71	6.72	174.04	401.19	2025-12-14 23:06:21.097265
6133	sensor_cilantro_1	22.13	62.19	76.44	1.64	6.55	77.12	480.52	2025-12-14 23:06:21.097466
6134	sensor_cilantro_2	20.49	73.04	73.06	1.79	6.44	57.39	408.52	2025-12-14 23:06:21.097613
6135	sensor_rabano_1	20.08	70.84	68.72	1.85	6.55	154.02	437.17	2025-12-14 23:06:31.108645
6136	sensor_rabano_2	20.09	57.30	61.38	1.64	6.49	68.76	415.34	2025-12-14 23:06:31.109467
6137	sensor_cilantro_1	20.80	75.39	64.51	1.43	6.53	101.04	437.33	2025-12-14 23:06:31.109655
6138	sensor_cilantro_2	22.41	73.50	74.84	1.62	6.64	135.68	410.22	2025-12-14 23:06:31.10981
6139	sensor_rabano_1	22.27	70.95	70.91	1.96	6.53	149.68	419.14	2025-12-14 23:06:41.120733
6140	sensor_rabano_2	23.49	64.91	65.57	1.63	6.57	120.81	476.43	2025-12-14 23:06:41.121753
6141	sensor_cilantro_1	19.71	75.68	69.63	1.95	6.70	128.46	467.92	2025-12-14 23:06:41.122008
6142	sensor_cilantro_2	20.54	62.13	62.61	1.85	6.43	194.71	456.40	2025-12-14 23:06:41.122246
6143	sensor_rabano_1	22.31	61.37	72.19	1.69	6.58	87.49	429.58	2025-12-14 23:06:51.130112
6144	sensor_rabano_2	23.35	61.23	68.94	1.46	6.45	108.13	471.36	2025-12-14 23:06:51.130936
6145	sensor_cilantro_1	19.88	70.87	71.25	1.67	6.64	119.57	481.16	2025-12-14 23:06:51.13111
6146	sensor_cilantro_2	19.32	64.57	62.23	1.85	6.64	130.10	410.99	2025-12-14 23:06:51.131246
6147	sensor_rabano_1	22.18	70.43	78.39	1.77	6.47	184.41	467.72	2025-12-14 23:07:01.141691
6148	sensor_rabano_2	20.44	71.36	69.87	1.92	6.53	174.76	492.58	2025-12-14 23:07:01.142487
6149	sensor_cilantro_1	21.31	74.90	62.18	1.51	6.51	165.66	476.28	2025-12-14 23:07:01.142707
6150	sensor_cilantro_2	20.57	75.16	61.91	1.96	6.69	151.06	414.40	2025-12-14 23:07:01.142851
6151	sensor_rabano_1	23.12	67.01	71.81	2.00	6.54	92.86	478.28	2025-12-14 23:07:11.15298
6152	sensor_rabano_2	20.54	70.44	60.36	1.57	6.51	51.30	412.03	2025-12-14 23:07:11.154169
6153	sensor_cilantro_1	19.36	65.93	77.46	1.70	6.62	175.56	497.77	2025-12-14 23:07:11.154267
6154	sensor_cilantro_2	20.13	68.67	73.90	1.99	6.79	119.34	448.20	2025-12-14 23:07:11.154333
6155	sensor_rabano_1	22.57	71.57	77.09	1.55	6.70	98.59	453.11	2025-12-14 23:07:21.166043
6156	sensor_rabano_2	21.63	69.73	69.62	1.58	6.40	114.80	463.78	2025-12-14 23:07:21.166866
6157	sensor_cilantro_1	21.12	74.42	73.09	1.66	6.55	190.31	495.43	2025-12-14 23:07:21.167052
6158	sensor_cilantro_2	22.07	70.81	71.92	1.96	6.73	148.84	486.88	2025-12-14 23:07:21.167199
6159	sensor_rabano_1	22.25	68.17	77.06	1.79	6.49	108.70	467.95	2025-12-14 23:07:31.178029
6160	sensor_rabano_2	23.21	63.26	67.25	1.84	6.63	54.15	489.67	2025-12-14 23:07:31.178867
6161	sensor_cilantro_1	19.59	72.68	73.72	1.45	6.55	137.71	460.93	2025-12-14 23:07:31.179075
6162	sensor_cilantro_2	21.89	63.54	61.81	1.83	6.58	128.93	487.92	2025-12-14 23:07:31.179223
6163	sensor_rabano_1	22.51	70.47	63.68	1.80	6.48	178.00	474.08	2025-12-14 23:07:41.190018
6164	sensor_rabano_2	21.50	71.76	62.20	1.89	6.66	147.63	475.32	2025-12-14 23:07:41.190858
6165	sensor_cilantro_1	21.34	63.06	68.32	1.55	6.55	150.02	408.35	2025-12-14 23:07:41.191054
6166	sensor_cilantro_2	19.40	64.15	66.62	1.54	6.46	78.09	467.39	2025-12-14 23:07:41.191206
6167	sensor_rabano_1	21.97	61.31	64.98	1.96	6.65	62.09	403.15	2025-12-14 23:07:51.201594
6168	sensor_rabano_2	22.77	68.52	64.90	1.71	6.72	67.65	414.51	2025-12-14 23:07:51.20237
6169	sensor_cilantro_1	20.88	62.24	79.23	1.79	6.76	160.00	450.22	2025-12-14 23:07:51.202571
6170	sensor_cilantro_2	22.33	67.48	64.36	1.44	6.76	80.84	400.28	2025-12-14 23:07:51.202721
6171	sensor_rabano_1	22.94	61.03	64.13	1.57	6.58	178.79	438.29	2025-12-14 23:08:01.213973
6172	sensor_rabano_2	20.64	72.24	74.94	1.49	6.75	87.68	486.13	2025-12-14 23:08:01.21478
6173	sensor_cilantro_1	19.97	75.75	66.32	1.43	6.79	154.31	462.40	2025-12-14 23:08:01.214968
6174	sensor_cilantro_2	21.90	69.26	70.69	1.67	6.49	118.53	415.86	2025-12-14 23:08:01.215113
6175	sensor_rabano_1	23.80	63.22	64.42	1.65	6.64	109.30	479.36	2025-12-14 23:08:11.224982
6176	sensor_rabano_2	20.99	63.33	64.83	1.66	6.72	156.59	473.61	2025-12-14 23:08:11.225637
6177	sensor_cilantro_1	21.18	66.94	64.58	1.99	6.77	141.55	435.37	2025-12-14 23:08:11.225884
6178	sensor_cilantro_2	21.31	62.36	70.33	1.40	6.58	68.18	425.77	2025-12-14 23:08:11.225973
6179	sensor_rabano_1	23.51	64.20	62.61	1.72	6.61	140.97	419.83	2025-12-14 23:08:21.236461
6180	sensor_rabano_2	23.59	62.35	71.56	1.64	6.59	62.05	472.67	2025-12-14 23:08:21.237436
6181	sensor_cilantro_1	22.33	72.39	71.07	1.92	6.41	50.54	436.87	2025-12-14 23:08:21.237699
6182	sensor_cilantro_2	20.51	68.72	74.37	1.49	6.47	62.87	437.59	2025-12-14 23:08:21.237789
6183	sensor_rabano_1	22.58	67.72	65.75	1.68	6.76	80.29	403.59	2025-12-14 23:08:31.246758
6184	sensor_rabano_2	22.86	72.55	79.86	1.41	6.61	151.33	474.50	2025-12-14 23:08:31.247451
6185	sensor_cilantro_1	19.88	76.70	69.57	1.65	6.67	64.18	468.56	2025-12-14 23:08:31.247559
6186	sensor_cilantro_2	22.38	69.46	73.49	1.65	6.66	160.99	419.13	2025-12-14 23:08:31.247622
6187	sensor_rabano_1	22.74	58.60	79.44	1.81	6.60	83.57	470.48	2025-12-14 23:08:41.258172
6188	sensor_rabano_2	20.95	66.22	62.15	1.69	6.65	70.73	446.18	2025-12-14 23:08:41.258985
6189	sensor_cilantro_1	22.61	66.50	70.62	1.91	6.60	148.38	467.64	2025-12-14 23:08:41.259178
6190	sensor_cilantro_2	19.36	65.38	62.47	1.79	6.59	143.36	491.61	2025-12-14 23:08:41.259324
6191	sensor_rabano_1	22.57	68.70	69.57	1.95	6.54	79.34	497.80	2025-12-14 23:08:51.270222
6192	sensor_rabano_2	23.19	68.04	76.49	1.48	6.48	121.18	430.49	2025-12-14 23:08:51.271076
6193	sensor_cilantro_1	21.22	64.38	65.95	1.62	6.52	111.48	491.07	2025-12-14 23:08:51.271263
6194	sensor_cilantro_2	19.73	65.08	71.33	1.93	6.62	153.89	475.92	2025-12-14 23:08:51.271405
6195	sensor_rabano_1	21.99	63.37	79.63	1.77	6.52	94.32	416.31	2025-12-14 23:09:01.282507
6196	sensor_rabano_2	20.46	58.32	77.84	1.50	6.49	157.13	454.54	2025-12-14 23:09:01.283342
6197	sensor_cilantro_1	19.97	77.78	65.32	1.60	6.41	178.66	435.12	2025-12-14 23:09:01.283547
6198	sensor_cilantro_2	21.07	64.08	64.01	1.68	6.72	124.55	438.26	2025-12-14 23:09:01.283756
6199	sensor_rabano_1	22.47	68.73	67.89	1.99	6.76	82.26	420.94	2025-12-14 23:09:11.295002
6200	sensor_rabano_2	23.31	69.41	66.89	1.73	6.52	99.76	429.68	2025-12-14 23:09:11.295772
6201	sensor_cilantro_1	19.29	74.01	79.43	1.95	6.47	104.38	488.45	2025-12-14 23:09:11.295955
6202	sensor_cilantro_2	22.09	77.48	69.60	1.90	6.44	162.44	459.00	2025-12-14 23:09:11.296096
6203	sensor_rabano_1	21.20	64.34	64.79	1.94	6.80	77.57	422.56	2025-12-14 23:09:21.307067
6204	sensor_rabano_2	21.11	60.50	73.57	1.85	6.46	80.07	449.10	2025-12-14 23:09:21.307893
6205	sensor_cilantro_1	20.99	71.66	67.68	2.00	6.45	164.32	499.84	2025-12-14 23:09:21.308132
6206	sensor_cilantro_2	20.44	67.41	74.42	1.62	6.56	157.15	481.01	2025-12-14 23:09:21.30836
6207	sensor_rabano_1	23.45	60.92	75.21	1.79	6.59	110.62	479.70	2025-12-14 23:09:31.319517
6208	sensor_rabano_2	21.09	59.44	62.89	1.55	6.56	56.88	422.94	2025-12-14 23:09:31.320367
6209	sensor_cilantro_1	22.39	70.29	73.37	1.68	6.48	162.27	422.19	2025-12-14 23:09:31.320658
6210	sensor_cilantro_2	20.63	70.78	67.49	1.50	6.58	114.40	465.33	2025-12-14 23:09:31.320813
6211	sensor_rabano_1	22.93	62.81	66.52	1.50	6.78	131.59	496.34	2025-12-14 23:09:41.331307
6212	sensor_rabano_2	22.45	62.88	78.36	1.86	6.80	105.11	403.14	2025-12-14 23:09:41.332146
6213	sensor_cilantro_1	22.67	69.22	79.96	1.40	6.70	173.13	452.26	2025-12-14 23:09:41.332333
6214	sensor_cilantro_2	19.67	76.26	69.23	1.97	6.75	150.92	445.59	2025-12-14 23:09:41.332555
6215	sensor_rabano_1	22.00	66.83	63.64	1.42	6.57	127.04	447.88	2025-12-14 23:09:51.342127
6216	sensor_rabano_2	21.09	67.88	67.85	1.80	6.65	101.89	439.44	2025-12-14 23:09:51.342919
6217	sensor_cilantro_1	22.02	66.45	66.27	1.93	6.79	59.82	484.93	2025-12-14 23:09:51.343111
6218	sensor_cilantro_2	19.88	74.88	68.63	1.66	6.61	156.66	433.28	2025-12-14 23:09:51.343256
6219	sensor_rabano_1	23.82	60.09	79.01	1.74	6.79	146.50	455.35	2025-12-14 23:10:01.354151
6220	sensor_rabano_2	20.21	68.11	64.49	1.63	6.72	145.40	475.06	2025-12-14 23:10:01.355169
6221	sensor_cilantro_1	22.76	75.86	61.80	1.51	6.68	50.62	441.91	2025-12-14 23:10:01.355426
6222	sensor_cilantro_2	21.99	76.56	68.17	1.47	6.60	103.47	441.56	2025-12-14 23:10:01.35569
6223	sensor_rabano_1	23.52	68.32	79.63	1.51	6.58	167.46	429.38	2025-12-14 23:10:11.364337
6224	sensor_rabano_2	22.90	63.22	65.81	1.86	6.45	163.22	448.67	2025-12-14 23:10:11.364824
6225	sensor_cilantro_1	19.77	74.26	64.47	1.54	6.52	170.07	422.39	2025-12-14 23:10:11.364906
6226	sensor_cilantro_2	22.17	67.48	74.79	1.83	6.46	191.91	471.22	2025-12-14 23:10:11.364964
6227	sensor_rabano_1	23.95	58.35	73.45	1.83	6.78	115.37	494.44	2025-12-14 23:10:21.375621
6228	sensor_rabano_2	23.88	70.09	67.65	1.74	6.49	91.71	442.95	2025-12-14 23:10:21.376459
6229	sensor_cilantro_1	19.37	67.02	68.33	1.92	6.48	182.44	454.93	2025-12-14 23:10:21.376704
6230	sensor_cilantro_2	22.42	71.64	70.01	1.96	6.51	170.15	496.86	2025-12-14 23:10:21.37686
6231	sensor_rabano_1	21.21	67.58	75.04	1.87	6.46	76.43	485.51	2025-12-14 23:10:31.387523
6232	sensor_rabano_2	23.34	59.88	74.49	1.97	6.71	55.40	474.76	2025-12-14 23:10:31.388279
6233	sensor_cilantro_1	20.95	70.54	64.42	1.71	6.68	169.35	498.91	2025-12-14 23:10:31.388546
6234	sensor_cilantro_2	19.55	77.29	79.04	1.57	6.48	156.08	452.60	2025-12-14 23:10:31.388747
6235	sensor_rabano_1	20.79	66.08	75.79	1.94	6.55	94.71	405.04	2025-12-14 23:10:41.399501
6236	sensor_rabano_2	22.73	68.34	72.78	1.55	6.40	198.30	408.84	2025-12-14 23:10:41.400263
6237	sensor_cilantro_1	20.96	63.72	71.49	1.77	6.75	133.09	447.42	2025-12-14 23:10:41.400445
6238	sensor_cilantro_2	22.52	74.29	75.69	1.89	6.53	64.07	486.78	2025-12-14 23:10:41.400599
6239	sensor_rabano_1	23.30	67.87	70.31	1.76	6.53	61.55	401.79	2025-12-14 23:10:51.613048
6240	sensor_rabano_2	22.25	68.41	75.30	1.57	6.74	150.45	404.71	2025-12-14 23:10:51.613853
6241	sensor_cilantro_1	22.40	72.31	67.35	1.74	6.76	198.60	493.85	2025-12-14 23:10:51.61405
6242	sensor_cilantro_2	21.75	71.92	74.81	1.95	6.78	172.58	438.34	2025-12-14 23:10:51.6142
6243	sensor_rabano_1	23.48	72.74	61.77	1.74	6.50	169.16	443.22	2025-12-14 23:11:01.624893
6244	sensor_rabano_2	22.41	67.71	74.84	1.58	6.51	109.60	483.29	2025-12-14 23:11:01.625785
6245	sensor_cilantro_1	19.50	73.30	69.19	1.64	6.66	128.24	438.20	2025-12-14 23:11:01.625997
6246	sensor_cilantro_2	20.75	63.89	73.81	1.75	6.68	58.89	430.23	2025-12-14 23:11:01.626157
6247	sensor_rabano_1	22.28	58.81	77.90	1.60	6.46	134.01	413.62	2025-12-14 23:11:11.637224
6248	sensor_rabano_2	21.69	70.69	66.09	1.60	6.62	182.01	489.95	2025-12-14 23:11:11.638111
6249	sensor_cilantro_1	19.21	77.25	67.60	1.82	6.62	88.19	476.49	2025-12-14 23:11:11.638302
6250	sensor_cilantro_2	22.24	64.43	67.07	1.55	6.47	61.25	411.27	2025-12-14 23:11:11.638459
6251	sensor_rabano_1	20.97	57.59	75.43	1.68	6.42	92.97	455.28	2025-12-14 23:14:48.171332
6252	sensor_rabano_2	23.02	58.28	64.64	1.99	6.56	101.04	420.01	2025-12-14 23:14:48.172217
6253	sensor_cilantro_1	21.18	68.22	69.33	1.72	6.73	101.40	439.02	2025-12-14 23:14:48.172404
6254	sensor_cilantro_2	22.42	66.61	76.83	1.87	6.64	65.61	400.01	2025-12-14 23:14:48.172637
6255	sensor_rabano_1	22.64	64.93	72.97	1.98	6.53	74.50	469.87	2025-12-14 23:14:58.183353
6256	sensor_rabano_2	21.99	68.09	71.66	1.45	6.42	165.75	498.52	2025-12-14 23:14:58.184176
6257	sensor_cilantro_1	20.39	67.02	60.45	1.95	6.47	113.03	487.10	2025-12-14 23:14:58.184365
6258	sensor_cilantro_2	20.01	68.84	60.49	1.46	6.58	147.21	416.31	2025-12-14 23:14:58.184522
6259	sensor_rabano_1	20.61	71.58	73.53	1.57	6.52	88.73	467.21	2025-12-14 23:15:08.195104
6260	sensor_rabano_2	20.65	71.19	69.82	1.83	6.47	198.12	453.99	2025-12-14 23:15:08.196002
6261	sensor_cilantro_1	20.36	74.35	77.21	1.65	6.60	109.24	455.96	2025-12-14 23:15:08.196234
6262	sensor_cilantro_2	20.10	77.06	68.70	1.66	6.40	104.50	473.32	2025-12-14 23:15:08.196438
6263	sensor_rabano_1	22.21	60.57	61.95	1.90	6.60	108.75	489.07	2025-12-14 23:15:18.206755
6264	sensor_rabano_2	23.61	59.06	79.67	1.54	6.61	64.34	489.53	2025-12-14 23:15:18.207595
6265	sensor_cilantro_1	22.91	70.83	68.63	1.52	6.78	65.19	489.51	2025-12-14 23:15:18.207827
6266	sensor_cilantro_2	20.16	67.45	65.28	1.91	6.78	144.32	414.10	2025-12-14 23:15:18.20798
6267	sensor_rabano_1	22.53	69.25	79.06	1.99	6.50	115.41	465.34	2025-12-14 23:15:28.219193
6268	sensor_rabano_2	20.42	61.22	71.09	1.74	6.75	88.71	467.29	2025-12-14 23:15:28.22017
6269	sensor_cilantro_1	19.62	68.32	70.22	1.78	6.69	136.35	462.84	2025-12-14 23:15:28.220553
6270	sensor_cilantro_2	19.44	72.04	64.63	1.76	6.51	188.78	452.94	2025-12-14 23:15:28.220822
6271	sensor_rabano_1	22.77	63.23	71.51	1.45	6.49	191.58	461.85	2025-12-14 23:15:38.232222
6272	sensor_rabano_2	22.76	59.39	76.00	1.76	6.65	160.24	414.99	2025-12-14 23:15:38.233009
6273	sensor_cilantro_1	19.49	62.31	60.37	1.99	6.64	95.12	411.80	2025-12-14 23:15:38.233198
6274	sensor_cilantro_2	20.16	65.48	66.80	1.83	6.52	186.55	450.91	2025-12-14 23:15:38.233342
6275	sensor_rabano_1	23.74	60.43	60.09	1.55	6.52	135.21	431.45	2025-12-14 23:15:48.244898
6276	sensor_rabano_2	23.39	70.18	74.74	1.81	6.41	149.50	468.68	2025-12-14 23:15:48.245705
6277	sensor_cilantro_1	20.40	64.74	76.37	1.67	6.79	65.71	485.65	2025-12-14 23:15:48.2459
6278	sensor_cilantro_2	21.51	72.32	68.10	1.47	6.62	98.02	470.61	2025-12-14 23:15:48.246044
6279	sensor_rabano_1	20.05	58.22	76.35	1.85	6.69	157.36	411.76	2025-12-14 23:15:58.256636
6280	sensor_rabano_2	22.18	69.53	70.44	1.41	6.67	171.55	412.27	2025-12-14 23:15:58.257441
6281	sensor_cilantro_1	22.37	76.43	67.26	1.89	6.75	105.49	414.38	2025-12-14 23:15:58.257711
6282	sensor_cilantro_2	22.30	73.65	72.80	1.70	6.45	151.14	439.52	2025-12-14 23:15:58.257866
6283	sensor_rabano_1	23.26	62.91	67.91	1.88	6.44	127.10	441.01	2025-12-14 23:16:08.268487
6284	sensor_rabano_2	20.97	57.24	61.68	1.67	6.57	190.39	492.79	2025-12-14 23:16:08.269331
6285	sensor_cilantro_1	20.65	64.73	72.63	1.55	6.72	192.26	451.19	2025-12-14 23:16:08.269591
6286	sensor_cilantro_2	22.82	62.44	75.14	1.75	6.51	86.52	468.53	2025-12-14 23:16:08.269852
6287	sensor_rabano_1	22.55	61.10	62.27	1.88	6.77	188.32	462.74	2025-12-14 23:16:18.281251
6288	sensor_rabano_2	23.20	57.14	61.50	1.75	6.50	162.07	432.17	2025-12-14 23:16:18.281968
6289	sensor_cilantro_1	21.73	70.04	70.08	1.64	6.70	174.57	471.22	2025-12-14 23:16:18.282149
6290	sensor_cilantro_2	20.87	72.96	61.91	1.88	6.45	95.26	469.23	2025-12-14 23:16:18.282292
6291	sensor_rabano_1	23.20	58.02	61.98	1.54	6.76	65.48	470.82	2025-12-14 23:16:28.293163
6292	sensor_rabano_2	22.65	59.10	62.36	1.85	6.61	79.65	494.12	2025-12-14 23:16:28.293927
6293	sensor_cilantro_1	19.86	75.97	68.00	1.88	6.67	144.39	416.70	2025-12-14 23:16:28.29411
6294	sensor_cilantro_2	20.37	74.38	66.25	1.50	6.54	110.40	480.00	2025-12-14 23:16:28.294251
6295	sensor_rabano_1	20.83	57.43	64.15	1.79	6.67	80.81	434.96	2025-12-14 23:16:38.305249
6296	sensor_rabano_2	20.11	60.18	60.34	1.62	6.47	152.19	432.42	2025-12-14 23:16:38.306133
6297	sensor_cilantro_1	21.83	74.38	75.85	1.52	6.55	185.61	463.88	2025-12-14 23:16:38.306319
6298	sensor_cilantro_2	21.65	69.57	65.74	1.42	6.41	109.70	491.06	2025-12-14 23:16:38.306553
6299	sensor_rabano_1	23.46	67.85	78.23	1.89	6.70	156.96	435.48	2025-12-14 23:16:48.317381
6300	sensor_rabano_2	23.23	66.42	77.53	1.99	6.41	87.65	466.95	2025-12-14 23:16:48.318269
6301	sensor_cilantro_1	20.84	67.13	66.20	1.99	6.62	62.66	455.75	2025-12-14 23:16:48.318472
6302	sensor_cilantro_2	22.30	77.36	63.58	1.42	6.64	143.87	422.96	2025-12-14 23:16:48.318685
6303	sensor_rabano_1	20.15	69.00	75.32	1.96	6.47	53.35	462.52	2025-12-14 23:16:58.329739
6304	sensor_rabano_2	22.25	71.45	65.79	1.85	6.60	149.23	483.94	2025-12-14 23:16:58.330586
6305	sensor_cilantro_1	20.23	70.30	75.67	1.64	6.76	98.03	400.23	2025-12-14 23:16:58.330771
6306	sensor_cilantro_2	20.43	70.16	72.69	1.58	6.51	86.36	446.43	2025-12-14 23:16:58.330917
6307	sensor_rabano_1	23.93	62.67	66.97	1.88	6.69	164.27	452.44	2025-12-14 23:17:08.341274
6308	sensor_rabano_2	21.18	71.02	68.90	1.87	6.56	97.19	441.39	2025-12-14 23:17:08.342077
6309	sensor_cilantro_1	19.03	67.35	73.50	1.52	6.50	141.65	418.55	2025-12-14 23:17:08.34227
6310	sensor_cilantro_2	19.86	74.18	77.84	1.47	6.75	108.53	486.92	2025-12-14 23:17:08.342425
6311	sensor_rabano_1	20.40	70.75	60.54	1.43	6.50	61.69	421.17	2025-12-14 23:17:18.352452
6312	sensor_rabano_2	20.91	72.30	71.88	1.99	6.57	131.02	488.16	2025-12-14 23:17:18.353172
6313	sensor_cilantro_1	21.69	69.97	72.30	1.53	6.49	198.48	412.39	2025-12-14 23:17:18.353337
6314	sensor_cilantro_2	20.08	76.95	69.72	1.87	6.80	114.70	464.57	2025-12-14 23:17:18.353422
6315	sensor_rabano_1	22.08	69.12	62.91	1.99	6.78	102.81	434.51	2025-12-14 23:17:28.362349
6316	sensor_rabano_2	23.29	58.06	78.33	1.82	6.48	97.22	477.87	2025-12-14 23:17:28.363049
6317	sensor_cilantro_1	19.56	69.77	65.90	1.93	6.75	190.78	441.96	2025-12-14 23:17:28.363141
6318	sensor_cilantro_2	21.42	76.01	69.33	1.89	6.57	62.73	414.67	2025-12-14 23:17:28.363197
6319	sensor_rabano_1	22.62	61.01	62.79	1.84	6.60	139.95	443.23	2025-12-14 23:17:38.370558
6320	sensor_rabano_2	20.02	72.25	78.22	1.60	6.65	143.88	498.29	2025-12-14 23:17:38.371027
6321	sensor_cilantro_1	20.14	69.45	61.04	1.49	6.65	147.68	435.79	2025-12-14 23:17:38.371104
6322	sensor_cilantro_2	19.19	62.13	75.33	1.90	6.47	125.56	424.22	2025-12-14 23:17:38.371161
6323	sensor_rabano_1	21.17	64.09	69.62	1.60	6.67	65.13	446.39	2025-12-14 23:17:48.379044
6324	sensor_rabano_2	20.46	59.62	61.17	1.96	6.78	173.42	427.86	2025-12-14 23:17:48.379561
6325	sensor_cilantro_1	19.57	66.65	67.88	1.93	6.76	94.12	494.47	2025-12-14 23:17:48.37973
6326	sensor_cilantro_2	21.61	70.54	74.20	1.65	6.63	194.03	478.77	2025-12-14 23:17:48.37981
6327	sensor_rabano_1	22.00	61.03	73.87	1.79	6.76	119.42	418.31	2025-12-14 23:17:58.386881
6328	sensor_rabano_2	22.69	66.02	78.02	1.46	6.58	197.08	471.56	2025-12-14 23:17:58.387348
6329	sensor_cilantro_1	19.08	64.82	78.56	1.97	6.42	144.51	458.38	2025-12-14 23:17:58.387485
6330	sensor_cilantro_2	22.05	66.62	68.17	1.77	6.74	64.43	450.31	2025-12-14 23:17:58.387575
6331	sensor_rabano_1	22.29	66.68	77.97	1.92	6.52	87.10	475.50	2025-12-14 23:18:08.398485
6332	sensor_rabano_2	21.51	69.68	75.30	1.76	6.70	66.35	409.32	2025-12-14 23:18:08.399331
6333	sensor_cilantro_1	20.19	72.57	64.07	1.90	6.52	115.62	449.30	2025-12-14 23:18:08.399571
6334	sensor_cilantro_2	20.40	69.42	66.79	1.50	6.79	182.28	496.90	2025-12-14 23:18:08.399729
6335	sensor_rabano_1	23.08	61.87	73.20	1.53	6.52	110.84	439.56	2025-12-14 23:18:18.409457
6336	sensor_rabano_2	21.50	57.51	64.52	1.93	6.66	106.81	413.63	2025-12-14 23:18:18.410306
6337	sensor_cilantro_1	19.07	77.83	67.67	1.87	6.69	196.56	415.64	2025-12-14 23:18:18.410506
6338	sensor_cilantro_2	19.46	66.53	66.85	1.58	6.44	127.27	413.22	2025-12-14 23:18:18.41066
6339	sensor_rabano_1	21.55	65.59	73.09	1.55	6.49	185.86	418.81	2025-12-14 23:18:28.421462
6340	sensor_rabano_2	22.49	65.07	69.30	1.53	6.62	173.02	453.31	2025-12-14 23:18:28.422439
6341	sensor_cilantro_1	21.46	69.33	78.34	1.98	6.71	77.58	490.23	2025-12-14 23:18:28.422746
6342	sensor_cilantro_2	21.63	73.98	63.56	1.99	6.42	163.39	496.74	2025-12-14 23:18:28.422998
6343	sensor_rabano_1	22.71	70.09	76.02	1.94	6.41	75.12	439.91	2025-12-14 23:18:38.434454
6344	sensor_rabano_2	22.53	70.63	65.98	1.81	6.40	120.91	413.47	2025-12-14 23:18:38.435293
6345	sensor_cilantro_1	20.25	69.51	73.15	1.94	6.72	187.52	411.14	2025-12-14 23:18:38.435489
6346	sensor_cilantro_2	19.08	74.84	73.02	1.43	6.50	187.08	457.61	2025-12-14 23:18:38.435735
6347	sensor_rabano_1	23.91	57.50	77.43	1.79	6.46	95.04	448.67	2025-12-14 23:18:48.446518
6348	sensor_rabano_2	23.26	71.95	65.69	1.44	6.42	161.49	493.93	2025-12-14 23:18:48.447304
6349	sensor_cilantro_1	19.34	65.85	70.91	1.96	6.77	141.83	428.66	2025-12-14 23:18:48.44741
6350	sensor_cilantro_2	22.96	72.50	73.25	1.95	6.47	116.42	430.06	2025-12-14 23:18:48.447557
6351	sensor_rabano_1	23.00	70.33	67.47	1.63	6.61	77.35	481.50	2025-12-14 23:18:58.455833
6352	sensor_rabano_2	20.82	69.30	61.21	1.83	6.47	191.58	435.48	2025-12-14 23:18:58.456406
6353	sensor_cilantro_1	19.67	71.12	62.72	1.57	6.68	55.08	404.56	2025-12-14 23:18:58.456485
6354	sensor_cilantro_2	22.94	72.66	66.86	1.77	6.52	154.00	478.64	2025-12-14 23:18:58.456542
6355	sensor_rabano_1	21.20	69.41	74.62	1.60	6.44	172.12	494.93	2025-12-14 23:19:08.464134
6356	sensor_rabano_2	20.70	70.40	65.46	1.66	6.58	79.41	406.47	2025-12-14 23:19:08.464624
6357	sensor_cilantro_1	21.09	66.57	74.54	1.93	6.55	159.10	453.78	2025-12-14 23:19:08.464708
6358	sensor_cilantro_2	21.29	69.39	75.10	1.55	6.69	87.21	404.50	2025-12-14 23:19:08.464764
6359	sensor_rabano_1	23.08	64.21	66.42	1.46	6.55	87.69	453.76	2025-12-14 23:19:18.475735
6360	sensor_rabano_2	21.67	61.54	72.39	1.49	6.69	186.96	429.17	2025-12-14 23:19:18.476547
6361	sensor_cilantro_1	20.65	70.58	72.97	1.46	6.58	81.10	411.27	2025-12-14 23:19:18.476916
6362	sensor_cilantro_2	19.34	74.55	75.21	1.88	6.56	71.33	462.60	2025-12-14 23:19:18.477149
6363	sensor_rabano_1	21.34	68.38	78.78	1.67	6.76	198.54	493.66	2025-12-14 23:19:28.487925
6364	sensor_rabano_2	22.50	66.86	67.54	1.49	6.76	133.81	445.90	2025-12-14 23:19:28.488708
6365	sensor_cilantro_1	21.94	63.84	75.00	1.69	6.72	126.04	420.61	2025-12-14 23:19:28.488896
6366	sensor_cilantro_2	21.50	65.49	68.40	1.53	6.73	199.02	438.27	2025-12-14 23:19:28.489038
6367	sensor_rabano_1	23.78	70.20	71.30	1.89	6.64	112.64	449.27	2025-12-14 23:19:38.500079
6368	sensor_rabano_2	22.21	63.11	68.21	1.92	6.74	150.36	473.20	2025-12-14 23:19:38.50087
6369	sensor_cilantro_1	21.35	68.60	68.46	1.68	6.54	187.24	473.05	2025-12-14 23:19:38.501058
6370	sensor_cilantro_2	19.13	71.02	67.91	1.61	6.52	174.13	497.59	2025-12-14 23:19:38.5012
6371	sensor_rabano_1	23.08	60.49	67.63	1.42	6.75	194.72	423.01	2025-12-14 23:19:48.512174
6372	sensor_rabano_2	20.30	67.29	61.10	1.46	6.74	155.14	474.69	2025-12-14 23:19:48.513006
6373	sensor_cilantro_1	20.92	74.78	66.39	1.53	6.67	139.39	407.12	2025-12-14 23:19:48.513195
6374	sensor_cilantro_2	20.46	74.45	69.53	1.92	6.70	178.27	493.14	2025-12-14 23:19:48.51334
6375	sensor_rabano_1	23.92	57.22	78.54	1.50	6.63	103.23	484.77	2025-12-14 23:19:58.598236
6376	sensor_rabano_2	23.91	58.52	73.36	1.80	6.52	127.52	489.97	2025-12-14 23:19:58.5987
6377	sensor_cilantro_1	19.28	74.88	66.30	1.73	6.56	125.80	487.75	2025-12-14 23:19:58.598794
6378	sensor_cilantro_2	20.61	76.58	79.27	1.62	6.48	65.61	466.95	2025-12-14 23:19:58.598852
6379	sensor_rabano_1	20.72	57.79	60.33	1.61	6.76	124.11	469.63	2025-12-14 23:20:08.609182
6380	sensor_rabano_2	23.26	71.25	76.88	1.95	6.54	114.14	411.35	2025-12-14 23:20:08.60997
6381	sensor_cilantro_1	20.38	68.82	77.16	1.91	6.51	153.66	452.76	2025-12-14 23:20:08.610158
6382	sensor_cilantro_2	20.28	62.19	70.43	1.41	6.80	122.05	428.59	2025-12-14 23:20:08.610302
6383	sensor_rabano_1	23.78	62.44	65.26	1.99	6.77	195.10	469.60	2025-12-14 23:20:18.621292
6384	sensor_rabano_2	23.27	70.92	69.08	1.73	6.53	183.15	454.75	2025-12-14 23:20:18.622159
6385	sensor_cilantro_1	20.98	64.14	64.28	1.92	6.56	52.15	449.36	2025-12-14 23:20:18.622345
6386	sensor_cilantro_2	20.17	70.31	70.27	1.62	6.62	143.29	401.18	2025-12-14 23:20:18.622506
6387	sensor_rabano_1	23.31	69.81	62.92	1.43	6.41	77.47	485.02	2025-12-14 23:20:28.632977
6388	sensor_rabano_2	20.53	62.03	68.68	1.85	6.60	109.94	474.38	2025-12-14 23:20:28.633795
6389	sensor_cilantro_1	20.04	70.84	65.54	1.71	6.77	54.63	415.31	2025-12-14 23:20:28.633985
6390	sensor_cilantro_2	19.06	74.91	76.99	1.49	6.55	65.92	464.80	2025-12-14 23:20:28.634132
6391	sensor_rabano_1	23.86	61.00	72.32	1.93	6.45	66.15	445.68	2025-12-14 23:20:38.645002
6392	sensor_rabano_2	21.06	68.55	73.23	1.50	6.72	92.23	470.61	2025-12-14 23:20:38.645765
6393	sensor_cilantro_1	19.56	62.76	70.63	1.63	6.60	82.56	443.54	2025-12-14 23:20:38.645995
6394	sensor_cilantro_2	22.85	71.90	66.64	1.94	6.56	127.18	402.94	2025-12-14 23:20:38.646153
6395	sensor_rabano_1	21.17	67.77	60.10	1.68	6.54	55.84	480.84	2025-12-14 23:20:48.656428
6396	sensor_rabano_2	21.18	68.55	64.03	1.87	6.73	155.04	466.82	2025-12-14 23:20:48.657314
6397	sensor_cilantro_1	21.35	77.01	65.77	1.67	6.70	70.10	466.58	2025-12-14 23:20:48.657517
6398	sensor_cilantro_2	22.06	64.68	64.51	1.63	6.54	73.63	461.75	2025-12-14 23:20:48.657744
6399	sensor_rabano_1	23.99	66.27	77.36	1.44	6.53	159.29	465.82	2025-12-14 23:20:58.669196
6400	sensor_rabano_2	20.69	71.01	78.00	1.74	6.56	131.85	464.14	2025-12-14 23:20:58.66994
6401	sensor_cilantro_1	20.93	68.74	61.30	1.61	6.80	107.10	455.98	2025-12-14 23:20:58.670122
6402	sensor_cilantro_2	19.43	66.50	68.39	1.73	6.77	103.14	484.79	2025-12-14 23:20:58.670259
6403	sensor_rabano_1	22.47	70.64	67.36	1.45	6.70	151.54	460.60	2025-12-14 23:21:08.681
6404	sensor_rabano_2	22.01	70.26	65.93	1.69	6.50	55.96	460.57	2025-12-14 23:21:08.681917
6405	sensor_cilantro_1	20.16	68.30	75.26	1.61	6.76	146.20	475.42	2025-12-14 23:21:08.682254
6406	sensor_cilantro_2	20.89	63.93	64.31	1.54	6.52	183.84	469.84	2025-12-14 23:21:08.682407
6407	sensor_rabano_1	21.21	62.38	60.77	1.40	6.69	102.05	461.06	2025-12-14 23:21:18.693495
6408	sensor_rabano_2	22.55	69.22	72.03	1.87	6.67	89.82	403.45	2025-12-14 23:21:18.694465
6409	sensor_cilantro_1	19.34	63.11	65.52	1.89	6.48	146.64	458.07	2025-12-14 23:21:18.694771
6410	sensor_cilantro_2	19.74	64.65	66.34	1.64	6.62	144.41	443.89	2025-12-14 23:21:18.694969
6411	sensor_rabano_1	23.31	66.52	64.87	1.92	6.69	139.06	412.03	2025-12-14 23:21:28.705659
6412	sensor_rabano_2	20.09	59.77	66.15	1.57	6.68	67.01	425.50	2025-12-14 23:21:28.706454
6413	sensor_cilantro_1	21.53	77.36	65.61	1.63	6.47	160.72	471.63	2025-12-14 23:21:28.70664
6414	sensor_cilantro_2	20.57	72.86	74.18	1.72	6.60	84.94	459.76	2025-12-14 23:21:28.706783
6415	sensor_rabano_1	22.15	66.94	65.94	1.95	6.51	174.97	410.99	2025-12-14 23:21:38.717158
6416	sensor_rabano_2	20.50	62.79	67.50	1.81	6.73	59.52	470.46	2025-12-14 23:21:38.71793
6417	sensor_cilantro_1	20.49	76.02	77.69	1.77	6.42	83.92	498.87	2025-12-14 23:21:38.718035
6418	sensor_cilantro_2	22.61	73.72	67.02	1.82	6.55	93.87	428.81	2025-12-14 23:21:38.718093
6419	sensor_rabano_1	20.18	69.11	67.18	1.91	6.57	97.46	405.88	2025-12-14 23:21:48.729736
6420	sensor_rabano_2	22.01	71.72	63.91	1.78	6.53	52.20	483.02	2025-12-14 23:21:48.731665
6421	sensor_cilantro_1	19.36	77.85	79.00	1.68	6.70	183.70	432.44	2025-12-14 23:21:48.732351
6422	sensor_cilantro_2	21.88	74.16	63.36	1.49	6.46	86.36	453.22	2025-12-14 23:21:48.732698
6423	sensor_rabano_1	20.71	65.21	74.25	1.59	6.44	117.43	474.43	2025-12-14 23:21:58.744197
6424	sensor_rabano_2	23.65	66.82	68.89	1.96	6.57	181.65	491.68	2025-12-14 23:21:58.745082
6425	sensor_cilantro_1	22.53	72.94	71.65	1.60	6.61	102.17	429.06	2025-12-14 23:21:58.745286
6426	sensor_cilantro_2	22.79	68.61	79.07	1.78	6.48	62.53	415.50	2025-12-14 23:21:58.745458
6427	sensor_rabano_1	22.71	62.59	75.52	1.55	6.45	149.82	490.76	2025-12-14 23:22:08.755713
6428	sensor_rabano_2	21.38	68.21	79.33	1.76	6.55	137.02	421.60	2025-12-14 23:22:08.756473
6429	sensor_cilantro_1	22.07	68.71	76.63	1.86	6.64	150.85	492.28	2025-12-14 23:22:08.756893
6430	sensor_cilantro_2	19.20	64.26	61.49	1.97	6.62	82.36	419.55	2025-12-14 23:22:08.757242
6431	sensor_rabano_1	20.16	67.82	61.92	1.45	6.56	135.71	418.48	2025-12-14 23:22:18.767369
6432	sensor_rabano_2	23.33	62.96	66.79	1.91	6.41	131.95	491.69	2025-12-14 23:22:18.768236
6433	sensor_cilantro_1	22.00	74.87	71.16	1.98	6.77	141.56	469.71	2025-12-14 23:22:18.768427
6434	sensor_cilantro_2	21.51	77.52	71.12	1.70	6.70	183.25	447.64	2025-12-14 23:22:18.768637
6435	sensor_rabano_1	22.11	72.36	76.39	1.81	6.45	149.82	417.46	2025-12-14 23:22:28.779018
6436	sensor_rabano_2	20.48	70.59	67.42	1.81	6.60	70.93	423.59	2025-12-14 23:22:28.779741
6437	sensor_cilantro_1	19.86	71.54	70.52	1.94	6.73	171.19	405.66	2025-12-14 23:22:28.779931
6438	sensor_cilantro_2	22.20	69.50	68.21	1.58	6.58	51.86	451.78	2025-12-14 23:22:28.780076
6439	sensor_rabano_1	23.46	65.91	74.26	1.90	6.73	67.81	412.04	2025-12-14 23:22:38.790392
6440	sensor_rabano_2	23.60	57.04	66.02	1.50	6.59	71.17	411.43	2025-12-14 23:22:38.791305
6441	sensor_cilantro_1	21.92	67.93	75.88	1.50	6.55	176.91	495.77	2025-12-14 23:22:38.791638
6442	sensor_cilantro_2	21.95	70.64	61.40	1.72	6.79	122.96	487.65	2025-12-14 23:22:38.79194
6443	sensor_rabano_1	22.76	70.52	73.43	1.99	6.71	133.57	481.55	2025-12-14 23:22:48.802397
6444	sensor_rabano_2	21.46	64.30	76.35	1.49	6.52	75.80	403.03	2025-12-14 23:22:48.803301
6445	sensor_cilantro_1	22.75	77.73	70.83	1.85	6.48	71.91	478.68	2025-12-14 23:22:48.803548
6446	sensor_cilantro_2	22.09	65.29	63.36	1.55	6.74	118.24	459.09	2025-12-14 23:22:48.803827
6447	sensor_rabano_1	20.66	57.18	77.61	1.70	6.60	55.78	483.82	2025-12-14 23:22:58.814276
6448	sensor_rabano_2	21.53	68.35	68.20	1.97	6.67	92.01	410.21	2025-12-14 23:22:58.815164
6449	sensor_cilantro_1	22.56	66.69	60.75	1.71	6.75	91.80	454.59	2025-12-14 23:22:58.815393
6450	sensor_cilantro_2	21.36	67.99	75.37	1.50	6.56	143.77	493.68	2025-12-14 23:22:58.815621
6451	sensor_rabano_1	20.75	67.63	71.06	1.77	6.46	175.86	493.23	2025-12-14 23:23:08.826902
6452	sensor_rabano_2	21.86	64.29	67.69	1.84	6.41	86.15	400.53	2025-12-14 23:23:08.827837
6453	sensor_cilantro_1	21.16	71.36	71.27	1.51	6.68	146.95	430.59	2025-12-14 23:23:08.828065
6454	sensor_cilantro_2	19.87	73.00	63.19	1.79	6.41	69.61	489.28	2025-12-14 23:23:08.828248
6455	sensor_rabano_1	21.35	71.29	78.88	1.51	6.62	139.83	476.59	2025-12-14 23:23:18.839073
6456	sensor_rabano_2	23.45	64.02	65.06	1.49	6.57	111.97	402.51	2025-12-14 23:23:18.839886
6457	sensor_cilantro_1	20.61	77.70	61.38	1.52	6.53	163.01	475.80	2025-12-14 23:23:18.840082
6458	sensor_cilantro_2	19.68	64.72	69.98	1.83	6.65	150.50	439.10	2025-12-14 23:23:18.840225
6459	sensor_rabano_1	23.01	71.20	74.03	1.62	6.67	199.25	409.98	2025-12-14 23:23:28.851452
6460	sensor_rabano_2	20.54	64.17	64.69	1.48	6.45	58.01	423.83	2025-12-14 23:23:28.852329
6461	sensor_cilantro_1	20.72	73.11	72.34	1.67	6.79	93.00	422.84	2025-12-14 23:23:28.852539
6462	sensor_cilantro_2	22.12	62.89	65.37	1.88	6.65	182.06	444.59	2025-12-14 23:23:28.852778
6463	sensor_rabano_1	21.84	60.36	67.94	1.95	6.48	164.33	457.09	2025-12-14 23:23:38.86263
6464	sensor_rabano_2	22.84	61.46	68.56	1.60	6.78	129.71	426.07	2025-12-14 23:23:38.863225
6465	sensor_cilantro_1	21.48	67.62	75.89	1.79	6.65	168.78	490.21	2025-12-14 23:23:38.863309
6466	sensor_cilantro_2	19.44	67.21	60.55	1.95	6.52	64.36	422.16	2025-12-14 23:23:38.863366
6467	sensor_rabano_1	23.46	57.89	65.61	1.81	6.64	54.85	462.06	2025-12-14 23:23:48.872631
6468	sensor_rabano_2	22.21	69.26	64.53	1.48	6.79	126.43	431.97	2025-12-14 23:23:48.873547
6469	sensor_cilantro_1	19.19	74.31	77.45	1.64	6.76	129.24	482.12	2025-12-14 23:23:48.873819
6470	sensor_cilantro_2	21.62	72.24	78.65	1.61	6.51	97.76	465.83	2025-12-14 23:23:48.87402
6471	sensor_rabano_1	20.36	67.41	71.47	1.74	6.63	179.38	405.70	2025-12-14 23:23:58.882645
6472	sensor_rabano_2	22.93	60.52	78.45	1.73	6.66	143.84	438.40	2025-12-14 23:23:58.883276
6473	sensor_cilantro_1	19.61	65.35	75.14	1.72	6.62	67.13	442.98	2025-12-14 23:23:58.883383
6474	sensor_cilantro_2	19.30	72.61	72.19	1.58	6.41	134.68	484.07	2025-12-14 23:23:58.883457
6475	sensor_rabano_1	21.07	65.26	62.47	1.71	6.51	156.33	405.67	2025-12-14 23:24:08.893862
6476	sensor_rabano_2	23.02	71.82	62.71	1.73	6.75	139.42	493.77	2025-12-14 23:24:08.894718
6477	sensor_cilantro_1	22.38	73.99	67.83	1.91	6.47	54.71	406.85	2025-12-14 23:24:08.894926
6478	sensor_cilantro_2	22.59	69.01	62.86	1.97	6.72	189.53	486.70	2025-12-14 23:24:08.89507
6479	sensor_rabano_1	20.14	63.13	74.22	1.83	6.44	179.52	461.57	2025-12-14 23:24:18.906113
6480	sensor_rabano_2	20.12	59.65	60.85	1.72	6.51	198.93	478.16	2025-12-14 23:24:18.907548
6481	sensor_cilantro_1	20.42	63.42	66.94	1.59	6.53	183.38	442.46	2025-12-14 23:24:18.907896
6482	sensor_cilantro_2	19.97	75.83	70.24	1.50	6.68	89.13	457.04	2025-12-14 23:24:18.908145
6483	sensor_rabano_1	22.42	72.49	69.99	1.91	6.62	66.28	462.18	2025-12-14 23:24:28.918709
6484	sensor_rabano_2	20.07	59.44	72.96	1.89	6.75	80.10	432.78	2025-12-14 23:24:28.919546
6485	sensor_cilantro_1	22.81	69.95	74.45	1.68	6.49	165.08	418.28	2025-12-14 23:24:28.919822
6486	sensor_cilantro_2	20.49	65.17	71.92	1.70	6.70	128.35	470.34	2025-12-14 23:24:28.920031
6487	sensor_rabano_1	22.29	59.07	76.26	1.94	6.65	86.71	426.11	2025-12-14 23:24:38.93084
6488	sensor_rabano_2	21.83	65.56	63.90	1.65	6.59	132.45	420.35	2025-12-14 23:24:38.931608
6489	sensor_cilantro_1	22.59	65.85	71.42	1.43	6.44	95.94	482.07	2025-12-14 23:24:38.931788
6490	sensor_cilantro_2	22.03	68.15	66.81	1.82	6.54	120.79	461.93	2025-12-14 23:24:38.931928
6491	sensor_rabano_1	20.67	60.37	72.56	1.70	6.55	84.72	461.43	2025-12-14 23:24:48.942462
6492	sensor_rabano_2	23.56	69.94	72.42	1.48	6.78	193.19	415.45	2025-12-14 23:24:48.943319
6493	sensor_cilantro_1	20.55	62.93	61.67	1.68	6.57	187.07	457.23	2025-12-14 23:24:48.943538
6494	sensor_cilantro_2	19.98	71.06	69.02	1.61	6.57	199.73	421.71	2025-12-14 23:24:48.943752
6495	sensor_rabano_1	23.74	59.62	74.41	1.47	6.46	190.76	465.91	2025-12-14 23:24:59.042126
6496	sensor_rabano_2	22.73	60.97	63.73	1.99	6.55	110.52	495.68	2025-12-14 23:24:59.043012
6497	sensor_cilantro_1	20.78	65.03	76.03	1.61	6.43	98.42	446.98	2025-12-14 23:24:59.043198
6498	sensor_cilantro_2	20.42	75.12	65.44	1.70	6.46	171.51	497.26	2025-12-14 23:24:59.043345
6499	sensor_rabano_1	21.91	72.44	76.01	1.54	6.59	94.78	408.76	2025-12-14 23:25:09.052775
6500	sensor_rabano_2	23.59	69.98	71.56	1.89	6.59	105.31	490.02	2025-12-14 23:25:09.053389
6501	sensor_cilantro_1	20.97	62.26	73.64	1.80	6.67	67.74	408.67	2025-12-14 23:25:09.053488
6502	sensor_cilantro_2	20.46	70.41	66.68	1.46	6.62	135.59	451.99	2025-12-14 23:25:09.053557
6503	sensor_rabano_1	20.05	61.59	72.21	1.71	6.53	117.13	485.48	2025-12-14 23:25:19.063747
6504	sensor_rabano_2	23.57	62.78	61.90	1.42	6.77	150.11	469.40	2025-12-14 23:25:19.064275
6505	sensor_cilantro_1	19.74	64.98	76.28	1.84	6.69	108.55	433.67	2025-12-14 23:25:19.064362
6506	sensor_cilantro_2	22.63	66.73	71.06	1.45	6.47	62.58	464.59	2025-12-14 23:25:19.064478
6507	sensor_rabano_1	22.82	60.69	60.88	1.73	6.41	94.80	498.38	2025-12-14 23:25:29.0749
6508	sensor_rabano_2	21.23	68.87	69.95	1.40	6.80	175.08	457.16	2025-12-14 23:25:29.075698
6509	sensor_cilantro_1	19.16	73.31	72.00	1.62	6.59	138.13	426.90	2025-12-14 23:25:29.075892
6510	sensor_cilantro_2	22.87	65.55	70.64	1.64	6.77	186.43	413.16	2025-12-14 23:25:29.07604
6511	sensor_rabano_1	21.27	60.05	64.62	1.88	6.55	100.28	456.02	2025-12-14 23:25:39.087387
6512	sensor_rabano_2	21.17	70.14	65.54	1.59	6.79	157.30	457.30	2025-12-14 23:25:39.088263
6513	sensor_cilantro_1	21.75	71.99	64.80	1.96	6.45	53.63	424.83	2025-12-14 23:25:39.088461
6514	sensor_cilantro_2	22.92	69.88	74.48	1.83	6.49	166.88	477.02	2025-12-14 23:25:39.088616
6515	sensor_rabano_1	22.10	64.17	60.82	1.77	6.58	55.41	458.83	2025-12-14 23:25:49.09994
6516	sensor_rabano_2	23.37	71.79	68.42	1.58	6.73	76.80	444.17	2025-12-14 23:25:49.100678
6517	sensor_cilantro_1	22.57	72.77	71.45	1.93	6.64	122.69	400.49	2025-12-14 23:25:49.100866
6518	sensor_cilantro_2	20.31	62.37	65.29	1.47	6.58	145.30	447.85	2025-12-14 23:25:49.10102
6519	sensor_rabano_1	23.89	60.21	75.44	1.43	6.48	96.83	440.15	2025-12-14 23:25:59.112391
6520	sensor_rabano_2	23.50	60.16	61.48	1.45	6.60	122.71	470.94	2025-12-14 23:25:59.113228
6521	sensor_cilantro_1	20.88	62.20	72.89	1.72	6.55	72.40	463.44	2025-12-14 23:25:59.113409
6522	sensor_cilantro_2	22.51	77.26	72.69	1.80	6.68	89.37	447.67	2025-12-14 23:25:59.11356
6523	sensor_rabano_1	22.73	68.85	79.04	1.71	6.77	119.08	483.85	2025-12-14 23:26:09.125328
6524	sensor_rabano_2	20.47	70.12	65.66	1.56	6.48	107.51	436.12	2025-12-14 23:26:09.126151
6525	sensor_cilantro_1	20.65	65.13	66.45	1.53	6.58	85.02	457.68	2025-12-14 23:26:09.12635
6526	sensor_cilantro_2	22.50	73.29	63.75	1.98	6.74	79.46	481.36	2025-12-14 23:26:09.126526
6527	sensor_rabano_1	22.79	59.82	67.72	1.41	6.61	178.21	490.07	2025-12-14 23:26:19.136946
6528	sensor_rabano_2	22.85	66.35	73.51	1.69	6.51	196.48	426.92	2025-12-14 23:26:19.137757
6529	sensor_cilantro_1	22.00	64.35	69.97	1.54	6.44	54.78	405.45	2025-12-14 23:26:19.137967
6530	sensor_cilantro_2	20.14	74.65	79.67	1.51	6.51	155.87	419.31	2025-12-14 23:26:19.138138
6531	sensor_rabano_1	20.46	67.83	60.59	1.82	6.57	177.31	443.10	2025-12-14 23:26:29.149202
6532	sensor_rabano_2	23.45	72.77	64.03	1.75	6.75	68.49	411.47	2025-12-14 23:26:29.150022
6533	sensor_cilantro_1	20.88	62.54	64.14	1.89	6.61	120.94	405.74	2025-12-14 23:26:29.150253
6534	sensor_cilantro_2	21.40	72.81	72.26	1.74	6.65	80.97	402.09	2025-12-14 23:26:29.150457
6535	sensor_rabano_1	23.66	63.40	60.81	1.47	6.47	140.14	435.13	2025-12-14 23:26:39.161284
6536	sensor_rabano_2	22.15	69.97	78.34	1.62	6.48	130.58	437.61	2025-12-14 23:26:39.162077
6537	sensor_cilantro_1	21.07	72.98	76.97	1.76	6.50	143.93	426.08	2025-12-14 23:26:39.162258
6538	sensor_cilantro_2	19.92	72.69	62.71	1.68	6.80	79.33	469.33	2025-12-14 23:26:39.162409
6539	sensor_rabano_1	21.22	72.55	65.99	1.79	6.60	97.16	494.95	2025-12-14 23:26:49.173281
6540	sensor_rabano_2	21.63	63.44	67.62	1.74	6.77	151.33	453.95	2025-12-14 23:26:49.174136
6541	sensor_cilantro_1	19.96	65.78	65.04	1.92	6.73	118.00	460.78	2025-12-14 23:26:49.174245
6542	sensor_cilantro_2	20.34	74.81	60.55	1.87	6.65	94.52	440.80	2025-12-14 23:26:49.174305
6543	sensor_rabano_1	20.37	58.42	60.55	1.82	6.48	128.98	496.99	2025-12-14 23:26:59.184783
6544	sensor_rabano_2	22.48	58.82	63.55	1.57	6.65	66.63	403.11	2025-12-14 23:26:59.185503
6545	sensor_cilantro_1	22.17	74.45	74.40	1.53	6.80	133.83	414.33	2025-12-14 23:26:59.18568
6546	sensor_cilantro_2	21.81	73.71	68.40	1.71	6.65	163.54	404.48	2025-12-14 23:26:59.185823
6547	sensor_rabano_1	23.38	66.06	68.53	1.49	6.54	196.23	467.35	2025-12-14 23:27:09.194305
6548	sensor_rabano_2	21.37	72.29	78.06	1.83	6.51	148.34	411.04	2025-12-14 23:27:09.194797
6549	sensor_cilantro_1	20.37	73.41	61.08	1.89	6.60	113.65	440.29	2025-12-14 23:27:09.194882
6550	sensor_cilantro_2	21.69	62.23	62.08	1.65	6.76	187.06	409.55	2025-12-14 23:27:09.19494
6551	sensor_rabano_1	21.61	72.52	75.04	1.72	6.53	156.62	428.44	2025-12-14 23:27:19.205071
6552	sensor_rabano_2	23.04	70.00	79.70	1.50	6.53	189.43	471.92	2025-12-14 23:27:19.205824
6553	sensor_cilantro_1	20.12	76.13	77.88	1.92	6.59	175.37	426.83	2025-12-14 23:27:19.206051
6554	sensor_cilantro_2	21.10	71.07	63.79	1.86	6.42	77.55	411.76	2025-12-14 23:27:19.20621
6555	sensor_rabano_1	20.73	72.35	70.50	1.90	6.65	56.74	435.53	2025-12-14 23:27:29.217487
6556	sensor_rabano_2	23.47	64.18	60.95	1.99	6.72	123.82	479.77	2025-12-14 23:27:29.218359
6557	sensor_cilantro_1	20.94	68.15	66.42	1.43	6.76	162.83	407.58	2025-12-14 23:27:29.218565
6558	sensor_cilantro_2	19.19	71.34	63.73	1.52	6.52	145.67	498.78	2025-12-14 23:27:29.21877
6559	sensor_rabano_1	23.25	68.15	72.40	1.94	6.72	63.13	444.37	2025-12-14 23:27:39.229261
6560	sensor_rabano_2	23.33	69.11	65.40	1.89	6.51	50.06	476.07	2025-12-14 23:27:39.230108
6561	sensor_cilantro_1	20.03	66.60	71.36	1.54	6.64	198.98	477.41	2025-12-14 23:27:39.230304
6562	sensor_cilantro_2	21.32	64.96	73.52	1.50	6.48	73.35	414.70	2025-12-14 23:27:39.23046
6563	sensor_rabano_1	22.96	62.97	68.01	1.94	6.71	81.79	436.57	2025-12-14 23:27:49.241499
6564	sensor_rabano_2	23.69	72.63	66.30	1.74	6.65	188.97	449.18	2025-12-14 23:27:49.242536
6565	sensor_cilantro_1	21.29	77.55	71.99	1.98	6.41	121.52	468.87	2025-12-14 23:27:49.24274
6566	sensor_cilantro_2	20.50	63.05	60.11	1.74	6.78	153.08	440.74	2025-12-14 23:27:49.242976
6567	sensor_rabano_1	21.29	65.33	69.70	1.41	6.66	59.27	404.21	2025-12-14 23:27:59.252771
6568	sensor_rabano_2	21.99	63.44	74.03	1.69	6.73	154.03	471.41	2025-12-14 23:27:59.253508
6569	sensor_cilantro_1	20.62	64.46	67.36	1.73	6.77	58.37	418.41	2025-12-14 23:27:59.253766
6570	sensor_cilantro_2	22.51	70.65	62.33	1.84	6.44	193.29	414.97	2025-12-14 23:27:59.254003
6571	sensor_rabano_1	23.13	58.75	78.88	1.64	6.70	103.21	444.98	2025-12-14 23:28:09.264401
6572	sensor_rabano_2	22.95	66.20	75.22	1.44	6.57	54.08	435.83	2025-12-14 23:28:09.265289
6573	sensor_cilantro_1	22.56	66.93	70.27	1.74	6.66	83.23	412.21	2025-12-14 23:28:09.265531
6574	sensor_cilantro_2	22.21	63.40	75.44	1.61	6.53	84.60	402.86	2025-12-14 23:28:09.265751
6575	sensor_rabano_1	20.31	58.14	76.47	1.65	6.59	158.13	479.45	2025-12-14 23:28:19.276237
6576	sensor_rabano_2	20.13	70.92	69.33	1.94	6.48	129.28	478.65	2025-12-14 23:28:19.277156
6577	sensor_cilantro_1	21.89	63.92	73.54	1.99	6.67	129.05	428.45	2025-12-14 23:28:19.277382
6578	sensor_cilantro_2	21.74	66.05	62.06	1.84	6.65	166.69	463.03	2025-12-14 23:28:19.277653
6579	sensor_rabano_1	21.21	66.69	69.77	1.99	6.52	105.43	402.10	2025-12-14 23:28:29.28602
6580	sensor_rabano_2	23.34	57.16	77.57	1.64	6.68	187.61	472.29	2025-12-14 23:28:29.286608
6581	sensor_cilantro_1	20.58	64.41	75.20	1.84	6.67	104.27	456.35	2025-12-14 23:28:29.28676
6582	sensor_cilantro_2	19.00	65.83	65.65	1.56	6.76	142.57	476.93	2025-12-14 23:28:29.286829
6583	sensor_rabano_1	23.58	67.06	60.29	1.99	6.65	190.73	437.11	2025-12-14 23:28:39.296788
6584	sensor_rabano_2	20.36	69.14	66.45	1.62	6.62	93.31	431.33	2025-12-14 23:28:39.297502
6585	sensor_cilantro_1	21.82	68.25	70.72	1.90	6.57	116.39	426.03	2025-12-14 23:28:39.297688
6586	sensor_cilantro_2	19.54	67.72	66.81	1.51	6.47	166.05	491.85	2025-12-14 23:28:39.297827
6587	sensor_rabano_1	23.64	65.93	60.63	1.48	6.41	165.80	424.80	2025-12-14 23:28:49.307304
6588	sensor_rabano_2	22.12	65.79	62.41	1.91	6.79	123.98	448.09	2025-12-14 23:28:49.307979
6589	sensor_cilantro_1	19.10	75.67	75.10	1.50	6.70	66.28	477.74	2025-12-14 23:28:49.308059
6590	sensor_cilantro_2	20.59	62.46	67.67	1.85	6.73	54.46	438.81	2025-12-14 23:28:49.308117
6591	sensor_rabano_1	23.72	72.95	75.92	1.56	6.76	68.53	430.73	2025-12-14 23:28:59.318479
6592	sensor_rabano_2	21.49	71.25	70.76	1.69	6.47	73.80	424.13	2025-12-14 23:28:59.319284
6593	sensor_cilantro_1	21.77	68.69	65.84	1.60	6.43	90.34	430.81	2025-12-14 23:28:59.319485
6594	sensor_cilantro_2	19.25	63.34	61.63	1.93	6.70	180.33	469.13	2025-12-14 23:28:59.319689
6595	sensor_rabano_1	23.07	57.03	67.88	1.40	6.50	144.73	477.34	2025-12-14 23:29:09.329025
6596	sensor_rabano_2	23.88	70.88	61.20	1.40	6.50	75.87	491.92	2025-12-14 23:29:09.329507
6597	sensor_cilantro_1	19.59	69.72	63.16	1.53	6.67	123.08	476.39	2025-12-14 23:29:09.329598
6598	sensor_cilantro_2	19.93	72.17	78.91	1.80	6.56	121.09	410.46	2025-12-14 23:29:09.329659
6599	sensor_rabano_1	21.49	69.96	74.54	1.75	6.45	60.13	445.92	2025-12-14 23:29:19.33995
6600	sensor_rabano_2	22.66	65.46	78.26	1.51	6.48	133.80	434.09	2025-12-14 23:29:19.340717
6601	sensor_cilantro_1	22.87	69.10	72.77	1.54	6.56	82.26	411.83	2025-12-14 23:29:19.340906
6602	sensor_cilantro_2	19.50	62.05	73.92	1.70	6.40	86.22	468.00	2025-12-14 23:29:19.341052
6603	sensor_rabano_1	20.60	58.94	69.97	1.80	6.67	195.02	475.22	2025-12-14 23:29:29.349312
6604	sensor_rabano_2	20.16	69.88	74.22	1.83	6.54	65.63	443.09	2025-12-14 23:29:29.349806
6605	sensor_cilantro_1	21.34	63.05	78.55	1.74	6.67	194.79	467.26	2025-12-14 23:29:29.34989
6606	sensor_cilantro_2	21.99	76.69	73.09	1.45	6.59	99.90	442.69	2025-12-14 23:29:29.349947
6607	sensor_rabano_1	22.85	60.38	77.41	1.63	6.64	120.23	466.94	2025-12-14 23:29:39.360281
6608	sensor_rabano_2	21.41	68.91	70.29	1.52	6.53	89.55	479.64	2025-12-14 23:29:39.361122
6609	sensor_cilantro_1	20.97	72.12	74.65	1.82	6.43	102.08	456.72	2025-12-14 23:29:39.361312
6610	sensor_cilantro_2	22.20	69.69	62.64	1.45	6.54	187.79	440.98	2025-12-14 23:29:39.361466
6611	sensor_rabano_1	20.83	68.45	69.36	1.95	6.41	103.70	411.54	2025-12-14 23:29:49.372501
6612	sensor_rabano_2	22.17	66.07	68.28	1.81	6.47	62.19	405.95	2025-12-14 23:29:49.37333
6613	sensor_cilantro_1	22.38	73.13	70.86	1.66	6.69	99.56	424.16	2025-12-14 23:29:49.373576
6614	sensor_cilantro_2	22.52	67.25	73.73	1.70	6.44	94.50	451.22	2025-12-14 23:29:49.373738
6615	sensor_rabano_1	23.38	71.97	62.77	1.73	6.76	135.72	438.17	2025-12-14 23:29:59.442174
6616	sensor_rabano_2	21.86	68.00	77.93	1.50	6.52	163.21	484.79	2025-12-14 23:29:59.443082
6617	sensor_cilantro_1	22.49	67.57	69.96	1.65	6.71	146.70	411.60	2025-12-14 23:29:59.443268
6618	sensor_cilantro_2	22.27	70.00	67.81	1.83	6.66	132.26	403.37	2025-12-14 23:29:59.443421
6619	sensor_rabano_1	23.57	57.42	68.62	1.55	6.72	58.72	403.63	2025-12-14 23:30:09.454594
6620	sensor_rabano_2	23.43	72.37	74.25	1.98	6.45	131.56	482.77	2025-12-14 23:30:09.455492
6621	sensor_cilantro_1	21.64	76.94	79.14	1.85	6.51	94.24	496.98	2025-12-14 23:30:09.455771
6622	sensor_cilantro_2	19.07	68.29	73.41	1.77	6.69	102.97	498.77	2025-12-14 23:30:09.455978
6623	sensor_rabano_1	23.54	57.38	67.01	1.44	6.57	71.71	457.06	2025-12-14 23:30:19.465535
6624	sensor_rabano_2	21.59	66.98	63.64	1.53	6.72	128.09	471.89	2025-12-14 23:30:19.465988
6625	sensor_cilantro_1	19.94	71.07	65.36	1.45	6.75	113.18	481.06	2025-12-14 23:30:19.466076
6626	sensor_cilantro_2	22.12	64.56	75.71	1.90	6.76	144.65	487.87	2025-12-14 23:30:19.466134
6627	sensor_rabano_1	22.11	68.96	79.41	1.40	6.65	120.98	431.00	2025-12-14 23:30:29.473177
6628	sensor_rabano_2	22.72	67.15	71.28	1.50	6.77	60.61	422.99	2025-12-14 23:30:29.473667
6629	sensor_cilantro_1	21.44	69.03	79.55	1.90	6.63	136.20	419.79	2025-12-14 23:30:29.473754
6630	sensor_cilantro_2	20.15	77.46	71.48	1.83	6.65	118.70	464.16	2025-12-14 23:30:29.473813
6631	sensor_rabano_1	20.77	66.67	72.22	1.77	6.63	97.31	466.00	2025-12-14 23:30:39.48225
6632	sensor_rabano_2	20.15	57.86	64.40	1.41	6.69	106.49	426.87	2025-12-14 23:30:39.482702
6633	sensor_cilantro_1	22.02	62.83	62.90	1.72	6.46	195.45	401.87	2025-12-14 23:30:39.482809
6634	sensor_cilantro_2	21.30	62.73	75.59	1.69	6.65	161.04	405.57	2025-12-14 23:30:39.482867
6635	sensor_rabano_1	20.15	61.79	79.04	1.91	6.50	79.83	441.75	2025-12-14 23:30:49.493495
6636	sensor_rabano_2	23.66	64.59	62.13	1.57	6.60	141.10	466.12	2025-12-14 23:30:49.494343
6637	sensor_cilantro_1	22.48	66.23	76.07	1.43	6.72	133.87	494.09	2025-12-14 23:30:49.494481
6638	sensor_cilantro_2	22.18	71.30	61.68	1.75	6.54	110.17	426.00	2025-12-14 23:30:49.494634
6639	sensor_rabano_1	22.25	59.47	66.68	1.67	6.74	76.22	407.76	2025-12-14 23:30:59.503618
6640	sensor_rabano_2	21.93	59.44	74.18	1.79	6.64	67.19	452.05	2025-12-14 23:30:59.504196
6641	sensor_cilantro_1	20.31	77.81	71.56	1.99	6.63	117.70	472.55	2025-12-14 23:30:59.504291
6642	sensor_cilantro_2	22.04	62.40	79.39	1.80	6.79	78.73	430.30	2025-12-14 23:30:59.504348
6643	sensor_rabano_1	22.04	62.83	78.51	1.61	6.58	185.97	407.35	2025-12-14 23:31:09.514722
6644	sensor_rabano_2	21.20	69.33	73.24	1.53	6.50	82.77	456.95	2025-12-14 23:31:09.515551
6645	sensor_cilantro_1	21.66	66.48	76.66	1.77	6.55	81.41	447.62	2025-12-14 23:31:09.515745
6646	sensor_cilantro_2	22.10	64.43	67.44	1.74	6.53	181.03	474.87	2025-12-14 23:31:09.515889
6647	sensor_rabano_1	20.16	59.72	68.97	1.76	6.77	50.94	495.75	2025-12-14 23:31:19.527212
6648	sensor_rabano_2	22.86	61.59	73.66	1.81	6.67	71.18	447.31	2025-12-14 23:31:19.527963
6649	sensor_cilantro_1	22.91	71.77	62.81	1.53	6.64	171.05	408.43	2025-12-14 23:31:19.528143
6650	sensor_cilantro_2	22.56	62.33	66.95	1.87	6.57	82.88	443.29	2025-12-14 23:31:19.528281
6651	sensor_rabano_1	23.61	63.94	73.72	1.60	6.67	131.66	474.79	2025-12-14 23:31:29.53847
6652	sensor_rabano_2	22.50	69.54	79.80	1.80	6.76	185.22	487.67	2025-12-14 23:31:29.539267
6653	sensor_cilantro_1	19.40	64.89	72.62	1.77	6.45	176.33	465.65	2025-12-14 23:31:29.539481
6654	sensor_cilantro_2	21.72	75.68	75.95	1.97	6.74	105.88	403.46	2025-12-14 23:31:29.539642
6655	sensor_rabano_1	22.98	72.04	66.53	1.76	6.65	92.74	498.41	2025-12-14 23:31:39.550296
6656	sensor_rabano_2	23.10	71.52	65.71	1.65	6.60	173.53	454.01	2025-12-14 23:31:39.551134
6657	sensor_cilantro_1	19.53	65.14	74.04	1.66	6.72	121.68	447.30	2025-12-14 23:31:39.551314
6658	sensor_cilantro_2	20.36	73.79	76.73	1.97	6.44	82.89	487.59	2025-12-14 23:31:39.551542
6659	sensor_rabano_1	22.44	63.17	69.18	1.41	6.43	181.48	495.43	2025-12-14 23:31:49.562498
6660	sensor_rabano_2	22.15	69.08	73.38	1.67	6.53	101.13	499.20	2025-12-14 23:31:49.563271
6661	sensor_cilantro_1	21.95	72.54	76.55	1.69	6.54	137.21	481.13	2025-12-14 23:31:49.563527
6662	sensor_cilantro_2	19.50	70.93	64.07	1.72	6.66	153.71	461.90	2025-12-14 23:31:49.563733
6663	sensor_rabano_1	20.30	59.54	66.95	1.47	6.76	181.37	491.43	2025-12-14 23:31:59.574919
6664	sensor_rabano_2	22.13	57.22	77.60	1.49	6.56	117.94	427.93	2025-12-14 23:31:59.575656
6665	sensor_cilantro_1	20.10	69.55	64.45	1.74	6.74	193.30	467.17	2025-12-14 23:31:59.575831
6666	sensor_cilantro_2	22.05	71.04	72.41	1.55	6.57	189.81	454.16	2025-12-14 23:31:59.575971
6667	sensor_rabano_1	23.73	59.43	77.04	1.44	6.75	132.68	476.01	2025-12-14 23:32:09.586879
6668	sensor_rabano_2	23.98	58.03	62.11	1.65	6.40	147.23	412.74	2025-12-14 23:32:09.587688
6669	sensor_cilantro_1	20.90	65.78	79.68	1.79	6.68	142.31	496.10	2025-12-14 23:32:09.587923
6670	sensor_cilantro_2	21.73	77.20	75.76	1.70	6.71	153.94	488.55	2025-12-14 23:32:09.588086
6671	sensor_rabano_1	23.77	67.63	60.86	1.41	6.77	112.43	426.09	2025-12-14 23:32:19.598956
6672	sensor_rabano_2	21.16	66.76	66.75	1.54	6.76	175.80	476.48	2025-12-14 23:32:19.599733
6673	sensor_cilantro_1	22.00	71.56	79.34	1.97	6.46	180.73	493.75	2025-12-14 23:32:19.599986
6674	sensor_cilantro_2	22.99	70.60	76.69	1.51	6.69	57.81	441.64	2025-12-14 23:32:19.600157
6675	sensor_rabano_1	23.89	62.54	67.84	1.63	6.65	96.74	422.20	2025-12-14 23:32:29.610438
6676	sensor_rabano_2	20.94	58.14	60.19	1.66	6.59	125.34	465.75	2025-12-14 23:32:29.611214
6677	sensor_cilantro_1	21.40	66.40	75.89	1.50	6.74	148.42	401.89	2025-12-14 23:32:29.61132
6678	sensor_cilantro_2	21.23	73.99	67.69	1.84	6.77	91.23	474.74	2025-12-14 23:32:29.61138
6679	sensor_rabano_1	23.38	72.32	75.58	1.73	6.74	194.28	446.03	2025-12-14 23:32:39.62191
6680	sensor_rabano_2	21.47	63.00	65.01	1.97	6.43	77.67	480.59	2025-12-14 23:32:39.62281
6681	sensor_cilantro_1	22.30	74.13	72.50	1.63	6.67	116.02	434.78	2025-12-14 23:32:39.623049
6682	sensor_cilantro_2	22.77	75.40	66.70	1.78	6.72	84.62	455.46	2025-12-14 23:32:39.623205
6683	sensor_rabano_1	22.67	66.81	69.82	1.56	6.42	75.39	434.71	2025-12-14 23:32:49.633581
6684	sensor_rabano_2	23.56	72.27	69.13	1.75	6.54	169.78	476.29	2025-12-14 23:32:49.634394
6685	sensor_cilantro_1	20.67	77.32	79.20	1.78	6.73	82.82	470.54	2025-12-14 23:32:49.634833
6686	sensor_cilantro_2	21.67	75.25	61.20	1.73	6.65	115.74	485.10	2025-12-14 23:32:49.635037
\.


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 223
-- Name: dim_planta_planta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: edgar
--

SELECT pg_catalog.setval('public.dim_planta_planta_id_seq', 12, true);


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 225
-- Name: dim_sensor_sensor_id_dim_seq; Type: SEQUENCE SET; Schema: public; Owner: edgar
--

SELECT pg_catalog.setval('public.dim_sensor_sensor_id_dim_seq', 8, true);


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 221
-- Name: dim_tiempo_tiempo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: edgar
--

SELECT pg_catalog.setval('public.dim_tiempo_tiempo_id_seq', 4, true);


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 227
-- Name: dim_ubicacion_ubicacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: edgar
--

SELECT pg_catalog.setval('public.dim_ubicacion_ubicacion_id_seq', 2, true);


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 229
-- Name: fact_mediciones_medicion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: edgar
--

SELECT pg_catalog.setval('public.fact_mediciones_medicion_id_seq', 1, false);


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 231
-- Name: fact_predicciones_prediccion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: edgar
--

SELECT pg_catalog.setval('public.fact_predicciones_prediccion_id_seq', 1, false);


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 215
-- Name: plants_plant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: edgar
--

SELECT pg_catalog.setval('public.plants_plant_id_seq', 6, true);


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 219
-- Name: predictions_prediction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: edgar
--

SELECT pg_catalog.setval('public.predictions_prediction_id_seq', 183, true);


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 217
-- Name: sensor_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: edgar
--

SELECT pg_catalog.setval('public.sensor_data_id_seq', 6686, true);


--
-- TOC entry 3362 (class 2606 OID 16667)
-- Name: dim_planta dim_planta_pkey; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_planta
    ADD CONSTRAINT dim_planta_pkey PRIMARY KEY (planta_id);


--
-- TOC entry 3366 (class 2606 OID 16676)
-- Name: dim_sensor dim_sensor_pkey; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_sensor
    ADD CONSTRAINT dim_sensor_pkey PRIMARY KEY (sensor_id_dim);


--
-- TOC entry 3368 (class 2606 OID 16678)
-- Name: dim_sensor dim_sensor_sensor_id_key; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_sensor
    ADD CONSTRAINT dim_sensor_sensor_id_key UNIQUE (sensor_id);


--
-- TOC entry 3354 (class 2606 OID 16656)
-- Name: dim_tiempo dim_tiempo_fecha_key; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_tiempo
    ADD CONSTRAINT dim_tiempo_fecha_key UNIQUE (fecha);


--
-- TOC entry 3356 (class 2606 OID 16654)
-- Name: dim_tiempo dim_tiempo_pkey; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_tiempo
    ADD CONSTRAINT dim_tiempo_pkey PRIMARY KEY (tiempo_id);


--
-- TOC entry 3372 (class 2606 OID 16687)
-- Name: dim_ubicacion dim_ubicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_ubicacion
    ADD CONSTRAINT dim_ubicacion_pkey PRIMARY KEY (ubicacion_id);


--
-- TOC entry 3375 (class 2606 OID 16695)
-- Name: fact_mediciones fact_mediciones_pkey; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_mediciones
    ADD CONSTRAINT fact_mediciones_pkey PRIMARY KEY (medicion_id);


--
-- TOC entry 3382 (class 2606 OID 16749)
-- Name: fact_predicciones fact_predicciones_pkey; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_predicciones
    ADD CONSTRAINT fact_predicciones_pkey PRIMARY KEY (prediccion_id);


--
-- TOC entry 3348 (class 2606 OID 16431)
-- Name: plants plants_pkey; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.plants
    ADD CONSTRAINT plants_pkey PRIMARY KEY (plant_id);


--
-- TOC entry 3352 (class 2606 OID 16445)
-- Name: predictions predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_pkey PRIMARY KEY (prediction_id);


--
-- TOC entry 3350 (class 2606 OID 16438)
-- Name: sensor_data sensor_data_pkey; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.sensor_data
    ADD CONSTRAINT sensor_data_pkey PRIMARY KEY (id);


--
-- TOC entry 3360 (class 2606 OID 16658)
-- Name: dim_tiempo unique_fecha; Type: CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.dim_tiempo
    ADD CONSTRAINT unique_fecha UNIQUE (fecha, hora, minuto);


--
-- TOC entry 3363 (class 1259 OID 16669)
-- Name: idx_dim_planta_estado; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_dim_planta_estado ON public.dim_planta USING btree (estado);


--
-- TOC entry 3364 (class 1259 OID 16668)
-- Name: idx_dim_planta_tipo; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_dim_planta_tipo ON public.dim_planta USING btree (tipo_planta);


--
-- TOC entry 3369 (class 1259 OID 16679)
-- Name: idx_dim_sensor_id; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_dim_sensor_id ON public.dim_sensor USING btree (sensor_id);


--
-- TOC entry 3370 (class 1259 OID 16680)
-- Name: idx_dim_sensor_tipo; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_dim_sensor_tipo ON public.dim_sensor USING btree (tipo_sensor);


--
-- TOC entry 3357 (class 1259 OID 16660)
-- Name: idx_dim_tiempo_año_mes; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX "idx_dim_tiempo_año_mes" ON public.dim_tiempo USING btree ("año", mes);


--
-- TOC entry 3358 (class 1259 OID 16659)
-- Name: idx_dim_tiempo_fecha; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_dim_tiempo_fecha ON public.dim_tiempo USING btree (fecha);


--
-- TOC entry 3373 (class 1259 OID 16688)
-- Name: idx_dim_ubicacion_invernadero; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_dim_ubicacion_invernadero ON public.dim_ubicacion USING btree (invernadero);


--
-- TOC entry 3376 (class 1259 OID 16737)
-- Name: idx_fact_mediciones_planta; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_fact_mediciones_planta ON public.fact_mediciones USING btree (planta_id);


--
-- TOC entry 3377 (class 1259 OID 16738)
-- Name: idx_fact_mediciones_sensor; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_fact_mediciones_sensor ON public.fact_mediciones USING btree (sensor_id_dim);


--
-- TOC entry 3378 (class 1259 OID 16736)
-- Name: idx_fact_mediciones_tiempo; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_fact_mediciones_tiempo ON public.fact_mediciones USING btree (tiempo_id);


--
-- TOC entry 3379 (class 1259 OID 16740)
-- Name: idx_fact_mediciones_timestamp; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_fact_mediciones_timestamp ON public.fact_mediciones USING btree (timestamp_original);


--
-- TOC entry 3380 (class 1259 OID 16739)
-- Name: idx_fact_mediciones_ubicacion; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_fact_mediciones_ubicacion ON public.fact_mediciones USING btree (ubicacion_id);


--
-- TOC entry 3383 (class 1259 OID 16771)
-- Name: idx_fact_predicciones_planta; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_fact_predicciones_planta ON public.fact_predicciones USING btree (planta_id);


--
-- TOC entry 3384 (class 1259 OID 16770)
-- Name: idx_fact_predicciones_tiempo; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_fact_predicciones_tiempo ON public.fact_predicciones USING btree (tiempo_id);


--
-- TOC entry 3385 (class 1259 OID 16772)
-- Name: idx_fact_predicciones_timestamp; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_fact_predicciones_timestamp ON public.fact_predicciones USING btree (timestamp_original);


--
-- TOC entry 3386 (class 1259 OID 16780)
-- Name: idx_mv_mediciones_dia_planta_fecha; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_mv_mediciones_dia_planta_fecha ON public.mv_mediciones_dia_planta USING btree (fecha);


--
-- TOC entry 3387 (class 1259 OID 16781)
-- Name: idx_mv_mediciones_dia_planta_tipo; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_mv_mediciones_dia_planta_tipo ON public.mv_mediciones_dia_planta USING btree (tipo_planta);


--
-- TOC entry 3388 (class 1259 OID 16789)
-- Name: idx_mv_pred_semana_planta_semana; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_mv_pred_semana_planta_semana ON public.mv_predicciones_semana_planta USING btree (semana);


--
-- TOC entry 3389 (class 1259 OID 16790)
-- Name: idx_mv_pred_semana_planta_tipo; Type: INDEX; Schema: public; Owner: edgar
--

CREATE INDEX idx_mv_pred_semana_planta_tipo ON public.mv_predicciones_semana_planta USING btree (tipo_planta);


--
-- TOC entry 3390 (class 2606 OID 16701)
-- Name: fact_mediciones fact_mediciones_planta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_mediciones
    ADD CONSTRAINT fact_mediciones_planta_id_fkey FOREIGN KEY (planta_id) REFERENCES public.dim_planta(planta_id);


--
-- TOC entry 3391 (class 2606 OID 16706)
-- Name: fact_mediciones fact_mediciones_sensor_id_dim_fkey; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_mediciones
    ADD CONSTRAINT fact_mediciones_sensor_id_dim_fkey FOREIGN KEY (sensor_id_dim) REFERENCES public.dim_sensor(sensor_id_dim);


--
-- TOC entry 3392 (class 2606 OID 16696)
-- Name: fact_mediciones fact_mediciones_tiempo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_mediciones
    ADD CONSTRAINT fact_mediciones_tiempo_id_fkey FOREIGN KEY (tiempo_id) REFERENCES public.dim_tiempo(tiempo_id);


--
-- TOC entry 3393 (class 2606 OID 16711)
-- Name: fact_mediciones fact_mediciones_ubicacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_mediciones
    ADD CONSTRAINT fact_mediciones_ubicacion_id_fkey FOREIGN KEY (ubicacion_id) REFERENCES public.dim_ubicacion(ubicacion_id);


--
-- TOC entry 3398 (class 2606 OID 16755)
-- Name: fact_predicciones fact_predicciones_planta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_predicciones
    ADD CONSTRAINT fact_predicciones_planta_id_fkey FOREIGN KEY (planta_id) REFERENCES public.dim_planta(planta_id);


--
-- TOC entry 3399 (class 2606 OID 16750)
-- Name: fact_predicciones fact_predicciones_tiempo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_predicciones
    ADD CONSTRAINT fact_predicciones_tiempo_id_fkey FOREIGN KEY (tiempo_id) REFERENCES public.dim_tiempo(tiempo_id);


--
-- TOC entry 3394 (class 2606 OID 16721)
-- Name: fact_mediciones fk_planta; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_mediciones
    ADD CONSTRAINT fk_planta FOREIGN KEY (planta_id) REFERENCES public.dim_planta(planta_id);


--
-- TOC entry 3400 (class 2606 OID 16765)
-- Name: fact_predicciones fk_planta_pred; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_predicciones
    ADD CONSTRAINT fk_planta_pred FOREIGN KEY (planta_id) REFERENCES public.dim_planta(planta_id);


--
-- TOC entry 3395 (class 2606 OID 16726)
-- Name: fact_mediciones fk_sensor; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_mediciones
    ADD CONSTRAINT fk_sensor FOREIGN KEY (sensor_id_dim) REFERENCES public.dim_sensor(sensor_id_dim);


--
-- TOC entry 3396 (class 2606 OID 16716)
-- Name: fact_mediciones fk_tiempo; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_mediciones
    ADD CONSTRAINT fk_tiempo FOREIGN KEY (tiempo_id) REFERENCES public.dim_tiempo(tiempo_id);


--
-- TOC entry 3401 (class 2606 OID 16760)
-- Name: fact_predicciones fk_tiempo_pred; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_predicciones
    ADD CONSTRAINT fk_tiempo_pred FOREIGN KEY (tiempo_id) REFERENCES public.dim_tiempo(tiempo_id);


--
-- TOC entry 3397 (class 2606 OID 16731)
-- Name: fact_mediciones fk_ubicacion; Type: FK CONSTRAINT; Schema: public; Owner: edgar
--

ALTER TABLE ONLY public.fact_mediciones
    ADD CONSTRAINT fk_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES public.dim_ubicacion(ubicacion_id);


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: edgar
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 3565 (class 0 OID 16773)
-- Dependencies: 233 3568
-- Name: mv_mediciones_dia_planta; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: edgar
--

REFRESH MATERIALIZED VIEW public.mv_mediciones_dia_planta;


--
-- TOC entry 3566 (class 0 OID 16782)
-- Dependencies: 234 3568
-- Name: mv_predicciones_semana_planta; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: edgar
--

REFRESH MATERIALIZED VIEW public.mv_predicciones_semana_planta;


-- Completed on 2025-12-14 23:32:53 CST

--
-- PostgreSQL database dump complete
--

\unrestrict btUV4VzVoX5pwrtpAMOdQleTLPCxoQJKZMv6LMxBVdmhagd0RuKfwm3Ic8r4wzi

