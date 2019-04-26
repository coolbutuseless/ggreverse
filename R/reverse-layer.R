

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert layer \code{mapping} argument into code to create it
#'
#' @param layer ggplot2 layer object
#'
#' @return character string "mapping = aes(x = ..., y = ...)" or NULL
#'
#' @importFrom glue glue
#' @importFrom stats setNames
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_layer_mapping <- function(layer) {

  mapping  <- layer$mapping

  if (length(mapping) == 0) {
    return(NULL)
  }

  arg_list   <- purrr::map(sub("^~", '', as.character(mapping)), as.name)
  arg_names  <- names(mapping)
  arg_list   <- setNames(arg_list, arg_names)


  aes_args <- fargs(arg_list)

  glue::glue("mapping = aes({aes_args %||% ''})")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert layer \code{aes_params} into code to create them
#'
#' @param layer ggplot2 layer object
#'
#' @return character string "size = 3, na.rm = TRUE, ..." or NULL
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_layer_aes_params <- function(layer) {
  fargs(layer$aes_params)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert layer \code{position} into code to create it
#'
#' @param layer ggplot2 layer object
#'
#' @return character string "position = position_XXX(x, y)"
#'
#' @import purrr
#' @importFrom glue glue
#' @importFrom stats setNames
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_layer_position <- function(layer) {

  if (!inherits(layer, 'LayerInstance')) {
    stop("reverse_position: 'layer' argument must inherit from class 'LayerInstance'")
  }

  position <- layer$position

  pos_class    <- class(position)[1]
  pos_func     <- snakeize(pos_class)
  pos_formals  <- formals(pos_func)
  pos_argnames <- names(pos_formals)

  non_default_argnames <- c()
  for (argname in pos_argnames) {
    if (argname %in% names(position) && !identical(position[[argname]], pos_formals[[argname]])) {
      non_default_argnames <- c(non_default_argnames, argname)
    }
  }

  non_default_arglist <- purrr::map(non_default_argnames, ~position[[.x]])
  non_default_arglist <- setNames(non_default_arglist, non_default_argnames)

  position_args <- fargs(non_default_arglist)

  glue::glue("position = {pos_func}({position_args %||% ''})")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert layer \code{stat} into code to create it
#'
#' @param layer ggplot2 layer object
#'
#' @return character string of format "stat = 'statname'"
#'
#' @import purrr
#' @importFrom glue glue
#' @importFrom stats setNames
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_layer_stat <- function(layer) {
  stat          <- layer$stat
  stat_params   <- layer$stat_params
  stat_class    <- class(stat)[1]
  stat_func     <- snakeize(stat_class)

  stat_string   <- sub("^stat_", "", stat_func)

  return(
    glue::glue("stat = \"{stat_string}\"")
  )

  # stat_formals  <- formals(stat_func)
  # stat_argnames <- names(stat_formals)
  #
  # non_default_argnames <- c()
  # for (argname in stat_argnames) {
  #   if (argname %in% names(stat) && !identical(stat[[argname]], stat_formals[[argname]])) {
  #     non_default_argnames <- c(non_default_argnames, argname)
  #   }
  # }
  #
  # non_default_arglist <- purrr::map(non_default_argnames, ~position[[.x]])
  # non_default_arglist <- setNames(non_default_arglist, non_default_argnames)
  #
  # non_default_arglist <- c(non_default_arglist, stat_params)
  #
  # stat_args <- fargs(non_default_arglist)
  #
  # glue::glue("stat = {stat_func}({stat_args %||% ''})")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert layer \code{data} into code to create it
#'
#' @param layer ggplot2 layer object
#' @param p ggplot2 object
#' @param layer_data_name default name to use for data if it isn't waiver, and
#'        matching data cannot be found in the \code{plot_env}
#'
#' @return character string of format "data = ..." or NULL
#'
#' @import purrr
#' @importFrom glue glue
#' @importFrom stats setNames
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_layer_data <- function(layer, p, layer_data_name) {
  data <- layer$data

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 'waiver' means to just inherit the data from root object
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (inherits(data, 'waiver')) {
    # Inherit the data
    return(NULL)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Otherwise try and find the identical data in the environment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  env <- p$plot_env
  for (varname in ls(envir = env)) {
    if (identical(data, env[[varname]])) {
      return(glue::glue("data = {data}"))
    }
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Otherwise use a default name
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(glue::glue("data = {layer_data_name}"))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert plot \code{layer} into code to create it
#'
#' @param layer ggplot2 layer object
#' @param p ggplot2 plot object
#' @param layer_data_name name
#'
#' @return character string "geom_XXX(...)"
#'
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_layer <- function(layer, p, layer_data_name) {
  if (!inherits(layer, 'LayerInstance')) {
    stop("reverse_layer: 'layer' argument must inherit from class 'LayerInstance'")
  }
  geom_name       <- snakeize(class(layer$geom)[1])
  data_text       <- reverse_layer_data(layer, p, layer_data_name)
  position_text   <- reverse_layer_position(layer)
  stat_text       <- reverse_layer_stat(layer)
  aes_text        <- reverse_layer_mapping(layer)
  aes_params_text <- reverse_layer_aes_params(layer)
  geom_args       <- paste(c(data_text, aes_text, aes_params_text, position_text, stat_text), collapse = ", ")


  glue::glue("{geom_name}({geom_args %||% ''})")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert all plot \code{layers} into code to create them
#'
#' @param p ggplot2 plot object
#' @param layer_data_names names
#'
#' @import purrr
#'
#' @return vector of character strings - one for each layer
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reverse_layers <- function(p, layer_data_names) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create default layer data names if none have been provided
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (is.null(layer_data_names)) {
    layer_data_names <- paste0("layer_data_", seq_along(p$layers))
  } else if (length(p$layers) != length(layer_data_names)) {
    stop("layer_data_names must be NULL or the same length as the number of layers in the plot")
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create code for each layer
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  purrr::map2_chr(p$layers, layer_data_names, ~reverse_layer(layer = .x, p, layer_data_name = .y))
}

