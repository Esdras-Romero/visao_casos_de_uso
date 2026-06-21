# UC006 - Atualizar usuários

## Objetivo
Atualizar dados cadastrais e funcionais dos usuários vinculados à corporação, mantendo as informações institucionais atualizadas.

## Ator principal
Administrador do Sistema

## Pré-condições
- Usuário existente na base de dados do SIG-GCM.
- Administrador do Sistema autenticado com sessão ativa.

## Pós-condições
- Dados cadastrais modificados com sucesso no banco de dados relacional.
- Registro detalhado da alteração gravado nos logs de auditoria do sistema.

## Fluxo principal
1. O ator acessa o menu administrativo e aciona a funcionalidade Atualizar usuários.
2. O sistema valida o perfil do ator , realiza uma consulta síncrona à base de dados  e renderiza a tela de edição preenchida com os dados atuais do usuário (ID, Nome, E-mail, Perfil, Setor e Status).  
3. O ator altera os campos desejados no formulário estruturado.
4. O ator clica na ação "Salvar Alterações".
5. O sistema intercepta a requisição e valida a obrigatoriedade dos dados, formato de e-mail corporativo e integridade das regras de jornada/vínculos ativos.
6. O sistema persiste as alterações na base de dados do SIG-GCM.
7. O sistema gera e grava um log de auditoria completo sobre a transação crítica.
8. O sistema apresenta a mensagem de sucesso em formato de notificação na interface: "Usuário atualizado com sucesso!".

## Fluxos alternativos e exceções
- **A1 - Dados inválidos (E-mail fora do padrão institucional):** 
- No momento da validação (Passo 5), o sistema identifica que o e-mail não segue o padrão corporativo aceito.
- O sistema aborta a operação de persistência, destaca o campo com alerta visual e solicita correção.
- MENSAGEM EXATA: "Erro na validação dos dados: O e-mail informado deve ser um e-mail institucional válido."
- **A2 - Acesso não autorizado:** 
- No passo 2 ou 5, o sistema detecta que o token de sessão expirou ou o ator perdeu o privilégio administrativo.
- O sistema bloqueia a requisição no back-end e nega o processamento.
- MENSAGEM EXATA: "Acesso Negado: Você não possui permissão para atualizar dados de usuários."
- **A3 - Regra de negócio violada (Inativação com escala ativa):** 
- No passo 5, o sistema detecta que o ator alterou o status do usuário para "Inativo", mas o servidor possui escalas de plantão ativas vinculadas no futuro.  
- O sistema impede a conclusão da atualização para evitar buracos operacionais nas escalas de serviço.
- MENSAGEM EXATA: "Operação Cancelada: Não é possível desativar um usuário com escalas operacionais ativas pendentes."

## Dicionário de Dados da Tela
Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação/Regra de Negócio
ID do usuário | Numérico (Long) | Sim | Identificador único e imutável do registro na base relacional.
Nome Completo | Texto (até 100 caracteres) | Sim | Aceita apenas caracteres alfabéticos. Não pode ser nulo ou vazio.  
E-mail Institucional | Texto (até 100 caracteres) | Sim | Deve conter estrutura de e-mail válida com domínio oficial (ex: @gcm.gov.br). Deve ser exclusivo no sistema.  
Perfil de Acesso | Alfanumérico (Dropdown) | Sim | Deve mapear estritamente um dos perfis homologados da corporação (Administrador, Comando, RH, etc.).
Setor Vinculado | Alfanumérico (Dropdown) | Sim | Vincula obrigatoriamente o servidor à sua unidade organizacional correta (DIROP, RH, etc.).
Status do Usuário | Booleano (Radio/Toggle) | Sim | Opções: Ativo ou Inativo. Mudar para Inativo bloqueia acessos futuros de forma imediata.  

## Regras de negócio relacionadas
- RN001 / RN004: O sistema impede cruzamento ilegal de jornadas ou acessos a recursos sem a devida atribuição de perfil institucional.  
- RN005: Qualquer modificação realizada nos campos cadastrais e de permissão deve disparar nativamente a geração de logs detalhados para garantir auditoria contínua.

## Critérios de aceitação
- A interface funcional e as requisições de API devem respeitar estritamente o controle de acesso baseado no perfil do Administrador.  
- Toda alteração bem-sucedida deve gerar um rastro contendo o estado anterior e posterior do registro modificado.
- O sistema deve emitir respostas visuais limpas e inequívocas para cenários de sucesso ou falhas cadastrais. 

## Logs de Auditoria (Operação Crítica)

{
  "timestamp": "2026-06-21T17:40:00Z",
  "actor_id": 1001,
  "action": "USER_UPDATE",
  "target_user_id": 4500,
  "diff": {
    "perfil_acesso": { "antes": "Equipe Operacional", "depois": "Supervisor de Plantão" },
    "status": { "antes": "Ativo", "depois": "Ativo" }
  },
  "security": { "ip": "10.0.1.50", "protocol": "HTTPS" }
}

## Rastreabilidade Restrita
- RF: RF002, RF006, RF007, RF022, RF025, RF026.
- RN: RN001, RN004, RN005.
- RNF: RNF005, RNF006, RNF008, RNF024.
- CA: CA001, CA004, CA009. 