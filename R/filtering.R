#' Find and filter patients using predicate functions
#'
#' Find desired Patient/Study/Series/Instance in an Orthanc server. Predicate
#'   functions (filters) take a single Patient/Study/Series/Instance as the
#'   first argument and return a single `TRUE` or `FALSE` for whether the
#'   resource should be kept or discarded, respectively.
#'
#' @param client Orthanc client.
#' @param patient_filter Predicate function to filter \link{Patient}s.
#' @param study_filter Predicate function to filter \link{Study}s.
#' @param series_filter Predicate function to filer \link{Series}.
#' @param instance_filter Predicate function to filter \link{Instance}s.
#'
#' @details
#' This function builds a series of tree structures. Each tree corresponds to a
#'   patient. The layers in the tree correspond to:
#'
#'   `Patient -> Studies -> Series -> Instances`
#'
#' @return A `list` of filtered \link{Patient}s.
#'
#' @export
#'
#' @examples
#' client <- Orthanc$new("https://orthanc.uclouvain.be/demo")
#'
#' find_and_filter_patients(
#'   client = client,
#'   series_filter = \(series) series$modality == "CT"
#' )
find_and_filter_patients <- function(
  client,
  patient_filter = NULL,
  study_filter = NULL,
  series_filter = NULL,
  instance_filter = NULL
) {
  check_orthanc_client(client)

  patients <- purrr::map(client$get_patients(), \(x) {
    Patient$new(x, client, TRUE)
  })

  if (!rlang::is_null(patient_filter)) {
    check_function(patient_filter)
    patients <- purrr::keep(patients, patient_filter)
  }

  for (patient in patients) {
    if (!rlang::is_null(study_filter)) {
      check_function(study_filter)
      resources <- purrr::keep(
        .x = patient$studies,
        .p = study_filter
      )
      patient$set_child_resources(resources)
    }

    for (study in patient$studies) {
      if (!rlang::is_null(series_filter)) {
        check_function(series_filter)
        resources <- purrr::keep(
          .x = study$series,
          .p = series_filter
        )
        study$set_child_resources(resources)
      }

      for (series in study$series) {
        if (!rlang::is_null(instance_filter)) {
          check_function(instance_filter)
          resources <- purrr::keep(
            .x = series$instances,
            .p = instance_filter
          )
          series$set_child_resources(resources)
        }
      }
    }
  }

  trim_patients(patients)
}

trim_patients <- function(patients) {
  purrr::walk(patients, \(pt) pt$remove_empty_studies())
  patients <- purrr::discard(patients, \(pt) is_empty_list(pt$studies))
  patients
}
