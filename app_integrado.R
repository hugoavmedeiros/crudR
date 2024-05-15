library(shiny)
library(DBI)

# Função para conectar ao banco de dados SQLite
connect_to_database <- function() {
  con <- dbConnect(RSQLite::SQLite(), "usuarios.db")
  # Cria a tabela se ela não existir
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS app_usuarios (
      id INTEGER PRIMARY KEY,
      nome TEXT,
      app TEXT,
      senha TEXT,
      secretaria TEXT,
      inicio TEXT,
      expira TEXT,
      admin TEXT,
      comment TEXT
    )
  ")
  return(con)
}

# Módulo de atualização de usuário
updateUserModuleUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectizeInput(ns("update_nome"), "Nome do Usuário:", choices = "", selected = ""),
    textInput(ns("update_app"), "App:", value = ""),
    textInput(ns("update_senha"), "Senha:", value = ""),
    textInput(ns("update_secretaria"), "Secretaria:", value = ""),
    textInput(ns("update_inicio"), "Início:", value = ""),
    textInput(ns("update_expira"), "Expira:", value = ""),
    textInput(ns("update_admin"), "Admin:", value = ""),
    textInput(ns("update_comment"), "Comentário:", value = ""),
    actionButton(ns("updateUserBtn"), "Atualizar Usuário")
  )
}

updateUserModule <- function(input, output, session, con) {
  observe({
    query <- "SELECT nome FROM app_usuarios;"
    users <- dbGetQuery(con(), query)$nome
    updateSelectizeInput(session, "update_nome", choices = users, selected = "")
  })
  
  observeEvent(input$updateUserBtn, {
    if (input$update_nome != "") {
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
  })
}

# Módulo de adição de usuário
addUserModuleUI <- function(id) {
  ns <- NS(id)
  tagList(
    textInput(ns("add_nome"), "Nome:", value = ""),
    textInput(ns("add_app"), "App:", value = ""),
    textInput(ns("add_senha"), "Senha:", value = ""),
    textInput(ns("add_secretaria"), "Secretaria:", value = ""),
    textInput(ns("add_inicio"), "Início:", value = ""),
    textInput(ns("add_expira"), "Expira:", value = ""),
    textInput(ns("add_admin"), "Admin:", value = ""),
    textInput(ns("add_comment"), "Comentário:", value = ""),
    actionButton(ns("addUserBtn"), "Adicionar Usuário"),
    actionButton(ns("removeUserBtn"), "Remover Usuário")
  )
}

addUserModule <- function(input, output, session, con) {
  observeEvent(input$addUserBtn, {
    dbBegin(con(), immediate = TRUE)
    query <- paste0(
      "INSERT INTO app_usuarios (nome, app, senha, secretaria, inicio, expira, admin, comment) VALUES ('",
      input$add_nome, "', '",
      input$add_app, "', '",
      input$add_senha, "', '",
      input$add_secretaria, "', '",
      input$add_inicio, "', '",
      input$add_expira, "', '",
      input$add_admin, "', '",
      input$add_comment, "');"
    )
    dbExecute(con(), query)
    dbCommit(con())
  })
  
  observeEvent(input$removeUserBtn, {
    dbBegin(con(), immediate = TRUE)
    query <- paste0("DELETE FROM app_usuarios WHERE nome = '", input$add_nome, "';")
    dbExecute(con(), query)
    dbCommit(con())
  })
}

# UI
ui <- fluidPage(
  titlePanel("Gerenciador de Usuários"),
  fluidRow(
    column(6, updateUserModuleUI("updateUser")),
    column(6, addUserModuleUI("addUser"))
  )
)

# Server
server <- function(input, output, session) {
  con <- reactiveVal(connect_to_database())
  callModule(updateUserModule, "updateUser", con)
  callModule(addUserModule, "addUser", con)
}

# Run the application
shinyApp(ui = ui, server = server)
