# UC003 - Recuperar Senha

## Objetivo
Permitir que um usuário recupere sua senha utilizando o e-mail institucional cadastrado no SIG-GCM.

## Atores
- Usuário do Sistema

## Pré-condições
- O usuário possui cadastro ativo.
- Existe um e-mail institucional vinculado ao usuário.
- O serviço de envio de e-mails está disponível.

## Pós-condições
- Um token temporário de recuperação é gerado.
- Um e-mail contendo o link de recuperação é enviado ao endereço institucional.
- A operação é registrada em auditoria.

---

# Artefato 1 — Detalhamento Técnico

## Dicionário de Dados

| Campo | Tipo | Obrigatório | Validação / Regra |
|--------|------|-------------|-------------------|
| E-mail Institucional | E-mail | Sim | Deve existir na base de usuários ativos |
| Botão Recuperar Senha | Ação | Sim | Executa validações antes do envio |
| Botão Cancelar | Ação | Não | Retorna para tela de Login |

---

## Fluxo Principal Detalhado

### Passo 1
O usuário acessa a tela **Recuperar Senha**.

### Passo 2
O sistema renderiza os seguintes componentes:

- Campo E-mail Institucional
- Botão Recuperar Senha
- Botão Cancelar

### Passo 3
O usuário informa o e-mail institucional.

### Passo 4
O sistema valida:

- preenchimento obrigatório;
- formato do e-mail;
- existência do usuário;
- situação do usuário (ativo);
- existência de e-mail institucional cadastrado.

### Passo 5
Caso todas as validações sejam satisfeitas:

- gera token único;
- define validade de 30 minutos;
- grava o token;
- envia e-mail institucional.

### Passo 6
O sistema registra auditoria.

### Passo 7
O sistema apresenta:

> Solicitação de recuperação enviada com sucesso. Caso o e-mail informado esteja cadastrado, verifique sua caixa de entrada.

---

## Fluxos Alternativos

### A1 — Campo obrigatório

**Condição**

Campo E-mail vazio.

**Mensagem**
O campo "E-mail Institucional" é obrigatório.

---

### A2 — Formato inválido

**Mensagem**
Informe um endereço de e-mail válido.

---

### A3 — Usuário inexistente

**Mensagem**
Não foi possível processar a solicitação de recuperação de senha.

> (Mensagem genérica por motivos de segurança.)

---

### A4 — Usuário bloqueado

**Mensagem**
Sua conta encontra-se bloqueada. Entre em contato com o administrador do sistema.

---

### A5 — Serviço de e-mail indisponível

**Mensagem**
Não foi possível enviar o e-mail de recuperação. Tente novamente mais tarde.

---

## Rastreabilidade

### Requisitos Funcionais

- RF001
- RF003
- RF004

### Regras de Negócio

- RN001
- RN002
- RN004
- RN006

### Requisitos Não Funcionais

- RNF001 Segurança
- RNF003 Auditoria
- RNF005 Disponibilidade

### Critérios de Aceitação

- CA001
- CA002
- CA003

---

## Logs de Auditoria

Registrar:

- Data/Hora
- Usuário informado
- IP de origem
- Navegador
- Sessão
- Operação = RECUPERAR_SENHA
- Resultado (Sucesso/Falha)
- Motivo da falha (quando existir)

---

# Artefato 2 — Diagrama de Sequência

```plantuml
@startuml
...
@enduml