library(tidyverse)
library(jsonlite)
library(glue)

openapi_spec <- fromJSON("inst/Orthanc/orthanc-openapi.json")

df <-
  openapi_spec |>
  pluck('paths') |>
  enframe("route", "data") |>
  mutate(
    data = map(data, \(x) enframe(x, "method", "info"))
  ) |>
  unnest(data) |>
  unnest_wider(info) |>
  filter(!deprecated)

roxygen_desc <-
  df |>
  select(route, method, summary, description) |>
  mutate(
    summary = str_wrap(
      glue("#' @description {summary}"),
      width = 65
    ),
    description = str_wrap(description, 65),
    description = str_split(description, "\n"),
    description = map(description, \(x) {
      imap(x, \(y, i) {
        if (i == 1) {
          str_replace(y, "\\S", "#' \\0")
        } else {
          str_replace(y, "\\S", "#'   \\0")
        }
      })
    }),
    description = map_chr(description, \(x) {
      glue_collapse(x, "\n")
    }),
    description = str_replace_all(description, "\\[", "\\\\["),
    description = str_replace_all(description, "\\]", "\\\\]"),
    roxygen = as.character(glue("{summary}\n#'\n{description}"))
  ) |>
  select(route, method, description = roxygen)

roxygen_family <-
  df |>
  select(route, method, tags) |>
  mutate(
    family = str_split(str_wrap(tags, 65), "\n"),
    family = map_chr(family, \(x) {
      glue("#' @family {x}") |>
        glue_collapse(sep = "\n") |>
        as.character()
    })
  ) |>
  select(route, method, family)

roxygen_return <-
  df |>
  select(route, method, responses) |>
  hoist(
    responses,
    return = list("200", "content", 1, "schema", "description")
  ) |>
  mutate(
    return = replace_na(return, "Nothing, invisibly"),
    return = str_replace(return, "^$", "Nothing, invisibly"),
    return = glue("@return {return}."),
    return = str_split(str_wrap(return, 65, exdent = 2), "\n"),
    return = map_chr(return, \(x) {
      glue("#' {x}") |>
        glue_collapse(sep = "\n") |>
        as.character()
    }),
    return = str_replace_all(
      return,
      "JSON array|JSON associative array",
      "List"
    )
  ) |>
  select(route, method, return)

roxygen_params_opt_defer <-
  df |>
  select(route, method, parameters) |>
  unnest(parameters) |>
  unnest(schema) |>
  filter(!required) |>
  distinct(route, method, `in`) |>
  mutate(
    param_type = if_else(`in` == "query", "params", "headers"),
    params = case_match(
      param_type,
      "params" ~ "(list) Named-list of optional query parameters. See Details.",
      "headers" ~ "(list) Named-list of optional header parameters. See Details."
    ),
    params = as.character(glue("#' @param {param_type} {params}")),
  ) |>
  summarise(
    params = as.character(glue_collapse(params, sep = '\n')),
    .by = c(route, method)
  )

roxygen_params_opt <-
  df |>
  select(route, method, parameters) |>
  unnest(parameters) |>
  unnest(schema) |>
  filter(!required) |>
  mutate(
    vec_type = case_match(
      type,
      "string" ~ "character",
      "number" ~ "numeric",
      "boolean" ~ "logical",
      "array" ~ "list"
    )
  )

roxygen_params_opt_query <-
  roxygen_params_opt |>
  filter(`in` == 'query') |>
  mutate(
    desc = as.character(glue("- {name} ({type}): {description}")),
    desc = str_wrap(desc, 65, exdent = 5, indent = 3),
    desc = glue("#'{desc}"),
    desc = str_replace_all(desc, "\n", "\n#'")
  ) |>
  summarise(
    params = as.character(glue_collapse(desc, sep = "\n")),
    details = as.character(
      glue(
        "#' Optional query parameters (`params`):\n{params}"
      )
    ),
    .by = c(route, method)
  ) |>
  select(route, method, details)

roxygen_params_opt_header <-
  roxygen_params_opt |>
  filter(`in` == 'header') |>
  mutate(
    desc = as.character(glue("- {name} ({type}): {description}")),
    desc = str_wrap(desc, 65, exdent = 5, indent = 3),
    desc = glue("#'{desc}"),
    desc = str_replace_all(desc, "\n", "\n#'")
  ) |>
  summarise(
    params = as.character(glue_collapse(desc, sep = "\n")),
    details = as.character(
      glue(
        "#' Optional headers (`headers`):\n{params}"
      )
    ),
    .by = c(route, method)
  ) |>
  select(route, method, details)

roxygen_params_req <-
  df |>
  select(route, method, parameters) |>
  unnest(parameters) |>
  unnest(schema) |>
  filter(required) |>
  mutate(
    vec_type = case_match(
      type,
      "string" ~ "character",
      "number" ~ "numeric",
      "boolearn" ~ "logical"
    )
  ) |>
  mutate(
    description = glue("({vec_type}) {description}"),
    roxy = map2(name, description, \(x, y) glue('@param {x} {y}.')),
    roxy = as.character(roxy),
    roxy = map2(name, roxy, \(x, y) {
      str_wrap(y, 65, exdent = 2) |>
        str_split("\n") |>
        map(\(x) glue("#' {x}")) |>
        unlist() |>
        glue_collapse(sep = "\n")
    })
  ) |>
  summarise(
    params = as.character(glue_collapse(roxy, sep = '\n')),
    .by = c(route, method)
  )

roxygen_params_body <-
  roxygen_req_body |>
  mutate(
    params = case_match(
      name,
      c(
        "application/dicom",
        "application/zip"
      ) ~ "#' @param file (character) Path to file for request body. See Details.",
      "application/json" ~ "#' @param json (list) Named-list for request body. See Details.",
      c(
        "application/octet-stream",
        "text/plain"
      ) ~ "#' @param data (bytes or character) Raw data for request body. See Details."
    )
  ) |>
  distinct(route, method, params) |>
  summarise(
    params = glue_collapse(params, sep = "\n"),
    .by = c(route, method)
  )


roxygen_params <-
  full_join(
    roxygen_params_req,
    roxygen_params_opt_defer,
    by = join_by(route, method)
  ) |>
  full_join(roxygen_params_body, by = join_by(route, method)) |>
  mutate(
    params.z = params,
    params = case_when(
      is.na(params.x) & is.na(params.y) & is.na(params.z) ~ "",
      is.na(params.y) & is.na(params.z) ~ params.x,
      is.na(params.x) & is.na(params.z) ~ params.y,
      is.na(params.x) & is.na(params.y) ~ params.z,
      is.na(params.x) ~ glue("{params.y}\n{params.z}"),
      is.na(params.y) ~ glue("{params.x}\n{params.z}"),
      is.na(params.z) ~ glue("{params.x}\n{params.y}"),
      .default = as.character(glue("{params.x}\n{params.y}\n{params.z}"))
    )
  ) |>
  select(route, method, params)

roxygen_req_body <-
  df |>
  select(route, method, requestBody) |>
  filter(!map_lgl(requestBody, is.null)) |>
  hoist(requestBody, "content") |>
  mutate(
    name = map(content, names)
  ) |>
  unnest(c(name, content))

roxygen_body_json <-
  roxygen_req_body |>
  filter(name == "application/json") |>
  hoist(content, properties = c("schema", "properties")) |>
  mutate(
    arg = map(properties, names)
  ) |>
  unnest(c(arg, properties), keep_empty = TRUE) |>
  hoist(content, desc2 = c("schema", "description")) |>
  hoist(properties, type = "type", desc = "description") |>
  mutate(
    desc = coalesce(desc, desc2),
    arg = coalesce(arg, ""),
    type = case_match(
      type,
      "string" ~ "character",
      "number" ~ "numeric",
      "boolean" ~ "logical",
      "array" ~ "list",
      "object" ~ "list",
      .default = "list"
    ),
    desc = as.character(glue("- {arg} ({type}): {desc}")),
    desc = str_wrap(desc, 65, exdent = 5, indent = 3),
    desc = glue("#'{desc}"),
    desc = str_replace_all(desc, "\n", "\n#'")
  ) |>
  summarise(
    params = as.character(glue_collapse(desc, sep = "\n")),
    details = as.character(
      glue(
        "#' Request body JSON schema ({unique(name)}):\n{params}"
      )
    ),
    .by = c(route, method)
  ) |>
  select(route, method, details)

roxygen_body_others <-
  roxygen_req_body |>
  filter(name != "application/json") |>
  hoist(content, description = c("schema", "description")) |>
  mutate(
    desc = as.character(glue("{description} ({name})"))
  ) |>
  summarise(
    desc = as.character(glue_collapse(desc, sep = " or ")),
    .by = c(route, method)
  ) |>
  mutate(
    details = as.character(glue("Request body: {desc}")),
    details = as.character(glue("#' {details}.")),
    details = str_wrap(details, 65, exdent = 3),
    details = str_replace_all(details, "\n", "\n#'")
  ) |>
  select(route, method, details)

roxygen_body_schema <-
  bind_rows(roxygen_body_json, roxygen_body_others) |>
  summarise(
    details = as.character(glue_collapse(details, sep = "\n")),
    .by = c(route, method)
  )

roxygen_details <-
  full_join(
    roxygen_body_schema,
    roxygen_params_opt_header,
    by = join_by(route, method)
  ) |>
  full_join(roxygen_params_opt_query, by = join_by(route, method)) |>
  rename(details.z = details) |>
  mutate(
    details.x = if_else(is.na(details.x), "", glue("\n\n{details.x}")),
    details.y = if_else(is.na(details.y), "", glue("\n\n#'\n{details.y}")),
    details.z = if_else(is.na(details.z), "", glue("\n\n#'\n{details.z}"))
  ) |>
  mutate(
    details = as.character(glue(
      "#' @details{details.x}{details.y}{details.z}"
    ))
  ) |>
  select(route, method, details)

final_df <-
  full_join(roxygen_desc, roxygen_family, by = join_by(route, method)) |>
  full_join(roxygen_return, by = join_by(route, method)) |>
  full_join(roxygen_params, by = join_by(route, method)) |>
  full_join(roxygen_details, by = join_by(route, method)) |>
  mutate(
    roxygen = case_when(
      is.na(params) & is.na(details) ~ glue(
        "{description}\n#'\n{family}\n#'\n{return}"
      ),
      is.na(params) ~ glue(
        "{description}\n#'\n{family}\n#'\n{details}\n#'\n{return}"
      ),
      is.na(details) ~ glue(
        "{description}\n#'\n{params}\n#'\n{family}\n#'\n{return}"
      ),
      .default = glue(
        "{description}\n#'\n{params}\n#'\n{family}\n#'\n{details}\n#'\n{return}"
      )
    ),
    roxygen = str_replace_all(roxygen, "`true`", "`TRUE`"),
    roxygen = str_replace_all(roxygen, "`false`", "`FALSE`"),
    has_route_params = str_detect(route, "\\{"),
    all_params = str_match_all(roxygen, "#' @param (\\w+)"),
    route_params = str_match_all(route, "\\{(\\w+)\\}"),
    non_route_params = map2(all_params, route_params, \(x, y) {
      setdiff(x[, 2], y[, 2])
    }),
    has_non_route_params = map_lgl(non_route_params, \(x) !rlang::is_empty(x)),
    non_route_params_str = map_chr(non_route_params, \(x) {
      if (length(x) == 0) {
        return("")
      }
      if (length(x) == 1) {
        return(glue("{x} = NULL"))
      }
      if (length(x) > 1) {
        x <- glue_collapse(x, sep = " = NULL, ")
        return(glue("{x} = NULL"))
      }
    }),
    non_route_params_args = map_chr(non_route_params, \(x) {
      map_chr(x, \(y) glue("{y} = {y}")) |>
        glue_collapse(sep = ", ")
    }),
    route_params = map_chr(route_params, \(x) {
      glue_collapse(x[, 2], sep = ", ")
    }),
    params = glue('{route_params}, {non_route_params_str}'),
    params = str_remove_all(params, "^[[:punct:]]+ |[[:punct:]]+ $"),
    route_clean = str_remove_all(route, "\\{|\\}"),
    route_clean = str_remove(route_clean, "^/"),
    route_clean = str_replace_all(route_clean, "/|-", "_"),
    route_clean = glue("{method}_{route_clean}"),
    func = case_when(
      has_route_params & has_non_route_params ~ glue(
        '{route_clean} = function({params}) {{
        self${str_to_upper(method)}(glue::glue("{route}"), {non_route_params_args})
      }}'
      ),
      has_route_params ~ glue(
        '{route_clean} = function({params}) {{
        self${str_to_upper(method)}(glue::glue("{route}"))
      }}'
      ),
      has_non_route_params ~ glue(
        '{route_clean} = function({params}) {{
        self${str_to_upper(method)}("{route}", {non_route_params_args})
      }}'
      ),
      .default = glue(
        '{route_clean} = function({params}) {{
        self${str_to_upper(method)}("{route}")
      }}'
      )
    ),
    roxygen = glue("{roxygen}\n{func}")
  ) |>
  select(route, method, roxygen)

write_csv(
  x = final_df,
  file = "inst/Orthanc/Orthanc_roxygen_1_12_10.csv"
)

final_df |>
  pull(roxygen) |>
  glue_collapse(sep = ",\n\n") |>
  clipr::write_clip()
