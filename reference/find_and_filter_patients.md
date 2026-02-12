# Find and filter patients

Find desired Patients/Study/Series/Instance in an Orthanc server

## Usage

``` r
find_and_filter_patients(
  client,
  patient_filter = NULL,
  study_filter = NULL,
  series_filter = NULL,
  instance_filter = NULL
)
```

## Arguments

- client:

  Orthanc client.

- patient_filter:

  Predicate function to filter Patients.

- study_filter:

  Predicate function to filter Studies.

- series_filter:

  Predicate function to filer Series.

- instance_filter:

  Predicate function to filter Instances.

## Value

A `list` of
[Patient](https://mattwarkentin.github.io/orthanc/reference/Patient.md)s.

## Details

This function builds a series of tree structure. Each tree correspond to
a patient. The layers in the tree correspond to:

`Patient -> Studies -> Series -> Instances`
