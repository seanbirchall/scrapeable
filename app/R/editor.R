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
          placeholder = "Write some code to get started...",
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

      # observe source run ----
      shiny::observeEvent(input$run, {
        shinyjs::addClass("run", class = "disabled")
        run <- eval_code(
          code = input$ace,
          ext = ide$tab_selected_extension
        )
        ide$evals <- run[["evals"]]
        ide$tabs[[ide$tab_selected]][["code"]] <- input$ace
        ide$history[["code"]] <- c(input$ace, ide$history[["code"]])
        ide$history[["start_time"]] <- c(run[["start_time"]], ide$history[["start_time"]])
        ide$history[["run_time"]] <- c(run[["run_time"]], ide$history[["run_time"]])
        ide$last_run <- input$ace
        viewer <- run[["viewer"]]
        if(!is.null(viewer)){
          ide$show_df_viewer <- FALSE
          ide$viewer <- viewer
        }
        if(is.null(viewer) & !ide$show_df_viewer & ide$tab_control == "viewer"){
          shinyjs::click("control-tab_environment", asis = TRUE)
        }
        shinyjs::removeClass("run", class = "disabled")
      }, ignoreInit = TRUE)

      # observe selected run ----
      shiny::observeEvent(input$ace_run_code_selected, {
        shinyjs::addClass("run", class = "disabled")
        run <- eval_code(
          code = input$ace_selection,
          ext = ide$tab_selected_extension
        )
        ide$evals <- run[["evals"]]
        ide$tabs[[ide$tab_selected]][["code"]] <- input$ace_selection
        ide$history[["code"]] <- c(input$ace_selection, ide$history[["code"]])
        ide$history[["start_time"]] <- c(run[["start_time"]], ide$history[["start_time"]])
        ide$history[["run_time"]] <- c(run[["run_time"]], ide$history[["run_time"]])
        ide$last_run <- input$ace_selection
        viewer <- run[["viewer"]]
        if(!is.null(viewer)){
          ide$show_df_viewer <- FALSE
          ide$viewer <- viewer
        }
        if(is.null(viewer) & !ide$show_df_viewer & ide$tab_control == "viewer"){
          shinyjs::click("control-tab_environment", asis = TRUE)
        }
        shinyjs::removeClass("run", class = "disabled")
      }, ignoreInit = TRUE)

      # observe extension ----
      shiny::observeEvent(ide$tab_selected_extension, {
        if(ide$tab_selected_extension %in% c("r", "rmd", "qmd", "md", "app", "api", "db")){
          shinyAce::updateAceEditor(
            session = session,
            editorId = "ace",
            mode = "r",
            autoComplete = "live",
            autoCompleters = c("static", "rlang", "snippet", "text", "keyword")
          )
        }else if(ide$tab_selected_extension == "sql"){
          shinyAce::updateAceEditor(
            session = session,
            editorId = "ace",
            mode = "sql",
            autoComplete = "live",
            autoCompleters = c("static", "snippet", "text", "keyword")
          )
        }else if(ide$tab_selected_extension == "js"){
          shinyAce::updateAceEditor(
            session = session,
            editorId = "ace",
            mode = "javascript",
            autoComplete = "live",
            autoCompleters = c("static", "snippet", "text", "keyword")
          )
        }
      }, ignoreInit = TRUE)

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
