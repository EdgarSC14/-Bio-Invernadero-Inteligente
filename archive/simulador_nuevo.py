# find_password.py
import psycopg2

# Lista de contraseñas comunes para probar
passwords_to_try = [
    "1234",           # La que intentaste
    "postgres",       # Contraseña por defecto común
    "password",       # Otra común
    "admin",          # Otra posibilidad
    "root",           # Otra común
    "",               # Sin contraseña (vacía)
    "Postgres",       # Con mayúscula
    "POSTGRES",       # Todo mayúsculas
    "12345",          # Similar a 1234
    "123456",         # Otra secuencia común
]

print("🔍 Probando contraseñas para PostgreSQL...")

for password in passwords_to_try:
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="postgres",
            user="postgres",
            password=password,
            port="5432",
            connect_timeout=5
        )
        print(f"✅ ¡CONTRASEÑA ENCONTRADA: '{password}'")
        conn.close()
        break
    except:
        print(f"❌ Falló: '{password}'")
else:
    print("💥 No se pudo encontrar la contraseña")
    print("💡 Ejecuta esto en PostgreSQL para cambiar la contraseña:")
    print("   ALTER USER postgres WITH PASSWORD '1234';")