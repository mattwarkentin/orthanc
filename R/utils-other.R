sync_to_async <- function(client) {
  OrthancAsync$new(client$url, client$private$username, client$private$password)
}

async_to_sync <- function(client) {
  Orthanc$new(client$url, client$private$username, client$private$password)
}

to_orthanc_patient_id <- function(patient_id) {
  make_orthanc_id(patient_id)
}

to_orthanc_study_id <- function(patient_id, study_uid) {
  make_orthanc_id(patient_id, study_uid)
}

to_orthanc_series_id <- function(patient_id, study_uid, series_uid) {
  make_orthanc_id(patient_id, study_uid, series_uid)
}

to_orthanc_instance_id <- function(
  patient_id,
  study_uid,
  series_uid,
  instance_uid
) {
  make_orthanc_id(patient_id, study_uid, series_uid, instance_uid)
}

make_orthanc_id <- function(
  patient_id,
  study_uid = NULL,
  series_uid = NULL,
  instance_uid = NULL
) {
  ids <- list(patient_id, study_uid, series_uid, instance_uid)

  ids <- purrr::compact(ids)

  ids_string <- glue::glue_collapse(ids, sep = "|")

  uid <- digest::digest(ids_string, algo = "sha1", serialize = FALSE)

  sub("(\\S{8})(\\S{8})(\\S{8})(\\S{8})(\\S{8})", "\\1-\\2-\\3-\\4-\\5", uid)
}
