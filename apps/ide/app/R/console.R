ui_console <- function(id="console"){
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
          align = "right",
          column(
            width = 12,
            align = "right",
            class = "m-0",
            style = "padding: 0px;",
            shiny::actionButton(
              inputId = ns("Clear"),
              label = NULL,
              style = "width: 45px; font-size: 80%; padding: 0px; border: 1px solid #f2f2f2; background-color: #ffc107;",
              icon = shiny::icon(
                "broom"
              )
            ) %>%
              bslib::tooltip("Clear Console", placement = "bottom")
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
      
      # observe input state
      observeEvent(input$Clear, {
        message("Clear Code")
        ide$evals <- NULL
      })
      
      # ui outputs
      output$console <- shiny::renderUI({
        shiny::tags$div(
          style = "line-height: normal; letter-spacing: -0.00164474px; font-size: 12px; font-kerning: none;",
          
          lapply(seq_along(ide$evals), function(chunk){
            gsub_terminal <- function(src){
              base::paste0(
                "> ",
                src
              )
            }
            
            src <- shiny::tags$span(
              class = "r-src",
              gsub_terminal(
                ide$evals[[chunk]][["src"]]
              )
            )
            
            
            if(is.null(ide$evals[[chunk]][["msg"]][["messages"]])){
              messages <- NULL
            }else{
              messages <- shiny::tags$span(class="r-message", paste(ide$evals[[chunk]][["msg"]][["messages"]], collapse = "\n"))
            }
            
            
            if(is.null(ide$evals[[chunk]][["msg"]][["warnings"]])){
              warnings <- NULL
            }else{
              warnings <- shiny::tags$span(class="r-warning", paste(ide$evals[[chunk]][["msg"]][["warnings"]], collapse = "\n"))
            }
            
            
            if(is.null(ide$evals[[chunk]][["msg"]][["errors"]])){
              errors <- NULL
            }else{
              errors <- shiny::tags$span(class="r-error", paste(ide$evals[[chunk]][["msg"]][["errors"]], collapse = "\n"))
            }
            
            if(is.null(ide$evals[[chunk]][["output"]])){
              output <- NULL
            }else{
              output <- shiny::tags$span(class="r-output", paste(ide$evals[[chunk]][["output"]], collapse = "\n"))
            }
            
            tgs <- shiny::tagList(
              src,
              if(!is.null(src)){shiny::tags$br()},
              messages,
              if(!is.null(messages)){shiny::tags$br()},
              warnings,
              if(!is.null(warnings)){shiny::tags$br()},
              errors,
              if(!is.null(errors)){shiny::tags$br()},
              output,
              shiny::tags$br()
            )
            
          })
        )
      })
      
    }
    
  )
  
}