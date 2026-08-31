# DICOM Series Class

An abstract class for a DICOM Series resource.

## Value

An R6 instance of class `"Series"`.

## Super class

[`Resource`](https://mattwarkentin.github.io/orthanc/reference/Resource.md)
-\> `Series`

## Active bindings

- `instances`:

  Instances

- `instances_ids`:

  Instances identifiers

- `num_instances`:

  Number of instances

- `instances_tags`:

  Instances tags

- `uid`:

  SeriesInstanceUID

- `manufacturer`:

  Manufacturer

- `date`:

  Series Date

- `modality`:

  Modality

- `series_number`:

  Series Number

- `performed_procedure_step_description`:

  Performed Procedure Step Description

- `protocol_name`:

  Protocol Name

- `station_name`:

  Station Name

- `description`:

  Series Description

- `body_part_examined`:

  Body Part Examined

- `sequence_name`:

  Sequence Name

- `cardiac_number_of_images`:

  Cardiac Number of Images

- `image_in_acquisition`:

  Images in Acquisition

- `number_of_temporal_positions`:

  Number of Temporal Positions

- `number_of_slices`:

  Number of Slices

- `number_of_time_slices`:

  Number of Time Slices

- `image_orientation_patient`:

  Image Orientation Patient

- `series_type`:

  Series Type

- `operators_name`:

  Operators Name

- `acquisition_device_processing_description`:

  Acquisition Device Processing Description

- `contrast_bolus_agent`:

  Contrast Bolus Agent

- `is_stable`:

  Is stable?

- `last_update`:

  Last Update

- `labels`:

  Get or add labels

- `study_identifier`:

  Parent study identifier

- `parent_study`:

  Parent study

- `parent_patient`:

  Parent patient

- `shared_tags`:

  Shared tags

- `statistics`:

  Statistics

## Methods

### Public methods

- [`Series$get_main_information()`](#method-Series-get_main_information)

- [`Series$add_label()`](#method-Series-add_label)

- [`Series$has_label()`](#method-Series-has_label)

- [`Series$remove_label()`](#method-Series-remove_label)

- [`Series$anonymize()`](#method-Series-anonymize)

- [`Series$anonymize_as_job()`](#method-Series-anonymize_as_job)

- [`Series$modify()`](#method-Series-modify)

- [`Series$modify_as_job()`](#method-Series-modify_as_job)

- [`Series$get_zip_archive_content()`](#method-Series-get_zip_archive_content)

- [`Series$download_archive()`](#method-Series-download_archive)

- [`Series$get_shared_tags()`](#method-Series-get_shared_tags)

- [`Series$remove_empty_instances()`](#method-Series-remove_empty_instances)

- [`Series$get_nifti_file_content()`](#method-Series-get_nifti_file_content)

- [`Series$download_nifti()`](#method-Series-download_nifti)

- [`Series$clone()`](#method-Series-clone)

Inherited methods

- [`Resource$initialize()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-initialize)
- [`Resource$print()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-print)
- [`Resource$set_child_resources()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-set_child_resources)

------------------------------------------------------------------------

### `Series$get_main_information()`

Get series information.

#### Usage

    Series$get_main_information()

------------------------------------------------------------------------

### `Series$add_label()`

Add label to resource.

#### Usage

    Series$add_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### `Series$has_label()`

Test if resource has label.

#### Usage

    Series$has_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### `Series$remove_label()`

Delete label from resource.

#### Usage

    Series$remove_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### `Series$anonymize()`

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

### `Series$anonymize_as_job()`

Anonymize Series

#### Usage

    Series$anonymize_as_job(
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

### `Series$modify()`

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

### `Series$modify_as_job()`

Modify Series

#### Usage

    Series$modify_as_job(
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

### `Series$get_zip_archive_content()`

Get bytes of the zip archive.

#### Usage

    Series$get_zip_archive_content()

------------------------------------------------------------------------

### `Series$download_archive()`

Download zip archive to `path`.

#### Usage

    Series$download_archive(path, stream = FALSE)

#### Arguments

- `path`:

  Path on disk.

- `stream`:

  Should the resource be streamed and written to disk in chunks? Default
  is `FALSE`, which means the resource file contents are retrieved in
  their entirety and written to disk all at once.

------------------------------------------------------------------------

### `Series$get_shared_tags()`

Retrieve the shared tags of the series.

#### Usage

    Series$get_shared_tags()

------------------------------------------------------------------------

### `Series$remove_empty_instances()`

Remove empty instances from series.

#### Usage

    Series$remove_empty_instances()

------------------------------------------------------------------------

### `Series$get_nifti_file_content()`

Get bytes of NIfTI file content.

#### Usage

    Series$get_nifti_file_content(compress = TRUE)

#### Arguments

- `compress`:

  Compress to gzip (nii.gz) Default is `TRUE`.

------------------------------------------------------------------------

### `Series$download_nifti()`

Download series as NIfTI.

#### Usage

    Series$download_nifti(path, compress = TRUE, stream = FALSE)

#### Arguments

- `path`:

  Path on disk.

- `compress`:

  Compress to gzip (`nii.gz`) Default is `TRUE`.

- `stream`:

  Should the resource be streamed and written to disk in chunks? Default
  is `FALSE`, which means the resource contents are retrieved in their
  entirety and written to disk all at once.

------------------------------------------------------------------------

### `Series$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Series$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
