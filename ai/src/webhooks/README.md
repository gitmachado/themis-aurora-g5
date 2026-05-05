# Webhooks (`/src/webhooks/`)

Este diretório expõe a API do serviço de Inteligência Artificial para comunicação externa, principalmente com a Meta (WhatsApp).

## O que deve estar aqui:
- **Servidor Express**: Setup básico do express rodando na porta 3001.
- **WhatsApp Webhook (`whatsapp.ts`)**:
  - `GET /webhook`: Endpoint para verificação de token (Handshake) exigido pela Cloud API do WhatsApp.
  - `POST /webhook`: Receptor de mensagens do cliente. Filtra apenas mensagens de texto (v1) e encaminha o `whatsappNumber` e o conteúdo da mensagem para invocação do LangGraph.
