ui_explore <- function(id="explore"){
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::tags$div(
      shiny::fluidRow(
        class = "m-0",
        style = "height: 35px;",
        shiny::fluidRow(
          shiny::column(
            width = 1,
            style = "padding:5px; width: 15%;",
            shiny::actionButton(
              inputId = ns("menu_data"),
              label = "Data",
              width = "100%",
              icon = shiny::icon(
                name = "table"
              ),
              style = "padding: 1px; font-size: 14px;"
            ),
          ),
          shiny::column(
            width = 1,
            style = "padding:5px; width: 15%;",
            shiny::actionButton(
              inputId = ns("menu_visual"),
              label = "Visual",
              width = "100%",
              icon = shiny::icon(
                name = "bar-chart"
              ),
              style = "padding: 1px; font-size: 14px;"
            ),
          ),
          shiny::column(
            width = 1,
            style = "padding:5px; width: 15%;",
            shiny::actionButton(
              inputId = ns("menu_model"),
              label = "Model",
              width = "100%",
              icon = shiny::icon(
                name = "lightbulb"
              ),
              style = "padding: 1px; font-size: 14px;"
            ),
          )
        )
      ),
      shiny::fluidRow(
        class = "m-0",
        style = "height: calc(100vh - 61px);",
        bslib::card(
          height = "100%",
          style = "padding: 0px;",
          full_screen = TRUE,
          fill = TRUE,
          bslib::card_header(
            style = "padding: 0px;",
            shiny::uiOutput(
              outputId = ns("bi_header")
            ) 
          ),
          bslib::layout_sidebar(
            sidebar = bslib::sidebar(
              shiny::uiOutput(
                outputId = ns("bi_sidebar")
              ),
              fillable = TRUE,
              fill = TRUE
            ),
            bslib::card_body(
              style = "padding: 0px;",
              shiny::uiOutput(
                outputId = ns("bi_content")
              )
            )
          )
        )
      )
    ),
    shiny::includeScript(
      path = "www/bi.js"
    )
  )
  
}

server_explore <- function(id="explore", ide){
  
  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns
      
      # reactives
      df_selected <- shiny::reactive({
        select <- reactable::getReactableState("bi_dataframes", "selected")
      })
      
      data <- shiny::reactive({
        shiny::req(df_selected())
        
        df <- get(ide$df[df_selected(), ])
        ide$df_vars <- colnames(df)
        return(df)
      })
      
      # observe input state
      shiny::observeEvent(input$menu_data, {
        ide$menu <- "data"
      })
      
      shiny::observeEvent(input$menu_visual, {
        ide$menu <- "visual"
      })
      
      shiny::observeEvent(input$menu_model, {
        ide$menu <- "model"
      })
      
      shiny::observeEvent(df_selected(), {
        ide$df_selected <- df_selected()
      })
      
      shiny::observeEvent(input$add_visual, {
        shiny::insertUI(
          selector = paste0("#", ns("add_visual")),
          where = "afterEnd",
          ui = shiny::tagList(
            shiny::actionButton(
              inputId = "viz2",
              label = "Viz-2",
              style = "width: 10%; font-size: 80%; padding: 0px; border: 1px solid white;"
            )
          )
        )
      })
      
      shiny::observeEvent(input$add_model, {
        shiny::insertUI(
          selector = paste0("#", ns("add_model")),
          where = "afterEnd",
          ui = shiny::tagList(
            shiny::actionButton(
              inputId = "mod2",
              label = "Mod-2",
              style = "width: 10%; font-size: 80%; padding: 0px; border: 1px solid white;"
            )
          )
        )
      })
      
      # ui outputs
      output$bi_header <- shiny::renderUI({
        
        if(ide$menu == "data"){
          
          shiny::tagList(
            shiny::fluidRow(
              class = "m-0",
              shiny::actionButton(
                inputId = ns("data_tab_table"),
                label = "Table",
                style = "width: 10%; font-size: 12px; padding: 0px; border: 1px solid white;"
              )
            )
          )
          
        }else if(ide$menu == "visual"){
          
          shiny::tagList(
            shiny::fluidRow(
              class = "m-0",
              shiny::actionButton(
                inputId = ns("add_visual"),
                label = NULL,
                style = "width: 10%; font-size: 12px; padding: 0px; border: 1px solid white;",
                icon = shiny::icon(
                  "plus"
                )
              ),
              shiny::actionButton(
                inputId = ns("viz1"),
                label = "Viz-1",
                style = "width: 10%; font-size: 12px; padding: 0px; border: 1px solid white;"
              )
            )
          )
          
        }else if(ide$menu == "model"){
          
          shiny::tagList(
            shiny::fluidRow(
              class = "m-0",
              shiny::actionButton(
                inputId = ns("add_model"),
                label = NULL,
                style = "width: 10%; font-size: 12px; padding: 0px; border: 1px solid white;",
                icon = shiny::icon(
                  "plus"
                )
              ),
              shiny::actionButton(
                inputId = ns("mod1"),
                label = "Mod-1",
                style = "width: 10%; font-size: 12px; padding: 0px; border: 1px solid white;"
              )
            )
          )
          
        }
        
      })
      
      output$bi_sidebar <- shiny::renderUI({
        
        if(ide$menu == "data"){
          shiny::tagList(
            reactable::reactableOutput(
              outputId = ns("bi_dataframes")
            )
          )
        }else if (ide$menu == "visual"){
          shiny::tagList(
            shiny::selectizeInput(
              inputId = "select_plot",
              label = "Choose a Visual",
              choices = list(
                `Table` = c("Pivot Table", "Table"),
                `Distribution` = c("Histogram", "Density", "Boxplot", "Word Cloud", "Probability Plot"),
                `Aggregate` = c("Barplot", "Stacked Barplot", "3D Barplot", "Heatmap", "Radar", "Piechart", "Donut", "Rosetype"),
                `Time Series` = c("Line", "Area", "Step", "River", "Autocorrelation", "Partial Autocorr"),
                `Relationship` = c("Correlogram", "Parallel", "Scatter", "3D Scatter", "Copula", "3D Copula"),
                `Evaluation` = c("Residuals", "Residuals Scatter", "Partial Dependence Line", "Partial Dependence Heatmap", "Calibration Line", "Calibration Boxplot", "Variable Importance", "Shapley Importance", "ROC Plot", "Confusion Matrix", "Gains", "Lift")
              ),
              options = list(placeholder = "Visual Type..."),
              selected = "Line",
              multiple = FALSE
            ),
            shiny::uiOutput("bi_plots")
          )
        }else if(ide$menu == "model"){
          shiny::tags$h3("model")
        }
        
        
      })
      
      output$bi_content <- shiny::renderUI({
        
      })
      
      output$bi_dataframes <- reactable::renderReactable({
        # shiny::req(ide$df_selected)
        if(!is.null(ide$df)){
          reactable::reactable(
            data = ide$df,
            minRows = 10,
            height = "45vh",
            searchable = TRUE,
            highlight = TRUE,
            onClick = "select",
            selection = "single",
            pagination = FALSE,
            pageSizeOptions = 10,
            wrap = FALSE,
            compact = TRUE,
            borderless = FALSE,
            defaultSelected = df_selected(),
            language = reactableLang(
              searchPlaceholder = "Search...",
              noData = "No Match",
            ),
            theme = reactableTheme(
              color = "black",
              backgroundColor = "#f2f2f2",
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
        }
        
      })
      
      
    }
  )
}