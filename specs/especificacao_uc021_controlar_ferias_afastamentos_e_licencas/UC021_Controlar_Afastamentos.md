# UC021 - Controlar Férias, Afastamentos e Licenças
## ARTEFATO 1: Detalhamento Técnico e Dicionário de Dados

### Dicionário de Dados da Tela/Ação: Registrar Situação Funcional
Esta tabela define os campos necessários para cadastrar um período de interrupção de atividades que impactará diretamente no motor de geração de escalas de serviço do SIG-GCM.

| Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação / Regra |
| :--- | :--- | :--- | :--- |
| **Matricula_Servidor** | Alfanumérico (10) | Sim | Chave Estrangeira (`tb_servidor`). Deve corresponder a um servidor cadastrado e ativo. |
| **Tipo_Situacao** | Enumerado | Sim | Valores aceitos: `FERIAS`, `LICENCA_MEDICA`, `LICENCA_PREMIO`, `AFASTAMENTO_INTERNO`, `SUSPENSAO`. |
| **Data_Inicio** | Data (AAAA-MM-DD) | Sim | Data inicial do evento. Não pode ser inferior à data atual para novas programações de férias. |
| **Data_Fim** | Data (AAAA-MM-DD) | Sim | Data final do evento. Deve ser estritamente igual ou posterior à `Data_Inicio`. |
| **Documento_Legal** | Alfanumérico (50) | Sim | Número da portaria, atestado, certidão ou boletim interno que ampara a alteração funcional. |

### Fluxo Principal Detalhado
1. O integrante do **Setor de RH** realiza o login seguro no sistema (`[RF101]`).
2. O ator pesquisa o servidor desejado na base pelo prontuário e seleciona a opção "Registrar Alteração Funcional (Férias/Afastamentos/Licenças)" (`[RF601]`).
3. O sistema valida as permissões do perfil Setor de RH e renderiza a tela operacional exibindo o histórico de afastamentos do servidor (`[RF102]`, `[RNF202]`).
4. O ator preenche o Tipo de Situação, define o intervalo de datas (`Data_Inicio` e `Data_Fim`) e insere o número do Documento Legal.
5. O ator aciona o comando "Gravar Situação Funcional".
6. O sistema executa as validações cronológicas e impede conflitos de datas com outros períodos já homologados na ficha do trabalhador.
7. O sistema persiste o registro na tabela `tb_afastamento` e altera temporariamente o status dinâmico do servidor para o tipo de licença correspondente.
8. O sistema sinaliza o módulo de inteligência de escalas para indisponibilizar automaticamente o guarda-civil em qualquer escala contida no intervalo delimitado (`[RF602]`).
9. O sistema gera de forma automática um log rastreável de alteração cadastral sensível (`[RF704]`, `[RNF205]`).
10. O sistema recarrega a linha do tempo funcional do servidor e apresenta um alerta de sucesso na operação.

### Fluxos Alternativos e de Exceção

#### A1 - Dados inválidos
* **6a. Inconsistência de Período:** Se a `Data_Inicio` for configurada para um dia posterior à `Data_Fim`, a operação é interrompida com o alerta: `"Erro de período: A data de término do afastamento não pode preceder a data de início."`
* **6b. Campo de Amparo Vazio:** Se o campo `Documento_Legal` não for preenchido, o sistema impede a gravação exibindo: `"Validação Falhou: É obrigatório informar o documento de amparo legal (Portaria/Atestado) para registrar esta situação."`

#### A2 - Acesso não autorizado
* **3a. Usuário sem atribuição de RH:** Se um operador com perfil do Comando ou perfil Administrativo de outra divisão tentar submeter dados de afastamentos, a transação sofre rollback e o sistema exibe: `"Acesso Negado: Alterações de prontuário e histórico de disponibilidade funcional são restritas ao perfil Setor de RH."` (`[RNF202]`).

#### A3 - Regra de negócio violada
* **6c. Superposição de Datas (Overlap):** Se o intervalo escolhido conflitar total ou parcialmente com férias ou licenças já cadastradas para aquele mesmo servidor, o sistema bloqueia e emite: `"Operação Cancelada: O período informado sobrepõe-se a um afastamento já existente cadastrado para este servidor."`
* **6d. Servidor Vinculado a Escala Publicada:** Se o servidor já possuir plantões agendados e publicados dentro do período de afastamento solicitado, o sistema exige uma confirmação do operador, forçando a remoção do servidor das respectivas escalas para não gerar furos operacionais.

### Rastreabilidade Restrita
* **[RF601]** - Gestão e atualização de pessoal e registros funcionais.
* **[RF602]** - Regras automáticas de impedimento de dotação e alocação de pessoal em plantões/escalas.
* **[RF704]** - Histórico cronológico e rastreabilidade de ações críticas no prontuário do servidor.
* **[RNF202]** - Autenticação baseada em funções administrativas (RBAC).
* **[RNF205]** - Auditoria interna por meio de trilhas de auditoria protegidas por hash.