
ui_sidebar <- function(id="sidebar"){
  ns <- shiny::NS(id)

  bslib::sidebar(
    class = "container-sidebar",
    shiny::tags$div(
      class = "container-header",
      shiny::actionButton(
        inputId = ns("login"),
        label = NULL,
        icon = shiny::icon(
          "user"
        ),
        class = "button-login"
      ) |>
        bslib::tooltip("Login / Sign Up", placement = "bottom")
    ),
    shiny::tags$strong(
      "History",
      class = "header-sidebar"
    ),
    shiny::uiOutput(
      outputId = ns("history"),
      fill = TRUE,
      inline = TRUE
    )
  )
}

server_sidebar <- function(id="sidebar", ide){
  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # observe login ----
      shiny::observeEvent(input$login, {
        shiny::showModal(
          shiny::modalDialog(
            title = "Login / Sign Up",
            shiny::column(
              width = 12,
              shiny::fluidRow(
                class = "justify-content-center",
                shiny::actionButton(
                  inputId = "login",
                  label = "Login",
                  style = "width: 50%;",
                  onClick = "window.parent.location.href='https://scrapeable.auth.us-east-2.amazoncognito.com/login?client_id=4u1auln0l9c8n3f0cjfaq6gpa1&response_type=code&scope=openid&redirect_uri=https%3A%2F%2Fwww.scrapeable.com%2FwebR%2F';",
                )
              ),
              shiny::tags$br(),
              shiny::fluidRow(
                class = "justify-content-center",
                shiny::actionButton(
                  inputId = "sign_up",
                  label = "Sign Up",
                  style = "width: 50%;",
                  onClick = "window.parent.location.href='https://scrapeable.auth.us-east-2.amazoncognito.com/signup?client_id=4u1auln0l9c8n3f0cjfaq6gpa1&response_type=code&scope=openid&redirect_uri=https%3A%2F%2Fwww.scrapeable.com%2FwebR%2F';",
                )
              )
            ),
            footer = "redirecting to AWS Cognito",
            easyClose = TRUE,
            size = "m"
          )
        )
      })

      # observe history selection ----
      observeEvent(input$selectHistory, {
        message(input$selectHistory)
        showModal(
          modalDialog(
            title = NULL,
            easyClose = T,
            footer = NULL,
            shiny::tags$code(
              ide$history[["code"]][input$selectHistory]
            )
          )
        )
      })

      # output history ----
      output$history <- shiny::renderUI({
        if(!is.null(ide$history)){
          lapply(seq_along(ide$history[["code"]]), function(x){
            code <- ide$history[["code"]][x]
            time <- ide$history[["time"]][x]
            runtime <- ide$history[["runtime"]][x]
            shiny::tags$p(
              class = "p-history",
              code
            ) |>
              bslib::tooltip(paste(paste0("Run:  ", time), paste("Time: ", round(runtime, 5), attributes(runtime)[["units"]]), sep = "\n"))
          })
        }
      })
    }
  )
}
