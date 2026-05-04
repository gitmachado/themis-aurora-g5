import { PostgresSaver } from "@langchain/langgraph-checkpoint-postgres";
import pg from "pg";

const DATABASE_URL = process.env.DATABASE_URL || "postgresql://postgres:postgres@localhost:5433/omniconnect_db";

const pool = new pg.Pool({ connectionString: DATABASE_URL });

export const checkpointer = PostgresSaver.fromConnString(DATABASE_URL);

export async function setupCheckpointer(): Promise<void> {
  // PostgresSaver cria suas tabelas automaticamente (checkpoints, checkpoint_writes, etc.)
  await (checkpointer as any).setup();
}
