# Query data in the Orthanc server

Query data in the Orthanc server

## Usage

``` r
query_orthanc(
  client,
  level,
  query = list(),
  labels = character(),
  labels_constraint = "All",
  limit = 1000L,
  since = 0L,
  retrieve_all_resources = TRUE,
  lock_children = FALSE
)
```

## Arguments

- client:

  Orthanc API client.

- level:

  Level of the query ('Patient', 'Study', 'Series', 'Instance').

- query:

  Named-list that specifies the filters on the level related DICOM tags.

- labels:

  Character vector of labels to look for in resources.

- labels_constraint:

  Contraint on the labels ('All', 'Any', 'None').

- limit:

  Limit the number of reported instances (default is `1000L`).

- since:

  Show only the resources since the index specified in the `since`
  parameter.

- retrieve_all_resources:

  Retrieve all resources since the index specified in the `since`
  parameter.

- lock_children:

  If `lock_children` is `TRUE`, the resource children (e.g., instances
  of a series via `Series.instances`) will be cached at the first query
  rather than queried every time. This is useful when you want to filter
  the children of a resource and want to maintain the filter result.

## Value

A `list` of resources.
