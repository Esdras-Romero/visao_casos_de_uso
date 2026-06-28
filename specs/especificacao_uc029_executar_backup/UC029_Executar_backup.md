# UC029 - Executar backup

## Objetivo
Realizar o backup completo ou parcial da base de dados relacional, arquivos de logs de auditoria e anexos digitais do sistema SIG-GCM, garantindo a salvaguarda de informações estratégicas de segurança pública e a continuidade do negócio em caso de desastre.

## Ator Principal
Administrador do Sistema

## Pré-condições
- Usuário autenticado com perfil de infraestrutura de alta segurança (SysAdmin).
- Espaço de armazenamento suficiente disponível no volume local de contingência ou no bucket de nuvem homologado.

## Pós-condições
- Arquivo de backup compactado, criptografado e persistido no storage alvo, com metadados registrados na tabela de controle de segurança.

## Dicionário de Dados da Tela/Ação

| Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra |
| :--- | :--- | :--- | :--- |
| **Tipo_Backup** | Enumerado | Sim | Escopo da cópia de segurança. Valores aceitos: `COMPLETO`, `INCREMENTAL`, `APENAS_LOGS`. |
| **Destino_Armazenamento** | Enumerado | Sim | Destino físico do binário gerado. Valores aceitos: `STORAGE_NUVEM_REDUNDANTE`, `SERVIDOR_LOCAL_CONTINGENCIA`. |
| **Criptografia_Adicional** | Booleano | Sim | Flag indicando a aplicação de dupla camada de criptografia (AES-256). Padrão: Sim. |

## Fluxo principal
1. O Administrador do Sistema realiza o procedimento de login corporativo exigindo autenticação multifator (MFA).
2. O ator navega até o menu de infraestrutura, utilitários de banco de dados e aciona a opção **Executar backup**.
3. O sistema renderiza a tela técnica exibindo os seletores de escopo, rádio-botões para destinação do arquivo e o indicador de espaço em disco em tempo real.
4. O ator informa o Tipo_Backup, seleciona o Destino_Armazenamento desejado e confirma a flag de Criptografia_Adicional.
5. O ator aciona o comando "Iniciar Processamento de Backup".
6. O sistema intercepta o comando e valida se a sessão atual pertence de forma inequívoca ao perfil Administrador do Sistema.
7. O sistema congela transações voláteis em memória de forma momentânea para garantir a consistência de estado das tabelas e inicia a extração estruturada dos dados.
8. O sistema compacta o dump gerado em um pacote `.tar.gz`, calcula sua assinatura digital SHA-256 e transfere o binário cifrado para o storage de destino escolhido.
9. O sistema grava os metadados técnicos do arquivo gerado (tamanho, hash, data e responsável) em uma entrada definitiva da trilha de logs de auditoria de infraestrutura.
10. O sistema recarrega a console de administração e exibe a mensagem de sucesso em tela: `"Cópia de segurança gerada com sucesso! O arquivo de backup foi criptografado e transmitido ao repositório seguro."`

## Fluxo alternativos e exceções

### A1 - Dados inválidos
* **4a. Seleção Incompleta de Parâmetros:** Se o operador deixar de marcar o escopo da rotina em `Tipo_Backup` antes de submeter o formulário, o sistema bloqueia o disparo técnico do motor e renderiza a mensagem de erro: `"Erro de Configuração: É obrigatório especificar o escopo do tipo de backup e o repositório de destino."`

### A2 - Acesso não autorizado
* **6a. Tentativa de Disparo por Perfil Institucional Padrão:** Se um usuário autenticado sob o perfil de Administrador Institucional ou Setor de RH tentar invocar de forma direta os endpoints controladores deste backup, o sistema nega a transação na camada de segurança e exibe: `"Acesso Negado: A execução manual de rotinas de backup e cópias frias da base é restrita ao perfil Administrador do Sistema."`

### A3 - Regra de negócio violada
* **7a. Insuficiência de Espaço ou Queda de Conexão com o Storage:** Se o volume alocado ou bucket externo reportar falta de capacidade de armazenamento durante a escrita, ou houver oscilação de link, o sistema cancela a exportação, desfaz os arquivos temporários criados e exibe na tela o erro: `"Falha de Infraestrutura: Espaço em disco insuficiente ou indisponibilidade no storage de destino para acomodar a cópia de segurança."`

## Regras de negócio relacionadas
* **RN004 (Criptografia de Dados em Repouso):** Todo arquivo de backup produzido pelo SIG-GCM deve sofrer cifragem compulsória de algoritmo AES-256 bits antes do envio para redes de armazenamento externas.
* **RN005 (Manutenção de Trilha Síncrona):** É proibida a deleção ou substituição de metadados de backups antigos na tabela de rastreabilidade do sistema.

## Critérios de aceitação
* A operação de cópia completa do banco relacional deve rodar em background sem derrubar as sessões ativas de leitura e atendimento de ocorrências da GCM.
* O arquivo final transmitido deve conter o hash de integridade validado automaticamente pelo storage remoto após a conclusão do upload.
* O sistema deve notificar o administrador em tela sobre o tamanho exato em Megabytes do arquivo exportado.

## Logs de auditoria
Sendo uma atividade de máxima criticidade para a resiliência de dados do município, o sistema grava na tabela `tb_sys_backup_audit`:

[TIMESTAMP_UTC] | [USER_ID: ID_SysAdmin] | [ROLE: SysAdmin] | [BACKUP_TYPE: Tipo_Backup]
[DESTINATION: Destino_Armazenamento] | [FILE_SIZE_MB: Tam_Arquivo] | [FILE_HASH: SHA256_HASH]

## Rastreabilidade Restrita
* **[RF704]** - Ferramentas de infraestrutura de dados e manutenção de cópias funcionais.
* **[RNF202]** - Controle estrito de privilégios de acesso por papéis (RBAC).
* **[RNF205]** - Geração de trilhas de auditoria criptográficas para ações críticas de infraestrutura.