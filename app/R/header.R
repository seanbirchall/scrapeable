ui_header <- function(id){
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::tags$div(
      class = "header-search-container-left"
    ),
    shiny::tags$div(
      class = "header-search-container-center"
      # shiny::selectizeInput(
      #   inputId = "search",
      #   label = NULL,
      #   width = "100%",
      #   multiple = TRUE,
      #   choices = NULL,
      #   options = list(
      #     # valueField = "id",
      #     # labelField = "label",
      #     # searchField = c("id", "name", "description", "tag"),
      #     placeholder = "🔍 Search for code snippets.... (coming soon!)",
      #     maxOptions = 10,
      #     maxItems = 1,
      #     create = TRUE
      #   )
      # ) |>
      #   htmltools::tagAppendAttributes(class = "header-search-selectize")
    ),
    shiny::tags$div(
      class = "header-search-container-right",
      shiny::actionButton(
        inputId = ns("deploy"),
        label = "Deploy",
        style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid rgb(246, 247, 249); background-color: rgb(246, 247, 249); color: black;",
        icon = shiny::icon(
          "cloud-arrow-up"
        )
      ) |>
        bslib::tooltip("Cloud Deploy", placement = "bottom"),
      shiny::actionButton(
        inputId = ns("share"),
        label = "Share",
        style = "width: 80px; font-size: 12px; padding: 0px; border: 1px solid rgb(246, 247, 249); background-color: rgb(246, 247, 249); color: black;",
        icon = shiny::icon(
          "share-nodes"
        )
      ) |>
        bslib::tooltip("Create Link", placement = "bottom"),
      shiny::actionButton(
        inputId = ns("login"),
        label = NULL,
        icon = shiny::icon(
          "user"
        ),
        class = "button-login"
      ) |>
        bslib::tooltip("Login / Sign Up", placement = "bottom")
    )
  )
}

server_header <- function(id, ide){
  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # show login ----
      observeEvent(input$login, {
        ide$show_login <- ide$show_login + 1
      })

      # observe share link ----
      shiny::observeEvent(input$share, {
        if(!is.null(session$userData$authentication)){
          ## share notification ----
          show_notification(
            type = "loading",
            msg = "Preparing Share Link",
            duration = 5,
            id = "notification_share"
          )
          ## share tabs ----
          ide$tabs[[ide$tab_selected]][["code"]] <- input[["editor-ace"]]
          tabs <- ide$tabs
          tabs <- jsonlite::base64url_enc(
            serialize(
              object = tabs,
              connection = NULL
            )
          )
          ## check new code ----
          if(!identical(tabs, ide$last_tabs)){
            ide$last_tabs <- tabs
            id <- uuid::UUIDgenerate()
            ide$last_id <- id
            payload <- list(
              code = tabs,
              id = id
            )
          }else{
            id <- ide$last_id
            payload <- NULL
            if(ide$code_received > 0){
              ide$code_received <- as.integer(Sys.time())
            }else{
              ide$code_received <- -as.integer(Sys.time())
            }
          }
          ## send payload if not null ----
          if(!is.null(payload)){
            session$sendCustomMessage(
              type = "put_code",
              message = list(
                payload = payload,
                token = session$userData$authentication
              )
            )
          }
        }else{
          ## unauthenticated share ----
          shinyjs::click("login")
          shiny::removeNotification(
            id = "notification_login",
          )
          show_notification(
            type = "error",
            msg = "Please Login to Share",
            duration = 5,
            id = "notification_login"
          )
        }
      })
    }
  )
}
