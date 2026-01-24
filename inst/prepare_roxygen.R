library(tidyverse)
library(jsonlite)
library(glue)

spec <- fromJSON("inst/orthanc-openapi.json")

get_routes <-
  spec |>
  pluck('paths') |>
  map(\(x) pluck(x, 'get')) |>
  tibblify::tibblify() |>
  rename(route = .names) |>
  filter(!is.na(deprecated))

get_desc <-
  get_routes |>
  select(route, summary, description) |>
  mutate(
    summary = str_split(str_wrap(summary, 80 - 3), "\n"),
    summary = map_chr(summary, \(x) {
      glue("#' @description\n#' {x}") |>
        glue_collapse(sep = "\n") |>
        as.character()
    }),
    description = str_split(str_wrap(description, 80 - 3), "\n"),
    description = map_chr(description, \(x) {
      glue("#' {x}") |>
        glue_collapse(sep = "\n") |>
        as.character()
    }),
    roxygen = as.character(glue("{summary}\n#'\n{description}"))
  ) |>
  select(route, description = roxygen)


get_return <-
  get_routes |>
  select(route, responses) |>
  hoist(responses, return = c(2, 1, 2, 1, 1)) |>
  mutate(
    return = glue("@return {return}."),
    return = str_split(str_wrap(return, 80 - 3), "\n"),
    return = map_chr(return, \(x) {
      glue("#' {x}") |>
        glue_collapse(sep = "\n") |>
        as.character()
    })
  ) |>
  select(route, return)

params <-
  fromJSON("inst/orthanc-openapi.json") |>
  pluck('paths') |>
  map(\(x) pluck(x, 'get', 'parameters')) |>
  map(as_tibble) |>
  list_rbind(names_to = 'route') |>
  filter(required)

get_params <-
  params |>
  select(route, name, description) |>
  mutate(
    roxy = map2(name, description, \(x, y) glue('@param {x} {y}.')),
    roxy = as.character(roxy),
    roxy = map2(name, roxy, \(x, y) {
      str_wrap(y, 80 - 3) |>
        str_split("\n") |>
        map(\(x) glue("#' {x}")) |>
        unlist() |>
        glue_collapse(sep = "\n")
    })
  ) |>
  summarise(
    params = as.character(glue_collapse(roxy, sep = '\n')),
    .by = route
  )

full_join(get_desc, get_params, by = join_by(route)) |>
  full_join(get_return, by = join_by(route)) |>
  mutate(
    params = if_else(is.na(params), "", glue("\n\n#'\n{params}")),
    docs = glue("{description}{params}\n#'\n{return}")
  ) |>
  View()
