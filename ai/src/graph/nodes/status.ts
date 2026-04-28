import { AIMessage } from "@langchain/core/messages";
import { OmniStateType } from "../state.js";

// Removido axios e backend url para desacoplamento de infra

const STATUS_LABELS: Record<string, string> = {
  OPEN: "Aberto",
  UNDER_ANALYSIS: "Em Análise",
  AWAITING_DOCUMENT: "Aguardando Documentos",
  COMPLETED: "Concluído",
  ARCHIVED: "Arquivado",
};

const NUMS = ["1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣"];

function formatDate(date: string | null): string {
  if (!date) return "—";
  return new Date(date).toLocaleDateString("pt-BR");
}

function formatSingle(p: any): string {
  const status = STATUS_LABELS[p.currentStatus] ?? p.currentStatus;
  const lines = [
    `📋 ${p.title}${p.processNumber ? ` | Nº ${p.processNumber}` : ""}`,
    `📊 Status: ${status}`,
    `📅 Última movimentação: ${formatDate(p.lastMovementDate)}`,
  ];
  if (p.lastNote) lines.push(`💬 "${p.lastNote}"`);
  return lines.join("\n");
}

function formatList(processes: any[]): string {
  const items = processes
    .slice(0, 5)
    .map((p, i) => {
      const status = STATUS_LABELS[p.currentStatus] ?? p.currentStatus;
      return `${NUMS[i]} ${p.title}${p.processNumber ? ` (Nº ${p.processNumber})` : ""} — ${status}`;
    })
    .join("\n");
  return `Você tem ${processes.length} processo(s):\n\n${items}\n\nQual deseja consultar? (Digite o número)`;
}

async function fetchProcesses(whatsappNumber: string): Promise<any[]> {
  // MOCK: Para independência, retornando mock em vez da chamada Axios
  console.log(`[Status Node] Mocking fetchProcesses for ${whatsappNumber}`);
  return [
    {
      id: "mock-1",
      title: "Ação Trabalhista",
      processNumber: "1234567-89.2024.5.02.0001",
      currentStatus: "UNDER_ANALYSIS",
      lastMovementDate: new Date().toISOString(),
      lastNote: "Aguardando despacho do juiz",
    }
  ];
}

export async function statusNode(
  state: OmniStateType
): Promise<Partial<OmniStateType>> {
  const { whatsappNumber, messages } = state;
  const userInput = String(messages.at(-1)?.content ?? "").trim();

  let processes: any[];
  try {
    processes = await fetchProcesses(whatsappNumber);
  } catch (err) {
    console.error("[Status Node] Erro ao buscar processos:", err);
    return {
      currentNode: "sync_node",
      messages: [
        new AIMessage("Não consegui consultar seus processos agora. Tente novamente em instantes."),
      ],
    };
  }

  // Usuário escolheu um número da lista anterior
  const choice = parseInt(userInput, 10);
  if (!isNaN(choice) && choice >= 1 && choice <= processes.length) {
    return {
      currentNode: "sync_node",
      messages: [new AIMessage(formatSingle(processes[choice - 1]))],
    };
  }

  if (processes.length === 0) {
    return {
      currentNode: "sync_node",
      messages: [
        new AIMessage(
          "Você não tem processos abertos no nosso escritório.\nQuer abrir um novo caso? Posso ajudar com a triagem! 😊"
        ),
      ],
    };
  }

  if (processes.length === 1) {
    return {
      currentNode: "sync_node",
      messages: [new AIMessage(formatSingle(processes[0]))],
    };
  }

  // Múltiplos processos — lista numerada, aguarda escolha
  return {
    currentNode: "sync_node",
    messages: [new AIMessage(formatList(processes))],
  };
}
