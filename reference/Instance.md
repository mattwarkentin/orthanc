# DICOM Instance Class

An abstract class for a DICOM Instance resource.

## Value

An R6 instance of class `"Instance"`.

## Super class

[`orthanc::Resource`](https://mattwarkentin.github.io/orthanc/reference/Resource.md)
-\> `Instance`

## Active bindings

- `uid`:

  Get the `SOPInstanceUID`.

- `file_size`:

  Get the file size.

- `creation_date`:

  Get creation date.

- `series_identifier`:

  Get parent series identifier.

- `parent_series`:

  Get parent series.

- `parent_study`:

  Get parent study

- `parent_patient`:

  Get parent patient

- `acquisition_number`:

  Acquisition number.

- `image_index`:

  Image index.

- `image_orientation_patient`:

  Image orientation patient.

- `image_position_patient`:

  Image position patient.

- `image_comments`:

  Image comments.

- `instance_number`:

  Instance number.

- `number_of_frames`:

  Number of frames.

- `temporal_position_identifier`:

  Temporal position identifier.

- `tags`:

  Get tags.

- `simplified_tags`:

  Get simplified tags.

- `labels`:

  Get instance labels.

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

Inherited methods

- [`orthanc::Resource$initialize()`](https://mattwarkentin.github.io/orthanc/html/Resource.html#method-Resource-initialize)
- [`orthanc::Resource$print()`](https://mattwarkentin.github.io/orthanc/html/Resource.html#method-Resource-print)

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
