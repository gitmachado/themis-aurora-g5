import { Router } from "express";
import { HumanMessage } from "@langchain/core/messages";
import { lawyerGraph } from "../graph/lawyer-graph.js";

export const lawyerChatRouter = Router();

lawyerChatRouter.post("/lawyer-chat", async (req, res) => {
  try {
    const { message, lawyerId, threadId } = req.body || {};

    if (!message || !lawyerId || !threadId) {
      return res.status(400).json({ error: "Faltando campos obrigatórios: message, lawyerId ou threadId" });
    }

    console.log(`[LawyerChat] Processando mensagem do advogado ${lawyerId} na thread ${threadId}`);

    const result = await lawyerGraph.invoke(
      {
        messages: [new HumanMessage(message)],
        lawyerId,
      },
      {
        configurable: { thread_id: threadId },
      }
    );

    const lastMessage = result.messages.at(-1);
    const reply = typeof lastMessage?.content === "string"
      ? lastMessage.content
      : JSON.stringify(lastMessage?.content ?? "");

    return res.status(200).json({ reply });
  } catch (err) {
    console.error("[LawyerChat] Erro:", err);
    return res.status(500).json({ error: "Erro interno ao processar mensagem" });
  }
});
