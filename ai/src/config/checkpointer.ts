import { PostgresSaver } from "@langchain/langgraph-checkpoint-postgres";

const DATABASE_URL =
  process.env.DATABASE_URL ||
  "postgresql://postgres:postgres@localhost:5432/omniconnect";

export const checkpointer = PostgresSaver.fromConnString(DATABASE_URL);

// Cria as tabelas internas do LangGraph no PostgreSQL (executar 1x na inicialização)
export async function setupCheckpointer(): Promise<void> {
  await checkpointer.setup();
}
