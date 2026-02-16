# Retrieve and write patients to a given path

Retrieve and write patients to a given path

## Usage

``` r
retrieve_and_write_patients(patients, path, progress = FALSE)
```

## Arguments

- patients:

  List of
  [Patient](https://mattwarkentin.github.io/orthanc/reference/Patient.md)s

- path:

  Path where you want to write the patients (files).

- progress:

  Whether to show a progress bar. Use `TRUE` to turn on a basic progress
  bar, use a string to give it a name, or see
  [progress_bars](https://purrr.tidyverse.org/reference/progress_bars.html)
  for more details.

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
