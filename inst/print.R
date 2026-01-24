#' Print the result of an Orthanc API call
#'
#' @param x The result object.
#' @param ... Ignored.
#' @return The result.
#'
#' @export
#' @method print orthanc_response
print.orthanc_response <- function(x, ...) {
  attributes(x) <- list(class = class(x))
  print(x)
}
