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
server_Licitacoes <- function(id){
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
          updateTextInput(session, "update_app", value = "")
          updateTextInput(session, "update_senha", value = "")
          updateTextInput(session, "update_secretaria", value = "")
          updateTextInput(session, "update_inicio", value = "")
          updateTextInput(session, "update_expira", value = "")
          updateTextInput(session, "update_admin", value = "")
          updateTextInput(session, "update_comment", value = "")
        }
      })
      
      observeEvent(input$removeUserBtn, {
        if (input$update_nome != "") {
          dbBegin(con(), immediate = TRUE)
          query <- paste0("DELETE FROM app_usuarios WHERE nome = '", input$update_nome, "';")
          dbExecute(con(), query)
          dbCommit(con())
          
          query <- "SELECT nome FROM app_usuarios;"
          users <- dbGetQuery(con(), query)$nome
          updateSelectizeInput(session, "update_nome", choices = users, selected = "")
        }
      })
      
      observeEvent(input$addUserBtn, {
        user_exists <- dbGetQuery(con(), paste0("SELECT COUNT(*) FROM app_usuarios WHERE nome = '", input$nome, "';"))[[1]]
        if (user_exists == 0) {
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

          query <- "SELECT nome FROM app_usuarios;"
          users <- dbGetQuery(con(), query)$nome
          updateSelectizeInput(session, "update_nome", choices = users, selected = "")
        } else {
         
          showModal(modalDialog(
            title = "Erro",
            "O nome de usuário já existe na base de dados.",
            footer = modalButton("Fechar"),
            easyClose = T,
            fade = T
          ))
        }
      })
      
      observeEvent(input$updateUserBtn, {
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
      })
      
      all_user_data <- reactive({
        query <- "SELECT * FROM app_usuarios;"
        dbGetQuery(con(), query)
      })
      
      output$data_table <- renderDataTable({
        datatable(all_user_data(), options = list(pageLength = 5))
      })
           
    } # fecha sessão
  ) # fecha moduleServer
} # fecha server
