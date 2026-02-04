
# orthanc <img src="man/figures/logo.png" align="right" height="120" alt="" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/mattwarkentin/orthanc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mattwarkentin/orthanc/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of `orthanc` is to provide programmatic access to the Orthanc
DICOM Server REST API for the R language.

## Installation

You can install the development version of `orthanc` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("mattwarkentin/orthanc")
```

## Usage

``` r
options(max.print = 10)
```

``` r
library(orthanc)

client <- Orthanc$new("https://orthanc.uclouvain.be/demo")

client$get_instances()
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
#> [[6]]
#> [1] "005f747f-edbb7c3a-9174bcfa-5591350a-0866aa35"
#> 
#> [[7]]
#> [1] "00874fa6-f3da74b0-147489f4-71427817-a8b502ed"
#> 
#> [[8]]
#> [1] "0092ce4b-9d4b0966-f5fd8c6a-beb6daa7-2e6bcda9"
#> 
#> [[9]]
#> [1] "00a99a6f-a5ace144-3e0ef3ae-831374b6-311c1307"
#> 
#> [[10]]
#> [1] "00c7f841-f909c088-9732704b-4a533ea3-c2f2be2c"
#> 
#>  [ reached 'max' / getOption("max.print") -- omitted 2542 entries ]
#> attr(,"class")
#> [1] "orthanc_response" "list"
```
