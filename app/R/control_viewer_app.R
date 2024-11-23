ui_control_viewer_app <- function(id="app"){
  ns <- shiny::NS(id)

  shinyjs::hidden(
    shiny::tagList(
      bslib::card(
        id = ns("container"),
        fill = TRUE,
        full_screen = FALSE,
        style = "height: 100vh;",
        bslib::card_body(
          style = "padding:0px;",
          fillable = TRUE,
          fill = TRUE,
          tags$div("app")
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

      # show ----
      observeEvent(ide$viewer_window, {
        shinyjs::toggle(id = "container", time = 0, condition = ide$viewer_window[["type"]] == "app")
      })

      # hide ----
      observeEvent(ide$viewer_clear, {
        shinyjs::hide(id = "container", time = 0)
      })
    }
  )
}
