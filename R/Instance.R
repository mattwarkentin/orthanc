#' DICOM Instance Class
#'
#' @description
#' An abstract class for a DICOM Instance resource.
#'
#' @return An R6 instance of class `"Instance"`.
#'
#' @export
Instance <- R6::R6Class(
  classname = "Instance",
  inherit = Resource,
  portable = FALSE,
  cloneable = FALSE,
  public = list(
    #' @description Retrieves DICOM file
    #'
    #' This method retrieves bytes corresponding to DICOM file.
    get_dicom_file_content = function() {
      private$.client$get_instances_id_file(private$.id)
    },

    #' @description Download DICOM file to a path.
    #' @param file File path on disk.
    download = function(file) {
      private$.download_file(
        "GET",
        glue::glue("/instances/{private$.id}/file"),
        file
      )
    },

    #' @description Get instance information.
    get_main_information = function() {
      private$.client$get_instances_id(private$.id)
    },

    #' @description Add label to resource.
    #' @param label Label.
    add_label = function(label) {
      private$.client$put_instances_id_labels_label(private$.id, label)
    },

    #' @description Delete label from resource.
    #' @param label Label.
    remove_label = function(label) {
      private$.client$delete_instances_id_labels_label(private$.id, label)
    },

    #' @description Get content by tag.
    #' @param tag tag.
    get_content_by_tag = function(tag) {
      private$.client$get_instances_id_content_path(
        private$.id,
        path = tag
      )
    },

    #' @description Anonymize Instance
    #' @param remove List of tags to remove.
    #' @param replace Named-list of tags to replce.
    #' @param keep List of tags to keep unchanged.
    #' @param force Force tags to be changed.
    #' @param keep_private_tags Keep private tags from DICOM instance.
    #' @param keep_source Keep original resource.
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
      private_creator = NULL,
      force = FALSE,
      dicom_version = NULL
    ) {
      data <- list(
        Remove = remove,
        Replace = replace,
        Keep = keep,
        Force = force,
        KeepPrivateTags = keep_private_tags,
        KeepSource = keep_source
      )

      if (!rlang::is_null(private_creator)) {
        data["PrivateCreator"] <- private_creator
      }

      if (!rlang::is_null(dicom_version)) {
        data["DicomVersion"] <- dicom_version
      }

      private$.client$post_instances_id_anonymize(private$.id, data)
    },

    #' @description Modify an Instance
    #' @param remove List of tags to remove.
    #' @param replace Named-list of tags to replce.
    #' @param keep List of tags to keep unchanged.
    #' @param force Force tags to be changed.
    #' @param remove_private_tags Remove private tags from DICOM instance.
    #' @param keep_source Keep original resource.
    #' @param private_creator Private creator to be used for private tags in
    #'   replace.
    modify = function(
      remove = list(),
      replace = list(),
      keep = list(),
      remove_private_tags = FALSE,
      keep_source = TRUE,
      private_creator = NULL,
      force = FALSE
    ) {
      if (!force & any(names(replace)) == "SOPInstanceUID") {
        rlang::abort("If SOPInstanceUID is replaced, `force` must be `TRUE`")
      }

      data <- list(
        Remove = remove,
        Replace = replace,
        Keep = keep,
        Force = force,
        RemovePrivateTags = remove_private_tags,
        KeepSource = keep_source
      )

      if (!rlang::is_null(private_creator)) {
        data["PrivateCreator"] <- private_creator
      }

      private$.client$post_instances_id_modify(private$.id, data)
    }
  ),
  private = list(
    .type = "Instance"
  ),
  active = list(
    #' @field uid Get the `SOPInstanceUID`.
    uid = function() {
      private$.get_main_dicom_tag_value("SOPInstanceUID")
    },

    #' @field file_size Get the file size.
    file_size = function() {
      self$get_main_information()[["FileSize"]]
    },

    #' @field creation_date Get creation date.
    creation_date = function() {
      private$.get_main_dicom_tag_value("InstanceCreationDate")
    },

    #' @field series_identifier Get parent series identifier.
    series_identifier = function() {
      self$get_main_information()[["ParentSeries"]]
    },

    #' @field parent_series Get parent series.
    parent_series = function() {
      Series$new(self$series_identifier, private$.client)
    },

    #' @field parent_study Get parent study
    parent_study = function() {
      self$parent_series$parent_study
    },

    #' @field parent_patient Get parent patient
    parent_patient = function() {
      self$parent_study$parent_patient
    },

    #' @field acquisition_number Acquisition number.
    acquisition_number = function() {
      as.integer(private$.get_main_dicom_tag_value("AcquisitionNumber"))
    },

    #' @field image_index Image index.
    image_index = function() {
      as.integer(private$.get_main_dicom_tag_value("ImageIndex"))
    },

    #' @field image_orientation_patient Image orientation patient.
    image_orientation_patient = function() {
      private$.get_main_dicom_tag_value("ImageOrientationPatient")
    },

    #' @field image_position_patient Image position patient.
    image_position_patient = function() {
      private$.get_main_dicom_tag_value("ImagePositionPatient")
    },

    #' @field image_comments Image comments.
    image_comments = function() {
      private$.get_main_dicom_tag_value("ImageComments")
    },

    #' @field instance_number Instance number.
    instance_number = function() {
      private$.get_main_dicom_tag_value("InstanceNumber")
    },

    #' @field number_of_frames Number of frames.
    number_of_frames = function() {
      private$.get_main_dicom_tag_value("NumberOfFrames")
    },

    #' @field temporal_position_identifier Temporal position identifier.
    temporal_position_identifier = function() {
      private$.get_main_dicom_tag_value("TemporalPositionIdentifier")
    },

    #' @field tags Get tags.
    tags = function() {
      private$.client$get_instances_id_tags(private$.id)
    },

    #' @field simplified_tags Get simplified tags.
    simplified_tags = function() {
      private$.client$get_instances_id_tags(
        private$.id,
        params = list(simplify = TRUE)
      )
    },

    #' @field labels Get instance labels.
    labels = function() {
      self$get_main_information()[["Labels"]]
    }
  )
)
