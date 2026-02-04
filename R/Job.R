#' Job class to follow a Job in Orthanc
#'
#' @return An instance of `Job`.
#'
#' @export
Job <-
  R6::R6Class(
    classname = "Job",
    portable = FALSE,
    cloneable = FALSE,
    public = list(
      #' @description Create a new Job instance.
      #' @param id Job ID.
      #' @param client Orthanc API client.
      initialize = function(id, client) {
        private$id <- id
        private$client <- client
      },

      #' @description Stop execution until job is not Pending/Running.
      #' @param interval Time interval to check the job status, default is 2s.
      wait_until_completion = function(interval = 2L) {
        while (self$state. %in% c(JobStates()$pending, JobStates()$running)) {
          Sys.sleep(interval)
        }
      },

      #' @description Get job information.
      get_information = function() {
        private$client$get_jobs_id(private$id)
      }
    ),
    active = list(
      #' @field state Job state.
      state = function() {
        state <- self$get_information()[["State"]]
        JobStates()[[state]]
      },

      #' @field content Job content.
      content = function() {
        self$get_information()[["Content"]]
      },

      #' @field type Job type.
      type = function() {
        self$get_information()[["Type"]]
      },

      #' @field creation_time Job creation time.
      creation_time = function() {
        self$get_information()[["CreationTime"]]
      },

      #' @field effective_runtime Job effective runtime.
      effective_runtime = function() {
        self$get_information()[["EffectiveRuntime"]]
      },

      #' @field priority Job priority.
      priority = function() {
        self$get_information()[["Priority"]]
      },

      #' @field progress Job progress.
      progress = function() {
        self$get_information()[["Progress"]]
      },

      #' @field error Job error.
      error = function() {
        self$get_information()[["ErrorCode"]]
      },

      #' @field error_details Job error details.
      error_details = function() {
        self$get_information()[["ErrorDetails"]]
      },

      #' @field timestamp Job timestamp.
      timestamp = function() {
        self$get_information()[["Timestamp"]]
      },

      #' @field completion_time Job completion time.
      completion_time = function() {
        self$get_information()[["CompletionTime"]]
      }
    ),
    private = list(
      id = NULL,
      client = NULL
    )
  )

JobStates <- function() {
  list(
    failure = "Failure",
    paused = "Paused",
    pending = "Pending",
    retry = "Retry",
    running = "Running",
    success = "Success"
  )
}
