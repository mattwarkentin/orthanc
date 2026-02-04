#' DICOM Study Class
#'
#' @description
#' An abstract class for a DICOM Study resource.
#'
#' @return An R6 instance of class `"Study"`.
#'
#' @export
Study <- R6::R6Class(
  classname = "Study",
  inherit = Resource,
  portable = FALSE,
  cloneable = FALSE,
  public = list(
    #' @description Get study information.
    get_main_information = function() {
      private$.client$get_studies_id(private$.id)
    },

    #' @description Add label to resource.
    #' @param label Label.
    add_label = function(label) {
      private$.client$put_studies_id_labels_label(private$.id, label)
    },

    #' @description Delete label from resource.
    #' @param label Label.
    remove_label = function(label) {
      private$.client$delete_studies_id_labels_label(private$.id, label)
    },

    #' @description Anonymize Study
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

      anon_study <- private$.client$post_studies_id_anonymize(
        private$.id,
        data
      )

      Study$new(anon_study[["ID"]], private$.client)
    },

    #' @description Anonymize Study
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

      anon_study <- private$.client$post_studies_id_anonymize(
        private$.id,
        data
      )

      Job$new(anon_study[["ID"]], private$.client)
    },

    #' @description Modify Study
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
      if (!force & any(names(replace)) == "StudyInstanceUID") {
        rlang::abort("If StudyInstanceUID is replaced, `force` must be `TRUE`")
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

      mod_study <- private$.client$post_studies_id_modify(private$.id, data)

      private$.main_dicom_tags <- NULL

      Study$new(mod_study[["ID"]], private$.client)
    },

    #' @description Modify Study as Job
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
      if (!force & any(names(replace)) == "StudyInstanceUID") {
        rlang::abort("If StudyInstanceUID is replaced, `force` must be `TRUE`")
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

      mod_study <- private$.client$post_studies_id_modify(private$.id, data)

      private$.main_dicom_tags <- NULL

      Job$new(mod_study[["ID"]], private$.client)
    },

    #' @description Get the bytes of the zip file.
    get_zip = function() {
      private$.client$get_studies_id_archive(private$.id)
    },

    #' @description Download the zip file to a path.
    #' @param file File path on disk.
    download = function(file) {
      private$.download_file(
        "GET",
        glue::glue("/studies/{private$.id}/archive"),
        file
      )
    },

    #' @description Retrieve the shared tags of the study.
    get_shared_tags = function() {
      private$.client$get_studies_id_shared_tags(
        private$.id,
        params = list(simplify = TRUE)
      )
    }
  ),
  private = list(
    .type = "Study"
  ),
  active = list(
    #' @field patient_identifier Get parent patient identifier.
    patient_identifier = function() {
      self$get_main_information()[["ParentPatient"]]
    },

    #' @field parent_patient Get parent patient
    parent_patient = function() {
      Patient$new(self$patient_identifier, private$.client)
    },

    #' @field referring_physician_name Referring Physician Name
    referring_physician_name = function() {
      private$.get_main_dicom_tag_value("ReferringPhysicianName")
    },

    #' @field requesting_physician Requesting Physician
    requesting_physician = function() {
      private$.get_main_dicom_tag_value("RequestingPhysician")
    },

    #' @field date Study Date
    date = function() {
      private$.get_main_dicom_tag_value("StudyDate")
    },

    #' @field study_id Study ID
    study_id = function() {
      private$.get_main_dicom_tag_value("StudyID")
    },

    #' @field uid StudyInstanceUID
    uid = function() {
      private$.get_main_dicom_tag_value("StudyInstanceUID")
    },

    #' @field patient_information Patient Main DICOM Tags
    patient_information = function() {
      self$get_main_information()[["PatientMainDicomTags"]]
    },

    #' @field series Get patient's series
    series = function() {
      series_ids = self$get_main_information()[["Series"]]
      purrr::map(series_ids, \(x) Series$new(x, private$.client))
    },

    #' @field accession_number Accession Number
    accession_number = function() {
      private$.get_main_dicom_tag_value("AccessionNumber")
    },

    #' @field description Description
    description = function() {
      private$.get_main_dicom_tag_value("StudyDescription")
    },

    #' @field institution_name Institution Name
    institution_name = function() {
      private$.get_main_dicom_tag_value("InstitutionName")
    },

    #' @field requested_procedure_description Requested procedure
    #'   description.
    requested_procedure_description = function() {
      private$.get_main_dicom_tag_value("RequestedProcedureDescription")
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

    #' @field shared_tags Shared tags.
    shared_tags = function() {
      self$get_shared_tags()
    }
  )
)
