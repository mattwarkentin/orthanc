#' Retrieve and write patients to a path
#'
#' Retrieve the DICOM file contents for a list of [Patient]s and write them
#'   to a `path` on disk. DICOM files are saved to disk in a directory structure
#'   of `Patient -> Study -> Series -> File`. If [mirai::daemons()] has
#'   been used to set persistent background processes, this function will write
#'   patients to disk in parallel using all available processes.
#'
#' @param patients List of [Patient]s.
#' @param path Path where you want to write the patients (files).
#' @param progress Whether to show progress bars. By default, progress bars are
#'   enabled in interactive sessions (i.e., if `rlang::is_interactive()`
#'   returns `TRUE`).
#' @param stream Should the resources be streamed and written to disk in
#'   chunks? Default is `FALSE`, which means the resource file contents are
#'   retrieved in their entirety and written to disk all at once.
#'
#' @return Nothing, invisibly.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' client <- Orthanc$new("https://orthanc.uclouvain.be/demo")
#'
#' patients <- find_patients(client, query = list(PatientName = "HN_P001"))
#'
#' retrieve_and_write_patients(patients, tempdir())
#' }
retrieve_and_write_patients = function(
  patients,
  path,
  stream = FALSE,
  progress = rlang::is_interactive()
) {
  check_list_of_class_any(patients, "Patient")
  check_path_exists(path)
  check_scalar_logical(progress)
  check_scalar_logical(stream)

  purrr::walk(
    .x = patients,
    .f = purrr::in_parallel(
      .f = \(x) retrieve_and_write_patient(x, path, stream),
      path = path,
      retrieve_and_write_patient = retrieve_and_write_patient,
      retrieve_and_write_study = retrieve_and_write_study,
      retrieve_and_write_series = retrieve_and_write_series,
      retrieve_and_write_instance = retrieve_and_write_instance,
      stream = stream
    ),
    .progress = ifelse(progress, "Exporting Patients", FALSE)
  )
  invisible()
}

retrieve_and_write_patient = function(patient, path, stream) {
  patient_id <- patient$patient_id
  if (patient_id == "" || rlang::is_null(patient_id)) {
    patient_id <- "unknown"
  }
  patient_path <- glue::glue("{path}/{patient_id}")
  purrr::walk(patient$studies, \(x) {
    retrieve_and_write_study(x, patient_path, stream)
  })
}

retrieve_and_write_study = function(study, patient_path, stream) {
  study_path <- glue::glue("{patient_path}/{study$uid}")
  purrr::walk(study$series, \(x) {
    retrieve_and_write_series(x, study_path, stream)
  })
}

retrieve_and_write_series = function(series, study_path, stream) {
  series_path <- glue::glue("{study_path}/{series$uid}")
  fs::dir_create(series_path, recurse = TRUE)
  purrr::walk(series$instances, \(x) {
    retrieve_and_write_instance(x, series_path, stream)
  })
}

retrieve_and_write_instance = function(instance, series_path, stream) {
  instance$download_dicom(series_path, stream)
}
