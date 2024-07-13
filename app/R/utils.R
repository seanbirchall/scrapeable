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

    flags <- c("print(", "str(")
    check_flags <- lapply(flags, function(flag){
      grepl(flag, src, fixed = TRUE)
    })

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

    if(is.null(evals[[chunk]][["output"]]) & !any(check_flags == TRUE)){
      output <- NULL
    }else if(any(check_flags == TRUE)){
      output <- shiny::tags$span(
        class="r-output",
        paste(capture.output(eval(parse(text = evals[[chunk]][["src"]]))), collapse = "\n")
      )
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

# reactable buttons ----
reactable_button <- function(inputId, icon) {
  glue::glue(
    "
    function(cellInfo, state) {{
      var clickid = '{inputId}';
      var {{ index }} = cellInfo;
      return `<i class='{icon} reactable-bttn' style='color:red;' ` +
        `id='${{index+1}}' ` +
        `onclick='event.stopPropagation(); Shiny.setInputValue(&#39;${{clickid}}&#39;, this.id, {{priority: &#39;event&#39;}})' ` +
        `style='padding-left: 0.2em;'></i>`
    }}
    "
  ) |> htmlwidgets::JS()
}

# get all envrionment objects ----
get_environment <- function(){
  environment <- ls(.GlobalEnv)
  class <- as.character(lapply(mget(environment, envir = .GlobalEnv), class))
  df_environment <- data.frame(
    Object = environment,
    Class = class
  )
  if(nrow(df_environment) > 0){
    df_environment$trash <- NA_character_
  }else{
    df_environment$trash <- character(0)
  }
  return(df_environment)
}

# remove object from envrionment ----
remove_environment <- function(object){
  rm(list = object, envir = .GlobalEnv)
  gc()
}

# get all packages ----
get_packages <- function(){
  df_package <- sessionInfo()[["otherPkgs"]]
  df_package <- do.call(rbind, lapply(seq_along(df_package), function(x) {
    data.frame(
      Package = df_package[[x]][["Package"]],
      Title = df_package[[x]][["Title"]],
      Version = df_package[[x]][["Version"]]
    )
  }))
  return(df_package)
}

# check object ----
check_object_type <- function(obj) {
  cls <- class(obj)
  if (is.null(obj)) {
    return("NULL")
  } else if ("data.frame" %in% cls) {
    return("data.frame")
  } else if ("matrix" %in% cls) {
    return("matrix")
  } else if ("array" %in% cls & !"matrix" %in% cls) {
    return("array")
  } else if ("list" %in% cls & !"data.frame" %in% cls) {
    return("list")
  } else if ("factor" %in% cls) {
    return("factor")
  } else if ("function" %in% cls) {
    return("function")
  } else if ("tbl" %in% cls) {
    return("tibble")
  } else if ("environment" %in% cls) {
    return("environment")
  } else if ("name" %in% cls) {
    return("symbol")
  } else if ("expression" %in% cls) {
    return("expression")
  } else if ("Date" %in% cls) {
    return("Date")
  } else if ("POSIXct" %in% cls || "POSIXlt" %in% cls) {
    return("datetime")
  } else if ("complex" %in% cls) {
    return("complex")
  } else if ("raw" %in% cls) {
    return("raw")
  } else if ("formula" %in% cls) {
    return("formula")
  } else if ("ts" %in% cls) {
    return("time series")
  } else if ("data.table" %in% cls) {
    return("data.table")
  } else if ("Matrix" %in% cls) {
    return("sparse matrix")
  } else if (is.vector(obj)) {
    return("vector")
  } else {
    return("other")
  }
}
