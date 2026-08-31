# DICOM Patient Class

An abstract class for a DICOM Patient resource.

## Value

An R6 instance of class `"Patient"`.

## Super class

[`Resource`](https://mattwarkentin.github.io/orthanc/reference/Resource.md)
-\> `Patient`

## Active bindings

- `patient_id`:

  Patient ID

- `name`:

  Patient Name

- `birth_date`:

  Patient Birth Date

- `sex`:

  Patient Sex

- `other_patient_ids`:

  Other Patient IDs

- `is_stable`:

  Is stable?

- `last_update`:

  Last Update

- `labels`:

  Get or add labels

- `protected`:

  Get or set if patient is protected against recycling

- `studies`:

  Studies

- `studies_ids`:

  Studies identifiers

- `series`:

  Series

- `series_ids`:

  Series identifiers

- `instances`:

  Instances

- `instances_ids`:

  Instances identifiers

- `instances_tags`:

  Instances tags

- `num_studies`:

  Number of studies

- `num_series`:

  Number of series

- `num_instances`:

  Number of instances

- `shared_tags`:

  Shared tags

- `statistics`:

  Statistics

## Methods

### Public methods

- [`Patient$get_main_information()`](#method-Patient-get_main_information)

- [`Patient$add_label()`](#method-Patient-add_label)

- [`Patient$has_label()`](#method-Patient-has_label)

- [`Patient$remove_label()`](#method-Patient-remove_label)

- [`Patient$get_zip_archive_content()`](#method-Patient-get_zip_archive_content)

- [`Patient$download_archive()`](#method-Patient-download_archive)

- [`Patient$get_patient_module()`](#method-Patient-get_patient_module)

- [`Patient$anonymize()`](#method-Patient-anonymize)

- [`Patient$anonymize_as_job()`](#method-Patient-anonymize_as_job)

- [`Patient$modify()`](#method-Patient-modify)

- [`Patient$modify_as_job()`](#method-Patient-modify_as_job)

- [`Patient$get_shared_tags()`](#method-Patient-get_shared_tags)

- [`Patient$remove_empty_studies()`](#method-Patient-remove_empty_studies)

- [`Patient$clone()`](#method-Patient-clone)

Inherited methods

- [`Resource$initialize()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-initialize)
- [`Resource$print()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-print)
- [`Resource$set_child_resources()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-set_child_resources)

------------------------------------------------------------------------

### `Patient$get_main_information()`

Get patient information.

#### Usage

    Patient$get_main_information()

------------------------------------------------------------------------

### `Patient$add_label()`

Add label to resource.

#### Usage

    Patient$add_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### `Patient$has_label()`

Test if resource has label.

#### Usage

    Patient$has_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### `Patient$remove_label()`

Delete label from resource.

#### Usage

    Patient$remove_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### `Patient$get_zip_archive_content()`

Get bytes of the zip archive.

#### Usage

    Patient$get_zip_archive_content()

------------------------------------------------------------------------

### `Patient$download_archive()`

Download zip archive to `path`.

#### Usage

    Patient$download_archive(path, stream = FALSE)

#### Arguments

- `path`:

  Path on disk.

- `stream`:

  Should the resource be streamed and written to disk in chunks? Default
  is `FALSE`, which means the resource file contents are retrieved in
  their entirety and written to disk all at once.

------------------------------------------------------------------------

### `Patient$get_patient_module()`

Get patient module in a simplified version

#### Usage

    Patient$get_patient_module()

------------------------------------------------------------------------

### `Patient$anonymize()`

Anonymize Patient

#### Usage

    Patient$anonymize(
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

### `Patient$anonymize_as_job()`

Anonymize Patient

#### Usage

    Patient$anonymize_as_job(
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

### `Patient$modify()`

Modify Patient

#### Usage

    Patient$modify(
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

### `Patient$modify_as_job()`

Modify Patient

#### Usage

    Patient$modify_as_job(
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

### `Patient$get_shared_tags()`

Retrieve the shared tags of the patient.

#### Usage

    Patient$get_shared_tags()

------------------------------------------------------------------------

### `Patient$remove_empty_studies()`

Remove empty studies from patient.

#### Usage

    Patient$remove_empty_studies()

------------------------------------------------------------------------

### `Patient$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Patient$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
