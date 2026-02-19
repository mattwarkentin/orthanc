# Find and filter patients using predicate functions

Find desired Patient/Study/Series/Instance in an Orthanc server.
Predicate functions (filters) take a single
Patient/Study/Series/Instance as the first argument and return a single
`TRUE` or `FALSE` for whether the resource should be kept or discarded,
respectively.

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
#> [[1]]
#> <Patient: 0946fcb6-cf12ab43-bad958c1-bf057ad5-0fc6f54c>
#> [[2]]
#> <Patient: 16738bc3-e47ed42a-43ce044c-a3414a45-cb069bd0>
#> [[3]]
#> <Patient: 2f74083e-9b042648-10edac14-b26950f8-f82ec3a0>
#> [[4]]
#> <Patient: 46e6332c-677825b6-202fcf7c-f787bc5f-7b07c382>
#> [[5]]
#> <Patient: 65ce8003-696b2eb6-03adeee7-6561ce8e-3e03f13a>
#> [[6]]
#> <Patient: 6816cb19-844d5aee-85245eba-28e841e6-2414fae2>
#> [[7]]
#> <Patient: a8d72883-45661eab-168bafbf-d799b4dc-4fc83a26>
#> [[8]]
#> <Patient: da39a3ee-5e6b4b0d-3255bfef-95601890-afd80709>
```
