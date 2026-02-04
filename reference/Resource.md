# DICOM Resource Class

An abstract class for a DICOM Resource in the Orthanc API Client.

## Value

An R6 instance of class `"Resource"`.

## Active bindings

- `identifier`:

  Orthanc identifier of the resource.

- `main_dicom_tags`:

  Main DICOM tags for the resource.

## Methods

### Public methods

- [`Resource$new()`](#method-Resource-new)

- [`Resource$get_main_information()`](#method-Resource-get_main_information)

- [`Resource$print()`](#method-Resource-print)

------------------------------------------------------------------------

### Method `new()`

Create a new Resource.

#### Usage

    Resource$new(id, client)

#### Arguments

- `id`:

  Orthanc identifier of the resource.

- `client`:

  `Orthanc` client.

------------------------------------------------------------------------

### Method `get_main_information()`

Get main information for the resource.

#### Usage

    Resource$get_main_information()

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a `Resource` object.

#### Usage

    Resource$print(...)

#### Arguments

- `...`:

  Not currently used.
