# DICOM Series Class

An abstract class for a DICOM Series resource.

## Value

An R6 instance of class `"Series"`.

## Super class

[`orthanc::Resource`](https://mattwarkentin.github.io/orthanc/reference/Resource.md)
-\> `Series`

## Active bindings

- `instances`:

  Get series instances.

- `uid`:

  Get SeriesInstanceUID.

- `manufacturer`:

  Manufacturer.

- `date`:

  Date.

- `modality`:

  Modality.

- `series_number`:

  Series number.

- `performed_procedure_step_description`:

  Performed procedure step description.

- `protocol_name`:

  Protocol name.

- `station_name`:

  Station name.

- `description`:

  Description.

- `body_part_examined`:

  Body part examined.

- `sequence_name`:

  Sequence name.

- `cardiac_number_of_images`:

  Cardiac number of images.

- `image_in_acquisition`:

  Images in acquisition.

- `number_of_temporal_positions`:

  Number of temporal positions.

- `number_of_slices`:

  Number of slices.

- `number_of_time_slices`:

  Number of time slices.

- `image_orientation_patient`:

  Image orientation patient.

- `series_type`:

  Series type.

- `operators_name`:

  Operators name.

- `acquisition_device_processing_description`:

  Acquisition device processing description.

- `contrast_bolus_agent`:

  Contrast bolus agent.

- `is_stable`:

  Is stable?

- `last_update`:

  Last update.

- `labels`:

  Labels.

- `study_identifier`:

  Get parent study identifier.

- `parent_study`:

  Get parent study.

- `parent_patient`:

  Get parent patient.

- `shared_tags`:

  Shared tags.

## Methods

### Public methods

- [`Series$get_main_information()`](#method-Series-get_main_information)

- [`Series$add_label()`](#method-Series-add_label)

- [`Series$remove_label()`](#method-Series-remove_label)

- [`Series$anonymize()`](#method-Series-anonymize)

- [`Series$modify()`](#method-Series-modify)

- [`Series$get_zip()`](#method-Series-get_zip)

- [`Series$download()`](#method-Series-download)

- [`Series$get_shared_tags()`](#method-Series-get_shared_tags)

Inherited methods

- [`orthanc::Resource$initialize()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-initialize)
- [`orthanc::Resource$print()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-print)

------------------------------------------------------------------------

### Method `get_main_information()`

Get series information.

#### Usage

    Series$get_main_information()

------------------------------------------------------------------------

### Method `add_label()`

Add label to resource.

#### Usage

    Series$add_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### Method `remove_label()`

Delete label from resource.

#### Usage

    Series$remove_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### Method `anonymize()`

Anonymize Series

#### Usage

    Series$anonymize(
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

- `priority`:

  Priority of the job.

- `permissive`:

  Ignore errors during individual steps of the job?

- `private_creator`:

  Private creator to be used for private tags in replace.

- `force`:

  Force tags to be changed.

- `dicom_version`:

  Version of the DICOM standard to use for anonymization.

------------------------------------------------------------------------

### Method `modify()`

Modify Series

#### Usage

    Series$modify(
      remove = list(),
      replace = list(),
      keep = list(),
      remove_private_tags = FALSE,
      keep_source = TRUE,
      priority = 0L,
      permissive = FALSE,
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

- `priority`:

  Priority of the job.

- `permissive`:

  Ignore errors during individual steps of the job?

- `private_creator`:

  Private creator to be used for private tags in replace.

- `force`:

  Force tags to be changed.

------------------------------------------------------------------------

### Method `get_zip()`

Get the bytes of the zip file.

#### Usage

    Series$get_zip()

------------------------------------------------------------------------

### Method `download()`

Download the zip file to a path.

#### Usage

    Series$download(file)

#### Arguments

- `file`:

  File path on disk.

------------------------------------------------------------------------

### Method `get_shared_tags()`

Retrieve the shared tags of the series.

#### Usage

    Series$get_shared_tags()
