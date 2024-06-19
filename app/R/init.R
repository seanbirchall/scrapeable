init <- function(name){
  golem <- shiny::reactiveValues()
  golem[[name]] <- 1
  return(golem)
}

trigger <- function(name){
  golem[[name]] <- golem[[name]] + 1
}

on <- function(name, ...){
  shiny::observeEvent(name, {
    ...
  })
}
