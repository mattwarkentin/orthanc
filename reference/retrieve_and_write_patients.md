# Retrieve and write patients to a path

Retrieve the DICOM file contents for a list of
[Patient](https://mattwarkentin.github.io/orthanc/reference/Patient.md)s
and write them to a `path` on disk. DICOM files are saved to disk in a
directory structure of `Patient -> Study -> Series -> File`. If
[`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html) has
been used to set persistent background processes, this function will
write patients to disk in parallel using all available processes.

## Usage

``` r
retrieve_and_write_patients(patients, path, progress = rlang::is_interactive())
```

## Arguments

- patients:

  List of
  [Patient](https://mattwarkentin.github.io/orthanc/reference/Patient.md)s

- path:

  Path where you want to write the patients (files).

- progress:

  Whether to show progress bars. By default, progress bars are enabled
  in interactive sessions (i.e., if
  [`rlang::is_interactive()`](https://rlang.r-lib.org/reference/is_interactive.html)
  returns `TRUE`).

## Value

Nothing, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
client <- Orthanc$new("https://orthanc.uclouvain.be/demo")

patients <- find_patients(client, query = list(PatientName = "HN_P001"))

retrieve_and_write_patients(patients, tempdir())
} # }
```
