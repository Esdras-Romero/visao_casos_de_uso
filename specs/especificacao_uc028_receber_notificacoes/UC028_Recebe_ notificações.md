# UC028 - Receber notificações

## Objetivo
Centralizar, exibir e gerenciar a entrega de avisos operacionais, alertas de quebra de escala, convocações de plantão e comunicações administrativas emitidas pelo ecossistema SIG-GCM para os servidores e guardas municipais.

## Ator Principal
Usuário do Sistema

## Pré-condições
- Usuário devidamente autenticado em qualquer nível de acesso na plataforma corporativa ou aplicativo mobile.
- Evento do sistema (ex: alteração de escala, alerta de conformidade, memorando interno) disparado e pendente de leitura.

## Pós-condições
- Notificação apresentada em tela, contabilizada no marcador de lidas/não lidas e atualizada no banco de dados com a confirmação de recebimento do dispositivo.

## Dicionário de Dados da Tela/Ação

| Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra |
| :--- | :--- | :--- | :--- |
| **ID_Notificacao** | Inteiro | Sim | Identificador único da mensagem no banco de dados. |
| **Filtro_Categoria** | Enumerado | Não | Filtro de exibição. Valores: `URGENTE`, `ADMINISTRATIVO`, `ESCALAS`, `ALERTAS_SISTEMA`. Se nulo, traz todas. |
| **Acao_Leitura** | Enumerado | Sim | Operação realizada pelo usuário. Valores: `MARCAR_COMO_LIDA`, `ARQUIVAR`, `EXCLUIR`. |

## Fluxo principal
1. O Usuário do Sistema realiza a autenticação padrão na plataforma web ou dispositivo móvel do SIG-GCM.
2. O sistema verifica em segundo plano a existência de mensagens pendentes na tabela de distribuição (`tb_user_notification`).
3. O sistema renderiza o componente visual de "Sino de Alertas" na barra superior da interface com o contador de mensagens não lidas.
4. O ator acessa a central de mensageria selecionando a funcionalidade **Receber notificações**.
5. O sistema apresenta a lista cronológica de avisos dinamicamente na tela, permitindo o uso do `Filtro_Categoria`.
6. O ator seleciona uma notificação específica para leitura e aciona o comando implícito ou explícito de `Acao_Leitura` (Marcar como lida).
7. O sistema intercepta o identificador `ID_Notificacao` e valida as permissões de escopo para garantir que a mensagem pertence àquele ID de usuário.
8. O sistema altera o status da mensagem de `PENDENTE` para `LIDA` e registra o exato timestamp (2026) da ação de recebimento.
9. O sistema atualiza o contador do painel em tempo real, decrementando os avisos pendentes sem recarregar a página global.
10. O sistema exibe um micro-feedback visual na interface (ícone de check ou esmaecimento da linha) indicando o sucesso da operação de leitura.

## Fluxo alternativos e exceções

### A1 - Dados inválidos
* **7a. ID de Notificação Inexistente ou Corrompido:** Se o token de requisição enviar um `ID_Notificacao` inválido ou estruturalmente danificado na URL da API, o sistema bloqueia o processamento em lote e apresenta em tela a mensagem de erro: `"Erro de Parâmetro: A notificação solicitada não foi localizada ou possui um formato inválido."`

### A2 - Acesso não autorizado
* **7b. Violação de Privacidade de Mensagem (Hijacking):** Se o usuário tentar ler ou atualizar o status de um `ID_Notificacao` destinado a outra matrícula ou CPF de guarda, o sistema bloqueia sumariamente a alteração, gera um log de incidente de segurança e apresenta na tela a mensagem de erro: `"Acesso Negado: Você não possui autorização para ler ou alterar o status desta mensagem de terceiros."`

### A3 - Regra de negócio violada
* **8a. Tentativa de Exclusão de Mensagem de Convocação Crítica:** Se o ator tentar acionar a ação `EXCLUIR` ou `ARQUIVAR` em uma notificação com nível de severidade máxima (ex: Convocação de Emergência de Plantão do Comando), o sistema impede a destruição do registro e apresenta a justificativa: `"Operação Recusada: Avisos de convocação urgente e ordens de serviço do comando não podem ser excluídos pelo operador. Leitura obrigatória."`

## Regras de negócio relacionadas
* **RN008 (Ciclo de Vida da Notificação):** Mensagens administrativas comuns expiram e são arquivadas automaticamente pelo sistema após 30 dias de sua publicação, caso não tenham sido marcadas manualmente.
* **RN009 (Evidência Eletrônica de Ciência):** O registro do status `LIDA` em convocações críticas serve como comprovante jurídico e administrativo de que o servidor tomou ciência oficial da escala gerada.

## Critérios de aceitação
* O painel deve suportar atualização assíncrona (via WebSockets ou Long Polling) para que alertas críticos cheguem instantaneamente à tela do guarda sem necessidade de clique em "atualizar".
* Mensagens categorizadas como `URGENTE` devem se sobrepor na interface em formato de janela modal pop-up imperativa.
* Nenhuma ação realizada na interface de notificações pode acarretar em perda de logs do banco de dados mestre.

## Logs de auditoria
Sendo um evento recorrente de interface, o sistema restringe a gravação de logs persistentes de auditoria estrita apenas para as alterações de status de mensagens urgentes ou convocações legais na tabela `tb_audit_notifications_read`:

[TIMESTAMP_UTC] | [USER_ID: ID_Usuario] | [ROLE: Perfil_Usuario] | [NOTIFICATION_ID: ID_Notificacao]
[CATEGORY: URGENTE/CONVOCACAO] | [ACTION_PERFORMED: Acao_Leitura] | [CONFIRMATION_HASH: SHA256]

## Rastreabilidade Restrita
* **[RF708]** - Módulo centralizador de mensageria, transmissão push e entrega de comunicados internos.
* **[RNF202]** - Controle de acesso por identificação inequívoca de conta (RBAC).
* **[RNF205]** - Rastreabilidade eletrônica de leitura de comunicados oficiais e ordens de serviço.