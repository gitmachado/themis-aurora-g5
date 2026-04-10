// ========================
// Enums do Domínio OmniConnect
// ========================

/** Nichos de atuação jurídica suportados */
export type TipoCaso =
  | 'Trabalhista'
  | 'Cível'
  | 'Família'
  | 'Criminal'
  | 'Previdenciário';

/** Nível de urgência informado pelo lead */
export type NivelUrgencia = 'Alta' | 'Média' | 'Baixa';

/** Estado do lead no funil de conversão */
export type StatusLead = 'PENDENTE' | 'EM_CONTATO' | 'CONVERTIDO' | 'DESCARTADO';

/** Status do processo jurídico */
export type StatusProcesso =
  | 'EM_ABERTO'
  | 'EM_ANALISE'
  | 'AGUARDANDO_DOCUMENTO'
  | 'CONCLUIDO'
  | 'ARQUIVADO';

/** Perfis de acesso ao sistema */
export type UserRole = 'ADVOGADO' | 'CLIENTE';

/** Tipos de evento na timeline de um processo */
export type TipoEvento =
  | 'ATUALIZACAO_STATUS'
  | 'NOTA_ADVOGADO'
  | 'ENVIO_DOCUMENTO'
  | 'CRIACAO_PROCESSO';

/** Disponibilidade de contato informada pelo lead */
export type DisponibilidadeContato = 'Manhã' | 'Tarde' | 'Noite';

/** Tipos de notificação push (FCM) */
export type TipoNotificacao =
  | 'NOVO_LEAD'
  | 'STATUS_ALTERADO'
  | 'DOCUMENTO_ENVIADO'
  | 'SUPORTE_HUMANO';

/** Quem enviou a mensagem no chat */
export type RemetenteMensagem = 'BOT' | 'CLIENTE' | 'ADVOGADO';
