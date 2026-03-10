#' Asynchronous Orthanc API Client
#'
#' @description
#' Orthanc is an open-source, lightweight DICOM server for healthcare and
#'   medical research. This `R6` generator creates a client to access
#'   Orthanc's RESTful API. More details about the Orthanc REST API can be
#'   found here: <https://orthanc.uclouvain.be/book/users/rest.html>.
#'
#'   The full documentation of the Orthanc API can be found here:
#'   <https://orthanc.uclouvain.be/api/>.
#'
#' @return An `OrthancAsync` instance.
#'
#' @details
#' See [Orthanc] for more information.
#'
#' @importFrom mirai mirai
#'
#' @export
OrthancAsync <-
  R6::R6Class(
    classname = 'OrthancAsync',
    inherit = Orthanc,
    public = list(
      #' @description Print method for `OrthancAsync`.
      #' @param x Object to print.
      #' @param ... Further arguments passed to or from other methods.
      print = function(x, ...) {
        cat("<Orthanc API Client [asynchronous]>")
      }
    ),
    private = list(
      request_perform = function(req) {
        username <- private$username
        password <- private$password
        response_process <- private$response_process
        mirai::mirai(
          {
            req <- httr2::req_auth_basic(req, username, password)
            resp <- httr2::req_perform(req)
            response_process(req, resp)
          },
          req = req,
          response_process = response_process,
          username = username,
          password = password
        )
      }
    )
  )
