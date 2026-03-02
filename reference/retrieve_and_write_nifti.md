# Retrieve and write resources to a path

Retrieve the NIfTI file or ZIP Archive contents for a list of resources
and write them to a `path` on disk. If
[`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html) has
been used to set persistent background processes, these functions will
write resources to disk in parallel using all available processes.

## Usage

``` r
retrieve_and_write_nifti(
  resources,
  path,
  compress = TRUE,
  stream = FALSE,
  progress = rlang::is_interactive()
)

retrieve_and_write_archives(
  resources,
  path,
  stream = FALSE,
  progress = rlang::is_interactive()
)

retrieve_and_write_images(resources, path, progress = rlang::is_interactive())
```

## Arguments

- resources:

  List of resources.

- path:

  Path where you want to write the resources.

- compress:

  Compress to gzip (`nii.gz`) Default is `TRUE`.

- stream:

  Should the resource be streamed and written to disk in chunks? Default
  is `FALSE`, which means the resource file contents are retrieved in
  their entirety and written to disk all at once.

- progress:

  Whether to show progress bars. By default, progress bars are enabled
  in interactive sessions (i.e., if
  [`rlang::is_interactive()`](https://rlang.r-lib.org/reference/is_interactive.html)
  returns `TRUE`).

## Value

Nothing, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
client <- Orthanc$new("https://orthanc.uclouvain.be/demo")
study_id <- client$get_studies()[[1]]
study <- Study$new(study_id, client)

retrieve_and_write_nifti(study$series, tempdir())

retrieve_and_write_archives(study$series, tempdir())

retrieve_and_write_images(study$instances, tempdir())
} # }
```
