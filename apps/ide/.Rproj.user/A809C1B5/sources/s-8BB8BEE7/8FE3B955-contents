
source("R/global.R")

options(launch.browser = FALSE)

ui <- bslib::page(
  
  shinyjs::useShinyjs(),
  
  title = "webR IDE",
  
  theme = bslib::bs_theme(
    preset = "flatly",
    font_scale = 0.95, 
    `enable-rounded` = FALSE, 
    `enable-transitions` = FALSE
  ),
  
  shinybusy::add_busy_spinner(
    timeout = 500,
    spin = "half-circle",
    color = "#f39c12",
    position = "bottom-left",
    height = "10%",
    width = "10%"
  ),
  
  shiny::tags$head(
    shiny::tags$link(
      rel = "stylesheet", href = "style.css"
    )
  ),
  
  shiny::tags$body(
    shiny::tags$div(
      class = "split",
      shiny::tags$div(
        id = "pane-code",
        shiny::tags$div(
          id = "pane-editor",
          ui_editor(
            id = "editor"
          )
        ),
        shiny::tags$div(
          id = "pane-console",
          ui_console(
            id = "console"
          )
        )
      ),
      shiny::tags$div(
        id = "pane-control",
        ui_controls(
          id = "controls"
        )
      )
    )
  ),
  
  shiny::includeScript(
    path = "https://cdnjs.cloudflare.com/ajax/libs/split.js/1.6.2/split.min.js"
  ),
  shiny::includeScript(
    path = "https://cdn.jsdelivr.net/npm/js-md5@0.8.3/src/md5.min.js"
  ),
  shiny::includeScript(
    path = "www/custom.js"
  )
  
)

server <- function(input, output, session){
  
  # values to pass to components
  ide <- shiny::reactiveValues(
    # global
    envir = NULL,
    pak = NULL,
    view = NULL,
    # code
    hash = NULL,
    evals = NULL,
    code = NULL,
    # navigation
    tab = "environment",
    tab_modal = "structure",
    menu = "data",
    tab_data = "table",
    tab_visual = "viz1",
    tab_model = "mod1",
    # table selections
    df_selected = NULL,
    obj_selected = NULL,
    # explore
    df = NULL,
    df_vars = NULL
  )
  
  # check for code
  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query[['code']])) {
      message("Checking Hash ")
 
    }
  })
  
  server_editor(
    id = "editor",
    ide = ide
  )
  
  server_console(
    id = "console",
    ide = ide
  )
  
  server_controls(
    id = "controls",
    ide = ide
  )
  
  server_environment(
    id = "environment",
    ide = ide
  )
  
  server_explore(
    id = "explore",
    ide = ide
  )
  
  server_viewer(
    id = "viewer",
    ide = ide
  )
  
  do <- list(
    code = c("iris %>%\n mutate(n=n())"),
    enviornment = list(
      objects = c(""),
      packages = c("dplyr", "tidyr", "readxl")
    ),
    viewer = c(""),
    explore = c(""),
    description = c(""),
    id = c(""),
    user = c("")
  )
  
  shiny::observeEvent(input$share, {
    
    shinyjs::runjs(
      "var editor = ace.edit('editor-Ace');
       var editorValue = editor.getValue();
       var editorHash = md5(editorValue);
       
       // previous hash
       var previousEditorHash = Shiny.shinyapp.$values.editorHash;
       
       if(editorHash !== previousEditorHash && editorValue.length > 1){
        fetch('https://httpbin.org/post', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(
            {
              'code': editorValue,
              'id': editorHash
            }
          )
        })
        .then(response => response.json())
        .then(data => {
          Shiny.setInputValue('editorHash', editorHash);
        })
        .catch(error => console.error('Error:', error));
       }
      "
    )
    
    shiny::showModal(
      shiny::modalDialog(
        title = "IDE URL",
        shiny::fluidRow(
          shiny::column(
            width = 9,
            shiny::textInput(
              inputId = "share_text",
              label = NULL,
              width = "100%",
              value = paste0("https://www.scrapeable.com/?ide=", ide$hash)
            )
          ),
          shiny::column(
            width = 3,
            shiny::actionButton(
              inputId = "share_ide",
              label = "Copy URL",
              width = "100%",
              icon = shiny::icon(
                "link"
              )
            )
          )
        ),
        easyClose = TRUE,
        footer = NULL,
        size = "l"
      )
    )
    
  })
  
}

shiny::shinyApp(ui = ui, server = server)
