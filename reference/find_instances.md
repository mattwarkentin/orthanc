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

  Additional arguments passed to `query_orthanc`.

## Value

A `list` of
[Instance](https://mattwarkentin.github.io/orthanc/reference/Instance.md)
objects.

## Examples

``` r
client <- Orthanc$new("https://orthanc.uclouvain.be/demo")
find_instances(
  client = client,
  query = list(SOPInstanceUID = "1.3.6.1.4.1.14519.5.2.1.2193.7172.260209224923274040650639981398")
)
#> [[1]]
#> <Instance: 1ef6aa01-aea6d37e-6f834d3f-85b8db92-495f34ac>
```
