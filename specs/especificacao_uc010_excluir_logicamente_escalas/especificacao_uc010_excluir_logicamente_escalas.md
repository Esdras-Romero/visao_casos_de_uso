# UC010 - Excluir logicamente escalas

## Objetivo
Inativar uma escala operacional previamente cadastrada alterando seu estado lógico no sistema, de modo a preservar o histórico de planejamento para fins de auditoria, estatística e prestação de contas, sem remover fisicamente os registros do banco de dados.

## Ator principal
Administrador Operacional

## Pré-condições
- Escala operacional alvo existente e em estado "Ativa" na base de dados do SIG-GCM.
- Administrador Operacional devidamente autenticado e com uma sessão ativa válida.

## Pós-condições
- O registro da escala tem o seu atributo de controle alterado para "Inativo" no banco de dados relacional.
- Trilha de auditoria gerada e gravada contendo as justificativas da exclusão lógica.

## Fluxo principal
1. O ator acessa a listagem ou o calendário de escalas operacionais e aciona a funcionalidade Excluir logicamente escalas para um registro específico.
2. O sistema valida o perfil do ator, realiza uma consulta síncrona à base de dados e renderiza uma janela modal de confirmação preenchida com os dados resumidos da escala (ID da Escala, Nome do Servidor Alocado, Data do Plantão, Horário do Plantão, Posto de Serviço e os campos para seleção do motivo).
3. O ator seleciona o Motivo da Inativação através de uma lista de opções predefinidas.
4. O ator digita a justificativa detalhada no campo de texto obrigatório.
5. O ator clica na ação "Confirmar Exclusão Lógica".
6. O sistema intercepta a requisição, valida o preenchimento dos dados obrigatórios, a validade do token de sessão do ator e se o plantão já foi iniciado ou concluído.
7. O sistema executa o comando de atualização mudando o estado do registro para inativo no banco de dados do SIG-GCM.
8.  O sistema gera e grava um log de auditoria detalhado sobre esta transação operacional crítica.
9. O sistema fecha a modal de confirmação e apresenta a mensagem de sucesso em formato de notificação na interface: "Escala operacional excluída logicamente com sucesso!".

## Fluxos alternativos e exceções
- **A1 - Dados inválidos (Ausência de Justificativa Teatral)**
- No momento da validação (Passo 6), o sistema identifica que o campo Justificativa Detalhada está vazio ou não atende ao tamanho mínimo exigido.
- O sistema aborta a transação de escrita, destaca o campo textual com alerta visual vermelho na interface e solicita a devida correção.
- MENSAGEM EXATA: "Erro na validação dos dados: O campo justificativa é obrigatório e deve conter no mínimo 15 caracteres."
- **A2 - Acesso não autorizado:** 
- No passo 2 ou 6, o sistema intercepta a requisição e detecta que o ator não possui o papel de Administrador Operacional ou que o seu token de sessão expirou.
- O sistema bloqueia a execução da operação no back-end e retorna a mensagem de erro para a interface.
- MENSAGEM EXATA: "Acesso Negado: Você não possui permissão para excluir logicamente escalas operacionais."
- **A3 - Regra de negócio violada (Tentativa de inativar escala antiga ou em andamento):**
- No passo 6, o sistema verifica a data e a hora do plantão e constata que a escala já foi iniciada, executada ou pertence ao passado cronológico.
- O sistema impede a modificação lógica para proteger o histórico retroativo e apresenta a justificativa impeditiva na tela.
- MENSAGEM EXATA: "Operação Cancelada: Não é permitido inativar ou excluir escalas cujo período de plantão já tenha sido iniciado ou concluído."

## Dicionário de Dados da Tela
Nome do Campo | Tipo de Dado | Obrigatoriedade |Validação/Regra de Negócio
ID da Escala | Numérico (Long) | Sim | Identificador único da escala no sistema. Exibido em modo somente leitura.
Servidor Alocado | Texto | Sim | Nome completo do guarda municipal escalado. Exibido em modo somente leitura.
Data e Horário | Texto | Sim | Período cronológico reservado para o plantão. Exibido em modo somente leitura.
Motivo da Inativação | Alfanumérico (Dropdown) | Sim | Opções: "Ajuste de Efetivo", "Cancelamento de Evento", "Permuta Deferida", "Erro de Lançamento".
Justificativa Detalhada | Texto (entre 15 e 500 caracteres) | Sim | Campo de texto livre. Deve conter a justificativa formal para fins de auditoria regula

## Regras de negócio relacionadas
- RN001 / RN002: A operação é restrita ao perfil de Administrador Operacional, garantindo o isolamento de funções conforme o setor institucional da Guarda Civil Municipal.
- RN005 / RN007: Operações que alteram o status de planejamento ativo para fins legais devem obrigar o registro de justificativas textuais e proibir a aplicação de comandos DELETE diretos na tabela física.

## Critérios de aceitação
- O sistema deve implementar controle de acesso baseado em regras (RBAC) impedindo usuários de perfis operacionais de invocar o endpoint de inativação.
- O registro inativado logicamente deve sumir das escalas ativas de trabalho diário, mas deve permanecer acessível em relatórios históricos e painéis de auditoria sob a flag indicativa de inatividade.
- O sistema deve emitir respostas visuais limpas e imediatas para cenários de sucesso ou falhas operacionais.

## Logs de Auditoria (Operação Crítica)
{
  "timestamp": "2026-06-21T18:45:00Z",
  "actor_id": 3012,
  "actor_profile": "Administrador Operacional",
  "action": "LOGICAL_DELETE_SCHEDULE",
  "target_scale_id": 9214,
  "payload": {
    "motivo_codigo": "Cancelamento de Evento",
    "justificativa": "Operação de apoio ao jogo de futebol cancelada pelo comando geral por questões climáticas.",
    "estado_anterior": { "is_active": true },
    "estado_novo": { "is_active": false }
  },
  "security": {
    "ip_address": "10.0.3.45",
    "protocol": "HTTPS"
  }
}

## Rastreabilidade Restrita
- RF: RF001, RF002, RF010.
- RN: RN001, RN002, RN005, RN007.
- RNF: RNF004, RNF005, RNF008, RNF024.
- CA: CA001, CA009.
