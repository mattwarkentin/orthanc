#' DICOM Series Class
#'
#' @description
#' An abstract class for a DICOM Series resource.
#'
#' @return An R6 instance of class `"Series"`.
#'
#' @importFrom purrr map
#'
#' @export
Series <- R6::R6Class(
  classname = "Series",
  inherit = Resource,
  portable = FALSE,
  cloneable = FALSE,
  public = list(
    #' @description Get series information.
    get_main_information = function() {
      private$client$get_series_id(private$id)
    },

    #' @description Add label to resource.
    #' @param label Label.
    add_label = function(label) {
      check_scalar_character(label)
      private$client$put_series_id_labels_label(private$id, label)
    },

    #' @description Delete label from resource.
    #' @param label Label.
    remove_label = function(label) {
      check_scalar_character(label)
      private$client$delete_series_id_labels_label(private$id, label)
    },

    #' @description Anonymize Series
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

      anon_series <- private$client$post_series_id_anonymize(private$id, data)

      Series$new(anon_series[["ID"]], private$client)
    },

    #' @description Anonymize Series
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

      anon_series <- private$client$post_series_id_anonymize(private$id, data)

      Job$new(anon_series[["ID"]], private$client)
    },

    #' @description Modify Series
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

      if (!force & any(names(replace)) == "SeriesInstanceUID") {
        rlang::abort("If SeriesInstanceUID is replaced, `force` must be `TRUE`")
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

      mod_series <- private$client$post_series_id_modify(private$id, data)

      private$.main_dicom_tags <- NULL

      Series$new(mod_series[["ID"]], private$client)
    },

    #' @description Modify Series
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

      if (!force & any(names(replace)) == "SeriesInstanceUID") {
        rlang::abort("If SeriesInstanceUID is replaced, `force` must be `TRUE`")
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

      mod_series <- private$client$post_series_id_modify(private$id, data)

      private$.main_dicom_tags <- NULL

      Job$new(mod_series[["ID"]], private$client)
    },

    #' @description Get the bytes of the zip file.
    get_zip = function() {
      private$client$get_series_id_archive(private$id)
    },

    #' @description Download the zip file to a path.
    #' @param file File path on disk.
    download = function(file) {
      check_scalar_character(file)
      private$download_file(
        "GET",
        glue::glue("/series/{private$id}/archive"),
        file
      )
    },

    #' @description Retrieve the shared tags of the series.
    get_shared_tags = function() {
      private$client$get_series_id_shared_tags(
        private$id,
        params = list(simplify = TRUE)
      )
    },

    #' @description Remove empty instances from series.
    remove_empty_instances = function() {
      if (!rlang::is_empty(private$child_resources)) {
        self$set_child_resources(purrr::compact(private$child_resources))
      }
      invisible(self)
    },

    #' @description Download series as NIfTI.
    #' @param path Path on disk.
    #' @param compress Compress to gzip.
    download_nifti = function(path, compress = FALSE) {
      if (!client_has_plugin(private$client, "neuro")) {
        rlang::abort(
          glue::glue("Orthanc client does not have required plugin `{plugin}`.")
        )
      }

      check_scalar_character(path)
      check_scalar_logical(compress)

      if (!fs::dir_exists(path)) {
        rlang::abort("`path` does not exist.")
      }
      path <- fs::path_expand(path)

      params <- NULL

      if (compress) {
        file <- glue::glue("{path}/{self$uid}.nii.gz")
        params <- list(compress = "")
      } else {
        file <- glue::glue("{path}/{self$uid}.nii")
      }

      bytes <- private$client$GET(
        glue::glue("/series/{self$identifier}/nifti"),
        params = params
      )

      file_con <- file(file, "wb")
      writeBin(as.raw(bytes), file_con)
    }
  ),
  private = list(
    resource_type = "Series"
  ),
  active = list(
    #' @field instances Instances
    instances = function() {
      if (private$lock_children) {
        if (rlang::is_null(private$child_resources)) {
          instances_ids <- self$get_main_information()[["Instances"]]
          private$child_resources = purrr::map(instances_ids, \(id) {
            Instance$new(id, private$client, private$lock_children)
          })
        }
        return(private$child_resources)
      }

      instances_ids = self$get_main_information()[["Instances"]]
      purrr::map(instances_ids, \(id) Instance$new(id, private$client))
    },

    #' @field instances_ids Instances identifiers
    instances_ids = function() {
      purrr::map_chr(
        private$client$get_series_id_instances(self$identifier),
        \(x) x$ID
      )
    },

    #' @field instances_tags Instances tags
    instances_tags = function() {
      private$client$get_series_id_instances_tags(
        self$identifier,
        params = list(simplify = TRUE)
      )
    },

    #' @field uid SeriesInstanceUID
    uid = function() {
      private$get_main_dicom_tag_value("SeriesInstanceUID")
    },

    #' @field manufacturer Manufacturer
    manufacturer = function() {
      private$get_main_dicom_tag_value("Manufacturer")
    },

    #' @field date Series Date
    date = function() {
      private$get_main_dicom_tag_value("SeriesDate")
    },

    #' @field modality Modality
    modality = function() {
      private$get_main_dicom_tag_value("Modality")
    },

    #' @field series_number Series Number
    series_number = function() {
      private$get_main_dicom_tag_value("SeriesNumber")
    },

    #' @field performed_procedure_step_description Performed Procedure Step
    #'   Description
    performed_procedure_step_description = function() {
      private$get_main_dicom_tag_value("PerformedProcedureStepDescription")
    },

    #' @field protocol_name Protocol Name
    protocol_name = function() {
      private$get_main_dicom_tag_value("ProtocolName")
    },

    #' @field station_name Station Name
    station_name = function() {
      private$get_main_dicom_tag_value("StationName")
    },

    #' @field description Series Description
    description = function() {
      private$get_main_dicom_tag_value("SeriesDescription")
    },

    #' @field body_part_examined Body Part Examined
    body_part_examined = function() {
      private$get_main_dicom_tag_value("BodyPartExamined")
    },

    #' @field sequence_name Sequence Name
    sequence_name = function() {
      private$get_main_dicom_tag_value("SequenceName")
    },

    #' @field cardiac_number_of_images Cardiac Number of Images
    cardiac_number_of_images = function() {
      private$get_main_dicom_tag_value("CardiacNumberOfImages")
    },

    #' @field image_in_acquisition Images in Acquisition
    image_in_acquisition = function() {
      private$get_main_dicom_tag_value("ImagesInAcquisition")
    },

    #' @field number_of_temporal_positions Number of Temporal Positions
    number_of_temporal_positions = function() {
      private$get_main_dicom_tag_value("NumberOfTemporalPositions")
    },

    #' @field number_of_slices Number of Slices
    number_of_slices = function() {
      private$get_main_dicom_tag_value("NumberOfSlices")
    },

    #' @field number_of_time_slices Number of Time Slices
    number_of_time_slices = function() {
      private$get_main_dicom_tag_value("NumberOfTimeSlices")
    },

    #' @field image_orientation_patient Image Orientation Patient
    image_orientation_patient = function() {
      private$get_main_dicom_tag_value("ImageOrientationPatient")
    },

    #' @field series_type Series Type
    series_type = function() {
      private$get_main_dicom_tag_value("SeriesType")
    },

    #' @field operators_name Operators Name
    operators_name = function() {
      private$get_main_dicom_tag_value("OperatorsName")
    },

    #' @field acquisition_device_processing_description Acquisition Device
    #'   Processing Description
    acquisition_device_processing_description = function() {
      private$get_main_dicom_tag_value(
        "AcquisitionDeviceProcessingDescription"
      )
    },

    #' @field contrast_bolus_agent Contrast Bolus Agent
    contrast_bolus_agent = function() {
      private$get_main_dicom_tag_value("ContrastBolusAgent")
    },

    #' @field is_stable Is stable?
    is_stable = function() {
      self$get_main_information()[["IsStable"]]
    },

    #' @field last_update Last Update
    last_update = function() {
      self$get_main_information()[["LastUpdate"]]
    },

    #' @field labels Labels
    labels = function() {
      self$get_main_information()[["Labels"]]
    },

    #' @field study_identifier Parent study identifier
    study_identifier = function() {
      self$get_main_information()[["ParentStudy"]]
    },

    #' @field parent_study Parent study
    parent_study = function() {
      Study$new(self$study_identifier, private$client)
    },

    #' @field parent_patient Parent patient
    parent_patient = function() {
      self$parent_study$parent_patient
    },

    #' @field shared_tags Shared tags
    shared_tags = function() {
      self$get_shared_tags()
    },

    #' @field statistics Statistics
    statistics = function() {
      private$client$get_series_id_statistics(self$identifier)
    }
  )
)
