

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{theme} into code to create it
#'
#' For incomplete themes, produce an explicit \code{theme()} call with all
#' theme arguments.
#'
#' Otherwise, try and match against the standard ggplot themes.
#'
#' @param p ggplot2 plot object
#'
#' @return Character string "theme_XXX(...)" or "theme(...)" or NULL
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_theme <- function(p) {
  theme <- p$theme

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If the theme list has no elements, then no explicit theme set
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (length(theme) == 0) {
    return(NULL)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Check whether this is a complete or an incomplete theme
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  is_complete_theme <- attr(p$theme, 'complete')

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If this is an incomplete theme, then just parse it into a theme() call
  # with explicit arguments
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (!is_complete_theme) {
    theme_args <- fargs(p$theme)
    return(glue::glue("theme({theme_args})"))
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Otherwise, it is a complete theme.
  # Only going to try and match it against known themes from ggplot2
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  size <- theme$text$size

  known_themes <- list(
    theme_bw       = theme_bw,
    theme_classic  = theme_classic,
    theme_dark     = theme_dark,
    theme_gray     = theme_gray,
    theme_light    = theme_light,
    theme_linedraw = theme_linedraw,
    theme_minimal  = theme_minimal,
    theme_void     = theme_void
  )

  for (i in seq_along(known_themes)) {
    theme_func <- known_themes[[i]]
    theme_act  <- theme_func(size)
    if (identical(theme_act, theme)) {
      # message("theme: ", names(known_themes)[i])
      return(glue::glue("{names(known_themes)[i]}({size})"))
    }
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If we got here, then the theme is not a match for anything in ggplot2.
  # Possibilities:
  #    1 - it's a theme from something else e.g. {ggthemes} package
  #    2 - it's a ggplot theme but with some customisations.
  #        ToDo: Could possible handle this case by figuring out the ggplot2 theme
  #              with the smallest diff from this given theme and then overlaying
  #              a delta 'theme()' call of the differences.
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  warning("No theme from ggplot2 matches the theme in this plot identically")
  return(NULL)
}

