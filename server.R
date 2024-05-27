function(input, output, session){

  #### auth ----
  # auth <- callModule(
  #   module = auth_server,
  #   id = "auth",
  #   check_credentials = check_creds(sepe_datalake, key, session)
  # )
  
  auth<- secure_server(
    check_credentials = check_creds(sepe_datalake, key, session)
  )

  #### módulos ----
  #server_Sidebar("main")
  server_Licitacoes("main")
  server_Sobre("main")

  observeEvent(input$logout, {
    session$reload()
  })

  session$onSessionEnded(function() {
    if(!is_interactive()) dbDisconnect(con)
  })

}
