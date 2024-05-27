ui_Sobre <- function(id) {
  ns <- NS(id)
  nav_panel(
    title = "Sobre",
    card(class = "sobre-pikchr",
         full_screen = FALSE, #min_height = '200px',
         card_header("Sobre a Secretaria Executiva de Monitoramento Estratégico", class = "bg-warning"),
         card_body(class = "cards-sobre-info",
                   markdown('
### Missão
Promover o desenvolvimento sustentável e a eficiência na gestão pública, fornecendo informações estratégicas e apoio decisivo às autoridades governamentais, por meio de monitoramento, análise e avaliação contínuos, para garantir a entrega eficaz de serviços públicos de qualidade à sociedade.

### Valores
1. **Transparência:** Comprometemo-nos a operar de forma aberta e transparente, garantindo o acesso à informação estratégica para o público em geral, promovendo a prestação de contas e a confiança na gestão governamental.

2. **Integridade:** Pautamos nossas ações pelos mais elevados padrões éticos, agindo com honestidade, responsabilidade e imparcialidade em todos os nossos processos de monitoramento e análise.

3. **Eficiência:** Buscamos a excelência na gestão dos recursos públicos, otimizando processos e garantindo o uso eficaz dos recursos disponíveis para atingir nossos objetivos estratégicos.

4. **Colaboração:** Valorizamos parcerias e cooperação interinstitucional, promovendo o trabalho em equipe e a troca de conhecimentos para alcançar resultados melhores e mais abrangentes.

5. **Inovação:** Estamos comprometidos com a busca contínua por soluções inovadoras para o aprimoramento da gestão pública, aplicando tecnologias e metodologias avançadas de monitoramento estratégico.

6. **Foco no Cidadão:** Colocamos o cidadão no centro de nossas ações, priorizando suas necessidades e expectativas na tomada de decisões e no monitoramento das políticas públicas.

7. **Responsabilidade Ambiental:** Consideramos os impactos ambientais em nossas ações e promovemos a adoção de práticas sustentáveis em todas as áreas de atuação.

8. **Aprendizado Contínuo:** Buscamos aprimorar constantemente nossas habilidades e conhecimentos para nos mantermos atualizados e eficazes na prestação de serviços de monitoramento estratégico.
                ')
         )
    ),
card(
  full_screen = TRUE,
  card_header("Equipe", class = "bg-info"),
  card_body(class = "cards_sobre",
            layout_column_wrap(fill = FALSE,
                               width = "475px", gap = '1rem',
                               value_box(
                                 title = "Secretário-Chefe da SEMOBI",
                                 value = "Diogo Bezerra",
                                 theme = "primary",
                                 showcase = tags$img(class = "mlk-userbox", src = "images/diogo.png"),
                                 p(bs_icon("envelope-at-fill"), "diogo.bezerra@semobi.pe.gov.br")
                               ),
                               value_box(
                                 title = "Secretário Executivo de Monitoramento",
                                 value = "André Leite",
                                 theme = "secondary",
                                 showcase = tags$img(class = "mlk-userbox", src = "images/leite.png"),
                                 p(bs_icon("envelope-at-fill"), "andre.leite@sepe.pe.gov.br")
                               ),
                               value_box(
                                 title = "Superintendente Técnico",
                                 value = "Hortênsia Oliveira",
                                 theme = "success",
                                 showcase = tags$img(class = "mlk-userbox", src = "images/hortensia.jpg"),
                                 p(bs_icon("envelope-at-fill"), "hortensia.nunes@sepe.pe.gov.br")
                               ),
                               value_box(
                                 title = "Gerente Geral de Monitoramento",
                                 value = "Arissa Andrade",
                                 theme = "info",
                                 showcase = tags$img(class = "mlk-userbox", src = "images/arissa.jpg"),
                                 p(bs_icon("envelope-at-fill"), "arissa.andrade@sepe.pe.gov.br")
                               ),
                               value_box(
                                 title = "Assessor Especial",
                                 value = "Rafael Zimmerle",
                                 theme = "danger",
                                 showcase = tags$img(class = "mlk-userbox", src = "images/rafael.png"),
                                 p(bs_icon("envelope-at-fill"), "rafael.zimmerle@sepe.pe.gov.br")
                               ),
                               value_box(
                                 title = "Assessor Especial",
                                 value = "Carlos Amorim",
                                 theme = "warning",
                                 showcase = tags$img(class = "mlk-userbox", src = "images/carlos.png"),
                                 p(bs_icon("envelope-at-fill"), "carlos.andrade@sepe.pe.gov.br")
                               )
            )
  )
)
  )
}

server_Sobre <- function(id){
  moduleServer(
    id,
    function(input, output, session) {
    }
  )
}
