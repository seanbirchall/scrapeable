ui_controls <- function(id="controls"){
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::tags$div(
      style = "height: 100vh; width: 100%; overflow: hidden;",
      shiny::fluidRow(
        class = "m-0",
        style = "height: 100vh;",
        bslib::card(
          height = "100%",
          style = "padding: 0px;",
          full_screen = FALSE,
          fill = TRUE,
          bslib::card_header(
            style = "padding: 0px; background-color: #eee;",
            shiny::fluidRow(
              class = "m-0",
              column(
                width = 10,
                align = "left",
                style = "padding: 0px;",
                shiny::actionButton(
                  inputId = ns("tab_environment"),
                  label = "Environment",
                  style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid #f2f2f2; background-color: #eee; color: black; font-weight: 600;"
                ),
                shiny::actionButton(
                  inputId = ns("tab_viewer"),
                  label = "Viewer",
                  style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid #f2f2f2; background-color: #eee; color: black; font-weight: 600;"
                ),
                shiny::actionButton(
                  inputId = ns("tab_explore"),
                  label = "Explore",
                  style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid #f2f2f2; background-color: #eee; color: black; font-weight: 600;"
                )
              ),
              column(
                width = 2,
                align = "right",
                style = "padding: 0px;",
                shiny::actionButton(
                  inputId = "share",
                  label = "Share",
                  style = "width: 80px; font-size: 80%; padding: 0px; border: 1px solid #eee; background-color: #eee; color: black;",
                  icon = shiny::icon(
                    "share-nodes"
                  )
                ) %>%
                  bslib::tooltip("Create Link", placement = "bottom")
              )
            )
          ),
          bslib::card_body(
            style = "padding: 0px; margin: 0px;",
            height = "100%",
            uiOutput(ns("control"))
          )
        )
      )
    )
  )
  
}

server_controls <- function(id="controls", ide){
  
  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # observe input state
      shiny::observeEvent(input$tab_environment, {
        ide$tab <- "environment"
      })
      
      shiny::observeEvent(input$tab_viewer, {
        ide$tab <- "viewer"
      })
      
      shiny::observeEvent(input$tab_explore, {
        ide$tab <- "explore"
      })
      
      shiny::observeEvent(ide$code, {
        message("Watching Code")
        
        ev <- ls(.GlobalEnv)
        cl <- as.character(lapply(mget(ev, envir = .GlobalEnv), class))
        df_envir <- data.frame(
          Object = ev,
          Class = cl
        ) %>%
          filter(!Object %in% c("server_console", "server_controls", "server_editor", "ui_console", "ui_controls", "ui_editor", "ui_environment"))

        ide$envir <- df_envir
        
        df_envir <- df_envir %>%
          filter(grepl("data.frame|tbl|tbl_df|data.table", Class, ignore.case = TRUE)) %>%
          select(DataFrames = Object)
        
        ide$df <- dplyr::bind_rows(
          ide$df,
          df_envir
        ) %>%
          distinct(DataFrames)
        
        df_pak <- sessionInfo()[["otherPkgs"]]
        df_pak <- purrr::map_df(seq_along(df_pak), function(x){
          data.frame(
            Package = df_pak[[x]][["Package"]],
            Title = df_pak[[x]][["Title"]],
            Version = df_pak[[x]][["Version"]]
          )
        })
        
        ide$pak <- df_pak
        
      }, ignoreInit = TRUE)
      
      shiny::observeEvent(ide$view, {
        message("watching Viewer")
        
        shinyjs::delay(1, shinyjs::click(id = "tab_viewer"))
        
      }, ignoreInit = TRUE)
      
      
      # ui outputs
      output$control <- shiny::renderUI({
        
        if(ide$tab == "environment"){
          
          ui_environment(
            id = "environment"
          )
          
        }else if(ide$tab == "viewer"){
          
          ui_viewer(
            id = "viewer"
          )
          
        }else if(ide$tab == "explore"){
          
          ui_explore(
            id = "explore"
          )
          
        }else if(ide$tab == "help"){
          
        }
        
      })
      
    }
  )
  
}