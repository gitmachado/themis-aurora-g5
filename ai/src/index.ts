import "dotenv/config";
import express from "express";
import { setupCheckpointer } from "./config/checkpointer.js";
import { whatsappRouter } from "./webhooks/whatsapp.js";

const app = express();
const PORT = process.env.PORT || 3001;

app.use(express.json());
app.use(whatsappRouter);

app.get("/health", (_req, res) => res.json({ status: "ok" }));

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
