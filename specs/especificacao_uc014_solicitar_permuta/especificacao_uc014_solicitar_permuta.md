# UC014 - Solicitar permuta

## Objetivo
Permitir que um Servidor Operacional formalize um pedido de troca de plantão com outro servidor (GCM substituto) , registrando as escalas de origem e destino para que a solicitação seja encaminhada para análise e aprovação administrativa superior.

## Ator principal
Servidor Operacional

## Pré-condições
1. O Servidor Operacional (solicitante) deve estar autenticado no sistema SIG-GCM.  
2. O servidor solicitante deve estar previamente escalado em um plantão ativo e publicado no sistema.  
3. O servidor substituto deve estar cadastrado e ativo na corporação.

## Pós-condições
1. A solicitação de permuta é registrada no banco de dados com o status provisório de "Pendente de Aprovação".  
2. Uma notificação interna é enviada automaticamente para o Supervisor Operacional responsável pela avaliação.

## Dicionário de Dados da Tela/Ação
- Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra
- id_escala_origem | Inteiro (UUID) | Sim | Deve corresponder a uma escala válida e ativa associada diretamente à matrícula do servidor solicitante.  
- id_servidor_substituto | Inteiro (UUID) | Sim | Deve corresponder a um GCM ativo no sistema que não seja o próprio solicitante.  
- id_escala_destino | Inteiro (UUID) | Sim | Deve ser uma escala atribuída ao servidor substituto ou um turno em que ele esteja disponível para cobrir.
- justificativa | Texto (Máx. 250 caracteres) | Sim | Campo de texto livre detalhando o motivo da troca. Não pode conter apenas caracteres especiais.

## Fluxo principal
1. O Servidor Operacional acessa a funcionalidade Solicitar permuta no menu do sistema.  
2. O sistema recupera e renderiza a tela exibindo os plantões futuros em que o solicitante está alocado, junto a um seletor para escolha do servidor substituto e o campo de justificativa.
3. O Servidor Operacional seleciona o seu plantão de origem (id_escala_origem), escolhe o GCM substituto (id_servidor_substituto), a escala de destino (id_escala_destino) e insere a justificativa.
4. O Administrador do sistema/Módulo de Controle valida o perfil de acesso do ator (Servidor Operacional).  
5. O sistema realiza as validações de dados obrigatórios e dispara o motor de consistência de escalas do banco de dados.  
6. O sistema insere um registro na tabela tbl_permutas com o status "PENDENTE_APROVACAO".
7. O sistema gera uma entrada na tabela de log de auditoria devido à relevância operacional e alteração de histórico.  
8. O sistema apresenta a mensagem de sucesso na tela: "MSG-001: Solicitação de permuta registrada com sucesso e encaminhada para aprovação administrativa."

## Fluxos alternativos e exceções
- **A1 - Dados inválidos: (Campos vazios ou incorretos)**
- Condição: O ator deixa o campo justificativa em branco ou tenta submeter sem selecionar um GCM substituto.
 - 1. O sistema impede o envio da requisição.
 - 1. O sistema realça os campos inconsistentes em vermelho e apresenta a mensagem de erro na tela: "MSG-E01: Dados inválidos. Certifique-se de preencher todos os campos obrigatórios e informar uma justificativa válida."

- **A2 - Acesso não autorizado:** 
- Condição: Um usuário sem o perfil de "Servidor Operacional" tenta acessar diretamente o endpoint da API de criação de permutas.
 - 1. O barramento de segurança intercepta a chamada de sistema.
 - 1. O processamento é interrompido e o sistema exibe a mensagem de erro: "MSG-E02: Acesso não autorizado. Seu perfil funcional não possui permissões para solicitar permutas."

- **A3 - Regra de negócio violada: Conflito de Escala Gerado**
 - Condição: A permuta solicitada criaria uma sobreposição ou conflito direto na agenda de trabalho de qualquer um dos servidores envolvidos.
 - 1. O motor de validação detecta o choque cronológico de horários.  
 - 1. O sistema bloqueia a criação da solicitação e apresenta a justificativa na tela: "MSG-E03: Violação de Regra de Negócio. Esta operação não pôde ser concluída porque geraria um conflito ou sobreposição de escalas para os servidores envolvidos."

## Regras de negócio relacionadas
- RN001: Nenhum servidor poderá possuir escalas conflitantes. (A solicitação de permuta pré-analisa as grades futuras para evitar geração de choques de horário síncronos) .  
- RN002: Permutas dependerão de aprovação administrativa. (O registro deve nascer obrigatoriamente travado em status de aprovação) .  
- RN004: Usuários somente poderão acessar funcionalidades autorizadas.  
- RN005: Alterações relevantes deverão gerar logs

## Critérios de aceitação
- CA001: Usuários autenticados devem acessar apenas funcionalidades autorizadas.  
- CA002: O sistema não deve permitir conflitos de escalas.  
- CA003: Permutas devem depender de aprovação administrativa.  
- CA009: O sistema deve registrar logs das operações críticas.

## Logs de auditoria
Toda criação de permuta constitui alteração em registros de escala e rastreabilidade funcional. O sistema grava os seguintes dados exatos em tbl_log_auditoria:  
- Data_Hora: Timestamp do servidor no momento do envio da solicitação.  
- ID_Usuario_Solicitante: Identificador único (UUID) do GCM autenticado.  
- IP_Origem e User_Agent do navegador do usuário.
- Payload_JSON: Conteúdo completo gravado contendo os campos (id_escala_origem, id_servidor_substituto, id_escala_destino).
- Status_Acao: "SOLICITACAO_PERMUTA_REGISTRADA".

## Rastreabilidade RestritaRF014: Solicitar permutas de plantão para possibilitar ajustes pessoais e operacionais.  
- RF016: Manutenção do histórico completo das permutas realizadas para fins de auditoria.  
- RN001, RN002, RN004, RN005: Restrições operacionais de conflito de escala, aprovação de permuta, controle de acesso e auditoria.  
- RNF005, RNF008: Controle de acesso por perfil e auditoria operacional.  
- CA001, CA002, CA003, CA009: Critérios de verificação para controle de acesso, integridade de escalas, aprovações e logs. 
