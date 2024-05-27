fn_navbar <- function(){
    a(href = "https://monitoramento.sepe.pe.gov.br",
      class = "govpe-logo",
      shiny::icon(name = "markdown", class = "fa-solid fa-2xl"),
    )
}

## Links

link_home <-  tags$a(HTML("Monitoramento"), href = "https://monitoramento.sepe.pe.gov.br")
link_git <- tags$a(shiny::icon("github"), href = "https://github.com/StrategicProjects", target = "_blank")
link_logout <- actionLink(inputId = "logout", icon = shiny::icon("arrow-right-from-bracket"), label = "") # , href = "https://monitoramento.sepe.pe.gov.br", target = "_self")

