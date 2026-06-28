# UC015 - Aprovar ou reprovar permuta

## Objetivo
Permitir que o Supervisor Operacional avalie as solicitações de permutas de plantão submetidas pelos servidores funcionais, autorizando ou indeferindo o pedido com base na conveniência do serviço e na conformidade com as regras operacionais da corporação.

## Ator principal
Supervisor Operacional

## Pré-condições
- O usuário deve estar autenticado no SIG-GCM sob o perfil de "Supervisor Operacional".  
- Deve existir pelo menos uma solicitação de permuta cadastrada previamente no banco de dados com o status igual a "PENDENTE_APROVACAO".

## Pós-condições
- O status da permuta é atualizado na tabela tbl_permutas para "APROVADO" ou "REPROVADO".
- Se aprovada, o sistema atualiza as alocações das respectivas escalas operacionais envolvidas, trocando as matrículas dos GCMs de forma automática.
- Se reprovada, os plantões permanecem inalterados com seus donos originais.
- Notificações automáticas de alteração de escala são disparadas aos servidores envolvidos.

## Dicionário de Dados da Tela/Ação
Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra
- id_permuta | Inteiro (UUID) | Sim | Deve corresponder a um identificador de permuta existente cujo status atual seja "PENDENTE_APROVACAO".
- acao_decisao | Enum (Texto) | Sim | Valores fixos aceitos no payload: APROVAR ou REPROVAR.
- justificativa_analis | Texto (Alfanumérico) | Sim (Apenas se acao_decisao = REPROVAR) | Obrigatório em caso de reprovação para motivar o ato administrativo (Máx. 500 caracteres). Não pode ser nulo ou vazio neste cenário.

## Fluxo principal
1. O Supervisor Operacional acessa a funcionalidade Aprovar ou reprovar permuta através do painel de pendências administrativas.
2. O sistema executa uma consulta à tabela tbl_permutas, filtrando registros com status "PENDENTE_APROVACAO", e renderiza em tela a listagem detalhada contendo: GCM Solicitante, GCM Substituto, Escala Origem, Escala Destino e Justificativa da Troca.
3. O Supervisor Operacional seleciona uma permuta específica (id_permuta) e escolhe a opção desejada clicando no botão "Aprovar" ou "Reprovar".
4. O sistema intercepta o comando e valida se as credenciais ativas do usuário pertencem ao perfil de "Supervisor Operacional".
5. O sistema valida se os dados obrigatórios foram preenchidos (incluindo a consistência da justificativa caso tenha sido uma reprovação).
6. O sistema executa a transação no banco de dados, atualizando o status do registro e modificando os titulares na tabela tbl_escalas caso a decisão tenha sido favorável.
7. O sistema grava de maneira síncrona o log de auditoria na base de dados imutável devido à criticidade da alteração.
8. O sistema apresenta a mensagem de sucesso na interface do ator: "MSG-001: Avaliação de permuta processada com sucesso. Os servidores envolvidos foram notificados."

## Fluxos alternativos e exceções
- **A1 - Dados inválidos: (Ausência de justificativa no indeferimento)**
- Condição: O Supervisor Operacional seleciona a ação REPROVAR mas envia o campo justificativa_analise em branco.
 1. O sistema aborta o processo de gravação e mantém o registro original intocado.
 1. O sistema realça o campo de texto em vermelho na interface e exibe a mensagem exata de erro: "MSG-E01: Operação inválida. É obrigatório registrar uma justificativa formal ao reprovar uma solicitação de permuta."

- **A2 - Acesso não autorizado:**
- Condição: Um usuário autenticado sob o perfil de "Equipe Operacional" ou "Setor de Transporte" tenta submeter a aprovação chamando diretamente o endpoint da API. 
 1. O barramento de segurança/middleware intercepta a chamada de rede.
 1. O sistema bloqueia a execução, gera um alerta de segurança e retorna para a tela a mensagem exata: "MSG-E02: Acesso negado. Seu perfil de usuário não possui as permissões necessárias para homologar ou rejeitar permutas."

- **A3 - Regra de negócio violada: (Permuta já processada)**
- Condição: Dois supervisores abrem a mesma tela concorrentemente, e o segundo tenta salvar uma decisão sobre uma permuta que já foi aprovada/reprovada pelo primeiro.
 1. O sistema executa um optimistic lock ou validação pré-gravação e detecta que o status da permuta no banco já não é mais "PENDENTE_APROVACAO".
 1. O sistema impede a sobreescrita dos dados e apresenta a mensagem de erro explicativa: "MSG-E03: Erro de Consistência. Esta solicitação de permuta já foi processada anteriormente por outro supervisor e não pode ser modificada."

## Regras de negócio relacionadas
- RN001 - Inexistência de Conflito Concorrente: Nenhuma alteração decorrente da aprovação da permuta poderá gerar choque de horários ou duplicidade para os servidores afetados.  
- RN002 - Obrigatoriedade de Homologação Administrativa: As permutas planejadas entre as equipes dependem estritamente da aprovação eletrônica do supervisor para passar a valer na escala publicada.  
- RN004 - Restrição de Funcionalidade por Perfil: Apenas perfis de gestão/supervisão operacional possuem permissão de escrita e modificação neste módulo.  
- RN005 - Rastreabilidade de Operações de Escala: Qualquer modificação que mude a titularidade de um plantão publicado deve gerar log histórico e auditoria imutável. 

## Critérios de aceitação
- CA001: O sistema deve validar e garantir que usuários autenticados acessem apenas as funcionalidades compatíveis com suas atribuições delegadas (Aprovação restrita ao Supervisor Operacional).  
- CA002: O sistema não deve permitir conflitos ou sobreposições de escalas após a efetivação da permuta.  
- CA003: Toda alteração de titularidade em permutas deve depender da aprovação explícita e registrada na administração.  
- CA009: O sistema deve registrar logs das operações críticas para permitir auditorias completas.

## Logs de auditoria
Sendo esta uma operação crítica de alteração das equipes de serviço em campo, o sistema grava na tabela tbl_log_auditoria:  
- timestamp: Data, hora, minuto e segundo do processamento do voto.id_usuario_auditor: Identificador único (UUID) do Supervisor Operacional responsável.
- ip_origem: Endereço IP do terminal de rede que realizou a operação.
- id_entidade_afetada: O UUID contido no parâmetro id_permuta.
- payload_modificacao: Estrutura JSON gravando o estado final da ação, por exemplo: {"acao": "REPROVAR", "justificativa": "Efetivo reduzido no dia devido a licenças médicas"} ou {"acao": "APROVAR", "escalas_modificadas": ["UUID-1", "UUID-2"]}.

## Rastreabilidade Restrita
- RF015: Aprovar ou reprovar solicitações de permuta.  
- RF016: Manutenção do histórico completo das permutas realizadas para fins de auditoria.  
- RF025, RF026: Registro de operações críticas em logs e rastreamento de alterações.  
- RN001, RN002, RN004, RN005: Regras de negócio de conflito, aprovação, controle de acesso e logs.  
- RNF005, RNF008: Requisitos não funcionais de controle de acesso por perfil e auditoria operacional.  
- CA001, CA002, CA003, CA009: Critérios de aceitação funcionais e de segurança do sistema.
