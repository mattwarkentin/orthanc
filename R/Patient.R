#' DICOM Patient Class
#'
#' @description
#' An abstract class for a DICOM Patient resource.
#'
#' @return An R6 instance of class `"Patient"`.
#'
#' @export
Patient <- R6::R6Class(
  classname = "Patient",
  inherit = Resource,
  portable = FALSE,
  cloneable = FALSE,
  public = list(
    #' @description Get patient information.
    get_main_information = function() {
      private$.client$get_patients_id(private$.id)
    },

    #' @description Add label to resource.
    #' @param label Label.
    add_label = function(label) {
      private$.client$put_patients_id_labels_label(private$.id, label)
    },

    #' @description Delete label from resource.
    #' @param label Label.
    remove_label = function(label) {
      private$.client$delete_patients_id_labels_label(private$.id, label)
    },

    #' @description Get the bytes of the zip file.
    get_zip = function() {
      private$.client$get_patients_id_archive(private$.id)
    },

    #' @description Download the zip file to a path.
    #' @param file File path on disk.
    download = function(file) {
      private$.download_file(
        "GET",
        glue::glue("/patients/{private$.id}/archive"),
        file
      )
    },

    #' @description Get patient module in a simplified version
    get_patient_module = function() {
      private$.client$get_patients_id_module(
        private$.id,
        params = list(simplify = TRUE)
      )
    },

    #' @description Anonymize Patient
    #' @param remove List of tags to remove.
    #' @param replace Named-list of tags to replce.
    #' @param keep List of tags to keep unchanged.
    #' @param force Force tags to be changed.
    #' @param keep_private_tags Keep private tags from DICOM instance.
    #' @param keep_source Keep original resource.
    #' @param priority Priority of the job.
    #' @param permissive Ignore errors during individual steps of the job?
    #' @param private_creator Private creator to be used for private tags in
    #'   replace.
    #' @param dicom_version Version of the DICOM standard to use for
    #'   anonymization.
    anonymize = function(
      remove = list(),
      replace = list(),
      keep = list(),
      keep_private_tags = FALSE,
      keep_source = TRUE,
      priority = 0L,
      permissive = FALSE,
      private_creator = NULL,
      force = FALSE,
      dicom_version = NULL
    ) {
      data <- list(
        Aysnchronous = FALSE,
        Remove = remove,
        Replace = replace,
        Keep = keep,
        Force = force,
        KeepPrivateTags = keep_private_tags,
        KeepSource = keep_source,
        Priority = priority,
        Permissive = permissive
      )

      if (!rlang::is_null(private_creator)) {
        data["PrivateCreator"] <- private_creator
      }

      if (!rlang::is_null(dicom_version)) {
        data["DicomVersion"] <- dicom_version
      }

      anon_patient <- private$.client$post_patients_id_anonymize(
        private$.id,
        data
      )

      Patient$new(anon_patient[["ID"]], private$.client)
    },

    #' @description Anonymize Patient
    #' @param remove List of tags to remove.
    #' @param replace Named-list of tags to replce.
    #' @param keep List of tags to keep unchanged.
    #' @param force Force tags to be changed.
    #' @param keep_private_tags Keep private tags from DICOM instance.
    #' @param keep_source Keep original resource.
    #' @param priority Priority of the job.
    #' @param permissive Ignore errors during individual steps of the job?
    #' @param private_creator Private creator to be used for private tags in
    #'   replace.
    #' @param dicom_version Version of the DICOM standard to use for
    #'   anonymization.
    anonymize_as_job = function(
      remove = list(),
      replace = list(),
      keep = list(),
      keep_private_tags = FALSE,
      keep_source = TRUE,
      priority = 0L,
      permissive = FALSE,
      private_creator = NULL,
      force = FALSE,
      dicom_version = NULL
    ) {
      data <- list(
        Aysnchronous = TRUE,
        Remove = remove,
        Replace = replace,
        Keep = keep,
        Force = force,
        KeepPrivateTags = keep_private_tags,
        KeepSource = keep_source,
        Priority = priority,
        Permissive = permissive
      )

      if (!rlang::is_null(private_creator)) {
        data["PrivateCreator"] <- private_creator
      }

      if (!rlang::is_null(dicom_version)) {
        data["DicomVersion"] <- dicom_version
      }

      anon_patient <- private$.client$post_patients_id_anonymize(
        private$.id,
        data
      )

      Job$new(anon_patient[["ID"]], private$.client)
    },

    #' @description Modify Patient
    #' @param remove List of tags to remove.
    #' @param replace Named-list of tags to replce.
    #' @param keep List of tags to keep unchanged.
    #' @param force Force tags to be changed.
    #' @param remove_private_tags Remove private tags from DICOM instance.
    #' @param keep_source Keep original resource.
    #' @param priority Priority of the job.
    #' @param permissive Ignore errors during individual steps of the job?
    #' @param private_creator Private creator to be used for private tags in
    #'   replace.
    modify = function(
      remove = list(),
      replace = list(),
      keep = list(),
      remove_private_tags = FALSE,
      keep_source = TRUE,
      priority = 0L,
      permissive = FALSE,
      private_creator = NULL,
      force = FALSE
    ) {
      if (!force & any(names(replace)) == "PatientID") {
        rlang::abort("If PatientID is replaced, `force` must be `TRUE`")
      }

      data <- list(
        Aysnchronous = FALSE,
        Remove = remove,
        Replace = replace,
        Keep = keep,
        Force = force,
        RemovePrivateTags = remove_private_tags,
        KeepSource = keep_source,
        Priority = priority,
        Permissive = permissive
      )

      if (!rlang::is_null(private_creator)) {
        data["PrivateCreator"] <- private_creator
      }

      mod_patient <- private$.client$post_patients_id_modify(private$.id, data)

      private$.main_dicom_tags <- NULL

      Patient$new(mod_patient[["ID"]], private$.client)
    },

    #' @description Modify Patient
    #' @param remove List of tags to remove.
    #' @param replace Named-list of tags to replce.
    #' @param keep List of tags to keep unchanged.
    #' @param force Force tags to be changed.
    #' @param remove_private_tags Remove private tags from DICOM instance.
    #' @param keep_source Keep original resource.
    #' @param priority Priority of the job.
    #' @param permissive Ignore errors during individual steps of the job?
    #' @param private_creator Private creator to be used for private tags in
    #'   replace.
    modify_as_job = function(
      remove = list(),
      replace = list(),
      keep = list(),
      remove_private_tags = FALSE,
      keep_source = TRUE,
      priority = 0L,
      permissive = FALSE,
      private_creator = NULL,
      force = FALSE
    ) {
      if (!force & any(names(replace)) == "PatientID") {
        rlang::abort("If PatientID is replaced, `force` must be `TRUE`")
      }

      data <- list(
        Aysnchronous = TRUE,
        Remove = remove,
        Replace = replace,
        Keep = keep,
        Force = force,
        RemovePrivateTags = remove_private_tags,
        KeepSource = keep_source,
        Priority = priority,
        Permissive = permissive
      )

      if (!rlang::is_null(private_creator)) {
        data["PrivateCreator"] <- private_creator
      }

      mod_patient <- private$.client$post_patients_id_modify(private$.id, data)

      private$.main_dicom_tags <- NULL

      Job$new(mod_patient[["ID"]], private$.client)
    },

    #' @description Retrieve the shared tags of the patient.
    get_shared_tags = function() {
      private$.client$get_patients_id_shared_tags(
        private$.id,
        params = list(simplify = TRUE)
      )
    }
  ),
  active = list(
    #' @field patient_id Patient ID.
    patient_id = function() {
      private$.get_main_dicom_tag_value("PatientID")
    },

    #' @field name Patient Name.
    name = function() {
      private$.get_main_dicom_tag_value("PatientName")
    },

    #' @field birth_date Patient Birth Date.
    birth_date = function() {
      private$.get_main_dicom_tag_value("BirthDate")
    },

    #' @field sex Patient Sex.
    sex = function() {
      private$.get_main_dicom_tag_value("PatientSex")
    },

    #' @field other_patient_ids Other Patient IDs.
    other_patient_ids = function() {
      private$.get_main_dicom_tag_value("OtherPatientIDs")
    },

    #' @field is_stable Is stable?
    is_stable = function() {
      self$get_main_information()[["IsStable"]]
    },

    #' @field last_update Last update.
    last_update = function() {
      self$get_main_information()[["LastUpdate"]]
    },

    #' @field labels Labels.
    labels = function() {
      self$get_main_information()[["Labels"]]
    },

    #' @field protected Get or Set if patient is protected against recycling.
    protected = function(x) {
      if (rlang::is_missing(x)) {
        return(private$.client$get_patients_id_protected(private$.id))
      }
      private$.client$put_patients_id_protected(private$.id, json = list(x))
    },

    #' @field studies Get patient's studies.
    studies = function() {
      studies_ids = self$get_main_information()[["Studies"]]
      purrr::map(studies_ids, \(x) Study$new(x, private$.client))
    },

    #' @field shared_tags Shared tags.
    shared_tags = function() {
      self$get_shared_tags()
    }
  ),
  private = list(
    .type = "Patient"
  )
)
