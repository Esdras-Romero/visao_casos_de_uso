# UC018 - Validar Horas Extras
## ARTEFATO 1: Detalhamento Técnico e Dicionário de Dados

### Dicionário de Dados da Tela/Ação: Validar Horas Extras
Esta tabela define os campos de entrada, controle e persistência utilizados pela Diretoria Operacional para homologação ou rejeição do banco de horas extras.

| Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação / Regra |
| :--- | :--- | :--- | :--- |
| **ID_Hora_Extra** | Inteiro | Sim | Identificador único do registro de hora extra. O sistema valida se o status atual no banco é estritamente `"Pendente de Validação Administrativa"`. |
| **Decisao_Validacao** | Enumerado | Sim | Valores aceitos: `APROVADO` ou `REPROVADO`. |
| **Justificativa_Diretoria** | Texto (Até 500 carac.) | Não | Obrigatório se a `Decisao_Validacao` for igual a `REPROVADO` ou se o parecer violar limites previstos em relatórios de conformidade (`[RF702]`). |
| **Data_Parecer** | Data (AAAA-MM-DD) | Sim | Preenchido automaticamente pelo sistema com a data corrente do servidor. Não permite alteração manual. |

### Fluxo Principal Detalhado
1. O integrante da **Diretoria Operacional** realiza a autenticação segura no SIG-GCM (`[RF101]`).
2. O ator acessa o menu "Painel de Gestão" e seleciona a funcionalidade "Validar Horas Extras" (`[RF502]`).
3. O sistema verifica se o perfil de acesso possui as atribuições explícitas da Diretoria Operacional (`[RF102]`, `[RNF202]`).
4. O sistema renderiza a tela exibindo uma tabela com a fila de registros cujo status seja `"Pendente de Validação Administrativa"`, mostrando a matrícula, nome do servidor, data da execução, horas calculadas e a justificativa operacional inserida pelo supervisor (`[RF501]`).
5. O ator seleciona o registro específico clicando em "Analisar".
6. O sistema exibe o detalhamento completo do plantão e os dados consolidados do servidor.
7. O ator seleciona a opção no campo `Decisao_Validacao` (Aprovado ou Reprovado).
8. Se a opção for "Reprovado", o ator digita formalmente o motivo no campo `Justificativa_Diretoria`.
9. O ator clica no botão "Confirmar Parecer".
10. O sistema intercepta a requisição e valida as regras de negócio em relação ao teto orçamentário e conformidade legal das jornadas (`[RF702]`).
11. O sistema altera o status do registro no banco para `"Homologado"` ou `"Rejeitado Administrativamente"`.
12. O sistema executa de forma transparente o gatilho de auditoria operacional gravando as alterações (`[RF704]`, `[RNF205]`).
13. O interface limpa a tela de análise, atualiza a fila de pendências e exibe uma mensagem de sucesso na interface gráfica (`[RNF301]`).

### Fluxos Alternativos e de Exceção

#### A1 - Dados inválidos
* **10a. Ausência de Justificativa na Reprovação:** Se a `Decisao_Validacao` for configurada como `REPROVADO` e o campo `Justificativa_Diretoria` estiver em branco, o sistema interrompe o processamento, realça o campo de texto em vermelho e exibe a mensagem: `"Erro de validação: O campo Justificativa da Diretoria é obrigatório quando o parecer for de reprovação."`

#### A2 - Acesso não autorizado
* **3a. Usuário sem privilégio administrativo:** Caso um Supervisor de Plantão ou integrante da Equipe Operacional tente invocar o endpoint ou renderizar a tela de validação, o sistema bloqueia o acesso imediatamente, registrando uma tentativa de violação e exibindo a mensagem: `"Acesso Negado: Seu perfil de usuário não possui permissões de escrita para validar administrativamente horas extraordinárias no SIG-GCM."` (`[RNF202]`).

#### A3 - Regra de negócio violada
* **10b. Registro Modificado ou Já Julgado:** Se o registro de hora extra selecionado tiver sido alterado por outro administrador concorrente ou deletado logicamente no intervalo da análise, o sistema impede a conclusão e exibe o alerta: `"Conflito de Concorrência: A hora extra informada já foi processada ou não se encontra mais em estado Pendente."`
* **10c. Violação Orçamentária Municipal:** Se o volume acumulado de horas extras aprovadas para aquela divisão operacional atingir o teto orçamentário mensal parametrizado no sistema (`[RF903]`), o sistema emite um bloqueio de conformidade legal exibindo a mensagem: `"Operação Recusada: Limite orçamentário e de conformidade legal de jornadas excedido para o setor neste mês."` (`[RF702]`).

### Rastreabilidade Restrita
* **[RF502]** - Validação administrativa das horas extras informadas por integrantes da Diretoria Operacional.
* **[RF702]** - Relatórios de validação da conformidade legal e dotação das jornadas dos servidores.
* **[RF704]** - Rastreamento completo de alterações e histórico de dados críticos modificados na plataforma.
* **[RF903]** - Parametrização de regras operacionais gerais e tetos de controle do sistema.
* **[RNF202]** - Implementação de controle de acesso estrito baseado em perfis (RBAC).
* **[RNF205]** - Geração automática de logs detalhados e imutáveis de auditoria de operações financeiras/laborais.

### Logs de Auditoria
A validação de horas extras altera diretamente o fluxo financeiro e o histórico funcional do servidor. Portanto, o sistema grava de forma imutável na tabela `tb_log_operacional` (`[RNF205]`) os seguintes metadados:

```
[TIMESTAMP_UTC] | [ID_USUARIO: ID do Diretor] | [PERFIL: Diretoria Operacional] | [ACAO: VALIDACAO_HORA_EXTRA]
[DADOS: ID_Hora_Extra: W, Servidor_Afetado: X, Decisao: APROVADO/REPROVADO, Impacto_Financeiro: Calculado] | [INTEGRIDADE: HASH_SHA256]
```
