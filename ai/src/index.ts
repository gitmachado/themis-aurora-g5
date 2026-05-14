import "dotenv/config";
import express from "express";
import { setupCheckpointer } from "./config/checkpointer.js";
import { whatsappRouter } from "./webhooks/whatsapp.js";
import { graph } from "./graph/index.js";
import { sendWhatsAppMessage } from "./webhooks/send-message.js";
import { syncMessage } from "./graph/nodes/sync.js";

const app = express();
const PORT = process.env.PORT || 3001;

app.use(express.json());
app.use(whatsappRouter);

// ── Handoff Endpoints ──

app.post("/handoff/resume", async (req, res) => {
  const { whatsappNumber } = req.body;
  if (!whatsappNumber) return res.status(400).json({ error: "whatsappNumber is required" });

  console.log(`[AI Module] Recebido pedido de RETOMADA para ${whatsappNumber}`);

  try {
    const config = { configurable: { thread_id: whatsappNumber } };
    await graph.updateState(config, { 
      needsHandoff: false,
      currentNode: "router_node"
    });
    
    const message = "Olá! O atendimento automatizado foi retomado. Qualquer dúvida, estou aqui para ajudar!";
    
    await sendWhatsAppMessage(whatsappNumber, message);
    await syncMessage({
      whatsappNumber,
      content: message,
      senderRole: "BOT",
      messageType: "TEXT",
      whatsappMessageId: null,
    });

    console.log(`[AI Module] Handoff finalizado com sucesso para ${whatsappNumber}. IA retomando.`);
    res.json({ success: true });
  } catch (err) {
    console.error("[AI Module] Erro ao retomar handoff:", err);
    res.status(500).json({ error: "Failed to update state or send message" });
  }
});

app.post("/handoff/start", async (req, res) => {
  const { whatsappNumber } = req.body;
  if (!whatsappNumber) return res.status(400).json({ error: "whatsappNumber is required" });

  console.log(`[AI Module] Recebido pedido de HANDOFF (PAUSA) para ${whatsappNumber}`);

  try {
    const config = { configurable: { thread_id: whatsappNumber } };
    await graph.updateState(config, { 
      needsHandoff: true,
      currentNode: "sync_node"
    });
    
    const message = "Estou transferindo você para um de nossos advogados especialistas. Ele(a) entrará em contato em instantes por aqui mesmo.";
    
    await sendWhatsAppMessage(whatsappNumber, message);
    await syncMessage({
      whatsappNumber,
      content: message,
      senderRole: "BOT",
      messageType: "TEXT",
      whatsappMessageId: null,
    });

    console.log(`[AI Module] Handoff iniciado com sucesso para ${whatsappNumber}. IA silenciada.`);
    res.json({ success: true });
  } catch (err) {
    console.error("[AI Module] Erro ao iniciar handoff:", err);
    res.status(500).json({ error: "Failed to update state or send message" });
  }
});

// ── Health Check ──

app.get("/health", (_req, res) => res.json({ status: "ok" }));

// ── Startup ──

(async () => {
  try {
    await setupCheckpointer();
    app.listen(PORT, () => {
      console.log(`[AI Module] Servidor rodando na porta ${PORT}`);
    });
  } catch (err) {
    console.error("[AI Module] Falha ao iniciar:", err);
    process.exit(1);
  }
})();
