# Tela: Detalhe e Conversão de Lead

- **Localização**: [Stack] A partir da Triagem.
- **Objetivo**: Validar triagem da IA e criar o usuário/processo.

## 🏗️ Blueprint Visual
- **Corpo**: 
  - Seção "Capturado pelo Bot": Exibe os 6 campos obrigatórios.
  - Campos editáveis para correção manual do advogado.
  - Botão principal "Converter em Cliente".

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Dados IA | `Lead.caseDescription` | Texto longo descritivo. |
| Campo CPF | `Lead.cpf` | Máscara de CPF. |
| Disponibilidade | `Lead.contactAvailability` | Texto (Morning/Afternoon/Night). |

## 🕹️ Ações
- **Converter**: Cria registro na tabela `User` e gera senha.
- **Anotações**: `Lead.lawyerNotes` (Persiste histórico interno).

## 💡 Sugestões do Gemini
- **Seções de Dados**: Agrupar informações em blocos com títulos claros (Dados do Cliente, Relato do Caso).
- **Sticky Footer Bar**: Botão "Converter em Cliente" fixo na base da tela para fácil acesso.
- **Checklist**: Lista de campos obrigatórios marcados visualmente para o advogado conferir.
