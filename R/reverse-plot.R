

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{data} argument into code to create it
#'
#'
#' @param p ggplot2 plot object
#' @param ggplot_data_name name of primary data source
#'
#' @return character string "data = ..."
#'
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_ggplot_data <- function(p, ggplot_data_name) {
  data <- p$data

  if (inherits(data, 'waiver')) {
    return(NULL)
  }

  env <- p$plot_env
  for (varname in ls(envir = env)) {
    if (identical(data, env[[varname]])) {
      return(glue::glue("data = {varname}"))
    }
  }

  return(glue::glue("data = {ggplot_data_name}"))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{ggplot} call into code to create it
#'
#' @param p ggplot2 plot object
#' @param ggplot_data_name ggplot data name. Used if identical data match cannot
#'        be found in the \code{plot_env}
#'
#' @return character string "ggplot(...)"
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_ggplot <- function(p, ggplot_data_name) {
  data_code   <- reverse_ggplot_data(p, ggplot_data_name)
  ggplot_aes  <- reverse_layer_mapping(p)

  ggplot_args <- paste(c(data_code, ggplot_aes), collapse = ", ")

  glue::glue("ggplot({ggplot_args})")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Reverse plot
#'
#' @param p ggplot2 plot object
#' @param ggplot_data_name name of primary data source. An attempt is made to
#'        find the actual name of the data variable by comparing the data stored
#'        in the plot object against all variables in the object's \code{plot_env}.
#'        If no matching data is found, then \code{ggplot_data_name} is used as
#'        the name of the data variable.
#' @param layer_data_names name of layer data sources. If a layer simply inherits
#'        the root data source, then no name is needed. Otherwise, an attempt is made to
#'        find the actual name of the data variable by comparing the data stored
#'        in the plot layer against all variables in the plot's \code{plot_env}.
#'        If no matching data is found, then \code{layer_data_name} is used as
#'        the name of the data variable.
#'
#' @return text to create the given plot
#'
#' @import purrr
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
convert_to_code <- function(p,
                            ggplot_data_name = 'ggplot_data_name',
                            layer_data_names = NULL) {

  if (!inherits(p, 'ggplot')) {
    stop("reverse_plot: 'p' argument must inherit from class 'ggplot'")
  }

  ggplot_call <- reverse_ggplot(p, ggplot_data_name)
  layers      <- reverse_layers(p, layer_data_names)
  facet       <- reverse_facet(p)
  scales      <- reverse_scales(p)
  labels      <- reverse_labels(p)
  theme       <- reverse_theme(p)
  coords      <- reverse_coordinates(p)

  paste(c(ggplot_call, layers, facet, scales, labels, theme, coords), collapse = "+")
}




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Testing
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (interactive()) {
  library(ggplot2)
  library(purrr)
  library(ggreverse)

  plot_df <- mtcars

  p <- ggplot(plot_df) +
    geom_point(aes(mpg, wt)) +
    labs(title = "hello") +
    theme_bw()

  plot_code <- convert_to_code(p)

  styler::style_text(
    gsub("[+]", "+\n", plot_code)
  )

  if (FALSE) {
    eval(parse(text = plot_code))
  }

  plot_code

}





