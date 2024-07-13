server_control_environment_explore <- function(id="explore", ide){

  shiny::moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns

      df_viewer <- shiny::reactiveVal(
        ui_mod_df_viewer(
          id = ns("df_viewer")
        )
      )

      # sub-modules ----
      server_mod_df_viewer(
        id = "df_viewer",
        ide = ide
      )

      # show df_viewer ----
      shiny::observeEvent(ide$environment_selected, {
        check_type <- check_object_type(ide$environment_selected)
        if(check_type %in% c("data.frame", "matrix", "tibble", "data.table")){
          ide$viewer <- ui_mod_df_viewer(
            id = ns("df_viewer")
          )
          ide$viewer_shown <- TRUE
        }
      })
    }
  )
}
