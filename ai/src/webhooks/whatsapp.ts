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
import { downloadWhatsAppMedia } from "../utils/media-downloader.js";
import { transcribeAudio } from "../utils/transcriber.js";
import { syncMessage } from "../graph/nodes/sync.js";
import { getLeadByPhone, notifyLawyer } from "../utils/backend-client.js";
import { FALLBACK_ERROR_MESSAGE } from "../config/prompts.js";

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
    const message = req.body?.entry?.[0]?.changes?.[0]?.value?.messages?.[0];
    
    if (message) {
      console.log(`[Webhook] Mensagem recebida de ${message.from}: ${message.text?.body || "(sem texto)"}`);
    }

    if (!message) return;

    const whatsappNumber: string = message.from;
    const type: string = message.type;

    console.log(`[Webhook] Processando mensagem de ${whatsappNumber}, tipo: ${type}`);

    // Resolve o corpo de texto — áudio é transcrito, demais não-texto são ignorados
    let textBody: string;
    if (type === "audio" && message.audio?.id) {
      console.log(`[Webhook] Áudio recebido de ${whatsappNumber}, transcrevendo...`);
      try {
        const audioBuffer = await downloadWhatsAppMedia(message.audio.id);
        textBody = await transcribeAudio(audioBuffer, message.audio.mime_type ?? "audio/ogg");
        console.log(`[Webhook] Transcrição concluída para ${whatsappNumber}: "${textBody.substring(0, 60)}..."`);
      } catch (transcriptionErr) {
        console.error("[Webhook] Falha ao transcrever áudio:", transcriptionErr);
        await sendWhatsAppMessage(
          whatsappNumber,
          "Não consegui entender o áudio. 😔 Poderia digitar sua mensagem?"
        );
        return;
      }
    } else if (type === "text" && message.text?.body) {
      textBody = message.text.body;
    } else {
      console.log(`[Webhook] Tipo de mensagem não suportado (${type}) de ${whatsappNumber}`);
      await sendWhatsAppMessage(
        whatsappNumber,
        "Por enquanto só processo mensagens de texto e áudio. Por favor, envie sua dúvida escrita ou em áudio. 😊"
      );
      return;
    }

    const messageId: string = message.id;

    // 2. Sincroniza mensagem do cliente com o backend imediatamente
    try {
      await syncMessage({
        whatsappNumber,
        content: textBody,
        senderRole: "CLIENT",
        messageType: "TEXT",
        whatsappMessageId: messageId,
      });
    } catch (syncErr) {
      console.error("[Webhook] Erro ao sincronizar mensagem do cliente:", syncErr);
    }

    // 3. Guardrail — bloqueia tentativas de prompt injection
    if (containsPromptInjection(textBody)) {
      console.warn(`[GUARDRAIL] Injeção detectada de ${whatsappNumber}`);
      await sendWhatsAppMessage(whatsappNumber, DEFAULT_GUARDRAIL_RESPONSE);
      return;
    }

    // 4. Carrega config do escritório
    const config = await getBotConfig().catch(() => {
      console.warn("[Webhook] Falha ao carregar config, usando padrão.");
      return INITIAL_CONFIG;
    });

    // 5. Verificação de horário de atendimento foi removida (atendimento 24h)

    // 6. Sincroniza estado de pausa do banco de dados com a IA
    const graphConfig = { configurable: { thread_id: whatsappNumber } };
    const currentState = await graph.getState(graphConfig);
    const hasExistingState = currentState?.values && Object.keys(currentState.values).length > 0;

    // Se a consulta ao banco falhar, MANTÉM o estado anterior (nunca força false)
    let finalNeedsHandoff = hasExistingState ? currentState.values.needsHandoff : false;
    try {
      const lead = await getLeadByPhone(whatsappNumber);
      if (lead?.isAIPaused !== undefined) {
        finalNeedsHandoff = lead.isAIPaused;
      }
    } catch (dbErr: any) {
      console.error("[Webhook] Erro ao consultar estado de pausa no banco (mantendo estado anterior):", dbErr.message);
      // Não altera finalNeedsHandoff — mantém o estado do grafo
    }

    // 7. Monta estado e invoca o grafo
    const initialState = {
      whatsappNumber,
      userType: "UNKNOWN" as const,
      userId: null,
      leadId: null,
      messages: [new HumanMessage(textBody)],
      triage: INITIAL_TRIAGE,
      currentNode: "router_node",
      needsHandoff: finalNeedsHandoff,
      handoffReason: null,
      config,
    };

    console.log(`[Webhook] Invocando grafo para ${whatsappNumber}... (Handoff: ${finalNeedsHandoff})`);
    const result = await graph.invoke(
      hasExistingState ? { messages: [new HumanMessage(textBody)], needsHandoff: finalNeedsHandoff } : initialState,
      graphConfig
    );
    console.log(`[Webhook] Grafo finalizado para ${whatsappNumber}.`);

    // 8. Envia resposta do bot ao cliente
    const botMessages = result.messages || [];
    const lastMessage = botMessages.at(-1);

    if (lastMessage && lastMessage.content) {
      const isAI = (lastMessage as any)._getType?.() === 'ai' || 
                   (lastMessage as any).type === 'ai';
      
      if (isAI) {
        await sendWhatsAppMessage(whatsappNumber, String(lastMessage.content));
        console.log(`[Webhook] Resposta enviada para ${whatsappNumber}: ${String(lastMessage.content).substring(0, 80)}...`);
      } else {
        console.log(`[Webhook] Última mensagem não é AI (${(lastMessage as any).type}), pulando envio.`);
      }
    } else {
      console.log(`[Webhook] Grafo não retornou mensagens para enviar.`);
    }
  } catch (err) {
    console.error("[Webhook] Erro CRÍTICO ao processar mensagem:", err);
    try {
      const message = req.body?.entry?.[0]?.changes?.[0]?.value?.messages?.[0];
      if (message?.from) {
        await sendWhatsAppMessage(message.from, FALLBACK_ERROR_MESSAGE);
        
        await notifyLawyer({
          type: "EMERGENCY_HANDOFF",
          message: `ERRO CRÍTICO NA IA: O bot travou ao processar mensagem de ${message.from}. Erro: ${err instanceof Error ? err.message : String(err)}`,
          whatsappNumber: message.from
        }).catch(() => {});
      }
    } catch (fallbackErr) {
      console.error("[Webhook] Falha ao enviar feedback de erro:", fallbackErr);
    }
  }
});
