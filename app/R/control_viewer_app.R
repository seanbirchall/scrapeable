ui_control_viewer_app <- function(id="app"){
  ns <- shiny::NS(id)

  shiny::tagList(
    bslib::card(
      id = ns("view"),
      fill = TRUE,
      full_screen = FALSE,
      style = "height: 100vh;",
      bslib::card_body(
        style = "padding:0px;",
        fillable = TRUE,
        fill = TRUE,
        appViewerOutput(
          outputId = ns("content")
        )
      )
    )
  )
}


server_control_viewer_app <- function(id="app", ide){

  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # app-viewer ----
      # output$content <- renderAppViewer({
      #
      # })
    }
  )
}
