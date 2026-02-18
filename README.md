
# orthanc <img src="man/figures/logo.png" align="right" height="120" alt="" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/mattwarkentin/orthanc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mattwarkentin/orthanc/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of `orthanc` is to provide programmatic access to the
[Orthanc](https://orthanc.uclouvain.be) DICOM Server REST API for the R
language.

## Installation

You can install the development version of `orthanc` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("mattwarkentin/orthanc")
```

## Usage

``` r
library(orthanc)

client <- Orthanc$new("https://orthanc.uclouvain.be/demo")

instances <- client$get_instances()

instances
#> [[1]]
#> [1] "001a7d82-54008387-7b23ad57-8fb6202a-6d3b305b"
#> 
#> [[2]]
#> [1] "001b6592-37c2fbe4-2c07c724-ce9607e2-2bd210e8"
#> 
#> [[3]]
#> [1] "00330d0f-911e5e8d-1e305bae-e5c53b73-d2a49298"
#> 
#> [[4]]
#> [1] "00402ce7-ac05c687-4d0839bc-cecd4fad-3d1b7eed"
#> 
#> [[5]]
#> [1] "00419319-1d16e8d6-2eb65ed2-0de8313f-3356e31e"
#> 
#>  [ reached 'max' / getOption("max.print") -- omitted 2547 entries ]
#> attr(,"class")
#> [1] "orthanc_response" "list"
```

``` r
instance <- Instance$new(instances[[1]], client)
instance
#> <Instance: 001a7d82-54008387-7b23ad57-8fb6202a-6d3b305b>

instance$main_dicom_tags
#> $AcquisitionNumber
#> [1] "4"
#> 
#> $ImageOrientationPatient
#> [1] "1\\0\\0\\0\\1\\0"
#> 
#> $ImagePositionPatient
#> [1] "-249.51171875\\-458.51171875\\364"
#> 
#> $InstanceCreationDate
#> [1] "20151217"
#> 
#> $InstanceCreationTime
#> [1] "125203.943000"
#> 
#>  [ reached 'max' / getOption("max.print") -- omitted 2 entries ]
```

## Code of Conduct

Please note that the `orthanc` project is released with a [Contributor
Code of
Conduct](https://mattwarkentin.github.io/orthanc/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
