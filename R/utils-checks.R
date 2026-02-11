check_orthanc_client <- function(x, x_nm = NULL) {
  if (rlang::inherits_all(x, "Orthanc")) {
    return(TRUE)
  }

  if (rlang::is_null(x_nm)) {
    x_nm <- deparse(substitute(x))
  }

  rlang::abort(
    message = glue::glue(
      "`{x_nm}` must be an Orthanc client object."
    ),
    call = rlang::caller_env()
  )
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
      "Length of `{x_nm}` must be equal to length of `{y_nm}`."
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
