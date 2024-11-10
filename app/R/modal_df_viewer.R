server_modal_df_viewer <- function(id="modal_df_viewer", ide){

  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # show modal ----
      observeEvent(ide$modal_df_viewer, {
        shiny::req(
          ide$environment_selected,
          ide$modal_df_viewer
        )
        body <- df_viewer_modal_input(
          data = ide$environment_selected[["data"]],
          op = ide$modal_df_viewer
        )
        showModal(
          modal(
            header = "Commands",
            body = body[["html"]],
            footer = NULL,
            height = NULL
          )
        )
      })

      # apply operation ----
      observeEvent(input$apply, {
        out <- df_viewer_modal_output(
          data = ide$environment_selected[["data"]],
          op = ide$modal_df_viewer,
          input = input
        )
        ide$environment_selected[["data"]] <- out[["data"]]
        ide$environment_selected[["code"]] <- c(ide$environment_selected[["code"]], out[["code"]])
        removeModal()
      })

      # cancel operation ----
      observeEvent(input$cancel, {
        removeModal()
      })

      modal <- function(header=tagList(), body=tagList(), footer=tagList(), height="60vh", easyClose=T){
        ns <- getDefaultReactiveDomain()$ns
        modalDialog(
          title = NULL,
          easyClose = easyClose,
          footer = NULL,
          style = "padding: 0px; margin: 0px; gap: 0px;",
          bslib::card(
            style = "padding: 0px; margin: 0px; gap: 0px;",
            height = height,
            full_screen = FALSE,
            fill = FALSE,
            id = ns("content"),
            class = "overflow-visible",
            bslib::card_header(
              style = "padding: 0px; margin: 0px; gap: 0px; height: 24px;",
              shiny::tags$div(
                style = "display: flex; justify-content: flex-start; margin-left: 5px;",
                header
              )
            ),
            bslib::card_body(
              style = "padding: 0px; margin: 0px; gap: 0px;",
              fillable = FALSE,
              fill = FALSE,
              class = "overflow-visible",
              body
            ),
            bslib::card_footer(
              style = "padding: 8px; margin: 0px; gap: 0px; height: 40px;",
              shiny::tags$div(
                style = "display: flex; justify-content: flex-end;",
                shiny::actionButton(
                  inputId = ns("apply"),
                  label = "Ok",
                  class = "button-ok"
                ) |>
                  bslib::tooltip("Ctrl+Enter", placement = "bottom"),
                shiny::actionButton(
                  inputId = ns("cancel"),
                  label = "Cancel",
                  class = "button-cancel"
                ) |>
                  bslib::tooltip("Esc", placement = "bottom")
              )
            )
          )
        )
      }

      df_viewer_modal_input <- function(data, op){
        action <- op[["action"]]
        column <- op[["column"]]
        columns <- names(data)
        el <- NULL
        add_rm <- NULL

        if (action == "rename") {
          el <- shiny::tagList(
            shiny::selectizeInput(
              inputId = ns("column"),
              label = "Column",
              choices = columns,
              selected = column,
              multiple = TRUE,
              width = "100%",
              options = list(
                maxItems = 1
              )
            ) |>
              shiny::tagAppendAttributes(
                class = "selectize-sm no-margin"
              ),
            shiny::textInput(
              inputId = ns("name"),
              label = "New Name",
              width = "100%"
            ) |>
              shiny::tagAppendAttributes(
                class = "input-sm no-margin"
              )
          )
          add_rm <- TRUE
        } else if (action == "select") {
          el <- shiny::tagList(
            shiny::selectizeInput(
              inputId = ns("columns"),
              label = "Column",
              choices = columns,
              selected = columns,
              multiple = TRUE,
              width = "100%",
              options = list(
                plugins = list('remove_button')
              )
            ) |>
              shiny::tagAppendAttributes(
                class = "selectize-sm"
              )
          )
          add_rm <- FALSE
        } else if (action == "reorder:asc") {

        } else if (action == "reorder:desc") {

        } else if (action == "reorder:manual") {
          el <- shiny::tagList(
            shiny::fluidRow(
              shiny::column(
                width = 9,
                class = "m-0",
                shiny::selectizeInput(
                  inputId = ns("column"),
                  label = "Column",
                  choices = columns,
                  selected = column,
                  multiple = TRUE,
                  width = "100%",
                  options = list(
                    plugins = list('remove_button')
                  )
                ) |>
                  shiny::tagAppendAttributes(
                    class = "selectize-sm"
                  )
              ),
              shiny::column(
                width = 3,
                class = "m-0",
                shiny::radioButtons(
                  inputId = ns("direction"),
                  label = "Direction",
                  choiceNames = c("Ascending", "Descending"),
                  choiceValues = c("asc", "desc"),
                  inline = TRUE
                )
              )
            )
          )
        } else if (action == "filter:isequalto") {
          # Filter is equal to logic
        } else if (action == "filter:isnotequalto") {
          # Filter is not equal to logic
        } else if (action == "filter:isin") {
          # Filter is in logic
        } else if (action == "filter:isnotin") {
          # Filter is not in logic
        } else if (action == "filter:contain") {
          # Filter contains logic
        } else if (action == "filter:doesnotcontain") {
          # Filter does not contain logic
        } else if (action == "distinct") {
          # Distinct logic
        } else if (action == "groupby") {
          # Group by logic
        } else if (action == "summarize") {
          # Summarize logic
        } else if (action == "calc") {
          # Calculation logic
        } else if (action == "windowcalc") {
          # Window calculation logic
        } else if (action == "arrange:asc") {
          # Arrange ascending logic
        } else if (action == "arrange:desc") {
          # Arrange descending logic
        } else if (action == "join") {
          # Join logic
        } else if (action == "update") {
          # Update logic
        } else if (action == "append") {
          # Append logic
        } else if (action == "pivotlonger") {
          # Pivot longer logic
        } else if (action == "pivotwider") {
          # Pivot wider logic
        } else if (action == "separate") {
          # Separate logic
        } else if (action == "unite") {
          # Unite logic
        } else if (action == "cross") {
          # Cross logic
        } else if (action == "change:numeric") {
          # Change to numeric logic
        } else if (action == "change:date") {
          # Change to date logic
        } else if (action == "change:time") {
          # Change to time logic
        } else if (action == "change:character") {
          # Change to character logic
        } else if (action == "change:logical") {
          # Change to logical logic
        } else if (action == "change:factor") {
          # Change to factor logic
        } else {
          # Default case or error handling
          stop("Unsupported action:", action)
        }

        if(add_rm){
          add_rm <- shiny::tags$div(
            style = "display: flex; justify-content: flex-start; margin-top: 10px;",
            shiny::actionButton(
              inputId = ns("add"),
              label = NULL,
              class = "button-add",
              icon = shiny::icon("plus")
            ) |>
              bslib::tooltip("Duplicate Inputs", placement = "bottom"),
            shiny::actionButton(
              inputId = ns("remove"),
              label = NULL,
              class = "button-remove",
              icon = shiny::icon("xmark")
            ) |>
              bslib::tooltip("Remove Inputs", placement = "bottom")
          )
        }else{
          add_rm <- NULL
        }

        inp <- list(
          html = shiny::tags$div(
            el,
            add_rm,
            style = "max-height: 45vh; min-height: auto; width: 100%; padding: 5px;"
          )
        )
        return(inp)
      }

      df_viewer_modal_output <- function(data, op, input){
        action <- op[["action"]]
        column <- op[["column"]]
        columns <- names(data)
        code <- NULL
        if(action == "rename"){
          req(input$name, input$column)
          code <- paste0(
            "dplyr::rename(data,",
            input$name,
            "=",
            input$column,
            ")"
          )
          data <- tryCatch(
            eval(parse(text = code)),
            error = function(e) NULL
          )
        }
        if(action == "select"){
          req(input$columns)
          code <- paste0(
            "dplyr::select(data, c(",
            paste(input$columns, collapse = ","),
            "))"
          )
          data <- tryCatch(
            eval(parse(text = code)),
            error = function(e) NULL
          )
        }
        return(
          list(
            data = data,
            code = code
          )
        )
      }

    }
  )
}
