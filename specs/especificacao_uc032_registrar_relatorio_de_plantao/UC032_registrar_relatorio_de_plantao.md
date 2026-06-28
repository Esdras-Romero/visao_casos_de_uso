# UC032 - Registrar relatório de plantão

## Objetivo
Registrar o relatório oficial de encerramento de turno, consolidando as ocorrências atendidas, o efetivo presente, o uso de viaturas, o consumo de combustível e quaisquer intercorrências operacionais ocorridas durante o plantão da Guarda Municipal.

## Ator Principal
Supervisor de Plantão

## Pré-condições
- Usuário devidamente autenticado com o perfil de Supervisor de Plantão ou Comando Geral.
- Existência de um plantão ativo ou encerrado nas últimas 24 horas atrelado à equipe ou subinspetoria do ator.

## Pós-condições
- Relatório de plantão persistido de forma permanente, mudando o estado do turno para `ENCERRADO` e vinculando todas as ocorrências mapeadas do período ao documento unificado.

## Dicionário de Dados da Tela/Ação

| Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra |
| :--- | :--- | :--- | :--- |
| **ID_Plantao** | Inteiro | Sim | Identificador numérico do plantão correspondente no banco. |
| **Resumo_Operacional** | Texto (2000) | Sim | Descrição narrativa detalhada das atividades desenvolvidas pela corporação. |
| **Kms_Rodados_Viatura** | Inteiro | Sim | Somatório da quilometragem percorrida pelas viaturas do turno. Deve ser maior que `0`. |
| **Intercorrencia_Efetivo** | Booleano | Sim | Flag indicando se houve faltas, dispensas médicas ou punições disciplinares. |

## Fluxo principal
1. O Supervisor de Plantão acessa o menu de encerramento de turnos operacionais no painel do SIG-GCM.
2. O ator seleciona o turno correspondente e aciona a funcionalidade **Registrar relatório de plantão**.
3. O sistema recupera e exibe em formato de sumário os dados pré-carregados do turno: relação de guardas escalados, lista de viaturas alocadas e o número de ocorrências despachadas automaticamente para aquela equipe.
4. O ator preenche o campo `Resumo_Operacional`, informa os `Kms_Rodados_Viatura` e marca a flag de `Intercorrencia_Efetivo`.
5. O ator aciona o comando "Finalizar e Protocolar Relatório".
6. O sistema intercepta o envio e valida as regras de controle de acesso (RBAC), confirmando que a matrícula do usuário possui autorização de supervisão de campo.
7. O sistema confere se os campos obrigatórios estão preenchidos e executa o batimento de integridade dos dados (se a quilometragem informada faz sentido técnico).
8. O sistema altera o status do turno de `EM_ANDAMENTO` para `CONCLUIDO`, gera um número de protocolo sequencial inviolável para o relatório e o anexa de forma definitiva ao registro do plantão.
9. O sistema dispara uma notificação assíncrona automática via push e e-mail para a Inspetoria Geral com o sumário consolidado do turno.
10. O sistema recarrega a página exibindo o número do protocolo e a mensagem de sucesso: `"Relatório de Plantão protocolado com sucesso sob o número #GCM-2026-XXXX. Turno encerrado no sistema."`

## Fluxo alternativos e exceções

### A1 - Dados inválidos
* **4a. Quilometragem Negativa ou Inconsistente:** Se o ator preencher o campo `Kms_Rodados_Viatura` com um valor menor ou igual a zero, o sistema bloqueia o envio, realça a caixa de texto e exibe a mensagem de erro: `"Erro de Consistência: A quilometragem informada para o conjunto de viaturas deve ser superior a zero."`

### A2 - Acesso não autorizado
* **6a. Tentativa de Encerramento por Guarda de Linha (GCM Padrão):** Se um guarda civil operacional sem atribuição de supervisão ou comando tentar forçar a submissão de dados para este endpoint de fechamento, o sistema rejeita a operação na camada do controlador e exibe: `"Acesso Negado: O registro e encerramento de relatórios de plantão é restrito ao Supervisor de Plantão responsável pelo turno."`

### A3 - Regra de negócio violada
* **7a. Plantão já Encerrado ou Modificado por Outro Supervisor:** Se o ator tentar salvar o relatório de um plantão cujo status no banco já consta como `CONCLUIDO` (ex: em caso de clique duplo ou ação conjunta de co-supervisores), o sistema cancela a transação e apresenta a justificativa: `"Operação Recusada: Este plantão já foi finalizado e protocolado previamente por outro operador. Alterações não permitidas."`

## Regras de negócio relacionadas
* **RN006 (Imutabilidade de Relatório Protocolado):** Após a geração do número de protocolo oficial e encerramento do turno, o texto descritivo do relatório não poderá sofrer nenhuma exclusão ou edição direta, permitindo-se apenas anexos de adendos assinados.
* **RN007 (Vínculo de Ocorrências Pendentes):** Não é permitido fechar um relatório de plantão se houver alguma ocorrência com status `EM_ATENDIMENTO` pendente pela equipe. Todas devem ser encerradas ou repassadas para o turno subsequente antes do fechamento.

## Critérios de aceitação
* O sistema deve calcular automaticamente a quantidade total de horas trabalhadas no plantão com base no timestamp de abertura e fechamento.
* O relatório final deve ser disponibilizado imediatamente para exportação em formato PDF com o brasão oficial da Guarda Civil Municipal.
* O tempo total de resposta para salvar os dados e mudar o status do plantão no banco de dados não deve exceder 500ms.

## Logs de auditoria
Sendo o fechamento de turno um ato administrativo com implicações operacionais e jurídicas, o sistema grava de forma compulsória na tabela `tb_audit_shift_reports`:

[TIMESTAMP_UTC] | [USER_ID: ID_Supervisor] | [ROLE: Supervisor_Plantao] | [SHIFT_ID: ID_Plantao]
[PROTOCOL_NUM: Protocolo_Gerado] | [TOTAL_KM: Kms_Rodados_Viatura] | [INTEGRITY_HASH: SHA256_Report]

## Rastreabilidade Restrita
* **[RF112]** - Módulo de gestão de turnos operacionais, fechamento de escalas e consolidação de atividades de campo.
* **[RNF202]** - Controle de acesso por papéis hierárquicos e delegações de comando (RBAC).
* **[RNF205]** - Rastreabilidade eletrônica com logs permanentes de encerramentos administrativos.