# UC011 - GERAR ESCALAS AUTOMATICAMENTE

# Objetivo 
Gerar escalas com base em efetivo e regime de trabalho.  

# Ator principal 
Diretoria Operacional   

# Pré-condições
- Regimes de trabalho configurados (ex: 12x60, 24x120).  
- Servidores do efetivo devidamente cadastrados e disponíveis no sistema.  
- Cartão Programa Operacional ativo para o período.  

# Pós-condições
- Escalas geradas automaticamente e validadas quanto a conflitos.  
- Log de auditoria registrado para rastreabilidade.  

# Dicionário de Dados da Tela/Ação
- Nome do Campo | Tipo de Dado | Obrigatoriedade | Validação/Regra
- Mês/Ano de Referência | Data (MM/AAAA) | Sim | Deve ser igual ou posterior ao mês/ano corrente (2026). Bloqueia retroativos.
- Regime de Trabalho | Seleção (Dropdown) | Sim | Lista os regimes válidos cadastrados no sistema (12x60, 24x120, etc.).  
- Setor Vinculado | Seleção (Dropdown) | Sim | Filtra os servidores ativos associados ao respectivo setor.  
- Efetivo Mínimo por Plantão | Inteiro | Sim | Deve ser maior que zero e menor ou igual ao efetivo total disponível do setor.
- Cartão Programa Associado | Seleção (Dropdown) | Sim | Lista os Cartões Programas vigentes e aprovados para o período.  

# Fluxo principal
1. O ator acessa a funcionalidade Gerar escalas automaticamente através do painel de operações.  
2.  O sistema apresenta os dados e opções necessárias, renderizando o formulário com os campos de parametrização (Mês/Ano, Regime, Setor, Efetivo Mínimo e Cartão Programa).
3.  O ator informa ou seleciona os dados exigidos na interface e clica em "Executar Geração Automatizada".
4. O sistema valida permissões , dados obrigatórios e regras de negócio aplicáveis.  
5. O sistema executa a operação solicitada, rodando o algoritmo de distribuição que aloca o efetivo ativo desimpedindo quem estiver em gozo de férias ou licenças.  
6. O sistema registra auditoria quando a operação for crítica, gravando os metadados da geração automática nos logs do sistema.  
7. O sistema apresenta mensagem de sucesso ao ator e disponibiliza a grade gerada em modo rascunho.

# Fluxos alternativos e exceções

- A1 - Dados inválidos:
  - Condição: O ator deixa campos obrigatórios em branco ou insere um mês passado.
  - Comportamento: O sistema informa os campos inconsistentes na tela e solicita correção.
  - MENSAGEM EXATA: "Operação Inválida: Todos os campos obrigatórios devem ser preenchidos e o período de referência deve ser igual ou superior ao mês corrente."
- A2 - Acesso não autorizado:
 - Condição: Um usuário sem a atribuição de Diretoria Operacional tenta submeter a requisição.
 - Comportamento: O sistema bloqueia a operação, impede o processamento e informa ausência de permissão.  
 - MENSAGEM EXATA: "Acesso Negado: Seu perfil institucional não possui permissão para executar a geração automatizada de escalas."
- A3 - Regra de negócio violada:
 - Condição: O sistema detecta que o efetivo disponível causará sobreposição de horários ou desrespeitará o descanso do regime (violação da RN001).  
 - Comportamento: O sistema impede a conclusão, aborta a persistência e apresenta justificativa.  
 - MENSAGEM EXATA: "Erro de Consistência: A geração automática foi abortada pois foram detectados conflitos de jornadas ou indisponibilidade de efetivo para o regime selecionado."
- A4 - Regra de negócio violada (Falta de Cartão Programa):
 - Condição: O período selecionado não possui um planejamento do Cartão Programa vigente (violação da RN007).  
 - Comportamento: O sistema impede a geração.
 - MENSAGEM EXATA: "Planejamento Ausente: Não é possível gerar a escala. Vincule um Cartão Programa Operacional válido e aprovado para este período."
 
# Regras de negócio relacionadas
- RN001: Nenhum servidor poderá possuir escalas conflitantes.  
- RN004: Usuários somente poderão acessar funcionalidades autorizadas.  
- RN005: Alterações relevantes deverão gerar logs.  
- RN007: O Cartão Programa deverá ser atualizado conforme demandas operacionais.  

# Critérios de aceitação
- A funcionalidade deve respeitar controle de acesso por perfil (apenas perfis autorizados geram escalas).  
- A operação deve manter rastreabilidade quando alterar dados relevantes (gravação obrigatória de logs).  
- O sistema deve apresentar mensagens claras de sucesso ou erro (conforme mapeado nas mensagens exatas dos fluxos).  
- O sistema não deve permitir, sob nenhuma hipótese, a criação de conflitos de escalas.  

# Logs de Auditoria
- Caso a operação seja concluída com sucesso, os seguintes dados exatos devem ser gravados:
 - id_usuario, nome_usuario, perfil_institucional, data_hora_execucao, acao_executada ("GERACAO_AUTOMATICA"), parametros_filtros (setor_id, regime_id, mes_ano) e quantidade_registros_gerados.  