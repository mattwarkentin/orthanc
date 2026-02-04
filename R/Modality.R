#' Wrapper around Orthanc API when dealing with a modality.
#'
#' @export
Modality <-
  R6::R6Class(
    classname = "Modality",
    portable = FALSE,
    cloneable = FALSE,
    public = list(
      #' @field modality Modality.
      modality = NULL,

      #' Create a new Modality instance.
      #' @param client Orthanc API client.
      #' @param modality Modality.
      initalize = function(client, modality) {
        private$client <- client
        self$modality <- modality
        self$query <- self$find
      },

      #' @description C-Echo to modality
      echo = function() {
        private$client$post_modalities_id_echo(self$modality)
      },

      #' @description C-Move SCU: Send all the results to another modality whose
      #'   AET is in the body.
      #' @param level Level of the query ("Patient", "Study", "Series",
      #'   "Instance").
      #' @param resources List or named-list of DICOM tags that identify data to
      #'   retrieve (e.g., list(StudyInstanceUID = "1.3.6.1.4.1.22213.2.6291.2.1")).
      get = function(level, resources) {
        private$client$post_modalities_id_get(
          self$modality,
          json = list(
            Level = level,
            Resources = resources
          )
        )
      },

      #' @description C-Find (Querying with data)
      #' @param data Named-list to send in the body of request.
      find = function(data) {
        query_id <- private$client$post_modalities_id_query(
          self$modality,
          json = data
        )[["ID"]]
        answers <- self$get_query_answers(query_id)
        list(
          ID = query_id,
          answers = answers
        )
      },

      #' @description C-Find (Querying with data)
      #' @param query_id Query identifier.
      #' @param cmove_data Ex. list(TargetAet = 'target_modality_name', Synchronous = FALSE)
      move = function(query_id, cmove_data) {
        private$client$post_queries_id_retrieve(
          query_identifier,
          json = cmove_data
        )
      },

      #' @description Store series or instance to modality.
      #' @param instance_or_series_id Instance or Series Orthanc identifier.
      store = function(instance_or_series_id) {
        private$client$post_modalities_id_store(
          self$modality,
          json = instance_or_series_id
        )
      },

      #' @description Get query answers.
      #' @param query_id Query identifier.
      get_query_answers = function(query_id) {
        answers <- list()

        answer_ids <- private$client$get_queries_id_answers(query_id)

        purrr::map(answer_ids, \(x) {
          answer_content <- private$client$get_queries_id_answers_index_content(
            query_id,
            x,
            params = list(simplify = TRUE)
          )
          append(answers, answer_content)
        })

        answers
      }
    ),
    private = list(
      client = NULL
    )
  )

#' @inherit Modality
#' @export
RemoteModality <-
  R6::R6Class(
    classname = "RemoteModality",
    inherit = Modality,
    cloneable = FALSE,
    portable = FALSE
  )
