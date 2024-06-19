
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
        bslib::tooltip("Login / Signup", placement = "bottom")
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
      shiny::observeEvent(input$Login, {
        shiny::showModal(
          shiny::modalDialog(
            title = "Login / Sign Up",
            shiny::column(
              width = 12,
              shiny::fluidRow(
                shiny::actionButton(
                  inputId = "login",
                  label = "Login",
                  style = "width: 150px;",
                  onClick = "window.parent.location.href='https://scrapeable.auth.us-east-2.amazoncognito.com/login?client_id=4u1auln0l9c8n3f0cjfaq6gpa1&response_type=code&scope=openid&redirect_uri=https%3A%2F%2Fwww.scrapeable.com%2FwebR%2F';",
                )
              ),
              shiny::tags$br(),
              shiny::fluidRow(
                shiny::actionButton(
                  inputId = "sign_up",
                  label = "Sign Up",
                  style = "width: 150px;",
                  onClick = "window.parent.location.href='https://scrapeable.auth.us-east-2.amazoncognito.com/signup?client_id=4u1auln0l9c8n3f0cjfaq6gpa1&response_type=code&scope=openid&redirect_uri=https%3A%2F%2Fwww.scrapeable.com%2FwebR%2F';",
                )
              )
            ),
            footer = "redirecting to AWS Cognito for secure Login / Sign Up...",
            easyClose = TRUE,
            size = "m"
          )
        )
      })
    }
  )
}
