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

find_instances(client, query = list(BodyPartExamined = 'CHEST'))
#> [[1]]
#> <Instance: 001a7d82-54008387-7b23ad57-8fb6202a-6d3b305b>
#> [[2]]
#> <Instance: 005f747f-edbb7c3a-9174bcfa-5591350a-0866aa35>
#> [[3]]
#> <Instance: 0092ce4b-9d4b0966-f5fd8c6a-beb6daa7-2e6bcda9>
#> [[4]]
#> <Instance: 00cc35c5-f7e8bbe1-aa784413-87e00620-001104cc>
#> [[5]]
#> <Instance: 02184370-1bdd3c2e-5d14690c-4f7d6173-62c47724>
#> [[6]]
#> <Instance: 025c7cfa-28037c29-f7028d01-527ddac5-a7cc5bf8>
#> [[7]]
#> <Instance: 0363a0de-f443d8f8-1a9790fe-d79740f2-00c0724e>
#> [[8]]
#> <Instance: 079d5889-85cb07a3-d3608b8c-d5863ea4-39bdcd37>
#> [[9]]
#> <Instance: 08575e68-7d723709-c4590d0c-950bb164-096f8585>
#> [[10]]
#> <Instance: 085f66d7-b3cdc15a-c3a14f4c-8cc4d611-e2086505>
#>  [ reached 'max' / getOption("max.print") -- omitted 414 entries ]
```
