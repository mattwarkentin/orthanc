library(jsonlite)
library(purrr)

openapi_spec_url <- "https://orthanc.uclouvain.be/api/orthanc-openapi.json"

endpoints <-
  read_json(openapi_spec_url) |>
  pluck('paths') |>
  map(\(x) names(x)) |>
  enframe("route", "method") |>
  unnest(method)

write_csv(
  x = endpoints,
  file = "inst/Orthanc/Orthanc_endpoints_1_12_10.csv"
)
