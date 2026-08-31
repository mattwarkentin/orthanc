#' Find and filter patients using predicate functions
#'
#' Find desired Patient/Study/Series/Instance in an Orthanc server. Predicate
#'   functions (filters) take a single Patient/Study/Series/Instance as the
#'   first argument and return a single `TRUE` or `FALSE` for whether the
#'   resource should be kept or discarded, respectively. If [mirai::daemons()]
#'   has been used to set persistent background processes, this function will
#'   apply filters in parallel (over patients) using all available processes.
#'
#' @param client Orthanc client.
#' @param patient_filter Predicate function to filter [Patient]s.
#' @param study_filter Predicate function to filter [Study]s.
#' @param series_filter Predicate function to filter [Series].
#' @param instance_filter Predicate function to filter [Instance]s.
#' @param progress Whether to show progress bars. By default, progress bars are
#'   enabled in interactive sessions (i.e., if `rlang::is_interactive()`
#'   returns `TRUE`).
#' @param ... Named-arguments to declare in the environment of the predicate
#'   functions, if performing filtering in parallel with `mirai`. If your
#'   predicate functions require access to objects in the global environment, ]
#'   you must pass them to `...` so they are available on each background worker
#'   when running in parallel (i.e., when [mirai::daemons()] has been set).
#'
#' @details
#' This function builds a series of tree structures. Each tree corresponds to a
#'   patient. The layers in the tree correspond to:
#'
#'   `Patient -> Studies -> Series -> Instances`
#'
#' @return A `list` of filtered [Patient]s.
#'
#' @import carrier
#'
#' @export
#'
#' @examples
#' \dontrun{
#' client <- Orthanc$new("https://orthanc.uclouvain.be/demo")
#'
#' find_and_filter_patients(
#'   client = client,
#'   patient_filter = \(pt) pt$is_stable
#' )
#' }
find_and_filter_patients <- function(
  client,
  patient_filter = NULL,
  study_filter = NULL,
  series_filter = NULL,
  instance_filter = NULL,
  progress = rlang::is_interactive(),
  ...
) {
  check_orthanc_client(client)
  check_scalar_logical(progress)
  rlang::check_dots_used()

  patients <- purrr::map(
    client$get_patients(),
    \(x) {
      Patient$new(x, client, TRUE)
    },
    .progress = ifelse(progress, "Getting Patients", FALSE)
  )

  if (!rlang::is_null(patient_filter)) {
    check_function(patient_filter)
    patients_to_keep <- purrr::map_lgl(
      .x = patients,
      .f = purrr::in_parallel(
        .f = \(patient) patient_filter(patient),
        patient_filter = patient_filter,
        ...
      ),
      .progress = ifelse(progress, "Filtering Patients", FALSE)
    )
    patients <- patients[patients_to_keep]

    if (is_empty_list(patients)) {
      return(list())
    }
  }

  patients <- purrr::map(
    .x = patients,
    .f = purrr::in_parallel(
      \(patient) {
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
        patient
      },
      study_filter = study_filter,
      series_filter = series_filter,
      instance_filter = instance_filter,
      check_function = check_function,
      ...
    ),
    .progress = ifelse(progress, "Filtering Resources", FALSE)
  )

  trim_patients(patients, progress)
}

trim_patients <- function(patients, progress) {
  purrr::discard(
    .x = patients,
    .p = \(pt) {
      pt$remove_empty_studies()
      is_empty_list(pt$studies)
    },
    .progress = ifelse(progress, "Trimming Patients", FALSE)
  )
}
