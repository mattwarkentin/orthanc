# Modality Class

Wrapper around Orthanc API when dealing with a modality

## Value

An instance of `Modality`.

## Public fields

- `modality`:

  Modality.

## Methods

### Public methods

- [`Modality$initalize()`](#method-Modality-initalize)

- [`Modality$echo()`](#method-Modality-echo)

- [`Modality$get()`](#method-Modality-get)

- [`Modality$find()`](#method-Modality-find)

- [`Modality$move()`](#method-Modality-move)

- [`Modality$store()`](#method-Modality-store)

- [`Modality$get_query_answers()`](#method-Modality-get_query_answers)

- [`Modality$clone()`](#method-Modality-clone)

------------------------------------------------------------------------

### `Modality$initalize()`

Create a new Modality instance.

#### Usage

    Modality$initalize(client, modality)

#### Arguments

- `client`:

  Orthanc API client.

- `modality`:

  Remote modality.

------------------------------------------------------------------------

### `Modality$echo()`

C-Echo to modality

#### Usage

    Modality$echo()

------------------------------------------------------------------------

### `Modality$get()`

C-Move SCU: Send all the results to another modality whose AET is in the
body.

#### Usage

    Modality$get(level, resources)

#### Arguments

- `level`:

  Level of the query ("Patient", "Study", "Series", "Instance").

- `resources`:

  List or named-list of DICOM tags that identify data to retrieve (e.g.,
  list(StudyInstanceUID = "1.3.6.1.4.1.22213.2.6291.2.1")).

------------------------------------------------------------------------

### `Modality$find()`

C-Find (Querying with data)

#### Usage

    Modality$find(data)

#### Arguments

- `data`:

  Named-list to send in the body of request.

------------------------------------------------------------------------

### `Modality$move()`

C-Find (Querying with data)

#### Usage

    Modality$move(query_id, cmove_data)

#### Arguments

- `query_id`:

  Query identifier.

- `cmove_data`:

  Ex. list(TargetAet = 'target_modality_name', Synchronous = FALSE)

------------------------------------------------------------------------

### `Modality$store()`

Store series or instance to modality.

#### Usage

    Modality$store(instance_or_series_id)

#### Arguments

- `instance_or_series_id`:

  Instance or Series Orthanc identifier.

------------------------------------------------------------------------

### `Modality$get_query_answers()`

Get query answers.

#### Usage

    Modality$get_query_answers(query_id)

#### Arguments

- `query_id`:

  Query identifier.

------------------------------------------------------------------------

### `Modality$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Modality$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
