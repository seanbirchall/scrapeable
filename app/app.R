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
          ui_controls(
            id = "controls"
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

  # reactiveValues ----
  ide <- shiny::reactiveValues(
    tabs = list(
      tab1 = ""
    ),
    tabs_available = "tab1",
    tab_selected = "tab1",
    tab_extension = "r",
    tab_previous = NULL,
    last_code = "no-hash",
    show_login = 1,
    show_share = 1
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
  server_controls(
    id = "controls",
    ide = ide
  )

  # Selected tab ----
  observeEvent(input$tab, {
    tab_new <- input$tab
    ide$tab_selected <- tab_new
    # save previous tab code
    if(!is.null(ide$tab_previous)){
      ide$tabs[[ide$tab_previous]] <- input[["editor-ace"]]
    }
    # create new tab
    if(!tab_new %in% names(ide$tabs)){
      ide$tabs[[tab_new]] <- ""
      ide$tabs_available <- c(ide$tabs_available, tab_new)
    }
    # Update Ace with code
    updateAceEditor(
      session = session,
      editorId = "editor-ace",
      value = ide$tabs[[tab_new]]
    )
    ide$tab_previous <- tab_new
  })

  # Tab close ----
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

  # Tab edited ----
  observeEvent(input$tab_edit, {
    tab_edit_info <- input$tab_edit
    print(tab_edit_info)

    if (is.null(tab_edit_info) || is.null(tab_edit_info$new_name) || is.null(tab_edit_info$old_name)) {
      warning("Invalid input$tab_edit structure")
      return()
    }

    edited_tab <- tab_edit_info$new_name
    original_tab <- tab_edit_info$old_name

    if(original_tab %in% names(ide$tabs)){
      # Rename the tab and preserve its code
      ide$tabs[[edited_tab]] <- ide$tabs[[original_tab]]
      ide$tabs[[original_tab]] <- NULL

      # Update previous tab if it was the one being edited
      if(ide$tab_previous == original_tab){
        ide$tab_previous <- edited_tab
      }
    }
  })

  # on start observe query parameters ----
  shiny::observe({
    query <- parseQueryString(session$clientData$url_search)
    # ide query parameter ----
    if(!is.null(query[['ide']])){
      if(grepl("^s-", query[['ide']]) & nchar(query[['ide']]) == 34){
        lookup <- tryCatch(
          base64url::base64_urldecode(
            jsonlite::fromJSON(
              paste0(
                "https://scrapeable-share.nyc3.cdn.digitaloceanspaces.com/",
                query[['ide']],
                ".json"
              )
            )[["code"]]
          ),
          error = function(e){
            "# code snippet not found"
          }
        )

        if(!is.null(lookup)){
          updateAceEditor(
            session = session,
            editorId = "editor-ace",
            value = lookup
          )
        }
      }else{
        message("non-hash code")
        lookup <- tryCatch(
          as.character(base64url::base64_urldecode(query[['ide']])),
          error = function(e){
            "# code snippet not found"
          }
        )
        if(!is.null(lookup)){
          updateAceEditor(
            session = session,
            editorId = "editor-ace",
            value = lookup
          )
        }
      }
    }

    # code query parameter ----
    if(!is.null(query[['code']])){
      body <- paste0(
        "grant_type=authorization_code&",
        "client_id=4u1auln0l9c8n3f0cjfaq6gpa1&",
        "redirect_uri=https://www.scrapeable.com/webR/&",
        "code=",
        query[['code']]
      )
      shinyjs::runjs(
        paste0(
          "tryAuth(", body, ");"
        )
      )
      if(!is.null(input$idToken)){

      }
    }
  })

  # observe share link ----
  shiny::observeEvent(input$share, {
    # code ----
    code <- input[["editor-ace"]]
    if(!is.null(input$idToken)){
      code <- base64url::base64_urlencode(code)
      hash <- paste0("s-", openssl::md5(code))
    }else{
      code <- base64url::base64_urlencode(code)
      hash <- NULL
    }

    if(code != ide$last_code){
      message("new hash / ascii")
      ide$last_code <- code
      if(!is.null(hash)){
        # function to put object on DO
      }
    }

    # share ui ----
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
              value = paste0("https://www.scrapeable.com/webR/?ide=", code)
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
              onclick="copyClipboard('share_text')",
              style = "width: 150px;"
            )
          )
        ),
        easyClose = TRUE,
        footer = NULL,
        size = "xl"
      )
    )
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
