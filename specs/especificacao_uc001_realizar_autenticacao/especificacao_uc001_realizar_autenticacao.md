# UC001 - Realizar Autenticação

## Informações Gerais

| Item | Descrição |
|------|-----------|
| Código | UC001 |
| Nome | Realizar Autenticação |
| Objetivo | Permitir que um usuário autenticado acesse o SIG-GCM conforme seu perfil institucional. |
| Atores | Usuário do Sistema |
| Prioridade | Alta |
| Frequência de Uso | Diária |
| Pré-condições | Usuário cadastrado e ativo. |
| Pós-condições | Sessão autenticada criada e usuário redirecionado ao Dashboard. |

---

# Requisitos Relacionados

## Requisitos Funcionais

- RF001
- RF002
- RF003
- RF004
- RF005
- RF006
- RF007

## Regras de Negócio

- RN001
- RN002
- RN003
- RN004
- RN005
- RN006
- RN007
- RN008
- RN009

## Critérios de Aceitação

- CA01
- CA02
- CA03
- CA04
- CA05

---

# Dicionário de Dados

| Campo | Tipo | Obrigatório | Validação |
|-------|------|-------------|-----------|
| Login | Texto | Sim | Deve existir usuário ativo cadastrado. |
| Senha | Password | Sim | Deve corresponder ao hash armazenado. |

---

# Fluxo Principal

## FP01
O usuário acessa a página de autenticação.

### Resultado esperado

O sistema verifica se existe sessão ativa.

---

## FP02

O sistema renderiza a tela contendo:

- Campo Login
- Campo Senha
- Botão Entrar
- Link Esqueci minha senha

---

## FP03

O usuário informa Login e Senha.

---

## FP04

O sistema valida:

- Campos obrigatórios;
- Existência do usuário;
- Situação cadastral;
- Senha;
- Perfil institucional.

---

## FP05

O sistema cria:

- Sessão autenticada;
- Token de sessão;
- Contexto do usuário.

---

## FP06

O sistema registra auditoria.

---

## FP07

O sistema redireciona para o Dashboard.

Mensagem:

> Autenticação realizada com sucesso.

---

# Fluxos Alternativos

## FA01 — Campo obrigatório

**Condição**

Login ou senha não informado.

**Mensagem**

> Login e senha são obrigatórios.

**Retorno**

Retorna ao FP03.

---

## FA02 — Usuário inexistente

**Mensagem**

> Usuário ou senha inválidos.

---

## FA03 — Senha incorreta

**Mensagem**

> Usuário ou senha inválidos.

---

## FA04 — Usuário bloqueado

**Mensagem**

> Seu usuário está bloqueado. Entre em contato com o administrador do sistema.

---

## FA05 — Usuário inativo

**Mensagem**

> Usuário inativo. Acesso não permitido.

---

## FA06 — Sem permissão

**Mensagem**

> Você não possui permissão para acessar este recurso.

---

## FA07 — Regra de negócio

**Mensagem**

> A autenticação não pôde ser concluída devido às regras de segurança da instituição.

---

## FA08 — Erro interno

**Mensagem**

> Não foi possível realizar a autenticação no momento. Tente novamente mais tarde.

---

# Logs de Auditoria

| Campo | Valor Gravado |
|--------|---------------|
| EventId | UUID |
| DataHora | Timestamp |
| Usuário | Login |
| IdUsuário | ID interno |
| Perfil | Perfil institucional |
| Resultado | Sucesso/Falha |
| Motivo | Descrição da falha |
| IP | IPv4/IPv6 |
| Navegador | User Agent |
| Sistema Operacional | SO do cliente |
| SessionId | UUID |
| Token | Identificador do Token |
| Módulo | Dashboard |
| Host | Nome da estação |

---

# Regras de Validação

- Login obrigatório.
- Senha obrigatória.
- Usuário deve estar ativo.
- Usuário não pode estar bloqueado.
- Senha deve corresponder ao hash armazenado.
- O perfil deve possuir permissão para acesso.

---

# Resultado Esperado

O usuário acessa somente os módulos autorizados conforme seu perfil institucional e todas as operações de autenticação ficam registradas para auditoria.