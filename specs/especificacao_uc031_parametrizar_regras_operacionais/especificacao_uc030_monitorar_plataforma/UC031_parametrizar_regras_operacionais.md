# UC031 - Parametrizar regras operacionais

## Objetivo
Configurar, validar e versionar as variáveis de ambiente e regras de negócio globais que regem o comportamento operacional do SIG-GCM, como limites de tolerância de atraso, regras de acionamento de plantão, raio de cerca eletrônica (geofencing) e níveis de criticidade de ocorrências.

## Ator Principal
Administrador do Sistema

## Pré-condições
- Usuário devidamente autenticado com papel de alta administração (SysAdmin).
- Sessão ativa estabelecida sob conexão segura HTTPS.

## Pós-condições
- Parâmetros operacionais modificados, validados, gravados com número de versão sequencial no banco de dados e aplicados em tempo real às rotinas do sistema.

## Dicionário de Dados da Tela/Ação

| Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra |
| :--- | :--- | :--- | :--- |
| **Limite_Tolerancia_Minutos** | Inteiro | Sim | Margem aceitável para atrasos em postos de serviço. Deve estar entre `0` e `60`. |
| **Raio_Geofencing_Metros** | Inteiro | Sim | Raio de tolerância para o check-in do guarda via GPS. Deve estar entre `10` e `500`. |
| **Severidade_Notificacao_Automatica** | Enumerado | Sim | Nível mínimo para disparar push automático ao comando. Valores: `BAIXA`, `MEDIA`, `ALTA`, `CRITICA`. |
| **Justificativa_Alteracao** | Texto (250) | Sim | Texto explicativo do porquê a regra de negócio do sistema está sendo alterada. |

## Fluxo principal
1. O Administrador do Sistema realiza o login de alta segurança exigindo o segundo fator de autenticação (MFA).
2. O ator navega até o painel de configurações avançadas do sistema e seleciona a opção **Parametrizar regras operacionais**.
3. O sistema renderiza a interface de controle exibindo os campos numéricos de tolerância, seletores de nível de severidade, histórico de versões vigentes e um campo em branco para justificativa.
4. O ator altera o valor de `Limite_Tolerancia_Minutos`, ajusta o `Raio_Geofencing_Metros`, redefine a `Severidade_Notificacao_Automatica` e insere o texto explicativo em `Justificativa_Alteracao`.
5. O ator aciona o comando "Salvar e Aplicar Novas Regras".
6. O sistema intercepta a requisição e valida se o token de sessão do usuário possui a flag estrita de escrita de configurações globais (SysAdmin).
7. O sistema valida se os dados informados cumprem as restrições físicas de intervalos numéricos e se o campo de justificativa possui conteúdo válido.
8. O sistema incrementa o número da versão da regra (`versao_atual + 1`), monta o payload de histórico e persiste as novas diretrizes na tabela de parâmetros (`tb_sys_parameters`).
9. O sistema grava um registro imutável com a assinatura da alteração, a justificativa fornecida e o estado anterior dos dados na tabela física de auditoria de regras.
10. O sistema limpa o cache interno de aplicação para que as novas diretrizes passem a valer imediatamente no motor de regras de negócio e exibe a mensagem de sucesso: `"Parâmetros operacionais atualizados com sucesso! Nova versão [V_X] aplicada globalmente."`

## Fluxo alternativos e exceções

### A1 - Dados inválidos
* **7a. Parâmetros Fora dos Limites Operacionais:** Se o operador preencher o campo `Raio_Geofencing_Metros` com um valor fora do intervalo homologado (ex: 5 metros ou 600 metros), o sistema suspende a gravação, destaca o campo em vermelho e exibe: `"Erro de Validação: O raio de geofencing configurado está fora do limite permitido (10 a 500 metros). Corrija o valor para avançar."`
* **7b. Justificativa Ausente:** Se o campo `Justificativa_Alteracao` for deixado em branco, o sistema impede a submissão e apresenta o aviso: `"Erro de Preenchimento: É obrigatório descrever uma justificativa técnica ou administrativa para fins de auditoria antes de alterar as regras operacionais."`

### A2 - Acesso não autorizado
* **6a. Bloqueio por Insuficiência de Papel (RBAC):** Se um usuário com o papel de Setor de RH ou Supervisor de Operações tentar enviar uma requisição direta para salvar dados neste endpoint, o gateway de segurança bloqueia o tráfego e exibe: `"Acesso Negado: A alteração de variáveis estruturais e regras de negócio do SIG-GCM é restrita ao perfil de Administrador do Sistema."`

### A3 - Regra de negócio violada
* **8a. Conflito de Versionamento Concorrente:** Se dois administradores estiverem com a tela aberta ao mesmo tempo e tentarem salvar alterações simultâneas, o sistema detecta que a versão base da memória divergiu da versão gravada no banco (Optimistic Locking Exception), desfaz a operação e exibe: `"Operação Recusada: Os parâmetros foram modificados por outro administrador enquanto você editava esta página. Recarregue a tela e tente novamente."`

## Regras de negócio relacionadas
* **RN002 (Versionamento Compulsório):** Nenhuma regra operacional mestre pode ser sobrescrita sem que seu estado anterior seja guardado em tabela de histórico com data, hora, autor e versão incrementada.
* **RN003 (Persistência Transacional Estrita):** A atualização de parâmetros exige consistência ACID total; qualquer falha na escrita de uma variável deve disparar o Rollback automático de todo o lote modificado.

## Critérios de aceitação
* A interface de parametrização deve fornecer um botão de "Restaurar Padrões de Fábrica", exigindo nova confirmação do administrador antes do reset.
* Os novos limites de minutos e metros devem ser injetados em memória RAM de aplicação (Cache Redis ou similar) de forma assíncrona, garantindo latência menor que 100ms para o usuário final que faz o check-in.
* A trilha de auditoria deve salvar os dados antigos e novos em formato estruturado (JSON B).

## Logs de auditoria
Sendo a configuração mestre de comportamento do software, toda alteração sem exceção persiste dados detalhados na tabela `tb_audit_sys_rules`:

[TIMESTAMP_UTC] | [USER_ID: ID_SysAdmin] | [ROLE: SysAdmin] | [RULE_VERSION: Versao_Nova]
[MODIFIED_PARAMS: JSON_Campos_Alterados] | [PREVIOUS_STATE: JSON_Estado_Anterior] | [JUSTIFICATION: Justificativa_Alteracao]

## Rastreabilidade Restrita
* **[RF712]** - Painel administrativo de controle de diretrizes, variáveis globais e motores de regras.
* **[RNF202]** - Controle estrito de acesso baseado em papéis de alta granularidade (RBAC).
* **[RNF205]** - Geração compulsória de logs e trilhas de auditoria para alteração de regras do negócio.