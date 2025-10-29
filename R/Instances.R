get_instances <- function(url) {
  httr2::request(url) |>
    httr2::req_url_path_append('instances') |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    unlist()
}
