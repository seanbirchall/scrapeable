ui_control_viewer <- function(id="viewer", fill){
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
            inputId = ns("clear"),
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
        style = "height: calc(100vh - 68px);",
        bslib::card(
          height = "100%",
          style = "padding: 0px !important; gap: 0px; margin: 0px;",
          full_screen = FALSE,
          fill = TRUE,
          bslib::card_body(
            style = "padding: 0px !important; gap: 0px; margin: 0px;",
            shiny::uiOutput(
              outputId = ns("viewer"),
              fill = fill
            )
          )
        )
      )
    )
  )
}

server_control_viewer <- function(id="viewer", ide){

  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # sub-modules ----
      server_control_viewer_df(
        id = "df_viewer",
        ide = ide
      )
      server_control_viewer_app(
        id = "app",
        ide = ide
      )

      # observe clear viewer ----
      shiny::observeEvent(input$clear, {
        ide$show_df_viewer <- FALSE
        ide$environment_selected <- NULL
        ide$viewer <- NULL
        ide$df_viewer <- NULL
      })

      # observe viewer ----
      shiny::observeEvent(ide$viewer, {
        if(!is.null(ide$viewer)){
          shinyjs::delay(1, shinyjs::click(id = "control-tab_viewer", asis = TRUE))
        }else{
          shinyjs::delay(1, shinyjs::click(id = "control-tab_environment", asis = TRUE))
        }
      })

      # ui viewer ----
      output$viewer <- shiny::renderUI({
        shiny::req(ide$viewer)
        if(length(ide$viewer) > 1){
          ide$show_df_viewer <- FALSE
        }
        lapply(seq_along(ide$viewer), function(widget){
          bslib::card(
            ide$viewer[[widget]],
            fill = TRUE,
            full_screen = TRUE,
            style = "padding: 0px; margin: 0px;"
          )
        })
      })

      # show df_viewer ----
      shiny::observeEvent(ide$environment_selected, {
        ide$viewer <- NULL
        check_type <- check_object_type(ide$environment_selected[["data"]])
        if(check_type %in% c("data.frame", "matrix", "tibble", "data.table")){
          ide$show_df_viewer <- TRUE
          ide$viewer <- ui_control_viewer_df(
            id = ns("df_viewer")
          )
        }
      })
    }
  )
}
