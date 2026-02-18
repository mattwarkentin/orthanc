# Finds patients in Orthanc according to queries and labels

Finds patients in Orthanc according to queries and labels

## Usage

``` r
find_patients(
  client,
  query = list(),
  labels = character(),
  labels_constraint = "All",
  ...
)
```

## Arguments

- client:

  Orthanc API client.

- query:

  Named-list that specifies the filters on the level related DICOM tags.

- labels:

  Character vector of labels to look for in resources.

- labels_constraint:

  Contraint on the labels ('All', 'Any', 'None').

- ...:

  Additional arguments passed to `query_orthanc`.

## Value

A `list` of
[Patient](https://mattwarkentin.github.io/orthanc/reference/Patient.md)
objects.

## Examples

``` r
client <- Orthanc$new("https://orthanc.uclouvain.be/demo")

find_patients(client, query = list(PatientName = "HN_P001"))
#> [[1]]
#> <Patient: 65ce8003-696b2eb6-03adeee7-6561ce8e-3e03f13a>
```
