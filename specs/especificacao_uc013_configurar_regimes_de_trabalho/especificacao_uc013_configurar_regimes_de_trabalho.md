# UC013 - Configurar regimes de trabalho

## Objetivo
Permitir que o Administrador Operacional cadastre e parametrize diferentes modelos de jornadas e regimes de trabalho da corporação (como os regimes padrões 12x60, 24x120 ou escalas personalizadas), estabelecendo os limites de horas de serviço e o tempo mínimo de descanso regulamentar.

## Ator principal
Administrador Operacional

## Pré-condições
1. O Administrador Operacional deve estar autenticado no sistema.  
2. O usuário deve possuir um perfil ativo com permissão explícita para parametrização de regras operacionais

## Pós-condições
1. O novo regime de trabalho é persistido no banco de dados.
2. O regime configurado fica imediatamente disponível como opção para o planejamento de novas escalas operacionais.

## Dicionário de Dados da Tela/Ação
- Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra
- nome_regime | Texto (Alfanumérico, máx. 50 caracteres) | Sim | Deve ser único no sistema (ex: "Plantão Padrão 12x60", "Operação Especial").
- horas_trabalho | 	Inteiro | Sim | Deve ser maior que 0 e menor ou igual a 24 horas.
- horas_descanso |	Inteiro | Sim | Deve ser maior ou igual a 11 horas (interstício mínimo legal para proteção funcional).
- limite_mensal_horas | Inteiro | Sim | Deve ser um valor entre 120 e 220 horas, limitando o teto operacional do servidor.
- permite_hora_extra | Booleano | Sim | Flag que define se o regime aceita acréscimo de RPE (Regime de Plantão Extraordinário).

## Fluxo principal
1. O Administrador Operacional acessa o menu "Configurações" e seleciona a opção Configurar Regimes de Trabalho.  
2. O sistema renderiza o formulário de cadastro, exibindo os campos vazios para preenchimento: nome_regime, horas_trabalho, horas_descanso, limite_mensal_horas e o seletor permite_hora_extra.
3. O Administrador Operacional preenche todos os dados solicitados e clica no botão "Salvar Diretriz".
4. O sistema intercepta os dados enviados e valida se o usuário possui papel ativo correspondente ao perfil exigido.  
5. O sistema valida se todos os campos obrigatórios foram informados e se respeitam os limites matemáticos configurados no dicionário de dados.
6. O sistema executa a inserção do novo registro na tabela tbl_regimes_trabalho do banco de dados relacional. 
7. O sistema gera automaticamente um registro imutável na tabela de log de auditoria operacional.  
8. O sistema exibe na tela a mensagem de sucesso: "MSG-001: Regime de trabalho cadastrado e parametrizado com sucesso."

## Fluxos alternativos e exceções
- **A1 - Dados inválidos: (Campos incompletos ou fora do limite)**
  - Condição: O ator deixa o campo nome_regime em branco ou insere um valor de horas_descanso menor do que 11 horas.
  - 1. O sistema suspende a gravação no banco de dados.
  - 1. O sistema realça os campos com inconformidades em vermelho e exibe a mensagem em tela: "MSG-E01: Dados inválidos. Certifique-se de preencher todos os campos obrigatórios e respeitar o descanso mínimo legal de 11 horas."

- **A2 - Acesso não autorizado:** 
  - Condição: Um usuário autenticado sem o perfil de Administrador Operacional tenta submeter a requisição via API de forma direta.  
  1. A camada de controle de acesso intercepta e bloqueia a operação imediatamente.  
  2. O sistema interrompe o processamento e exibe a mensagem de erro: "MSG-E02: Acesso negado. Seu perfil de usuário não possui permissão para alterar ou cadastrar parâmetros operacionais do sistema." 


- **A3 - Regra de negócio violada: (Nome duplicado)**
  - Condição: O ator insere um nome de regime que já existe na base de dados do SIG-GCM.
  - 1. O sistema faz a checagem de unicidade e impede a conclusão do cadastro.
  - 1. O sistema mantém os dados no formulário e apresenta a mensagem de justificativa: "MSG-E03: Violação de Regra Operacional. Já existe um regime cadastrado com o nome informado."

## Regras de negócio relacionadas
- RN001: Nenhum servidor poderá possuir escalas conflitantes (a parametrização correta das horas de trabalho e descanso serve de barreira de entrada para evitar conflitos futuros).  
- RN003: Horas extras devem respeitar limites legais (o campo limite_mensal_horas e a flag do regime apoiam o cumprimento automático desta regra).  
- RN004: Usuários somente poderão acessar funcionalidades autorizadas.  RN005: Alterações relevantes deverão gerar logs

## Critérios de aceitação
- CA001: Usuários autenticados devem acessar apenas funcionalidades autorizadas (Acesso restrito ao perfil Administrador Operacional).
- CA005: O sistema deve validar jornadas legais automaticamente (Garantido pelo bloqueio de horas de descanso inferiores a 11 horas no cadastro).
- CA009: O sistema deve registrar logs das operações críticas.
- CA010: O sistema deve suportar expansão modular sem impacto estrutural significativo.

## Logs de auditoria
Como a alteração de parâmetros operacionais é considerada uma operação crítica , o sistema deve salvar de forma síncrona na tabela 
- tbl_log_auditoria:  timestamp_operacao: Data e hora exata do servidor no momento do clique.
- id_usuario: Código identificador do Administrador Operacional logado.  
- ip_origem: Endereço IP de onde partiu a requisição externa.
- tipo_acao: Inserção/Criação (INSERT).
- dados_anteriores: Nulo (por ser um novo cadastro).
- dados_novos: Payload completo em formato JSON contendo os valores gravados (nome_regime, horas_trabalho, horas_descanso, limite_mensal_horas, permite_hora_extra).

## Rastreabilidade RestritaRF013: 
- Configurar diferentes regimes de trabalho, como 12x60, 24x120 e escalas personalizadas.  
- RF025: Registro de operações críticas em logs de auditoria.  
- RF031: Parametrizar as regras operacionais do sistema.  
- RN003, RN004, RN005: Regras de controle legal de jornada, acessos e rastreabilidade.  
- RNF005, RNF008: Controle de acesso por perfil e auditoria operacional.  
- CA001, CA005, CA009: Validações de segurança, conformidade legal de jornadas e auditoria.  
