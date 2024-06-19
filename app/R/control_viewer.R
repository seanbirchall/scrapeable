ui_viewer <- function(id="viewer"){
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::tags$div(
      shiny::column(
        align = "left",
        class = "m-0",
        style = "padding: 0px; background-color: rgb(246, 247, 249);",
        width = 12,
        shiny::tags$div(
          style = "display: flex; align-items: center; justify-content: flex-start;",
          shiny::actionButton(
            inputId = ns("clear_viewer"),
            label = NULL,
            class = "button-clear",
            icon = shiny::icon(
              name = "remove"
            )
          ) |>
            bslib::tooltip("Clear Viewer", placement = "bottom")
        )
      ),
      shiny::fluidRow(
        class = "m-0",
        style = "height: calc(100vh - 50px);",
        bslib::card(
          height = "100%",
          style = "padding: 0px;",
          full_screen = FALSE,
          fill = TRUE,
          bslib::card_body(
            style = "padding: 0px;",
            shiny::uiOutput(
              outputId = ns("viewer")
            )
          )
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

      # ui viewer ----
      output$viewer <- shiny::renderUI({
        lapply(seq_along(ide$view), function(widget){
          bslib::card(
            ide$view[[widget]],
            fill = TRUE,
            full_screen = TRUE,
            style = "padding: 0px; margin: 0px;"
          )
        })
      })

      # observe clear viewer ----
      shiny::observeEvent(input$clear_viewer, {
        ide$view <- NULL
      })
    }
  )
}
