ui_control_viewer_df <- function(id="df_viewer"){
  ns <- shiny::NS(id)

  shinyjs::hidden(
    shiny::tagList(
      bslib::card(
        id = ns("container"),
        fill = TRUE,
        full_screen = FALSE,
        style = "height: 100vh;",
        bslib::card_header(
          style = "padding: 0px; margin: 0px; gap: 0px; height: 24px;",
          uiOutput(
            outputId = ns("toolbar"),
            class = "header-div-card-left2"
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
  )
}


server_control_viewer_df <- function(id="df_viewer", ide){

  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # show ----
      observeEvent(ide$viewer_window, {
        shinyjs::toggle(id = "container", time = 0, condition = ide$viewer_window[["type"]] == "df_viewer")
      })

      # hide ----
      observeEvent(ide$viewer_clear, {
        shinyjs::hide(id = "container", time = 0)
      })

      # toolbar ----
      output$toolbar <- shiny::renderUI({
        shiny::req(ide$environment_selected[["data"]])
        rows <- format(nrow(ide$environment_selected[["data"]]), big.mark = ",", scientific = FALSE)
        columns <- format(ncol(ide$environment_selected[["data"]]), big.mark = ",", scientific = FALSE)

        tagList(
          shiny::tags$div(
            style = "display: flex; align-items: center; margin-right: 5px;",
            shiny::tags$p(
              "Track:",
              style = "font-size: 12px; margin: 0 5px 0 0;"
            ),
            shiny::checkboxInput(
              inputId = ns("track"),
              label = NULL,
              value = ide$df_viewer[["track"]] %||% FALSE,
              width = "20px"
            )
          ),

          shiny::tags$div(
            style = "display: flex; align-items: center; margin-right: 10px;",
            shiny::tags$p(
              paste("Rows:", rows),
              style = "font-size: 12px; margin: 0 5px 0 0;"
            ),
            shiny::selectInput(
              inputId = ns("rows"),
              label = NULL,
              choices = list(
                First = list(`→50` = 50, `→100` = 100, `→200` = 200, `→500` = 500, `→1000` = 1000),
                Last = list(`←50` = -50, `←100` = -100, `←200` = -200, `←500` = -500, `←1000` = -1000)
              ),
              selectize = FALSE,
              selected = ide$df_viewer[["rows"]] %||% 50,
              width = "75px"
            )
          ),

          shiny::tags$div(
            style = "display: flex; align-items: center; margin-right: 10px;",
            shiny::tags$p(
              paste("Columns:", columns),
              style = "font-size: 12px; margin: 0 5px 0 0;"
            ),
            shiny::selectInput(
              inputId = ns("columns"),
              label = NULL,
              choices = list(
                First = list(`→100` = 100),
                Last = list(`←100` = -100)
              ),
              selectize = FALSE,
              selected = ide$df_viewer[["columns"]] %||% 100,
              width = "75px"
            )
          ),

          shiny::tags$div(
            style = "display: flex; align-items: center; margin-right: 10px;",
            shiny::tags$p(
              "Index From:",
              style = "font-size: 12px; margin: 0 5px 0 0;"
            ),
            shiny::numericInput(
              inputId = ns("index"),
              label = NULL,
              value = ide$df_viewer[["index"]] %||% 1,
              min = 1,
              width = "100px"
            )
          ),

          shiny::tags$div(
            style = "display: flex; align-items: center;",
            shiny::actionButton(
              inputId = ns("code"),
              label = NULL,
              icon = shiny::icon("code"),
              class = "button-code"
            )
          )
        )
      })

      # track object changes ----
      observeEvent(input$track, {
        ide$df_viewer[["track"]] <- input$track
      })

      # rows ----
      observeEvent(input$rows, {
        ide$df_viewer[["rows"]] <- input$rows
      })

      # columns ----
      observeEvent(input$columns, {
        ide$df_viewer[["columns"]] <- input$columns
      })

      # index ----
      observeEvent(input$index, {
        ide$df_viewer[["index"]] <- input$index
      })

      # code ----
      observeEvent(input$code, {
        code <- paste(ide$environment_selected[["code"]], collapse = " |>\n")
        cat(code)
      })

      # df rows ----
      output$nrow <- shiny::renderUI({
        shiny::req(ide$environment_selected[["data"]])
        rows <- format(nrow(ide$environment_selected[["data"]]), big.mark = ",", scientific = FALSE)
        shiny::tags$p(
          paste("Rows:", rows),
          style = "font-size: 12px; margin-left: -35px;"
        )
      })

      # df cols ----
      output$ncol <- shiny::renderUI({
        shiny::req(ide$environment_selected[["data"]])
        columns <- format(ncol(ide$environment_selected[["data"]]), big.mark = ",", scientific = FALSE)
        shiny::tags$p(
          paste("Columns:", columns),
          style = "font-size: 12px; margin-left: 10px;"
        )
      })

      # df index ----
      output$start <- shiny::renderUI({
        shiny::req(ide$environment_selected[["data"]])
        shiny::tags$p(
          "Index From:",
          style = "font-size: 12px; margin-left: 10px;"
        )
      })

      # df-viewer ----
      output$spreadsheet <- renderdfViewer({
        shiny::req(ide$environment_selected[["data"]], input$index, input$rows, input$columns)
        df <- ide$environment_selected[["data"]]
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
          df <- data.frame(x1=NA_character_)
        }

        df_viewer(
          data = df,
          colHeaders = names(df),
          width = "100%",
          menu_items = list(
            rename = list(
              name = "Rename",
              submenu = list(
                list(key = "rename", name = "✚", value = "rename"),
                list(name = "---------"),
                list(key = "rename:lower", name = "To Lower", value = "rename:lower"),
                list(key = "rename:upper", name = "To Upper", value = "rename:upper"),
                list(key = "rename:snake", name = "To Snake", value = "rename:snake"),
                list(key = "rename:title", name = "To Title", value = "rename:title"),
                list(key = "rename:unique", name = "To Unique", value = "rename:unique")
              )
            ),

            select = list(
              name = "Select Columns (Remove)",
              submenu = list(
                list(key = "select", name = "✚", value = "select"),
                list(name = "---------"),
                list(key = "select:selected", name = "Selected Column", value = "select:selected"),
                list(key = "select:starts", name = "Starts With", value = "select:starts"),
                list(key = "select:ends", name = "Ends With", value = "select:ends"),
                list(key = "select:contain", name = "Contains", value = "select:contain")
              )
            ),

            reorder = list(
              name = "Reorder Columns",
              submenu = list(
                list(key = "reorder", name = "✚", value = "reorder"),
                list(name = "---------"),
                list(key = "reorder:ascending", name = "Ascending", value = "reorder:ascending"),
                list(key = "reorder:descending", name = "Descending", value = "reorder:descending")
              )
            ),
            separator = list(name = "---------"),

            filter = list(
              name = "Filter",
              submenu = list(
                list(key = "filter", name = "✚", value = "filter"),
                list(name = "---------"),
                list(key = "filter:equal", name = "Equal / Not Equal", value = "filter:equal"),
                list(key = "filter:in", name = "In / Not In", value = "filter:in"),
                list(key = "filter:pattern", name = "Pattern", value = "filter:pattern"),
                list(key = "filter:na", name = "Is NA", value = "filter:na")
              )
            ),

            distinct = list(
              name = "Distinct (Unique Rows)",
              submenu = list(
                list(key = "distinct", name = "✚", value = "distinct"),
                list(name = "---------"),
                list(key = "distinct:selected", name = "Selected Column", value = "distinct:selected"),
                list(key = "distinct:everything", name = "Everything", value = "distinct:everything")
              )
            ),

            groupby = list(
              name = "Group By",
              submenu = list(
                list(key = "groupby", name = "✚", value = "groupby"),
                list(name = "---------"),
                list(key = "groupby:selected", name = "Selected Column", value = "groupby:selected"),
                list(key = "groupby:everything", name = "Everything", value = "groupby:everything")
              )
            ),

            summarize = list(
              name = "Summarize (Aggregate)",
              value = "summarize"
            ),

            create = list(
              name = "Create Calculation",
              value = "create"
            ),

            arrange = list(
              name = "Arrange (Sort)",
              submenu = list(
                list(key = "arrange", name = "✚", value = "arrange"),
                list(name = "---------"),
                list(key = "arrange:ascending", name = "Ascending", value = "arrange:ascending"),
                list(key = "arrange:descending", name = "Descending", value = "arrange:descending")
              )
            ),
            separator = list(name = "---------"),

            join = list(
              name = "Join with DF (Add Columns)",
              value = "join"
            ),

            update = list(
              name = "Update / Insert",
              value = "update"
            ),

            append = list(
              name = "Append (Add Rows)",
              value = "append"
            ),

            pivotlonger = list(
              name = "Pivot Longer (Wide to Long)",
              submenu = list(
                list(key = "pivotlonger", name = "✚", value = "pivotlonger"),
                list(name = "---------"),
                list(key = "pivotlonger:selected", name = "Selected Column", value = "pivotlonger:selected"),
                list(key = "pivotlonger:everything", name = "Everything", value = "pivotlonger:everything")
              )
            ),

            pivotwider = list(
              name = "Pivot Wider (Long to Wide)",
              submenu = list(
                list(key = "pivotwider", name = "✚", value = "pivotwider"),
                list(name = "---------"),
                list(key = "pivotwider:selected", name = "Selected Column", value = "pivotwider:selected"),
                list(key = "pivotwider:everything", name = "Everything", value = "pivotwider:everything")
              )
            ),

            separate = list(
              name = "Separate (Text to Columns)",
              submenu = list(
                list(key = "separate", name = "✚", value = "separate"),
                list(name = "---------"),
                list(key = "separate:selected", name = "Selected Column", value = "separate:selected"),
                list(key = "separate:everything", name = "Everything", value = "separate:everything")
              )
            ),

            unite = list(
              name = "Unite (Columns)",
              value = "unite"
            ),

            cross = list(
              name = "Crossing (Cartesian Product)",
              value = "cross"
            ),
            separator = list(name = "---------"),

            change = list(
              name = "Column Data Type",
              submenu = list(
                list(key = "change:numeric", name = "Numeric", value = "change:numeric"),
                list(key = "change:date", name = "Date", value = "change:date"),
                list(key = "change:time", name = "Time", value = "change:time"),
                list(key = "change:logical", name = "Logical", value = "change:logical"),
                list(key = "change:factor", name = "Factor", value = "change:factor")
              )
            ),

            replace = list(
              name = "Replace Values",
              submenu = list(
                list(key = "replace", name = "✚", value = "replace"),
                list(name = "---------"),
                list(key = "replace:na", name = "Is NA", value = "replace:na"),
                list(key = "replace:empty", name = "Is Empty", value = "replace:empty"),
                list(key = "replace:pattern", name = "Pattern", value = "replace:pattern")
              )
            )
          )
        )
      })

      # action ----
      shiny::observeEvent(input$spreadsheet_action, {
        print(input$spreadsheet_action)
      })
    }
  )
}
