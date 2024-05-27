ui <- page(
  title = "...",
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "login.css"),
  ),
  # include css
  includeCSS("www/login.css"),
  # include the message.js script
  includeScript("www/messages.js"),
  theme = fn_custom_theme(),
  # authentication module
  # autentica,
  useShinyjs(),
  useWaiter(), # dependencies
 
  conditionalPanel(
    condition="$('html').hasClass('shiny-busy')",
    tags$div(
      id="loadmessage",
      tags$p(tags$strong("Processando...")),
      load_svg
      )
  ),
  
#### ui ----

  tagList(
    page_navbar(fillable = FALSE,
      lang = "pt",
      window_title = "Monitoramento &mdash; Dashboard",
      title = fn_navbar(), #shiny::icon(name = "m", class = "fa-solid fa-beat-fade fa-xl"),
      id = "navbar",
      #--- LEFT MENU ---#
      #--- M O D U L E S ---#
      #ui_Sidebar("main"),
      ui_Licitacoes("main"),
      ui_Sobre("main"),
      #--- RIGHT MENU ---#
      nav_spacer(),
      nav_item(link_home),
      nav_item(link_git),
      nav_item(link_logout)
    )
  )
)

# secure_app(
#   ui,
#   language = "pt-BR",
#   #choose_language = TRUE,
#   theme = fn_custom_theme(),
#   fab_position = "none",
#   tags_top = tags$div(
#     tags$img(src = "images/logo_sepe.png", width = '80%')),
#   tags_bottom = tags$div(
#     tags$p(
#       "Qualquer dúvida, entrar em contato com o ",
#       tags$a(
#         href = "mailto:andre.leite@sepe.pe.gov.br?Subject=SEPE Apps",
#         target="_top", "administrador"))),
#   background = "radial-gradient(circle at 22.4% 21.7%, rgb(238, 130, 238) 0%, rgb(127, 0, 255) 100.2%);",
#   head_auth = tagList(
#     tags$link(
#       rel = "stylesheet",
#       type = "text/css",
#       href = "login.css"),
#   )
# )