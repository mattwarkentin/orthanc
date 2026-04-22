library(tidyverse)

devtools::load_all()

o <- Orthanc$new()

instance <- Instance$new(o$get_instances()[[1]], o)

series <- Series$new(o$get_series()[[1]], o)

study <- Study$new(o$get_studies()[[1]], o)

patient <- Patient$new(o$get_patients()[[1]], o)

# Instances - DICOM ----

instances_dicom <- bench::mark(
  INSTANCE_WHOLE = instance$download_dicom(tempdir(), stream = FALSE),
  INSTANCE_STREAM = instance$download_dicom(tempdir(), stream = TRUE)
)

# Instances - NIfTI ----

instances_nifti <- bench::mark(
  INSTANCE_WHOLE_RAW = instance$download_nifti(
    tempdir(),
    compress = FALSE,
    stream = FALSE
  ),
  INSTANCE_WHOLE_COMP = instance$download_nifti(
    tempdir(),
    compress = TRUE,
    stream = FALSE
  ),
  INSTANCE_STREAM_RAW = instance$download_nifti(
    tempdir(),
    compress = FALSE,
    stream = TRUE
  ),
  INSTANCE_STREAM_COMP = instance$download_nifti(
    tempdir(),
    compress = TRUE,
    stream = TRUE
  )
)

# Series - ZIP Archive ----

series_zip <- bench::mark(
  SERIES_WHOLE = series$download_archive(tempdir(), stream = FALSE),
  SERIES_STREAM = series$download_archive(tempdir(), stream = TRUE)
)

# Series - NIfTI ----

series_nifti_comp <- bench::mark(
  SERIES_WHOLE_COMP = series$download_nifti(
    tempdir(),
    compress = TRUE,
    stream = FALSE
  ),
  SERIES_STREAM_COMP = series$download_nifti(
    tempdir(),
    compress = TRUE,
    stream = TRUE
  )
)

series_nifti_raw <- bench::mark(
  SERIES_WHOLE_RAW = series$download_nifti(
    tempdir(),
    compress = FALSE,
    stream = FALSE
  ),
  SERIES_STREAM_RAW = series$download_nifti(
    tempdir(),
    compress = FALSE,
    stream = TRUE
  )
)

# Study - ZIP Archive ----

studies_zip <- bench::mark(
  STUDY_WHOLE = study$download_archive(tempdir(), stream = FALSE),
  STUDY_STREAM = study$download_archive(tempdir(), stream = TRUE)
)

# Patient - ZIP Archive ----

patients_zip <- bench::mark(
  PATIENT_WHOLE = patient$download_archive(tempdir(), stream = FALSE),
  PATIENT_STREAM = patient$download_archive(tempdir(), stream = TRUE)
)

# Combine results ----

df <- dplyr::bind_rows(
  DICOM = instances_dicom,
  NIfTI = instances_nifti,
  ZIP = series_zip,
  NIfTI = series_nifti,
  ZIP = studies_zip,
  ZIP = patients_zip,
  .id = "name"
)
