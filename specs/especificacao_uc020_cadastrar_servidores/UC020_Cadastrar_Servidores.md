# UC020 - Cadastrar Servidores
## ARTEFATO 1: Detalhamento Técnico e Dicionário de Dados

### Dicionário de Dados da Tela/Ação: Cadastrar Servidor
Esta tabela define as restrições de validação e persistência para a inserção de novos guardas e servidores no banco de dados unificado do SIG-GCM.

| Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação / Regra |
| :--- | :--- | :--- | :--- |
| **Matricula** | Alfanumérico (10) | Sim | Chave Primária. Deve ser única no sistema. Não pode conter caracteres especiais. |
| **CPF** | Alfanumérico (11) | Sim | Deve possuir 11 dígitos numéricos exatos e passar na validação de dígito verificador. Deve ser único. |
| **Nome_Completo** | Texto (Até 100 carac.)| Sim | Não pode conter números ou caracteres especiais de pontuação. |
| **Cargo_Posto** | Enumerado | Sim | Valores aceitos: `Guarda_3_Classe`, `Guarda_2_Classe`, `Guarda_1_Classe`, `Subinspetor`, `Inspetor`, `Inspetor_Geral`. |
| **Status_Funcional**| Enumerado | Sim | Valor padrão inicial: `ATIVO`. Permite alteração posterior para `FERIAS`, `LICENCA` ou `AFASTADO`. |
| **Data_Admissao** | Data (AAAA-MM-DD) | Sim | Não pode ser superior à data corrente do sistema (proibido data futura). |

### Fluxo Principal Detalhado
1. O integrante do **Setor de RH** realiza o login seguro no sistema (`[RF101]`).
2. O ator navega até o submódulo "Gestão de Efetivo" e aciona a opção "Cadastrar Novo Servidor" (`[RF601]`).
3. O sistema intercepta o pedido, valida se o perfil logado possui permissões específicas de escrita do RH e renderiza o formulário em branco (`[RF102]`, `[RNF202]`, `[RNF301]`).
4. O ator preenche todos os dados obrigatórios do formulário (Matrícula, CPF, Nome Completo, Cargo/Posto e Data de Admissão).
5. O ator aciona o comando "Salvar Cadastro".
6. O sistema valida localmente o preenchimento e a integridade matemática do CPF.
7. O sistema realiza uma consulta concorrente na base de dados para garantir a inexistência de duplicidade para a Matrícula e CPF informados.
8. O sistema persiste as informações na tabela `tb_servidor` com o status funcional inicial definido como `"ATIVO"`.
9. O sistema dispara automaticamente a gravação de logs imutáveis detalhando a inclusão do novo membro no efetivo municipal (`[RF704]`, `[RNF205]`).
10. A interface limpa os campos preenchidos e renderiza um alerta visual de sucesso para o operador.

### Fluxos Alternativos e de Exceção

#### A1 - Dados inválidos
* **6a. Campos obrigatórios em branco:** Se houver campos vazios, o sistema aborta a operação, destaca as bordas em vermelho e exibe: `"Erro de validação: O campo [Nome do Campo] é obrigatório e precisa ser preenchido."`
* **6b. CPF Inválido:** Se o cálculo do dígito verificador do CPF falhar, o sistema impede o envio e exibe: `"Erro de formato: O CPF informado não é válido. Verifique os dígitos."`

#### A2 - Acesso não autorizado
* **3a. Bloqueio por perfil de acesso:** Se um usuário pertencente à Equipe Operacional ou ao Comando tentar forçar o endpoint de gravação de pessoal, o sistema bloqueia o comportamento e exibe: `"Acesso Negado: Seu perfil de usuário não possui permissões de escrita para gerenciar o efetivo no SIG-GCM."` (`[RNF202]`).

#### A3 - Regra de negócio violada
* **7a. Duplicidade de Cadastro (Matrícula ou CPF):** Se a Matrícula ou o CPF já constarem em uso por outro registro na base de dados, a gravação é rejeitada e o sistema exibe: `"Operação Recusada: Já existe um servidor cadastrado com a Matrícula ou CPF informado."`
* **7b. Data de Admissão Inconsistente:** Se a `Data_Admissao` informada for posterior ao dia corrente do servidor, o sistema barra a inserção exibindo: `"Erro cronológico: A data de admissão não pode ser uma data futura."`

### Rastreabilidade Restrita
* **[RF601]** - Cadastro e gerenciamento do Efetivo operacional por parte do setor de RH.
* **[RF704]** - Rastreamento completo de alterações e histórico de dados críticos modificados.
* **[RNF202]** - Controle de acesso estrito baseado em papéis (RBAC).
* **[RNF205]** - Geração automatizada de logs detalhados e imutáveis de auditoria.

### Logs de Auditoria
A inserção de novos servidores modifica de forma definitiva o Efetivo ativo apto para escalas e gera impacto financeiro. O sistema registra na tabela `tb_log_operacional`: