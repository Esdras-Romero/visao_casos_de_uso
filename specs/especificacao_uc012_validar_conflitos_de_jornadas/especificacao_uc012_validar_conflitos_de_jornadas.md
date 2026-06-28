# UC012 - Validar conflitos de jornadas

## Objetivo
Detectar e impedir a sobreposição de escalas de serviço e a violação de restrições legais de jornada de trabalho (interstício mínimo, carga horária máxima semanal/mensal) dos Guardas Civis Municipais durante o planejamento ou alteração de escalas operacionais.

## Ator principal
Administrador Operacional

## Pré-condições
1. O ator deve estar autenticado no SIG-GCM com perfil de acesso "Administrador Operacional" ou superior.
2. Deve haver uma escala ou folha de plantão em estado de "Criação" ou "Alteração".
3. Os Guardas Civis Municipais (GCMs) a serem validados devem estar devidamente cadastrados e ativos no sistema.
## Pós-condições
1. Os conflitos de jornadas são identificados, gerando relatórios de inconsistência.
2. O sistema bloqueia a gravação ou publicação da escala caso haja sobreposição ou ilegalidade, garantindo o cumprimento do regime estatutário/trabalhista.
3. Logs de auditoria são gerados para fins de responsabilização administrativa.

## Dicionário de Dados da Tela/Ação
- Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra
- id_escala | inteiro(UUID) | SIM | Deve ser um identificador de escala válido no status "Rascunho" ou "Revisão".
- id_gcm | Inteiro(UUID) | Sim | Deve corresponder a um GCM ativo no sistema.
- data_inicio_jornada | DateTime (YYYY-MM-DD HH:mm:ss) | Sim | Deve ser maior ou igual à data atual. Não pode ser superior a 90 dias no futuro.
- data_fim_jornada | DateTime (YYYY-MM-DD HH:mm:ss) | Sim | Deve ser estritamente maior que data_inicio_jornada.
- tipo_escala | Enum (Texto) | Sim | Valores aceitos: PLANTÃO_12X36, PLANTÃO_24X72, DIÁRIA_8H, OP_ESPECIAL.

## Fluxo principal
1. O Administrador Operacional solicita a validação ou tenta salvar/publicar uma escala contendo alocações de jornadas para um ou mais GCMs.
2. O sistema intercepta a requisição e renderiza a tela/modal de processamento de regras de conformidade de jornada.
3. O sistema varre as tabelas de banco de dados buscando a escala atual em processamento e as escalas já publicadas de outras unidades/divisões para o período selecionado.
4. O sistema executa as seguintes validações matemáticas e temporais em lote:
 - Validação 1: Ausência de sobreposição cronológica de horários para o mesmo id_gcm.
 - Validação 2: Respeito ao interstício mínimo de 11 horas consecutivas de descanso entre o término de uma jornada e o início de outra (conforme regime estatutário do município).
 - Validação 3: Limite de carga horária máxima mensal permitida para o regime de trabalho do GCM.
5. Sendo todas as validações bem-sucedidas, o sistema executa a gravação da escala no banco de dados com o status "Validada".
6. O sistema dispara a gravação automática do Log de Auditoria em formato imutável.
7. O sistema exibe na tela a mensagem de sucesso: "MSG-001: Validação de jornada concluída com sucesso. Nenhuma inconsistência encontrada."

## Fluxos alternativos e exceções
- **A1 - Dados inválidos (Inconsistência de Datas)**
  - Condição: O ator insere uma data de fim de jornada anterior à data de início.
  - 1. O sistema interrompe o processamento.
  - 1. O sistema realça os campos em vermelho e exibe a mensagem de erro: "MSG-E01: Data final da jornada não pode ser anterior ou igual à data inicial de início."
- **A2 - Acesso não autorizado:**
  - Condição: Usuário autenticado tenta disparar a validação através de chamada de API direta sem possuir o perfil "Administrador Operacional".
  - 1. O gateway de segurança do sistema bloqueia a requisição.
  - 1. O sistema redireciona para a tela de erro de permissão ou retorna HTTP 403, exibindo a mensagem: "MSG-E02: Acesso negado. Seu perfil de usuário não possui privilégios para executar a validação de conflitos de jornadas."
- **A3 - Regra de negócio violada:Sobreposição de Escala** 
  - Condição: O GCM selecionado já está escalado em outra viatura ou posto no mesmo intervalo de tempo.
  - 1. O sistema bloqueia a gravação dos dados.
  - 1. O sistema exibe um modal em tela com a listagem dos conflitos identificados, destacando a mensagem: "MSG-E03: Violação de Regra Operacional. O GCM [Nome do GCM] já possui uma jornada ativa no período [HH:MM às HH:MM] na Unidade [Nome da Unidade]."
- **A4 - Regra de Negócio Violada: Desrespeito ao Interstício Mínimo** 
  - Condição: O intervalo entre o fim da jornada anterior planejada e o início da nova jornada é inferior a 11 horas.
  - 1. O sistema impede a conclusão da escala.
  - 1. O sistema exibe em tela a mensagem: "MSG-E04: Alerta Legal. O GCM [Nome do GCM] não cumpre o interstício mínimo obrigatório de 11 horas de descanso. Intervalo calculado: [X] horas."

## Regras de negócio relacionadas
- RN001 - Exclusividade de Alocação: Um GCM não pode ser escalado para mais de um posto, viatura ou evento de forma síncrona ou com sobreposição de minutos.
- RN002 - Interstício Legal: Obrigatoriedade de intervalo de descanso de, no mínimo, 11 horas consecutivas entre escalas consecutivas.
- RN003 - Teto de Carga Horária Extraordinária: Bloqueio de alocação de GCMs que atingiram o limite de horas mensais permitidas por lei municipal para regimes de plantão extraordinário/RPE.

## Critérios de aceitação
- CA01: O sistema deve impedir, em nível de banco de dados (restrição lógica/transacional), que qualquer escala com conflito impeditivo seja salva com o status "Publicada".
- CA02: A validação em lote de uma escala contendo até 200 GCMs não deve exceder o tempo de resposta de 2 segundos (requisito de performance).
- CA03: Erros de violação de regra jurídica/estatutária devem ser exibidos de forma clara, identificando explicitamente a matrícula e o nome do GCM envolvido.

## Logs de auditoria
Caso a operação seja realizada com sucesso ou bloqueada por quebra de regra crítica, o sistema deve registrar obrigatoriamente no banco de auditoria (tbl_log_auditoria):
- Timestamp da operação (Data, hora, minuto, segundo).
- ID_Usuario do Administrador Operacional que disparou a ação.
- IP_Origem e User-Agent.
- Payload da validação (Lista de IDs de GCMs avaliados).
- Resultado_Acao: [SUCESSO], [BLOQUEIO_SOBREPOSICAO] ou [BLOQUEIO_INTERSTICIO].

## Rastreabilidade Restrita
- RF012: Requisito Funcional de Gestão e Validação Automatizada de Escalas Operacionais.
- RN001, RN002, RN003: Regras de Negócio de Escalonamento e Proteção Jurídico-Trabalhista do Servidor.
- RNF008: Requisito Não-Funcional de Segurança e Auditoria de Ações Administrativas.
- CA01, CA02: Critérios de Aceitação de Performance e Integridade de Dados do Módulo Operacional.
