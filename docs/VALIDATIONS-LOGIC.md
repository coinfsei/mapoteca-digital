# ✅ Validations Logic - Mapoteca Digital

## 📋 Visão Geral

Este documento detalha toda a lógica de validações em cascata e regras de negócio implementadas no formulário da Mapoteca Digital.

**Princípio:** SEMPRE validar via tabelas N:N antes de permitir inserção.

---

## 🔑 Regras de Negócio Críticas

### Regra 1: Validação Classe + Tipo ⚠️ CRÍTICA

**Descrição:** Apenas 6 combinações de Classe + Tipo são válidas

**Combinações Permitidas:**
```
1. Mapa (01) + Estadual (01) ✓
2. Mapa (01) + Regional (02) ✓
3. Mapa (01) + Municipal (03) ✓
4. Cartograma (02) + Estadual (01) ✓
5. Cartograma (02) + Regional (02) ✓
6. Cartograma (02) + Municipal (03) ✓
```

**Tabela de Validação:** `t_classe_mapa_tipo_mapa`

**Query SQL:**
```sql
-- Verificar se combinação é válida
SELECT COUNT(*) as is_valid
FROM dados_mapoteca.t_classe_mapa_tipo_mapa
WHERE id_classe_mapa = :classe
  AND id_tipo_mapa = :tipo;

-- Se COUNT = 1: válido
-- Se COUNT = 0: inválido
```

**Implementação JavaScript (Experience Builder):**
```javascript
/**
 * Valida combinação de Classe + Tipo
 * @param {string} idClasse - ID da classe selecionada
 * @param {string} idTipo - ID do tipo selecionado
 * @returns {Promise<boolean>} - true se válido, false se inválido
 */
async function validateClasseTipo(idClasse, idTipo) {
  if (!idClasse || !idTipo) {
    return false;
  }

  const query = {
    where: `id_classe_mapa = '${idClasse}' AND id_tipo_mapa = '${idTipo}'`,
    outFields: ['id_classe_mapa'],
    returnGeometry: false,
    returnCountOnly: true
  };

  try {
    const featureSet = await FS_Mapoteca_Relacionamentos
      .queryFeatures('/0/query', query);

    return featureSet.count === 1;
  } catch (error) {
    console.error('Erro ao validar classe/tipo:', error);
    return false;
  }
}

/**
 * Handler do evento onChange dos dropdowns
 */
form.on('change:id_classe_mapa', async () => {
  const classe = form.getValue('id_classe_mapa');
  const tipo = form.getValue('id_tipo_mapa');

  if (tipo) {
    const isValid = await validateClasseTipo(classe, tipo);
    if (!isValid) {
      form.setError('id_tipo_mapa',
        'Combinação inválida. Consulte a tabela de combinações permitidas.');
      form.clear('id_tipo_mapa');
    }
  }
});

form.on('change:id_tipo_mapa', async () => {
  const classe = form.getValue('id_classe_mapa');
  const tipo = form.getValue('id_tipo_mapa');

  if (classe) {
    const isValid = await validateClasseTipo(classe, tipo);
    if (!isValid) {
      form.setError('id_tipo_mapa',
        'Combinação inválida. Consulte a tabela de combinações permitidas.');
      form.clear('id_tipo_mapa');
    } else {
      form.clearError('id_tipo_mapa');
    }
  }
});
```

**Mensagens de Erro:**
- ❌ "Combinação inválida de Classe e Tipo"
- ❌ "Apenas 6 combinações são permitidas. Consulte a tabela."
- ❌ "Selecione primeiro a Classe do Mapa"

---

### Regra 2: Validação Tipo Regionalização + Região ⚠️ CRÍTICA

**Descrição:** Regiões são específicas para cada tipo de regionalização

**Exemplo:**
```
Tipo Regionalização: "Mesorregiões Geográficas (TRG02)"
  ✓ Regiões válidas: 7 regiões específicas
  ✗ Outras regiões: inválidas para este tipo

Tipo Regionalização: "Territórios de Identidade (TRG05)"
  ✓ Regiões válidas: 26 regiões específicas
  ✗ Outras regiões: inválidas para este tipo
```

**Tabela de Validação:** `t_regionalizacao_regiao` (229 relacionamentos)

**Query SQL:**
```sql
-- Buscar regiões válidas para um tipo de regionalização
SELECT id_regiao, nome_regiao
FROM dados_mapoteca.t_regionalizacao_regiao
WHERE id_tipo_regionalizacao = :tipo_regionalizacao
ORDER BY nome_regiao;

-- Validar combinação específica
SELECT COUNT(*) as is_valid
FROM dados_mapoteca.t_regionalizacao_regiao
WHERE id_tipo_regionalizacao = :tipo_regionalizacao
  AND id_regiao = :regiao;
```

**Implementação JavaScript:**
```javascript
/**
 * Carrega regiões válidas para o tipo de regionalização selecionado
 * @param {string} idTipoRegionalizacao - ID do tipo selecionado
 */
async function loadRegioesValidas(idTipoRegionalizacao) {
  if (!idTipoRegionalizacao) {
    form.setOptions('id_regiao', []);
    form.disable('id_regiao');
    return;
  }

  const query = {
    where: `id_tipo_regionalizacao = '${idTipoRegionalizacao}'`,
    outFields: ['id_regiao', 'nome_regiao'],
    orderByFields: 'nome_regiao ASC',
    returnGeometry: false
  };

  try {
    const featureSet = await FS_Mapoteca_Relacionamentos
      .queryFeatures('/1/query', query);

    const options = featureSet.features.map(f => ({
      value: f.attributes.id_regiao,
      label: f.attributes.nome_regiao
    }));

    form.setOptions('id_regiao', options);
    form.enable('id_regiao');
    form.clear('id_regiao'); // Limpar seleção anterior
  } catch (error) {
    console.error('Erro ao carregar regiões:', error);
    form.setError('id_tipo_regionalizacao',
      'Erro ao carregar regiões. Tente novamente.');
  }
}

/**
 * Handler do evento onChange
 */
form.on('change:id_tipo_regionalizacao', async (event) => {
  const tipoRegionalizacao = event.value;
  await loadRegioesValidas(tipoRegionalizacao);
});

/**
 * Validar ao carregar publicação existente
 */
form.on('load', async (data) => {
  if (data.id_tipo_regionalizacao) {
    await loadRegioesValidas(data.id_tipo_regionalizacao);
  }
});
```

**Mensagens de Erro:**
- ⚠️ "Selecione primeiro o Tipo de Regionalização"
- ❌ "Região inválida para este tipo de regionalização"
- ❌ "Nenhuma região encontrada para este tipo"

---

### Regra 3: Validação Tipo Tema + Tema ⚠️ CRÍTICA

**Descrição:** Temas são categorizados por tipo de tema

**Exemplo:**
```
Tipo Tema: "Físico-Ambiental (TTM03)"
  ✓ Temas válidos: Geologia, Solos, Relevo, Biomas, etc.
  ✗ Outros temas: inválidos para este tipo

Tipo Tema: "Socioeconômico (TTM05)"
  ✓ Temas válidos: População, PIB, ICMS, etc.
  ✗ Outros temas: inválidos para este tipo
```

**Tabela de Validação:** `t_tipo_tema_tema` (55 relacionamentos)

**Query SQL:**
```sql
-- Buscar temas válidos para um tipo de tema
SELECT t.id_tema, t.codigo_tema, t.nome_tema
FROM dados_mapoteca.t_tipo_tema_tema ttt
JOIN dados_mapoteca.t_tema t ON ttt.id_tema = t.id_tema
WHERE ttt.id_tipo_tema = :tipo_tema
ORDER BY t.nome_tema;
```

**Implementação JavaScript:**
```javascript
/**
 * Carrega temas válidos para o tipo de tema selecionado
 * @param {string} idTipoTema - ID do tipo selecionado
 */
async function loadTemasValidos(idTipoTema) {
  if (!idTipoTema) {
    form.setOptions('id_tema', []);
    form.disable('id_tema');
    return;
  }

  // Query na tabela de relacionamento
  const queryRelacionamento = {
    where: `id_tipo_tema = '${idTipoTema}'`,
    outFields: ['id_tema'],
    returnGeometry: false
  };

  try {
    const relacionamentos = await FS_Mapoteca_Relacionamentos
      .queryFeatures('/2/query', queryRelacionamento);

    const idsTemasValidos = relacionamentos.features
      .map(f => f.attributes.id_tema);

    // Query na tabela de temas para obter nomes
    const queryTemas = {
      where: `id_tema IN (${idsTemasValidos.join(',')})`,
      outFields: ['id_tema', 'codigo_tema', 'nome_tema'],
      orderByFields: 'nome_tema ASC',
      returnGeometry: false
    };

    const temas = await FS_Mapoteca_Dominios
      .queryFeatures('/t_tema/query', queryTemas);

    const options = temas.features.map(f => ({
      value: f.attributes.id_tema,
      label: f.attributes.nome_tema
    }));

    form.setOptions('id_tema', options);
    form.enable('id_tema');
    form.clear('id_tema');
  } catch (error) {
    console.error('Erro ao carregar temas:', error);
    form.setError('id_tipo_tema',
      'Erro ao carregar temas. Tente novamente.');
  }
}

/**
 * Handler do evento onChange
 */
form.on('change:id_tipo_tema', async (event) => {
  const tipoTema = event.value;
  await loadTemasValidos(tipoTema);
});
```

---

## 🔒 Validações de Campos Obrigatórios

### Campos Obrigatórios
```javascript
const camposObrigatorios = [
  'id_classe_mapa',       // Classe do Mapa
  'id_tipo_mapa',         // Tipo do Mapa
  'id_ano',               // Ano de Referência
  'id_regiao',            // Região
  'codigo_escala',        // Escala Cartográfica
  'codigo_cor',           // Colorização
  'id_tipo_regionalizacao', // Tipo de Regionalização
  'id_tema',              // Tema
  'id_tipo_tema'          // Tipo de Tema
];

/**
 * Validar se todos os campos obrigatórios foram preenchidos
 * @returns {boolean} - true se válido, false se inválido
 */
function validateRequiredFields() {
  const errors = [];

  camposObrigatorios.forEach(campo => {
    const value = form.getValue(campo);
    if (!value || value === '') {
      errors.push(campo);
      form.setError(campo, 'Campo obrigatório');
    }
  });

  return errors.length === 0;
}

/**
 * Habilitar botão Salvar apenas se formulário válido
 */
form.on('change', () => {
  const isValid = validateRequiredFields();
  form.setButtonEnabled('btnSalvar', isValid);
});
```

---

## 📎 Validações de Attachments (PDFs)

### Regra: Arquivo PDF Válido

**Validações:**
1. ✅ Tipo de arquivo: `application/pdf`
2. ✅ Tamanho máximo: 50 MB (52.428.800 bytes)
3. ✅ Nome do arquivo: máximo 255 caracteres
4. ✅ Header PDF válido: começa com `%PDF`

**Implementação JavaScript:**
```javascript
/**
 * Validar arquivo PDF antes de upload
 * @param {File} file - Arquivo selecionado
 * @returns {object} - { valid: boolean, error: string }
 */
function validatePDF(file) {
  // Validar tipo de arquivo
  if (file.type !== 'application/pdf') {
    return {
      valid: false,
      error: 'Apenas arquivos PDF são permitidos'
    };
  }

  // Validar tamanho (máximo 50MB)
  const maxSize = 52428800; // 50 MB em bytes
  if (file.size > maxSize) {
    const sizeMB = (file.size / 1048576).toFixed(2);
    return {
      valid: false,
      error: `Arquivo muito grande (${sizeMB} MB). Máximo permitido: 50 MB`
    };
  }

  // Validar nome do arquivo
  if (file.name.length > 255) {
    return {
      valid: false,
      error: 'Nome do arquivo muito longo (máximo 255 caracteres)'
    };
  }

  // Validar extensão
  if (!file.name.toLowerCase().endsWith('.pdf')) {
    return {
      valid: false,
      error: 'Arquivo deve ter extensão .pdf'
    };
  }

  return {
    valid: true,
    error: null
  };
}

/**
 * Handler do widget de Attachment
 */
attachmentWidget.on('beforeAdd', (event) => {
  const file = event.file;
  const validation = validatePDF(file);

  if (!validation.valid) {
    event.preventDefault();
    showNotification('error', validation.error);
  }
});

/**
 * Validar header do PDF (opcional - verificação adicional)
 */
async function validatePDFHeader(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();

    reader.onload = (e) => {
      const bytes = new Uint8Array(e.target.result);
      const header = String.fromCharCode(...bytes.slice(0, 4));

      if (header === '%PDF') {
        resolve(true);
      } else {
        reject(new Error('Arquivo não é um PDF válido (header inválido)'));
      }
    };

    reader.onerror = () => reject(new Error('Erro ao ler arquivo'));
    reader.readAsArrayBuffer(file.slice(0, 4));
  });
}
```

**Mensagens de Erro:**
- ❌ "Apenas arquivos PDF são permitidos"
- ❌ "Arquivo muito grande (X MB). Máximo: 50 MB"
- ❌ "Nome do arquivo muito longo (máx 255 caracteres)"
- ❌ "Arquivo não é um PDF válido"

---

## 🎯 Função de Validação Completa

```javascript
/**
 * Validação completa do formulário antes de salvar
 * @returns {Promise<object>} - { valid: boolean, errors: array }
 */
async function validateForm() {
  const errors = [];

  // 1. Validar campos obrigatórios
  if (!validateRequiredFields()) {
    errors.push({ field: 'required', message: 'Preencha todos os campos obrigatórios' });
  }

  // 2. Validar Classe + Tipo
  const classe = form.getValue('id_classe_mapa');
  const tipo = form.getValue('id_tipo_mapa');
  if (classe && tipo) {
    const isValid = await validateClasseTipo(classe, tipo);
    if (!isValid) {
      errors.push({ field: 'id_tipo_mapa', message: 'Combinação inválida de Classe e Tipo' });
    }
  }

  // 3. Validar Tipo Regionalização + Região
  const tipoReg = form.getValue('id_tipo_regionalizacao');
  const regiao = form.getValue('id_regiao');
  if (tipoReg && regiao) {
    const query = {
      where: `id_tipo_regionalizacao = '${tipoReg}' AND id_regiao = '${regiao}'`,
      returnCountOnly: true
    };
    const result = await FS_Mapoteca_Relacionamentos.queryFeatures('/1/query', query);
    if (result.count === 0) {
      errors.push({ field: 'id_regiao', message: 'Região inválida para este tipo de regionalização' });
    }
  }

  // 4. Validar Tipo Tema + Tema
  const tipoTema = form.getValue('id_tipo_tema');
  const tema = form.getValue('id_tema');
  if (tipoTema && tema) {
    const query = {
      where: `id_tipo_tema = '${tipoTema}' AND id_tema = ${tema}`,
      returnCountOnly: true
    };
    const result = await FS_Mapoteca_Relacionamentos.queryFeatures('/2/query', query);
    if (result.count === 0) {
      errors.push({ field: 'id_tema', message: 'Tema inválido para este tipo de tema' });
    }
  }

  // 5. Validar attachment (se houver)
  const attachments = attachmentWidget.getAttachments();
  if (attachments.length === 0) {
    errors.push({ field: 'attachment', message: 'É necessário anexar pelo menos um PDF' });
  }

  return {
    valid: errors.length === 0,
    errors: errors
  };
}

/**
 * Salvar formulário com validação completa
 */
async function saveForm() {
  // Validar formulário
  const validation = await validateForm();

  if (!validation.valid) {
    showNotification('error', 'Existem erros no formulário. Corrija antes de salvar.');
    validation.errors.forEach(error => {
      form.setError(error.field, error.message);
    });
    return;
  }

  try {
    // Salvar publicação
    const feature = form.getFeature();
    const result = await FS_Mapoteca_Publicacoes.applyEdits({
      adds: [feature]
    });

    if (result.addFeatureResults[0].success) {
      showNotification('success', 'Publicação salva com sucesso!');
      form.clear();
      listWidget.refresh();
    } else {
      showNotification('error', 'Erro ao salvar publicação');
    }
  } catch (error) {
    console.error('Erro ao salvar:', error);
    showNotification('error', 'Erro ao salvar publicação: ' + error.message);
  }
}
```

---

## 📊 Matriz de Validações

| Campo | Tipo Validação | Tabela N:N | Obrigatório | Erro |
|-------|---------------|------------|-------------|------|
| `id_classe_mapa` | Dropdown | - | ✓ | Campo obrigatório |
| `id_tipo_mapa` | Dropdown + Cascata | `t_classe_mapa_tipo_mapa` | ✓ | Combinação inválida |
| `id_ano` | Dropdown | - | ✓ | Campo obrigatório |
| `id_tipo_regionalizacao` | Dropdown | - | ✓ | Campo obrigatório |
| `id_regiao` | Dropdown + Cascata | `t_regionalizacao_regiao` | ✓ | Região inválida |
| `id_tipo_tema` | Dropdown | - | ✓ | Campo obrigatório |
| `id_tema` | Dropdown + Cascata | `t_tipo_tema_tema` | ✓ | Tema inválido |
| `codigo_escala` | Dropdown | - | ✓ | Campo obrigatório |
| `codigo_cor` | Dropdown | - | ✓ | Campo obrigatório |
| Attachment (PDF) | File Upload | - | ✓ | PDF inválido ou ausente |

---

## 🧪 Casos de Teste

### Teste 1: Validação Classe + Tipo
```javascript
// Válido
await validateClasseTipo('01', '01'); // true (Mapa Estadual)
await validateClasseTipo('02', '03'); // true (Cartograma Municipal)

// Inválido
await validateClasseTipo('99', '01'); // false (combinação não existe)
await validateClasseTipo('01', '99'); // false (combinação não existe)
```

### Teste 2: Cascata Regionalização → Região
```javascript
// Carregar regiões para tipo TRG02 (Mesorregiões)
await loadRegioesValidas('TRG02');
// Deve retornar: 7 regiões

// Carregar regiões para tipo TRG05 (Territórios de Identidade)
await loadRegioesValidas('TRG05');
// Deve retornar: 26 regiões
```

### Teste 3: Upload de PDF
```javascript
// Válido
const validPDF = new File(['content'], 'mapa.pdf', {
  type: 'application/pdf',
  size: 1048576 // 1 MB
});
validatePDF(validPDF); // { valid: true, error: null }

// Inválido - tamanho
const largePDF = new File(['content'], 'mapa.pdf', {
  type: 'application/pdf',
  size: 52428801 // > 50 MB
});
validatePDF(largePDF); // { valid: false, error: 'Arquivo muito grande...' }

// Inválido - tipo
const invalidFile = new File(['content'], 'documento.docx', {
  type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
});
validatePDF(invalidFile); // { valid: false, error: 'Apenas arquivos PDF...' }
```

---

## 📋 Checklist de Implementação

### Validações Básicas
- [ ] Campos obrigatórios configurados
- [ ] Mensagens de erro personalizadas
- [ ] Botão Salvar desabilitado se inválido

### Validações em Cascata
- [ ] Classe + Tipo validado via `t_classe_mapa_tipo_mapa`
- [ ] Tipo Regionalização → Região via `t_regionalizacao_regiao`
- [ ] Tipo Tema → Tema via `t_tipo_tema_tema`

### Validações de Attachment
- [ ] Tipo de arquivo (apenas PDF)
- [ ] Tamanho máximo (50 MB)
- [ ] Nome do arquivo (máx 255 caracteres)
- [ ] Header PDF válido

### Testes
- [ ] Todos os casos de teste passando
- [ ] Mensagens de erro claras e úteis
- [ ] Performance < 1s por validação

---

**Versão:** 1.0
**Data:** 2025-11-17
**Status:** ✅ Pronto para Implementação
