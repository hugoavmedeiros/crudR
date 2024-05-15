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

# UI
ui <- fluidPage(
  titlePanel("Gerenciador de Usuários"),
  
  # Formulário para adicionar usuário
  sidebarPanel(
    h4("Adicionar Usuário"),
    textInput("nome", "Nome:"),
    textInput("app", "App:"),
    textInput("senha", "Senha:"),
    textInput("secretaria", "Secretaria:"),
    textInput("inicio", "Início:"),
    textInput("expira", "Expira:"),
    textInput("admin", "Admin:"),
    textInput("comment", "Comentário:"),
    actionButton("addUserBtn", "Adicionar Usuário")
  ),
  
  # Formulário para atualizar usuário
  sidebarPanel(
    h4("Atualizar Usuário"),
    selectizeInput("update_nome", "Nome do Usuário:", choices = "", selected = ""),
    textInput("update_app", "App:", value = ""),
    textInput("update_senha", "Senha:", value = ""),
    textInput("update_secretaria", "Secretaria:", value = ""),
    textInput("update_inicio", "Início:", value = ""),
    textInput("update_expira", "Expira:", value = ""),
    textInput("update_admin", "Admin:", value = ""),
    textInput("update_comment", "Comentário:", value = ""),
    actionButton("updateUserBtn", "Atualizar Usuário")
  ),
  
  # Botão para remover usuário
  sidebarPanel(
    h4("Remover Usuário"),
    selectizeInput("remove_nome", "Nome do Usuário:", choices = "", selected = ""),
    actionButton("removeUserBtn", "Remover Usuário")
  )
)

# Server
server <- function(input, output, session) {
  con <- reactiveVal(connect_to_database())
  
  # Popula o selectizeInput com os nomes de usuário presentes no banco
  observe({
    query <- "SELECT nome FROM app_usuarios;"
    users <- dbGetQuery(con(), query)$nome
    updateSelectizeInput(session, "update_nome", choices = users, selected = "")
    updateSelectizeInput(session, "remove_nome", choices = users, selected = "")
  })
  
  # Atualiza os outros campos ao selecionar um nome de usuário para atualização
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
  
  # Remover usuário
  observeEvent(input$removeUserBtn, {
    if (input$remove_nome != "") {
      query <- paste0("DELETE FROM app_usuarios WHERE nome = '", input$remove_nome, "';")
      dbExecute(con(), query)
      
      # Atualiza as opções do selectizeInput de remover usuário
      query <- "SELECT nome FROM app_usuarios;"
      users <- dbGetQuery(con(), query)$nome
      updateSelectizeInput(session, "remove_nome", choices = users, selected = "")
      
      # Atualiza as opções do selectizeInput de atualizar usuário
      updateSelectizeInput(session, "update_nome", choices = users, selected = "")
    }
  })
  
  # Adicionar usuário
  observeEvent(input$addUserBtn, {
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
    
    # Atualiza as opções do selectizeInput de remover usuário
    query <- "SELECT nome FROM app_usuarios;"
    users <- dbGetQuery(con(), query)$nome
    updateSelectizeInput(session, "remove_nome", choices = users, selected = "")
    
    # Atualiza as opções do selectizeInput de atualizar usuário
    updateSelectizeInput(session, "update_nome", choices = users, selected = "")
  })
  
  # Atualizar usuário
  observeEvent(input$updateUserBtn, {
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
  })
}

# Run the application
shinyApp(ui = ui, server = server)
