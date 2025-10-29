get_series <- function(url) {
  httr2::request(url) |>
    httr2::req_url_path_append('series') |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    unlist()
}
