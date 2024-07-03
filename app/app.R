ui <- bslib::page(

  # global ----
  shinyjs::useShinyjs(),
  title = "WebR IDE",
  theme = bslib::bs_theme(
    preset = "flatly",
    font_scale = 0.95,
    `enable-rounded` = FALSE,
    `enable-transitions` = FALSE
  ),

  # css ----
  shiny::tags$head(
    shiny::tags$link(
      rel = "stylesheet", type = "text/css", href = "style.css"
    ),
    shiny::tags$link(
      rel = "stylesheet", type = "text/css", href = "split.css"
    ),
    shiny::tags$link(
      rel = "stylesheet", type = "text/css", href = "w2ui.css"
    ),
    shiny::tags$link(
      rel = "stylesheet", type = "text/css", href = "w2ui-2.0.min.css"
    )
  ),

  # content ----
  bslib::card(
    class = "main-container",
    full_screen = FALSE,
    fill = TRUE,
    bslib::layout_sidebar(
      class = "container-sidebar-layout",
      sidebar = ui_sidebar(
        id = "sidebar"
      ),
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
          ui_control(
            id = "control"
          )
        )
      )
    )
  ),

  # js ----
  shiny::tags$footer(
    shiny::tags$script(
      type = "text/javascript", src = "split.min.JS"
    ),
    shiny::tags$script(
      type = "text/javascript", src = "w2ui-2.0.min.js"
    ),
    shiny::tags$script(
      type = "text/javascript", src = "w2ui.js"
    ),
    shiny::tags$script(
      type = "text/javascript", src = "active_tab.js"
    ),
    shiny::tags$script(
      type = "text/javascript", src = "modalActive.js"
    ),
    shiny::tags$script(
      type = "text/javascript", src = "authenticate.js"
    ),
    shiny::tags$script(
      type = "text/javascript", src = "copy_by_id.js"
    ),
    shiny::tags$script(
      type = "text/javascript", src = "keyboard_shortcuts.js"
    )
  )
)

server <- function(input, output, session) {

  # tab text w2ui['tabs'].get('tab2').text = 'new.r'; w2ui['tabs'].refresh();

  # on-load ide ----
  ide <- shiny::reactiveValues(
    tabs = list(
      tab1 = list(
        name = "script.R",
        code = ""
      )
    ),
    tabs_available = "tab1",
    tab_selected = "tab1",
    tab_extension = "r",
    tab_previous = NULL,
    history = NULL,
    last_run = "",
    last_code = "no-hash",
    show_login = 1,
    show_share = 1,
    environment = data.frame(
      Object = character(0),
      Class = character(0)
    )
  )

  # sub-modules ----
  server_sidebar(
    id = "sidebar",
    ide = ide
  )
  server_editor(
    id = "editor",
    ide = ide
  )
  server_console(
    id = "console",
    ide = ide
  )
  server_control(
    id = "control",
    ide = ide
  )

  # selected tab ----
  observeEvent(input$tab, {
    tab_new <- input$tab
    ide$tab_selected <- tab_new
    # save previous tab code
    if(!is.null(ide$tab_previous)){
      ide$tabs[[ide$tab_previous]][["code"]] <- input[["editor-ace"]]
    }
    # create new tab
    if(!tab_new %in% names(ide$tabs)){
      ide$tabs[[tab_new]][["code"]] <- ""
      tab_name <- paste0("script", gsub("[^0-9]", "", tab_new), ".R")
      ide$tabs[[tab_new]][["name"]] <- tab_name
      ide$tabs_available <- c(ide$tabs_available, tab_new)
    }
    # Update Ace with code
    updateAceEditor(
      session = session,
      editorId = "editor-ace",
      value = ide$tabs[[tab_new]][["code"]]
    )
    ide$tab_previous <- tab_new
  })

  # tab close ----
  observeEvent(input$tab_close, {
    tab_to_close <- input$tab_close
    ide$tabs_available <- ide$tabs_available[!ide$tabs_available %in% tab_to_close]
    ide$tabs <- ide$tabs[ide$tabs_available]
    if(tab_to_close == input$tab){
      tab_selected <- names(ide$tabs)[1]
      if(is.na(tab_selected)){
        shinyjs::click(
          id = "tabs_tabs_tab_add"
        )
      }else{
        shinyjs::click(
          id = paste0("tabs_tabs_tab_", tab_selected)
        )
      }
    }
  })

  # tab edited ----
  observeEvent(input$tab_edit, {
    tab_edit <- input$tab_edit
    tab_edited <- tab_edit[["tabId"]]
    tab_edited_name <- tab_edit[["newName"]]
    if(tab_edited %in% ide$tabs_available){
      ide$tabs[[tab_edited]][["name"]] <- tab_edited_name
    }
  })

  # on start observe query parameters ----
  shiny::observe({
    query <- parseQueryString(session$clientData$url_search)

    # ide query ----
    if(!is.null(query[['ide']])){
      if(nchar(query[['ide']]) == 36){
        lookup <- tryCatch(
          jsonlite::fromJSON(
            paste0(
              "https://scrapeable-share.nyc3.cdn.digitaloceanspaces.com/",
              query[['ide']],
              ".json"
            )
          )[["code"]],
          error = function(e){
            NULL
          }
        )
        if(!is.null(lookup)){
          ide$tabs <- lookup
          session$sendCustomMessage("initializeTabs", reactiveValuesToList(ide$tabs))
          # updateAceEditor(
          #   session = session,
          #   editorId = "editor-ace",
          #   value = lookup
          # )
        }
      }
    }

    # authentication ----
    if(!is.null(query[['code']])){
      body <- paste0(
        "grant_type=authorization_code&",
        "client_id=4u1auln0l9c8n3f0cjfaq6gpa1&",
        "redirect_uri=https://www.scrapeable.com/webR/&",
        "code=",
        query[['code']]
      )
      body_js <- jsonlite::toJSON(body, auto_unbox = TRUE)
      shinyjs::runjs(
        paste0(
          "tryAuth(", body_js, ");"
        )
      )
    }else{
      session$sendCustomMessage("refreshToken", list())
    }
  })

  # set token in session user data ----
  observeEvent(input$idToken, {
    session$userData$authentication <- input$idToken
  })

  # observe share link ----
  shiny::observeEvent(input$share, {
    if(!is.null(session$userData$authentication)){
      # share notification ----
      shiny::showNotification(
        ui = shiny::tagList(
          shiny::tags$div(
            shiny::tags$p(
              "Preparing Share Link"
            )
          )
        ),
        id = "share_notification",
        type = "message",
        duration = 20
      )

      # share tabs ----
      ide$tabs[[ide$tab_selected]][["code"]] <- input[["editor-ace"]]
      tabs <- ide$tabs
      tabs <- qs::base91_encode(
        qs::qserialize(
          tabs
        )
      )
      if(!identical(tabs, ide$last_tabs)){
        ide$last_tabs <- tabs
        id <- uuid::UUIDgenerate()
        ide$last_id <- id
        payload <- jsonlite::toJSON(
          data.frame(
            code = tabs,
            id = id
          ),
          auto_unbox = TRUE
        )
        print(qs::qdeserialize(
          qs::base91_decode(
            jsonlite::fromJSON(payload)[["code"]]
          )
        ))
      }else{
        id <- ide$last_id
      }

      # remove notification ----
      removeNotification(
        id = "share_notification"
      )

      # share modal ----
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
                value = paste0("https://www.scrapeable.com/webR/?ide=", id)
              )
            ),
            shiny::column(
              width = 3,
              shiny::actionButton(
                inputId = "share_ide",
                label = "Copy URL",
                icon = shiny::icon(
                  "link"
                ),
                onclick="copy_by_id('share_text', false)",
                style = "width: 150px;"
              )
            )
          ),
          easyClose = TRUE,
          footer = NULL,
          size = "xl"
        )
      )
    }else{
      shinyjs::click("sidebar-login")
      shiny::showNotification(
        ui = shiny::tagList(
          shiny::tags$div(
            shiny::tags$p(
              "Please Login to Share"
            )
          )
        ),
        type = "warning",
        duration = 5
      )
    }
  })

  # on start click ----
  shinyjs::click(
    id = "editor-run"
  )
  shinyjs::click(
    id = "tabs_tabs_tab_tab1"
  )
}

shinyApp(ui = ui, server = server)
