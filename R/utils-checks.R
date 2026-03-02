check_orthanc_client <- function(x, x_nm = NULL, async_allowed = FALSE) {
  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }

  if (async_allowed) {
    if (!rlang::inherits_any(x, c("OrthancAsync", "Orthanc"))) {
      return(rlang::abort(
        message = glue::glue(
          "`{x_nm}` must be an `Orthanc` or `OrthancAsync` client object."
        ),
        call = rlang::caller_env()
      ))
    }
  } else {
    if (!rlang::inherits_only(x, c("Orthanc", "R6"))) {
      return(rlang::abort(
        message = glue::glue(
          "`{x_nm}` must be an `Orthanc` client object."
        ),
        call = rlang::caller_env()
      ))
    }
  }

  TRUE
}

check_list <- function(x, x_nm = NULL) {
  if (rlang::inherits_all(x, "list")) {
    return(TRUE)
  }

  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }

  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be a list."
    ),
    call = rlang::caller_env()
  )
}

check_named_list <- function(x, x_nm = NULL) {
  if (rlang::inherits_all(x, "list") & all(nchar(names(x)) > 0)) {
    return(TRUE)
  }

  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }

  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be a named list."
    ),
    call = rlang::caller_env()
  )
}

check_equal_length <- function(x, y) {
  x_nm <- deparse(substitute(x))
  y_nm <- deparse(substitute(y))
  if (length(x) == length(y)) {
    return(TRUE)
  }
  rlang::abort(
    message = glue::glue(
      "Length of `{x_nm}` and `{y_nm}` must be equal."
    ),
    call = rlang::caller_env()
  )
}

check_integer <- function(x, x_nm = NULL) {
  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }
  if (rlang::is_integerish(x)) {
    return(TRUE)
  }
  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be an integer"
    ),
    call = rlang::caller_env()
  )
}

check_numeric <- function(x, x_nm = NULL) {
  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }
  if (rlang::is_double(x)) {
    return(TRUE)
  }
  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be numeric."
    ),
    call = rlang::caller_env()
  )
}

check_character <- function(x, x_nm = NULL) {
  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }
  if (rlang::is_character(x)) {
    return(TRUE)
  }
  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be a character."
    ),
    call = rlang::caller_env()
  )
}

check_logical <- function(x, x_nm = NULL) {
  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }
  if (rlang::is_logical(x)) {
    return(TRUE)
  }
  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be logical."
    ),
    call = rlang::caller_env()
  )
}

check_scalar_integer <- function(x, x_nm = NULL) {
  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }

  if (rlang::is_scalar_integerish(x)) {
    return(TRUE)
  }
  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be a scalar integer."
    ),
    call = rlang::caller_env()
  )
}

check_scalar_numeric <- function(x, x_nm = NULL) {
  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }

  if (rlang::is_scalar_double(x)) {
    return(TRUE)
  }
  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be a scalar numeric"
    ),
    call = rlang::caller_env()
  )
}

check_scalar_character <- function(x, x_nm = NULL) {
  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }

  if (rlang::is_scalar_character(x)) {
    return(TRUE)
  }
  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be a scalar character"
    ),
    call = rlang::caller_env()
  )
}

check_scalar_logical <- function(x, x_nm = NULL) {
  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }

  if (rlang::is_scalar_logical(x)) {
    return(TRUE)
  }
  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be a scalar logical."
    ),
    call = rlang::caller_env()
  )
}

check_function <- function(x, x_nm = NULL) {
  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }

  if (rlang::is_function(x)) {
    return(TRUE)
  }
  rlang::abort(
    message = glue::glue("`{x_nm}` must be a function."),
    call = rlang::caller_env()
  )
}

is_empty_list <- function(x) {
  rlang::is_list(x) && rlang::is_empty(x)
}

check_path_exists <- function(path) {
  check_scalar_character(path)
  if (fs::dir_exists(path)) {
    return(TRUE)
  }
  rlang::abort("`path` does not exist.", call = rlang::caller_env())
}

check_class_any <- function(x, class) {
  x_nm <- deparse(substitute(x))
  class_str <- glue::glue_collapse(glue::glue('"{class}"'), " or ")
  if (rlang::inherits_any(x, class)) {
    return(TRUE)
  }
  rlang::abort(
    glue::glue("`{x_nm}` must inherit one of class: {class_str}"),
    call = rlang::caller_env()
  )
}

check_list_of_class_any <- function(x, class) {
  x_nm <- deparse(substitute(x))
  class_str <- glue::glue_collapse(glue::glue('"{class}"'), " or ")
  if (is.list(x) && purrr::every(x, \(x) rlang::inherits_any(x, class))) {
    return(TRUE)
  }
  rlang::abort(
    glue::glue('All elements of `{x_nm}` must inherit from class {class_str}.'),
    call = rlang::caller_env()
  )
}
