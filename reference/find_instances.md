# Finds instances in Orthanc according to queries and labels

Finds instances in Orthanc according to queries and labels

## Usage

``` r
find_instances(
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

  Not currently used.

## Value

A `list` of
[Instance](https://mattwarkentin.github.io/orthanc/reference/Instance.md)s.
