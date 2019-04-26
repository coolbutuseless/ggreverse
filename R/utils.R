

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Local copy of 'snakeize' function that isn't exported from 'ggplot2'
#'
#' @param x geom or stat name in CamelCase e.g. "GeomPoint"
#'
#' @return name in "snake_case" e.g. "geom_point"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
snakeize <- function (x) {
    x <- gsub("([A-Za-z])([A-Z])([a-z])", "\\1_\\2\\3", x)
    x <- gsub(".", "_", x, fixed = TRUE)
    x <- gsub("([a-z])([A-Z])", "\\1_\\2", x)
    tolower(x)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Format named list into argument text for a function call
#'
#' @param nlist named list
#'
#' @return single character string
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fargs <- function(nlist) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # No elements in list?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (length(nlist) == 0) {
    return(NULL)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Keep only the 'names' attribute of the 'nlist'
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  all_attrs <- names(attributes(nlist))
  rem_attrs <- setdiff(all_attrs, "names")
  for (aname in rem_attrs) {
    attr(nlist, aname) <- NULL
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Use 'deparse()' to turn the list into call arguments.
  # delete the 'list(...)' wrapper
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stringr::str_sub(
    deparse(nlist, width.cutoff = 500),
    start = 6, end = -2
  )
}

