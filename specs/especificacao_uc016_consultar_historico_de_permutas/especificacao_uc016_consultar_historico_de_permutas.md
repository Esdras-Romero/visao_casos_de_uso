# UC016 - Consultar histórico de permutas

## Objetivo
Disponibilizar ao Administrador do Sistema a consulta unificada, filtragem e rastreamento completo de todas as solicitações de permutas de plantão processadas na plataforma, viabilizando auditorias internas e a conferência do histórico de alterações operacionais.

## Ator principal
Administrador do Sistema

## Pré-condições
1. O usuário deve estar autenticado no SIG-GCM sob o perfil de "Administrador do Sistema".  
2. Existência de registros de permutas salvos previamente na base de dados relacional (tbl_permutas).

## Pós-condições
1. O sistema renderiza na tela a listagem de registros correspondente aos filtros aplicados.
2. É mantida a rastreabilidade integral das consultas operacionais críticas para auditoria corporativa.

## Dicionário de Dados da Tela/Ação
- Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra
- data_inicio | Date (YYYY-MM-DD) | Não | Se informada, deve ser menor ou igual à data atual do sistema.
- data_fim | Date (YYYY-MM-DD) | Não | Se informada, deve ser maior ou igual à data_inicio e menor ou igual à data atual.
- matricula_solicitante | Texto (Alfanumérico) | Não | Deve corresponder a um padrão de matrícula funcional ativo ou histórico do sistema.
- status_permuta | Enum (Texto) | Não | Deve filtrar estritamente pelos valores: PENDENTE_APROVACAO, APROVADO, REPRO

## Fluxo principal
1. O Administrador do Sistema acessa o menu de "Auditoria" e seleciona a opção Consultar histórico de permutas.
2. O sistema renderiza a tela com os campos de filtros: data_inicio, data_fim, matricula_solicitante e status_permuta.
3. O ator preenche os parâmetros desejados para a pesquisa e clica na ação "Filtrar Histórico".
4. O sistema valida se o perfil do usuário logado é correspondente a "Administrador do Sistema".
5. O sistema valida a consistência cronológica do intervalo de datas informado.
6. O sistema executa uma instrução de busca (SELECT) na tabela tbl_permutas aplicando os filtros especificados.
7. O sistema grava um registro de log de auditoria na tabela tbl_log_auditoria mapeando que o histórico foi consultado por aquele usuário.  
8. O sistema renderiza a listagem de resultados com sucesso, exibindo as colunas de data da solicitação, GCM solicitante, GCM substituto, status final e o responsável pela homologação.

## Fluxos alternativos e exceções
- **A1 - Dados inválidos: (Intervalo de datas inconsistente)**
 - Condição: O ator insere uma data_fim cronologicamente anterior à data_inicio.
  1. O sistema interrompe o processamento da consulta.
  1. O sistema realça os limites de data em vermelho e exibe a mensagem exata na tela: "MSG-E01: Intervalo de pesquisa inválido. A data final da consulta não pode ser anterior à data inicial."

- **A2 - Acesso não autorizado:** 
- Condição: Um usuário autenticado sob o perfil de "Equipe Operacional" tenta forçar uma requisição direta ao endpoint de listagem de histórico de auditoria de permutas.
 1. O módulo de controle de acesso intercepta a chamada de sistema.  
 1. O sistema bloqueia a execução da consulta e exibe a mensagem de erro: "MSG-E02: Acesso negado. Seu perfil institucional não possui privilégios para consultar o histórico global de auditoria de permutas."

- **A3 - Regra de negócio violada: (Nenhum registro encontrado)**
- Condição: Os critérios de busca submetidos não encontram nenhuma correspondência na base de dados de permutas.
 1. O sistema conclui a pesquisa no banco com retorno vazio.
 1. O sistema limpa a tabela de resultados e apresenta a mensagem informativa: "MSG-I03: Nenhum registro de permuta foi encontrado para os filtros selecionados."

## Regras de negócio relacionadas
- RN004 - Controle de Acesso Autoritativo: Apenas usuários com perfis administrativos ou de alta gestão operacional possuem direito de visualização sobre o repositório histórico completo de logs e permutas da corporação.  
- RN005 - Rastreabilidade Obrigatória: Toda e qualquer consulta ou alteração nos registros de histórico do efetivo deve gerar rastros claros e auditáveis para prevenção de fraudes. 

## Critérios de aceitação
- CA001: Usuários autenticados devem acessar apenas as funcionalidades autorizadas de acordo com seu respectivo nível hierárquico.  
- CA009: O sistema deve registrar logs detalhados e imutáveis de todas as operações críticas e consultas a relatórios de auditoria.  
- CA010: O mecanismo de consulta de histórico deve operar de forma desacoplada, permitindo a inclusão de novos filtros sem comprometer a estrutura das tabelas bases do sistema.

## Logs de auditoria
Toda consulta ao histórico total de permutas deve disparar um registro síncrono na tabela tbl_log_auditoria:  
- timestamp: Data, hora, minuto e segundo exatos do servidor no momento do clique.
- id_usuario: UUID do Administrador do Sistema autenticado.  
- ip_origem: Endereço de IP da máquina solicitante.
- acao_executada: "CONSULTA_HISTORICO_PERMUTAS".
- filtros_utilizados: Objeto JSON registrando os parâmetros digitados na tela, por exemplo: {"data_inicio": "2026-01-01", "data_fim": "2026-06-28", "status": "APROVADO"}.

## Rastreabilidade Restrita
- RF016: Manutenção do histórico completo das permutas realizadas para fins de auditoria e rastreabilidade.  
- RF025, RF026: Registro de operações críticas e rastreamento de alterações no sistema.  
- RN004, RN005: Regras de acesso restrito e obrigatoriedade de geração de logs.  
- RNF005, RNF008: Controle de acesso por perfil e auditoria operacional do ecossistema.  
- CA001, CA009: Critérios de validação de acessos autorizados e registro de logs operacionais.  
