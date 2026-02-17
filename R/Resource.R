#' DICOM Resource Class
#'
#' @description
#'
#' An abstract class for a DICOM Resource
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
    #' @param lock_children If `lock_children` is `TRUE`, the resource children
    #'   (e.g., instances of a series via `Series$instances`) will be cached at
    #'   the first query rather than queried every time. This is useful when you
    #'   want to filter the children of a resource and want to maintain the
    #'   filter result.
    initialize = function(id, client, lock_children = FALSE) {
      check_orthanc_client(client)
      check_scalar_character(id)
      check_scalar_logical(lock_children)
      private$id <- id
      private$client <- client
      private$lock_children <- lock_children
    },

    #' @description Get main information for the resource.
    get_main_information = function() {
      rlang::abort("Method not implemented.")
    },

    #' @description Print a `Resource` object.
    #' @param ... Not currently used.
    print = function(...) {
      cat(glue::glue("<{private$resource_type}: {private$id}>"))
    },

    #' @description Set child resources.
    #' @param resources List of resources.
    set_child_resources = function(resources) {
      if (private$lock_children) {
        private$child_resources <- resources
        return(invisible(self))
      }
      rlang::abort("Can only set child resources if `lock_children` is `TRUE`.")
    }
  ),
  active = list(
    #' @field identifier Orthanc identifier of the resource.
    identifier = function() {
      private$id
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
  ),
  private = list(
    resource_type = "Resource",
    id = NULL,
    client = NULL,
    lock_children = NULL,
    child_resources = NULL,
    .main_dicom_tags = NULL,
    get_main_dicom_tag_value = function(x) {
      self$main_dicom_tags[[x]]
    },
    download_file = function(method, route, file, params = NULL) {
      resp_con <- private$client$stream(method, route, params = params)
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
  )
)
