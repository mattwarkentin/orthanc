# Job class to follow a Job in Orthanc

Job class to follow a Job in Orthanc

Job class to follow a Job in Orthanc

## Value

An instance of `Job`.

## Active bindings

- `state`:

  Job state.

- `content`:

  Job content.

- `type`:

  Job type.

- `creation_time`:

  Job creation time.

- `effective_runtime`:

  Job effective runtime.

- `priority`:

  Job priority.

- `progress`:

  Job progress.

- `error`:

  Job error.

- `error_details`:

  Job error details.

- `timestamp`:

  Job timestamp.

- `completion_time`:

  Job completion time.

## Methods

### Public methods

- [`Job$new()`](#method-Job-new)

- [`Job$wait_until_completion()`](#method-Job-wait_until_completion)

- [`Job$get_information()`](#method-Job-get_information)

------------------------------------------------------------------------

### Method `new()`

Create a new Job instance.

#### Usage

    Job$new(id, client)

#### Arguments

- `id`:

  Job ID.

- `client`:

  Orthanc API client.

------------------------------------------------------------------------

### Method `wait_until_completion()`

Stop execution until job is not Pending/Running.

#### Usage

    Job$wait_until_completion(interval = 2L)

#### Arguments

- `interval`:

  Time interval to check the job status, default is 2s.

------------------------------------------------------------------------

### Method `get_information()`

Get job information.

#### Usage

    Job$get_information()
