# UC007 - Bloquear ou desativar usuários

## Objetivo
Impedir o acesso lógico de usuários desligados, afastados ou com suspeita de uso indevido aos módulos operacionais e administrativos, sem realizar a exclusão física do histórico de dados para preservar a integridade referencial do sistema.

## Ator principal
Administrador do Sistema

## Pré-condições
- Usuário a ser bloqueado/desativado previamente existente e cadastrado na base de dados do SIG-GCM.
- Administrador do Sistema devidamente autenticado e com uma sessão ativa válida.

## Pós-condições
- Flag de status ou bloqueio atualizada com sucesso no banco de dados relacional.
- Sessões ativas do usuário afetado derrubadas imediatamente pelo mecanismo de autenticação.
- Registro detalhado da alteração gravado de forma síncrona nos logs de auditoria do sistema.

## Fluxo principal
1. O ator acessa o menu administrativo de gerenciamento de contas e aciona a funcionalidade Bloquear ou desativar usuários.
2. O sistema valida o perfil do ator, realiza uma consulta síncrona à base de dados para buscar o registro do usuário alvo e renderiza a tela de alteração de status preenchida com as informações vigentes (ID do Usuário, Nome Completo, Matrícula Funcional, Status Atual e Motivo da Alteração).
3. O ator altera o campo "Novo Status" para a opção de bloqueio desejada e seleciona o motivo da alteração de status.
4. O ator digita uma justificativa detalhada no campo textual obrigatório.
5. O ator clica na ação "Confirmar Alteração de Status".
6. O sistema intercepta a requisição, valida a integridade de todas as entradas, a validade do token do administrador e confere se a regra de salvaguarda de segurança (auto-bloqueio) foi respeitada.
7. O sistema persiste a alteração de status no banco de dados do SIG-GCM.
8. O sistema invalida imediatamente o token de autenticação ativo do usuário afetado no servidor, forçando o encerramento da sessão dele caso esteja logado.
9. O sistema gera e grava um log de auditoria completo sobre a transação crítica.
10. O sistema apresenta a mensagem de sucesso em formato de notificação na interface: "Status do usuário atualizado com sucesso!".

## Fluxos alternativos e exceções
- **A1 - Dados inválidos (Ausência de Justificativa Teatral):** 
- No momento da validação (Passo 6), o sistema identifica que o campo Justificativa Detalhada está em branco ou com caracteres insuficientes.
- O sistema aborta a operação de escrita no banco de dados, destaca o campo de texto com alerta visual vermelho e solicita preenchimento.
- MENSAGEM EXATA: "Erro na validação dos dados: O campo justificativa é obrigatório e deve conter no mínimo 15 caracteres."
- **A2 - Acesso não autorizado:** 
- No passo 2 ou 6, o sistema detecta que o token de sessão do administrador expirou ou que o ator perdeu as permissões do perfil de privilégio administrativo.
- O sistema bloqueia a requisição no back-end, nega o processamento da rota e redireciona para a tela de login.
- MENSAGEM EXATA: "Acesso Negado: Você não possui permissão para bloquear ou desativar usuários."
- **A3 - Regra de negócio violada (Auto-bloqueio do Administrador logado):** 
- No passo 6, o sistema detecta que o ID do Usuário alvo da desativação é exatamente idêntico ao ID do Administrador que está executando a ação.
- O sistema impede a conclusão da atualização para evitar a perda permanente de acesso administrativo do próprio operador logado.
- MENSAGEM EXATA: "Operação Cancelada: Não é permitido bloquear ou desativar o seu próprio usuário de forma autônoma."
## Dicionário de Dados da Tela
Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação/Regra de Negócio
ID do Usuário | Numérico (Long) | Sim | Identificador único e imutável do registro do usuário alvo. Não editável.
Nome Completo | Texto (até 100 caracteres) | Sim | Exibido em modo somente leitura para validação do ator.
Matrícula Funcional | Texto (até 20 caracteres) | Sim | Registro institucional do servidor da GCM. Exibido em modo somente leitura.
Novo Status | Alfanumérico (Dropdown) | Sim | Opções disponíveis para seleção: "Bloqueado Temporariamente" ou "Desativado Definitivamente".
Motivo da Alteração | Alfanumérico (Dropdown) | Sim | Opções vinculadas ao negócio: "Afastamento Médico", "Desligamento da Corporação", "Processo Administrativo", "Suspeita de Fraude".
Justificativa Detalhada | Texto (entre 15 e 500 caracteres) | Sim | Campo de texto livre. Deve conter a justificativa formal para auditoria jurídica posterior.

## Regras de negócio relacionadas
- RN001 / RN002: O sistema deve validar estritamente o nível de permissão do perfil que invoca a operação, assegurando que apenas perfis habilitados (Administrador) gerenciem o ciclo de vida de contas de usuários.
- RN005: Como a inativação ou bloqueio de uma conta afeta o acesso institucional e paralisa credenciais, a operação é demarcada como crítica, exigindo por padrão a criação imediata de rastro detalhado com justificativa textual obrigatória.

## Critérios de aceitação
- A interface e os endpoints da API devem negar a operação caso o perfil do ator logado seja inferior ao nível de Administrador do Sistema.
- Nenhuma conta de usuário pode ser apagada fisicamente (DELETE) da base de dados; a desativação deve ocorrer estritamente de maneira lógica alterando o status e registrando as justificativas fornecidas.
- Após a efetivação do bloqueio, qualquer tentativa de autenticação com as credenciais do usuário afetado deve ser imediatamente recusada, retornando uma mensagem indicando conta inativa.

## Logs de Auditoria (Operação Crítica)
{
  "timestamp": "2026-06-21T18:00:00Z",
  "actor_id": 1001,
  "action": "USER_STATUS_CHANGE",
  "target_user_id": 4580,
  "diff": {
    "status_anterior": "Ativo",
    "status_novo": "Desativado Definitivamente",
    "motivo_codigo": "Desligamento da Corporação"
  },
  "justificativa": "Servidor exonerado conforme Diário Oficial do Município número 1422, publicado em 19/06/2026.",
  "security": {
    "ip_address": "10.0.1.50",
    "session_token_invalidated_count": 1
  }
}

## Rastreabilidade Restrita
- RF: RF002, RF004, RF007.
- RN: RN001, RN002, RN005.
- RNF: RNF005, RNF006, RNF008, RNF024.
- CA: CA001, CA009.
