pacman::p_load(
  #banco
  DBI, RSQLite, 
  #base
  rlang, tidyverse,
  #web
  bsicons, bslib, htmltools, httr, shiny, shinyjs
,waiter
,lubridate
,dbplyr
,shinyWidgets
,shinycssloaders
,pals
,sf
,plotly
,leaflet
,leaflet.extras
,tidyverse
,viridis
,vistime
,leafgl
,mapview
,shinymanager
,glue
,safer
,config
,svglite
,reactable
,DT
,scales     
,jsonlite
,stringi
,writexl)

#### config ----
Sys.setlocale(locale = "pt_BR.utf8")

### YAML CONFIG INFO ###
status <- config::get("status")
sepe_datalake <- config::get(paste0("sepedatalake_", status))
app_name <- config::get("app_name")
seed <- read_rds("data/semente.rds")
key <- safer::keypair(seed = seed)


# Encrypt columns of atibble
encrypt_col <- function(col, key) {
  unlist(lapply(
    col,
    function(x) {
      return(safer::encrypt_string(x, key$private_key, key$public_key))
    }
  ))
}


# Decode columns of a tibble
decrypt_col <- function(col, key) {
  unlist(lapply(
    col,
    function(x) {
      return(safer::decrypt_string(x, key$private_key, key$public_key))
    }
  ))
}

#### AUTHENTICATION FUNCTIONS ----
set_labels(
  language = "pt-BR",
  "Please authenticate" = "",
  "Username:" = "Nome",
  "Password:" = "Senha"
)

check_creds <- function(sepe_datalake, seed, session) {
  function(user, password) {
    con <- DBI::dbConnect(
      drv      = RPostgres::Postgres(),
      host     = sepe_datalake$server,
      user     = sepe_datalake$uid,
      password = sepe_datalake$pwd,
      port     = sepe_datalake$port,
      dbname   = sepe_datalake$database
    )
    on.exit(dbDisconnect(con))

    req <- glue_sql("SELECT * FROM app_usuarios WHERE \"nome\" = ({nome}) AND \"senha\" = ({senha}) AND \"app\" = ({app})",
                    nome = safer::encrypt_string(user, key$private_key, key$public_key),
                    senha = safer::encrypt_string(password, key$private_key, key$public_key),
                    app = safer::encrypt_string(app_name, key$private_key, key$public_key),
                    .con = con
    )

    res <- dbGetQuery(con, req)
    tibble(
      nome = user,
      app = app_name,
      url_protocol = session$clientData$url_protocol,
      url_hostname = session$clientData$url_hostname,
      url_port = session$clientData$url_port,
      login_timestamp = Sys.time(),
      login_success = (nrow(res) > 0)
    ) %>%
      dbWriteTable(con, "app_logs", ., append = TRUE)

    if (nrow(res) > 0) {
      list(result = TRUE, user_info = list(user = user))
    } else {
      list(result = FALSE)
    }
  }
}

#### GENERIC FUNCTIONS ----

raw_svg <- function(p, wid = 10, ht = 8, scaling = 2.5) {
  s <- svgstring(scaling = scaling, width = wid, height = ht)
  tryCatch(print(p),
           finally = dev.off()
  )
  ss <- str_replace(s(), pattern = "width='\\d*.\\d*pt' height='\\d*.\\d*pt'", replacement = "width='100%' height='100%'" )
  sss <- str_replace_all(ss, pattern = 'font-family:.*;', replacement = "")
  #print(sss)
  return(htmltools::HTML(sss))
}

status_badge <- function(color = "#aaa", width = "0.55rem", height = width) {
  span(style = list(
    display = "inline-block",
    marginRight = "0.5rem",
    width = width,
    height = height,
    backgroundColor = color,
    borderRadius = "50%"
  ))
}

### END GENERIC FUNCTIONS ###

#### scripts ----

file_paths <- fs::dir_ls(c("modules", "helpers"))
map(file_paths, function(x){source(x)})

#### utils ----
load_svg <- HTML('<svg version="1.1" id="L7" width="200" height="200" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 100 100" enable-background="new 0 0 100 100" xml:space="preserve">
 <path fill="#C39BD3" d="M31.6,3.5C5.9,13.6-6.6,42.7,3.5,68.4c10.1,25.7,39.2,38.3,64.9,28.1l-3.1-7.9c-21.3,8.4-45.4-2-53.8-23.3
  c-8.4-21.3,2-45.4,23.3-53.8L31.6,3.5z">
      <animateTransform attributeName="transform" attributeType="XML" type="rotate" dur="2s" from="0 50 50" to="360 50 50" repeatCount="indefinite"></animateTransform>
  </path>
 <path fill="#C39BD3" d="M42.3,39.6c5.7-4.3,13.9-3.1,18.1,2.7c4.3,5.7,3.1,13.9-2.7,18.1l4.1,5.5c8.8-6.5,10.6-19,4.1-27.7
  c-6.5-8.8-19-10.6-27.7-4.1L42.3,39.6z">
      <animateTransform attributeName="transform" attributeType="XML" type="rotate" dur="1s" from="0 50 50" to="-360 50 50" repeatCount="indefinite"></animateTransform>
  </path>
 <path fill="#C39BD3" d="M82,35.7C74.1,18,53.4,10.1,35.7,18S10.1,46.6,18,64.3l7.6-3.4c-6-13.5,0-29.3,13.5-35.3s29.3,0,35.3,13.5
  L82,35.7z">
      <animateTransform attributeName="transform" attributeType="XML" type="rotate" dur="2s" from="0 50 50" to="360 50 50" repeatCount="indefinite"></animateTransform>
  </path>
</svg>')

connect_to_database <- function() {
  con <- dbConnect(RSQLite::SQLite(), "usuarios.db")
  
  dbGetQuery(con, "PRAGMA busy_timeout = 5000;") 
  sqliteSetBusyHandler(con, function(nAttempts) {
    print(paste("O banco de dados está bloqueado. Tentativa", nAttempts))
    Sys.sleep(0.1) 
    return(TRUE)  
  })
  
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