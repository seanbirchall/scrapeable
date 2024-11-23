ui_control_viewer <- function(id="viewer", fill){
  ns <- shiny::NS(id)

  shinyjs::hidden(
    shiny::tagList(
      shiny::tags$div(
        id = ns("container"),
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
              bslib::tooltip("Clear Viewer", placement = "bottom"),
            shinyjs::hidden(
              shiny::actionButton(
                inputId = ns("show"),
                label = NULL,
              )
            )
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
              ui_control_viewer_widget(
                id = ns("widget")
              ),
              ui_control_viewer_df(
                id = ns("df_viewer")
              ),
              ui_control_viewer_app(
                id = ns("app")
              )
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

      # on-load defaults ----
      ide$viewer_window <- list(
        type = "widget",
        id = uuid::UUIDgenerate()
      )
      ide$viewer_clear <- 1

      # show ----
      observeEvent(ide$tab_control, {
        shinyjs::toggle(id = "container", time = 0, condition = ide$tab_control == "viewer")
      })

      # sub-modules ----
      server_control_viewer_widget(
        id = "widget",
        ide = ide
      )
      server_control_viewer_df(
        id = "df_viewer",
        ide = ide
      )
      server_control_viewer_app(
        id = "app",
        ide = ide
      )

      # clear viewer ----
      shiny::observeEvent(input$clear, {
        ide$viewer_clear <- ide$viewer_clear + 1
      })

      # show widget ----
      shiny::observeEvent(ide$viewer, {
        if(!is.null(ide$viewer)){
          ide$viewer_window[["type"]] <- "widget"
          ide$viewer_window[["id"]] <- uuid::UUIDgenerate()
          shinyjs::delay(1, shinyjs::click(id = "control-tab_viewer", asis = TRUE))
        }
      })

      # show df_viewer ----
      shiny::observeEvent(c(ide$environment_selected, input$show), {
        ide$viewer <- NULL
        check_type <- check_object_type(ide$environment_selected[["data"]])
        if(check_type %in% c("data.frame", "matrix", "tibble", "data.table")){
          shinyjs::delay(1, shinyjs::click(id = "control-tab_viewer", asis = TRUE))
          ide$viewer_window[["type"]] <- "df_viewer"
          ide$viewer_window[["id"]] <- uuid::UUIDgenerate()
        }
      })
    }
  )
}
