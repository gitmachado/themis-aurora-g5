import { MemorySaver } from "@langchain/langgraph";

// Substituindo PostgresSaver por MemorySaver para remover integração com DB
export const checkpointer = new MemorySaver();

export async function setupCheckpointer(): Promise<void> {
  // MemorySaver não precisa de setup assíncrono para criar tabelas
  return Promise.resolve();
}
