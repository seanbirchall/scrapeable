df_viewer <- function(data, colHeaders = NULL, rowHeaders = TRUE, width = NULL, height = NULL, elementId = NULL) {
  # Convert data to a list if it's a data frame
  if(is.data.frame(data)){
    data <- lapply(1:nrow(data), function(i) as.list(data[i,]))  # convert names to list
  }

  # If colHeaders is NULL, use column names from data
  if(is.null(colHeaders) & !is.null(names(data))){
    colHeaders <- names(data)
  }

  # Forward options using x
  x = list(
    data = data,
    colHeaders = colHeaders,
    rowHeaders = rowHeaders
  )

  deps <- list(
    htmltools::htmlDependency(
      name = "handsontable",
      version = "1",
      src = "www",
      script = "handsontable.js",
      stylesheet = "handsontable.css"
    ),
    htmltools::htmlDependency(
      name = "df_viewer",
      version = "1",
      src = "www",
      script = "df_viewer.js"
    )
  )

  # Create widget
  widget <- htmlwidgets::createWidget(
    name = 'df_viewer',
    x,
    width = width,
    height = height,
    package = 'df_viewer',
    elementId = elementId,
    dependencies = deps
  )

  return(widget)

}

#' Shiny bindings for df_viewer
#'
#' Output and render functions for using df_viewer within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a df_viewer
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name df_viewer-shiny
#'
#' @export
dfViewerOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'df_viewer', width, height, package = 'df_viewer')
}

#' @rdname df_viewer-shiny
#' @export
renderdfViewer <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) }
  htmlwidgets::shinyRenderWidget(expr, dfViewerOutput, env, quoted = TRUE)
}
