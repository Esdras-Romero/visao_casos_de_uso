# UC024 - Validar conformidade legal

## Objetivo
Validar de forma automatizada a conformidade legal das jornadas de trabalho e plantões executados pelo efetivo da Guarda Civil Municipal, identificando quebras de regras trabalhistas, limites de horas extras e períodos de descanso obrigatórios.

## Ator Principal
Administrador Institucional

## Pré-condições
- Regras e parâmetros de jornada (limite diário, semanal e interstício mínimo) previamente cadastrados no sistema.
- Espelhos de ponto e registros de jornadas efetivas preenchidos para o período selecionado.

## Pós-condições
- Conformidade das jornadas validada, status atualizado no banco de dados e inconsistências detectadas sinalizadas no painel gerencial.

## Dicionário de Dados da Tela/Ação
| Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra |
| :--- | :--- | :--- | :--- |
| **Mes_Referencia** | Enumerado | Sim | Seleção do mês a ser auditado (Janeiro a Dezembro). |
| **Ano_Referencia** | Inteiro | Sim | Ano a ser auditado. Deve ser menor ou igual ao ano corrente (2026). |
| **ID_Grupo_Efetivo**| Inteiro | Não | Filtro por agrupamento específico de guardas. Se nulo, valida todo o efetivo municipal. |
| **Ignorar_Alertas_Leves**| Booleano | Sim | Flag indicando se inconsistências informativas barram o processo. Padrão: Não. |

## Fluxo principal
1. O Administrador Institucional realiza a autenticação segura no ecossistema SIG-GCM.
2. O ator acessa o painel de gerenciamento de faturamento e auditoria de pessoal e seleciona a opção **Validar conformidade legal**.
3. O sistema renderiza a interface apresentando os seletores de período (Mês/Ano), filtros de grupos do efetivo e o histórico do motor de processamento.
4. O ator informa o Mês_Referencia, o Ano_Referencia e define o escopo do Grupo de Efetivo aplicável.
5. O ator aciona o comando "Executar Validação de Conformidade".
6. O sistema valida as credenciais de segurança e o perfil do ator para certificar permissão total de escrita no módulo corporativo.
7. O sistema invoca o motor automático de regras operacionais, cruzando os dados da tabela de jornadas com as diretrizes de descanso mínimo e carga horária limite.
8. O sistema atualiza o status dos lançamentos avaliados na base de dados e compila o mapa de inconsistências temporais.
9. O sistema registra de maneira permanente e imutável a execução crítica da rotina automática na trilha de logs de auditoria.
10. O sistema apresenta em tela uma caixa de diálogo informativa contendo a mensagem de sucesso: "Validação de conformidade concluída com sucesso! Nenhuma inconsistência impeditiva encontrada."

## Fluxo alternativos e exceções
### A1 - Dados inválidos
* **4a. Período Futuro Detectado:** Se o `Ano_Referencia` for preenchido com um valor superior ao ano vigente do sistema (2026), o sistema interrompe a requisição e apresenta em tela a mensagem de erro: "Erro de Parâmetro: O ano de referência informado não pode ser superior ao ano vigente do sistema."

### A2 - Acesso não autorizado
* **6a. Falha na Autenticação de Perfil (RBAC):** Se um usuário autenticado com perfil Operacional ou do Setor de RH tentar invocar o endpoint controlador do motor de validação legal, o sistema bloqueia a execução da rotina, gera um log de tentativa de invasão e renderiza na tela a mensagem de erro: "Acesso Negado: A execução da validação automatizada de conformidade legal é restrita ao perfil de Administrador Institucional."

### A3 - Regra de negócio violada
* **7a. Inconsistência Crítica Encontrada:** Se o motor automático detectar quebras gravíssimas de regulamento (ex: guarda escalado sem cumprir o interstício de descanso mínimo de 11 horas entre plantões), o sistema suspende a homologação em lote dos pontos e renderiza na tela a mensagem informativa: "Operação Suspensa: Foram identificadas violações críticas de conformidade legal no período selecionado. Verifique os alertas detalhados."

## Regras de negócio relacionadas
* **RN001 (Limite de Horas Diárias):** Nenhum servidor da GCM pode ultrapassar o limite estabelecido de horas de serviço ativo por ciclo de 24 horas.
* **RN002 (Interstício Mínimo de Descanso):** Deve ser garantido o intervalo mínimo obrigatório de descanso contínuo entre o término de um plantão e o início de outra jornada na escala.
* **RN003 (Concorrência de Lotação):** É proibida a sobreposição de horários de trabalho para o mesmo CPF em frentes de patrulhamento distintas.

## Critérios de aceitação
* A rotina só pode ser disparada por usuários pertencentes ao perfil estrutural de Administrador Institucional.
* Toda execução do motor automatizado deve deixar rastro histórico inalterável contendo os parâmetros de entrada e a volumetria de falhas capturadas.
* O sistema deve exibir alertas visuais categorizados em tela por gravidade (Leve/Crítico) após o processamento.

## Logs de auditoria
Sendo uma operação de controle massivo com impacto direto na folha de dotação e conformidade jurídica do município, o sistema grava na tabela `tb_audit_compliance`:
* **[TIMESTAMP_UTC]**  
* **[ID_USER: ID do Administrador]** 
* **[PERFIL: Admin_Institucional]**  
* **[ROUTINE: COMPLIANCE_ENGINE_EXEC]**
* **[FILTERS: Mês X, Ano Y, Grupo Z]**  
* **[METRICS: Processados: N, Sucesso: S, Inconsistências: I]** 
* **[HASH: SHA256_VERIFICATION]**

## Rastreabilidade Restrita
* **[RF702]** - Relatórios e processamento emitidos para validação da conformidade legal e dotação das jornadas.
* **[RNF202]** - Controle de acesso rigoroso baseado em papéis (RBAC).
* **[RNF205]** - Geração compulsória de logs imutáveis de auditoria operacional do sistema.