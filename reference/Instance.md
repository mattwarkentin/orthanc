# DICOM Instance Class

An abstract class for a DICOM Instance resource.

## Value

An R6 instance of class `"Instance"`.

## Super class

[`Resource`](https://mattwarkentin.github.io/orthanc/reference/Resource.md)
-\> `Instance`

## Active bindings

- `uid`:

  SOPInstanceUID

- `file_size`:

  File size

- `creation_date`:

  Creation Date

- `series_identifier`:

  Parent series identifier

- `parent_series`:

  Parent series

- `parent_study`:

  Parent study

- `parent_patient`:

  Parent patient

- `acquisition_number`:

  Acquisition Number

- `image_index`:

  Image Index

- `image_orientation_patient`:

  Image Orientation Patient

- `image_position_patient`:

  Image Position Patient

- `image_comments`:

  Image Comments

- `instance_number`:

  Instance Number

- `temporal_position_identifier`:

  Temporal Position Identifier

- `tags`:

  Tags

- `simplified_tags`:

  Simplified Tags

- `labels`:

  Get or add labels

- `statistics`:

  Statistics

- `list_frames`:

  List frames (zero-based indexing)

- `frames`:

  Number of frames

- `rows`:

  Number of rows

- `columns`:

  Number of columns

- `shape`:

  Shape (rows x columns x frames (if multi-frame))

- `dim`:

  Number of dimensions

- `slice_thickness`:

  Slice thickness

- `pixel_spacing`:

  Pixel spacing

## Methods

### Public methods

- [`Instance$get_dicom_file_content()`](#method-Instance-get_dicom_file_content)

- [`Instance$download_dicom()`](#method-Instance-download_dicom)

- [`Instance$get_main_information()`](#method-Instance-get_main_information)

- [`Instance$add_label()`](#method-Instance-add_label)

- [`Instance$has_label()`](#method-Instance-has_label)

- [`Instance$remove_label()`](#method-Instance-remove_label)

- [`Instance$get_raw_content_by_tag()`](#method-Instance-get_raw_content_by_tag)

- [`Instance$anonymize()`](#method-Instance-anonymize)

- [`Instance$modify()`](#method-Instance-modify)

- [`Instance$get_nifti_file_content()`](#method-Instance-get_nifti_file_content)

- [`Instance$download_nifti()`](#method-Instance-download_nifti)

- [`Instance$download_image()`](#method-Instance-download_image)

- [`Instance$clone()`](#method-Instance-clone)

Inherited methods

- [`Resource$initialize()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-initialize)
- [`Resource$print()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-print)
- [`Resource$set_child_resources()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-set_child_resources)

------------------------------------------------------------------------

### `Instance$get_dicom_file_content()`

Retrieves bytes of DICOM file content

This method retrieves bytes corresponding to the DICOM file.

#### Usage

    Instance$get_dicom_file_content()

------------------------------------------------------------------------

### `Instance$download_dicom()`

Download DICOM file to a path.

#### Usage

    Instance$download_dicom(path, stream = FALSE)

#### Arguments

- `path`:

  Path on disk.

- `stream`:

  Should the resource be streamed and written to disk in chunks? Default
  is `FALSE`, which means the resource file contents are retrieved in
  their entirety and written to disk all at once.

------------------------------------------------------------------------

### `Instance$get_main_information()`

Get instance information.

#### Usage

    Instance$get_main_information()

------------------------------------------------------------------------

### `Instance$add_label()`

Add label to resource.

#### Usage

    Instance$add_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### `Instance$has_label()`

Test if resource has label.

#### Usage

    Instance$has_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### `Instance$remove_label()`

Delete label from resource.

#### Usage

    Instance$remove_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### `Instance$get_raw_content_by_tag()`

Get raw content of one DICOM tag.

#### Usage

    Instance$get_raw_content_by_tag(tag)

#### Arguments

- `tag`:

  tag.

------------------------------------------------------------------------

### `Instance$anonymize()`

Anonymize Instance

#### Usage

    Instance$anonymize(
      remove = list(),
      replace = list(),
      keep = list(),
      keep_private_tags = FALSE,
      keep_source = TRUE,
      private_creator = NULL,
      force = FALSE,
      dicom_version = NULL
    )

#### Arguments

- `remove`:

  List of tags to remove.

- `replace`:

  Named-list of tags to replce.

- `keep`:

  List of tags to keep unchanged.

- `keep_private_tags`:

  Keep private tags from DICOM instance.

- `keep_source`:

  Keep original resource.

- `private_creator`:

  Private creator to be used for private tags in replace.

- `force`:

  Force tags to be changed.

- `dicom_version`:

  Version of the DICOM standard to use for anonymization.

------------------------------------------------------------------------

### `Instance$modify()`

Modify an Instance

#### Usage

    Instance$modify(
      remove = list(),
      replace = list(),
      keep = list(),
      remove_private_tags = FALSE,
      keep_source = TRUE,
      private_creator = NULL,
      force = FALSE
    )

#### Arguments

- `remove`:

  List of tags to remove.

- `replace`:

  Named-list of tags to replce.

- `keep`:

  List of tags to keep unchanged.

- `remove_private_tags`:

  Remove private tags from DICOM instance.

- `keep_source`:

  Keep original resource.

- `private_creator`:

  Private creator to be used for private tags in replace.

- `force`:

  Force tags to be changed.

------------------------------------------------------------------------

### `Instance$get_nifti_file_content()`

Get bytes of NIfTI file content.

#### Usage

    Instance$get_nifti_file_content(compress = TRUE)

#### Arguments

- `compress`:

  Compress to gzip (nii.gz) Default is `TRUE`.

------------------------------------------------------------------------

### `Instance$download_nifti()`

Download instance as NIfTI.

#### Usage

    Instance$download_nifti(path, compress = TRUE, stream = FALSE)

#### Arguments

- `path`:

  Path on disk.

- `compress`:

  Compress to gzip (nii.gz) Default is `TRUE`.

- `stream`:

  Should the resource be streamed and written to disk in chunks? Default
  is `FALSE`, which means the resource file contents are retrieved in
  their entirety and written to disk all at once.

------------------------------------------------------------------------

### `Instance$download_image()`

Download instance as an image.

#### Usage

    Instance$download_image(
      path,
      frame = 0L,
      format = c("png", "jpeg"),
      render = TRUE,
      params = NULL,
      ...
    )

#### Arguments

- `path`:

  Path on disk.

- `frame`:

  Index of the frame (starts at `0L`). Default is `0L`.

- `format`:

  One of `"png"` or `"jpeg"`. Default is `"png"`.

- `render`:

  Should the image be scaled (with `RescaleSlope` and
  `RescaleIntercept`) and windowed (with `WindowCenter` and
  `WindowWidth`, if available). Default is `TRUE`.

- `params`:

  Optional named-list of query parameters.

- `...`:

  Optional arguments passed on to
  [`png::writePNG()`](https://rdrr.io/pkg/png/man/writePNG.html) or
  [`jpeg::writeJPEG()`](https://rdrr.io/pkg/jpeg/man/writeJPEG.html).

------------------------------------------------------------------------

### `Instance$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Instance$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
