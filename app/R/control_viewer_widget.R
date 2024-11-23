ui_control_viewer_widget <- function(id="widget"){
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
          shiny::uiOutput(
            outputId = ns("widget")
          )
        )
      )
    )
  )
}


server_control_viewer_widget <- function(id="widget", ide){

  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # show ----
      observeEvent(ide$viewer_window, {
        shinyjs::toggle(id = "container", time = 0, condition = ide$viewer_window[["type"]] == "widget")
      })

      # hide ----
      observeEvent(ide$viewer_clear, {
        shinyjs::hide(id = "container", time = 0)
      })

      # widgets ----
      output$widget <- shiny::renderUI({
        shiny::req(ide$viewer_window == "widget")
        shiny::req(ide$viewer)
        lapply(seq_along(ide$viewer), function(widget){
          bslib::card(
            ide$viewer[[widget]],
            fill = TRUE,
            full_screen = TRUE,
            style = "padding: 0px; margin: 0px;"
          )
        })
      })

    }
  )
}
