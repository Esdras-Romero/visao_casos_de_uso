# UC025 - Registrar logs de auditoria

## Objetivo
Permitir ao Administrador do Sistema registrar manualmente intervenções críticas de infraestrutura, manutenções emergenciais em banco de dados ou declarações de incidentes de segurança, garantindo a rastreabilidade e integridade do ecossistema SIG-GCM.

## Ator Principal
Administrador do Sistema

## Pré-condições
- Usuário autenticado com privilégios de gerenciamento de infraestrutura (Root/SysAdmin).
- Ocorrência de uma intervenção manual ou evento crítico que exija documentação legal no histórico do sistema.

## Pós-condições
- Registro de auditoria persistido em base de dados com assinatura digital/hash SHA-256 gerado, tornando-se imutável.

## Dicionário de Dados da Tela/Ação

| Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra |
| :--- | :--- | :--- | :--- |
| **Modulo_Alvo** | Enumerado | Sim | Identifica o subsistema afetado. Valores: `SEGURANCA`, `INFRAESTRUTURA`, `BANCO_DADOS`, `CORE_APPLICATIONAL`. |
| **Nivel_Impacto** | Enumerado | Sim | Severidade do evento registrado. Valores: `BAIXO`, `MEDIO`, `ALTO`, `CRITICO`. |
| **Descricao_Evento** | Alfanumérico (500) | Sim | Texto descritivo detalhando a ação realizada ou o incidente observado. Não pode conter caracteres de injeção SQL. |
| **Payload_Dados** | Texto Longo (JSON) | Sim | Estado dos dados afetados ou parâmetros técnicos da alteração estrutural. Deve ser um JSON estruturalmente válido. |

## Fluxo principal
1. O Administrador do Sistema realiza o login de alta segurança com múltiplos fatores de autenticação (MFA).
2. O ator navega até o console de gerenciamento de segurança e seleciona a funcionalidade **Registrar logs de auditoria**.
3. O sistema renderiza a interface administrativa exibindo os campos de categorização do evento, nível de severidade, descrição textual e terminal de payload JSON.
4. O ator seleciona o Modulo_Alvo, define o Nivel_Impacto, digita a Descricao_Evento e cola o Payload_Dados correspondente à intervenção técnica.
5. O ator aciona o comando "Gravar Registro de Auditoria".
6. O sistema intercepta a requisição e valida o nível de privilégio do token do usuário logado na matriz de controle de acesso (RBAC).
7. O sistema executa a validação sintática do campo JSON e analisa o texto contra strings maliciosas.
8. O sistema calcula o hash SHA-256 combinando os dados enviados, o timestamp atual (2026) e o ID do usuário para assegurar a imutabilidade do registro.
9. O sistema insere a linha de log de auditoria de forma definitiva no banco de dados relacional.
10. O sistema apresenta em tela um banner verde de sucesso contendo a mensagem: `"Log de auditoria registrado com sucesso! Assinatura digital gerada e vinculada ao histórico imutável."`

## Fluxo alternativos e exceções

### A1 - Dados inválidos
* **7a. Payload JSON Corrompido:** Se o campo `Payload_Dados` contiver uma estrutura que quebre o parser de JSON do sistema, a transação é interrompida e o sistema renderiza na tela a mensagem de erro: `"Erro de Validação: O payload de dados alterados deve ser um JSON válido e a descrição não pode estar vazia."`

### A2 - Acesso não autorizado
* **6a. Token Administrativo Insuficiente:** Se um usuário com perfil de Gestor Operacional ou de Administrador Institucional tentar forçar o envio de dados para este endpoint de nível de sistema, a operação é sumariamente abortada, gerando um contra-alerta de segurança e exibindo na tela a mensagem: `"Acesso Negado: A gravação manual de eventos de auditoria de segurança é restrita ao perfil de Administrador do Sistema."`

### A3 - Regra de negócio violada
* **8a. Tentativa de Registro Retroativo Inconsistente:** Se os metadados do payload tentarem forçar um timestamp retroativo que viole o sequenciamento estrito dos registros cronológicos já consolidados da tabela, o sistema impede a gravação e apresenta a mensagem de justificativa: `"Operação Rejeitada: Violação de diretriz de segurança. Não é permitido o registro de eventos de auditoria com data retroativa."`

## Regras de negócio relacionadas
* **RN004 (Imutabilidade do Log):** Uma vez persistido na tabela de auditoria, o registro não pode sofrer nenhuma operação de UPDATE ou DELETE por qualquer usuário do sistema.
* **RN005 (Criptografia e Hash de Integridade):** Cada nova linha inserida na tabela de logs deve gerar uma assinatura hash baseada no registro anterior (cadeia de blocos), impedindo adulterações diretas no banco de dados.

## Critérios de aceitação
* A funcionalidade deve ser exposta exclusivamente para contas com a flag de privilégio de sistema ativa (SysAdmin).
* O campo descritivo deve passar por filtro sanitário contra Cross-Site Scripting (XSS) e SQL Injection.
* O sistema deve emitir resposta visual inequívoca em menos de 2 segundos após o processamento e assinatura do log.

## Logs de auditoria
Como a própria funcionalidade consiste em registrar um evento crítico de forma explícita, o sistema espelha o registro gerando uma entrada auto-auditada na tabela `tb_sys_audit_tracker`:

[TIMESTAMP_UTC] | [USER_ID: ID_SysAdmin] | [ROLE: SysAdmin] | [ACTION: MANUAL_LOG_REGISTRATION]
[TARGET_MODULE: Modulo_Alvo] | [SEVERITY: Nivel_Impacto] | [HASH_GENERATED: SHA256_HASH]

## Rastreabilidade Restrita
* **[RF704]** - Rastreabilidade completa e ferramentas de infraestrutura de dados.
* **[RNF202]** - Controle de acesso baseado em papéis de alta granularidade (RBAC).
* **[RNF205]** - Geração de trilhas de auditoria criptográficas para ações críticas de infraestrutura.