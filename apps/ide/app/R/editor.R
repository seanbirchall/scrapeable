ui_editor <- function(id="editor"){
  ns <- shiny::NS(id)
  
  shiny::tagList(
    bslib::card(
      height = "100%",
      full_screen = TRUE,
      fill = TRUE,
      bslib::card_header(
        style = "padding: 0px; background-color: #eee;",
        shiny::fluidRow(
          class = "m-0",
          column(
            width = 12,
            align = "right",
            class = "m-0",
            style = "padding: 0px;",
            shiny::actionButton(
              inputId = ns("Run"),
              label = NULL,
              style = "width: 45px; font-size: 80%; padding: 0px; border: 1px solid #f2f2f2; background-color: green;",
              icon = shiny::icon(
                "play"
              )
            ) %>%
              bslib::tooltip("Run Code (crtl + shift + enter)", placement = "bottom"),
            shiny::actionButton(
              inputId = ns("Import"),
              label = NULL,
              style = "width: 45px; font-size: 80%; padding: 0px; border: 1px solid #f2f2f2; background-color: #3498db;",
              icon = shiny::icon(
                "file"
              )
            ) %>%
              bslib::tooltip("Import Data (crtl + i)", placement = "bottom"),
            shiny::actionButton(
              inputId = ns("Remove"),
              label = NULL,
              style = "width: 45px; font-size: 80%; padding: 0px; border: 1px solid #f2f2f2; background-color: #e74c3c;",
              icon = shiny::icon(
                "remove"
              )
            ) %>%
              bslib::tooltip("Remove from Environment", placement = "bottom")
          )
        )
      ),
      bslib::card_body(
        style = "padding: 0px;",
        shinyAce::aceEditor(
          outputId = ns("Ace"),
          height = "100%",
          showPrintMargin = FALSE,
          mode = "r",
          autoComplete = "live",
          autoCompleters = c("static", "rlang", "snippet"),
          debounce = 1,
          tabSize = 2,
          selectionId = "selection",
          placeholder = "Write some R code to get started...",
          hotkeys = list(
            run_code = list(
              win = "Ctrl-Shift-Enter",
              mac = "CMD-SHIFT-ENTER"
            ),
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
      
      # reactives
      .run_code <- shiny::reactive({
        list(input$Ace_run_code, input$Run)
      })
      
      #observe input state
      shiny::observeEvent(.run_code(), {
        message("Run Code")
        
        run <- evals(txt = input$Ace, env = .GlobalEnv)
        ide$evals <- run
        ide$code <- input$Ace
        ide$hash <- md5(input$Ace)
        
        viewer <- tryCatch(
          lapply(run, function(v) if(any(v[["type"]] == "htmlwidget")) shiny::tagList(v[["result"]]) else NULL),
          error = function(e) NULL
        )
        
        message(viewer)
        if(!is.null(viewer)){
          viewer <- Filter(Negate(is.null), viewer)
          message(viewer)
          
          if(length(viewer) > 0){
            message("Update Viewer")
            message(viewer)
            ide$view <- viewer 
              
          }
        }
        
      }, priority = 1, ignoreInit = TRUE)
      
      # ui outputs
      shinyAce::aceAutocomplete(
        inputId = "Ace",
        session = session
      )
      
      shinyAce::aceAnnotate(
        inputId = "Ace",
        session = session
      )
      
      shinyAce::aceTooltip(
        inputId = "Ace",
        session = session
      )
      
    }
  )
  
}