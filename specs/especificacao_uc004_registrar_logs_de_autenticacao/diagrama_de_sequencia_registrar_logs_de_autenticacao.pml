@startuml

actor Administrador
boundary "Tela de Login" as Tela
control "Serviço de Autenticação" as Auth
control "Serviço de Auditoria" as Audit
database "Banco de Dados" as DB

Administrador -> Tela : Informar login e senha
Tela -> Auth : Solicitar autenticação
Auth -> DB : Validar credenciais

alt Credenciais válidas

    DB --> Auth : Usuário autenticado

    Auth -> Audit : Registrar evento LOGIN
    Audit -> DB : Persistir log

    DB --> Audit : Log gravado

    Auth --> Tela : Autenticação realizada
    Tela --> Administrador : Acesso concedido

    Administrador -> Tela : Solicitar Logout
    Tela -> Auth : Encerrar sessão
    Auth -> Audit : Registrar evento LOGOUT
    Audit -> DB : Atualizar log da sessão
    DB --> Audit : Log atualizado
    Auth --> Tela : Sessão encerrada
    Tela --> Administrador : Logout realizado

else Credenciais inválidas

    DB --> Auth : Falha
    Auth -> Audit : Registrar tentativa inválida
    Audit -> DB : Persistir log
    Auth --> Tela : Erro de autenticação
    Tela --> Administrador : Usuário ou senha inválidos

else Erro ao registrar auditoria

    Audit --> Auth : Falha
    Auth --> Tela : Não foi possível registrar o evento de auditoria

end

@enduml