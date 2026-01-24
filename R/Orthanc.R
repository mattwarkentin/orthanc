#' Orthanc API Client
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
#' @return An `Orthanc` instance.
#'
#' @export
Orthanc <-
  R6::R6Class(
    classname = 'Orthanc',
    cloneable = FALSE,
    portable = FALSE,
    public = list(
      #' @field url URL for Orthanc REST API.
      url = NULL,

      #' @field api_version Orthanc API version.
      api_version = "1.12.10",

      #' @description
      #' Initialize a new Orthanc API Client
      #'
      #' @param url URL for Orthanc REST API.
      #' @param username Optional username for Basic HTTP authentication.
      #' @param password Optional password for Basic HTTP authentication.
      #' @param ... Not currently used.
      initialize = function(url, username = NULL, password = NULL, ...) {
        rlang::check_dots_empty()
        if (rlang::is_missing(url)) {
          self$url <- default_api_url()
        } else {
          self$url <- url
        }
        private$setup_credentials(username, password)
      },

      #' @description GET request with specified route
      #' @param route HTTP route.
      #' @param params Parameters for the HTTP request.
      #' @param headers Headers for the HTTP request.
      #' @param cookies Cookies for the HTTP request.
      #' @return Serialized response of the HTTP GET request.
      GET = function(route, params = NULL, headers = NULL, cookies = NULL) {
        req <- private$build_request(route, params, headers, cookies, "GET")
        resp <- httr2::req_perform(req)
        private$process_response(req, resp)
      },

      #' @description DELETE to specified route
      #' @param route HTTP route.
      #' @param params Parameters for the HTTP request.
      #' @param headers Headers for the HTTP request.
      #' @param cookies Cookies for the HTTP request.
      #' @return Serialized response of the HTTP DELETE request.
      DELETE = function(route, params = NULL, headers = NULL, cookies = NULL) {
        req <- private$build_request(route, params, headers, cookies, "DELETE")
        resp <- httr2::req_perform(req)
        private$process_response(req, resp)
      },

      #' @description POST to specified route
      #' @param route HTTP route.
      #' @param file DICOM file to be uploaded or a ZIP archive containing
      #'   DICOM files.
      #' @param json List to be converted to JSON for request body.
      #' @param data Raw data.
      #' @param params Parameters for the HTTP request.
      #' @param headers Headers for the HTTP request.
      #' @param cookies Cookies for the HTTP request.
      #' @return Serialized response of the HTTP POST request.
      POST = function(
        route,
        file = NULL,
        json = NULL,
        data = NULL,
        params = NULL,
        headers = NULL,
        cookies = NULL
      ) {
        req <- private$build_request(route, params, headers, cookies, "POST")
        req <- private$include_content(req, file, json, data)
        resp <- httr2::req_perform(req)
        private$process_response(req, resp)
      },

      #' @description PUT to specified route
      #' @param route HTTP route.
      #' @param data Raw data.
      #' @param file DICOM file to be uploaded or a ZIP archive containing
      #'   DICOM files.
      #' @param json List to be converted to JSON for request body.
      #' @param params Parameters for the HTTP request.
      #' @param headers Headers for the HTTP request.
      #' @param cookies Cookies for the HTTP request.
      #' @return Serialized response of the HTTP PUT request.
      PUT = function(
        route,
        file = NULL,
        json = NULL,
        data = NULL,
        params = NULL,
        headers = NULL,
        cookies = NULL
      ) {
        req <- private$build_request(route, params, headers, cookies, "PUT")
        req <- private$include_content(req, file, json, data)
        resp <- httr2::req_perform(req)
        private$process_response(req, resp)
      },

      #' @description Print method for `Orthanc`.
      #' @param x Object to print.
      #' @param ... Further arguments passed to or from other methods.
      print = function(x, ...) {
        cat("<Orthanc API Client>")
      },

      #' @description
      #' List changes
      #'
      #' Whenever Orthanc receives a new DICOM instance, this event is recorded in
      #' the so-called _Changes Log_. This enables remote scripts to react to the
      #' arrival of new DICOM resources. A typical application is auto-routing,
      #' where an external script waits for a new DICOM instance to arrive into
      #' Orthanc, then forward this instance to another modality. Please note that,
      #' when resources are deleted, their corresponding change entries are also
      #' removed from the Changes Log, which helps ensuring that this log does not
      #' grow indefinitely.
      #'
      #' @param params Named-list of query parameters.
      #'
      #' @details
      #' Query Parameters:
      #' - `last`: Request only the last change id (this argument must be used alone)
      #' - `limit`: Limit the number of results
      #' - `since`: Show only the resources since the provided index excluded
      #' - `to`: Show only the resources till the provided index included (only available if your DB backend supports ExtendedChanges)
      #' - `type`: Show only the changes of the provided type (only available if your DB backend supports ExtendedChanges).  Multiple values can be provided and must be separated by a ';'.
      #'
      #' @return A `list`.
      get_changes = function(params = NULL) {
        self$GET('/changes', params)
      },

      #' @description
      #' List exports
      #'
      #' For medical traceability, Orthanc can be configured to store a log of
      #' all the resources that have been exported to remote modalities. In
      #' auto-routing scenarios, it is important to prevent this log to grow
      #' indefinitely as incoming instances are routed. You can either disable
      #' this logging by setting the option LogExportedResources to false in the
      #' configuration file, or periodically clear this log by DELETE-ing this
      #' URI. This route might be removed in future versions of Orthanc.
      #'
      #' @param params Named-list of query parameters.
      #'
      #' @details
      #' Query Parameters:
      #' - `limit`: Limit the number of results
      #' - `since`: Show only the resources since the provided index
      #'
      #' @return A `list`.
      get_exports = function(params = NULL) {
        self$GET('/exports', params)
      },

      #' @description
      #' List the available instances
      #'
      #' List the Orthanc identifiers of all the available DICOM instances.
      #'
      #' @param params  Named-list of query parameters.
      #'
      #' @details
      #' Query Parameters:
      #' - `expand` (str): If present, retrieve detailed information about the individual resources, not only their Orthanc identifiers
      #' - `full` (bool): If present, report the DICOM tags in full format (tags indexed by their hexadecimal format, associated with their symbolic name and their value)
      #' - `limit` (float): Limit the number of results
      #' - `requested-tags` (str): If present, list the DICOM Tags you want to list in the response.  This argument is a semi-column separated list of DICOM Tags identifiers; e.g: 'requested-tags=0010,0010;PatientBirthDate'.  The tags requested tags are returned in the 'RequestedTags' field in the response.  Note that, if you are requesting tags that are not listed in the Main Dicom Tags stored in DB, building the response might be slow since Orthanc will need to access the DICOM files.  If not specified, Orthanc will return all Main Dicom Tags to keep backward compatibility with Orthanc prior to 1.11.0.
      #' - `response-content` (str): Defines the content of response for each returned resource.  Allowed values are `MainDicomTags`, `Metadata`, `Children`, `Parent`, `Labels`, `Status`, `IsStable`, `Attachments`.  If not specified, Orthanc will return `MainDicomTags`, `Metadata`, `Children`, `Parent`, `Labels`, `Status`, `IsStable`.e.g: 'response-content=MainDicomTags;Children (new in Orthanc 1.12.5 - overrides `expand`)
      #' - `short` (bool): If present, report the DICOM tags in hexadecimal format
      #' - `since` (float): Show only the resources since the provided index
      #'
      #' @return A `list` containing either the Orthanc identifiers, or detailed information about the reported instances (if `expand` parameter is provided).
      get_instances = function(params = NULL) {
        self$GET('/instances', params)
      },

      #' @description
      #' Get detailed information about the DICOM instance whose Orthanc
      #' identifier is provided in the URL.
      #'
      #' @param id Orthanc identifier of the instance of interest.
      #' @param params  Named-list of query parameters.
      #'
      #' @return A `list`.
      get_instances_id = function(id, params = NULL) {
        self$GET(
          route = glue::glue('/instances/{id}', id = id),
          params = params
        )
      }
    ),
    private = list(
      req_auth = FALSE,
      username = NULL,
      password = NULL,
      setup_credentials = function(username, password) {
        if (!rlang::is_null(username) & nchar(username) > 0) {
          private$username <- username
          private$req_auth <- TRUE
        }

        if (!rlang::is_null(password) & nchar(password) > 0) {
          private$password <- password
        }

        invisible()
      },
      authenticate = function(req) {
        if (!private$req_auth) {
          return(req)
        }
        req |>
          httr2::req_auth_basic(
            username = private$username,
            password = private$password
          )
      },
      build_request = function(route, params, headers, cookies, method) {
        httr2::request(self$url) |>
          httr2::req_url_path_append(route) |>
          httr2::req_url_query(!!!params) |>
          httr2::req_headers(!!!headers) |>
          httr2::req_cookies_set(!!!cookies) |>
          private$authenticate() |>
          httr2::req_method(method) |>
          httr2::req_user_agent(
            "orthanc (https://github.com/mattwarkentin/orthanc)"
          )
      },
      include_content = function(req, file, json, data) {
        if (!rlang::is_missing(file)) {
          req <-
            req |>
            httr2::req_body_file(file)
        }

        if (!rlang::is_missing(data)) {
          req <-
            req |>
            httr2::req_body_raw(data)
        }

        if (!rlang::is_missing(json)) {
          req <-
            req |>
            httr2::req_body_json(json)
        }
        req
      },
      process_response = function(req, resp) {
        stopifnot(inherits(resp, "httr2_response"))

        content_type <- httr2::resp_content_type(resp)

        is_empty <- length(resp$body) == 0

        if (resp$status_code >= 200 & resp$status_code < 300) {
          if (is_empty) {
            res <- list()
          } else if (
            grepl("^application/json", content_type, ignore.case = TRUE)
          ) {
            res <- httr2::resp_body_json(resp)
          } else if (grepl("^text/html", content_type, ignore.case = TRUE)) {
            res <- httr2::resp_body_html(resp)
          } else if (grepl("^text/plain", content_type, ignore.case = TRUE)) {
            res <- httr2::resp_body_string(resp)
          } else {
            res <- httr2::resp_body_raw(resp)
          }
        }

        class(res) <- c("orthanc_response", "list")
        res
      }
    )
  )

default_api_url <- function() {
  Sys.getenv("ORTHANC_API_URL", unset = "http://localhost:8042")
}
