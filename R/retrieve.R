#' Retrieve and write patients to a path
#'
#' Retrieve the DICOM file contents for a list of [Patient]s and write them
#'   to a `path` on disk. DICOM files are saved to disk in a directory structure
#'   of `Patient -> Study -> Series -> File`. If [mirai::daemons()] has
#'   been used to set persistent background processes, this function will write
#'   patients to disk in parallel using all available processes.
#'
#' @param patients List of [Patient]s
#' @param path Path where you want to write the patients (files).
#' @param progress Whether to show progress bars. By default, progress bars are
#'   enabled in interactive sessions (i.e., if `rlang::is_interactive()`
#'   returns `TRUE`).
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
  progress = rlang::is_interactive()
) {
  check_list(patients)
  check_scalar_character(path)
  check_scalar_logical(progress)

  if (!fs::dir_exists(path)) {
    rlang::abort("`path` does not exist.")
  }
  purrr::walk(
    .x = patients,
    .f = purrr::in_parallel(
      .f = \(x) retrieve_and_write_patient(x, path),
      path = path,
      retrieve_and_write_patient = retrieve_and_write_patient,
      retrieve_and_write_study = retrieve_and_write_study,
      retrieve_and_write_series = retrieve_and_write_series,
      retrieve_and_write_instance = retrieve_and_write_instance
    ),
    .progress = ifelse(progress, "Exporting Patients", FALSE)
  )
  invisible()
}

retrieve_and_write_patient = function(patient, path) {
  patient_id <- patient$patient_id
  if (patient_id == "" || rlang::is_null(patient_id)) {
    patient_id <- "unknown"
  }
  patient_path <- glue::glue("{path}/{patient_id}")
  purrr::walk(patient$studies, \(x) retrieve_and_write_study(x, patient_path))
}

retrieve_and_write_study = function(study, patient_path) {
  study_path <- glue::glue("{patient_path}/{study$uid}")
  purrr::walk(study$series, \(x) retrieve_and_write_series(x, study_path))
}

retrieve_and_write_series = function(series, study_path) {
  series_path <- glue::glue("{study_path}/{series$uid}")
  fs::dir_create(series_path, recurse = TRUE)
  purrr::walk(series$instances, \(x) {
    retrieve_and_write_instance(x, series_path)
  })
}

retrieve_and_write_instance = function(instance, series_path) {
  instance_path <- fs::path_expand(glue::glue(
    "{series_path}/{instance$uid}.dcm"
  ))

  file_con <- file(instance_path, "wb")
  on.exit(close(file_con))

  dicom_instance_bytes <- instance$get_dicom_file_content()

  writeBin(as.raw(dicom_instance_bytes), file_con)
}
