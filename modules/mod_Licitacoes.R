#### bases da view ----

#### utils ----


#### ui ----

ui_Licitacoes <- function(id, label = "Counter"){
  ns <- NS(id)
  nav_panel(
    title = "Licitações",
    
    fluidPage(
      titlePanel("Gerenciador de Usuários"),
      
      layout_columns(
        fill = T,
        dataTableOutput(ns("data_table"))
      ),
      
      layout_columns(
        fill = T,
      card(
        h4("Adicionar Usuário"),
        textInput(ns("nome"), "Nome:"),
        textInput(ns("app"), "App:"),
        textInput(ns("senha"), "Senha:"),
        textInput(ns("secretaria"), "Secretaria:"),
        textInput(ns("inicio"), "Início:"),
        textInput(ns("expira"), "Expira:"),
        textInput(ns("admin"), "Admin:"),
        textInput(ns("comment"), "Comentário:"),
        actionButton(ns("addUserBtn"), "Adicionar Usuário")
      ),
      
      card(
        h4("Atualizar Usuário"),
        selectizeInput(ns("update_nome"), "Nome do Usuário:", choices = "", selected = ""),
        textInput(ns("update_app"), "App:", value = ""),
        textInput(ns("update_senha"), "Senha:", value = ""),
        textInput(ns("update_secretaria"), "Secretaria:", value = ""),
        textInput(ns("update_inicio"), "Início:", value = ""),
        textInput(ns("update_expira"), "Expira:", value = ""),
        textInput(ns("update_admin"), "Admin:", value = ""),
        textInput(ns("update_comment"), "Comentário:", value = ""),
        actionButton(ns("updateUserBtn"), "Atualizar Usuário"),
        actionButton(ns("removeUserBtn"), "Remover Usuário")
      )
    )
  )
  )
  
} # fecha ui_Resultados

#### servidor ----
server_Licitacoes <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      
      con <- reactiveVal(connect_to_database())
      
      observe({
        query <- "SELECT nome FROM app_usuarios;"
        users <- dbGetQuery(con(), query)$nome
        updateSelectizeInput(session, "update_nome", choices = users, selected = "")
      })
      
      observeEvent(input$update_nome, {
        if (input$update_nome != "") {
          query <- paste0("SELECT * FROM app_usuarios WHERE nome = '", input$update_nome, "';")
          user_data <- dbGetQuery(con(), query)
          if (nrow(user_data) > 0) {
            updateTextInput(session, "update_app", value = user_data$app)
            updateTextInput(session, "update_senha", value = user_data$senha)
            updateTextInput(session, "update_secretaria", value = user_data$secretaria)
            updateTextInput(session, "update_inicio", value = user_data$inicio)
            updateTextInput(session, "update_expira", value = user_data$expira)
            updateTextInput(session, "update_admin", value = user_data$admin)
            updateTextInput(session, "update_comment", value = user_data$comment)
          }
        } else {
          clearUpdateInputs(session)
        }
      })
      
      observeEvent(input$removeUserBtn, {
        if (input$update_nome != "") {
          deleteUsuario(input$update_nome)
          refreshUsers(session)
          clearInputs(session)
          invalidateLater(1000)  # Atualizar tabela após 1 segundo
        }
      })
      
      observeEvent(input$addUserBtn, {
        if (!usuarioExists(input$nome)) {
          addUser(input)
          refreshUsers(session)
          clearInputs(session)
          invalidateLater(1000)  # Atualizar tabela após 1 segundo
        } else {
          showModal(modalDialog(
            title = "Erro",
            "O nome de usuário já existe na base de dados.",
            footer = modalButton("Fechar"),
            easyClose = TRUE,
            fade = TRUE
          ))
        }
      })
      
      observeEvent(input$updateUserBtn, {
        updateUser(input)
        clearInputs(session)
        invalidateLater(1000)  # Atualizar tabela após 1 segundo
      })
      
      all_user_data <- reactiveVal({
        query <- "SELECT * FROM app_usuarios;"
        dbGetQuery(con(), query)
      })
      
      output$data_table <- renderDataTable({
        datatable(all_user_data(), options = list(pageLength = 5))
      })
      
      # Função para limpar os inputs de atualização
      clearUpdateInputs <- function(session) {
        updateTextInput(session, "update_app", value = "")
        updateTextInput(session, "update_senha", value = "")
        updateTextInput(session, "update_secretaria", value = "")
        updateTextInput(session, "update_inicio", value = "")
        updateTextInput(session, "update_expira", value = "")
        updateTextInput(session, "update_admin", value = "")
        updateTextInput(session, "update_comment", value = "")
      }
      
      # Função para deletar usuário
      deleteUsuario <- function(nome) {
        dbBegin(con(), immediate = TRUE)
        query <- paste0("DELETE FROM app_usuarios WHERE nome = '", nome, "';")
        dbExecute(con(), query)
        dbCommit(con())
      }
      
      # Função para verificar se o usuário já existe
      usuarioExists <- function(nome) {
        count <- dbGetQuery(con(), paste0("SELECT COUNT(*) FROM app_usuarios WHERE nome = '", nome, "';"))[[1]]
        return(count > 0)
      }
      
      # Função para adicionar usuário
      addUser <- function(input) {
        dbBegin(con(), immediate = TRUE)
        query <- paste0(
          "INSERT INTO app_usuarios (nome, app, senha, secretaria, inicio, expira, admin, comment) VALUES ('",
          input$nome, "', '",
          input$app, "', '",
          input$senha, "', '",
          input$secretaria, "', '",
          input$inicio, "', '",
          input$expira, "', '",
          input$admin, "', '",
          input$comment, "');"
        )
        dbExecute(con(), query)
        dbCommit(con())
      }
      
      # Função para atualizar usuário
      updateUser <- function(input) {
        dbBegin(con(), immediate = TRUE)
        query <- paste0(
          "UPDATE app_usuarios SET ",
          "app = '", input$update_app, "', ",
          "senha = '", input$update_senha, "', ",
          "secretaria = '", input$update_secretaria, "', ",
          "inicio = '", input$update_inicio, "', ",
          "expira = '", input$update_expira, "', ",
          "admin = '", input$update_admin, "', ",
          "comment = '", input$update_comment, "' ",
          "WHERE nome = '", input$update_nome, "';"
        )
        dbExecute(con(), query)
        dbCommit(con())
      }
      
      # Função para atualizar a lista de usuários
      refreshUsers <- function(session) {
        query <- "SELECT nome FROM app_usuarios;"
        users <- dbGetQuery(con(), query)$nome
        updateSelectizeInput(session, "update_nome", choices = users, selected = "")
      }
      
      # Função para limpar todos os inputs
      clearInputs <- function(session) {
        updateTextInput(session, "nome", value = "")
        updateTextInput(session, "app", value = "")
        updateTextInput(session, "senha", value = "")
        updateTextInput(session, "secretaria", value = "")
        updateTextInput(session, "inicio", value = "")
        updateTextInput(session, "expira", value = "")
        updateTextInput(session, "admin", value = "")
        updateTextInput(session, "comment", value = "")
      }
    }
  )
}



