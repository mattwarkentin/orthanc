# DICOM Patient Class

An abstract class for a DICOM Patient resource.

## Value

An R6 instance of class `"Patient"`.

## Super class

[`orthanc::Resource`](https://mattwarkentin.github.io/orthanc/reference/Resource.md)
-\> `Patient`

## Active bindings

- `patient_id`:

  Patient ID.

- `name`:

  Patient Name.

- `birth_date`:

  Patient Birth Date.

- `sex`:

  Patient Sex.

- `other_patient_ids`:

  Other Patient IDs.

- `is_stable`:

  Is stable?

- `last_update`:

  Last update.

- `labels`:

  Labels.

- `protected`:

  Get or Set if patient is protected against recycling.

- `studies`:

  Get patient's studies.

- `shared_tags`:

  Shared tags.

## Methods

### Public methods

- [`Patient$get_main_information()`](#method-Patient-get_main_information)

- [`Patient$add_label()`](#method-Patient-add_label)

- [`Patient$remove_label()`](#method-Patient-remove_label)

- [`Patient$get_zip()`](#method-Patient-get_zip)

- [`Patient$download()`](#method-Patient-download)

- [`Patient$get_patient_module()`](#method-Patient-get_patient_module)

- [`Patient$anonymize()`](#method-Patient-anonymize)

- [`Patient$anonymize_as_job()`](#method-Patient-anonymize_as_job)

- [`Patient$modify()`](#method-Patient-modify)

- [`Patient$modify_as_job()`](#method-Patient-modify_as_job)

- [`Patient$get_shared_tags()`](#method-Patient-get_shared_tags)

Inherited methods

- [`orthanc::Resource$initialize()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-initialize)
- [`orthanc::Resource$print()`](https://mattwarkentin.github.io/orthanc/reference/Resource.html#method-print)

------------------------------------------------------------------------

### Method `get_main_information()`

Get patient information.

#### Usage

    Patient$get_main_information()

------------------------------------------------------------------------

### Method `add_label()`

Add label to resource.

#### Usage

    Patient$add_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### Method `remove_label()`

Delete label from resource.

#### Usage

    Patient$remove_label(label)

#### Arguments

- `label`:

  Label.

------------------------------------------------------------------------

### Method `get_zip()`

Get the bytes of the zip file.

#### Usage

    Patient$get_zip()

------------------------------------------------------------------------

### Method `download()`

Download the zip file to a path.

#### Usage

    Patient$download(file)

#### Arguments

- `file`:

  File path on disk.

------------------------------------------------------------------------

### Method `get_patient_module()`

Get patient module in a simplified version

#### Usage

    Patient$get_patient_module()

------------------------------------------------------------------------

### Method `anonymize()`

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

### Method `anonymize_as_job()`

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

### Method `modify()`

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

### Method `modify_as_job()`

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

### Method `get_shared_tags()`

Retrieve the shared tags of the patient.

#### Usage

    Patient$get_shared_tags()
