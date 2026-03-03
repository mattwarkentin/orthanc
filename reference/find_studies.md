# Finds studies in Orthanc according to queries and labels

Finds studies in Orthanc according to queries and labels

## Usage

``` r
find_studies(
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
[Study](https://mattwarkentin.github.io/orthanc/reference/Study.md)
objects.

## Examples

``` r
client <- Orthanc$new("https://orthanc.uclouvain.be/demo")
find_studies(client, query = list(StudyDescription = "RT^HEAD_NECK (Adult)"))
#> [[1]]
#> <Study: 1c379a23-9fd28bba-02b60e5b-850ff34e-4349f09b>
```
