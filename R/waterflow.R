#' Solve the Waterflow Problem
#'
#' This \code{R6} Class provides methods to calculate the total number of
#' squares which will fill with water and to plot the walls and filled valleys.
#'
#' @section Usage:
#' \preformatted{
#'   p <- waterflow$new(wall = NULL)
#'   p$total()
#'   p$plot()
#'   p$print()
#' }
#'
#' @section Arguments:
#' \describe{
#'   \item{p}{A \code{waterflow} object.}
#'   \item{wall}{A numeric vector of wall heights}
#' }
#'
#' @section Details:
#' \code{$new()} calculates the amount of water the valleys will be filled with.
#'
#' \code{$total()} returns the total amount of water the valleys will be filled
#' with.
#'
#' \code{$plot()} plots the walls filled with water.
#'
#' \code{$print()} returns the \code{data.frame} of wall and water heights.
#'
#' @importFrom R6 R6Class
#' @importFrom ggplot2 ggplot geom_col aes scale_fill_manual scale_x_continuous
#'   theme element_blank element_line
#' @name waterflow
#' @examples
#' x <- c(2, 5, 1, 2, 3, 4, 7, 7, 6)
#' p <- waterflow$new(x)
#' p$total()
#' p$plot()
#' p$print()
NULL

#' @export

waterflow <- R6Class(
  "waterflow",
  public = list(
    initialize = function(wall = NULL) {
      if (is.null(wall)) {
        stop("Please provide some wall heights")
      }
      if (!is.numeric(wall)) {
        stop("Please provide a numeric vector")
      }
      len <- length(wall)
      water <- rep(0, len)
      for (i in seq_along(wall)) {
        currentHeight <- wall[i]
        maxLeftHeight <- if (i > 1) {
          max(wall[1:(i - 1)])
        } else {
          0
        }
        maxRightHeight <- if (i == len) {
          0
        } else {
          max(wall[(i + 1):len])
        }
        smallestMaxHeight <- min(maxLeftHeight, maxRightHeight)
        water[i] <- if (smallestMaxHeight - currentHeight > 0) {
          smallestMaxHeight - currentHeight
        } else {
          0
        }
      }
      private$waterDf <- private$tidyWater(water, wall)
    },
    plot = function() {
      ggplot(private$waterDf) +
        geom_col(
          aes(x = pos + 1 / 2, y = val, fill = type),
          width = 1, show.legend = FALSE
        ) +
        scale_fill_manual(values = c("dodgerblue2", "grey50")) +
        scale_x_continuous(breaks = seq(0, max(private$waterDf$pos), 1)) +
        theme(
          panel.background = element_blank(),
          panel.ontop = TRUE,
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_line(colour = "white", size = 0.5),
          panel.grid.major.x = element_line(colour = "white", size = 0.5),
          panel.grid.major.y = element_line(colour = "white", size = 0.5),
          axis.ticks = element_blank(),
          text = element_blank()
        )
    },
    print = function() print(private$waterDf),
    total = function() {
      sum(private$waterDf[private$waterDf$type %in% "water", "val"])
    }
  ),
  private = list(
    waterDf = NULL,
    tidyWater = function(water, wall) {
      data.frame(
        pos = seq_along(wall),
        type = factor(
          rep(c("water", "wall"), each = length(wall)),
          levels = c("water", "wall")
        ),
        val = c(water, wall)
      )
    }
  )
)
