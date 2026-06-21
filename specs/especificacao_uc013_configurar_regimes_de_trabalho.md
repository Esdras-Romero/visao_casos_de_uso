# UC013 - Configurar regimes de trabalho

## Objetivo
Configurar regimes 12x60, 24x120 e personalizados.

## Ator principal
Administrador Operacional

## Pré-condições
- Administrador operacional autenticado.

## Pós-condições
- Regime salvo e disponível para escalas.

## Fluxo principal
1. O ator acessa a funcionalidade **Configurar regimes de trabalho**.
2. O sistema apresenta os dados e opções necessárias.
3. O ator informa ou seleciona os dados exigidos.
4. O sistema valida permissões, dados obrigatórios e regras de negócio aplicáveis.
5. O sistema executa a operação solicitada.
6. O sistema registra auditoria quando a operação for crítica.
7. O sistema apresenta mensagem de sucesso ao ator.

## Fluxos alternativos e exceções
- **A1 - Dados inválidos:** o sistema informa os campos inconsistentes e solicita correção.
- **A2 - Acesso não autorizado:** o sistema bloqueia a operação e informa ausência de permissão.
- **A3 - Regra de negócio violada:** o sistema impede a conclusão e apresenta justificativa.

## Regras de negócio relacionadas
- RN001 a RN009, conforme aplicável ao módulo.

## Critérios de aceitação
- A funcionalidade deve respeitar controle de acesso por perfil.
- A operação deve manter rastreabilidade quando alterar dados relevantes.
- O sistema deve apresentar mensagens claras de sucesso ou erro.
