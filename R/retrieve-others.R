#' Retrieve and write resources to a path
#'
#' Retrieve the NIfTI file or ZIP Archive contents for a list of resources and
#'   write them to a `path` on disk. If [mirai::daemons()] has been used to set
#'   persistent background processes, these functions will write resources to
#'   disk in parallel using all available processes.
#'
#' @param resources List of resources.
#' @param path Path where you want to write the resources.
#' @param compress Compress to gzip (`nii.gz`) Default is `TRUE`.
#' @param progress Whether to show progress bars. By default, progress bars are
#'   enabled in interactive sessions (i.e., if `rlang::is_interactive()`
#'   returns `TRUE`).
#' @param stream Should the resource be streamed and written to disk in
#'   chunks? Default is `FALSE`, which means the resource file contents are
#'   retrieved in their entirety and written to disk all at once.
#'
#' @return Nothing, invisibly.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' client <- Orthanc$new("https://orthanc.uclouvain.be/demo")
#' study_id <- client$get_studies()[[1]]
#' study <- Study$new(study_id, client)
#'
#' retrieve_and_write_nifti(study$series, tempdir())
#'
#' retrieve_and_write_archives(study$series, tempdir())
#'
#' retrieve_and_write_images(study$instances, tempdir())
#' }
retrieve_and_write_nifti = function(
  resources,
  path,
  compress = TRUE,
  stream = FALSE,
  progress = rlang::is_interactive()
) {
  check_list_of_class_any(resources, c("Instance", "Series"))
  check_path_exists(path)
  check_scalar_logical(compress)
  check_scalar_logical(progress)
  check_scalar_logical(stream)

  purrr::walk(
    .x = resources,
    .f = purrr::in_parallel(
      .f = \(resource) resource$download_nifti(path, compress, stream),
      path = path,
      compress = compress,
      stream = stream
    ),
    .progress = ifelse(progress, "Exporting NIfTI", FALSE)
  )
  invisible()
}


#' @rdname retrieve_and_write_nifti
#' @export
retrieve_and_write_archives = function(
  resources,
  path,
  stream = FALSE,
  progress = rlang::is_interactive()
) {
  check_list_of_class_any(resources, c("Series", "Studies", "Patients"))
  check_path_exists(path)
  check_scalar_logical(progress)
  check_scalar_logical(stream)

  purrr::walk(
    .x = resources,
    .f = purrr::in_parallel(
      .f = \(resource) resource$download_archive(path, stream),
      path = path,
      stream = stream
    ),
    .progress = ifelse(progress, "Exporting Archives", FALSE)
  )
  invisible()
}


#' @rdname retrieve_and_write_nifti
#' @export
retrieve_and_write_images = function(
  resources,
  path,
  progress = rlang::is_interactive()
) {
  check_list_of_class_any(resources, c("Instances"))
  check_path_exists(path)
  check_scalar_logical(progress)

  purrr::walk(
    .x = resources,
    .f = purrr::in_parallel(
      .f = \(resource) resource$download_images(path),
      path = path
    ),
    .progress = ifelse(progress, "Exporting Images", FALSE)
  )
  invisible()
}
