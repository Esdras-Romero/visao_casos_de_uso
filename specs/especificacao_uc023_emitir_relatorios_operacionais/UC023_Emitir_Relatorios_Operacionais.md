# UC023 - Emitir Relatórios Operacionais

### Dicionário de Dados da Tela/Filtros: Emitir Relatório Operacional
Esta tabela define os parâmetros de entrada para consolidar os indicadores de execução dos serviços, patrulhamentos e ocorrências atendidas pela GCM.

| Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação / Regra |
| :--- | :--- | :--- | :--- |
| **Data_Inicio** | Data (AAAA-MM-DD) | Sim | Início do período amostral. Não pode ser posterior à `Data_Fim`. |
| **Data_Fim** | Data (AAAA-MM-DD) | Sim | Término do período amostral. Não pode ultrapassar a data atual do sistema. |
| **Regiao_GCM** | Enumerado | Não | Se selecionado, filtra por área de atuação (Ex: `ZONA_NORTE`, `ZONA_SUL`, `CENTRO`, `ORLA`). |
| **Tipo_Agrupamento** | Enumerado | Sim | Determina a quebra analítica do documento. Valores: `POR_OCORRENCIA`, `POR_VTR`, `RESUMO_SINTETICO`. |
| **Formato_Output** | Enumerado | Sim | Formato de saída do arquivo gerado. Valores aceitos: `PDF` ou `CSV`. |

### Fluxo Principal Detalhado
1. O **Gestor Operacional** efetua a autenticação padrão no ambiente corporativo do SIG-GCM (`[RF101]`).
2. O ator navega até o painel analítico e aciona o módulo "Emitir Relatórios Operacionais" (`[RF701]`).
3. O sistema avalia a matriz RBAC e confirma se o perfil logado possui atribuição operacional gerencial (`[RF102]`, `[RNF202]`).
4. O sistema renderiza o painel de filtros operacionais e estatísticos (`[RNF301]`).
5. O ator seleciona o intervalo de datas, escolhe o Tipo de Agrupamento das informações, o escopo da Região GCM opcional e define o Formato_Output.
6. O ator aciona a opção "Gerar Relatório de Execução".
7. O sistema executa as validações de formatação estrutural e sanidade lógica das janelas temporais informadas.
8. O sistema realiza varredura e compilação nas tabelas de ocorrências (`tb_ocorrencia`) e livros de bordo operacionais (`tb_livro_bordo`) cruzando dados de serviços executados.
9. O sistema grava um registro definitivo da consulta gerencial para fins de auditoria de dados sensíveis de segurança pública (`[RNF205]`).
10. O sistema gera a compilação do relatório e inicia o download direto do documento na máquina cliente dentro do tempo transacional aceitável (`[RNF701]`).

### Fluxos Alternativos e de Exceção

#### A1 - Dados inválidos
* **7a. Intervalo Incoerente:** Se a `Data_Inicio` for configurada matematicamente maior que a `Data_Fim`, a operação falha localmente emitindo o aviso: `"Erro de entrada: A data inicial selecionada ultrapassa o limite da data final do filtro."`

#### A2 - Acesso não autorizado
* **3a. Restrição de Escopo Operacional:** Se um guarda de equipe de rua (Perfil Operacional Padrão) ou um perfil externo tentar forçar a requisição do endpoint, o sistema bloqueia o acesso e emite: `"Acesso Negado: Emissão de balanços operacionais consolidada é restrita ao perfil Gestor Operacional."` (`[RNF202]`).

#### A3 - Regra de negócio violada
* **8a. Ausência de Registros Operacionais:** Se não houver nenhum atendimento de ocorrência ou lançamento de patrulhamento registrado na janela cronológica informada, o processo de renderização do arquivo é suspenso, exibindo: `"Pesquisa sem resultados: Não há dados operacionais computados no intervalo selecionado."`

### Rastreabilidade Restrita
* **[RF701]** - Geração de relatórios gerenciais e acompanhamento estatístico da execução dos serviços.
* **[RNF202]** - Controle de acesso rigoroso baseado em funções funcionais (RBAC).
* **[RNF205]** - Rastreabilidade de transações críticas e consultas a dados por log de auditoria.