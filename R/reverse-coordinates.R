

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{coordinates} into code to create them
#'
#' @param p ggplot2 plot object
#'
#' @return character string "coord_XXX(...)"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_coordinates <- function(p) {
  coordinates <- p$coordinates

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Use the class of the coordinates object to lookup the function name
  # in ggplot used to create it
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  coord_class    <- class(coordinates)[1]
  coord_func     <- snakeize(coord_class)
  coord_formals  <- formals(coord_func)
  coord_argnames <- names(coord_formals)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Cross check the default arguments for this function call against the
  # named values in the ggproto object.
  # If the formal argument exists in the ggproto and doesn't match the default
  # argument, then add it to the list of non-default argument names that need
  # to be explicitly called
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  non_default_argnames <- c()
  for (argname in coord_argnames) {
    if (argname %in% names(coordinates) && !identical(coordinates[[argname]], coord_formals[[argname]])) {
      non_default_argnames <- c(non_default_argnames, argname)
    }
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Look-up each of the argument names for its value in the ggproto object
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  non_default_arglist <- purrr::map(non_default_argnames, ~coordinates[[.x]])
  non_default_arglist <- setNames(non_default_arglist, non_default_argnames)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Convert the argument list into text
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  coordinates_args    <- fargs(non_default_arglist)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create the function call
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  glue::glue("{coord_func}({coordinates_args %||% ''})")
}

