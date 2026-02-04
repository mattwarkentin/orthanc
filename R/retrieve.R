#' Retrieve and write patients to given path
#'
#' @param patients List of \link{Patient}s
#' @param path Path where you want to write the files.
#'
#' @return Nothing, invisibly.
#'
#' @export
retrieve_and_write_patients = function(patients, path) {
  if (!fs::dir_exists(path)) {
    rlang::abort("`path` does not exist.")
  }
  for (patient in patients) {
    retrieve_and_write_patient(patient, path)
  }
  invisible()
}

retrieve_and_write_patient = function(patient, path) {
  patient_id <- patient$patient_id
  patient_path <- glue::glue("{path}/{patient_id}")

  for (study in patient$studies) {
    retrieve_and_write_study(study, patient_path)
  }
}

retrieve_and_write_study = function(study, patient_path) {
  study_path <- glue::glue("{patient_path}/{study$uid}")

  for (series in study$series) {
    retrieve_and_write_series(series, study_path)
  }
}

retrieve_and_write_series = function(series, study_path) {
  series_path <- glue::glue("{study_path}/{series$uid}")

  fs::dir_create(series_path, recurse = TRUE)

  for (instance in series$instances) {
    retrieve_and_write_instance(instance, series_path)
  }
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
