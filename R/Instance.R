#' DICOM Instance Class
#'
#' @description
#' An abstract class for a DICOM Instance resource.
#'
#' @return An R6 instance of class `"Instance"`.
#'
#' @importFrom prettyunits pretty_bytes
#'
#' @export
Instance <- R6::R6Class(
  classname = "Instance",
  inherit = Resource,
  portable = FALSE,
  cloneable = FALSE,
  public = list(
    #' @description Retrieves bytes of DICOM file content
    #'
    #' This method retrieves bytes corresponding to the DICOM file.
    get_dicom_file_content = function() {
      private$client$get_instances_id_file(self$identifier)
    },

    #' @description Download DICOM file to a path.
    #' @param path Path on disk.
    #' @param stream Should the resource be streamed and written to disk in
    #'   chunks? Default is `FALSE`, which means the resource file contents are
    #'   retrieved in their entirety and written to disk all at once.
    download_dicom = function(path, stream = FALSE) {
      check_path_exists(path)

      path <- glue::glue("{path}/{self$uid}.dcm")

      route <- glue::glue("/instances/{self$identifier}/file")

      if (stream) {
        private$download_file_stream(
          method = "GET",
          route = route,
          file = path
        )
      } else {
        private$download_file_whole(
          content = self$get_dicom_file_content(),
          file = path
      )
      }
    },

    #' @description Get instance information.
    get_main_information = function() {
      private$client$get_instances_id(private$id)
    },

    #' @description Add label to resource.
    #' @param label Label.
    add_label = function(label) {
      check_scalar_character(label)
      private$client$put_instances_id_labels_label(self$identifier, label)
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
      private$client$delete_instances_id_labels_label(self$identifier, label)
    },

    #' @description Get raw content of one DICOM tag.
    #' @param tag tag.
    get_raw_content_by_tag = function(tag) {
      check_scalar_character(tag)
      private$client$get_instances_id_content_path(
        self$identifier,
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
      check_list(remove)
      check_list(replace)
      check_list(keep)
      check_scalar_logical(keep_private_tags)
      check_scalar_logical(keep_source)
      check_scalar_logical(force)

      data <- list(
        Remove = remove,
        Replace = replace,
        Keep = keep,
        Force = force,
        KeepPrivateTags = keep_private_tags,
        KeepSource = keep_source
      )

      if (!rlang::is_null(private_creator)) {
        check_scalar_character(private_creator)
        data["PrivateCreator"] <- private_creator
      }

      if (!rlang::is_null(dicom_version)) {
        check_scalar_character(dicom_version)
        data["DicomVersion"] <- dicom_version
      }

      private$client$post_instances_id_anonymize(private$id, data)
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

      check_list(remove)
      check_list(replace)
      check_list(keep)
      check_scalar_logical(remove_private_tags)
      check_scalar_logical(keep_source)
      check_scalar_logical(force)

      data <- list(
        Remove = remove,
        Replace = replace,
        Keep = keep,
        Force = force,
        RemovePrivateTags = remove_private_tags,
        KeepSource = keep_source
      )

      if (!rlang::is_null(private_creator)) {
        check_scalar_character(private_creator)
        data["PrivateCreator"] <- private_creator
      }

      private$client$post_instances_id_modify(self$identifier, data)
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
        route = glue::glue("/instances/{self$identifier}/nifti"),
        params = params
      )
    },

    #' @description Download instance as NIfTI.
    #' @param path Path on disk.
    #' @param compress Compress to gzip (nii.gz) Default is `TRUE`.
    #' @param stream Should the resource be streamed and written to disk in
    #'   chunks? Default is `FALSE`, which means the resource file contents are
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

      path <- fs::path_expand(path)

      params <- NULL

      if (compress) {
        file <- glue::glue("{path}/{self$uid}.nii.gz")
        params <- list(compress = "")
      } else {
        file <- glue::glue("{path}/{self$uid}.nii")
      }

      route <- glue::glue("/instances/{self$identifier}/nifti")

      if (stream) {
        private$download_file_stream(
          method = "GET",
          route = route,
          file = file,
        params = params
      )
} else {
        private$download_file_whole(
          self$get_nifti_file_content(compress),
          file
        )
      }
    },

    #' @description Download instance as an image.
    #' @param path Path on disk.
    #' @param frame Index of the frame (starts at `0L`). Default is `0L`.
    #' @param format One of `"png"` or `"jpeg"`. Default is `"png"`.
    #' @param render Should the image be scaled (with `RescaleSlope` and
    #'   `RescaleIntercept`) and windowed (with `WindowCenter`
    #'   and `WindowWidth`, if available). Default is `TRUE`.
    #' @param params Optional named-list of query parameters.
    #' @param ... Optional arguments passed on to `png::writePNG()` or
    #'   `jpeg::writeJPEG()`.
    download_image = function(
      path,
      frame = 0L,
      format = c("png", "jpeg"),
      render = TRUE,
      params = NULL,
      ...
    ) {
      check_path_exists(path)
      check_scalar_integer(frame)
      check_scalar_logical(render)
      format <- rlang::arg_match(format)

      if (format == "png") {
        rlang::check_installed("png")
        path <- glue::glue("{path}/{self$uid}.png")

        if (render) {
          png <- private$client$get_instances_id_frames_frame_rendered(
            id = self$identifier,
            frame = frame,
            params = params,
            headers = list(Accept = "image/png")
          )
        } else {
          png <- private$client$get_instances_id_frames_frame_preview(
            id = self$identifier,
            frame = frame,
            params = params,
            headers = list(Accept = "image/png")
          )
        }
        png::writePNG(image = png::readPNG(png), target = path, ...)
      }

      if (format == "jpeg") {
        rlang::check_installed("jpeg")
        path <- glue::glue("{path}/{self$uid}.jpeg")

        if (render) {
          jpeg <- private$client$get_instances_id_frames_frame_rendered(
            id = self$identifier,
            frame = frame,
            params = params,
            headers = list(Accept = "image/jpeg")
          )
        } else {
          jpeg <- private$client$get_instances_id_frames_frame_preview(
            id = self$identifier,
            frame = frame,
            params = params,
            headers = list(Accept = "image/jpeg")
          )
        }
        jpeg::writeJPEG(image = jpeg::readJPEG(jpeg), target = path, ...)
      }
      invisible()
    }
  ),
  private = list(
    resource_type = "Instance"
  ),
  active = list(
    #' @field uid SOPInstanceUID
    uid = function() {
      private$get_main_dicom_tag_value("SOPInstanceUID")
    },

    #' @field file_size File size
    file_size = function() {
      prettyunits::pretty_bytes(
        bytes = self$get_main_information()[["FileSize"]],
        style = "nopad"
      )
    },

    #' @field creation_date Creation Date
    creation_date = function() {
      parse_dicom_date(private$get_main_dicom_tag_value("InstanceCreationDate"))
    },

    #' @field series_identifier Parent series identifier
    series_identifier = function() {
      self$get_main_information()[["ParentSeries"]]
    },

    #' @field parent_series Parent series
    parent_series = function() {
      Series$new(self$series_identifier, private$client)
    },

    #' @field parent_study Parent study
    parent_study = function() {
      self$parent_series$parent_study
    },

    #' @field parent_patient Parent patient
    parent_patient = function() {
      self$parent_study$parent_patient
    },

    #' @field acquisition_number Acquisition Number
    acquisition_number = function() {
      as.integer(private$get_main_dicom_tag_value("AcquisitionNumber"))
    },

    #' @field image_index Image Index
    image_index = function() {
      as.integer(private$get_main_dicom_tag_value("ImageIndex"))
    },

    #' @field image_orientation_patient Image Orientation Patient
    image_orientation_patient = function() {
      parse_dicom_numeric_vecs(private$get_main_dicom_tag_value(
        "ImageOrientationPatient"
      ))
    },

    #' @field image_position_patient Image Position Patient
    image_position_patient = function() {
      parse_dicom_numeric_vecs(private$get_main_dicom_tag_value(
        "ImagePositionPatient"
      ))
    },

    #' @field image_comments Image Comments
    image_comments = function() {
      private$get_main_dicom_tag_value("ImageComments")
    },

    #' @field instance_number Instance Number
    instance_number = function() {
      private$get_main_dicom_tag_value("InstanceNumber")
    },

    #' @field number_of_frames Number of Frames
    number_of_frames = function() {
      private$get_main_dicom_tag_value("NumberOfFrames")
    },

    #' @field temporal_position_identifier Temporal Position Identifier
    temporal_position_identifier = function() {
      private$get_main_dicom_tag_value("TemporalPositionIdentifier")
    },

    #' @field tags Tags
    tags = function() {
      private$client$get_instances_id_tags(private$id)
    },

    #' @field simplified_tags Simplified Tags
    simplified_tags = function() {
      private$client$get_instances_id_tags(
        private$id,
        params = list(simplify = TRUE)
      )
    },

    #' @field labels Get or add labels
    labels = function(label) {
      if (rlang::is_missing(label)) {
        return(self$get_main_information()[["Labels"]])
      }
      self$add_label(label)
    },

    #' @field statistics Statistics
    statistics = function() {
      private$client$get_instances_id_statistics(self$identifier)
    }
  )
)
