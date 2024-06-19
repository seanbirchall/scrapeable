ui_controls <- function(id="controls"){
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
            shiny::uiOutput(ns("control"))
          )
        )
      )
    )
  )

}

server_controls <- function(id="controls", ide){
  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # on-load ide ----
      ide$tab_control <- "environment"

      # sub-modules ----
      server_environment(
        id = "environment",
        ide = ide
      )
      server_viewer(
        id = "viewer",
        ide = ide
      )


      # observe control tabs ----
      shiny::observeEvent(input$tab_environment, {
        ide$tab_control <- "environment"
      })
      shiny::observeEvent(input$tab_viewer, {
        ide$tab_control <- "viewer"
      })

      # observe code ----
      shiny::observeEvent(ide$code, {
        ev <- ls(.GlobalEnv)
        cl <- as.character(lapply(mget(ev, envir = .GlobalEnv), class))
        df_envir <- data.frame(
          Object = ev,
          Class = cl
        ) |>
          dplyr::filter(!Object %in% c("server_console", "server_controls", "server_editor", "ui_console", "ui_controls", "ui_editor", "ui_environment", "catalog"))

        ide$envir <- df_envir

        df_envir <- df_envir |>
          dplyr::filter(grepl("data.frame|tbl|tbl_df|data.table", Class, ignore.case = TRUE)) |>
          dplyr::select(DataFrames = Object)

        ide$df <- dplyr::bind_rows(
          ide$df,
          df_envir
        ) |>
          dplyr::distinct(DataFrames)

        df_pak <- sessionInfo()[["otherPkgs"]]
        df_pak <- do.call(rbind, lapply(seq_along(df_pak), function(x) {
          data.frame(
            Package = df_pak[[x]][["Package"]],
            Title = df_pak[[x]][["Title"]],
            Version = df_pak[[x]][["Version"]]
          )
        }))
        ide$pak <- df_pak
      }, ignoreInit = TRUE)

      # observe viewer outputs ----
      shiny::observeEvent(ide$view, {
        shinyjs::delay(1, shinyjs::click(id = "tab_viewer"))
      }, ignoreInit = TRUE)


      # ui outputs ----
      output$control <- shiny::renderUI({
        if(ide$tab_control == "environment"){
          ui_environment(
            id = "environment"
          )
        }else if(ide$tab_control == "viewer"){
          ui_viewer(
            id = "viewer"
          )
        }
      })
    }
  )
}
