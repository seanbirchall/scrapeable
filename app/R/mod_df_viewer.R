ui_mod_df_viewer <- function(id="df_viewer"){
  ns <- shiny::NS(id)

  shiny::tagList(
    bslib::card(
      id = ns("view"),
      fill = TRUE,
      full_screen = FALSE,
      style = "height: 100vh;",
      bslib::card_header(
        style = "padding: 0px; margin: 0px; gap: 0px; height: 20px;",
        fluidRow(
          class = "m-0",
          shiny::column(
            width = 12,
            class = "c-0",
            shiny::tags$div(
              class = "header-div-card-left",
              shiny::uiOutput(
                outputId = ns("nrow"),
              ),
              shiny::selectInput(
                inputId = ns("rows"),
                label = NULL,
                choices = list(
                  First = list(`→50` = 50, `→100` = 100, `→200` = 200, `→500` = 500, `→1000` = 1000),
                  Last = list(`←50` = -50, `←100` = -100, `←200` = -200, `←500` = -500, `←1000` = -1000)
                ),
                selectize = FALSE,
                selected = 50,
                width = "75px"
              ),
              shiny::uiOutput(
                outputId = ns("ncol")
              ),
              shiny::selectInput(
                inputId = ns("columns"),
                label = NULL,
                choices = list(
                  First = list(`→100` = 100),
                  Last = list(`←100` = -100)
                ),
                selectize = FALSE,
                selected = 100,
                width = "75px"
              ),
              shiny::uiOutput(
                outputId = ns("start")
              ),
              shiny::numericInput(
                inputId = ns("index"),
                label = NULL,
                value = 1,
                min = 1,
                width = "100px"
              )
            )
          )
        )
      ),
      bslib::card_body(
        style = "padding:0px;",
        fillable = TRUE,
        fill = TRUE,
        dfViewerOutput(
          outputId = ns("spreadsheet")
        )
      )
    )
  )
}


server_mod_df_viewer <- function(id="df_viewer", ide){

  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # df rows ----
      output$nrow <- shiny::renderUI({
        rows <- format(nrow(ide$environment_selected), big.mark = ",", scientific = FALSE)
        shiny::tags$p(
          paste("Rows:", rows),
          style = "font-size: 12px; margin-left: -35px;"
        )
      })

      # df cols ----
      output$ncol <- shiny::renderUI({
        columns <- format(ncol(ide$environment_selected), big.mark = ",", scientific = FALSE)
        shiny::tags$p(
          paste("Columns:", columns),
          style = "font-size: 12px; margin-left: 10px;"
        )
      })

      # df index ----
      output$start <- shiny::renderUI({
        shiny::tags$p(
          "Index From:",
          style = "font-size: 12px; margin-left: 10px;"
        )
      })

      # df-viewer ----
      output$spreadsheet <- renderdfViewer({
        shiny::req(ide$environment_selected, input$index, input$rows, input$columns)
        df <- ide$environment_selected
        # Logic for start index
        start_index <- as.integer(input$index)
        if(is.na(start_index) | start_index < 1){
          start_index <- 1
        }else if (start_index > nrow(df)){
          start_index <- nrow(df)
        }

        # Logic for rows
        row_count <- as.integer(input$rows)
        if(row_count > 0){
          # View first n rows
          end_index <- min(start_index + row_count - 1, nrow(df))
          df <- df[start_index:end_index, , drop = FALSE]
        }else{
          # View last n rows
          start_index <- max(1, nrow(df) + row_count + 1)
          df <- df[start_index:nrow(df), , drop = FALSE]
        }

        # Logic for columns
        col_count <- as.integer(input$columns)
        if (col_count > 0) {
          # View first n columns
          df <- df[, 1:min(col_count, ncol(df)), drop = FALSE]
        } else {
          # View last n columns
          col_start <- max(1, ncol(df) + col_count + 1)
          df <- df[, col_start:ncol(df), drop = FALSE]
        }

        if(is.null(df)){
          df <- data.frame()
        }

        df_viewer(
          data = df,
          colHeaders = names(df),
          width = "100%"
        )
      }) |>
        shiny::debounce(1000)
    }
  )
}
