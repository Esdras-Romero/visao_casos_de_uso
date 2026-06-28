# UC027 - Integrar com sistemas de RH

## Objetivo
Sincronizar e consultar dados funcionais e de cadastro de pessoal entre o ecossistema interno do SIG-GCM e o sistema externo de Recursos Humanos da Prefeitura Municipal, evitando redundância de dados e garantindo a consistência das informações cadastrais dos servidores.

## Ator Principal
Setor de RH

## Pré-condições
- Barramento de integração ou APIs de microsserviços do sistema de RH municipal disponíveis e operacionais.
- Token de autenticação mútua (mTLS / API Key) devidamente configurado entre os servidores.

## Pós-condições
- Dados cadastrais sincronizados, espelhados e atualizados na base de dados do SIG-GCM com sucesso.

## Dicionário de Dados da Tela/Ação

| Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra |
| :--- | :--- | :--- | :--- |
| **Tipo_Operacao** | Enumerado | Sim | Define o sentido da integração. Valores aceitos: `IMPORTAR_DADOS_CADASTRAIS`, `EXPORTAR_FREQUENCIAS`. |
| **Matricula_Filtro** | Alfanumérico (10) | Não | Se preenchido, isola a sincronização a apenas um servidor. Se nulo, executa varredura em lote. |
| **Token_Sessao_RH** | Alfanumérico (256)| Sim | Credencial temporária cifrada para autenticação no barramento externo da prefeitura. |

## Fluxo principal
1. O profissional do Setor de RH realiza a autenticação biométrica ou por credenciais seguras no SIG-GCM.
2. O ator acessa o módulo de Administração de Pessoal e seleciona a opção **Integrar com sistemas de RH**.
3. O sistema renderiza a interface técnica exibindo seletores de operação, campo para filtro opcional de matrícula e o status de conectividade do barramento externo.
4. O ator seleciona o Tipo_Operacao desejado e insere o Token_Sessao_RH fornecido pelo ERP municipal para validar o canal de dados.
5. O ator aciona o comando "Iniciar Sincronização de Dados".
6. O sistema valida os privilégios do perfil do operador (Setor de RH) para garantir que a conta possui escopo de alteração de folha cadastral.
7. O sistema abre uma conexão via protocolo seguro (HTTPS/REST) enviando o payload de requisição estruturado para o endpoint externo do sistema de RH.
8. O barramento externo responde com os dados consolidados; o sistema valida a integridade do pacote recebido e atualiza a tabela interna de servidores (`tb_servidor`).
9. O sistema registra a execução detalhada do lote e volumetria de registros afetados na tabela física de auditoria.
10. O sistema recarrega a interface do usuário e exibe uma janela modal de sucesso com a mensagem: `"Integração realizada com sucesso! Dados sincronizados e atualizados de acordo com o barramento do RH municipal."`

## Fluxo alternativos e exceções

### A1 - Dados inválidos
* **4a. Token de Sessão Expirado ou Malformado:** Se o campo `Token_Sessao_RH` não seguir o padrão criptográfico esperado ou for rejeitado na validação de formato local, o sistema suspende o envio e apresenta em tela a mensagem de erro: `"Erro de Autenticação Interna: O token de sessão de RH fornecido é inválido ou está corrompido. Insira uma chave ativa."`

### A2 - Acesso não autorizado
* **6a. Falha de Papel do Usuário (RBAC):** Se um usuário com perfil Operacional (Guarda de ponta) tentar forçar uma chamada a esta rotina de integração de sistemas, o mecanismo de segurança bloqueia o tráfego de dados e renderiza na tela a mensagem de erro: `"Acesso Negado: A execução de sincronizações externas estruturais é exclusiva do perfil Setor de RH."`

### A3 - Regra de negócio violada
* **7a. Indisponibilidade ou Timeout da API Externa:** Se o barramento de serviços da prefeitura estiver fora do ar ou demorar mais do que o limite transacional aceitável para responder, o sistema desfaz as operações parciais de memória e emite em tela o aviso: `"Falha de Comunicação: O sistema de RH externo não respondeu no tempo limite. Operação abortada para evitar inconsistência de dados."`

## Regras de negócio relacionadas
* **RN006 (Consistência Cadastral Biunívoca):** Nenhuma matrícula de servidor pode ser criada no SIG-GCM se não constar previamente como ativa e homologada no banco de dados mestre de RH do município.
* **RN007 (Prevalência de Dados Mestre):** Em caso de divergência de nomes, CPFs ou filiações, os dados extraídos da API do sistema de RH sempre sobrepõem e corrigem as tabelas locais do SIG-GCM.

## Critérios de aceitação
* A funcionalidade deve rejeitar conexões que não utilizem criptografia em trânsito (TLS 1.3).
* O tempo de resposta para a validação inicial do barramento não deve ultrapassar 5 segundos.
* Todas as alterações efetuadas em lote na tabela local de servidores devem ser passíveis de Rollback automático caso ocorra queda de energia ou interrupção abrupta no meio do lote.

## Logs de auditoria
Toda chamada de sincronização ou transação de dados entre as fronteiras do sistema grava uma entrada detalhada na tabela `tb_audit_integration`:

[TIMESTAMP_UTC] | [USER_ID: ID_RhUser] | [ROLE: Setor_RH] | [INTERFACE: INTERG_RH_API]
[OPERATION_TYPE: Tipo_Operacao] | [ROWS_AFFECTED: Total de Linhas] | [EXTERNAL_RESPONSE_STATUS: HTTP_CODE] | [CONN_HASH: SHA256]

## Rastreabilidade Restrita
* **[RF705]** - Módulo de comunicação e compartilhamento de dados com sistemas corporativos legados ou externos.
* **[RNF202]** - Controle estrito de acesso baseado em papéis (RBAC).
* **[RNF205]** - Geração compulsória de logs e trilhas de auditoria para transações e chamadas de API externas.