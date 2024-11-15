ui_control <- function(id="control"){
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::tags$div(
      style = "height: 100vh; width: 100%; overflow: hidden;",
      shiny::fluidRow(
        class = "m-0",
        style = "height: 100vh;",
        bslib::card(
          height = "100%",
          style = "padding: 0px;",
          full_screen = FALSE,
          fill = TRUE,
          bslib::card_header(
            style = "padding: 0px; background-color: #eee;",
            shiny::fluidRow(
              class = "m-0",
              shiny::column(
                width = 6,
                align = "left",
                style = "padding: 0px;",
                shiny::tags$div(
                  style = "display: flex; align-items: center; justify-content: flex-start;",
                  shiny::actionButton(
                    inputId = ns("tab_environment"),
                    label = "Environment",
                    style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid #f2f2f2; background-color: #eee; color: black; font-weight: 600;"
                  ),
                  shiny::actionButton(
                    inputId = ns("tab_viewer"),
                    label = "Viewer",
                    style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid #f2f2f2; background-color: #eee; color: black; font-weight: 600;"
                  )
                )
              ),
              shiny::column(
                width = 6,
                align = "right",
                style = "padding: 0px;",
                shiny::tags$div(
                  style = "display: flex; align-items: center; justify-content: flex-end;",
                  shiny::actionButton(
                    inputId = "deploy",
                    label = "Deploy",
                    style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid #eee; background-color: #eee; color: black;",
                    icon = shiny::icon(
                      "cloud-arrow-up"
                    )
                  ) |>
                    bslib::tooltip("Cloud Deploy", placement = "bottom"),
                  shiny::actionButton(
                    inputId = "share",
                    label = "Share",
                    style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid #eee; background-color: #eee; color: black;",
                    icon = shiny::icon(
                      "share-nodes"
                    )
                  ) |>
                    bslib::tooltip("Create Link", placement = "bottom")
                )
              )
            )
          ),
          bslib::card_body(
            style = "padding: 0px; margin: 0px;",
            height = "100%",
            shiny::uiOutput(ns("control")),
            shinyjs::hidden(
              shiny::tags$div(id = ns("object_viewer"))
            )
          )
        )
      )
    )
  )

}

server_control <- function(id="control", ide){
  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # on-load ide ----
      ide$tab_control <- "environment"

      # sub-modules ----
      server_control_environment(
        id = "environment",
        ide = ide
      )
      server_control_viewer(
        id = "viewer",
        ide = ide
      )

      # observe control tabs ----
      shiny::observeEvent(input$tab_environment, {
        if(ide$show_df_viewer){
          # ide$viewer <- NULL
        }
        ide$tab_control <- "environment"
      })
      shiny::observeEvent(input$tab_viewer, {
        ide$tab_control <- "viewer"
      })

      # ui outputs ----
      output$control <- shiny::renderUI({
        if(ide$tab_control == "environment"){
          ui_control_environment(
            id = ns("environment")
          )
        }else if(ide$tab_control == "viewer"){
          ui_control_viewer(
            id = ns("viewer"),
            fill = TRUE
            # fill = ide$show_df_viewer
          )
        }
      })
    }
  )
}
