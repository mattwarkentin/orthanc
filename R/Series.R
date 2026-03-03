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
  public = list(
    #' @description Get series information.
    get_main_information = function() {
      private$client$get_series_id(self$identifier)
    },

    #' @description Add label to resource.
    #' @param label Label.
    add_label = function(label) {
      check_scalar_character(label)
      private$client$put_series_id_labels_label(self$identifier, label)
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
      private$client$delete_series_id_labels_label(self$identifier, label)
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

      anon_series <- private$client$post_series_id_anonymize(
        self$identifier,
        data
      )

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

      anon_series <- private$client$post_series_id_anonymize(
        self$identifier,
        data
      )

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

      mod_series <- private$client$post_series_id_modify(self$identifier, data)

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

      mod_series <- private$client$post_series_id_modify(self$identifier, data)

      private$.main_dicom_tags <- NULL

      Job$new(mod_series[["ID"]], private$client)
    },

    #' @description Get bytes of the zip archive.
    get_zip_archive_content = function() {
      private$client$get_series_id_archive(self$identifier)
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
          glue::glue("/series/{self$identifier}/archive"),
          file
        )
      } else {
        private$download_file_whole(self$get_zip_archive_content(), file)
      }
    },

    #' @description Retrieve the shared tags of the series.
    get_shared_tags = function() {
      private$client$get_series_id_shared_tags(
        self$identifier,
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

    #' @description Get bytes of NIfTI file content.
    #' @param compress Compress to gzip (nii.gz) Default is `TRUE`.
    get_nifti_file_content = function(compress = TRUE) {
      if (!client_has_plugin(private$client, "neuro")) {
        rlang::abort(
          glue::glue("Orthanc client does not have required plugin `{plugin}`.")
        )
      }

      params <- NULL

      if (compress) {
        params <- list(compress = "")
      }

      private$client$GET(
        route = glue::glue("/series/{self$identifier}/nifti"),
        params = params
      )
    },

    #' @description Download series as NIfTI.
    #' @param path Path on disk.
    #' @param compress Compress to gzip (`nii.gz`) Default is `TRUE`.
    #' @param stream Should the resource be streamed and written to disk in
    #'   chunks? Default is `FALSE`, which means the resource contents are
    #'   retrieved in their entirety and written to disk all at once.
    download_nifti = function(path, compress = TRUE, stream = FALSE) {
      if (!client_has_plugin(private$client, "neuro")) {
        rlang::abort(
          glue::glue("Orthanc client does not have required plugin `{plugin}`.")
        )
      }

      check_path_exists(path)
      check_scalar_logical(compress)
      check_scalar_logical(stream)

      params <- NULL

      if (compress) {
        file <- glue::glue("{path}/{self$uid}.nii.gz")
        params <- list(compress = "")
      } else {
        file <- glue::glue("{path}/{self$uid}.nii")
      }

      route <- glue::glue("/series/{self$identifier}/nifti")

      if (stream) {
        private$download_file_stream(
          method = "GET",
          route = route,
          file = file,
          params = params
        )
      } else {
        private$download_file_whole(self$get_nifti_file_content(compress), file)
      }
    }
  ),
  private = list(
    resource_type = "Series",
    populate_child_resources = function() {
      instances_ids <- self$get_main_information()[["Instances"]]
      private$child_resources = purrr::map(instances_ids, \(id) {
        Instance$new(id, private$client, private$lock_children)
      })
      invisible(self)
    }
  ),
  active = list(
    #' @field instances Instances
    instances = function() {
      if (private$lock_children) {
        if (rlang::is_null(private$child_resources)) {
          private$populate_child_resources()
        }
        return(private$child_resources)
      }

      instances_ids = self$get_main_information()[["Instances"]]
      purrr::map(instances_ids, \(id) Instance$new(id, private$client))
    },

    #' @field instances_ids Instances identifiers
    instances_ids = function() {
      if (private$lock_children) {
        ids <- purrr::map_chr(self$instances, \(x) x$identifier)
        return(ids)
      }
      purrr::map_chr(
        private$client$get_series_id_instances(self$identifier),
        \(x) x$ID
      )
    },

    #' @field num_instances Number of instances
    num_instances = function() {
      length(self$instances_ids)
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
      parse_dicom_date(private$get_main_dicom_tag_value("SeriesDate"))
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
      parse_dicom_date(self$get_main_information()[["LastUpdate"]])
    },

    #' @field labels Get or add labels
    labels = function(label) {
      if (rlang::is_missing(label)) {
        return(self$get_main_information()[["Labels"]])
      }
      self$add_label(label)
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
