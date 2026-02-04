# DICOM Study Class

An abstract class for a DICOM Study resource.

## Value

An R6 instance of class `"Study"`.

## Super class

[`orthanc::Resource`](https://mattwarkentin.github.io/orthanc/reference/Resource.md)
-\> `Study`

## Active bindings

- `patient_identifier`:

  Get parent patient identifier.

- `parent_patient`:

  Get parent patient

- `referring_physician_name`:

  Referring Physician Name

- `requesting_physician`:

  Requesting Physician

- `date`:

  Study Date

- `study_id`:

  Study ID

- `uid`:

  StudyInstanceUID

- `patient_information`:

  Patient Main DICOM Tags

- `series`:

  Get patient's series

- `accession_number`:

  Accession Number

- `description`:

  Description

- `institution_name`:

  Institution Name

- `requested_procedure_description`:

  Requested procedure description.

- `is_stable`:

  Is stable?

- `last_update`:

  Last update.

- `labels`:

  Labels.

- `shared_tags`:

  Shared tags.

## Methods

### Public methods

- [`Study$get_main_information()`](#method-Study-get_main_information)

- [`Study$add_label()`](#method-Study-add_label)

- [`Study$remove_label()`](#method-Study-remove_label)

- [`Study$anonymize()`](#method-Study-anonymize)

- [`Study$anonymize_as_job()`](#method-Study-anonymize_as_job)

- [`Study$modify()`](#method-Study-modify)

- [`Study$modify_as_job()`](#method-Study-modify_as_job)

- [`Study$get_zip()`](#method-Study-get_zip)

- [`Study$download()`](#method-Study-download)

- [`Study$get_shared_tags()`](#method-Study-get_shared_tags)

Inherited methods

- [`orthanc::Resource$initialize()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-initialize)
- [`orthanc::Resource$print()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-print)

------------------------------------------------------------------------

### Method `get_main_information()`

Get study information.

#### Usage

    Study$get_main_information()

------------------------------------------------------------------------

### Method `add_label()`

Add label to resource.

#### Usage

    Study$add_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### Method `remove_label()`

Delete label from resource.

#### Usage

    Study$remove_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### Method `anonymize()`

Anonymize Study

#### Usage

    Study$anonymize(
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

### Method `anonymize_as_job()`

Anonymize Study

#### Usage

    Study$anonymize_as_job(
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

Modify Study

#### Usage

    Study$modify(
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

### Method `modify_as_job()`

Modify Study as Job

#### Usage

    Study$modify_as_job(
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

    Study$get_zip()

------------------------------------------------------------------------

### Method `download()`

Download the zip file to a path.

#### Usage

    Study$download(file)

#### Arguments

- `file`:

  File path on disk.

------------------------------------------------------------------------

### Method `get_shared_tags()`

Retrieve the shared tags of the study.

#### Usage

    Study$get_shared_tags()
