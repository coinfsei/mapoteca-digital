import psycopg2
import json
from datetime import datetime

# Conectar
conn = psycopg2.connect(
    host="10.28.246.75",
    database="mapoteca",
    user="dados_mapoteca",
    password="Mapoteca2025"
    )
cursor = conn.cursor()

# Buscar tabelas
cursor.execute("""
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'dados_mapoteca'
      AND table_type = 'BASE TABLE'
    ORDER BY table_name
""")

tabelas = {}

for (table_name,) in cursor.fetchall():
    print(f"Processando {table_name}...")
    
    # Buscar colunas
    cursor.execute("""
        SELECT 
            column_name,
            data_type,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = 'dados_mapoteca'
          AND table_name = %s
        ORDER BY ordinal_position
    """, (table_name,))
    
    colunas = []
    for row in cursor.fetchall():
        colunas.append({
            'nome': row[0],
            'tipo': row[1],
            'nullable': row[2],
            'default': row[3]
        })
    
    # Contar registros
    cursor.execute(f"SELECT COUNT(*) FROM dados_mapoteca.{table_name}")
    total = cursor.fetchone()[0]
    
    tabelas[table_name] = {
        'nome': table_name,
        'colunas': colunas,
        'total_registros': total
    }

# Salvar JSON
schema_json = {
    'database': 'mapoteca',
    'schema': 'dados_mapoteca',
    'data_geracao': datetime.now().isoformat(),
    'tabelas': tabelas
}

with open('schema_dados_mapoteca.json', 'w', encoding='utf-8') as f:
    json.dump(schema_json, f, indent=2, ensure_ascii=False)

print(f"✅ JSON gerado: schema_dados_mapoteca.json")
print(f"📊 Total de tabelas: {len(tabelas)}")

cursor.close()
conn.close()
