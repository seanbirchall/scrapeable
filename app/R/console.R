ui_console <- function(id="console"){
  ns <- shiny::NS(id)

  shiny::tagList(
    bslib::card(
      height = "100%",
      full_screen = TRUE,
      fill = TRUE,
      bslib::card_header(
        class = "header-card",
        shiny::fluidRow(
          class = "m-0",
          align = "right",
          column(
            width = 12,
            align = "right",
            class = "c-0",
            shiny::tags$div(
              class = "header-div-card",
              shiny::actionButton(
                inputId = ns("copy"),
                label = NULL,
                class = "button-copy",
                icon = shiny::icon(
                  "copy"
                )
              ) |>
                bslib::tooltip("Copy Console (Ctrl+Shift+C)", placement = "bottom"),
              shiny::actionButton(
                inputId = ns("clear"),
                label = NULL,
                class = "button-clear",
                icon = shiny::icon(
                  "broom"
                )
              ) |>
                bslib::tooltip("Clear Console (Ctrl+Shift+L)", placement = "bottom")
            )
          )
        )
      ),
      bslib::card_body(
        style = "padding: 0px; margin-left: 10px;",
        shiny::uiOutput(
          outputId = ns("console")
        )
      )
    )
  )

}

server_console <- function(id="console", ide){
  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # observe clear ----
      observeEvent(input$clear, {
        ide$evals <- NULL
      })

      # ui console ----
      output$console <- shiny::renderUI({
        shiny::tags$div(
          style = "line-height: normal; letter-spacing: -0.00164474px; font-size: 12px; font-kerning: none;",
          consoleOutput(
            evals = ide$evals
          )
        )
      })
    }
  )
}
