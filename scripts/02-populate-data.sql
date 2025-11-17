-- ===================================================================================
-- Mapoteca Digital - Script 02: População de Dados Iniciais
-- ===================================================================================
-- Descrição: População das tabelas de domínio com dados base para a Mapoteca Digital
-- Ambiente: Oracle Linux (10.28.246.75) | PostgreSQL 14+ | ESRI SDE
-- Usuário: dados_mapoteca | Schema: dados_mapoteca
-- Data: 2025-11-10
-- Dependências: Script 01-setup-schema.sql deve ser executado primeiro
-- ===================================================================================

-- Configuração do ambiente
\set ON_ERROR_STOP on
SET client_min_messages TO WARNING;
SET search_path TO dados_mapoteca, public;

-- ===================================================================================
-- 1. TIPOS DE TEMA
-- ===================================================================================
INSERT INTO dados_mapoteca.tipos_tema (codigo, nome, descricao, cor_padrao, ordem_exibicao) VALUES
('cart', 'Cartografia', 'Mapas base e referências cartográficas fundamentais', '#2E86AB', 1),
('padm', 'Político-Administrativo', 'Divisões políticas, administrativas e governamentais', '#A23B72', 2),
('fisamb', 'Físico-Ambiental', 'Aspectos físicos, ambientais e recursos naturais', '#F18F01', 3),
('reg', 'Regionalização', 'Diferentes tipos de regionalização e divisões territoriais', '#C73E1D', 4),
('soc', 'Socioeconômico', 'Dados econômicos, sociais e demográficos', '#4A90A4', 5),
('infra', 'Infraestrutura', 'Infraestrutura, transportes e serviços básicos', '#7B68EE', 6);

-- Verificação
SELECT 'Tipos de Tema' as tabela, COUNT(*) as registros_inseridos
FROM dados_mapoteca.tipos_tema;

-- ===================================================================================
-- 2. CLASSES DE PUBLICAÇÃO (Mapa/Cartograma)
-- ===================================================================================
INSERT INTO dados_mapoteca.classes_publicacao (codigo, nome, descricao, ordem_exibicao) VALUES
('mapa', 'Mapa', 'Representação cartográfica tradicional de fenômenos geográficos', 1),
('cartograma', 'Cartograma', 'Representação gráfica de dados estatísticos com distorção territorial', 2);

-- Verificação
SELECT 'Classes de Publicação' as tabela, COUNT(*) as registros_inseridos
FROM dados_mapoteca.classes_publicacao;

-- ===================================================================================
-- 3. TIPOS DE PUBLICAÇÃO (Abrangência)
-- ===================================================================================
INSERT INTO dados_mapoteca.tipos_publicacao (codigo, nome, descricao, ordem_exibicao) VALUES
('estadual', 'Estadual', 'Publicações com abrangência em todo o estado da Bahia', 1),
('regional', 'Regional', 'Publicações que cobrem múltiplos municípios ou regiões específicas', 2),
('municipal', 'Municipal', 'Publicações com abrangência em nível municipal específico', 3);

-- Verificação
SELECT 'Tipos de Publicação' as tabela, COUNT(*) as registros_inseridos
FROM dados_mapoteca.tipos_publicacao;

-- ===================================================================================
-- 4. TEMAS PRINCIPAIS
-- ===================================================================================
INSERT INTO dados_mapoteca.temas (codigo, nome, slug, descricao, palavras_chave, id_tipo_tema, ordem_exibicao) VALUES

-- Temas Cartográficos
('articulacao-folha', 'Articulação de Folha Cartográfica', 'articulacao-folha',
 'Articulação de folhas cartográficas na escala 1:100.000 para organização sistemática do mapeamento',
 ARRAY('cartografia', 'folha', 'articulação', 'sistemática', '1:100.000'), 1, 1),

('sistema-referencia', 'Sistema de Referência', 'sistema-referencia',
 'Sistemas de coordenadas e referências geodésicas utilizados nos mapas',
 ARRAY('coordenadas', 'referência', 'geodésia', 'sirgas', 'datum'), 1, 2),

-- Temas Político-Administrativos
('divisao-politica', 'Divisão Político-Administrativa', 'divisao-politica',
 'Municípios, microrregiões, mesorregiões e outras divisões político-administrativas da Bahia',
 ARRAY('municípios', 'divisão', 'administração', 'regiões', 'limites'), 2, 1),

('sedes-municipios', 'Sedes dos Municípios', 'sedes-municipios',
 'Localização das sedes administrativas dos municípios baianos',
 ARRAY('sedes', 'municípios', 'administração', 'cidades'), 2, 2),

-- Temas Físico-Ambientais
('geologia', 'Geologia', 'geologia',
 'Mapas geológicos, tipos de rochas, recursos minerais e estruturas geológicas da Bahia',
 ARRAY('rochas', 'minerais', 'recursos naturais', 'estruturas', 'geodiversidade'), 3, 1),

('solos', 'Solos', 'solos',
 'Classificação e características dos solos do estado da Bahia',
 ARRAY('pedologia', 'classificação', 'fertilidade', 'erosão'), 3, 2),

('relevo', 'Relevo', 'relevo',
 'Compartimentos geomorfológicos, unidades de relevo e hipsometria da Bahia',
 ARRAY('geomorfologia', 'altitude', 'serras', 'planícies', 'depressões'), 3, 3),

('biomas', 'Biomas', 'biomas',
 'Distribuição dos biomas brasileiros com foco na Bahia: Caatinga, Cerrado, Mata Atlântica',
 ARRAY('vegetação', 'ecossistemas', 'biodiversidade', 'caatinga', 'cerrado', 'mata atlântica'), 3, 4),

('bacias-hidrograficas', 'Bacias Hidrográficas', 'bacias-hidrograficas',
 'Bacias e sub-bacias hidrográficas, principais rios e corpos d água',
 ARRAY('rios', 'hidrografia', 'águas', 'bacias', 'sub-bacias', 'nascentes'), 3, 5),

('uso-terra', 'Uso e Cobertura da Terra', 'uso-terra',
 'Uso atual e cobertura vegetal das terras, tipos de ocupação humana',
 ARRAY('ocupação', 'vegetação', 'solo', 'cobertura', 'desmatamento', 'agricultura'), 3, 6),

('vegetacao', 'Vegetação', 'vegetacao',
 'Tipos de formação vegetal, fitofisionomias e cobertura florestal',
 ARRAY('fitofisionomia', 'formações', 'florestas', 'savanas', 'campos'), 3, 7),

('clima', 'Climatologia', 'climatologia',
 'Classificações climáticas, precipitação, temperatura e elementos climáticos',
 ARRAY('clima', 'precipitação', 'temperatura', 'classificação', 'koppen'), 3, 8),

('hidrografia', 'Hidrografia', 'hidrografia',
 'Rede de drenagem, rios, lagos, represas e elementos hidrográficos',
 ARRAY('drenagem', 'rios', 'lagos', 'represas', 'bacias'), 3, 9),

('recursos-minerais', 'Recursos Minerais', 'recursos-minerais',
 'Distribuição de ocorrências minerais, jazidas e potencial mineral',
 ARRAY('mineração', 'jazidas', 'ocorrências', 'recursos', 'exploração'), 3, 10),

('unidades-conservacao', 'Unidades de Conservação', 'unidades-conservacao',
 'Parques, reservas e unidades de conservação ambiental existentes',
 ARRAY('parques', 'reservas', 'conservação', 'proteção', 'ambiental'), 3, 11),

('pontos-extremos', 'Pontos Extremos', 'pontos-extremos',
 'Altitudes máximas e mínimas, pontos extremos geográficos do estado',
 ARRAY('altitude', 'extremos', 'pico', 'depressão', 'coordenadas'), 3, 12),

-- Temas de Regionalização
('eixos-desenvolvimento', 'Eixos de Desenvolvimento', 'eixos-desenvolvimento',
 'Eixos estratégicos de desenvolvimento econômico e social do estado',
 ARRAY('desenvolvimento', 'estratégia', 'economia', 'social', 'planejamento'), 4, 1),

('mesorregioes', 'Mesorregiões Geográficas', 'mesorregioes',
 'Divisão do estado em mesorregiões segundo IBGE',
 ARRAY('mesorregiões', 'ibge', 'divisão', 'planejamento'), 4, 2),

('microrregioes', 'Microrregiões Geográficas', 'microrregioes',
 'Divisão do estado em microrregiões segundo IBGE',
 ARRAY('microrregiões', 'ibge', 'divisão', 'planejamento'), 4, 3),

('territorios-identidade', 'Territórios de Identidade', 'territorios-identidade',
 'Territórios definidos por identidades culturais e econômicas',
 ARRAY('territórios', 'identidade', 'cultura', 'desenvolvimento'), 4, 4),

('regioes-saude', 'Regiões de Saúde', 'regioes-saude',
 'Divisão do estado para fins de planejamento de saúde',
 ARRAY('saúde', 'planejamento', 'regiões', 'sus'), 4, 5),

('regioes-planejamento', 'Regiões de Planejamento', 'regioes-planejamento',
 'Regiões definidas para planejamento governamental integrado',
 ARRAY('planejamento', 'governo', 'integração', 'gestão'), 4, 6),

-- Temas Socioeconômicos
('populacao', 'População', 'populacao',
 'Dados demográficos, densidade populacional e distribuição populacional',
 ARRAY('demografia', 'habitantes', 'censo', 'densidade', 'distribuição'), 5, 1),

('pib', 'Produto Interno Bruto', 'pib',
 'Dados econômicos do PIB municipal, regional e setorial',
 ARRAY('economia', 'renda', 'desenvolvimento', 'setores', 'valor adicionado'), 5, 2),

('pib-percapita', 'PIB Per Capita', 'pib-percapita',
 'Renda per capita municipal e indicadores de desenvolvimento econômico',
 ARRAY('renda', 'per capita', 'desenvolvimento', 'economia'), 5, 3),

('fpm', 'Fundo de Participação dos Municípios', 'fpm',
 'Distribuição e valores do FPM aos municípios baianos',
 ARRAY('fpm', 'municípios', 'repartição', 'receita'), 5, 4),

('icms', 'ICMS', 'icms',
 'Arrecadação e distribuição do ICMS municipal',
 ARRAY('icms', 'arrecadação', 'municipal', 'impostos'), 5, 5),

('povos-indigenas', 'Povos Indígenas', 'povos-indigenas',
 'Terras e comunidades indígenas existentes no estado',
 ARRAY('indígenas', 'terras', 'comunidades', 'cultura'), 5, 6),

('assentamentos-rurais', 'Assentamentos Rurais', 'assentamentos-rurais',
 'Projetos de assentamento de reforma agrária',
 ARRAY('assentamentos', 'reforma agrária', 'rural', 'terra'), 5, 7),

('projetos-irrigacao', 'Projetos de Irrigação', 'projetos-irrigacao',
 'Perímetros irrigados e projetos de irrigação pública',
 ARRAY('irrigação', 'perímetros', 'agricultura', 'água'), 5, 8),

-- Temas de Infraestrutura
('sistema-transportes', 'Sistema de Transportes', 'sistema-transportes',
 'Rede rodoviária, ferroviária e outros modais de transporte',
 ARRAY('transporte', 'rodovias', 'ferrovias', 'modais', 'logística'), 6, 1),

('usinas-termicas', 'Usinas Termelétricas', 'usinas-termicas',
 'Localização e capacidade das usinas termelétricas do estado',
 ARRAY('energia', 'termelétricas', 'geração', 'elétrica'), 6, 2);

-- Verificação
SELECT 'Temas' as tabela, COUNT(*) as registros_inseridos
FROM dados_mapoteca.temas;

-- ===================================================================================
-- 5. REGIÕES (DESCRIÇÃO TEXTUAL)
-- ===================================================================================
INSERT INTO dados_mapoteca.regioes (codigo, nome, slug, descricao, tipo_regionalizacao, abrangencia, area_aproximada_km2, municipios_incluidos, principais_cidades) VALUES

-- Regiões Principais (Estadual)
('ba-estado', 'Bahia', 'bahia',
 'Estado completo da Bahia com todos os 417 municípios', 'estadual',
 'Todo o território do estado da Bahia', 564732.5,
 ARRAY('Salvador', 'Feira de Santana', 'Vitória da Conquista', 'Camaçari', 'Juazeiro'),
 ARRAY('Salvador', 'Feira de Santana', 'Vitória da Conquista', 'Camaçari', 'Juazeiro', 'Itabuna', 'Ilhéus')),

-- Regiões Geográficas (Regional)
('ba-norte', 'Norte Baiano', 'norte-baiano',
 'Região norte caracterizada pelo clima semiárido e economia baseada em agropecuária', 'regional',
 'Compreende os municípios da porção norte, incluindo as bacias do São Francisco', 150000,
 ARRAY('Juazeiro', 'Paulo Afonso', 'Senhor do Bonfim', 'Jacobina', 'Irecê'),
 ARRAY('Juazeiro', 'Paulo Afonso', 'Senhor do Bonfim', 'Juazeiro', 'Jacobina', 'Irecê', 'Barreiras')),

('ba-sul', 'Sul Baiano', 'sul-baiano',
 'Região sul com forte influência da indústria, cacau e agricultura diversificada', 'regional',
 'Região com economia diversificada entre indústria, cacau e agricultura', 180000,
 ARRAY('Vitória da Conquista', 'Itapetinga', 'Jequié', 'Ilhéus', 'Eunápolis'),
 ARRAY('Vitória da Conquista', 'Itapetinga', 'Jequié', 'Ilhéus', 'Eunápolis', 'Itabuna', 'Teixeira de Freitas')),

('ba-litoral', 'Litoral Baiano', 'litoral-baiano',
 'Faixa litorânea com forte turismo, indústria naval e atividades portuárias', 'regional',
 'Região costeira com forte influência econômica do turismo e indústria', 120000,
 ARRAY('Salvador', 'Lauro de Freitas', 'Camaçari', 'Porto Seguro', 'Ilhéus'),
 ARRAY('Salvador', 'Lauro de Freitas', 'Camaçari', 'Porto Seguro', 'Ilhéus', 'Alagoinhas', 'Santo Antônio de Jesus')),

('ba-oeste', 'Oeste Baiano', 'oeste-baiano',
 'Região oeste com fronteira agrícola e expansão da fronteira agrícola', 'regional',
 'Região de expansão agrícola e produção de grãos', 140000,
 ARRAY('Barreiras', 'Luís Eduardo Magalhães', 'Santa Maria da Vitória'),
 ARRAY('Barreiras', 'Luís Eduardo Magalhães', 'Santa Maria da Vitória', 'São Desidério')),

('ba-centro', 'Centro-Sul Baiano', 'centro-sul-baiano',
 'Região centro-sul com economia diversificada e importante entroncamento rodoviário', 'regional',
 'Região estratégica com logística e economia diversificada', 130000,
 ARRAY('Feira de Santana', 'Alagoinhas', 'Ribeira do Pombal'),
 ARRAY('Feira de Santana', 'Alagoinhas', 'Ribeira do Pombal', 'Serrinha', 'Irará')),

-- Regiões Específicas (Municipal代表性示例)
('ba-salvador', 'Região Metropolitana de Salvador', 'regiao-metropolitana-salvador',
 'Região metropolitana com maior concentração populacional e econômica do estado', 'regional',
 '13 municípios ao redor de Salvador', 4500,
 ARRAY('Salvador', 'Lauro de Freitas', 'Camaçari', 'Simões Filho', 'Vera Cruz'),
 ARRAY('Salvador', 'Lauro de Freitas', 'Camaçari', 'Simões Filho', 'Vera Cruz', 'Dias d Ávila')),

('ba-extremo-sul', 'Extremo Sul Baiano', 'extremo-sul-baiano',
 'Região do extremo sul com forte produção de cacau e turismo', 'regional',
 'Municípios do sul com identidade cultural e econômica própria', 35000,
 ARRAY('Porto Seguro', 'Eunápolis', 'Teixeira de Freitas', 'Alcobaça'),
 ARRAY('Porto Seguro', 'Eunápolis', 'Teixeira de Freitas', 'Alcobaça', 'Prado', 'Santa Cruz Cabrália'));

-- Verificação
SELECT 'Regiões' as tabela, COUNT(*) as registros_inseridos
FROM dados_mapoteca.regioes;

-- ===================================================================================
-- 6. ESCALAS CARTOGRÁFICAS
-- ===================================================================================
INSERT INTO dados_mapoteca.escalas (codigo, nome, descricao, denominador) VALUES
('1:25.000', '1:25.000', 'Escala municipal detalhada para áreas urbanas e estudos específicos', 25000),
('1:50.000', '1:50.000', 'Escala municipal padrão para planejamento urbano e rural', 50000),
('1:100.000', '1:100.000', 'Escala regional básica para estudos de média complexidade', 100000),
('1:250.000', '1:250.000', 'Escala regional detalhada para planejamento regional', 250000),
('1:500.000', '1:500.000', 'Escala estadual padrão para visão geral do estado', 500000),
('1:750.000', '1:750.000', 'Escala estadual reduzida para publicações didáticas', 750000),
('1:1.000.000', '1:1.000.000', 'Escala estadual ampla para visão sinótica', 1000000),
('1:2.500.000', '1:2.500.000', 'Escala nacional para contextos regionais amplos', 2500000);

-- Verificação
SELECT 'Escalas' as tabela, COUNT(*) as registros_inseridos
FROM dados_mapoteca.escalas;

-- ===================================================================================
-- 7. CORES E TIPOS DE REPRESENTAÇÃO
-- ===================================================================================
INSERT INTO dados_mapoteca.cores (codigo, nome, descricao) VALUES
('colorido', 'Colorido', 'Mapas e publicações representadas em cores'),
('pb', 'Preto e Branco', 'Publicações em escala de cinza, preto e branco'),
('satelite', 'Imagem de Satélite', 'Imagens de satélite e fotografias aéreas naturais'),
('tematico', 'Mapa Temático', 'Mapas com representações temáticas por cores'),
('falso_cor', 'Falsa Cor', 'Representações em falsa cor para realçar características'),
('hibrido', 'Híbrido', 'Combinação de diferentes tipos de representação visual');

INSERT INTO dados_mapoteca.cores (codigo, nome, descricao) VALUES
('azul', 'Predominantemente Azul', 'Mapas com predominância de tons azuis (geralmente hidrografia)'),
('verde', 'Predominantemente Verde', 'Mapas com predominância de tons verdes (geralmente vegetação)'),
('marrom', 'Predominantemente Marrom', 'Mapas com predominância de tons marrons (geralmente relevo/solos)'),
('multicor', 'Multicor', 'Mapas com múltiplas cores sem predominância específica');

-- Verificação
SELECT 'Cores' as tabela, COUNT(*) as registros_inseridos
FROM dados_mapoteca.cores;

-- ===================================================================================
-- 8. ANOS (PERÍODO DE REFERÊNCIA)
-- ===================================================================================
INSERT INTO dados_mapoteca.anos (ano, descricao) VALUES
(2010, 'Censo Demográfico 2010 - Ano base censitário'),
(2011, 'Dados anuais - 2011'),
(2012, 'Dados anuais - 2012'),
(2013, 'Dados anuais - 2013'),
(2014, 'Dados anuais - 2014'),
(2015, 'Dados anuais - 2015'),
(2016, 'Dados anuais - 2016'),
(2017, 'Dados anuais - 2017'),
(2018, 'Dados anuais - 2018'),
(2019, 'Dados anuais - 2019'),
(2020, 'Dados especiais - 2020 (COVID-19 e ano eleitoral)'),
(2021, 'Dados anuais - 2021'),
(2022, 'Dados anuais - 2022'),
(2023, 'Dados anuais - 2023'),
(2024, 'Dados anuais - 2024 (ano atual)'),
(2025, 'Projeções e estimativas - 2025'),
(2026, 'Projeções - 2026'),
(2027, 'Projeções - 2027'),
(2028, 'Projeções - 2028'),
(2029, 'Projeções - 2029'),
(2030, 'Projeções decadais - 2030');

-- Verificação
SELECT 'Anos' as tabela, COUNT(*) as registros_inseridos
FROM dados_mapoteca.anos;

-- ===================================================================================
-- 9. VALIDAÇÃO FINAL DOS DADOS
-- ===================================================================================

-- Resumo da população de dados
SELECT
    'RESUMO DA POPULAÇÃO DE DADOS' as descricao,
    'Script 02 concluído com sucesso' as status;

-- Contagem total de registros por tabela
SELECT
    'TIPOS DE TEMA' as tabela,
    COUNT(*) as total_registros,
    ARRAY_AGG(codigo ORDER BY codigo) as codigos_criados
FROM dados_mapoteca.tipos_tema

UNION ALL

SELECT
    'CLASSES PUBLICAÇÃO' as tabela,
    COUNT(*) as total_registros,
    ARRAY_AGG(codigo ORDER BY codigo) as codigos_criados
FROM dados_mapoteca.classes_publicacao

UNION ALL

SELECT
    'TIPOS PUBLICAÇÃO' as tabela,
    COUNT(*) as total_registros,
    ARRAY_AGG(codigo ORDER BY codigo) as codigos_criados
FROM dados_mapoteca.tipos_publicacao

UNION ALL

SELECT
    'TEMAS' as tabela,
    COUNT(*) as total_registros,
    STRING_AGG(codigo, ', ' ORDER BY codigo) as codigos_criados
FROM dados_mapoteca.temas

UNION ALL

SELECT
    'REGIÕES' as tabela,
    COUNT(*) as total_registros,
    STRING_AGG(codigo, ', ' ORDER BY codigo) as codigos_criados
FROM dados_mapoteca.regioes

UNION ALL

SELECT
    'ESCALAS' as tabela,
    COUNT(*) as total_registros,
    ARRAY_AGG(codigo ORDER BY codigo) as codigos_criados
FROM dados_mapoteca.escalas

UNION ALL

SELECT
    'CORES' as tabela,
    COUNT(*) as total_registros,
    ARRAY_AGG(codigo ORDER BY codigo) as codigos_criados
FROM dados_mapoteca.cores

UNION ALL

SELECT
    'ANOS' as tabela,
    COUNT(*) as total_registros,
    ARRAY_AGG(ano::TEXT ORDER BY ano) as codigos_criados
FROM dados_mapoteca.anos;

-- ===================================================================================
-- 10. COMBINAÇÕES VÁLIDAS (6 TIPOS DE PUBLICAÇÃO)
-- ===================================================================================

-- Verificar combinações válidas conforme requisitos
WITH combinacoes_validas AS (
    SELECT
        cp.codigo as classe_codigo,
        cp.nome as classe_nome,
        tp.codigo as tipo_codigo,
        tp.nome as tipo_nome,
        cp.nome || ' - ' || tp.nome as tipo_publicacao_completo,
        ROW_NUMBER() OVER (ORDER BY cp.ordem_exibicao, tp.ordem_exibicao) as ordem
    FROM dados_mapoteca.classes_publicacao cp
    CROSS JOIN dados_mapoteca.tipos_publicacao tp
    WHERE
        -- Mapas: Estadual, Regional, Municipal
        (cp.codigo = 'mapa' AND tp.codigo IN ('estadual', 'regional', 'municipal'))
        OR
        -- Cartogramas: Estadual, Regional, Municipal
        (cp.codigo = 'cartograma' AND tp.codigo IN ('estadual', 'regional', 'municipal'))
)
SELECT
    'COMBINAÇÕES VÁLIDAS (6 TIPOS)' as categoria,
    COUNT(*) as total_combinacoes,
    STRING_AGG(tipo_publicacao_completo, ' | ' ORDER BY ordem) as tipos_suportados
FROM combinacoes_validas;

-- Fim do Script 02
-- ===================================================================================