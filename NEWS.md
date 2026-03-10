# orthanc (development version)

## New features

- Fixed an issue with `OrthancAsync` where requests would fail when requiring basic authentication. The private method `$request_perform()` now adds the basic authentication (Authorization) header on the `mirai` worker instead of the main process.

- orthanc has gained support for batch exporting image files (PNG or JPEG) for Instances (`retrieve_and_write_images()`), NIfTI files for Instances and Series (`retrieve_and_write_nifti()`), if the Orthanc Neuroimaging plugin is available, and ZIP Archives for Series, Studies, and Patients (`retrieve_and_write_archives()`).
  - `retrieve_and_write_images()`, `retrieve_and_write_nifti()`, and `retrieve_and_write_archives()` have support for progress bars and parallel exporting using `mirai`, similar to `retrieve_and_write_patients()`.

- Major refactor of resource download methods so that output formats aren't ambiguous across the various resource types:
  - Instances now have `$download_dicom()` (formerly `$download()`), `$download_nifti()` (only works if Orthanc Neuroimaging plugin is avialable), and `$download_image()` (if R packages `png` or `jpeg` are installed).
  - Series now have `download_archive()` (formerly `download()`) and `download_nifti()` (only works if Orthanc Neuroimaging plugin is avialable).
  - Studies now have `download_archive()` (formerly `download()`)
  - Patients now have `download_archive()` (formerly `download()`)

- New methods and fields have been added to resources:
  - Instances now have:
    - `download_dicom()`: Download DICOM file to a path
    - `download_image()`: Download instance as an image
    - `has_label()`: Test if resource has label
    - `list_frames`: List frames
    - `frames`: Number of frames
    - `rows`: Number of rows
    - `columns`: Number of columns
    - `shape`: Shape
    - `dim`: Number of dimensions
    - `slice_thickness`: Slice thickness
    - `pixel_spacing`: Pixel spacing
  - Series now have:
    - `download_archive()`: Download zip archive to path
    - `has_label()`: Test if resource has label
    - `num_instances`: Number of instances
  - Studies now have:
    - `download_archive()`: Download zip archive to path
    - `has_label()`: Test if resource has label
    - `series_ids`: Series identifiers
    - `instances_ids`: Instances identifiers
    - `num_series`: Number of series
    - `num_instances`: Number of instances
  - Patients now have:
    - `download_archive()`: Download zip archive to path
    - `has_label()`: Test if resource has label
    - `studies_ids`: Studies identifiers
    - `series_ids`: Series identifiers
    - `instances_ids`: Instances identifiers
    - `num_studies`: Number of studies
    - `num_series`: Number of series
    - `num_instances`: Number of instances

- `$labels` active binding for resources can now be used to add new labels to a resource by assigning into the field (e.g., `Resource$labels <- "label"`).

## Minor improvements and bug fixes

- Improved support for progress bars and parallelization for `find_and_filter()`.

- `Instance$download_nifti()` and `Series$download_nifti()` now use gzip (nii.gz) compression by default.

- `$image_orientation_patient()` and `$image_position_patient()` now return parsed numeric vectors instead of character vectors.

- All `$date` or `$*_date` fields now return `"Date"` class vectors instead of character vectors.

- `$file_size` now returns "pretty" units thanks to `prettyunits::pretty_bytes()`.

- Updated `$print()` method for resources to show locked state, if locked.

- Added new `$is_locked` field to check whether child resources are locked or not.
  - This active binding can be used to modify locked state through assignment.

# orthanc 0.1.0

* Initial public release.
