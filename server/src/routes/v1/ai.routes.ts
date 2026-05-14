import { Router, Response } from 'express';
import { authMiddleware, AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { roleMiddleware } from '../../middlewares/implementations/roleMiddleware';
import { MessageRepository } from '@repositories';

const router = Router();
const messageRepository = new MessageRepository();

/**
 * @openapi
 * /ai/lawyer-chat:
 *   post:
 *     summary: Chat com a IA para Advogados (Suporte a Processos)
 *     tags: [AI]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [message]
 *             properties:
 *               message:
 *                 type: string
 *     responses:
 *       200:
 *         description: Resposta da IA com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 reply:
 *                   type: string
 *       400:
 *         description: Erro de validação
 *       504:
 *         description: Timeout do serviço de IA
 */
router.post(
  '/lawyer-chat',
  authMiddleware,
  roleMiddleware(['LAWYER']),
  async (req: AuthRequest, res: Response): Promise<void> => {
    try {
      const { message } = req.body;

      if (!message || typeof message !== 'string' || !message.trim()) {
        res.status(400).json({ error: 'O campo message é obrigatório e deve ser uma string não vazia' });
        return;
      }

      // Por simplicidade, usamos o ID do advogado logado como threadId.
      // Isso garante que cada advogado possua um histórico de conversa único e persistente.
      const lawyerId = req.user!.id;
      const threadId = req.user!.id;

      const aiModuleUrl = process.env.AI_MODULE_URL || 'http://localhost:3001';
      const aiChatUrl = `${aiModuleUrl}/lawyer-chat`;

      console.log(`[AI Route] Iniciando chamada para o chat IA em: ${aiChatUrl} para o advogado ${lawyerId}`);

      const abortController = new AbortController();
      const timeoutId = setTimeout(() => {
        abortController.abort();
      }, 30000);

      let response: globalThis.Response;
      try {
        response = await fetch(aiChatUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ message, lawyerId, threadId }),
          signal: abortController.signal,
        });
      } catch (fetchError: any) {
        if (fetchError.name === 'AbortError') {
          console.error(`[AI Route] Timeout de 30.000ms atingido para o advogado ${lawyerId}`);
          res.status(504).json({ error: 'O assistente IA demorou demais para responder. Tente novamente.' });
          return;
        }

        // Network/DNS/connection failure: upstream is unreachable, not a timeout.
        // Use 502 so troubleshooting (logs, dashboards) can tell the failure modes apart.
        console.error(`[AI Route] Erro ao conectar com o serviço de IA (${aiChatUrl}):`, fetchError);
        res.status(502).json({ error: 'O assistente IA está indisponível no momento. Tente novamente em instantes.' });
        return;
      } finally {
        clearTimeout(timeoutId);
      }

      if (!response.ok) {
        // Upstream replied but with an error status — treat as bad gateway.
        console.error(`[AI Route] Resposta invalida do modulo IA (${response.status}): ${response.statusText}`);
        res.status(502).json({ error: 'O assistente IA retornou um erro. Tente novamente em instantes.' });
        return;
      }

      const responseData = (await response.json()) as { reply?: string };
      const reply = responseData.reply;

      if (!reply) {
        console.error('[AI Route] Resposta vazia ou invalida recebida do modulo IA:', responseData);
        res.status(502).json({ error: 'O assistente IA retornou uma resposta vazia. Tente novamente.' });
        return;
      }

      // Persistência na tabela messages (falha silenciosamente sem bloquear a resposta ao Flutter)
      try {
        // Mensagem do advogado
        await messageRepository.create({
          userId: lawyerId,
          leadId: null,
          whatsappNumber: null,
          sender: 'LAWYER', // Mapeado de 'USER' conceitual para 'LAWYER' conforme regras de tipos e do BD
          content: message,
          whatsappMessageId: null,
        });

        // Resposta da IA
        await messageRepository.create({
          userId: lawyerId,
          leadId: null,
          whatsappNumber: null,
          sender: 'BOT',
          content: reply,
          whatsappMessageId: null,
        });

        console.log(`[AI Route] Mensagens do advogado ${lawyerId} e do assistente persistidas com sucesso`);
      } catch (dbError) {
        console.error('[AI Route] Erro ao persistir mensagens no banco de dados:', dbError);
      }

      res.status(200).json({ reply });
    } catch (error) {
      console.error('[AI Route] Erro inesperado no endpoint lawyer-chat:', error);
      res.status(500).json({ error: 'Ocorreu um erro interno ao processar sua solicitação.' });
    }
  }
);

export default router;
