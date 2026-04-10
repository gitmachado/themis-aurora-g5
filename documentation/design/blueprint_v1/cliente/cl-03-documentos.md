# Tela: CL-03 - Central de Documentos (Cliente)

- **Tipo**: [Tab Bar] Aba 3
- **Atalho**: `@cliente-documentos`

## 🧭 Navegação (Stack)
- **Origem**: Tab Bar
- **Destinos possíveis**:
    - Visualizador de PDF/Imagem (Push)

## 🏗️ Anatomia Visual
- **Tabs**: "Enviados" e "Recebidos".
- **FAB**: Botão "+" para iniciar upload.
- **Empty State**: Ilustração e instrução de como subir arquivos.

## 📊 Mapeamento de Dados (G5-8)
- `Documento[]`: Lista de arquivos vinculados ao usuário.
- `Documento.mimeType`: Ícones dinâmicos.
