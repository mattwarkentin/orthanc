new_orthanc_credential <- function(x) {
  if (is.character(x) && length(x) == 1) {
    structure(x, class = "orthanc_cred")
  } else {
    cli::cli_abort("An Orthanc credential must be a string")
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
  cat(paste0("<orthanc_cred> ", format(object), "\n", collapse = ""))
  invisible()
}

obfuscate <- function(x, first = 4, last = 4) {
  paste0(
    substr(x, start = 1, stop = first),
    "...",
    substr(x, start = nchar(x) - last + 1, stop = nchar(x))
  )
}
