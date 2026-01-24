.parse_params <- function(..., .params = list()) {
  params <- c(rlang::list2(...), .params)
  drop_named_nulls(params)
}

drop_named_nulls <- function(x) {
  if (has_no_names(x)) {
    return(x)
  }
  named <- has_name(x)
  null <- vapply(x, is.null, logical(1))
  cleanse_names(x[!named | !null])
}

has_no_names <- function(x) all(!has_name(x))

has_name <- function(x) {
  nms <- names(x)
  if (is.null(nms)) {
    rep_len(FALSE, length(x))
  } else {
    !(is.na(nms) | nms == "")
  }
}

cleanse_names <- function(x) {
  if (has_no_names(x)) {
    names(x) <- NULL
  }
  x
}

remove_headers <- function(x) {
  x[names(x) != "headers"]
}
