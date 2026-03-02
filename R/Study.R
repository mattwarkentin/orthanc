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
      private$client$get_studies_id(private$id)
    },

    #' @description Add label to resource.
    #' @param label Label.
    add_label = function(label) {
      check_scalar_character(label)
      private$client$put_studies_id_labels_label(self$identifier, label)
    },

    #' @description Test if resource has label.
    #' @param label Label.
    has_label = function(label) {
      check_scalar_character(label)
      tryCatch(
        {
          private$client$get_instances_id_labels_label(self$identifier, label)
          return(TRUE)
        },
        httr2_http_404 = function(e) return(FALSE)
      )
    },

    #' @description Delete label from resource.
    #' @param label Label.
    remove_label = function(label) {
      check_scalar_character(label)
      private$client$delete_studies_id_labels_label(self$identifier, label)
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
      check_list(remove)
      check_list(replace)
      check_list(keep)
      check_scalar_logical(keep_private_tags)
      check_scalar_logical(keep_source)
      check_scalar_integer(priority)
      check_scalar_logical(permissive)
      check_scalar_logical(force)

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
        check_scalar_character(private_creator)
        data["PrivateCreator"] <- private_creator
      }

      if (!rlang::is_null(dicom_version)) {
        check_scalar_character(dicom_version)
        data["DicomVersion"] <- dicom_version
      }

      anon_study <- private$client$post_studies_id_anonymize(
        private$id,
        data
      )

      Study$new(anon_study[["ID"]], private$client)
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
      check_list(remove)
      check_list(replace)
      check_list(keep)
      check_scalar_logical(keep_private_tags)
      check_scalar_logical(keep_source)
      check_scalar_integer(priority)
      check_scalar_logical(permissive)
      check_scalar_logical(force)

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
        check_scalar_character(private_creator)
        data["PrivateCreator"] <- private_creator
      }

      if (!rlang::is_null(dicom_version)) {
        check_scalar_character(dicom_version)
        data["DicomVersion"] <- dicom_version
      }

      anon_study <- private$client$post_studies_id_anonymize(
        private$id,
        data
      )

      Job$new(anon_study[["ID"]], private$client)
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
      check_list(remove)
      check_list(replace)
      check_list(keep)
      check_scalar_logical(remove_private_tags)
      check_scalar_logical(keep_source)
      check_scalar_integer(priority)
      check_scalar_logical(permissive)
      check_scalar_logical(force)

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
        check_scalar_character(private_creator)
        data["PrivateCreator"] <- private_creator
      }

      mod_study <- private$client$post_studies_id_modify(private$id, data)

      private$.main_dicom_tags <- NULL

      Study$new(mod_study[["ID"]], private$client)
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
      check_list(remove)
      check_list(replace)
      check_list(keep)
      check_scalar_logical(remove_private_tags)
      check_scalar_logical(keep_source)
      check_scalar_integer(priority)
      check_scalar_logical(permissive)
      check_scalar_logical(force)

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
        check_scalar_character(private_creator)
        data["PrivateCreator"] <- private_creator
      }

      mod_study <- private$client$post_studies_id_modify(private$id, data)

      private$.main_dicom_tags <- NULL

      Job$new(mod_study[["ID"]], private$client)
    },

    #' @description Get bytes of the zip archive.
    get_zip_archive_content = function() {
      private$client$get_studies_id_archive(self$identifier)
    },

    #' @description Download zip archive to `path`.
    #' @param path Path on disk.
    #' @param stream Should the resource be streamed and written to disk in
    #'   chunks? Default is `FALSE`, which means the resource file contents are
    #'   retrieved in their entirety and written to disk all at once.
    download_archive = function(path, stream = FALSE) {
      check_path_exists(path)
      file <- glue::glue("{path}/{self$uid}.zip")
      if (stream) {
        private$download_file_stream(
        "GET",
          glue::glue("/studies/{self$identifier}/archive"),
        file
      )
      } else {
        private$download_file_whole(self$get_zip_archive_content(), file)
      }
    },

    #' @description Retrieve the shared tags of the study.
    get_shared_tags = function() {
      private$client$get_studies_id_shared_tags(
        private$id,
        params = list(simplify = TRUE)
      )
    },

    #' @description Remove empty series from study.
    remove_empty_series = function() {
      if (rlang::is_empty(private$child_resources)) {
        return(invisible(self))
      }

      purrr::walk(private$child_resources, \(series) {
        series$remove_empty_instances()
      })

      resources <- purrr::discard(
        .x = private$child_resources,
        .p = \(series) {
          is_empty_list(series$private$child_resources)
        }
      )

      self$set_child_resources(resources)

      invisible(self)
    }
  ),
  private = list(
    resource_type = "Study"
  ),
  active = list(
    #' @field patient_identifier Parent patient identifier
    patient_identifier = function() {
      self$get_main_information()[["ParentPatient"]]
    },

    #' @field parent_patient Parent patient
    parent_patient = function() {
      Patient$new(self$patient_identifier, private$client)
    },

    #' @field referring_physician_name Referring Physician Name
    referring_physician_name = function() {
      private$get_main_dicom_tag_value("ReferringPhysicianName")
    },

    #' @field requesting_physician Requesting Physician
    requesting_physician = function() {
      private$get_main_dicom_tag_value("RequestingPhysician")
    },

    #' @field date Study Date
    date = function() {
      parse_dicom_date(private$get_main_dicom_tag_value("StudyDate"))
    },

    #' @field study_id Study ID
    study_id = function() {
      private$get_main_dicom_tag_value("StudyID")
    },

    #' @field uid StudyInstanceUID
    uid = function() {
      private$get_main_dicom_tag_value("StudyInstanceUID")
    },

    #' @field patient_information Patient Main DICOM Tags
    patient_information = function() {
      self$get_main_information()[["PatientMainDicomTags"]]
    },

    #' @field series_ids Series identifiers
    series_ids = function() {
      purrr::map_chr(
        private$client$get_studies_id_series(self$identifier),
        \(x) x$ID
      )
    },

    #' @field instances_ids Instances identifiers
    instances_ids = function() {
      purrr::map_chr(
        private$client$get_studies_id_instances(self$identifier),
        \(x) x$ID
      )
    },

    #' @field series Series
    series = function() {
      if (private$lock_children) {
        if (rlang::is_null(private$child_resources)) {
          series_ids = self$get_main_information()[["Series"]]
          private$child_resources = purrr::map(series_ids, \(id) {
            Series$new(id, private$client, private$lock_children)
          })
        }
        return(private$child_resources)
      }

      series_ids = self$get_main_information()[["Series"]]
      purrr::map(series_ids, \(id) Series$new(id, private$client))
    },

    #' @field instances Instances
    instances = function() {
      purrr::map(self$instances_ids, \(i) {
        Instance$new(i, private$client, private$lock_children)
      })
    },

    #' @field instances_tags Instances tags
    instances_tags = function() {
      private$client$get_studies_id_instances_tags(
        self$identifier,
        params = list(simplify = TRUE)
      )
    },

    #' @field accession_number Accession Number
    accession_number = function() {
      private$get_main_dicom_tag_value("AccessionNumber")
    },

    #' @field description Description
    description = function() {
      private$get_main_dicom_tag_value("StudyDescription")
    },

    #' @field institution_name Institution Name
    institution_name = function() {
      private$get_main_dicom_tag_value("InstitutionName")
    },

    #' @field requested_procedure_description Requested Procedure
    #'   Description.
    requested_procedure_description = function() {
      private$get_main_dicom_tag_value("RequestedProcedureDescription")
    },

    #' @field is_stable Is stable?
    is_stable = function() {
      self$get_main_information()[["IsStable"]]
    },

    #' @field last_update Last Update
    last_update = function() {
      parse_dicom_date(self$get_main_information()[["LastUpdate"]])
    },

    #' @field labels Get or add labels
    labels = function(label) {
      if (rlang::is_missing(label)) {
        return(self$get_main_information()[["Labels"]])
      }
      self$add_label(label)
    },

    #' @field shared_tags Shared Tags
    shared_tags = function() {
      self$get_shared_tags()
    },

    #' @field statistics Statistics
    statistics = function() {
      private$client$get_studies_id_statistics(self$identifier)
    }
  )
)
