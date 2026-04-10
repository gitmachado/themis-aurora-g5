# Tela: Detalhe e Conversão de Lead

- **Localização**: [Stack] A partir da Triagem.
- **Objetivo**: Validar triagem da IA e criar o usuário/processo.

## 🏗️ Blueprint Visual
- **Corpo**: 
  - Seção "Capturado pelo Bot": Exibe os 6 campos obrigatórios.
  - Campos editáveis para correção manual do advogado.
  - Botão principal "Converter em Cliente".

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Dados IA | `Lead.descricaoCaso` | Texto longo descritivo. |
| Campo CPF | `Lead.cpf` | Máscara de CPF. |
| Disponibilidade | `Lead.disponibilidadeContato` | Texto (Manhã/Tarde/Noite). |

## 🕹️ Ações
- **Converter**: Cria registro na tabela `User` e gera senha.
- **Anotações**: `Lead.observacoesAdvogado` (Persiste histórico interno).
