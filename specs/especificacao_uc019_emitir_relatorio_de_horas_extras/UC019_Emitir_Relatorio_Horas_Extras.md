# UC019 - Emitir Relatório de Horas Extras
## ARTEFATO 1: Detalhamento Técnico e Dicionário de Dados

### Dicionário de Dados da Tela/Filtros: Emitir Relatório de Horas Extras
Esta tabela define os parâmetros de entrada para a geração do relatório dinâmico na plataforma SIG-GCM.

| Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação / Regra |
| :--- | :--- | :--- | :--- |
| **Data_Inicio** | Data (AAAA-MM-DD) | Sim | Define o início do período de busca (`[RF701]`). Não pode ser posterior à `Data_Fim`. |
| **Data_Fim** | Data (AAAA-MM-DD) | Sim | Define o término do período de busca (`[RF701]`). Não pode ser uma data futura. |
| **Matricula_Filtro** | Alfanumérico (10) | Não | Se preenchido, restringe o relatório a um servidor específico (`[RF701]`). Deve ser uma matrícula válida no RH. |
| **Formato_Exportacao** | Enumerado | Sim | Valores aceitos: `PDF` ou `CSV`. |

### Fluxo Principal Detalhado
1. O integrante do **Comando** realiza a autenticação no sistema (`[RF101]`).
2. O ator acessa o menu "Relatórios e Estatísticas" e clica em "Emitir Relatório de Horas Extras" (`[RF702]`).
3. O sistema valida as credenciais do usuário e confirma o nível de permissão do perfil Comando (`[RF102]`, `[RNF202]`).
4. O sistema renderiza a interface com os parâmetros de filtragem de data, campo de matrícula opcional e botões de exportação (`[RNF301]`).
5. O ator insere a Data de Início, a Data de Fim, opcionalmente digita uma Matrícula e escolhe o Formato de Exportação (ex: PDF).
6. O ator aciona o comando "Gerar Relatório".
7. O sistema intercepta a requisição, valida as restrições de datas e faz a busca na base de dados, consolidando dados de horas calculadas, homologadas ou rejeitadas pela Diretoria Operacional (`[RF502]`).
8. O sistema compila o documento com os indicadores de conformidade legal das jornadas (`[RF702]`).
9. O sistema registra de maneira invisível o log de auditoria de consulta aos dados e geração do documento (`[RNF205]`).
10. O sistema disponibiliza o arquivo gerado para download e exibe mensagem de sucesso em tela dentro do tempo limite transacional (`[RNF701]`).

### Fluxos Alternativos e de Exceção

#### A1 - Dados inválidos
* **7a. Período Invertido ou Incompleto:** Se a `Data_Inicio` for maior que a `Data_Fim`, ou se algum campo obrigatório estiver vazio, o sistema interrompe o processamento e exibe: `"Erro nos parâmetros: A data inicial não pode ser superior à data final do relatório."`

#### A2 - Acesso não autorizado
* **3a. Restrição por Perfil:** Se um usuário com perfil Operacional tentar acessar a rota de relatórios gerenciais, o sistema impede a execução e exibe em tela: `"Acesso Negado: Seu perfil de usuário não possui permissões para emitir relatórios de conformidade legal no SIG-GCM."` (`[RNF202]`).

#### A3 - Regra de negócio violada
* **7b. Nenhum Registro Encontrado:** Se a busca no banco de dados não retornar nenhuma hora extra no período selecionado, o processamento de exportação é cancelado e o sistema notifica: `"Pesquisa sem resultados: Não existem registros de horas extras mapeados para os filtros informados."`

### Rastreabilidade Restrita
* **[RF701]** - Filtros e relatórios de horas calculadas por período e por servidor.
* **[RF702]** - Relatórios emitidos pelo Comando para validação da conformidade legal e dotação das jornadas.
* **[RF502]** - Vinculação com o status final atribuído pela validação da Diretoria Operacional.
* **[RNF202]** - Controle de acesso baseado em papéis (RBAC).
* **[RNF205]** - Logs imutáveis de auditoria operacional do sistema.
