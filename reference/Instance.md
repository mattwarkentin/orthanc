# DICOM Instance Class

An abstract class for a DICOM Instance resource.

## Value

An R6 instance of class `"Instance"`.

## Super class

[`orthanc::Resource`](https://mattwarkentin.github.io/orthanc/reference/Resource.md)
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

- `number_of_frames`:

  Number of Frames

- `temporal_position_identifier`:

  Temporal Position Identifier

- `tags`:

  Tags

- `simplified_tags`:

  Simplified Tags

- `labels`:

  Labels

- `statistics`:

  Statistics

## Methods

### Public methods

- [`Instance$get_dicom_file_content()`](#method-Instance-get_dicom_file_content)

- [`Instance$download()`](#method-Instance-download)

- [`Instance$get_main_information()`](#method-Instance-get_main_information)

- [`Instance$add_label()`](#method-Instance-add_label)

- [`Instance$remove_label()`](#method-Instance-remove_label)

- [`Instance$get_content_by_tag()`](#method-Instance-get_content_by_tag)

- [`Instance$anonymize()`](#method-Instance-anonymize)

- [`Instance$modify()`](#method-Instance-modify)

- [`Instance$download_nifti()`](#method-Instance-download_nifti)

Inherited methods

- [`orthanc::Resource$initialize()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-initialize)
- [`orthanc::Resource$print()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-print)
- [`orthanc::Resource$set_child_resources()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-set_child_resources)

------------------------------------------------------------------------

### Method `get_dicom_file_content()`

Retrieves DICOM file

This method retrieves bytes corresponding to DICOM file.

#### Usage

    Instance$get_dicom_file_content()

------------------------------------------------------------------------

### Method `download()`

Download DICOM file to a path.

#### Usage

    Instance$download(file)

#### Arguments

- `file`:

  File path on disk.

------------------------------------------------------------------------

### Method `get_main_information()`

Get instance information.

#### Usage

    Instance$get_main_information()

------------------------------------------------------------------------

### Method `add_label()`

Add label to resource.

#### Usage

    Instance$add_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### Method `remove_label()`

Delete label from resource.

#### Usage

    Instance$remove_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### Method `get_content_by_tag()`

Get content by tag.

#### Usage

    Instance$get_content_by_tag(tag)

#### Arguments

- `tag`:

  tag.

------------------------------------------------------------------------

### Method `anonymize()`

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

### Method `modify()`

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

### Method `download_nifti()`

Download instance as NIfTI.

#### Usage

    Instance$download_nifti(path, compress = FALSE)

#### Arguments

- `path`:

  Path on disk.

- `compress`:

  Compress to gzip.
