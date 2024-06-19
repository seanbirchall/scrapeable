ui_environment <- function(id="environment"){
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::fluidRow(
      class = "m-0",
      shiny::column(
        width = 12,
        class = "c-0",
        shiny::fluidRow(
          class = "m-0",
          bslib::card(
            style = "padding: 0px; height: calc(50vh - 30px);",
            fill = TRUE,
            bslib::card_body(
              style = "padding: 0px;",
              fillable = TRUE,
              fill = TRUE,
              reactable::reactableOutput(
                outputId = ns("environment"),
                height = "100%"
              )
            )
          ),
          bslib::card(
            style = "padding: 0px; height: calc(50vh - 30px);",
            bslib::card_body(
              style = "padding: 0px;",
              reactable::reactableOutput(
                outputId = ns("package")
              )
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

      # ignore sub-modules ----
      ignore <- c("server_console", "server_controls", "server_editor", "ui_console", "ui_controls", "ui_editor", "ui_environment", "catalog", "slice_data")

      # table selections ----
      environment_selected <- shiny::reactive({
        select <- reactable::getReactableState("environment", "selected")
      })

      # environment table selections ----
      shiny::observeEvent(environment_selected(), {
        showModal(
          modalDialog(
            title = NULL,
            footer = NULL,
            shiny::fluidRow(
              class = "m-0",
              bslib::card(
                height = "75vh",
                style = "padding: 0px;",
                full_screen = FALSE,
                fill = TRUE,
                footer = NULL,
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
                bslib::card_body(
                  style = "padding: 0px;",
                  shiny::fluidRow(
                    class = "m-0",
                    shiny::column(
                      width = 4,
                      shiny::radioButtons(
                        inputId = ns("envir_modal_sample"),
                        label = "Sample Method",
                        choiceNames = c("Head", "Tail", "None"),
                        choiceValues = c("head", "tail", "none"),
                        inline = TRUE
                      )
                    ),
                    shiny::column(
                      width = 4,
                      shiny::uiOutput(
                        outputId = ns("envir_modal_sample_n")
                      )
                    ),
                    shiny::column(
                      width = 4,
                      shiny::actionButton(
                        inputId = ns("remove_envir"),
                        label = "Remove Object",
                        icon = shiny::icon(
                          "remove"
                        ),
                        style = "background-color: #e74c3c; border: 1px solid #f2f2f2;"
                      )
                    )
                  ),
                  shiny::uiOutput(
                    outputId = ns("envir_modal")
                  )
                )

              )
            ),
            shiny::includeScript(
              path = "modalActive.js"
            ),
            easyClose = TRUE,
            size = "xl",
            style = "padding: 0px; height:75vh;"
          )
        )
      })

      # observe modal tabs ----
      shiny::observeEvent(input$envir_str, {
        ide$tab_modal <- "structure"
      })
      shiny::observeEvent(input$envir_table, {
        ide$tab_modal <- "table"
      })
      shiny::observeEvent(input$envir_list, {
        ide$tab_modal <- "list"
      })

      # observe remove from environment ----
      shiny::observeEvent(input$remove_envir, {
        object <- as.character(ide$envir[["Object"]][environment_selected()])
        base::rm(list = object, envir = .GlobalEnv)
        base::gc()

        ev <- ls(.GlobalEnv)
        cl <- as.character(lapply(mget(ev, envir = .GlobalEnv), class))
        df_envir <- data.frame(
          Object = ev,
          Class = cl
        ) |>
          filter(!Object %in% ignore)
        ide$envir <- df_envir
      })

      # ui environment
      output$ls <- reactable::renderReactable({
        if(!is.null(ide$envir)){
          reactable::reactable(
            ide$envir,
            height = "100%",
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

      # ui packages ----
      output$pak <- reactable::renderReactable({
        if(!is.null(ide$pak)){
          reactable::reactable(
            ide$pak,
            height = "100%",
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

      # ui environment modal ----
      output$envir_modal <- renderUI({
        if(input$envir_modal_sample == "head"){
          shiny::req(input$n)
          d <- head(
            get(
              ide$envir[["Object"]][environment_selected()],
              envir = .GlobalEnv
            ),
            n = input$n
          )
        }else if(input$envir_modal_sample == "tail"){
          shiny::req(input$n)
          d <- tail(
            get(
              ide$envir[["Object"]][environment_selected()],
              envir = .GlobalEnv
            ),
            n = input$n
          )
        }else{
          d <- get(
            ide$envir[["Object"]][environment_selected()],
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

      # ui modal dynamic
      output$envir_modal_sample_n <- renderUI({
        if(input$envir_modal_sample %in% c("head", "tail")){
          shiny::numericInput(
            inputId = ns("n"),
            label = "N Rows",
            value = 100
          )
        }else if(input$envir_modal_sample == "none"){

        }
      })
    }
  )
}
