# UC008 - Cadastrar escalas

## Objetivo
Cadastrar escalas operacionais e alocação de plantões para os servidores da Guarda Civil Municipal, garantindo a cobertura dos postos de trabalho e a consistência das jornadas de trabalho.

## Ator principal
Supervisor Operacional

## Pré-condições
- Supervisor Operacional autenticado com sessão ativa no sistema.
- Servidores (Guardas) previamente cadastrados e ativos no banco de dados.

## Pós-condições
- Nova escala operacional gravada com sucesso no banco de dados relacional.
- Registro da operação adicionado à trilha de logs de auditoria do sistema.

## Fluxo principal
1. O ator acessa o menu de gerenciamento operacional e aciona a funcionalidade Cadastrar escalas.
2. O sistema valida o perfil do ator, realiza uma consulta síncrona às tabelas de servidores ativos e postos de serviço, e renderiza a tela com o formulário de cadastro de escalas.
3. O ator seleciona o Servidor (Guarda), a Data do Plantão, a Hora de Início, a Hora de Término, o Posto de Serviço e o Tipo de Escala.
4. O ator clica na ação "Salvar Escala".
5. O sistema intercepta a requisição e valida a obrigatoriedade de todos os campos selecionados, bem como a consistência dos horários (Início < Término).
6. O sistema executa as validações de regras de negócio, verificando se o servidor selecionado já possui um plantão ativo ou sobreposto na mesma data e horário.
7. O sistema persiste a escala na base de dados relacional do SIG-GCM.
8. O sistema gera e grava um log de auditoria detalhado sobre esta transação operacional crítica.
9. O sistema apresenta a mensagem de sucesso em formato de notificação na interface: "Escala operacional cadastrada com sucesso!".

## Fluxos alternativos e exceções
- **A1 - Dados inválidos (Inconsistência de Horários):** 
- No momento da validação (Passo 5), o sistema identifica que a hora de término é anterior ou igual à hora de início, ou que existem campos obrigatórios vazios.
- O sistema aborta a operação de gravação, realça os campos inconsistentes na interface visual e solicita a devida correção.
- MENSAGEM EXATA: "Erro na validação dos dados: Verifique o preenchimento dos campos obrigatórios e garanta que a hora de término seja posterior à hora de início."
- **A2 - Acesso não autorizado:** 
- oNo passo 2 ou 5, o sistema intercepta a requisição e detecta que o ator não possui o perfil de Supervisor Operacional (ou Administrador), ou que o seu token de sessão expirou.
- O sistema bloqueia a execução da operação no back-end e retorna o erro para a interface gráfica.
- MENSAGEM EXATA: "Acesso Negado: Você não possui permissão para cadastrar escalas operacionais."
- **A3 - Regra de negócio violada (Choque de Horários / Servidor Indisponível):** 
- No passo 6, o sistema executa a checagem na tabela de escalas e constata que o servidor selecionado já está alocado em outra escala operacional ativa no mesmo período ou que o usuário associado está com status de bloqueado/desativado.
- O sistema impede a persistência dos dados e exibe a justificativa impeditiva na tela.
- MENSAGEM EXATA: "Operação Cancelada: O servidor selecionado já possui uma escala ativa ou sobreposta cadastrada para este período."

## Dicionário de Dados da Tela
Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação/Regra de Negócio
Servidor (Guarda) | Numérico (Long / ID) | Sim | Deve mapear um ID de usuário ativo no sistema vinculado à corporação.
Data do Plantão | Data (AAAA-MM-DD) | Sim | Não pode ser inferior à data corrente do sistema.
Hora de Início | Hora (HH:MM) | Sim | Deve registrar o início da jornada do plantão.
Hora de Término | Hora (HH:MM) | Sim | Deve ser estritamente posterior à Hora de Início.
Posto de Serviço | Alfanumérico (Dropdown) | Sim | Deve mapear uma localidade de patrulhamento ou posto ativo cadastrado.
Tipo de Escala | Alfanumérico (Dropdown) | Sim | Opções: "Ordinária", "Extraordinária", "Plantão Especial", "Operação Integrada".

## Regras de negócio relacionadas
- RN001 / RN002: A operação é restrita ao perfil de Supervisor Operacional ou superior, impedindo o acesso ou modificação por membros da equipe operacional padrão sem atribuições.
- RN004 / RN008: O sistema deve impedir que um servidor seja alocado em jornadas sobrepostas ou conflitantes na mesma data e intervalo de tempo, garantindo a integridade do planejamento operacional da corporação.

## Critérios de aceitação
- A interface e as chamadas aos endpoints de criação de escala devem aplicar controle de acesso estrito baseado em perfil (Role-Based Access Control - RBAC).
- O sistema não deve permitir o agendamento de um servidor cujo status cadastral esteja marcado como inativo ou bloqueado.
- Mensagens claras e em conformidade com o padrão visual devem ser exibidas imediatamente após a validação ou rejeição dos dados inseridos.

## Logs de Auditoria (Operação Crítica)
{
  "timestamp": "2026-06-21T18:15:30Z",
  "actor_id": 2045,
  "actor_profile": "Supervisor Operacional",
  "action": "CREATE_OPERATIONAL_SCHEDULE",
  "target_data": {
    "servidor_id": 4502,
    "data_plantao": "2026-06-22",
    "horario": "07:00-19:00",
    "posto_servico_id": 12,
    "tipo_escala": "Ordinária"
  },
  "security": {
    "ip_address": "10.0.2.15",
    "protocol": "HTTPS"
  }
}

## Rastreabilidade Restrita
- RF: RF001, RF002, RF008.
- RN: RN001, RN002, RN004, RN008.
- RNF: RNF004, RNF005, RNF008, RNF012.
- CA: CA001, CA009.
