#' DICOM Resource Class
#'
#' @description
#'
#' An abstract class for a DICOM Resource in the Orthanc API Client.
#'
#' @return An R6 instance of class `"Resource"`.
#'
#' @export
Resource <- R6::R6Class(
  classname = "Resource",
  portable = FALSE,
  cloneable = FALSE,
  public = list(
    #' @description Create a new Resource.
    #' @param id Orthanc identifier of the resource.
    #' @param client `Orthanc` client.
    initialize = function(id, client) {
      rlang::inherits_all(client, "Orthanc")
      private$.id <- id
      private$.client <- client
    },

    #' @description Get main information for the resource.
    get_main_information = function() {
      rlang::abort("Method not implemented.")
    },

    #' @description Print a `Resource` object.
    #' @param ... Not currently used.
    print = function(...) {
      cat(glue::glue("<{private$.type}: {private$.id}>"))
    }
  ),
  private = list(
    .type = "Resource",
    .id = NULL,
    .client = NULL,
    .main_dicom_tags = NULL,
    .get_main_dicom_tag_value = function(x) {
      self$main_dicom_tags[[x]]
    },
    .download_file = function(method, route, file, params = NULL) {
      resp_con <- private$.client$stream(method, route, params = params)
      file_con <- file(file, "wb")
      on.exit({
        close(resp_con)
        close(file_con)
      })
      while (!httr2::resp_stream_is_complete(resp_con)) {
        chunk <- httr2::resp_stream_raw(resp_con)
        writeBin(chunk, file_con)
      }
      invisible()
    }
  ),
  active = list(
    #' @field identifier Orthanc identifier of the resource.
    identifier = function() {
      private$.id
    },
    #' @field main_dicom_tags Main DICOM tags for the resource.
    main_dicom_tags = function() {
      if (rlang::is_null(private$.main_dicom_tags)) {
        private$.main_dicom_tags <- self$get_main_information()[[
          "MainDicomTags"
        ]]
      }
      private$.main_dicom_tags
    }
  )
)
