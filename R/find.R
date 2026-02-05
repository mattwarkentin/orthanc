#' Finds patients in Orthanc according to queries and labels
#'
#' @param client Orthanc API client.
#' @param query Named-list that specifies the filters on the level related DICOM
#'   tags.
#' @param labels Character vector of labels to look for in resources.
#' @param labels_constraint Contraint on the labels ('All', 'Any', 'None').
#' @param ... Not currently used.
#'
#' @return A `list` of \link{Patient}s.
#'
#' @export
find_patients <- function(
  client,
  query = list(),
  labels = character(),
  labels_constraint = "All",
  ...
) {
  rlang::check_dots_empty()

  query_orthanc(
    client = client,
    level = "Patient",
    query = query,
    labels = labels,
    labels_constraint = labels_constraint
  )
}

#' Finds studies in Orthanc according to queries and labels
#'
#' @param client Orthanc API client.
#' @param query Named-list that specifies the filters on the level related DICOM
#'   tags.
#' @param labels Character vector of labels to look for in resources.
#' @param labels_constraint Contraint on the labels ('All', 'Any', 'None').
#' @param ... Not currently used.
#'
#' @return A `list` of \link{Study}s.
#'
#' @export
find_studies <- function(
  client,
  query = list(),
  labels = character(),
  labels_constraint = "All",
  ...
) {
  rlang::check_dots_empty()

  query_orthanc(
    client = client,
    level = "Study",
    query = query,
    labels = labels,
    labels_constraint = labels_constraint
  )
}

#' Finds series in Orthanc according to queries and labels
#'
#' @param client Orthanc API client.
#' @param query Named-list that specifies the filters on the level related DICOM
#'   tags.
#' @param labels Character vector of labels to look for in resources.
#' @param labels_constraint Contraint on the labels ('All', 'Any', 'None').
#' @param ... Not currently used.
#'
#' @return A `list` of \link{Series}s.
#'
#' @export
find_series <- function(
  client,
  query = list(),
  labels = character(),
  labels_constraint = "All",
  ...
) {
  rlang::check_dots_empty()

  query_orthanc(
    client = client,
    level = "Series",
    query = query,
    labels = labels,
    labels_constraint = labels_constraint
  )
}

#' Finds instances in Orthanc according to queries and labels
#'
#' @param client Orthanc API client.
#' @param query Named-list that specifies the filters on the level related DICOM
#'   tags.
#' @param labels Character vector of labels to look for in resources.
#' @param labels_constraint Contraint on the labels ('All', 'Any', 'None').
#' @param ... Not currently used.
#'
#' @return A `list` of \link{Instance}s.
#'
#' @export
find_instances <- function(
  client,
  query = list(),
  labels = character(),
  labels_constraint = "All",
  ...
) {
  rlang::check_dots_empty()

  query_orthanc(
    client = client,
    level = "Instance",
    query = query,
    labels = labels,
    labels_constraint = labels_constraint
  )
}

#' Query data in the Orthanc server
#'
#' @param client Orthanc API client.
#' @param level Level of the query ('Patient', 'Study', 'Series', 'Instance').
#' @param query Named-list that specifies the filters on the level related DICOM
#'   tags.
#' @param labels Character vector of labels to look for in resources.
#' @param labels_constraint Contraint on the labels ('All', 'Any', 'None').
#' @param limit Limit the number of reported instances (default is `1000L`).
#' @param since Show only the resources since the index specified in the `since`
#'   parameter.
#' @param retrieve_all_resources Retrieve all resources since the index
#'   specified in the `since` parameter.
#' @param lock_children If `lock_children` is `TRUE`, the resource children
#'   (e.g., instances of a series via `Series.instances`) will be cached at the
#'   first query rather than queried every time. This is useful when you want
#'   to filter the children of a resource and want to maintain the filter
#'   result.
#'
#' @return A `list` of resources.
#'
#' @export
query_orthanc = function(
  client,
  level,
  query = list(),
  labels = character(),
  labels_constraint = "All",
  limit = 1000L,
  since = 0L,
  retrieve_all_resources = TRUE,
  lock_children = FALSE
) {
  validate_level(level)
  validate_labels_constraint(labels_constraint)

  data <- list(
    Expand = TRUE,
    Level = level,
    Limit = limit,
    Since = since,
    Query = query
  )

  if (!rlang::is_empty(labels)) {
    data[["Labels"]] <- labels
    data[["LabelsConstraint"]] <- labels_constraint
  }

  if (retrieve_all_resources) {
    results <- list()
    while (TRUE) {
      result_for_interval <- client$post_tools_find(data)
      if (length(result_for_interval) == 0) {
        break
      }

      results <- append(results, result_for_interval)
    }
  } else {
    results <- client$post_tools_find(data)
  }

  if (level == "Patient") {
    resources <- purrr::map(results, \(x) Patient$new(x, client))
  } else if (level == "Study") {
    resources <- purrr::map(results, \(x) Study$new(x, client))
  } else if (level == "Series") {
    resources <- purrr::map(results, \(x) Series$new(x, client))
  } else if (level == "Instance") {
    resources <- purrr::map(results, \(x) Instance$new(x, client))
  } else {
    rlang::abort("Unknown level.")
  }

  resources
}

validate_level = function(level) {
  if (!level %in% c("Patient", "Study", "Series", "Instance")) {
    rlang::abort(
      '`level` should be one of "Patient", "Study", "Series", or "Instance".'
    )
  }
}

validate_labels_constraint = function(constraint) {
  if (!constraint %in% c("All", "Any", "None")) {
    rlang::abort(
      '`labels_constraint` should be one of "All", "Any", or "None".'
    )
  }
}
