# UC022 - Vincular Servidores a Setores
## ARTEFATO 1: Detalhamento Técnico e Dicionário de Dados

### Dicionário de Dados da Tela/Ação: Vincular Servidor a Setor
Esta tabela define a estrutura de dados necessária para alocar um servidor do efetivo a uma unidade organizacional ou setor específico dentro do organograma do SIG-GCM.

| Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação / Regra |
| :--- | :--- | :--- | :--- |
| **Matricula_Servidor** | Alfanumérico (10) | Sim | Chave Estrangeira (`tb_servidor`). Deve identificar um servidor válido cadastrado no sistema. |
| **ID_Setor** | Inteiro | Sim | Chave Estrangeira (`tb_setor`). Deve corresponder a um setor institucional ativo (Ex: Corregedoria, Operacional, Logística). |
| **Data_Vinculo** | Data (AAAA-MM-DD) | Sim | Data em que a lotação passa a vigorar. Não pode ser inferior à data de admissão do servidor. |
| **Tipo_Designacao** | Enumerado | Sim | Valores aceitos: `TITULAR`, `SUBSTITUTO`, `EM_TRANSITO`. |

### Fluxo Principal Detalhado
1. O **Administrador Institucional** realiza a autenticação biométrica ou por senha no sistema (`[RF101]`).
2. O ator acessa o painel de configurações estruturais e seleciona a opção "Vincular Servidor a Setor" (`[RF603]`).
3. O sistema valida as credenciais do perfil Administrador Institucional e carrega a tela com os seletores de servidores e a árvore de setores institucionais cadastrados (`[RF102]`, `[RNF202]`).
4. O ator seleciona o Servidor (por nome ou matrícula), escolhe o Setor destino, define a Data do Vínculo e o Tipo de Designação.
5. O ator aciona o comando "Confirmar Vínculo".
6. O sistema intercepta o comando e valida se os IDs do servidor e do setor são íntegros e se a data informada é cronologicamente aceitável.
7. O sistema executa a transação na tabela associativa `tb_servidor_setor`, encerrando vínculos anteriores caso o setor exija exclusividade de lotação.
8. O sistema atualiza a matriz de permissões de escopo do servidor com base nas regras do novo setor atribuído.
9. O sistema grava a operação de movimentação de pessoal na trilha de auditoria imutável (`[RF704]`, `[RNF205]`).
10. O sistema recarrega o organograma dinâmico e exibe notificação visual de sucesso.

### Fluxos Alternativos e de Exceção

#### A1 - Dados inválidos
* **6a. Vínculo sem Entidades Selecionadas:** Se o operador não marcar um servidor ou setor antes de enviar, o sistema bloqueia o avanço e exibe: `"Erro de seleção: É mandatório escolher um servidor válido e um setor de destino cadastrado."`

#### A2 - Acesso não autorizado
* **3a. Usuário sem privilégios administrativos:** Se um usuário do Setor de RH ou do perfil Operacional tentar efetuar o mapeamento estrutural de setores, o sistema emite uma exceção de segurança e exibe: `"Acesso Negado: A movimentação hierárquica e vinculação setorial é exclusiva do perfil Administrador Institucional."` (`[RNF202]`).

#### A3 - Regra de negócio violada
* **6b. Setor Inativo:** Se o setor de destino estiver marcado com status desativado no sistema, a vinculação é abortada com o aviso: `"Operação Recusada: O setor selecionado encontra-se inativo e não pode receber novas dotações de pessoal."`
* **6c. Choque de Vigência:** Se a data de vínculo for retroativa a um período já consolidado em folhas de escala antigas ou anterior à admissão do guarda, o sistema bloqueia e exibe: `"Inconsistência Cronológica: A data de vinculação setorial é inválida por preceder o registro de admissão do servidor."`

### Rastreabilidade Restrita
* **[RF603]** - Configuração da estrutura organizacional e entes administrativos da corporação.
* **[RF704]** - Rastreabilidade completa de movimentações funcionais e alterações de dados relevantes.
* **[RNF202]** - Controle de acesso baseado em papéis (RBAC).
* **[RNF205]** - Geração de trilhas de auditoria criptográficas para ações de infraestrutura.