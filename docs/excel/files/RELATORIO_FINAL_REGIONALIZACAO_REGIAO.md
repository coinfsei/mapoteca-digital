# Relatório Final: Regionalização x Região com Abrangência

**Data de geração:** 13/11/2025 às 14:31:33

---

## 📊 Resumo Executivo

| Métrica | Valor |
|---------|-------|
| **Total de relacionamentos** | 229 |
| **Regionalizações** | 11 |
| **Regiões únicas** | 106 |
| **Abrangências preenchidas** | 229 (100%) |
| **Status** | ✅ Completo e validado |

---

## 📋 Estrutura da Tabela

| Campo | Tipo | Descrição | Exemplo |
|-------|------|-----------|---------|
| `id_regionalizacao` | VARCHAR(2) | Código da regionalização | '01', '02', ... '11' |
| `id_regiao` | VARCHAR(3) | Código da região | '001', '008', '019' |
| `nome_regiao` | VARCHAR(100) | Nome descritivo da região | 'Alagoinhas', 'Salvador' |
| `abrangencia` | VARCHAR(50) | Código de abrangência da região | 'alagoinhas', 'salvador' |

---

## 📈 Distribuição por Regionalização

- **Regionalização 1:** 13 regiões
- **Regionalização 2:** 7 regiões
- **Regionalização 3:** 32 regiões
- **Regionalização 4:** 9 regiões
- **Regionalização 5:** 26 regiões
- **Regionalização 6:** 30 regiões
- **Regionalização 7:** 27 regiões
- **Regionalização 8:** 15 regiões
- **Regionalização 9:** 33 regiões
- **Regionalização 10:** 10 regiões
- **Regionalização 11:** 27 regiões


---

## 🔍 Top 10 Abrangências Mais Frequentes

1. **irece** (8x): Irecê, Irecê, Irecê, Irecê, Irecê, Irecê, Irecê, Irecê
2. **barreiras** (6x): Barreiras, Barreiras, Barreiras, Barreiras, Barreiras, Barreiras
3. **feira_de_santana** (6x): Feira de Santana, Feira de Santana, Feira de Santana, Feira de Santana, Feira de Santana, Feira de Santana
4. **juazeiro** (6x): Juazeiro, Juazeiro, Juazeiro, Juazeiro, Juazeiro, Juazeiro
5. **vit_da_conquista** (6x): Vitória da Conquista, Vitória da Conquista, Vitória da Conquista, Vitória da Conquista, Vitória da Conquista, Vitória da Conquista
6. **sto_ant_de_jesus** (6x): Santo Antônio de Jesus, Santo Antônio de Jesus, Santo Antônio de Jesus, Santo Antônio de Jesus, Santo Antônio de Jesus, Santo Antônio de Jesus
7. **paulo_afonso** (6x): Paulo Afonso, Paulo Afonso, Paulo Afonso, Paulo Afonso, Paulo Afonso, Paulo Afonso
8. **jacobina** (5x): Jacobina, Jacobina, Jacobina, Jacobina, Jacobina
9. **jequie** (5x): Jequié, Jequié, Jequié, Jequié, Jequié
10. **itapetinga** (5x): Itapetinga, Itapetinga, Itapetinga, Itapetinga, Itapetinga


---

## 📑 Amostra dos Dados

### Regionalização 01 (primeiras 10 regiões)

| ID Região | Nome da Região | Abrangência |
|-----------|----------------|-------------|


### Regionalização 11 (primeiras 10 regiões)

| ID Região | Nome da Região | Abrangência |
|-----------|----------------|-------------|


---

## 💾 Scripts SQL para Importação

### PostgreSQL

```sql
-- Criar tabela
CREATE TABLE IF NOT EXISTS t_regionalizacao_regiao (
    id_regionalizacao VARCHAR(2) NOT NULL,
    id_regiao VARCHAR(3) NOT NULL,
    nome_regiao VARCHAR(100),
    abrangencia VARCHAR(50),
    PRIMARY KEY (id_regionalizacao, id_regiao),
    CONSTRAINT fk_regionalizacao 
        FOREIGN KEY (id_regionalizacao) 
        REFERENCES t_regionalizacao(id_regionalizacao),
    CONSTRAINT fk_regiao 
        FOREIGN KEY (id_regiao) 
        REFERENCES t_regiao(id_regiao)
);

-- Criar índices
CREATE INDEX idx_regionalizacao ON t_regionalizacao_regiao(id_regionalizacao);
CREATE INDEX idx_regiao ON t_regionalizacao_regiao(id_regiao);
CREATE INDEX idx_abrangencia ON t_regionalizacao_regiao(abrangencia);

-- Importar dados do CSV
COPY t_regionalizacao_regiao(
    id_regionalizacao, 
    id_regiao, 
    nome_regiao, 
    abrangencia
)
FROM '/caminho/para/t_regionalizacao_regiao_preenchida.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- Verificar importação
SELECT 
    id_regionalizacao,
    COUNT(*) as total_regioes
FROM t_regionalizacao_regiao
GROUP BY id_regionalizacao
ORDER BY id_regionalizacao;
```

### Consultas Úteis

```sql
-- Buscar todas as regiões de uma regionalização
SELECT 
    id_regiao,
    nome_regiao,
    abrangencia
FROM t_regionalizacao_regiao
WHERE id_regionalizacao = '01'
ORDER BY nome_regiao;

-- Contar regiões por regionalização
SELECT 
    id_regionalizacao,
    COUNT(*) as total_regioes
FROM t_regionalizacao_regiao
GROUP BY id_regionalizacao
ORDER BY id_regionalizacao;

-- Buscar regionalização de uma região específica
SELECT 
    id_regionalizacao,
    nome_regiao,
    abrangencia
FROM t_regionalizacao_regiao
WHERE id_regiao = '001';

-- Listar todas as abrangências únicas
SELECT DISTINCT 
    abrangencia,
    COUNT(*) OVER (PARTITION BY abrangencia) as frequencia
FROM t_regionalizacao_regiao
ORDER BY frequencia DESC, abrangencia;
```

---

## 📁 Arquivos Gerados

1. **t_regionalizacao_regiao_preenchida.xlsx**
   - Formato: Excel (.xlsx)
   - Tamanho: ~{len(df_final)} registros
   - Uso: Visualização e análise em planilhas

2. **t_regionalizacao_regiao_preenchida.csv**
   - Formato: CSV com UTF-8 (BOM)
   - Separador: vírgula (,)
   - Codificação: UTF-8 com BOM
   - Uso: Importação em bancos de dados

3. **RELATORIO_FINAL_REGIONALIZACAO_REGIAO.md**
   - Formato: Markdown
   - Conteúdo: Documentação completa

---

## ✅ Validações Realizadas

- ✅ Todos os IDs de região existem na tabela `t_regiao_limpo`
- ✅ Todos os relacionamentos possuem abrangência preenchida
- ✅ IDs formatados corretamente (zeros à esquerda)
- ✅ Sem valores nulos em campos obrigatórios
- ✅ Relacionamentos únicos (sem duplicatas)

---

## 📊 Estatísticas Detalhadas

| Regionalização | Qtd Regiões | Média | % do Total |
|----------------|-------------|-------|------------|
| 1 |  13 |   1.2 |   5.7% |
| 2 |   7 |   0.6 |   3.1% |
| 3 |  32 |   2.9 |  14.0% |
| 4 |   9 |   0.8 |   3.9% |
| 5 |  26 |   2.4 |  11.4% |
| 6 |  30 |   2.7 |  13.1% |
| 7 |  27 |   2.5 |  11.8% |
| 8 |  15 |   1.4 |   6.6% |
| 9 |  33 |   3.0 |  14.4% |
| 10 |  10 |   0.9 |   4.4% |
| 11 |  27 |   2.5 |  11.8% |
| **Total** | **229** | **20.8** | **100.0%** |


---

## 🎯 Próximos Passos Sugeridos

1. **Importar para o banco de dados PostgreSQL**
   - Usar o script SQL fornecido acima
   - Validar foreign keys com tabelas pai

2. **Criar views para análises**
   ```sql
   CREATE VIEW v_regionalizacao_completa AS
   SELECT 
       r.id_regionalizacao,
       r.id_regiao,
       r.nome_regiao,
       r.abrangencia,
       reg.nome_regionalizacao,
       reg.descricao
   FROM t_regionalizacao_regiao r
   JOIN t_regionalizacao reg ON r.id_regionalizacao = reg.id_regionalizacao;
   ```

3. **Integrar com aplicações**
   - API REST endpoints
   - Dashboards de visualização
   - Relatórios automáticos

---

## 📞 Suporte

Para dúvidas ou ajustes adicionais:
- Verificar documentação das tabelas relacionadas
- Consultar DBA para ajustes de foreign keys
- Revisar dados originais em caso de inconsistências

---

*Relatório gerado automaticamente por Claude AI*  
*Sistema de Relacionamento Regionalização x Região*  
