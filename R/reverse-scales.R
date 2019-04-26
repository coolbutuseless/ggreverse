

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{scales} into code to create them
#'
#' @param p ggplot2 plot object
#'
#' @return character string "scales_XXX(...)"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_scales <- function(p) {
  scales <- p$scales

  if (p$scales$n() > 0) {
    warning("No handling for 'scales'")
  }

  return(NULL)
}