import { Router } from "express";
import { sendWhatsAppMessage } from "./send-message.js";
import { HumanMessage } from "@langchain/core/messages";
import { graph } from "../graph/index.js";
import { INITIAL_TRIAGE, INITIAL_CONFIG } from "../graph/state.js";
import { getBotConfig } from "../tools/config-loader.js";
import {
  containsPromptInjection,
  DEFAULT_GUARDRAIL_RESPONSE,
} from "../utils/guardrails.js";

export const whatsappRouter = Router();

// GET /webhook — handshake de verificação do Meta
whatsappRouter.get("/webhook", (req, res) => {
  const mode = req.query["hub.mode"];
  const token = req.query["hub.verify_token"];
  const challenge = req.query["hub.challenge"];

  if (mode === "subscribe" && token === process.env.WA_VERIFY_TOKEN) {
    res.status(200).send(challenge);
  } else {
    res.sendStatus(403);
  }
});

// POST /webhook — receptor de mensagens do WhatsApp
whatsappRouter.post("/webhook", async (req, res) => {
  // Responde 200 imediatamente — WhatsApp reenvia se não receber em 5s
  res.sendStatus(200);

  try {
    const message =
      req.body?.entry?.[0]?.changes?.[0]?.value?.messages?.[0];
    if (!message) return;

    const whatsappNumber: string = message.from;
    const type: string = message.type;

    // Ignora mensagens não-texto (áudio, imagem, vídeo, etc.)
    if (type !== "text" || !message.text?.body) {
      console.log(
        `[Webhook] Mensagem não-texto ignorada (${type}) de ${whatsappNumber}`
      );
      await sendWhatsAppMessage(whatsappNumber, "Por enquanto só processo mensagens de texto. Por favor, envie sua dúvida escrita. 😊");
      return;
    }

    const textBody: string = message.text.body;

    // Guardrail — bloqueia tentativas de prompt injection antes de invocar o grafo
    if (containsPromptInjection(textBody)) {
      console.warn(`[GUARDRAIL] Injeção detectada de ${whatsappNumber}`);
      await sendWhatsAppMessage(whatsappNumber, DEFAULT_GUARDRAIL_RESPONSE);
      return;
    }

    // Carrega config do escritório (tom, horários, mensagem fora-de-horário)
    const config = await getBotConfig().catch(() => INITIAL_CONFIG);

    // Monta estado inicial da conversa
    const initialState = {
      whatsappNumber,
      userType: "UNKNOWN" as const,
      userId: null,
      leadId: null,
      messages: [new HumanMessage(textBody)],
      triage: INITIAL_TRIAGE,
      currentNode: "router",
      needsHandoff: false,
      handoffReason: null,
      config,
    };

    // Invoca o grafo — thread_id = whatsappNumber vincula ao checkpointer
    const result = await graph.invoke(initialState, {
      configurable: { thread_id: whatsappNumber },
    });

    // Envia resposta do bot ao cliente
    const botMessage = result.messages.at(-1);
    if (botMessage) {
      const responseText = String(botMessage.content);
      await sendWhatsAppMessage(whatsappNumber, responseText);
      console.log(
        `[Webhook] Resposta para ${whatsappNumber}: ${responseText.slice(0, 100)}`
      );
    }
  } catch (err) {
    console.error("[Webhook] Erro ao processar mensagem:", err);
  }
});
