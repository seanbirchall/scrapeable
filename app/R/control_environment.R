ui_control_environment <- function(id="environment"){
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::fluidRow(
      class = "m-0",
      shiny::column(
        width = 12,
        class = "c-0",
        shiny::fluidRow(
          class = "m-0",
          bslib::card(
            style = "padding: 0px; height: calc(50vh - 20px); margin: 0px;",
            fill = TRUE,
            bslib::card_body(
              style = "padding: 0px; margin: 0px;",
              fillable = TRUE,
              fill = TRUE,
              height = "100%",
              reactable::reactableOutput(
                outputId = ns("environment")
              )
            )
          ),
          bslib::card(
            style = "padding: 0px; height: calc(50vh - 3px); margin: 0px;",
            bslib::card_body(
              style = "padding: 0px; margin: 0px;",
              height = "100%",
              reactable::reactableOutput(
                outputId = ns("package")
              )
            )
          )
        )
      )
    )
  )
}

server_control_environment <- function(id="environment", ide){

  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      # observe last run ----
      observeEvent(ide$last_run, {
        ide$environment <- get_environment()
        ide$package <- get_packages()
      })

      # observe table object remove ----
      shiny::observeEvent(input$remove, {
        remove_environment(ide$environment[["Object"]][as.numeric(input$remove)])
        ide$environment <- get_environment()
      })

      # ui environment
      output$environment <- reactable::renderReactable({
        req(ide$environment) |>
          reactable::reactable(
            sortable = T,
            resizable = F,
            pagination = F,
            highlight = T,
            compact = T,
            bordered = T,
            onClick = "select",
            selection = "single",
            wrap = F,
            language = reactable::reactableLang(
              noData = "Environment is empty"
            ),
            columns = list(
              .selection = colDef(show = FALSE),
              trash = colDef(
                name = "rm", html = T, width = 40, sticky = "right",
                show = TRUE, align = "center", sortable = F,
                cell = reactable_button(ns("remove"), "fa fa-remove")
              )
            ),
            style = "font-size: 13px; overflow-x: hidden;",
            defaultSorted = "Class",
            theme = reactableTheme(
              rowSelectedStyle = list(
                backgroundColor = "lightgrey"
              ),
              headerStyle = list(
                backgroundColor = "rgb(246, 247, 249)",
                borderColor = "black"
              )
            )
          )
      })

      # ui packages ----
      output$package <- reactable::renderReactable({
        shiny::req(ide$package) |>
          reactable::reactable(
            sortable = T,
            resizable = F,
            pagination = F,
            highlight = T,
            compact = T,
            bordered = T,
            onClick = "select",
            selection = "single",
            wrap = F,
            columns = list(
              .selection = colDef(show = FALSE)
            ),
            style = "font-size: 13px; overflow-x: hidden;",
            defaultSorted = "Package",
            theme = reactableTheme(
              headerStyle = list(
                backgroundColor = "rgb(246, 247, 249)",
                borderColor = "black"
              )
            )
          )
      })
    }
  )
}
