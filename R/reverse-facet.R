

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert facet \code{labeller} argument into code to create it
#'
#' Try to match the current labeller against all the ggplot2 labellers.  If
#' no match is found, then just include the full labeller function call
#'
#' @param p ggplot2 plot object
#'
#' @return character string: "labeller = label_XXX" or full labeller function body
#'
#' @import ggplot2
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_facet_labeller <- function(p) {
  labeller <- p$facet$params$labeller

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # What are all the known labellers in ggplot
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  known_labellers <- list(
    label_value    = ggplot2::label_value,
    label_both     = ggplot2::label_both,
    label_context  = ggplot2::label_context,
    label_parsed   = ggplot2::label_parsed,
    label_wrap_gen = ggplot2::label_wrap_gen
  )

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Are any of the known labellers identical to the current one?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  matching_labeller <- keep(known_labellers, ~identical(.x, labeller))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return function name of labeller if known, otherwise the function body text
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (length(matching_labeller) == 1) {
    glue::glue("labeller = {names(matching_labeller)}")
  } else {
    glue::glue("labeller = {deparse(labeller, width.cutoff = 500)}")
  }
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert facet \code{scale} argument into code to create it
#'
#' @param p ggplot2 plot object
#'
#' @return character string: "scales = '...'"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_facet_scales <- function(p) {
  free <- p$facet$params$free

  if (free$x && free$y) {
    "scales = 'free'"
  } else if (free$x && !free$y) {
    "scales = 'free_x'"
  } else if (!free$x && free$y) {
    "scales = 'free_y'"
  } else {
    "scales = 'fixed'"
  }
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert facet \code{space} argument into code to create it
#'
#' @param p ggplot2 plot object
#'
#' @return character string: "space = '...'"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_facet_space <- function(p) {
  free <- p$facet$params$space_free

  if (free$x && free$y) {
    "space = 'free'"
  } else if (free$x && !free$y) {
    "space = 'free_x'"
  } else if (!free$x && free$y) {
    "space = 'free_y'"
  } else {
    "space = 'fixed'"
  }
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{facet_grid} into code to create it
#'
#' @param p ggplot2 plot object
#'
#' @return character string "facet_grid(...)"
#'
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_facet_grid <- function(p) {
  facet <- p$facet

  stopifnot (inherits(facet, "FacetGrid"))

  facet_func    <- 'facet_grid'
  facet_formals <- formals(facet_func)
  formal_names  <- names(facet_formals)
  params        <- facet$params


  glue::glue("{facet_func}(not_done_yet)")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{facet_wrap} into code to create it
#'
#' @param p ggplot2 plot object
#'
#' @return character string "facet_wrap(...)"
#'
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_facet_wrap <- function(p) {
  facet <- p$facet

  stopifnot (inherits(facet, "FacetWrap"))

  facet_func    <- 'facet_wrap'
  facet_formals <- formals(facet_func)
  formal_names  <- names(facet_formals)
  params        <- facet$params

  glue::glue("{facet_func}(not_done_yet)")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{facet} into code to create it
#'
#' @param p ggplot2 plot object
#'
#' @return character string "facet_XXX(...)" or NULL
#'
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_facet <- function(p) {
  facet <- p$facet

  if (inherits(facet, "FacetNull")) {
    NULL
  } else if (inherits(facet, "FacetWrap")) {
    warning("Facetting not done yet")
    return(NULL)
    reverse_facet_wrap(p)
  } else if (inherits(facet, "FacetGrid")) {
    warning("Facetting not done yet")
    return(NULL)
    reverse_facet_grid(p)
  }
}

