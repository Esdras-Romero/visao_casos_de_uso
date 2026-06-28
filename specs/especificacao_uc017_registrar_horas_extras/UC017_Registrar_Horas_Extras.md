# UC017 - Registrar Horas Extras (Refinado)
## ARTEFATO 1: Detalhamento Técnico e Dicionário de Dados

### Dicionário de Dados da Tela/Ação: Registrar Horas Extras
Esta tabela define as restrições de persistência e validação no SIG-GCM, associando os servidores ativos do efetivo ao plantão correspondente.

| Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação / Regra |
| :--- | :--- | :--- | :--- |
| **ID_Plantao** | Inteiro | Sim | Deve corresponder a um Plantão registrado e ativo no sistema. |
| **Matricula_Servidor** | Alfanumérico (10) | Sim | Deve pertencer a um guarda integrante do Efetivo ativo. O RH não pode ter registrado férias, afastamentos, licenças ou readaptações para este servidor no período (`[RF602]`). |
| **Data_Execucao** | Data (AAAA-MM-DD) | Sim | Não pode ser futura. Deve coincidir com a data em que o plantão ocorreu. |
| **Hora_Inicio** | Hora (HH:MM) | Sim | Deve ser estritamente menor que a `Hora_Fim`. |
| **Hora_Fim** | Hora (HH:MM) | Sim | Deve ser estritamente maior que a `Hora_Inicio`. |
| **Justificativa_Operacional** | Texto (Até 500 carac.) | Sim | Campo textual obrigatório detalhando a necessidade do serviço extraordinário além da escala base (`[RF501]`). |

### Fluxo Principal Detalhado
1. O **Supervisor de Plantão** se autentica no sistema (`[RF101]`) e, a partir de seu perfil de acesso parametrizado (`[RF102]`, `[RNF202]`), acessa o módulo "Gestão de Horas Extras" e clica em "Registrar Horas Extras" (`[RF501]`).
2. O sistema valida as permissões do usuário logado e renderiza a interface gráfica padronizada do formulário (`[RNF301]`).
3. O **Supervisor de Plantão** seleciona o código do Plantão de referência e informa a Matrícula do servidor que realizou a atividade extraordinária.
4. O sistema realiza uma busca interna no cadastro do RH (`[RF601]`) e retorna o nome do servidor, confirmando na interface que se trata de um guarda do Efetivo ativo.
5. O **Supervisor de Plantão** insere a Data de Execução, o horário de Início, o horário de Fim e preenche a Justificativa Operacional da extensão do serviço.
6. O **Supervisor de Plantão** aciona a ação "Salvar".
7. O sistema intercepta a requisição e valida as regras de integridade: confere o preenchimento de campos obrigatórios, analisa se há choque de horários com escalas existentes do servidor (`[RF306]`) e se há impedimentos funcionais ativos no RH (`[RF602]`).
8. O sistema grava os dados na base em caráter temporário com o status `"Pendente de Validação Administrativa"` (`[RF502]`).
9. O sistema dispara de forma transparente a gravação de logs imutáveis de auditoria operacional da transação (`[RF703]`, `[RNF205]`).
10. A interface limpa o formulário e exibe uma notificação visual de sucesso para o usuário.

### Fluxos Alternativos e de Exceção

#### A1 - Dados inválidos
* **7a. Campos obrigatórios em branco:** Se houver campos vazios, o sistema bloqueia a operação, realça as bordas e exibe: `"Erro de validação: O campo [Nome do Campo] é obrigatório e precisa ser preenchido."`
* **7b. Inconsistência de Horários:** Se a `Hora_Inicio` for maior ou igual à `Hora_Fim`, o sistema impede o salvamento e exibe: `"Erro na jornada: A hora de início do serviço extraordinário não pode ser igual ou posterior à hora de término."`

#### A2 - Acesso não autorizado
* **2a. Bloqueio por perfil de acesso:** Caso um integrante da Equipe Operacional tente forçar a rota de gravação, o sistema impede a renderização e exibe em um modal de segurança: `"Acesso Negado: Seu perfil de usuário não possui permissões de escrita para registrar horas extraordinárias no SIG-GCM."` (`[RNF202]`).

#### A3 - Regra de negócio violada
* **7c. Impedimento Funcional (Férias/Licenças):** Se o servidor consultado possuir registro ativo de licença ou afastamento no período (`[RF602]`), o sistema aborta a gravação e exibe: `"Operação Recusada: O servidor selecionado encontra-se em regime de afastamento/licença na data especificada."`
* **7d. Conflito de Jornadas Automático:** Se o horário extraordinário colidir com uma escala operacional regular já mapeada para o guarda (`[RF306]`), o sistema bloqueia a inserção e exibe: `"Conflito de Escala: O servidor já possui uma jornada ou hora extra registrada no intervalo de horas informado."`

### Rastreabilidade Restrita
* **[RF501]** - Registro de horas extras por parte do Supervisor de Plantão.
* **[RF502]** - Preparação do estado do registro para futura validação administrativa da Diretoria Operacional.
* **[RF306]** - Bloqueio automático de conflitos de horários e jornadas sobrepostas.
* **[RF602]** - Verificação de impedimentos funcionais gerenciados pelo RH (Férias e Licenças).
* **[RF703] / [RF704]** - Registro de logs operacionais e rastreamento completo de alterações de dados críticos.
* **[RNF202]** - Controle de acesso estrito baseado em perfis (RBAC).
* **[RNF205]** - Mecanismo automatizado de auditoria com gravação de logs imutáveis.
* **[RNF701]** - Tempo de resposta transacional limite de até 5 segundos.

### Logs de Auditoria
Em conformidade com as diretrizes de segurança e a LGPD (`[RNF203]`, `[RNF205]`), as alterações financeiras e laborais disparadas por esta rotina gravam entradas imutáveis na tabela de logs (`tb_log_operacional`) contendo:

```
[TIMESTAMP_UTC] | [ID_USUARIO: ID do Supervisor] | [PERFIL: Supervisor de Plantão] | [ACAO: INSERCAO_HORA_EXTRA]
[DETALHES: Matrícula Afetada: X, ID_Plantao: Y, Periodo: Data - Início/Fim, Status: Pendente_Validacao] | [INTEGRIDADE: HASH_SHA256]
```