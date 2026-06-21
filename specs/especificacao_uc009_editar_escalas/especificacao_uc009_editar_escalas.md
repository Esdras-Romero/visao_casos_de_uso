# UC009 - Editar escalas

## Objetivo
Alterar dados de escalas operacionais e plantões previamente cadastrados, ajustando alocações de guardas municipais, postos ou horários, garantindo a revalidação contra conflitos de jornada.

## Ator principal
Supervisor Operacional

## Pré-condições
- Escala operacional previamente existente e ativa no banco de dados.
- Supervisor Operacional autenticado com sessão ativa no sistema.

## Pós-condições
- Registro de escala atualizado e revalidado com sucesso no banco de dados relacional.
- Trilha de auditoria gerada com o histórico de alterações (valores antigos e novos).

## Fluxo principal
1. O ator acessa a funcionalidade Editar escalas selecionando uma escala específica em um calendário ou listagem operacional.
2. O sistema valida o perfil do ator, realiza uma consulta síncrona à base de dados para buscar o registro da escala e renderiza a tela de edição preenchida com os dados atuais da escala (ID da Escala, Guarda Alocado, Data do Plantão, Hora de Início, Hora de Término, Posto de Serviço e Tipo de Escala).
3. O ator altera os dados desejados nos campos editáveis do formulário.
4. O ator clica na ação "Salvar Alterações".
5. O sistema intercepta a requisição e valida a obrigatoriedade de todos os campos, além da consistência cronológica dos horários.
6. O sistema executa as validações de regras de negócio de alocação, verificando se a nova configuração de horários ou a mudança de guarda gera sobreposição de plantões para o servidor.
7. O sistema persiste as alterações na base de dados relacional do SIG-GCM.
8. O sistema gera e grava um log de auditoria detalhado sobre esta transação operacional crítica.
9. O sistema apresenta a mensagem de sucesso em formato de notificação na interface: "Escala operacional atualizada e revalidada com sucesso!".

## Fluxos alternativos e exceções
- **A1 - Dados inválidos (Inconsistência de Horários):**
- No momento da validação (Passo 5), o sistema identifica que a hora de término informada é anterior ou igual à hora de início.
- O sistema aborta a operação de gravação, realça os campos de horários em vermelho na interface visual e solicita correção.
- MENSAGEM EXATA: "Erro na validação dos dados: A hora de término deve ser estritamente posterior à hora de início."
- **A2 - Acesso não autorizado:**
- No passo 2 ou 5, o sistema intercepta a requisição e detecta que o ator não possui o perfil de Supervisor Operacional (ou Administrador), ou que seu token de sessão expirou.
- O sistema bloqueia o processamento no back-end e retorna o erro para a camada de apresentação.
- MENSAGEM EXATA: "Acesso Negado: Você não possui permissão para editar escalas operacionais."
- **A3 - Regra de negócio violada(Choque de Horários / Servidor em Duplo Plantão):**

- No passo 6, o sistema executa a checagem de concorrência na tabela de escalas e constata que o guarda selecionado para alteração já está alocado em outra escala ativa ou sobreposta no mesmo dia e intervalo de tempo.
- O sistema impede a persistência dos dados e exibe a justificativa na tela.
- MENSAGEM EXATA: "Operação Cancelada: O guarda selecionado já possui uma escala ativa ou sobreposta cadastrada para este período."

## Dicionário de Dados da Tela
Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação/Regra de Negócio
ID da Escala | Numérico (Long) | Sim | Identificador único da escala no banco de dados. Exibido em modo somente leitura.
Guarda Alocado | Numérico (Long / ID) | Sim | Deve mapear um ID de usuário ativo no sistema vinculado à corporação. Permite alteração.
Data do Plantão | Data (AAAA-MM-DD) | Sim | Não pode ser inferior à data corrente do sistema para evitar alterações retroativas sem auditoria especial.
Hora de Início | Hora (HH:MM) | Sim | Define o horário inicial do plantão operacional.
Hora de Término | Hora (HH:MM) | Sim | Deve ser estritamente posterior à Hora de Início.
Posto de Serviço | Alfanumérico (Dropdown) | Sim | Deve mapear uma localidade de patrulhamento ou posto ativo cadastrado na base.
Tipo de Escala | Alfanumérico (Dropdown) | Sim | Opções: "Ordinária", "Extraordinária", "Plantão Especial", "Operação Integrada".

## Regras de negócio relacionadas
- RN001 / RN002: A operação é restrita ao perfil de Supervisor Operacional ou superior, garantindo o princípio do privilégio mínimo por setor da Guarda Civil Municipal.
- RN009: O sistema deve impedir que alterações de escalas gerem conflitos de horários ou alocações redundantes para o mesmo servidor no mesmo intervalo de tempo.

## Critérios de aceitação
- A interface e as chamadas de API de atualização de escala devem validar estritamente o controle de acesso baseado no perfil do Supervisor Operacional.
- Toda alteração em campos relevantes (guarda, posto ou horários) deve gerar um registro de histórico contendo o estado anterior e posterior dos dados modificados (diff).
- O sistema deve apresentar mensagens claras e estruturadas em caso de erro de validação ou de violação de regras de negócio.

## Logs de Auditoria (Operação Crítica)
{
  "timestamp": "2026-06-21T18:30:15Z",
  "actor_id": 2045,
  "actor_profile": "Supervisor Operacional",
  "action": "UPDATE_OPERATIONAL_SCHEDULE",
  "target_scale_id": 8912,
  "diff": {
    "guarda_id": { "antes": 4502, "depois": 4610 },
    "hora_inicio": { "antes": "07:00", "depois": "08:00" },
    "hora_termino": { "antes": "19:00", "depois": "20:00" }
  },
  "security": {
    "ip_address": "10.0.2.15",
    "protocol": "HTTPS"
  }
}

## Rastreabilidade Restrita
- RF: RF001, RF002, RF009.
- RN: RN001, RN002, RN009.
- RNF: RNF004, RNF005, RNF008, RNF012.
- CA: CA001, CA009.