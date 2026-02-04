new_orthanc_credential <- function(x) {
  if (is.character(x) && length(x) == 1) {
    structure(x, class = "orthanc_cred")
  } else {
    rlang::abort("An Orthanc credential must be a string")
  }
}

orthanc_credential <- function(x) {
  new_orthanc_credential(x)
}

#' @exportS3Method
format.orthanc_cred <- function(x, ...) {
  if (x == "") {
    "<no credential>"
  } else {
    obfuscate(x)
  }
}

#' @exportS3Method
print.orthanc_cred <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}

#' @exportS3Method
str.orthanc_cred <- function(object, ...) {
  cat(format(object))
  invisible()
}

obfuscate <- function(x) {
  "<orthanc credential>"
}
