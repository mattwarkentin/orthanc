# Finds series in Orthanc according to queries and labels

Finds series in Orthanc according to queries and labels

## Usage

``` r
find_series(
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
[Series](https://mattwarkentin.github.io/orthanc/reference/Series.md)
objects.

## Examples

``` r
client <- Orthanc$new("https://orthanc.uclouvain.be/demo")
find_series(client, query = list(SeriesDescription = "HEAD/NECK  2.0  B30s"))
#> [[1]]
#> <Series: 52f4cb90-29d1d1a2-2ca34edd-4b8851fc-8cb269f2>
```
