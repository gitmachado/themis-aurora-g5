import { ChatOpenAI, OpenAIEmbeddings } from "@langchain/openai";
import { AIMessage } from "@langchain/core/messages";
import { MemoryVectorStore } from "langchain/vectorstores/memory";
import { OmniStateType } from "../state.js";
import { SYSTEM_PROMPT, RAG_PROMPT } from "../../config/prompts.js";

// Indicadores determinísticos de que o LLM não encontrou resposta na base
const HANDOFF_INDICATORS = [
  "não tenho essa informação",
  "não está no contexto",
  "transferir para um advogado",
  "não posso responder",
  "fora do contexto",
];

function containsHandoffIndicator(text: string): boolean {
  const lower = text.toLowerCase();
  return HANDOFF_INDICATORS.some((indicator) => lower.includes(indicator));
}

export async function ragNode(
  state: OmniStateType
): Promise<Partial<OmniStateType>> {
  const { messages } = state;
  const query = String(messages.at(-1)?.content ?? "").trim();

  // 1. Inicializa embeddings e vector store (MOCK IN MEMORY)
  const embeddings = new OpenAIEmbeddings({
    model: process.env.OPENAI_EMBEDDING_MODEL || "text-embedding-3-small",
    apiKey: process.env.OPENAI_API_KEY,
  });

  let vectorStore: MemoryVectorStore;
  try {
    vectorStore = await MemoryVectorStore.fromTexts(
      [
        // documentos_necessarios.pdf
        "Para casos trabalhistas, os documentos essenciais são: Carteira de Trabalho (CTPS), contracheques dos últimos 3 meses, contrato de trabalho e extrato do FGTS. Para rescisão, é necessário também o termo de rescisão (TRCT) e o aviso prévio (se aplicável). Documentos enviados devem estar em PDF legível, preferencialmente escaneados.",
        "Para casos de direito de família como divórcio e guarda, são necessários: certidão de casamento, documentos dos filhos (RG e certidão de nascimento), comprovante de renda de ambas as partes e a lista de bens do casal. Para inventário: certidão de óbito, matrícula dos imóveis e extratos bancários do falecido.",

        // faq_geral.pdf
        "O escritório atende as seguintes áreas do Direito: Trabalhista (rescisão, assédio, horas extras), Família (divórcio, guarda, pensão, inventário), Cível (contratos, cobranças, indenizações) e Previdenciário (aposentadoria, auxílio-doença, INSS). Não atuamos em Direito Penal/Criminal.",
        "O escritório oferece consulta inicial gratuita para análise do caso. Os honorários são definidos após a consulta e variam conforme a complexidade. Na área trabalhista, é comum o modelo de êxito (percentual sobre o valor ganho). Parcelamento dos honorários pode ser negociado diretamente com o advogado responsável.",

        // jurisprudencia_trabalhista.pdf
        "Horas extras: Todo trabalho realizado além da jornada contratual (ex: além das 8h diárias ou 44h semanais) deve ser pago com acréscimo de no mínimo 50% sobre o valor da hora normal. Se houver acordo coletivo, o percentual pode ser superior. O banco de horas só é válido se previsto em convenção coletiva. A prescrição para cobrar horas extras é de 5 anos, limitada a 2 anos após a demissão.",
        "Assédio moral: Caracterizado por exposição do trabalhador a situações humilhantes e constrangedoras de forma repetitiva. A jurisprudência trabalhista condena empresas que permitem práticas de cobranças abusivas de metas, xingamentos ou isolamento do funcionário. A prova pode ser feita por testemunhas. Doença ocupacional (LER, burnout, depressão) gera direito a estabilidade de 12 meses após o retorno do benefício previdenciário.",

        // modelos_contrato.pdf
        "Todo contrato cível deve conter: qualificação das partes (CPF, RG, endereço), objeto claramente definido, preço e forma de pagamento, obrigações de ambas as partes, prazos, hipóteses de rescisão e foro de eleição. A cláusula penal (multa) é fundamental e costuma ser de 10% a 20% sobre o valor inadimplido. Assinaturas digitais com certificado ICP-Brasil têm validade jurídica equivalente à assinatura física.",
        "Cláusula de confidencialidade (NDA): deve definir o que é informação confidencial, o período de vigência (pode perdurar após o fim do contrato) e estipular multa em caso de vazamento. Cláusula de foro recomendada: 'Para dirimir quaisquer controvérsias oriundas do presente contrato, as partes elegem o foro da comarca de São Paulo/SP.'",

        // regras_escritorio.pdf
        "Horário de atendimento do escritório: Segunda a quinta das 09h às 18h, sexta das 09h às 17h. Fechado aos sábados, domingos e feriados (exceto plantões urgentes). Intervalo de almoço das 12h às 13h30. Canais oficiais: e-mail contato@escritorio.com.br, telefone (11) 3000-0000 e WhatsApp Business (11) 98888-0000. SLA: e-mails respondidos em até 48h úteis, WhatsApp em até 24h úteis.",
        "O escritório opera em conformidade com a LGPD e o Estatuto da Advocacia da OAB. Todas as informações e documentos dos clientes são protegidos por sigilo profissional absoluto. Não fornecemos informações de processos a terceiros sem autorização formal do cliente. Reuniões devem ser agendadas com 24h de antecedência mínima. Tolerância de atraso: 15 minutos.",
      ],
      [
        { id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }, { id: 5 },
        { id: 6 }, { id: 7 }, { id: 8 }, { id: 9 }, { id: 10 },
      ],
      embeddings
    );
  } catch (err) {
    console.error("[RAG Node] Erro ao instanciar MemoryVectorStore:", err);
    return {
      currentNode: "handoff_node",
      needsHandoff: true,
      handoffReason: "Falha ao acessar a base de conhecimento",
      messages: [
        new AIMessage(
          "Não consegui acessar nossa base de conhecimento. Vou te conectar com um advogado."
        ),
      ],
    };
  }

  // 2. Busca os top 4 chunks mais relevantes
  let relevantDocs: Awaited<ReturnType<typeof vectorStore.similaritySearch>>;
  try {
    relevantDocs = await vectorStore.similaritySearch(query, 4);
  } catch (err) {
    console.error("[RAG Node] Erro na busca vetorial:", err);
    relevantDocs = [];
  }

  // 3. Monta contexto a partir dos chunks recuperados
  const context =
    relevantDocs.length > 0
      ? relevantDocs.map((d) => d.pageContent).join("\n---\n")
      : "Nenhum documento relevante encontrado.";

  // 4. Gera resposta com prompt defensivo
  const model = new ChatOpenAI({
    model: process.env.OPENAI_MODEL || "gpt-4o-mini",
    apiKey: process.env.OPENAI_API_KEY,
    temperature: 0,
  });

  const prompt = RAG_PROMPT.replace("{context}", context).replace("{query}", query);

  const response = await model.invoke([
    { role: "system", content: SYSTEM_PROMPT },
    { role: "user", content: prompt },
  ]);

  const responseText = String(response.content);

  // 5. Se sem chunks ou LLM indicou falta de informação → aciona handoff
  if (relevantDocs.length === 0 || containsHandoffIndicator(responseText)) {
    return {
      currentNode: "handoff_node",
      needsHandoff: true,
      handoffReason: "Pergunta fora da base de conhecimento",
      messages: [new AIMessage(responseText)],
    };
  }

  return {
    currentNode: "sync_node",
    needsHandoff: false,
    messages: [new AIMessage(responseText)],
  };
}
