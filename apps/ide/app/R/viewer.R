ui_viewer <- function(id="viewer"){
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::fluidRow(
      class = "m-0",
      shiny::column(
        width = 12,
        style = "padding: 0px;",
        shiny::uiOutput(
          outputId = ns("viewer")
        )
      )
    )
  )
}

server_viewer <- function(id="viewer", ide){
  
  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns
      
      output$viewer <- renderUI({
        lapply(seq_along(ide$view), function(widget){
          bslib::card(
            ide$view[[widget]],
            fill = TRUE,
            full_screen = TRUE,
            style = "padding: 0px; margin: 0px;"
          )
        })
      })
      
    }
  )
  
}