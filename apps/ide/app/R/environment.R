ui_environment <- function(id="environment"){
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::fluidRow(
      class = "m-0",
      shiny::column(
        width = 12,
        style = "padding: 0px;",
        shiny::fluidRow(
          class = "m-0",
          shiny::column(
            width = 12,
            style = "padding: 0px; height: 50%;",
            reactable::reactableOutput(
              outputId = ns("ls")
            )
          ),
          shiny::column(
            width = 12,
            style = "padding: 0px;",
            reactable::reactableOutput(
              outputId = ns("pak")
            )
          )
        )
      )
    )
  )
}

server_environment <- function(id="environment", ide){
  
  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns
      
      # reactives
      envir_selected <- shiny::reactive({
        select <- reactable::getReactableState("ls", "selected")
      })
      
      # observe inputs
      observeEvent(envir_selected(), {
        showModal(
          modalDialog(
            title = NULL,
            footer = NULL,
            shiny::fluidRow(
              class = "m-0",
              bslib::card(
                height = "65vh",
                style = "padding: 0px;",
                full_screen = FALSE,
                fill = TRUE,
                bslib::card_header(
                  style = "padding: 0px; background-color: #eee;",
                  shiny::fluidRow(
                    class = "m-0",
                    shiny::actionButton(
                      inputId = ns("envir_str"),
                      label = "Structure",
                      style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid #f2f2f2; background-color: #eee; color: black; font-weight: 600;"
                    ),
                    shiny::actionButton(
                      inputId = ns("envir_table"),
                      label = "Table",
                      style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid #f2f2f2; background-color: #eee; color: black; font-weight: 600;"
                    ),
                    shiny::actionButton(
                      inputId = ns("envir_list"),
                      label = "List",
                      style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid #f2f2f2; background-color: #eee; color: black; font-weight: 600;"
                    )
                  )
                ),
                bslib::layout_sidebar(
                  sidebar = bslib::sidebar(
                    shiny::radioButtons(
                      inputId = ns("envir_modal_sample"),
                      label = "Sample Method",
                      choiceNames = c("Head", "Tail", "None"),
                      choiceValues = c("head", "tail", "none")
                    ),
                    shiny::uiOutput(
                      outputId = ns("envir_modal_sample_n")
                    ),
                    fillable = TRUE,
                    fill = TRUE
                  ),
                  bslib::card_body(
                    style = "padding: 0px;",
                    shiny::uiOutput(
                      outputId = ns("envir_modal")
                    )
                  )
                )
              )
            ),
            shiny::includeScript(
              path = "www/modal.js"
            ),
            easyClose = TRUE,
            size = "xl",
            style = "padding: 0px; margin: 0px;"
          )
        )
      })
      
      observeEvent(input$envir_str, {
        ide$tab_modal <- "structure"
      })
      
      observeEvent(input$envir_table, {
        ide$tab_modal <- "table"
      })
      
      observeEvent(input$envir_list, {
        ide$tab_modal <- "list"
      })
      
      # ui outputs
      output$ls <- reactable::renderReactable({
        if(!is.null(ide$envir)){
          reactable::reactable(
            ide$envir,
            height = "47.5vh",
            sortable = T,
            resizable = T,
            pagination = F,
            highlight = T,
            compact = T,
            bordered = T,
            onClick = "select",
            selection = "single",
            wrap = F,
            columns = list(
              .selection = colDef(show = FALSE)
            ),
            style = "font-size: 13px; overflow-x: hidden;",
            defaultSorted = "Class",
            theme = reactableTheme(
              rowSelectedStyle = list(
                backgroundColor = "lightgrey"
              ),
              headerStyle = list(
                backgroundColor = "rgb(246, 247, 249)",
                borderColor = "black"
              )
            )
          )
        }
      })
      
      output$pak <- reactable::renderReactable({
        if(!is.null(ide$pak)){
          reactable::reactable(
            ide$pak,
            height = "47.5vh",
            sortable = T,
            resizable = T,
            pagination = F,
            highlight = T,
            compact = T,
            bordered = T,
            onClick = "select",
            selection = "single",
            wrap = F,
            columns = list(
              .selection = colDef(show = FALSE)
            ),
            style = "font-size: 13px; overflow-x: hidden;",
            defaultSorted = "Package",
            theme = reactableTheme(
              headerStyle = list(
                backgroundColor = "rgb(246, 247, 249)",
                borderColor = "black"
              )
            )
          )
        }
      })
      
      output$envir_modal <- renderUI({
        
        if(input$envir_modal_sample == "head"){
          shiny::req(input$n)
          
          d <- head(
            get(
              ide$envir[["Object"]][envir_selected()],
              envir = .GlobalEnv
            ),
            n = input$n
          )
        }else if(input$envir_modal_sample == "tail"){
          shiny::req(input$n)
          
          d <- tail(
            get(
              ide$envir[["Object"]][envir_selected()],
              envir = .GlobalEnv
            ),
            n = input$n
          )
        }else{
          d <- get(
            ide$envir[["Object"]][envir_selected()],
            envir = .GlobalEnv
          )
        }
        
        if(ide$tab_modal == "structure"){
          shiny::renderPrint({
            str(d)
          })
        }else if(ide$tab_modal == "table"){
          reactable(
            d,
            height = "100%",
            width = "100%"
          )
        }else if(ide$tab_modal == "list"){
          listviewer::jsonedit(
            d,
            height = "100%",
            width = "100%"
          )
        }
      })
      
      output$envir_modal_sample_n <- renderUI({
        if(input$envir_modal_sample %in% c("head", "tail")){
          
          shiny::numericInput(
            inputId = ns("n"),
            label = "N Rows",
            value = 100,
            min = 0,
            max = 10000
          )
          
        }else if(input$envir_modal_sample == "none"){
          
        }
        
      })
      
    }
  )
  
}