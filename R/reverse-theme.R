
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{theme} into code to create it
#'
#' For incomplete themes, produce an explicit \code{theme()} call with all
#' theme arguments.
#'
#' Otherwise, try and match against the standard ggplot themes.
#'
#' @param theme a ggplot2 theme object
#'
#' @return Character string "theme_XXX(...)" or "theme(...)" or NULL
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_theme <- function(theme) {

  stopifnot(inherits(theme, 'theme'))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If the theme list has no elements, then no explicit theme set
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (length(theme) == 0) {
    return(NULL)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Check whether this is a complete or an incomplete theme
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  is_complete_theme <- attr(theme, 'complete')

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If this is an incomplete theme, then just parse it into a theme() call
  # with explicit arguments
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (!is_complete_theme) {
    return(reverse_incomplete_theme(theme))
  }

  return(reverse_complete_theme(theme))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Shallow diff between 2 named lists
#'
#' @param ref reference list of defaults
#' @param test test list including customisations
#'
#' @return named list of just the customisations which differ from the reference
#'
#' @importFrom rlang is_named
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
shallow_diff <- function(ref, test) {

  # Sanity check
  stopifnot(is.list(ref))
  stopifnot(is.list(test))
  stopifnot(rlang::is_named(ref))
  stopifnot(rlang::is_named(test))

  # Remove all class information
  class(ref)  <- NULL
  class(test) <- NULL

  # Check each value in 'ref' and see if it differs in 'test'.
  test <- test[intersect(names(ref), names(test))]
  for (nm in names(test)) {
    if (identical(test[[nm]], ref[[nm]])) {
      test[nm] <- NULL
    }
  }
  test
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert theme \code{element} into code to create it
#'
#' @param element a ggplot2 theme element
#'
#' @return Character string "element_XXX(...)"
#'
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_element <- function(element) {

  stopifnot(inherits(element, 'element'))

  element_func <- class(element)[[1]]

  el_list                <- element
  attr(el_list, 'class') <- NULL

  formal_args  <- formals(element_func)
  formal_names <- names(formal_args)

  arg_list <- shallow_diff(formal_args, el_list)
  arg_string <- fargs(arg_list)

  glue::glue("{element_func}({arg_string})")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert a theme \code{unit} into code to create it
#'
#' @param theme_unit theme unit item
#'
#' @return character string "unit(...)"
#'
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_unit <- function(theme_unit) {
  stopifnot(inherits(theme_unit, 'unit'))

  values <- deparse(as.numeric(theme_unit))
  unit   <- attr(theme_unit, 'unit')

  as.character(glue::glue("unit({values}, '{unit}')"))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert a theme \code{margin} into code to create it
#'
#' @param theme_margin theme margin item
#'
#' @return character string "margin(...)"
#'
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_margin <- function(theme_margin) {
  stopifnot(inherits(theme_margin, 'margin'))

  v      <- as.numeric(theme_margin)
  unit   <- attr(theme_margin, 'unit')

  as.character(glue::glue("margin({v[1]}, {v[2]}, {v[3]}, {v[4]}, '{unit}')"))
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert a theme \code{item} into code to create it
#'
#' Theme items can be:
#' \itemize{
#' \item{element objects}
#' \item{margin objects}
#' \item{unit objects}
#' \item{character strings}
#' \item{logical values}
#' \item{numeric values}
#' }
#'
#' @param theme_item a ggplot2 theme item
#'
#' @return Character string "element_text(...)", "margin(...)" etc
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_theme_item <- function(theme_item) {
  if (inherits(theme_item, "element")) {
    reverse_element(theme_item)
  } else if (inherits(theme_item, 'margin')) {
    reverse_margin(theme_item)
  } else if (inherits(theme_item, 'unit')) {
    reverse_unit(theme_item)
  } else if (is.character(theme_item)) {
    deparse(theme_item)
  } else if (is.logical(theme_item)) {
    as.character(theme_item)
  } else if (is.numeric(theme_item)) {
    as.character(theme_item)
  } else {
    deparse("BAD")
  }
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert an incomplete \code{theme} into code to create it
#'
#' @param theme a ggplot2 theme element
#'
#' @return Character string "theme(...)"
#'
#' @import purrr
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_incomplete_theme <- function(theme) {
  stopifnot(inherits(theme, 'theme'))
  stopifnot(!attr(theme, 'complete'))

  items      <- purrr::map_chr(theme, reverse_theme_item)

  arg_string <- paste(names(items), unname(items), collapse = ", ", sep = "=")

  glue::glue("theme({arg_string})")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert an complete \code{theme} into code to create it
#'
#' @param theme a ggplot2 theme
#'
#' @return Character string "theme_XXX(...)" or "theme_XXX(...) + theme(...)"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_complete_theme <- function(theme) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Sanity check
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stopifnot(inherits(theme, 'theme'))
  stopifnot(attr(theme, 'complete'))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Search for an exact match in the ggplot2 themes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  size <- theme$text$size

  known_themes <- list(
    theme_bw       = ggplot2::theme_bw,
    theme_classic  = ggplot2::theme_classic,
    theme_dark     = ggplot2::theme_dark,
    theme_gray     = ggplot2::theme_gray,
    theme_light    = ggplot2::theme_light,
    theme_linedraw = ggplot2::theme_linedraw,
    theme_minimal  = ggplot2::theme_minimal,
    theme_void     = ggplot2::theme_void
  )

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Possibilities:
  #    1 - The theme is a perfect match for an existing theme
  #    2 - It's a theme but with some customisations.
  #  Figure out the ggplot2 theme
  #  with the smallest diff from this given theme and then overlaying
  #  a delta 'theme()' of the differences.
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  best_theme_match   <- NA
  min_theme_distance <- Inf
  theme_diff         <- NA


  for (i in seq_along(known_themes)) {
    theme_func <- known_themes[[i]]
    theme_act  <- theme_func(size)
    this_theme_diff <- shallow_diff(theme_act, theme)
    this_theme_distance <- length(this_theme_diff)
    if (this_theme_distance < min_theme_distance) {
      min_theme_distance <- this_theme_distance
      theme_diff         <- this_theme_diff
      best_theme_match   <- names(known_themes)[i]
    }
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # The best match is the base theme
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  base_theme_text <- glue::glue("{best_theme_match}({size})")

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create a theme() call to patch over any remaining differences
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (min_theme_distance > 0) {
    class(theme_diff) <- c('theme', 'gg')
    attr(theme_diff, 'complete') <- FALSE
    delta_theme_text <- reverse_incomplete_theme(theme_diff)
  } else {
    delta_theme_text <- NULL
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return the base theme + the delta (if any)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  c(base_theme_text, delta_theme_text)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Testing
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (interactive()) {

  library(ggplot2)
  library(purrr)
  library(dplyr)

  t1 <- theme_bw()
  t2 <- theme(
    text              = element_text(size = 3),     # element_text
    rect              = element_rect(fill = 'red'), # element_rect
    legend.position   = 'none',                     # character
    axis.ticks.length = unit(12, 'npc'),            # single digit unit
    plot.margin       = margin(1,2,3,4, 'npc'),     # margin
    panel.ontop       = TRUE,                       # logical
    aspect.ratio      = 1.1                         # numeric
  )

  theme <- t3 <- theme_bw() + theme(legend.position = 'none', rect = element_rect(fill = 'red'))

  reverse_incomplete_theme(t2)

  reverse_theme(t1)
  reverse_theme(t2)
  reverse_theme(t3)
}

