# UC030 - Monitorar plataforma

## Objetivo
Acompanhar em tempo real os indicadores de desempenho físico, disponibilidade de microsserviços, volumetria de erros de aplicação e picos de tráfego de usuários no ecossistema SIG-GCM, provendo subsídios visuais para engenharia de infraestrutura e prevenção de indisponibilidades.

## Ator Principal
Administrador do Sistema

## Pré-condições
- Instância do sistema operacional e barramento de telemetria ativos.
- Usuário devidamente autenticado com credenciais de administração de infraestrutura (SysAdmin).

## Pós-condições
- Painel de telemetria, consumo de CPU/Memória, latência de banco de dados e gráficos de vazão de requisições carregados e atualizados dinamicamente na interface.

## Dicionário de Dados da Tela/Ação

| Nome do Campo | Tipo de Dado | Obrigatoriedade (Sim/Não) | Validação/Regra |
| :--- | :--- | :--- | :--- |
| **Janela_Tempo** | Enumerado | Sim | Intervalo de retrocesso dos gráficos. Valores: `ULTIMOS_15_MIN`, `ULTIMA_1_HORA`, `ULTIMAS_24_HORAS`. |
| **Metrica_Alvo** | Enumerado | Não | Isola um vetor específico. Valores: `USO_CPU_RAM`, `LATENCIA_SQL`, `TAXA_ERROS_HTTP`, `TODAS`. Padrão: TODAS. |
| **Frequencia_Refresh**| Inteiro | Sim | Tempo de atualização automática da tela em segundos. Valores válidos: `5`, `10`, `30`, `60`. Padrão: 5. |

## Fluxo principal
1. O Administrador do Sistema realiza o login de alta segurança com múltiplos fatores de autenticação (MFA).
2. O ator acessa o painel de gerenciamento de infraestrutura e seleciona a funcionalidade **Monitorar plataforma**.
3. O sistema renderiza o dashboard de monitoramento injetando os seletores de intervalo de tempo, frequências de atualização e blocos vazios aguardando a transmissão assíncrona.
4. O ator configura a Janela_Tempo de análise, seleciona a Metrica_Alvo desejada e fixa a Frequencia_Refresh em 5 segundos.
5. O ator aciona o comando "Ativar Monitoramento Contínuo".
6. O sistema valida as permissões de token do usuário para certificar privilégios estritos de leitura de infraestrutura.
7. O sistema abre um canal de comunicação de baixa latência (WebSocket) com o agente interno de coleta de telemetria do servidor.
8. O sistema realiza a leitura contínua dos contadores do processador, consumo de memória volátil, pool de conexões do banco de dados e logs de requisições web.
9. O sistema atualiza dinamicamente as curvas de desempenho, gauges de saturação e taxas de requisição por segundo em tela na interface gráfica.
10. O sistema exibe um indicador de status de conexão ativa ("Live Telemetry") no topo do painel principal de monitoramento.

## Fluxo alternativos e exceções

### A1 - Dados inválidos
* **4a. Parâmetro de Atualização Fora do Limite:** Se o valor enviado no campo `Frequencia_Refresh` for modificado via console ou requisição maliciosa para um valor menor que 5 segundos (causando sobrecarga de pooling), o sistema rejeita a alteração e exibe: `"Erro de Parâmetro: A frequência de amostragem definida é inválida ou inferior ao limite mínimo de segurança estabelecido."`

### A2 - Acesso não autorizado
* **6a. Bloqueio por Insuficiência de Escopo (RBAC):** Se um usuário com perfil administrativo institucional padrão tentar acessar a rota do painel de monitoramento de baixo nível, o sistema aborta a renderização e apresenta a mensagem de erro: `"Acesso Negado: A visualização de telemetria estrutural e métricas de servidores é exclusiva para o perfil de Administrador do Sistema."`

### A3 - Regra de negócio violada
* **7a. Perda de Conectividade com o Agente de Telemetria:** Se o serviço centralizador de métricas da aplicação cair ou parar de reportar as informações para o painel de controle, o sistema interrompe o desenho dos gráficos, aciona um alarme visual sonoro local e exibe: `"Falha de Monitoramento: Interrupção na coleta de telemetria. Não foi possível estabelecer conexão com o daemon de monitoramento do sistema."`

## Regras de negócio relacionadas
* **RN004 (Saturação Crítica):** Sempre que a taxa de uso de hardware ultrapassar o limite crítico de 92% por mais de 3 minutos consecutivos, o sistema deve acionar alertas push automáticos para os administradores.
* **RN005 (Retenção de Métricas):** As métricas de telemetria bruta em alta definição de amostragem devem ser compactadas e descartadas após 7 dias de armazenamento para evitar o esgotamento do disco rígido do servidor.

## Critérios de aceitação
* Os gráficos de linha e barras devem utilizar componentes leves que não causem vazamento de memória (Memory Leak) no navegador do administrador após horas de tela aberta.
* O atraso na renderização de um dado gerado no servidor até a tela de monitoramento não pode passar do tempo limite tolerável de 2 segundos.
* Toda falha catastrófica observada em serviços core da aplicação (ex: queda total da conexão do banco de dados) deve disparar interrupção de tela com modal de emergência.

## Logs de auditoria
Por tratar-se de uma funcionalidade de leitura contínua e passiva de infraestrutura, o sistema realiza a gravação do log estrito na tabela `tb_sys_monitor_access` apenas na entrada e saída do painel, omitindo as atualizações síncronas de 5 segundos para fins de economia de armazenamento:

[TIMESTAMP_UTC] | [USER_ID: ID_SysAdmin] | [ROLE: SysAdmin] | [DASHBOARD: INFRA_TELEMETRY]
[WINDOW_SELECTION: Janela_Tempo] | [ACTION: VIEW_START/VIEW_STOP] | [INTEGRITY_HASH: SHA256]

## Rastreabilidade Restrita
* **[RF704]** - Ferramentas de infraestrutura de dados, logs operacionais e controle de hardware.
* **[RNF202]** - Controle estrito de acesso baseado em papéis de alta granularidade (RBAC).
* **[RNF205]** - Geração de logs e trilhas de auditoria operacional para acesso a dados do servidor.