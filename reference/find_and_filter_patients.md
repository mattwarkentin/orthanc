# Find and filter patients using predicate functions

Find desired Patient/Study/Series/Instance in an Orthanc server.
Predicate functions (filters) take a single
Patient/Study/Series/Instance as the first argument and return a single
`TRUE` or `FALSE` for whether the resource should be kept or discarded,
respectively. If
[`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html) has
been used to set persistent background processes, this function will
apply filters in parallel (over patients) using all available processes.

## Usage

``` r
find_and_filter_patients(
  client,
  patient_filter = NULL,
  study_filter = NULL,
  series_filter = NULL,
  instance_filter = NULL,
  progress = rlang::is_interactive()
)
```

## Arguments

- client:

  Orthanc client.

- patient_filter:

  Predicate function to filter
  [Patient](https://mattwarkentin.github.io/orthanc/reference/Patient.md)s.

- study_filter:

  Predicate function to filter
  [Study](https://mattwarkentin.github.io/orthanc/reference/Study.md)s.

- series_filter:

  Predicate function to filer
  [Series](https://mattwarkentin.github.io/orthanc/reference/Series.md).

- instance_filter:

  Predicate function to filter
  [Instance](https://mattwarkentin.github.io/orthanc/reference/Instance.md)s.

- progress:

  Whether to show progress bars. By default, progress bars are enabled
  in interactive sessions (i.e., if
  [`rlang::is_interactive()`](https://rlang.r-lib.org/reference/is_interactive.html)
  returns `TRUE`).

## Value

A `list` of filtered
[Patient](https://mattwarkentin.github.io/orthanc/reference/Patient.md)s.

## Details

This function builds a series of tree structures. Each tree corresponds
to a patient. The layers in the tree correspond to:

`Patient -> Studies -> Series -> Instances`

## Examples

``` r
client <- Orthanc$new("https://orthanc.uclouvain.be/demo")

find_and_filter_patients(
  client = client,
  patient_filter = \(pt) pt$is_stable
)
#> Error in httr2::req_perform(req): Failed to perform HTTP request.
#> Caused by error in `curl::curl_fetch_memory()`:
#> ! Timeout was reached [orthanc.uclouvain.be]:
#> Failed to connect to orthanc.uclouvain.be port 443 after 10002 ms: Timeout was reached
```
