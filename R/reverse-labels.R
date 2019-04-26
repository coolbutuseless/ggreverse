

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{labels} into code to create them
#'
#' @param p ggplot2 plot object
#'
#' @return character string "labs(...)" or NULL
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_labels <- function(p) {
  labs_args <- fargs(p$labels)

  if (is.null(labs_args)) {
    NULL
  } else {
    glue::glue("labs({labs_args})")
  }
}

