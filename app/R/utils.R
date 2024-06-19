# console output function ----
consoleOutput <- function(evals){
  lapply(seq_along(evals), function(chunk){
    src <- shiny::tags$span(
      class = "r-src",
      paste0(
        "> ",
        evals[[chunk]][["src"]]
      )
    )
    if(is.null(evals[[chunk]][["msg"]][["messages"]])){
      messages <- NULL
    }else{
      messages <- shiny::tags$span(class="r-message", paste(evals[[chunk]][["msg"]][["messages"]], collapse = "\n"))
    }

    if(is.null(evals[[chunk]][["msg"]][["warnings"]])){
      warnings <- NULL
    }else{
      warnings <- shiny::tags$span(class="r-warning", paste(evals[[chunk]][["msg"]][["warnings"]], collapse = "\n"))
    }

    if(is.null(evals[[chunk]][["msg"]][["errors"]])){
      errors <- NULL
    }else{
      errors <- shiny::tags$span(class="r-error", paste(evals[[chunk]][["msg"]][["errors"]], collapse = "\n"))
    }

    if(is.null(evals[[chunk]][["output"]])){
      output <- NULL
    }else{
      output <- shiny::tags$span(class="r-output", paste(evals[[chunk]][["output"]], collapse = "\n"))
    }

    tgs <- shiny::tagList(
      src,
      if(!is.null(src)){shiny::tags$br()},
      messages,
      if(!is.null(messages)){shiny::tags$br()},
      warnings,
      if(!is.null(warnings)){shiny::tags$br()},
      errors,
      if(!is.null(errors)){shiny::tags$br()},
      output,
      shiny::tags$br()
    )
  })
}

# viewer output function ----
viewerOutput <- function(run){
  viewer <- tryCatch(
    render_funs <- lapply(seq_along(run), function(v){
      if(any(class(run[[v]][["result"]]) %in% "reactable") | grepl("reactable(", run[[v]][["src"]], fixed = TRUE)){
        rerun_code <- paste0("reactable::renderReactable({", run[[v]][["src"]], "})")
        run_code <- evals(txt = rerun_code, env = .GlobalEnv)
        run_code[[1]][["result"]]
      }else if(any(grepl("plots", run[[v]][["result"]], fixed = TRUE))){
        rerun_code <- paste0("shiny::renderPlot({", run[[v]][["src"]], "})")
        run_code <- evals(txt = rerun_code, env = .GlobalEnv)
        run_code[[1]][["result"]]
      }else if(any(class(run[[v]][["result"]]) %in% "echarty") | grepl("$x$opts", run[[v]][["src"]], fixed = TRUE) | grepl("ec.init(", run[[v]][["src"]], fixed = TRUE)){
        rerun_code <- paste0("echarty::ecs.render({", run[[v]][["src"]], "})")
        run_code <- evals(txt = rerun_code, env = .GlobalEnv)
        run_code[[1]][["result"]]
      }else if(any(class(run[[v]][["result"]]) %in% "gt_tbl") | grepl("gt(", run[[v]][["src"]], fixed = TRUE)){
        message("hit GT portion")
        rerun_code <- paste0("gt::render_gt({", run[[v]][["src"]], "})")
        run_code <- evals(txt = rerun_code, env = .GlobalEnv)
        run_code[[1]][["result"]]
      }else if(any(class(run[[v]][["result"]]) %in% "jsonedit") | grepl("jsonedit(", run[[v]][["src"]], fixed = TRUE)){
        rerun_code <- paste0("listviewer::jsonedit({", run[[v]][["src"]], "})")
        run_code <- evals(txt = rerun_code, env = .GlobalEnv)
        run_code[[1]][["result"]]
      }
    }),
    error = function(e){
      NULL
    }
  )

  if(!is.null(viewer)){
    viewer <- Filter(Negate(is.null), viewer)
    if(length(viewer) > 0){
      return(viewer)
    }
  }

  return(NULL)
}
