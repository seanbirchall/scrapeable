ui_editor <- function(id="editor"){
  ns <- shiny::NS(id)

  shiny::tagList(
    bslib::card(
      height = "100%",
      full_screen = FALSE,
      fill = TRUE,
      bslib::card_header(
        class = "header-card",
        shiny::fluidRow(
          class = "m-0",
          shiny::column(
            width = 10,
            class = "c-0",
            shiny::tags$div(
              class = "header-div-card-left",
              shiny::tags$div(
                id = ns("tabs")
              )
            )
          ),
          shiny::column(
            width = 2,
            class = "c-0",
            shiny::tags$div(
              class = "header-div-card-right",
              shiny::actionButton(
                inputId = ns("run"),
                label = NULL,
                class = "button-run",
                icon = shiny::icon(
                  "play"
                )
              ) |>
                bslib::tooltip("Run Code (Ctrl+Shift+Enter) \n Run Selected (Ctrl+Enter)", placement = "bottom")
            )
          )
        )
      ),
      bslib::card_body(
        class = "body-card",
        shinyAce::aceEditor(
          outputId = ns("ace"),
          height = "100%",
          showPrintMargin = FALSE,
          mode = "r",
          autoComplete = "live",
          autoCompleters = c("static", "rlang", "snippet"),
          debounce = 0.01,
          tabSize = 2,
          selectionId = "selection",
          placeholder = "Write some R code to get started...",
          hotkeys = list(
            run_code_selected = list(
              win = "Ctrl-Enter",
              mac = "CMD-ENTER"
            )
          )
        )
      )
    )
  )
}

server_editor <- function(id="editor", ide){
  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # run reactive ----
      run_selected <- shiny::reactive({
        list(input$ace_run_code_selected)
      })

      # observe full run ----
      shiny::observeEvent(input$run, {
        shinyjs::addClass(
          id = "run",
          class = "disabled"
        )
        run <- evals(txt = input$ace, env = .GlobalEnv)
        ide$evals <- run
        ide$tabs[[ide$tab_selected]] <- input$ace
        ide$history <- c(ide$history, input$ace)
        ide$viewer <- viewerOutput(run)
        shinyjs::removeClass(
          id = "run",
          class = "disabled"
        )
      }, priority = 1, ignoreInit = TRUE)

      # observe selected run ----
      shiny::observeEvent(run_selected(), {
        shinyjs::addClass(
          id = "run",
          class = "disabled"
        )
        run <- evals(txt = input$ace_run_code_selected[["selection"]], env = .GlobalEnv)
        ide$evals <- run
        ide$tabs[[ide$tab_selected]] <- input$ace_run_code_selected[["selection"]]
        ide$history <- c(ide$history, input$ace_run_code_selected[["selection"]])
        ide$viewer <- viewerOutput(run)
        shinyjs::removeClass(
          id = "run",
          class = "disabled"
        )
      }, priority = 1, ignoreInit = TRUE)

      # observe import
      shiny::observeEvent(input$import, {
        shiny::showModal(
          shiny::modalDialog(
            title = "Data Catalog",
            shiny::fluidRow(
              class = "m-0",
              bslib::card(
                height = "75vh",
                style = "padding: 0px;",
                full_screen = FALSE,
                fill = TRUE,
                reactable::reactable(
                  data = catalog,
                  minRows = 7,
                  searchable = TRUE,
                  highlight = TRUE,
                  pagination = FALSE,
                  pageSizeOptions = 10,
                  wrap = FALSE,
                  compact = TRUE,
                  borderless = FALSE,
                  resizable = TRUE,
                  language = reactableLang(
                    searchPlaceholder = "Search...",
                    noData = "No Match",
                  ),
                  theme = reactableTheme(
                    color = "black",
                    # backgroundColor = "#f2f2f2",
                    backgroundColor = "#fff",
                    rowSelectedStyle = list(
                      backgroundColor = "lightgrey"
                    ),
                    headerStyle = list(
                      borderColor = "black",
                      textAlign = "left"
                    ),
                    searchInputStyle = list(
                      color = "black",
                      backgroundColor = "#ADD6FF26",
                      width = "100%"
                    )
                  ),
                  columns = list(
                    DataFrames = colDef(name = "Data Frames"),
                    .selection = colDef(show = FALSE)
                  ),
                  defaultColDef = colDef(align = "left")
                )
              )
            ),
            footer = NULL,
            easyClose = TRUE,
            size = "xl",
            style = "padding: 0px; height:75vh;"
          )
        )
      })

      # code completion ----
      shinyAce::aceAutocomplete(
        inputId = "ace",
        session = session
      )
      shinyAce::aceTooltip(
        inputId = "ace",
        session = session
      )
    }
  )
}
