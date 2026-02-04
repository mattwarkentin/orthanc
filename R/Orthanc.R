#' Orthanc API Client
#'
#' @description
#' Orthanc is an open-source, lightweight DICOM server for healthcare and
#'   medical research. This `R6` generator creates a client to access
#'   Orthanc's RESTful API. More details about the Orthanc REST API can be
#'   found here: <https://orthanc.uclouvain.be/book/users/rest.html>.
#'
#'   The full documentation of the Orthanc API can be found here:
#'   <https://orthanc.uclouvain.be/api/>.
#'
#' @return An `Orthanc` instance.
#'
#' @importFrom R6 R6Class
#' @importFrom httr2 request req_perform req_url_path_append req_url_query
#'   req_headers req_cookies_set req_user_agent req_auth_basic req_method
#'   req_body_json req_body_file req_body_raw req_get_body_type
#'   req_perform_connection resp_content_type resp_body_json resp_body_html
#'   resp_body_string resp_body_raw resp_stream_is_complete resp_stream_raw
#' @importFrom glue glue
#'
#' @export
Orthanc <-
  R6::R6Class(
    classname = 'Orthanc',
    cloneable = FALSE,
    portable = FALSE,
    public = list(
      #' @field url URL for Orthanc REST API.
      url = NULL,

      #' @field api_version Orthanc API version.
      api_version = "1.12.10",

      #' @description
      #' Initialize a new Orthanc API Client
      #'
      #' @param url URL for Orthanc REST API.
      #' @param username Optional username for Basic HTTP authentication.
      #' @param password Optional password for Basic HTTP authentication.
      #' @param ... Not currently used.
      initialize = function(url, username = NULL, password = NULL, ...) {
        rlang::check_dots_empty()
        if (rlang::is_missing(url)) {
          self$url <- default_api_url()
        } else {
          self$url <- url
        }
        private$setup_credentials(username, password)
      },

      #' @description GET request with specified route
      #' @param route HTTP route.
      #' @param params Parameters for the HTTP request.
      #' @param headers Headers for the HTTP request.
      #' @param cookies Cookies for the HTTP request.
      #' @return Serialized response of the HTTP GET request.
      GET = function(route, params = NULL, headers = NULL, cookies = NULL) {
        req <- private$request_build(route, params, headers, cookies, "GET")
        res <- private$request_perform(req)
        res
      },

      #' @description DELETE to specified route
      #' @param route HTTP route.
      #' @param params Parameters for the HTTP request.
      #' @param headers Headers for the HTTP request.
      #' @param cookies Cookies for the HTTP request.
      #' @return Serialized response of the HTTP DELETE request.
      DELETE = function(route, params = NULL, headers = NULL, cookies = NULL) {
        req <- private$request_build(route, params, headers, cookies, "DELETE")
        res <- private$request_perform(req)
        res
      },

      #' @description POST to specified route
      #' @param route HTTP route.
      #' @param file DICOM file to be uploaded or a ZIP archive containing
      #'   DICOM files.
      #' @param json List to be converted to JSON for request body.
      #' @param data Raw data.
      #' @param params Parameters for the HTTP request.
      #' @param headers Headers for the HTTP request.
      #' @param cookies Cookies for the HTTP request.
      #' @return Serialized response of the HTTP POST request.
      POST = function(
        route,
        file = NULL,
        json = NULL,
        data = NULL,
        params = NULL,
        headers = NULL,
        cookies = NULL
      ) {
        req <- private$request_build(route, params, headers, cookies, "POST")
        req <- private$include_content(req, file, json, data)
        res <- private$request_perform(req)
        res
      },

      #' @description PUT to specified route
      #' @param route HTTP route.
      #' @param data Raw data.
      #' @param file DICOM file to be uploaded or a ZIP archive containing
      #'   DICOM files.
      #' @param json List to be converted to JSON for request body.
      #' @param params Parameters for the HTTP request.
      #' @param headers Headers for the HTTP request.
      #' @param cookies Cookies for the HTTP request.
      #' @return Serialized response of the HTTP PUT request.
      PUT = function(
        route,
        file = NULL,
        json = NULL,
        data = NULL,
        params = NULL,
        headers = NULL,
        cookies = NULL
      ) {
        req <- private$request_build(route, params, headers, cookies, "PUT")
        req <- private$include_content(req, file, json, data)
        res <- private$request_perform(req)
        res
      },

      #' @description Stream an HTTP response body and write to disk.
      #' @param method HTTP method.
      #' @param route HTTP route.
      #' @param params Parameters for the HTTP request.
      #' @param headers Headers for the HTTP request.
      #' @param cookies Cookies for the HTTP request.
      #' @return Serialized response of the HTTP GET request.
      stream = function(
        method,
        route,
        params = NULL,
        headers = NULL,
        cookies = NULL
      ) {
        req <- private$request_build(route, params, headers, cookies, method)
        private$request_perform_stream(req)
      },

      #' @description Print method for `Orthanc`.
      #' @param x Object to print.
      #' @param ... Further arguments passed to or from other methods.
      print = function(x, ...) {
        cat("<Orthanc API Client>")
      },

      #' @description Clear changes
      #'
      #' Clear the full history stored in the changes log
      #'
      #' @family Tracking changes
      #'
      #' @return Nothing, invisibly.
      delete_changes = function() {
        self$DELETE("/changes")
      },

      #' @description List changes
      #'
      #' Whenever Orthanc receives a new DICOM instance, this event is
      #'   recorded in the so-called _Changes Log_. This enables remote
      #'   scripts to react to the arrival of new DICOM resources. A typical
      #'   application is auto-routing, where an external script waits for
      #'   a new DICOM instance to arrive into Orthanc, then forward this
      #'   instance to another modality. Please note that, when resources
      #'   are deleted, their corresponding change entries are also removed
      #'   from the Changes Log, which helps ensuring that this log does not
      #'   grow indefinitely.
      #'
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Tracking changes
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - last (number): Request only the last change id (this
      #'     argument must be used alone)
      #'   - limit (number): Limit the number of results
      #'   - since (number): Show only the resources since the provided
      #'     index excluded
      #'   - to (number): Show only the resources till the provided
      #'     index included (only available if your DB backend supports
      #'     ExtendedChanges)
      #'   - type (string): Show only the changes of the provided
      #'     type (only available if your DB backend supports
      #'     ExtendedChanges). Multiple values can be provided and must
      #'     be separated by a ';'.
      #'
      #' @return The list of changes.
      get_changes = function(params = NULL) {
        self$GET("/changes", params = params)
      },

      #' @description Clear exports
      #'
      #' Clear the full history stored in the exports log
      #'
      #' @family Tracking changes
      #'
      #' @return Nothing, invisibly.
      delete_exports = function() {
        self$DELETE("/exports")
      },

      #' @description List exports
      #'
      #' For medical traceability, Orthanc can be configured to store
      #'   a log of all the resources that have been exported to remote
      #'   modalities. In auto-routing scenarios, it is important to
      #'   prevent this log to grow indefinitely as incoming instances are
      #'   routed. You can either disable this logging by setting the option
      #'   `LogExportedResources` to `FALSE` in the configuration file, or
      #'   periodically clear this log by `DELETE`-ing this URI. This route
      #'   might be removed in future versions of Orthanc.
      #'
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Tracking changes
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - limit (number): Limit the number of results
      #'   - since (number): Show only the resources since the provided
      #'     index
      #'
      #' @return The list of exports.
      get_exports = function(params = NULL) {
        self$GET("/exports", params = params)
      },

      #' @description List the available instances
      #'
      #' List the Orthanc identifiers of all the available DICOM instances
      #'
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, retrieve detailed information
      #'     about the individual resources, not only their Orthanc
      #'     identifiers
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - limit (number): Limit the number of results
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - response-content (string): Defines the content of
      #'     response for each returned resource. Allowed values are
      #'     `MainDicomTags`, `Metadata`, `Children`, `Parent`, `Labels`,
      #'     `Status`, `IsStable`, `IsProtected`, `Attachments`. If not
      #'     specified, Orthanc will return `MainDicomTags`, `Metadata`,
      #'     `Children`, `Parent`, `Labels`, `Status`, `IsStable`,
      #'     `IsProtected`.e.g: 'response-content=MainDicomTags;Children
      #'     (new in Orthanc 1.12.5 - overrides `expand`)
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - since (number): Show only the resources since the provided
      #'     index
      #'
      #' @return List containing either the Orthanc identifiers, or
      #'   detailed information about the reported instances (if `expand`
      #'   argument is provided).
      get_instances = function(params = NULL) {
        self$GET("/instances", params = params)
      },

      #' @description Upload DICOM instances
      #'
      #' Upload DICOM instances
      #'
      #' @param file (character) Path to file for request body. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #' Request body: DICOM file to be uploaded (application/dicom)
      #'   or ZIP archive containing DICOM files (new in Orthanc 1.8.2)
      #'   (application/zip).
      #'
      #' @return Information about the uploaded instance, or list of
      #'   information for each uploaded instance in the case of ZIP
      #'   archive.
      post_instances = function(file = NULL) {
        self$POST("/instances", file = file)
      },

      #' @description Delete some instance
      #'
      #' Delete the DICOM instance whose Orthanc identifier is provided in
      #'   the URL
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #'
      #' @family Instances
      #'
      #' @return Nothing, invisibly.
      delete_instances_id = function(id) {
        self$DELETE(glue::glue("/instances/{id}"))
      },

      #' @description Get information about some instance
      #'
      #' Get detailed information about the DICOM instance whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Information about the DICOM instance.
      get_instances_id = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}"), params = params)
      },

      #' @description Anonymize instance
      #'
      #' Download an anonymized version of the DICOM instance
      #'   whose Orthanc identifier is provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/anonymization.html#anonymization-of-a-single-instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - DicomVersion (character): Version of the DICOM standard to
      #'     be used for anonymization. Check out configuration option
      #'     `DeidentifyLogsDicomVersion` for possible values.
      #'   - Force (logical): Allow the modification of tags related to
      #'     DICOM identifiers, at the risk of breaking the DICOM model
      #'     of the real world
      #'   - Keep (list): List of DICOM tags whose value must not be
      #'     destroyed by the anonymization. Starting with Orthanc 1.9.4,
      #'     paths to subsequences can be provided using the same syntax
      #'     as the `dcmodify` command-line tool (wildcards are supported
      #'     as well).
      #'   - KeepLabels (logical): Keep the labels of all resources level
      #'     (defaults to `FALSE`)
      #'   - KeepPrivateTags (logical): Keep the private tags from the
      #'     DICOM instances (defaults to `FALSE`)
      #'   - KeepSource (logical): If set to `FALSE`, instructs Orthanc
      #'     to the remove original resources. By default, the original
      #'     resources are kept in Orthanc.
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Replace`
      #'   - Remove (list): List of additional tags to be removed from
      #'     the DICOM instances. Starting with Orthanc 1.9.4, paths to
      #'     subsequences can be provided using the same syntax as the
      #'     `dcmodify` command-line tool (wildcards are supported as
      #'     well).
      #'   - Replace (list): Associative array to change the value
      #'     of some DICOM tags in the DICOM instances. Starting with
      #'     Orthanc 1.9.4, paths to subsequences can be provided
      #'     using the same syntax as the `dcmodify` command-line tool
      #'     (wildcards are supported as well).
      #'   - Transcode (character): Transcode the DICOM
      #'     instances to the provided DICOM transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return The anonymized DICOM instance.
      post_instances_id_anonymize = function(id, json = NULL) {
        self$POST(glue::glue("/instances/{id}/anonymize"), json = json)
      },

      #' @description List attachments
      #'
      #' Get the list of attachments that are associated with the given
      #'   instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (string): If present, retrieve the attachments list and
      #'     their numerical ids
      #'
      #' @return List containing the names of the attachments.
      get_instances_id_attachments = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}/attachments"), params = params)
      },

      #' @description Delete attachment
      #'
      #' Delete an attachment associated with the given DICOM instance.
      #'   This call will fail if trying to delete a system attachment (i.e.
      #'   whose index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the attachment, to check if
      #'     its content has not changed and can be deleted. This header
      #'     is mandatory if `CheckRevisions` option is `TRUE`.
      #'
      #' @return Nothing, invisibly.
      delete_instances_id_attachments_name = function(
        id,
        name,
        headers = NULL
      ) {
        self$DELETE(
          glue::glue("/instances/{id}/attachments/{name}"),
          headers = headers
        )
      },

      #' @description List operations on attachments
      #'
      #' Get the list of the operations that are available for attachments
      #'   associated with the given instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Other
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return List of the available operations.
      get_instances_id_attachments_name = function(id, name, headers = NULL) {
        self$GET(
          glue::glue("/instances/{id}/attachments/{name}"),
          headers = headers
        )
      },

      #' @description Set attachment
      #'
      #' Attach a file to the given DICOM instance. This call will fail
      #'   if trying to modify a system attachment (i.e. whose index is <
      #'   1024).
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #' Request body: Binary data containing the attachment
      #'   (application/octet-stream).
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the attachment, if this is
      #'     not the first time this attachment is set.
      #'
      #' @return Empty JSON object in the case of a success.
      put_instances_id_attachments_name = function(
        id,
        name,
        headers = NULL,
        data = NULL
      ) {
        self$PUT(
          glue::glue("/instances/{id}/attachments/{name}"),
          headers = headers,
          data = data
        )
      },

      #' @description Compress attachment
      #'
      #' Change the compression scheme that is used to store an
      #'   attachment.
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Instances
      #'
      #' @return Nothing, invisibly.
      post_instances_id_attachments_name_compress = function(id, name) {
        self$POST(glue::glue("/instances/{id}/attachments/{name}/compress"))
      },

      #' @description Get attachment (no decompression)
      #'
      #' Get the (binary) content of one attachment associated with
      #'   the given instance. The attachment will not be decompressed if
      #'   `StorageCompression` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Content-Range (string): Optional content range to access
      #'     part of the attachment (new in Orthanc 1.12.5)
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'
      #' @return The attachment.
      get_instances_id_attachments_name_compressed_data = function(
        id,
        name,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/attachments/{name}/compressed-data"),
          params = params,
          headers = headers
        )
      },

      #' @description Get MD5 of attachment on disk
      #'
      #' Get the MD5 hash of one attachment associated with the given
      #'   instance, as stored on the disk. This is different from `.../md5`
      #'   iff `EnableStorage` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The MD5 of the attachment, as stored on the disk.
      get_instances_id_attachments_name_compressed_md5 = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/attachments/{name}/compressed-md5"),
          headers = headers
        )
      },

      #' @description Get size of attachment on disk
      #'
      #' Get the size of one attachment associated with the given
      #'   instance, as stored on the disk. This is different from
      #'   `.../size` iff `EnableStorage` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The size of the attachment, as stored on the disk.
      get_instances_id_attachments_name_compressed_size = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/attachments/{name}/compressed-size"),
          headers = headers
        )
      },

      #' @description Get attachment
      #'
      #' Get the (binary) content of one attachment associated with the
      #'   given instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Content-Range (string): Optional content range to access
      #'     part of the attachment (new in Orthanc 1.12.5)
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'
      #' @return The attachment.
      get_instances_id_attachments_name_data = function(
        id,
        name,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/attachments/{name}/data"),
          params = params,
          headers = headers
        )
      },

      #' @description Get info about the attachment
      #'
      #' Get all the information about the attachment associated with the
      #'   given instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return JSON object containing the information about the
      #'   attachment.
      get_instances_id_attachments_name_info = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/attachments/{name}/info"),
          headers = headers
        )
      },

      #' @description Is attachment compressed?
      #'
      #' Test whether the attachment has been stored as a compressed file
      #'   on the disk.
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return `0` if the attachment was stored uncompressed, `1` if it
      #'   was compressed.
      get_instances_id_attachments_name_is_compressed = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/attachments/{name}/is-compressed"),
          headers = headers
        )
      },

      #' @description Get MD5 of attachment
      #'
      #' Get the MD5 hash of one attachment associated with the given
      #'   instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The MD5 of the attachment.
      get_instances_id_attachments_name_md5 = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/attachments/{name}/md5"),
          headers = headers
        )
      },

      #' @description Get size of attachment
      #'
      #' Get the size of one attachment associated with the given instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The size of the attachment.
      get_instances_id_attachments_name_size = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/attachments/{name}/size"),
          headers = headers
        )
      },

      #' @description Uncompress attachment
      #'
      #' Change the compression scheme that is used to store an
      #'   attachment.
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Instances
      #'
      #' @return Nothing, invisibly.
      post_instances_id_attachments_name_uncompress = function(id, name) {
        self$POST(glue::glue("/instances/{id}/attachments/{name}/uncompress"))
      },

      #' @description Verify attachment
      #'
      #' Verify that the attachment is not corrupted, by validating its
      #'   MD5 hash
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Instances
      #'
      #' @return On success, a valid JSON object is returned.
      post_instances_id_attachments_name_verify_md5 = function(id, name) {
        self$POST(glue::glue("/instances/{id}/attachments/{name}/verify-md5"))
      },

      #' @description Get raw tag
      #'
      #' Get the raw content of one DICOM tag in the hierarchy of DICOM
      #'   dataset
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param path (character) Path to the DICOM tag. This is the
      #'   interleaving of one DICOM tag, possibly followed by an index
      #'   for sequences. Sequences are accessible as, for instance,
      #'   `/0008-1140/1/0008-1150`.
      #'
      #' @family Instances
      #'
      #' @return The raw value of the tag of intereset (binary data, whose
      #'   memory layout depends on the underlying transfer syntax), or
      #'   List containing the list of available tags if accessing a
      #'   dataset.
      get_instances_id_content_path = function(id, path) {
        self$GET(glue::glue("/instances/{id}/content/{path}"))
      },

      #' @description Write DICOM onto filesystem
      #'
      #' Write the DICOM file onto the filesystem where Orthanc is
      #'   running. This is insecure for Orthanc servers that are remotely
      #'   accessible since one could overwrite any system file. Since
      #'   Orthanc 1.12.0, this route is disabled by default, but can be
      #'   enabled using the `RestApiWriteToFileSystemEnabled` configuration
      #'   option.
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #' Request body: Target path on the filesystem (text/plain).
      #'
      #' @return Nothing, invisibly.
      post_instances_id_export = function(id, data = NULL) {
        self$POST(glue::glue("/instances/{id}/export"), data = data)
      },

      #' @description Download DICOM
      #'
      #' Download one DICOM instance
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): This HTTP header can be set to retrieve the
      #'     DICOM instance in DICOMweb format
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - lossy-quality (number): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - transcode (string): If present, the DICOM file
      #'     will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return The DICOM instance.
      get_instances_id_file = function(id, params = NULL, headers = NULL) {
        self$GET(
          glue::glue("/instances/{id}/file"),
          params = params,
          headers = headers
        )
      },

      #' @description List available frames
      #'
      #' List the frames that are available in the DICOM instance of
      #'   interest
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #'
      #' @family Instances
      #'
      #' @return The list of the indices of the available frames.
      get_instances_id_frames = function(id) {
        self$GET(glue::glue("/instances/{id}/frames"))
      },

      #' @description List operations
      #'
      #' List the available operations under URI
      #'   `/instances/{id}/frames/{frame}/`
      #'
      #' @param frame (character) .
      #' @param id (character) .
      #'
      #' @family Other
      #'
      #' @return List of the available operations.
      get_instances_id_frames_frame = function(id, frame) {
        self$GET(glue::glue("/instances/{id}/frames/{frame}"))
      },

      #' @description Decode a frame (int16)
      #'
      #' Decode one frame of interest from the given DICOM instance.
      #'   Pixels of grayscale images are truncated to the \[-32768,32767\]
      #'   range. Negative values must be interpreted according to two's
      #'   complement.
      #'
      #' @param frame (numeric) Index of the frame (starts at `0`).
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): Format of the resulting image.
      #'     Can be `image/png` (default), `image/jpeg` or
      #'     `image/x-portable-arbitrarymap`
      #'
      #' Optional query parameters (`params`):
      #'   - quality (number): Quality for JPEG images (between 1 and
      #'     100, defaults to 90)
      #'   - returnUnsupportedImage (boolean): Returns an unsupported.png
      #'     placeholder image if unable to provide the image instead
      #'     of returning a 415 HTTP error (value is true if option is
      #'     present)
      #'
      #' @return JPEG image.
      get_instances_id_frames_frame_image_int16 = function(
        id,
        frame,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/frames/{frame}/image-int16"),
          params = params,
          headers = headers
        )
      },

      #' @description Decode a frame (uint16)
      #'
      #' Decode one frame of interest from the given DICOM instance.
      #'   Pixels of grayscale images are truncated to the \[0,65535\] range.
      #'
      #' @param frame (numeric) Index of the frame (starts at `0`).
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): Format of the resulting image.
      #'     Can be `image/png` (default), `image/jpeg` or
      #'     `image/x-portable-arbitrarymap`
      #'
      #' Optional query parameters (`params`):
      #'   - quality (number): Quality for JPEG images (between 1 and
      #'     100, defaults to 90)
      #'   - returnUnsupportedImage (boolean): Returns an unsupported.png
      #'     placeholder image if unable to provide the image instead
      #'     of returning a 415 HTTP error (value is true if option is
      #'     present)
      #'
      #' @return JPEG image.
      get_instances_id_frames_frame_image_uint16 = function(
        id,
        frame,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/frames/{frame}/image-uint16"),
          params = params,
          headers = headers
        )
      },

      #' @description Decode a frame (uint8)
      #'
      #' Decode one frame of interest from the given DICOM instance.
      #'   Pixels of grayscale images are truncated to the \[0,255\] range.
      #'
      #' @param frame (numeric) Index of the frame (starts at `0`).
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): Format of the resulting image.
      #'     Can be `image/png` (default), `image/jpeg` or
      #'     `image/x-portable-arbitrarymap`
      #'
      #' Optional query parameters (`params`):
      #'   - quality (number): Quality for JPEG images (between 1 and
      #'     100, defaults to 90)
      #'   - returnUnsupportedImage (boolean): Returns an unsupported.png
      #'     placeholder image if unable to provide the image instead
      #'     of returning a 415 HTTP error (value is true if option is
      #'     present)
      #'
      #' @return JPEG image.
      get_instances_id_frames_frame_image_uint8 = function(
        id,
        frame,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/frames/{frame}/image-uint8"),
          params = params,
          headers = headers
        )
      },

      #' @description Decode frame for Matlab
      #'
      #' Decode one frame of interest from the given DICOM instance, and
      #'   export this frame as a Octave/Matlab matrix to be imported with
      #'   `eval()`: https://orthanc.uclouvain.be/book/faq/matlab.html
      #'
      #' @param frame (numeric) Index of the frame (starts at `0`).
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #'
      #' @family Instances
      #'
      #' @return Octave/Matlab matrix.
      get_instances_id_frames_frame_matlab = function(id, frame) {
        self$GET(glue::glue("/instances/{id}/frames/{frame}/matlab"))
      },

      #' @description Decode frame for numpy
      #'
      #' Decode one frame of interest from the given DICOM instance,
      #'   for use with numpy in Python. The numpy array has 3 dimensions:
      #'   (height, width, color channel).
      #'
      #' @param frame (numeric) Index of the frame (starts at `0`).
      #' @param id (character) Orthanc identifier of the DICOM resource of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - compress (boolean): Compress the file as `.npz`
      #'   - rescale (boolean): On grayscale images, apply the rescaling
      #'     and return floating-point values
      #'
      #' @return Numpy file:
      #'   https://numpy.org/devdocs/reference/generated/numpy.lib.format.html.
      get_instances_id_frames_frame_numpy = function(id, frame, params = NULL) {
        self$GET(
          glue::glue("/instances/{id}/frames/{frame}/numpy"),
          params = params
        )
      },

      #' @description Decode a frame (preview)
      #'
      #' Decode one frame of interest from the given DICOM instance. The
      #'   full dynamic range of grayscale images is rescaled to the \[0,255\]
      #'   range.
      #'
      #' @param frame (numeric) Index of the frame (starts at `0`).
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): Format of the resulting image.
      #'     Can be `image/png` (default), `image/jpeg` or
      #'     `image/x-portable-arbitrarymap`
      #'
      #' Optional query parameters (`params`):
      #'   - quality (number): Quality for JPEG images (between 1 and
      #'     100, defaults to 90)
      #'   - returnUnsupportedImage (boolean): Returns an unsupported.png
      #'     placeholder image if unable to provide the image instead
      #'     of returning a 415 HTTP error (value is true if option is
      #'     present)
      #'
      #' @return JPEG image.
      get_instances_id_frames_frame_preview = function(
        id,
        frame,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/frames/{frame}/preview"),
          params = params,
          headers = headers
        )
      },

      #' @description Access raw frame
      #'
      #' Access the raw content of one individual frame of the DICOM
      #'   instance of interest, bypassing image decoding. This is notably
      #'   useful to access the source files in compressed transfer
      #'   syntaxes.
      #'
      #' @param frame (numeric) Index of the frame (starts at `0`).
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #'
      #' @family Instances
      #'
      #' @return The raw frame.
      get_instances_id_frames_frame_raw = function(id, frame) {
        self$GET(glue::glue("/instances/{id}/frames/{frame}/raw"))
      },

      #' @description Access raw frame (compressed)
      #'
      #' Access the raw content of one individual frame of the DICOM
      #'   instance of interest, bypassing image decoding. This is notably
      #'   useful to access the source files in compressed transfer
      #'   syntaxes. The image is compressed using gzip
      #'
      #' @param frame (numeric) Index of the frame (starts at `0`).
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #'
      #' @family Instances
      #'
      #' @return The raw frame, compressed using gzip.
      get_instances_id_frames_frame_raw.gz = function(id, frame) {
        self$GET(glue::glue("/instances/{id}/frames/{frame}/raw.gz"))
      },

      #' @description Render a frame
      #'
      #' Render one frame of interest from the given DICOM instance.
      #'   This function takes scaling into account (`RescaleSlope` and
      #'   `RescaleIntercept` tags), as well as the default windowing stored
      #'   in the DICOM file (`WindowCenter` and `WindowWidth`tags), and
      #'   can be used to resize the resulting image. Color images are not
      #'   affected by windowing.
      #'
      #' @param frame (numeric) Index of the frame (starts at `0`).
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): Format of the resulting image.
      #'     Can be `image/png` (default), `image/jpeg` or
      #'     `image/x-portable-arbitrarymap`
      #'
      #' Optional query parameters (`params`):
      #'   - height (number): Height of the resized image
      #'   - quality (number): Quality for JPEG images (between 1 and
      #'     100, defaults to 90)
      #'   - returnUnsupportedImage (boolean): Returns an unsupported.png
      #'     placeholder image if unable to provide the image instead
      #'     of returning a 415 HTTP error (value is true if option is
      #'     present)
      #'   - smooth (boolean): Whether to smooth image on resize
      #'   - width (number): Width of the resized image
      #'   - window-center (number): Windowing center
      #'   - window-width (number): Windowing width
      #'
      #' @return JPEG image.
      get_instances_id_frames_frame_rendered = function(
        id,
        frame,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/frames/{frame}/rendered"),
          params = params,
          headers = headers
        )
      },

      #' @description Get DICOM meta-header
      #'
      #' Get the DICOM tags in the meta-header of the DICOM instance. By
      #'   default, the `full` format is used, which combines hexadecimal
      #'   tags with human-readable description.
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return JSON object containing the DICOM tags and their
      #'   associated value.
      get_instances_id_header = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}/header"), params = params)
      },

      #' @description Decode an image (int16)
      #'
      #' Decode the first frame of the given DICOM instance. Pixels
      #'   of grayscale images are truncated to the \[-32768,32767\]
      #'   range. Negative values must be interpreted according to two's
      #'   complement.
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): Format of the resulting image.
      #'     Can be `image/png` (default), `image/jpeg` or
      #'     `image/x-portable-arbitrarymap`
      #'
      #' Optional query parameters (`params`):
      #'   - quality (number): Quality for JPEG images (between 1 and
      #'     100, defaults to 90)
      #'   - returnUnsupportedImage (boolean): Returns an unsupported.png
      #'     placeholder image if unable to provide the image instead
      #'     of returning a 415 HTTP error (value is true if option is
      #'     present)
      #'
      #' @return JPEG image.
      get_instances_id_image_int16 = function(
        id,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/image-int16"),
          params = params,
          headers = headers
        )
      },

      #' @description Decode an image (uint16)
      #'
      #' Decode the first frame of the given DICOM instance. Pixels of
      #'   grayscale images are truncated to the \[0,65535\] range.
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): Format of the resulting image.
      #'     Can be `image/png` (default), `image/jpeg` or
      #'     `image/x-portable-arbitrarymap`
      #'
      #' Optional query parameters (`params`):
      #'   - quality (number): Quality for JPEG images (between 1 and
      #'     100, defaults to 90)
      #'   - returnUnsupportedImage (boolean): Returns an unsupported.png
      #'     placeholder image if unable to provide the image instead
      #'     of returning a 415 HTTP error (value is true if option is
      #'     present)
      #'
      #' @return JPEG image.
      get_instances_id_image_uint16 = function(
        id,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/image-uint16"),
          params = params,
          headers = headers
        )
      },

      #' @description Decode an image (uint8)
      #'
      #' Decode the first frame of the given DICOM instance. Pixels of
      #'   grayscale images are truncated to the \[0,255\] range.
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): Format of the resulting image.
      #'     Can be `image/png` (default), `image/jpeg` or
      #'     `image/x-portable-arbitrarymap`
      #'
      #' Optional query parameters (`params`):
      #'   - quality (number): Quality for JPEG images (between 1 and
      #'     100, defaults to 90)
      #'   - returnUnsupportedImage (boolean): Returns an unsupported.png
      #'     placeholder image if unable to provide the image instead
      #'     of returning a 415 HTTP error (value is true if option is
      #'     present)
      #'
      #' @return JPEG image.
      get_instances_id_image_uint8 = function(
        id,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/instances/{id}/image-uint8"),
          params = params,
          headers = headers
        )
      },

      #' @description List labels
      #'
      #' Get the labels that are associated with the given instance (new
      #'   in Orthanc 1.12.0)
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #'
      #' @family Instances
      #'
      #' @return List containing the names of the labels.
      get_instances_id_labels = function(id) {
        self$GET(glue::glue("/instances/{id}/labels"))
      },

      #' @description Remove label
      #'
      #' Remove a label associated with a instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param label (character) The label to be removed.
      #'
      #' @family Instances
      #'
      #' @return Nothing, invisibly.
      delete_instances_id_labels_label = function(id, label) {
        self$DELETE(glue::glue("/instances/{id}/labels/{label}"))
      },

      #' @description Test label
      #'
      #' Test whether the instance is associated with the given label
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param label (character) The label of interest.
      #'
      #' @family Instances
      #'
      #' @return Empty string is returned in the case of presence, error
      #'   404 in the case of absence.
      get_instances_id_labels_label = function(id, label) {
        self$GET(glue::glue("/instances/{id}/labels/{label}"))
      },

      #' @description Add label
      #'
      #' Associate a label with a instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param label (character) The label to be added.
      #'
      #' @family Instances
      #'
      #' @return Nothing, invisibly.
      put_instances_id_labels_label = function(id, label) {
        self$PUT(glue::glue("/instances/{id}/labels/{label}"))
      },

      #' @description Decode frame for Matlab
      #'
      #' Decode the first frame of the given DICOM instance., and
      #'   export this frame as a Octave/Matlab matrix to be imported with
      #'   `eval()`: https://orthanc.uclouvain.be/book/faq/matlab.html
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #'
      #' @family Instances
      #'
      #' @return Octave/Matlab matrix.
      get_instances_id_matlab = function(id) {
        self$GET(glue::glue("/instances/{id}/matlab"))
      },

      #' @description List metadata
      #'
      #' Get the list of metadata that are associated with the given
      #'   instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, also retrieve the value of the
      #'     individual metadata
      #'   - numeric (string): If present, use the numeric identifier of
      #'     the metadata instead of its symbolic name
      #'
      #' @return List containing the names of the available
      #'   metadata, or List mapping metadata to their
      #'   values (if `expand` argument is provided).
      get_instances_id_metadata = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}/metadata"), params = params)
      },

      #' @description Delete metadata
      #'
      #' Delete some metadata associated with the given DICOM instance.
      #'   This call will fail if trying to delete a system metadata (i.e.
      #'   whose index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the metadata, to check if its
      #'     content has not changed and can be deleted. This header is
      #'     mandatory if `CheckRevisions` option is `TRUE`.
      #'
      #' @return Nothing, invisibly.
      delete_instances_id_metadata_name = function(id, name, headers = NULL) {
        self$DELETE(
          glue::glue("/instances/{id}/metadata/{name}"),
          headers = headers
        )
      },

      #' @description Get metadata
      #'
      #' Get the value of a metadata that is associated with the given
      #'   instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the metadata,
      #'     to check if its content has changed
      #'
      #' @return Value of the metadata.
      get_instances_id_metadata_name = function(id, name, headers = NULL) {
        self$GET(
          glue::glue("/instances/{id}/metadata/{name}"),
          headers = headers
        )
      },

      #' @description Set metadata
      #'
      #' Set the value of some metadata in the given DICOM instance. This
      #'   call will fail if trying to modify a system metadata (i.e. whose
      #'   index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #' Request body: String value of the metadata (text/plain).
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the metadata, if this is not
      #'     the first time this metadata is set.
      #'
      #' @return Nothing, invisibly.
      put_instances_id_metadata_name = function(
        id,
        name,
        headers = NULL,
        data = NULL
      ) {
        self$PUT(
          glue::glue("/instances/{id}/metadata/{name}"),
          headers = headers,
          data = data
        )
      },

      #' @description Modify instance
      #'
      #' Download a modified version of the DICOM instance
      #'   whose Orthanc identifier is provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/anonymization.html#modification-of-a-single-instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Force (logical): Allow the modification of tags related to
      #'     DICOM identifiers, at the risk of breaking the DICOM model
      #'     of the real world
      #'   - Keep (list): Keep the original value of the specified
      #'     tags, to be chosen among the `StudyInstanceUID`,
      #'     `SeriesInstanceUID` and `SOPInstanceUID` tags. Avoid this
      #'     feature as much as possible, as this breaks the DICOM model
      #'     of the real world.
      #'   - KeepSource (logical): If set to `FALSE`, instructs Orthanc
      #'     to the remove original resources. By default, the original
      #'     resources are kept in Orthanc.
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Replace`
      #'   - Remove (list): List of tags that must be removed from the
      #'     DICOM instances. Starting with Orthanc 1.9.4, paths to
      #'     subsequences can be provided using the same syntax as the
      #'     `dcmodify` command-line tool (wildcards are supported as
      #'     well).
      #'   - RemovePrivateTags (logical): Remove the private tags from
      #'     the DICOM instances (defaults to `FALSE`)
      #'   - Replace (list): Associative array to change the value
      #'     of some DICOM tags in the DICOM instances. Starting with
      #'     Orthanc 1.9.4, paths to subsequences can be provided
      #'     using the same syntax as the `dcmodify` command-line tool
      #'     (wildcards are supported as well).
      #'   - Transcode (character): Transcode the DICOM
      #'     instances to the provided DICOM transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return The modified DICOM instance.
      post_instances_id_modify = function(id, json = NULL) {
        self$POST(glue::glue("/instances/{id}/modify"), json = json)
      },

      #' @description Get instance module
      #'
      #' Get the instance module of the DICOM instance whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - ignore-length (array): Also include the DICOM tags that are
      #'     provided in this list, even if their associated value is
      #'     long
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return Information about the DICOM instance.
      get_instances_id_module = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}/module"), params = params)
      },

      #' @description Decode instance for numpy
      #'
      #' Decode the given DICOM instance, for use with numpy in Python.
      #'   The numpy array has 4 dimensions: (frame, height, width, color
      #'   channel).
      #'
      #' @param id (character) Orthanc identifier of the DICOM resource of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - compress (boolean): Compress the file as `.npz`
      #'   - rescale (boolean): On grayscale images, apply the rescaling
      #'     and return floating-point values
      #'
      #' @return Numpy file:
      #'   https://numpy.org/devdocs/reference/generated/numpy.lib.format.html.
      get_instances_id_numpy = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}/numpy"), params = params)
      },

      #' @description Get parent patient
      #'
      #' Get detailed information about the parent patient of the DICOM
      #'   instance whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Information about the parent DICOM patient.
      get_instances_id_patient = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}/patient"), params = params)
      },

      #' @description Get embedded PDF
      #'
      #' Get the PDF file that is embedded in one DICOM instance. If the
      #'   DICOM instance doesn't contain the `EncapsulatedDocument` tag or
      #'   if the `MIMETypeOfEncapsulatedDocument` tag doesn't correspond to
      #'   the PDF type, a `404` HTTP error is raised.
      #'
      #' @param id (character) Orthanc identifier of the instance
      #'   interest.
      #'
      #' @family Instances
      #'
      #' @return PDF file.
      get_instances_id_pdf = function(id) {
        self$GET(glue::glue("/instances/{id}/pdf"))
      },

      #' @description Decode an image (preview)
      #'
      #' Decode the first frame of the given DICOM instance. The full
      #'   dynamic range of grayscale images is rescaled to the \[0,255\]
      #'   range.
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): Format of the resulting image.
      #'     Can be `image/png` (default), `image/jpeg` or
      #'     `image/x-portable-arbitrarymap`
      #'
      #' Optional query parameters (`params`):
      #'   - quality (number): Quality for JPEG images (between 1 and
      #'     100, defaults to 90)
      #'   - returnUnsupportedImage (boolean): Returns an unsupported.png
      #'     placeholder image if unable to provide the image instead
      #'     of returning a 415 HTTP error (value is true if option is
      #'     present)
      #'
      #' @return JPEG image.
      get_instances_id_preview = function(id, params = NULL, headers = NULL) {
        self$GET(
          glue::glue("/instances/{id}/preview"),
          params = params,
          headers = headers
        )
      },

      #' @description Reconstruct tags & optionally files of instance
      #'
      #' Reconstruct the main DICOM tags in DB of the instance whose
      #'   Orthanc identifier is provided in the URL. This is useful
      #'   if child studies/series/instances have inconsistent values
      #'   for higher-level tags, in order to force Orthanc to use the
      #'   value from the resource of interest. Beware that this is a
      #'   time-consuming operation, as all the children DICOM instances
      #'   will be parsed again, and the Orthanc index will be updated
      #'   accordingly.
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - LimitToThisLevelMainDicomTags (logical): Only reconstruct
      #'     this level MainDicomTags by re-reading them from a random
      #'     child instance of the resource. This option is much faster
      #'     than a full reconstruct and is useful e.g. if you have
      #'     modified the 'ExtraMainDicomTags' at the Study level to
      #'     optimize the speed of some C-Find. 'false' by default. (New
      #'     in Orthanc 1.12.4)
      #'   - ReconstructFiles (logical): Also reconstruct the
      #'     files of the resources (e.g: apply IngestTranscoding,
      #'     StorageCompression). 'false' by default. (New in Orthanc
      #'     1.11.0)
      #'
      #' @return Nothing, invisibly.
      post_instances_id_reconstruct = function(id, json = NULL) {
        self$POST(glue::glue("/instances/{id}/reconstruct"), json = json)
      },

      #' @description Render an image
      #'
      #' Render the first frame of the given DICOM instance. This function
      #'   takes scaling into account (`RescaleSlope` and `RescaleIntercept`
      #'   tags), as well as the default windowing stored in the DICOM file
      #'   (`WindowCenter` and `WindowWidth`tags), and can be used to resize
      #'   the resulting image. Color images are not affected by windowing.
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Accept (string): Format of the resulting image.
      #'     Can be `image/png` (default), `image/jpeg` or
      #'     `image/x-portable-arbitrarymap`
      #'
      #' Optional query parameters (`params`):
      #'   - height (number): Height of the resized image
      #'   - quality (number): Quality for JPEG images (between 1 and
      #'     100, defaults to 90)
      #'   - returnUnsupportedImage (boolean): Returns an unsupported.png
      #'     placeholder image if unable to provide the image instead
      #'     of returning a 415 HTTP error (value is true if option is
      #'     present)
      #'   - smooth (boolean): Whether to smooth image on resize
      #'   - width (number): Width of the resized image
      #'   - window-center (number): Windowing center
      #'   - window-width (number): Windowing width
      #'
      #' @return JPEG image.
      get_instances_id_rendered = function(id, params = NULL, headers = NULL) {
        self$GET(
          glue::glue("/instances/{id}/rendered"),
          params = params,
          headers = headers
        )
      },

      #' @description Get parent series
      #'
      #' Get detailed information about the parent series of the DICOM
      #'   instance whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Information about the parent DICOM series.
      get_instances_id_series = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}/series"), params = params)
      },

      #' @description Get human-readable tags
      #'
      #' Get the DICOM tags in human-readable format (same as the
      #'   `/instances/{id}/tags?simplify` route)
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - ignore-length (array): Also include the DICOM tags that are
      #'     provided in this list, even if their associated value is
      #'     long
      #'   - whole (boolean): Whether to read the whole DICOM file
      #'     from the storage area (new in Orthanc 1.12.4). If set to
      #'     "false" (default value), the DICOM file is read until the
      #'     pixel data tag (7fe0,0010) to optimize access to storage.
      #'     Setting the option to "true" provides access to the DICOM
      #'     tags stored after the pixel data tag.
      #'
      #' @return JSON object containing the DICOM tags and their
      #'   associated value.
      get_instances_id_simplified_tags = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}/simplified-tags"), params = params)
      },

      #' @description Get instance statistics
      #'
      #' Get statistics about the given instance
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #'
      #' @family Instances
      #'
      #' @return Nothing, invisibly.
      get_instances_id_statistics = function(id) {
        self$GET(glue::glue("/instances/{id}/statistics"))
      },

      #' @description Get parent study
      #'
      #' Get detailed information about the parent study of the DICOM
      #'   instance whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Information about the parent DICOM study.
      get_instances_id_study = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}/study"), params = params)
      },

      #' @description Get DICOM tags
      #'
      #' Get the DICOM tags in the specified format. By default, the
      #'   `full` format is used, which combines hexadecimal tags with
      #'   human-readable description.
      #'
      #' @param id (character) Orthanc identifier of the DICOM instance of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Instances
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - ignore-length (array): Also include the DICOM tags that are
      #'     provided in this list, even if their associated value is
      #'     long
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'   - whole (boolean): Whether to read the whole DICOM file
      #'     from the storage area (new in Orthanc 1.12.4). If set to
      #'     "false" (default value), the DICOM file is read until the
      #'     pixel data tag (7fe0,0010) to optimize access to storage.
      #'     Setting the option to "true" provides access to the DICOM
      #'     tags stored after the pixel data tag.
      #'
      #' @return JSON object containing the DICOM tags and their
      #'   associated value.
      get_instances_id_tags = function(id, params = NULL) {
        self$GET(glue::glue("/instances/{id}/tags"), params = params)
      },

      #' @description List jobs
      #'
      #' List all the available jobs
      #'
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Jobs
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, retrieve detailed information
      #'     about the individual jobs
      #'
      #' @return List containing either the jobs identifiers, or
      #'   detailed information about the reported jobs (if `expand`
      #'   argument is provided).
      get_jobs = function(params = NULL) {
        self$GET("/jobs", params = params)
      },

      #' @description Delete a job from history
      #'
      #' Delete the job from the jobs history. Only a completed job can
      #'   be deleted. If the job has not run or not completed yet, you
      #'   must cancel it first. If the job has outputs, all outputs will be
      #'   deleted as well.
      #'
      #' @param id (character) Identifier of the job of interest.
      #'
      #' @family Jobs
      #'
      #' @return Nothing, invisibly.
      delete_jobs_id = function(id) {
        self$DELETE(glue::glue("/jobs/{id}"))
      },

      #' @description Get job
      #'
      #' Retrieve detailed information about the job
      #'   whose identifier is provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs
      #'
      #' @param id (character) Identifier of the job of interest.
      #'
      #' @family Jobs
      #'
      #' @return JSON object detailing the job.
      get_jobs_id = function(id) {
        self$GET(glue::glue("/jobs/{id}"))
      },

      #' @description Cancel job
      #'
      #' Cancel the job whose identifier is provided in the
      #'   URL. Check out the Orthanc Book for more information
      #'   about the state machine applicable to jobs:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs
      #'
      #' @param id (character) Identifier of the job of interest.
      #'
      #' @family Jobs
      #'
      #' @return Empty JSON object in the case of a success.
      post_jobs_id_cancel = function(id) {
        self$POST(glue::glue("/jobs/{id}/cancel"))
      },

      #' @description Pause job
      #'
      #' Pause the job whose identifier is provided in the
      #'   URL. Check out the Orthanc Book for more information
      #'   about the state machine applicable to jobs:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs
      #'
      #' @param id (character) Identifier of the job of interest.
      #'
      #' @family Jobs
      #'
      #' @return Empty JSON object in the case of a success.
      post_jobs_id_pause = function(id) {
        self$POST(glue::glue("/jobs/{id}/pause"))
      },

      #' @description Resubmit job
      #'
      #' Resubmit the job whose identifier is provided in the
      #'   URL. Check out the Orthanc Book for more information
      #'   about the state machine applicable to jobs:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs
      #'
      #' @param id (character) Identifier of the job of interest.
      #'
      #' @family Jobs
      #'
      #' @return Empty JSON object in the case of a success.
      post_jobs_id_resubmit = function(id) {
        self$POST(glue::glue("/jobs/{id}/resubmit"))
      },

      #' @description Resume job
      #'
      #' Resume the job whose identifier is provided in the
      #'   URL. Check out the Orthanc Book for more information
      #'   about the state machine applicable to jobs:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs
      #'
      #' @param id (character) Identifier of the job of interest.
      #'
      #' @family Jobs
      #'
      #' @return Empty JSON object in the case of a success.
      post_jobs_id_resume = function(id) {
        self$POST(glue::glue("/jobs/{id}/resume"))
      },

      #' @description Delete a job output
      #'
      #' Delete the output produced by a job. As of Orthanc 1.12.1, only
      #'   the jobs that generate a DICOMDIR media or a ZIP archive provide
      #'   such an output (with `key` equals to `archive`).
      #'
      #' @param id (character) Identifier of the job of interest.
      #' @param key (character) Name of the output of interest.
      #'
      #' @family Jobs
      #'
      #' @return Nothing, invisibly.
      delete_jobs_id_key = function(id, key) {
        self$DELETE(glue::glue("/jobs/{id}/{key}"))
      },

      #' @description Get job output
      #'
      #' Retrieve some output produced by a job. As of Orthanc 1.8.2, only
      #'   the jobs that generate a DICOMDIR media or a ZIP archive provide
      #'   such an output (with `key` equals to `archive`).
      #'
      #' @param id (character) Identifier of the job of interest.
      #' @param key (character) Name of the output of interest.
      #'
      #' @family Jobs
      #'
      #' @return Content of the output of the job.
      get_jobs_id_key = function(id, key) {
        self$GET(glue::glue("/jobs/{id}/{key}"))
      },

      #' @description List DICOM modalities
      #'
      #' List all the DICOM modalities that are known to Orthanc. This
      #'   corresponds either to the content of the `DicomModalities`
      #'   configuration option, or to the information stored in the
      #'   database if `DicomModalitiesInDatabase` is `TRUE`.
      #'
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, retrieve detailed information
      #'     about the individual DICOM modalities
      #'
      #' @return List containing either the identifiers of the
      #'   modalities, or detailed information about the modalities (if
      #'   `expand` argument is provided).
      get_modalities = function(params = NULL) {
        self$GET("/modalities", params = params)
      },

      #' @description Delete DICOM modality
      #'
      #' Delete one DICOM modality. This change is permanent iff.
      #'   `DicomModalitiesInDatabase` is `TRUE`, otherwise it is lost at
      #'   the next restart of Orthanc.
      #'
      #' @param id (character) Identifier of the DICOM modality of
      #'   interest.
      #'
      #' @family Networking
      #'
      #' @return Nothing, invisibly.
      delete_modalities_id = function(id) {
        self$DELETE(glue::glue("/modalities/{id}"))
      },

      #' @description List operations on modality
      #'
      #' List the operations that are available for a DICOM modality.
      #'
      #' @param id (character) Identifier of the DICOM modality of
      #'   interest.
      #'
      #' @family Networking
      #'
      #' @return List of the available operations.
      get_modalities_id = function(id) {
        self$GET(glue::glue("/modalities/{id}"))
      },

      #' @description Update DICOM modality
      #'
      #' Define a new DICOM modality, or update an existing one. This
      #'   change is permanent iff. `DicomModalitiesInDatabase` is `TRUE`,
      #'   otherwise it is lost at the next restart of Orthanc.
      #'
      #' @param id (character) Identifier of the new/updated DICOM
      #'   modality.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - AET (character): AET of the remote DICOM modality
      #'   - AllowEcho (logical): Whether to accept C-ECHO SCU commands
      #'     issued by the remote modality
      #'   - AllowFind (logical): Whether to accept C-FIND SCU commands
      #'     issued by the remote modality
      #'   - AllowFindWorklist (logical): Whether to accept C-FIND SCU
      #'     commands for worklists issued by the remote modality
      #'   - AllowGet (logical): Whether to accept C-GET SCU commands
      #'     issued by the remote modality
      #'   - AllowMove (logical): Whether to accept C-MOVE SCU commands
      #'     issued by the remote modality
      #'   - AllowStorageCommitment (logical): Whether to accept storage
      #'     commitment requests issued by the remote modality
      #'   - AllowStore (logical): Whether to accept C-STORE SCU commands
      #'     issued by the remote modality
      #'   - AllowTranscoding (logical): Whether to allow transcoding for
      #'     operations initiated by this modality. This option applies
      #'     to Orthanc C-GET SCP and to Orthanc C-STORE SCU. It only has
      #'     an effect if the global option `EnableTranscoding` is set to
      #'     `TRUE`.
      #'   - Host (character): Host address of the remote DICOM modality
      #'     (typically, an IP address)
      #'   - LocalAet (character): Whether to override the default
      #'     DicomAet in the SCU connection initiated by Orthanc to this
      #'     modality
      #'   - Manufacturer (character): Manufacturer of the remote DICOM
      #'     modality (check configuration option `DicomModalities` for
      #'     possible values
      #'   - Port (numeric): TCP port of the remote DICOM modality
      #'   - Timeout (numeric): Whether to override the default
      #'     DicomScuTimeout in the SCU connection initiated by Orthanc
      #'     to this modality
      #'   - UseDicomTls (logical): Whether to use DICOM TLS in the SCU
      #'     connection initiated by Orthanc (new in Orthanc 1.9.0)
      #'
      #' @return Nothing, invisibly.
      put_modalities_id = function(id, json = NULL) {
        self$PUT(glue::glue("/modalities/{id}"), json = json)
      },

      #' @description Get modality configuration
      #'
      #' Get detailed information about the configuration of some DICOM
      #'   modality
      #'
      #' @param id (character) Identifier of the modality of interest.
      #'
      #' @family Networking
      #'
      #' @return Configuration of the modality.
      get_modalities_id_configuration = function(id) {
        self$GET(glue::glue("/modalities/{id}/configuration"))
      },

      #' @description Trigger C-ECHO SCU
      #'
      #' Trigger C-ECHO SCU command against the DICOM
      #'   modality whose identifier is provided in URL:
      #'   https://orthanc.uclouvain.be/book/users/rest.html#performing-c-echo
      #'
      #' @param id (character) Identifier of the modality of interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - CheckFind (logical): Issue a dummy C-FIND command after the
      #'     C-GET SCU, in order to check whether the remote modality
      #'     knows about Orthanc. This field defaults to the value of the
      #'     `DicomEchoChecksFind` configuration option. New in Orthanc
      #'     1.8.1.
      #'   - Timeout (numeric): Timeout for the C-ECHO command, in
      #'     seconds
      #'
      #' @return Nothing, invisibly.
      post_modalities_id_echo = function(id, json = NULL) {
        self$POST(glue::glue("/modalities/{id}/echo"), json = json)
      },

      #' @description C-FIND SCU for worklist
      #'
      #' Trigger C-FIND SCU command against the remote worklists of the
      #'   DICOM modality whose identifier is provided in URL
      #'
      #' @param id (character) Identifier of the modality of interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Full (logical): If set to `TRUE`, report the DICOM tags
      #'     in full format (tags indexed by their hexadecimal format,
      #'     associated with their symbolic name and their value)
      #'   - Query (list): Associative array containing the filter on the
      #'     values of the DICOM tags
      #'   - Short (logical): If set to `TRUE`, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return List describing the DICOM tags of the matching
      #'   worklists.
      post_modalities_id_find_worklist = function(id, json = NULL) {
        self$POST(glue::glue("/modalities/{id}/find-worklist"), json = json)
      },

      #' @description Trigger C-GET SCU
      #'
      #' Start a C-GET SCU command as a job, in order to retrieve DICOM
      #'   resources from a remote DICOM modality whose identifier is
      #'   provided in the URL:
      #'
      #' @param id (character) Identifier of the modality of interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - Level (character): Level of the query (`Patient`, `Study`,
      #'     `Series` or `Instance`)
      #'   - LocalAet (character): Local AET that is used for this
      #'     commands, defaults to `DicomAet` configuration option.
      #'     Ignored if `DicomModalities` already sets `LocalAet` for
      #'     this modality.
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - Resources (list): List of queries identifying all the DICOM
      #'     resources to be sent. Usage of wildcards is prohibited and
      #'     the query shall only contain DICOM ID tags. Additionally,
      #'     you may provide SOPClassesInStudy to limit the scope
      #'     of the DICOM negotiation to certain SOPClassUID or to
      #'     present uncommon SOPClassUID during the DICOM negotiation.
      #'     By default, Orhanc will propose the most 120 common
      #'     SOPClassUIDs.
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Timeout (numeric): Timeout for the C-GET command, in seconds
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return Nothing, invisibly.
      post_modalities_id_get = function(id, json = NULL) {
        self$POST(glue::glue("/modalities/{id}/get"), json = json)
      },

      #' @description Trigger C-MOVE SCU
      #'
      #' Start a C-MOVE SCU command as a job, in order to drive the
      #'   execution of a sequence of C-STORE commands by some remote
      #'   DICOM modality whose identifier is provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/rest.html#performing-c-move
      #'
      #' @param id (character) Identifier of the modality of interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - Level (character): Level of the query (`Patient`, `Study`,
      #'     `Series` or `Instance`)
      #'   - LocalAet (character): Local AET that is used for this
      #'     commands, defaults to `DicomAet` configuration option.
      #'     Ignored if `DicomModalities` already sets `LocalAet` for
      #'     this modality.
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - Resources (list): List of queries identifying all the DICOM
      #'     resources to be sent
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - TargetAet (character): Target AET that will be used by
      #'     the remote DICOM modality as a target for its C-STORE SCU
      #'     commands, defaults to `DicomAet` configuration option in
      #'     order to do a simple query/retrieve
      #'   - Timeout (numeric): Timeout for the C-MOVE command, in
      #'     seconds
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return Nothing, invisibly.
      post_modalities_id_move = function(id, json = NULL) {
        self$POST(glue::glue("/modalities/{id}/move"), json = json)
      },

      #' @description Trigger C-FIND SCU
      #'
      #' Trigger C-FIND SCU command against the DICOM
      #'   modality whose identifier is provided in URL:
      #'   https://orthanc.uclouvain.be/book/users/rest.html#performing-query-retrieve-c-find-and-find-with-rest
      #'
      #' @param id (character) Identifier of the modality of interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Level (character): Level of the query (`Patient`, `Study`,
      #'     `Series` or `Instance`)
      #'   - LocalAet (character): Local AET that is used for this
      #'     commands, defaults to `DicomAet` configuration option.
      #'     Ignored if `DicomModalities` already sets `LocalAet` for
      #'     this modality.
      #'   - Normalize (logical): Whether to normalize the query, i.e.
      #'     whether to wipe out from the query, the DICOM tags that are
      #'     not applicable for the query-retrieve level of interest
      #'   - Query (list): Associative array containing the filter on the
      #'     values of the DICOM tags
      #'   - Timeout (numeric): Timeout for the C-FIND command and
      #'     subsequent C-MOVE retrievals, in seconds (new in Orthanc
      #'     1.9.1)
      #'
      #' @return Nothing, invisibly.
      post_modalities_id_query = function(id, json = NULL) {
        self$POST(glue::glue("/modalities/{id}/query"), json = json)
      },

      #' @description Trigger storage commitment request
      #'
      #' Trigger a storage commitment request to some remote
      #'   DICOM modality whose identifier is provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/storage-commitment.html#storage-commitment-scu
      #'
      #' @param id (character) Identifier of the modality of interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - DicomInstances (list): List of DICOM resources that are not
      #'     necessarily stored within Orthanc, but that must be checked
      #'     by storage commitment. This is a list of JSON objects that
      #'     must contain the `SOPClassUID` and `SOPInstanceUID` fields.
      #'   - Resources (list): List of the Orthanc identifiers of the
      #'     DICOM resources to be checked by storage commitment
      #'   - Timeout (numeric): Timeout for the storage commitment
      #'     command (new in Orthanc 1.9.1)
      #'
      #' @return Nothing, invisibly.
      post_modalities_id_storage_commitment = function(id, json = NULL) {
        self$POST(
          glue::glue("/modalities/{id}/storage-commitment"),
          json = json
        )
      },

      #' @description Trigger C-STORE SCU
      #'
      #' Start a C-STORE SCU command as a job, in order to send
      #'   DICOM resources stored locally to some remote DICOM
      #'   modality whose identifier is provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/rest.html#rest-store-scu
      #'
      #' @param id (character) Identifier of the modality of interest.
      #' @param json (list) Named-list for request body. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - CalledAet (character): Called AET that is used for this
      #'     commands, defaults to `AET` configuration option. Allows you
      #'     to overwrite the destination AET for a specific operation.
      #'   - Host (character): Host that is used for this commands,
      #'     defaults to `Host` configuration option. Allows you to
      #'     overwrite the destination host for a specific operation.
      #'   - LocalAet (character): Local AET that is used for this
      #'     commands, defaults to `DicomAet` configuration option.
      #'     Ignored if `DicomModalities` already sets `LocalAet` for
      #'     this modality.
      #'   - MoveOriginatorAet (character): Move originator AET that is
      #'     used for this commands, in order to fake a C-MOVE SCU
      #'   - MoveOriginatorID (numeric): Move originator ID that is used
      #'     for this commands, in order to fake a C-MOVE SCU
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Port (numeric): Port that is used for this command, defaults
      #'     to `Port` configuration option. Allows you to overwrite the
      #'     destination port for a specific operation.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - Resources (list): List of the Orthanc identifiers of all the
      #'     DICOM resources to be sent
      #'   - StorageCommitment (logical): Whether to
      #'     chain C-STORE with DICOM storage commitment
      #'     to validate the success of the transmission:
      #'     https://orthanc.uclouvain.be/book/users/storage-commitment.html#chaining-c-store-with-storage-commitment
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Timeout (numeric): Timeout for the C-STORE command, in
      #'     seconds
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #' Request body: The Orthanc identifier of one resource to be
      #'   sent (text/plain).
      #'
      #' @return Nothing, invisibly.
      post_modalities_id_store = function(id, json = NULL, data = NULL) {
        self$POST(
          glue::glue("/modalities/{id}/store"),
          json = json,
          data = data
        )
      },

      #' @description Straight C-STORE SCU
      #'
      #' Synchronously send the DICOM instance in the POST body to the
      #'   remote DICOM modality whose identifier is provided in URL,
      #'   without having to first store it locally within Orthanc. This
      #'   is an alternative to command-line tools such as `storescu` from
      #'   DCMTK or dcm4che.
      #'
      #' @param id (character) Identifier of the modality of interest.
      #' @param file (character) Path to file for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body: DICOM instance to be sent (application/dicom).
      #'
      #' @return Nothing, invisibly.
      post_modalities_id_store_straight = function(id, file = NULL) {
        self$POST(glue::glue("/modalities/{id}/store-straight"), file = file)
      },

      #' @description List the available patients
      #'
      #' List the Orthanc identifiers of all the available DICOM patients
      #'
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, retrieve detailed information
      #'     about the individual resources, not only their Orthanc
      #'     identifiers
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - limit (number): Limit the number of results
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - response-content (string): Defines the content of
      #'     response for each returned resource. Allowed values are
      #'     `MainDicomTags`, `Metadata`, `Children`, `Parent`, `Labels`,
      #'     `Status`, `IsStable`, `IsProtected`, `Attachments`. If not
      #'     specified, Orthanc will return `MainDicomTags`, `Metadata`,
      #'     `Children`, `Parent`, `Labels`, `Status`, `IsStable`,
      #'     `IsProtected`.e.g: 'response-content=MainDicomTags;Children
      #'     (new in Orthanc 1.12.5 - overrides `expand`)
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - since (number): Show only the resources since the provided
      #'     index
      #'
      #' @return List containing either the Orthanc identifiers, or
      #'   detailed information about the reported patients (if `expand`
      #'   argument is provided).
      get_patients = function(params = NULL) {
        self$GET("/patients", params = params)
      },

      #' @description Delete some patient
      #'
      #' Delete the DICOM patient whose Orthanc identifier is provided in
      #'   the URL
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #'
      #' @family Patients
      #'
      #' @return Nothing, invisibly.
      delete_patients_id = function(id) {
        self$DELETE(glue::glue("/patients/{id}"))
      },

      #' @description Get information about some patient
      #'
      #' Get detailed information about the DICOM patient whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Information about the DICOM patient.
      get_patients_id = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}"), params = params)
      },

      #' @description Anonymize patient
      #'
      #' Start a job that will anonymize all the DICOM instances
      #'   within the patient whose identifier is provided in the URL.
      #'   The modified DICOM instances will be stored into a brand new
      #'   patient, whose Orthanc identifiers will be returned by the job.
      #'   https://orthanc.uclouvain.be/book/users/anonymization.html#anonymization-of-patients-studies-or-series
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - DicomVersion (character): Version of the DICOM standard to
      #'     be used for anonymization. Check out configuration option
      #'     `DeidentifyLogsDicomVersion` for possible values.
      #'   - Force (logical): Allow the modification of tags related to
      #'     DICOM identifiers, at the risk of breaking the DICOM model
      #'     of the real world
      #'   - Keep (list): List of DICOM tags whose value must not be
      #'     destroyed by the anonymization. Starting with Orthanc 1.9.4,
      #'     paths to subsequences can be provided using the same syntax
      #'     as the `dcmodify` command-line tool (wildcards are supported
      #'     as well).
      #'   - KeepLabels (logical): Keep the labels of all resources level
      #'     (defaults to `FALSE`)
      #'   - KeepPrivateTags (logical): Keep the private tags from the
      #'     DICOM instances (defaults to `FALSE`)
      #'   - KeepSource (logical): If set to `FALSE`, instructs Orthanc
      #'     to the remove original resources. By default, the original
      #'     resources are kept in Orthanc.
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Replace`
      #'   - Remove (list): List of additional tags to be removed from
      #'     the DICOM instances. Starting with Orthanc 1.9.4, paths to
      #'     subsequences can be provided using the same syntax as the
      #'     `dcmodify` command-line tool (wildcards are supported as
      #'     well).
      #'   - Replace (list): Associative array to change the value
      #'     of some DICOM tags in the DICOM instances. Starting with
      #'     Orthanc 1.9.4, paths to subsequences can be provided
      #'     using the same syntax as the `dcmodify` command-line tool
      #'     (wildcards are supported as well).
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Transcode (character): Transcode the DICOM
      #'     instances to the provided DICOM transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return Nothing, invisibly.
      post_patients_id_anonymize = function(id, json = NULL) {
        self$POST(glue::glue("/patients/{id}/anonymize"), json = json)
      },

      #' @description Create ZIP archive
      #'
      #' Synchronously create a ZIP archive containing the DICOM patient
      #'   whose Orthanc identifier is provided in the URL. This flavor
      #'   is synchronous, which might *not* be desirable to archive large
      #'   amount of data, as it might lead to network timeouts. Prefer the
      #'   asynchronous version using `POST` method.
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - lossy-quality (number): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - transcode (string): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return ZIP file containing the archive.
      get_patients_id_archive = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}/archive"), params = params)
      },

      #' @description Create ZIP archive
      #'
      #' Create a ZIP archive containing the DICOM patient whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, create the archive in
      #'     asynchronous mode, which means that a job is submitted to
      #'     create the archive in background.
      #'   - Filename (character): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'   - Synchronous (logical): If `TRUE`, create the archive
      #'     in synchronous mode, which means that the HTTP answer
      #'     will directly contain the ZIP file. This is the default,
      #'     easy behavior. However, if global configuration option
      #'     "SynchronousZipStream" is set to "false", asynchronous
      #'     transfers should be preferred for large amount of data, as
      #'     the creation of the temporary file might lead to network
      #'     timeouts.
      #'   - Transcode (character): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): In asynchronous mode, user data that will
      #'     be attached to the job.
      #'
      #' @return In asynchronous mode, information about the
      #'   job that has been submitted to generate the archive:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs.
      post_patients_id_archive = function(id, json = NULL) {
        self$POST(glue::glue("/patients/{id}/archive"), json = json)
      },

      #' @description List attachments
      #'
      #' Get the list of attachments that are associated with the given
      #'   patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (string): If present, retrieve the attachments list and
      #'     their numerical ids
      #'
      #' @return List containing the names of the attachments.
      get_patients_id_attachments = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}/attachments"), params = params)
      },

      #' @description Delete attachment
      #'
      #' Delete an attachment associated with the given DICOM patient.
      #'   This call will fail if trying to delete a system attachment (i.e.
      #'   whose index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the attachment, to check if
      #'     its content has not changed and can be deleted. This header
      #'     is mandatory if `CheckRevisions` option is `TRUE`.
      #'
      #' @return Nothing, invisibly.
      delete_patients_id_attachments_name = function(id, name, headers = NULL) {
        self$DELETE(
          glue::glue("/patients/{id}/attachments/{name}"),
          headers = headers
        )
      },

      #' @description List operations on attachments
      #'
      #' Get the list of the operations that are available for attachments
      #'   associated with the given patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Other
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return List of the available operations.
      get_patients_id_attachments_name = function(id, name, headers = NULL) {
        self$GET(
          glue::glue("/patients/{id}/attachments/{name}"),
          headers = headers
        )
      },

      #' @description Set attachment
      #'
      #' Attach a file to the given DICOM patient. This call will fail
      #'   if trying to modify a system attachment (i.e. whose index is <
      #'   1024).
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #' Request body: Binary data containing the attachment
      #'   (application/octet-stream).
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the attachment, if this is
      #'     not the first time this attachment is set.
      #'
      #' @return Empty JSON object in the case of a success.
      put_patients_id_attachments_name = function(
        id,
        name,
        headers = NULL,
        data = NULL
      ) {
        self$PUT(
          glue::glue("/patients/{id}/attachments/{name}"),
          headers = headers,
          data = data
        )
      },

      #' @description Compress attachment
      #'
      #' Change the compression scheme that is used to store an
      #'   attachment.
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Patients
      #'
      #' @return Nothing, invisibly.
      post_patients_id_attachments_name_compress = function(id, name) {
        self$POST(glue::glue("/patients/{id}/attachments/{name}/compress"))
      },

      #' @description Get attachment (no decompression)
      #'
      #' Get the (binary) content of one attachment associated with
      #'   the given patient. The attachment will not be decompressed if
      #'   `StorageCompression` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Content-Range (string): Optional content range to access
      #'     part of the attachment (new in Orthanc 1.12.5)
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'
      #' @return The attachment.
      get_patients_id_attachments_name_compressed_data = function(
        id,
        name,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/patients/{id}/attachments/{name}/compressed-data"),
          params = params,
          headers = headers
        )
      },

      #' @description Get MD5 of attachment on disk
      #'
      #' Get the MD5 hash of one attachment associated with the given
      #'   patient, as stored on the disk. This is different from `.../md5`
      #'   iff `EnableStorage` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The MD5 of the attachment, as stored on the disk.
      get_patients_id_attachments_name_compressed_md5 = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/patients/{id}/attachments/{name}/compressed-md5"),
          headers = headers
        )
      },

      #' @description Get size of attachment on disk
      #'
      #' Get the size of one attachment associated with the given patient,
      #'   as stored on the disk. This is different from `.../size` iff
      #'   `EnableStorage` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The size of the attachment, as stored on the disk.
      get_patients_id_attachments_name_compressed_size = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/patients/{id}/attachments/{name}/compressed-size"),
          headers = headers
        )
      },

      #' @description Get attachment
      #'
      #' Get the (binary) content of one attachment associated with the
      #'   given patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Content-Range (string): Optional content range to access
      #'     part of the attachment (new in Orthanc 1.12.5)
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'
      #' @return The attachment.
      get_patients_id_attachments_name_data = function(
        id,
        name,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/patients/{id}/attachments/{name}/data"),
          params = params,
          headers = headers
        )
      },

      #' @description Get info about the attachment
      #'
      #' Get all the information about the attachment associated with the
      #'   given patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return JSON object containing the information about the
      #'   attachment.
      get_patients_id_attachments_name_info = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/patients/{id}/attachments/{name}/info"),
          headers = headers
        )
      },

      #' @description Is attachment compressed?
      #'
      #' Test whether the attachment has been stored as a compressed file
      #'   on the disk.
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return `0` if the attachment was stored uncompressed, `1` if it
      #'   was compressed.
      get_patients_id_attachments_name_is_compressed = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/patients/{id}/attachments/{name}/is-compressed"),
          headers = headers
        )
      },

      #' @description Get MD5 of attachment
      #'
      #' Get the MD5 hash of one attachment associated with the given
      #'   patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The MD5 of the attachment.
      get_patients_id_attachments_name_md5 = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/patients/{id}/attachments/{name}/md5"),
          headers = headers
        )
      },

      #' @description Get size of attachment
      #'
      #' Get the size of one attachment associated with the given patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The size of the attachment.
      get_patients_id_attachments_name_size = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/patients/{id}/attachments/{name}/size"),
          headers = headers
        )
      },

      #' @description Uncompress attachment
      #'
      #' Change the compression scheme that is used to store an
      #'   attachment.
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Patients
      #'
      #' @return Nothing, invisibly.
      post_patients_id_attachments_name_uncompress = function(id, name) {
        self$POST(glue::glue("/patients/{id}/attachments/{name}/uncompress"))
      },

      #' @description Verify attachment
      #'
      #' Verify that the attachment is not corrupted, by validating its
      #'   MD5 hash
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Patients
      #'
      #' @return On success, a valid JSON object is returned.
      post_patients_id_attachments_name_verify_md5 = function(id, name) {
        self$POST(glue::glue("/patients/{id}/attachments/{name}/verify-md5"))
      },

      #' @description Get child instances
      #'
      #' Get detailed information about the child instances of the DICOM
      #'   patient whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If false or missing, only retrieve the list
      #'     of child instances
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return List containing information about the child DICOM
      #'   instances.
      get_patients_id_instances = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}/instances"), params = params)
      },

      #' @description Get tags of instances
      #'
      #' Get the tags of all the child instances of the DICOM patient
      #'   whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - ignore-length (array): Also include the DICOM tags that are
      #'     provided in this list, even if their associated value is
      #'     long
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return JSON object associating the Orthanc identifiers of the
      #'   instances, with the values of their DICOM tags.
      get_patients_id_instances_tags = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}/instances-tags"), params = params)
      },

      #' @description List labels
      #'
      #' Get the labels that are associated with the given patient (new in
      #'   Orthanc 1.12.0)
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #'
      #' @family Patients
      #'
      #' @return List containing the names of the labels.
      get_patients_id_labels = function(id) {
        self$GET(glue::glue("/patients/{id}/labels"))
      },

      #' @description Remove label
      #'
      #' Remove a label associated with a patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param label (character) The label to be removed.
      #'
      #' @family Patients
      #'
      #' @return Nothing, invisibly.
      delete_patients_id_labels_label = function(id, label) {
        self$DELETE(glue::glue("/patients/{id}/labels/{label}"))
      },

      #' @description Test label
      #'
      #' Test whether the patient is associated with the given label
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param label (character) The label of interest.
      #'
      #' @family Patients
      #'
      #' @return Empty string is returned in the case of presence, error
      #'   404 in the case of absence.
      get_patients_id_labels_label = function(id, label) {
        self$GET(glue::glue("/patients/{id}/labels/{label}"))
      },

      #' @description Add label
      #'
      #' Associate a label with a patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param label (character) The label to be added.
      #'
      #' @family Patients
      #'
      #' @return Nothing, invisibly.
      put_patients_id_labels_label = function(id, label) {
        self$PUT(glue::glue("/patients/{id}/labels/{label}"))
      },

      #' @description Create DICOMDIR media
      #'
      #' Synchronously create a DICOMDIR media containing the DICOM
      #'   patient whose Orthanc identifier is provided in the URL. This
      #'   flavor is synchronous, which might *not* be desirable to archive
      #'   large amount of data, as it might lead to network timeouts.
      #'   Prefer the asynchronous version using `POST` method.
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - extended (string): If present, will include additional
      #'     tags such as `SeriesDescription`, leading to a so-called
      #'     *extended DICOMDIR*
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - lossy-quality (number): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - transcode (string): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return ZIP file containing the archive.
      get_patients_id_media = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}/media"), params = params)
      },

      #' @description Create DICOMDIR media
      #'
      #' Create a DICOMDIR media containing the DICOM patient whose
      #'   Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, create the archive in
      #'     asynchronous mode, which means that a job is submitted to
      #'     create the archive in background.
      #'   - Extended (logical): If `TRUE`, will include additional
      #'     tags such as `SeriesDescription`, leading to a so-called
      #'     *extended DICOMDIR*. Default value is `FALSE`.
      #'   - Filename (character): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'   - Synchronous (logical): If `TRUE`, create the archive
      #'     in synchronous mode, which means that the HTTP answer
      #'     will directly contain the ZIP file. This is the default,
      #'     easy behavior. However, if global configuration option
      #'     "SynchronousZipStream" is set to "false", asynchronous
      #'     transfers should be preferred for large amount of data, as
      #'     the creation of the temporary file might lead to network
      #'     timeouts.
      #'   - Transcode (character): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): In asynchronous mode, user data that will
      #'     be attached to the job.
      #'
      #' @return In asynchronous mode, information about the
      #'   job that has been submitted to generate the archive:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs.
      post_patients_id_media = function(id, json = NULL) {
        self$POST(glue::glue("/patients/{id}/media"), json = json)
      },

      #' @description List metadata
      #'
      #' Get the list of metadata that are associated with the given
      #'   patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, also retrieve the value of the
      #'     individual metadata
      #'   - numeric (string): If present, use the numeric identifier of
      #'     the metadata instead of its symbolic name
      #'
      #' @return List containing the names of the available
      #'   metadata, or List mapping metadata to their
      #'   values (if `expand` argument is provided).
      get_patients_id_metadata = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}/metadata"), params = params)
      },

      #' @description Delete metadata
      #'
      #' Delete some metadata associated with the given DICOM patient.
      #'   This call will fail if trying to delete a system metadata (i.e.
      #'   whose index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the metadata, to check if its
      #'     content has not changed and can be deleted. This header is
      #'     mandatory if `CheckRevisions` option is `TRUE`.
      #'
      #' @return Nothing, invisibly.
      delete_patients_id_metadata_name = function(id, name, headers = NULL) {
        self$DELETE(
          glue::glue("/patients/{id}/metadata/{name}"),
          headers = headers
        )
      },

      #' @description Get metadata
      #'
      #' Get the value of a metadata that is associated with the given
      #'   patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the metadata,
      #'     to check if its content has changed
      #'
      #' @return Value of the metadata.
      get_patients_id_metadata_name = function(id, name, headers = NULL) {
        self$GET(
          glue::glue("/patients/{id}/metadata/{name}"),
          headers = headers
        )
      },

      #' @description Set metadata
      #'
      #' Set the value of some metadata in the given DICOM patient. This
      #'   call will fail if trying to modify a system metadata (i.e. whose
      #'   index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #' Request body: String value of the metadata (text/plain).
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the metadata, if this is not
      #'     the first time this metadata is set.
      #'
      #' @return Nothing, invisibly.
      put_patients_id_metadata_name = function(
        id,
        name,
        headers = NULL,
        data = NULL
      ) {
        self$PUT(
          glue::glue("/patients/{id}/metadata/{name}"),
          headers = headers,
          data = data
        )
      },

      #' @description Modify patient
      #'
      #' Start a job that will modify all the DICOM instances within
      #'   the patient whose identifier is provided in the URL. The
      #'   modified DICOM instances will be stored into a brand new
      #'   patient, whose Orthanc identifiers will be returned by the job.
      #'   https://orthanc.uclouvain.be/book/users/anonymization.html#modification-of-studies-or-series
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - Force (logical): Allow the modification of tags related to
      #'     DICOM identifiers, at the risk of breaking the DICOM model
      #'     of the real world
      #'   - Keep (list): Keep the original value of the specified
      #'     tags, to be chosen among the `StudyInstanceUID`,
      #'     `SeriesInstanceUID` and `SOPInstanceUID` tags. Avoid this
      #'     feature as much as possible, as this breaks the DICOM model
      #'     of the real world.
      #'   - KeepSource (logical): If set to `FALSE`, instructs Orthanc
      #'     to the remove original resources. By default, the original
      #'     resources are kept in Orthanc.
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Replace`
      #'   - Remove (list): List of tags that must be removed from the
      #'     DICOM instances. Starting with Orthanc 1.9.4, paths to
      #'     subsequences can be provided using the same syntax as the
      #'     `dcmodify` command-line tool (wildcards are supported as
      #'     well).
      #'   - RemovePrivateTags (logical): Remove the private tags from
      #'     the DICOM instances (defaults to `FALSE`)
      #'   - Replace (list): Associative array to change the value
      #'     of some DICOM tags in the DICOM instances. Starting with
      #'     Orthanc 1.9.4, paths to subsequences can be provided
      #'     using the same syntax as the `dcmodify` command-line tool
      #'     (wildcards are supported as well).
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Transcode (character): Transcode the DICOM
      #'     instances to the provided DICOM transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return Nothing, invisibly.
      post_patients_id_modify = function(id, json = NULL) {
        self$POST(glue::glue("/patients/{id}/modify"), json = json)
      },

      #' @description Get patient module
      #'
      #' Get the patient module of the DICOM patient whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - ignore-length (array): Also include the DICOM tags that are
      #'     provided in this list, even if their associated value is
      #'     long
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return Information about the DICOM patient.
      get_patients_id_module = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}/module"), params = params)
      },

      #' @description Is the patient protected against recycling?
      #'
      #' Is the patient protected against recycling?
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #'
      #' @family Patients
      #'
      #' @return `1` if protected, `0` if not protected.
      get_patients_id_protected = function(id) {
        self$GET(glue::glue("/patients/{id}/protected"))
      },

      #' @description Protect/Unprotect a patient against recycling
      #'
      #' Protects a patient by sending `1` or `TRUE` in the
      #'   payload request. Unprotects a patient by sending
      #'   `0` or `FALSE` in the payload requests. More info:
      #'   https://orthanc.uclouvain.be/book/faq/features.html#recycling-protection
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param json (list) List for request body.
      #'
      #' @family Patients
      #'
      #' @return Nothing, invisibly.
      put_patients_id_protected = function(id, json) {
        self$PUT(glue::glue("/patients/{id}/protected"), json)
      },

      #' @description Reconstruct tags & optionally files of patient
      #'
      #' Reconstruct the main DICOM tags in DB of the patient whose
      #'   Orthanc identifier is provided in the URL. This is useful
      #'   if child studies/series/instances have inconsistent values
      #'   for higher-level tags, in order to force Orthanc to use the
      #'   value from the resource of interest. Beware that this is a
      #'   time-consuming operation, as all the children DICOM instances
      #'   will be parsed again, and the Orthanc index will be updated
      #'   accordingly.
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - LimitToThisLevelMainDicomTags (logical): Only reconstruct
      #'     this level MainDicomTags by re-reading them from a random
      #'     child instance of the resource. This option is much faster
      #'     than a full reconstruct and is useful e.g. if you have
      #'     modified the 'ExtraMainDicomTags' at the Study level to
      #'     optimize the speed of some C-Find. 'false' by default. (New
      #'     in Orthanc 1.12.4)
      #'   - ReconstructFiles (logical): Also reconstruct the
      #'     files of the resources (e.g: apply IngestTranscoding,
      #'     StorageCompression). 'false' by default. (New in Orthanc
      #'     1.11.0)
      #'
      #' @return Nothing, invisibly.
      post_patients_id_reconstruct = function(id, json = NULL) {
        self$POST(glue::glue("/patients/{id}/reconstruct"), json = json)
      },

      #' @description Get child series
      #'
      #' Get detailed information about the child series of the DICOM
      #'   patient whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If false or missing, only retrieve the list
      #'     of child series
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return List containing information about the child DICOM
      #'   series.
      get_patients_id_series = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}/series"), params = params)
      },

      #' @description Get shared tags
      #'
      #' Extract the DICOM tags whose value is constant across all the
      #'   child instances of the DICOM patient whose Orthanc identifier is
      #'   provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return JSON object containing the values of the DICOM tags.
      get_patients_id_shared_tags = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}/shared-tags"), params = params)
      },

      #' @description Get patient statistics
      #'
      #' Get statistics about the given patient
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #'
      #' @family Patients
      #'
      #' @return Nothing, invisibly.
      get_patients_id_statistics = function(id) {
        self$GET(glue::glue("/patients/{id}/statistics"))
      },

      #' @description Get child studies
      #'
      #' Get detailed information about the child studies of the DICOM
      #'   patient whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the patient of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Patients
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If false or missing, only retrieve the list
      #'     of child studies
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return List containing information about the child DICOM
      #'   studies.
      get_patients_id_studies = function(id, params = NULL) {
        self$GET(glue::glue("/patients/{id}/studies"), params = params)
      },

      #' @description List Orthanc peers
      #'
      #' List all the Orthanc peers that are known to Orthanc. This
      #'   corresponds either to the content of the `OrthancPeers`
      #'   configuration option, or to the information stored in the
      #'   database if `OrthancPeersInDatabase` is `TRUE`.
      #'
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, retrieve detailed information
      #'     about the individual Orthanc peers
      #'
      #' @return List containing either the identifiers of the
      #'   peers, or detailed information about the peers (if `expand`
      #'   argument is provided).
      get_peers = function(params = NULL) {
        self$GET("/peers", params = params)
      },

      #' @description Delete Orthanc peer
      #'
      #' Delete one Orthanc peer. This change is permanent iff.
      #'   `OrthancPeersInDatabase` is `TRUE`, otherwise it is lost at the
      #'   next restart of Orthanc.
      #'
      #' @param id (character) Identifier of the Orthanc peer of interest.
      #'
      #' @family Networking
      #'
      #' @return Nothing, invisibly.
      delete_peers_id = function(id) {
        self$DELETE(glue::glue("/peers/{id}"))
      },

      #' @description List operations on peer
      #'
      #' List the operations that are available for an Orthanc peer.
      #'
      #' @param id (character) Identifier of the peer of interest.
      #'
      #' @family Networking
      #'
      #' @return List of the available operations.
      get_peers_id = function(id) {
        self$GET(glue::glue("/peers/{id}"))
      },

      #' @description Update Orthanc peer
      #'
      #' Define a new Orthanc peer, or update an existing one. This change
      #'   is permanent iff. `OrthancPeersInDatabase` is `TRUE`, otherwise
      #'   it is lost at the next restart of Orthanc.
      #'
      #' @param id (character) Identifier of the new/updated Orthanc peer.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - CertificateFile (character): SSL certificate for the HTTPS
      #'     connections
      #'   - CertificateKeyFile (character): Key file for the SSL
      #'     certificate for the HTTPS connections
      #'   - CertificateKeyPassword (character): Key password for the SSL
      #'     certificate for the HTTPS connections
      #'   - HttpHeaders (list): HTTP headers to be used for the
      #'     connections to the remote peer
      #'   - Password (character): Password for the credentials
      #'   - URL (character): URL of the root of the REST API of the
      #'     remote Orthanc peer, for instance `http://localhost:8042/`
      #'   - Username (character): Username for the credentials
      #'
      #' @return Nothing, invisibly.
      put_peers_id = function(id, json = NULL) {
        self$PUT(glue::glue("/peers/{id}"), json = json)
      },

      #' @description Get peer configuration
      #'
      #' Get detailed information about the configuration of some Orthanc
      #'   peer
      #'
      #' @param id (character) Identifier of the peer of interest.
      #'
      #' @family Networking
      #'
      #' @return Configuration of the peer.
      get_peers_id_configuration = function(id) {
        self$GET(glue::glue("/peers/{id}/configuration"))
      },

      #' @description Send to Orthanc peer
      #'
      #' Send DICOM resources stored locally to some remote
      #'   Orthanc peer whose identifier is provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/rest.html#sending-one-resource
      #'
      #' @param id (character) Identifier of the modality of interest.
      #' @param json (list) Named-list for request body. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - Compress (logical): Whether to compress the DICOM instances
      #'     using gzip before the actual sending
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - Resources (list): List of the Orthanc identifiers of all the
      #'     DICOM resources to be sent
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Transcode (character): Transcode to the provided DICOM
      #'     transfer syntax before the actual sending
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #' Request body: The Orthanc identifier of one resource to be
      #'   sent (text/plain).
      #'
      #' @return Nothing, invisibly.
      post_peers_id_store = function(id, json = NULL, data = NULL) {
        self$POST(glue::glue("/peers/{id}/store"), json = json, data = data)
      },

      #' @description Straight store to peer
      #'
      #' Synchronously send the DICOM instance in the POST body to the
      #'   Orthanc peer whose identifier is provided in URL, without having
      #'   to first store it locally within Orthanc. This is an alternative
      #'   to command-line tools such as `curl`.
      #'
      #' @param id (character) Identifier of the modality of interest.
      #' @param file (character) Path to file for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body: DICOM instance to be sent (application/dicom).
      #'
      #' @return Nothing, invisibly.
      post_peers_id_store_straight = function(id, file = NULL) {
        self$POST(glue::glue("/peers/{id}/store-straight"), file = file)
      },

      #' @description Get peer system information
      #'
      #' Get system information about some Orthanc peer. This corresponds
      #'   to doing a `GET` request against the `/system` URI of the remote
      #'   peer. This route can be used to test connectivity.
      #'
      #' @param id (character) Identifier of the peer of interest.
      #'
      #' @family Networking
      #'
      #' @return System information about the peer.
      get_peers_id_system = function(id) {
        self$GET(glue::glue("/peers/{id}/system"))
      },

      #' @description List plugins
      #'
      #' List all the installed plugins
      #'
      #' @family System
      #'
      #' @return List containing the identifiers of the installed
      #'   plugins.
      get_plugins = function() {
        self$GET("/plugins")
      },

      #' @description JavaScript extensions to Orthanc Explorer
      #'
      #' Get the JavaScript extensions that are installed by all the
      #'   plugins using the `OrthancPluginExtendOrthancExplorer()` function
      #'   of the plugin SDK. This route is for internal use of Orthanc
      #'   Explorer.
      #'
      #' @family System
      #'
      #' @return The JavaScript extensions.
      get_plugins_explorer.js = function() {
        self$GET("/plugins/explorer.js")
      },

      #' @description Get plugin
      #'
      #' Get system information about the plugin whose identifier is
      #'   provided in the URL
      #'
      #' @param id (character) Identifier of the job of interest.
      #'
      #' @family System
      #'
      #' @return JSON object containing information about the plugin.
      get_plugins_id = function(id) {
        self$GET(glue::glue("/plugins/{id}"))
      },

      #' @description List query/retrieve operations
      #'
      #' List the identifiers of all the query/retrieve
      #'   operations on DICOM modalities, as initiated by calls to
      #'   `/modalities/{id}/query`. The length of this list is bounded
      #'   by the `QueryRetrieveSize` configuration option of Orthanc.
      #'   https://orthanc.uclouvain.be/book/users/rest.html#performing-query-retrieve-c-find-and-find-with-rest
      #'
      #' @family Networking
      #'
      #' @return List containing the identifiers.
      get_queries = function() {
        self$GET("/queries")
      },

      #' @description Delete a query
      #'
      #' Delete the query/retrieve operation whose identifier is provided
      #'   in the URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #'
      #' @family Networking
      #'
      #' @return Nothing, invisibly.
      delete_queries_id = function(id) {
        self$DELETE(glue::glue("/queries/{id}"))
      },

      #' @description List operations on a query
      #'
      #' List the available operations for the query/retrieve operation
      #'   whose identifier is provided in the URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #'
      #' @family Networking
      #'
      #' @return List containing the list of operations.
      get_queries_id = function(id) {
        self$GET(glue::glue("/queries/{id}"))
      },

      #' @description List answers to a query
      #'
      #' List the indices of all the available answers resulting from a
      #'   query/retrieve operation on some DICOM modality, whose identifier
      #'   is provided in the URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, retrieve detailed information
      #'     about the individual answers
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return List containing the indices of the answers, or
      #'   detailed information about the reported answers (if `expand`
      #'   argument is provided).
      get_queries_id_answers = function(id, params = NULL) {
        self$GET(glue::glue("/queries/{id}/answers"), params = params)
      },

      #' @description List operations on an answer
      #'
      #' List the available operations on an answer associated with the
      #'   query/retrieve operation whose identifier is provided in the URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #' @param index (character) Index of the answer.
      #'
      #' @family Networking
      #'
      #' @return List containing the list of operations.
      get_queries_id_answers_index = function(id, index) {
        self$GET(glue::glue("/queries/{id}/answers/{index}"))
      },

      #' @description Get one answer
      #'
      #' Get the content (DICOM tags) of one answer associated with the
      #'   query/retrieve operation whose identifier is provided in the URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #' @param index (character) Index of the answer.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return JSON object containing the DICOM tags of the answer.
      get_queries_id_answers_index_content = function(
        id,
        index,
        params = NULL
      ) {
        self$GET(
          glue::glue("/queries/{id}/answers/{index}/content"),
          params = params
        )
      },

      #' @description Query the child instances of an answer
      #'
      #' Issue a second DICOM C-FIND operation, in order to query the
      #'   child instances associated with one answer to some query/retrieve
      #'   operation whose identifiers are provided in the URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #' @param index (character) Index of the answer.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Query (list): Associative array containing the filter on the
      #'     values of the DICOM tags
      #'   - Timeout (numeric): Timeout for the C-FIND command, in
      #'     seconds (new in Orthanc 1.9.1)
      #'
      #' @return Nothing, invisibly.
      post_queries_id_answers_index_query_instances = function(
        id,
        index,
        json = NULL
      ) {
        self$POST(
          glue::glue("/queries/{id}/answers/{index}/query-instances"),
          json = json
        )
      },

      #' @description Query the child series of an answer
      #'
      #' Issue a second DICOM C-FIND operation, in order to query the
      #'   child series associated with one answer to some query/retrieve
      #'   operation whose identifiers are provided in the URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #' @param index (character) Index of the answer.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Query (list): Associative array containing the filter on the
      #'     values of the DICOM tags
      #'   - Timeout (numeric): Timeout for the C-FIND command, in
      #'     seconds (new in Orthanc 1.9.1)
      #'
      #' @return Nothing, invisibly.
      post_queries_id_answers_index_query_series = function(
        id,
        index,
        json = NULL
      ) {
        self$POST(
          glue::glue("/queries/{id}/answers/{index}/query-series"),
          json = json
        )
      },

      #' @description Query the child studies of an answer
      #'
      #' Issue a second DICOM C-FIND operation, in order to query the
      #'   child studies associated with one answer to some query/retrieve
      #'   operation whose identifiers are provided in the URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #' @param index (character) Index of the answer.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Query (list): Associative array containing the filter on the
      #'     values of the DICOM tags
      #'   - Timeout (numeric): Timeout for the C-FIND command, in
      #'     seconds (new in Orthanc 1.9.1)
      #'
      #' @return Nothing, invisibly.
      post_queries_id_answers_index_query_studies = function(
        id,
        index,
        json = NULL
      ) {
        self$POST(
          glue::glue("/queries/{id}/answers/{index}/query-studies"),
          json = json
        )
      },

      #' @description Retrieve one answer with a C-MOVE or a C-GET SCU
      #'
      #' Start a C-MOVE or a C-GET SCU command as a job, in order
      #'   to retrieve one answer associated with the query/retrieve
      #'   operation whose identifiers are provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/rest.html#performing-retrieve-c-move
      #'
      #' @param id (character) Identifier of the query of interest.
      #' @param index (character) Index of the answer.
      #' @param json (list) Named-list for request body. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - Full (logical): If set to `TRUE`, report the DICOM tags
      #'     in full format (tags indexed by their hexadecimal format,
      #'     associated with their symbolic name and their value)
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - RetrieveMethod (character): Force usage of C-MOVE
      #'     or C-GET to retrieve the resource. If note defined
      #'     in the payload, the retrieve method is defined in
      #'     the DicomDefaultRetrieveMethod configuration or in
      #'     DicomModalities->..->RetrieveMethod
      #'   - Simplify (logical): If set to `TRUE`, report the DICOM tags
      #'     in human-readable format (using the symbolic name of the
      #'     tags)
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - TargetAet (character): AET of the target modality. By
      #'     default, the AET of Orthanc is used, as defined in the
      #'     `DicomAet` configuration option.
      #'   - Timeout (numeric): Timeout for the C-MOVE command, in
      #'     seconds
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #' Request body: AET of the target modality (text/plain).
      #'
      #' @return Nothing, invisibly.
      post_queries_id_answers_index_retrieve = function(
        id,
        index,
        json = NULL,
        data = NULL
      ) {
        self$POST(
          glue::glue("/queries/{id}/answers/{index}/retrieve"),
          json = json,
          data = data
        )
      },

      #' @description Get level of original query
      #'
      #' Get the query level (value of the `QueryRetrieveLevel` tag) of
      #'   the query/retrieve operation whose identifier is provided in the
      #'   URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #'
      #' @family Networking
      #'
      #' @return The level.
      get_queries_id_level = function(id) {
        self$GET(glue::glue("/queries/{id}/level"))
      },

      #' @description Get modality of original query
      #'
      #' Get the identifier of the DICOM modality that was targeted by the
      #'   query/retrieve operation whose identifier is provided in the URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #'
      #' @family Networking
      #'
      #' @return The identifier of the DICOM modality.
      get_queries_id_modality = function(id) {
        self$GET(glue::glue("/queries/{id}/modality"))
      },

      #' @description Get original query arguments
      #'
      #' Get the original DICOM filter associated with the query/retrieve
      #'   operation whose identifier is provided in the URL
      #'
      #' @param id (character) Identifier of the query of interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return Content of the original query.
      get_queries_id_query = function(id, params = NULL) {
        self$GET(glue::glue("/queries/{id}/query"), params = params)
      },

      #' @description Retrieve all answers with C-MOVE SCU
      #'
      #' Start a C-MOVE SCU command as a job, in order to retrieve
      #'   all the answers associated with the query/retrieve
      #'   operation whose identifier is provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/rest.html#performing-retrieve-c-move
      #'
      #' @param id (character) Identifier of the query of interest.
      #' @param json (list) Named-list for request body. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Networking
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - Full (logical): If set to `TRUE`, report the DICOM tags
      #'     in full format (tags indexed by their hexadecimal format,
      #'     associated with their symbolic name and their value)
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - RetrieveMethod (character): Force usage of C-MOVE
      #'     or C-GET to retrieve the resource. If note defined
      #'     in the payload, the retrieve method is defined in
      #'     the DicomDefaultRetrieveMethod configuration or in
      #'     DicomModalities->..->RetrieveMethod
      #'   - Simplify (logical): If set to `TRUE`, report the DICOM tags
      #'     in human-readable format (using the symbolic name of the
      #'     tags)
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - TargetAet (character): AET of the target modality. By
      #'     default, the AET of Orthanc is used, as defined in the
      #'     `DicomAet` configuration option.
      #'   - Timeout (numeric): Timeout for the C-MOVE command, in
      #'     seconds
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #' Request body: AET of the target modality (text/plain).
      #'
      #' @return Nothing, invisibly.
      post_queries_id_retrieve = function(id, json = NULL, data = NULL) {
        self$POST(
          glue::glue("/queries/{id}/retrieve"),
          json = json,
          data = data
        )
      },

      #' @description List the available series
      #'
      #' List the Orthanc identifiers of all the available DICOM series
      #'
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, retrieve detailed information
      #'     about the individual resources, not only their Orthanc
      #'     identifiers
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - limit (number): Limit the number of results
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - response-content (string): Defines the content of
      #'     response for each returned resource. Allowed values are
      #'     `MainDicomTags`, `Metadata`, `Children`, `Parent`, `Labels`,
      #'     `Status`, `IsStable`, `IsProtected`, `Attachments`. If not
      #'     specified, Orthanc will return `MainDicomTags`, `Metadata`,
      #'     `Children`, `Parent`, `Labels`, `Status`, `IsStable`,
      #'     `IsProtected`.e.g: 'response-content=MainDicomTags;Children
      #'     (new in Orthanc 1.12.5 - overrides `expand`)
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - since (number): Show only the resources since the provided
      #'     index
      #'
      #' @return List containing either the Orthanc identifiers,
      #'   or detailed information about the reported series (if `expand`
      #'   argument is provided).
      get_series = function(params = NULL) {
        self$GET("/series", params = params)
      },

      #' @description Delete some series
      #'
      #' Delete the DICOM series whose Orthanc identifier is provided in
      #'   the URL
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #'
      #' @family Series
      #'
      #' @return Nothing, invisibly.
      delete_series_id = function(id) {
        self$DELETE(glue::glue("/series/{id}"))
      },

      #' @description Get information about some series
      #'
      #' Get detailed information about the DICOM series whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Information about the DICOM series.
      get_series_id = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}"), params = params)
      },

      #' @description Anonymize series
      #'
      #' Start a job that will anonymize all the DICOM instances
      #'   within the series whose identifier is provided in the URL.
      #'   The modified DICOM instances will be stored into a brand new
      #'   series, whose Orthanc identifiers will be returned by the job.
      #'   https://orthanc.uclouvain.be/book/users/anonymization.html#anonymization-of-patients-studies-or-series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - DicomVersion (character): Version of the DICOM standard to
      #'     be used for anonymization. Check out configuration option
      #'     `DeidentifyLogsDicomVersion` for possible values.
      #'   - Force (logical): Allow the modification of tags related to
      #'     DICOM identifiers, at the risk of breaking the DICOM model
      #'     of the real world
      #'   - Keep (list): List of DICOM tags whose value must not be
      #'     destroyed by the anonymization. Starting with Orthanc 1.9.4,
      #'     paths to subsequences can be provided using the same syntax
      #'     as the `dcmodify` command-line tool (wildcards are supported
      #'     as well).
      #'   - KeepLabels (logical): Keep the labels of all resources level
      #'     (defaults to `FALSE`)
      #'   - KeepPrivateTags (logical): Keep the private tags from the
      #'     DICOM instances (defaults to `FALSE`)
      #'   - KeepSource (logical): If set to `FALSE`, instructs Orthanc
      #'     to the remove original resources. By default, the original
      #'     resources are kept in Orthanc.
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Replace`
      #'   - Remove (list): List of additional tags to be removed from
      #'     the DICOM instances. Starting with Orthanc 1.9.4, paths to
      #'     subsequences can be provided using the same syntax as the
      #'     `dcmodify` command-line tool (wildcards are supported as
      #'     well).
      #'   - Replace (list): Associative array to change the value
      #'     of some DICOM tags in the DICOM instances. Starting with
      #'     Orthanc 1.9.4, paths to subsequences can be provided
      #'     using the same syntax as the `dcmodify` command-line tool
      #'     (wildcards are supported as well).
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Transcode (character): Transcode the DICOM
      #'     instances to the provided DICOM transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return Nothing, invisibly.
      post_series_id_anonymize = function(id, json = NULL) {
        self$POST(glue::glue("/series/{id}/anonymize"), json = json)
      },

      #' @description Create ZIP archive
      #'
      #' Synchronously create a ZIP archive containing the DICOM series
      #'   whose Orthanc identifier is provided in the URL. This flavor
      #'   is synchronous, which might *not* be desirable to archive large
      #'   amount of data, as it might lead to network timeouts. Prefer the
      #'   asynchronous version using `POST` method.
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - lossy-quality (number): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - transcode (string): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return ZIP file containing the archive.
      get_series_id_archive = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/archive"), params = params)
      },

      #' @description Create ZIP archive
      #'
      #' Create a ZIP archive containing the DICOM series whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, create the archive in
      #'     asynchronous mode, which means that a job is submitted to
      #'     create the archive in background.
      #'   - Filename (character): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'   - Synchronous (logical): If `TRUE`, create the archive
      #'     in synchronous mode, which means that the HTTP answer
      #'     will directly contain the ZIP file. This is the default,
      #'     easy behavior. However, if global configuration option
      #'     "SynchronousZipStream" is set to "false", asynchronous
      #'     transfers should be preferred for large amount of data, as
      #'     the creation of the temporary file might lead to network
      #'     timeouts.
      #'   - Transcode (character): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): In asynchronous mode, user data that will
      #'     be attached to the job.
      #'
      #' @return In asynchronous mode, information about the
      #'   job that has been submitted to generate the archive:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs.
      post_series_id_archive = function(id, json = NULL) {
        self$POST(glue::glue("/series/{id}/archive"), json = json)
      },

      #' @description List attachments
      #'
      #' Get the list of attachments that are associated with the given
      #'   series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (string): If present, retrieve the attachments list and
      #'     their numerical ids
      #'
      #' @return List containing the names of the attachments.
      get_series_id_attachments = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/attachments"), params = params)
      },

      #' @description Delete attachment
      #'
      #' Delete an attachment associated with the given DICOM series.
      #'   This call will fail if trying to delete a system attachment (i.e.
      #'   whose index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the attachment, to check if
      #'     its content has not changed and can be deleted. This header
      #'     is mandatory if `CheckRevisions` option is `TRUE`.
      #'
      #' @return Nothing, invisibly.
      delete_series_id_attachments_name = function(id, name, headers = NULL) {
        self$DELETE(
          glue::glue("/series/{id}/attachments/{name}"),
          headers = headers
        )
      },

      #' @description List operations on attachments
      #'
      #' Get the list of the operations that are available for attachments
      #'   associated with the given series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Other
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return List of the available operations.
      get_series_id_attachments_name = function(id, name, headers = NULL) {
        self$GET(
          glue::glue("/series/{id}/attachments/{name}"),
          headers = headers
        )
      },

      #' @description Set attachment
      #'
      #' Attach a file to the given DICOM series. This call will fail
      #'   if trying to modify a system attachment (i.e. whose index is <
      #'   1024).
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #' Request body: Binary data containing the attachment
      #'   (application/octet-stream).
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the attachment, if this is
      #'     not the first time this attachment is set.
      #'
      #' @return Empty JSON object in the case of a success.
      put_series_id_attachments_name = function(
        id,
        name,
        headers = NULL,
        data = NULL
      ) {
        self$PUT(
          glue::glue("/series/{id}/attachments/{name}"),
          headers = headers,
          data = data
        )
      },

      #' @description Compress attachment
      #'
      #' Change the compression scheme that is used to store an
      #'   attachment.
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Series
      #'
      #' @return Nothing, invisibly.
      post_series_id_attachments_name_compress = function(id, name) {
        self$POST(glue::glue("/series/{id}/attachments/{name}/compress"))
      },

      #' @description Get attachment (no decompression)
      #'
      #' Get the (binary) content of one attachment associated with
      #'   the given series. The attachment will not be decompressed if
      #'   `StorageCompression` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Content-Range (string): Optional content range to access
      #'     part of the attachment (new in Orthanc 1.12.5)
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'
      #' @return The attachment.
      get_series_id_attachments_name_compressed_data = function(
        id,
        name,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/series/{id}/attachments/{name}/compressed-data"),
          params = params,
          headers = headers
        )
      },

      #' @description Get MD5 of attachment on disk
      #'
      #' Get the MD5 hash of one attachment associated with the given
      #'   series, as stored on the disk. This is different from `.../md5`
      #'   iff `EnableStorage` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The MD5 of the attachment, as stored on the disk.
      get_series_id_attachments_name_compressed_md5 = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/series/{id}/attachments/{name}/compressed-md5"),
          headers = headers
        )
      },

      #' @description Get size of attachment on disk
      #'
      #' Get the size of one attachment associated with the given series,
      #'   as stored on the disk. This is different from `.../size` iff
      #'   `EnableStorage` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The size of the attachment, as stored on the disk.
      get_series_id_attachments_name_compressed_size = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/series/{id}/attachments/{name}/compressed-size"),
          headers = headers
        )
      },

      #' @description Get attachment
      #'
      #' Get the (binary) content of one attachment associated with the
      #'   given series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Content-Range (string): Optional content range to access
      #'     part of the attachment (new in Orthanc 1.12.5)
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'
      #' @return The attachment.
      get_series_id_attachments_name_data = function(
        id,
        name,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/series/{id}/attachments/{name}/data"),
          params = params,
          headers = headers
        )
      },

      #' @description Get info about the attachment
      #'
      #' Get all the information about the attachment associated with the
      #'   given series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return JSON object containing the information about the
      #'   attachment.
      get_series_id_attachments_name_info = function(id, name, headers = NULL) {
        self$GET(
          glue::glue("/series/{id}/attachments/{name}/info"),
          headers = headers
        )
      },

      #' @description Is attachment compressed?
      #'
      #' Test whether the attachment has been stored as a compressed file
      #'   on the disk.
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return `0` if the attachment was stored uncompressed, `1` if it
      #'   was compressed.
      get_series_id_attachments_name_is_compressed = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/series/{id}/attachments/{name}/is-compressed"),
          headers = headers
        )
      },

      #' @description Get MD5 of attachment
      #'
      #' Get the MD5 hash of one attachment associated with the given
      #'   series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The MD5 of the attachment.
      get_series_id_attachments_name_md5 = function(id, name, headers = NULL) {
        self$GET(
          glue::glue("/series/{id}/attachments/{name}/md5"),
          headers = headers
        )
      },

      #' @description Get size of attachment
      #'
      #' Get the size of one attachment associated with the given series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The size of the attachment.
      get_series_id_attachments_name_size = function(id, name, headers = NULL) {
        self$GET(
          glue::glue("/series/{id}/attachments/{name}/size"),
          headers = headers
        )
      },

      #' @description Uncompress attachment
      #'
      #' Change the compression scheme that is used to store an
      #'   attachment.
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Series
      #'
      #' @return Nothing, invisibly.
      post_series_id_attachments_name_uncompress = function(id, name) {
        self$POST(glue::glue("/series/{id}/attachments/{name}/uncompress"))
      },

      #' @description Verify attachment
      #'
      #' Verify that the attachment is not corrupted, by validating its
      #'   MD5 hash
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Series
      #'
      #' @return On success, a valid JSON object is returned.
      post_series_id_attachments_name_verify_md5 = function(id, name) {
        self$POST(glue::glue("/series/{id}/attachments/{name}/verify-md5"))
      },

      #' @description Get child instances
      #'
      #' Get detailed information about the child instances of the DICOM
      #'   series whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If false or missing, only retrieve the list
      #'     of child instances
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return List containing information about the child DICOM
      #'   instances.
      get_series_id_instances = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/instances"), params = params)
      },

      #' @description Get tags of instances
      #'
      #' Get the tags of all the child instances of the DICOM series whose
      #'   Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - ignore-length (array): Also include the DICOM tags that are
      #'     provided in this list, even if their associated value is
      #'     long
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return JSON object associating the Orthanc identifiers of the
      #'   instances, with the values of their DICOM tags.
      get_series_id_instances_tags = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/instances-tags"), params = params)
      },

      #' @description List labels
      #'
      #' Get the labels that are associated with the given series (new in
      #'   Orthanc 1.12.0)
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #'
      #' @family Series
      #'
      #' @return List containing the names of the labels.
      get_series_id_labels = function(id) {
        self$GET(glue::glue("/series/{id}/labels"))
      },

      #' @description Remove label
      #'
      #' Remove a label associated with a series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param label (character) The label to be removed.
      #'
      #' @family Series
      #'
      #' @return Nothing, invisibly.
      delete_series_id_labels_label = function(id, label) {
        self$DELETE(glue::glue("/series/{id}/labels/{label}"))
      },

      #' @description Test label
      #'
      #' Test whether the series is associated with the given label
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param label (character) The label of interest.
      #'
      #' @family Series
      #'
      #' @return Empty string is returned in the case of presence, error
      #'   404 in the case of absence.
      get_series_id_labels_label = function(id, label) {
        self$GET(glue::glue("/series/{id}/labels/{label}"))
      },

      #' @description Add label
      #'
      #' Associate a label with a series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param label (character) The label to be added.
      #'
      #' @family Series
      #'
      #' @return Nothing, invisibly.
      put_series_id_labels_label = function(id, label) {
        self$PUT(glue::glue("/series/{id}/labels/{label}"))
      },

      #' @description Create DICOMDIR media
      #'
      #' Synchronously create a DICOMDIR media containing the DICOM series
      #'   whose Orthanc identifier is provided in the URL. This flavor
      #'   is synchronous, which might *not* be desirable to archive large
      #'   amount of data, as it might lead to network timeouts. Prefer the
      #'   asynchronous version using `POST` method.
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - extended (string): If present, will include additional
      #'     tags such as `SeriesDescription`, leading to a so-called
      #'     *extended DICOMDIR*
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - lossy-quality (number): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - transcode (string): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return ZIP file containing the archive.
      get_series_id_media = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/media"), params = params)
      },

      #' @description Create DICOMDIR media
      #'
      #' Create a DICOMDIR media containing the DICOM series whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, create the archive in
      #'     asynchronous mode, which means that a job is submitted to
      #'     create the archive in background.
      #'   - Extended (logical): If `TRUE`, will include additional
      #'     tags such as `SeriesDescription`, leading to a so-called
      #'     *extended DICOMDIR*. Default value is `FALSE`.
      #'   - Filename (character): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'   - Synchronous (logical): If `TRUE`, create the archive
      #'     in synchronous mode, which means that the HTTP answer
      #'     will directly contain the ZIP file. This is the default,
      #'     easy behavior. However, if global configuration option
      #'     "SynchronousZipStream" is set to "false", asynchronous
      #'     transfers should be preferred for large amount of data, as
      #'     the creation of the temporary file might lead to network
      #'     timeouts.
      #'   - Transcode (character): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): In asynchronous mode, user data that will
      #'     be attached to the job.
      #'
      #' @return In asynchronous mode, information about the
      #'   job that has been submitted to generate the archive:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs.
      post_series_id_media = function(id, json = NULL) {
        self$POST(glue::glue("/series/{id}/media"), json = json)
      },

      #' @description List metadata
      #'
      #' Get the list of metadata that are associated with the given
      #'   series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, also retrieve the value of the
      #'     individual metadata
      #'   - numeric (string): If present, use the numeric identifier of
      #'     the metadata instead of its symbolic name
      #'
      #' @return List containing the names of the available
      #'   metadata, or List mapping metadata to their
      #'   values (if `expand` argument is provided).
      get_series_id_metadata = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/metadata"), params = params)
      },

      #' @description Delete metadata
      #'
      #' Delete some metadata associated with the given DICOM series. This
      #'   call will fail if trying to delete a system metadata (i.e. whose
      #'   index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the metadata, to check if its
      #'     content has not changed and can be deleted. This header is
      #'     mandatory if `CheckRevisions` option is `TRUE`.
      #'
      #' @return Nothing, invisibly.
      delete_series_id_metadata_name = function(id, name, headers = NULL) {
        self$DELETE(
          glue::glue("/series/{id}/metadata/{name}"),
          headers = headers
        )
      },

      #' @description Get metadata
      #'
      #' Get the value of a metadata that is associated with the given
      #'   series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the metadata,
      #'     to check if its content has changed
      #'
      #' @return Value of the metadata.
      get_series_id_metadata_name = function(id, name, headers = NULL) {
        self$GET(glue::glue("/series/{id}/metadata/{name}"), headers = headers)
      },

      #' @description Set metadata
      #'
      #' Set the value of some metadata in the given DICOM series. This
      #'   call will fail if trying to modify a system metadata (i.e. whose
      #'   index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #' Request body: String value of the metadata (text/plain).
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the metadata, if this is not
      #'     the first time this metadata is set.
      #'
      #' @return Nothing, invisibly.
      put_series_id_metadata_name = function(
        id,
        name,
        headers = NULL,
        data = NULL
      ) {
        self$PUT(
          glue::glue("/series/{id}/metadata/{name}"),
          headers = headers,
          data = data
        )
      },

      #' @description Modify series
      #'
      #' Start a job that will modify all the DICOM instances within
      #'   the series whose identifier is provided in the URL. The
      #'   modified DICOM instances will be stored into a brand new
      #'   series, whose Orthanc identifiers will be returned by the job.
      #'   https://orthanc.uclouvain.be/book/users/anonymization.html#modification-of-studies-or-series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - Force (logical): Allow the modification of tags related to
      #'     DICOM identifiers, at the risk of breaking the DICOM model
      #'     of the real world
      #'   - Keep (list): Keep the original value of the specified
      #'     tags, to be chosen among the `StudyInstanceUID`,
      #'     `SeriesInstanceUID` and `SOPInstanceUID` tags. Avoid this
      #'     feature as much as possible, as this breaks the DICOM model
      #'     of the real world.
      #'   - KeepSource (logical): If set to `FALSE`, instructs Orthanc
      #'     to the remove original resources. By default, the original
      #'     resources are kept in Orthanc.
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Replace`
      #'   - Remove (list): List of tags that must be removed from the
      #'     DICOM instances. Starting with Orthanc 1.9.4, paths to
      #'     subsequences can be provided using the same syntax as the
      #'     `dcmodify` command-line tool (wildcards are supported as
      #'     well).
      #'   - RemovePrivateTags (logical): Remove the private tags from
      #'     the DICOM instances (defaults to `FALSE`)
      #'   - Replace (list): Associative array to change the value
      #'     of some DICOM tags in the DICOM instances. Starting with
      #'     Orthanc 1.9.4, paths to subsequences can be provided
      #'     using the same syntax as the `dcmodify` command-line tool
      #'     (wildcards are supported as well).
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Transcode (character): Transcode the DICOM
      #'     instances to the provided DICOM transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return Nothing, invisibly.
      post_series_id_modify = function(id, json = NULL) {
        self$POST(glue::glue("/series/{id}/modify"), json = json)
      },

      #' @description Get series module
      #'
      #' Get the series module of the DICOM series whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - ignore-length (array): Also include the DICOM tags that are
      #'     provided in this list, even if their associated value is
      #'     long
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return Information about the DICOM series.
      get_series_id_module = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/module"), params = params)
      },

      #' @description Decode series for numpy
      #'
      #' Decode the given DICOM series, for use with numpy in Python.
      #'   The numpy array has 4 dimensions: (frame, height, width, color
      #'   channel).
      #'
      #' @param id (character) Orthanc identifier of the DICOM resource of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - compress (boolean): Compress the file as `.npz`
      #'   - rescale (boolean): On grayscale images, apply the rescaling
      #'     and return floating-point values
      #'
      #' @return Numpy file:
      #'   https://numpy.org/devdocs/reference/generated/numpy.lib.format.html.
      get_series_id_numpy = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/numpy"), params = params)
      },

      #' @description Get parent patient
      #'
      #' Get detailed information about the parent patient of the DICOM
      #'   series whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Information about the parent DICOM patient.
      get_series_id_patient = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/patient"), params = params)
      },

      #' @description Reconstruct tags & optionally files of series
      #'
      #' Reconstruct the main DICOM tags in DB of the series whose
      #'   Orthanc identifier is provided in the URL. This is useful
      #'   if child studies/series/instances have inconsistent values
      #'   for higher-level tags, in order to force Orthanc to use the
      #'   value from the resource of interest. Beware that this is a
      #'   time-consuming operation, as all the children DICOM instances
      #'   will be parsed again, and the Orthanc index will be updated
      #'   accordingly.
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - LimitToThisLevelMainDicomTags (logical): Only reconstruct
      #'     this level MainDicomTags by re-reading them from a random
      #'     child instance of the resource. This option is much faster
      #'     than a full reconstruct and is useful e.g. if you have
      #'     modified the 'ExtraMainDicomTags' at the Study level to
      #'     optimize the speed of some C-Find. 'false' by default. (New
      #'     in Orthanc 1.12.4)
      #'   - ReconstructFiles (logical): Also reconstruct the
      #'     files of the resources (e.g: apply IngestTranscoding,
      #'     StorageCompression). 'false' by default. (New in Orthanc
      #'     1.11.0)
      #'
      #' @return Nothing, invisibly.
      post_series_id_reconstruct = function(id, json = NULL) {
        self$POST(glue::glue("/series/{id}/reconstruct"), json = json)
      },

      #' @description Get shared tags
      #'
      #' Extract the DICOM tags whose value is constant across all the
      #'   child instances of the DICOM series whose Orthanc identifier is
      #'   provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return JSON object containing the values of the DICOM tags.
      get_series_id_shared_tags = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/shared-tags"), params = params)
      },

      #' @description Get series statistics
      #'
      #' Get statistics about the given series
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #'
      #' @family Series
      #'
      #' @return Nothing, invisibly.
      get_series_id_statistics = function(id) {
        self$GET(glue::glue("/series/{id}/statistics"))
      },

      #' @description Get parent study
      #'
      #' Get detailed information about the parent study of the DICOM
      #'   series whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the series of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Series
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Information about the parent DICOM study.
      get_series_id_study = function(id, params = NULL) {
        self$GET(glue::glue("/series/{id}/study"), params = params)
      },

      #' @description Get database statistics
      #'
      #' Get statistics related to the database of Orthanc
      #'
      #' @family System
      #'
      #' @return Nothing, invisibly.
      get_statistics = function() {
        self$GET("/statistics")
      },

      #' @description Get storage commitment report
      #'
      #' Get the storage commitment report whose
      #'   identifier is provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/storage-commitment.html#storage-commitment-scu
      #'
      #' @param id (character) Identifier of the storage commitment
      #'   report.
      #'
      #' @family Networking
      #'
      #' @return Nothing, invisibly.
      get_storage_commitment_id = function(id) {
        self$GET(glue::glue("/storage-commitment/{id}"))
      },

      #' @description Remove after storage commitment
      #'
      #' Remove out of Orthanc, the DICOM instances that have
      #'   been reported to have been properly received in the
      #'   storage commitment report whose identifier is provided
      #'   in the URL. This is only possible if the `Status`
      #'   of the storage commitment report is `Success`.
      #'   https://orthanc.uclouvain.be/book/users/storage-commitment.html#removing-the-instances
      #'
      #' @param id (character) Identifier of the storage commitment
      #'   report.
      #'
      #' @family Networking
      #'
      #' @return Nothing, invisibly.
      post_storage_commitment_id_remove = function(id) {
        self$POST(glue::glue("/storage-commitment/{id}/remove"))
      },

      #' @description List the available studies
      #'
      #' List the Orthanc identifiers of all the available DICOM studies
      #'
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, retrieve detailed information
      #'     about the individual resources, not only their Orthanc
      #'     identifiers
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - limit (number): Limit the number of results
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - response-content (string): Defines the content of
      #'     response for each returned resource. Allowed values are
      #'     `MainDicomTags`, `Metadata`, `Children`, `Parent`, `Labels`,
      #'     `Status`, `IsStable`, `IsProtected`, `Attachments`. If not
      #'     specified, Orthanc will return `MainDicomTags`, `Metadata`,
      #'     `Children`, `Parent`, `Labels`, `Status`, `IsStable`,
      #'     `IsProtected`.e.g: 'response-content=MainDicomTags;Children
      #'     (new in Orthanc 1.12.5 - overrides `expand`)
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - since (number): Show only the resources since the provided
      #'     index
      #'
      #' @return List containing either the Orthanc identifiers, or
      #'   detailed information about the reported studies (if `expand`
      #'   argument is provided).
      get_studies = function(params = NULL) {
        self$GET("/studies", params = params)
      },

      #' @description Delete some study
      #'
      #' Delete the DICOM study whose Orthanc identifier is provided in
      #'   the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #'
      #' @family Studies
      #'
      #' @return Nothing, invisibly.
      delete_studies_id = function(id) {
        self$DELETE(glue::glue("/studies/{id}"))
      },

      #' @description Get information about some study
      #'
      #' Get detailed information about the DICOM study whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Information about the DICOM study.
      get_studies_id = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}"), params = params)
      },

      #' @description Anonymize study
      #'
      #' Start a job that will anonymize all the DICOM instances
      #'   within the study whose identifier is provided in the URL.
      #'   The modified DICOM instances will be stored into a brand new
      #'   study, whose Orthanc identifiers will be returned by the job.
      #'   https://orthanc.uclouvain.be/book/users/anonymization.html#anonymization-of-patients-studies-or-series
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - DicomVersion (character): Version of the DICOM standard to
      #'     be used for anonymization. Check out configuration option
      #'     `DeidentifyLogsDicomVersion` for possible values.
      #'   - Force (logical): Allow the modification of tags related to
      #'     DICOM identifiers, at the risk of breaking the DICOM model
      #'     of the real world
      #'   - Keep (list): List of DICOM tags whose value must not be
      #'     destroyed by the anonymization. Starting with Orthanc 1.9.4,
      #'     paths to subsequences can be provided using the same syntax
      #'     as the `dcmodify` command-line tool (wildcards are supported
      #'     as well).
      #'   - KeepLabels (logical): Keep the labels of all resources level
      #'     (defaults to `FALSE`)
      #'   - KeepPrivateTags (logical): Keep the private tags from the
      #'     DICOM instances (defaults to `FALSE`)
      #'   - KeepSource (logical): If set to `FALSE`, instructs Orthanc
      #'     to the remove original resources. By default, the original
      #'     resources are kept in Orthanc.
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Replace`
      #'   - Remove (list): List of additional tags to be removed from
      #'     the DICOM instances. Starting with Orthanc 1.9.4, paths to
      #'     subsequences can be provided using the same syntax as the
      #'     `dcmodify` command-line tool (wildcards are supported as
      #'     well).
      #'   - Replace (list): Associative array to change the value
      #'     of some DICOM tags in the DICOM instances. Starting with
      #'     Orthanc 1.9.4, paths to subsequences can be provided
      #'     using the same syntax as the `dcmodify` command-line tool
      #'     (wildcards are supported as well).
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Transcode (character): Transcode the DICOM
      #'     instances to the provided DICOM transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return Nothing, invisibly.
      post_studies_id_anonymize = function(id, json = NULL) {
        self$POST(glue::glue("/studies/{id}/anonymize"), json = json)
      },

      #' @description Create ZIP archive
      #'
      #' Synchronously create a ZIP archive containing the DICOM study
      #'   whose Orthanc identifier is provided in the URL. This flavor
      #'   is synchronous, which might *not* be desirable to archive large
      #'   amount of data, as it might lead to network timeouts. Prefer the
      #'   asynchronous version using `POST` method.
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - lossy-quality (number): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - transcode (string): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return ZIP file containing the archive.
      get_studies_id_archive = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/archive"), params = params)
      },

      #' @description Create ZIP archive
      #'
      #' Create a ZIP archive containing the DICOM study whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, create the archive in
      #'     asynchronous mode, which means that a job is submitted to
      #'     create the archive in background.
      #'   - Filename (character): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'   - Synchronous (logical): If `TRUE`, create the archive
      #'     in synchronous mode, which means that the HTTP answer
      #'     will directly contain the ZIP file. This is the default,
      #'     easy behavior. However, if global configuration option
      #'     "SynchronousZipStream" is set to "false", asynchronous
      #'     transfers should be preferred for large amount of data, as
      #'     the creation of the temporary file might lead to network
      #'     timeouts.
      #'   - Transcode (character): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): In asynchronous mode, user data that will
      #'     be attached to the job.
      #'
      #' @return In asynchronous mode, information about the
      #'   job that has been submitted to generate the archive:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs.
      post_studies_id_archive = function(id, json = NULL) {
        self$POST(glue::glue("/studies/{id}/archive"), json = json)
      },

      #' @description List attachments
      #'
      #' Get the list of attachments that are associated with the given
      #'   study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (string): If present, retrieve the attachments list and
      #'     their numerical ids
      #'
      #' @return List containing the names of the attachments.
      get_studies_id_attachments = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/attachments"), params = params)
      },

      #' @description Delete attachment
      #'
      #' Delete an attachment associated with the given DICOM study. This
      #'   call will fail if trying to delete a system attachment (i.e.
      #'   whose index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the attachment, to check if
      #'     its content has not changed and can be deleted. This header
      #'     is mandatory if `CheckRevisions` option is `TRUE`.
      #'
      #' @return Nothing, invisibly.
      delete_studies_id_attachments_name = function(id, name, headers = NULL) {
        self$DELETE(
          glue::glue("/studies/{id}/attachments/{name}"),
          headers = headers
        )
      },

      #' @description List operations on attachments
      #'
      #' Get the list of the operations that are available for attachments
      #'   associated with the given study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Other
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return List of the available operations.
      get_studies_id_attachments_name = function(id, name, headers = NULL) {
        self$GET(
          glue::glue("/studies/{id}/attachments/{name}"),
          headers = headers
        )
      },

      #' @description Set attachment
      #'
      #' Attach a file to the given DICOM study. This call will fail
      #'   if trying to modify a system attachment (i.e. whose index is <
      #'   1024).
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #' Request body: Binary data containing the attachment
      #'   (application/octet-stream).
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the attachment, if this is
      #'     not the first time this attachment is set.
      #'
      #' @return Empty JSON object in the case of a success.
      put_studies_id_attachments_name = function(
        id,
        name,
        headers = NULL,
        data = NULL
      ) {
        self$PUT(
          glue::glue("/studies/{id}/attachments/{name}"),
          headers = headers,
          data = data
        )
      },

      #' @description Compress attachment
      #'
      #' Change the compression scheme that is used to store an
      #'   attachment.
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Studies
      #'
      #' @return Nothing, invisibly.
      post_studies_id_attachments_name_compress = function(id, name) {
        self$POST(glue::glue("/studies/{id}/attachments/{name}/compress"))
      },

      #' @description Get attachment (no decompression)
      #'
      #' Get the (binary) content of one attachment associated with
      #'   the given study. The attachment will not be decompressed if
      #'   `StorageCompression` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Content-Range (string): Optional content range to access
      #'     part of the attachment (new in Orthanc 1.12.5)
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'
      #' @return The attachment.
      get_studies_id_attachments_name_compressed_data = function(
        id,
        name,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/studies/{id}/attachments/{name}/compressed-data"),
          params = params,
          headers = headers
        )
      },

      #' @description Get MD5 of attachment on disk
      #'
      #' Get the MD5 hash of one attachment associated with the given
      #'   study, as stored on the disk. This is different from `.../md5`
      #'   iff `EnableStorage` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The MD5 of the attachment, as stored on the disk.
      get_studies_id_attachments_name_compressed_md5 = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/studies/{id}/attachments/{name}/compressed-md5"),
          headers = headers
        )
      },

      #' @description Get size of attachment on disk
      #'
      #' Get the size of one attachment associated with the given study,
      #'   as stored on the disk. This is different from `.../size` iff
      #'   `EnableStorage` is `TRUE`.
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The size of the attachment, as stored on the disk.
      get_studies_id_attachments_name_compressed_size = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/studies/{id}/attachments/{name}/compressed-size"),
          headers = headers
        )
      },

      #' @description Get attachment
      #'
      #' Get the (binary) content of one attachment associated with the
      #'   given study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param params (list) Named-list of optional query parameters. See Details.
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - Content-Range (string): Optional content range to access
      #'     part of the attachment (new in Orthanc 1.12.5)
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'
      #' @return The attachment.
      get_studies_id_attachments_name_data = function(
        id,
        name,
        params = NULL,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/studies/{id}/attachments/{name}/data"),
          params = params,
          headers = headers
        )
      },

      #' @description Get info about the attachment
      #'
      #' Get all the information about the attachment associated with the
      #'   given study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return JSON object containing the information about the
      #'   attachment.
      get_studies_id_attachments_name_info = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/studies/{id}/attachments/{name}/info"),
          headers = headers
        )
      },

      #' @description Is attachment compressed?
      #'
      #' Test whether the attachment has been stored as a compressed file
      #'   on the disk.
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return `0` if the attachment was stored uncompressed, `1` if it
      #'   was compressed.
      get_studies_id_attachments_name_is_compressed = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/studies/{id}/attachments/{name}/is-compressed"),
          headers = headers
        )
      },

      #' @description Get MD5 of attachment
      #'
      #' Get the MD5 hash of one attachment associated with the given
      #'   study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The MD5 of the attachment.
      get_studies_id_attachments_name_md5 = function(id, name, headers = NULL) {
        self$GET(
          glue::glue("/studies/{id}/attachments/{name}/md5"),
          headers = headers
        )
      },

      #' @description Get size of attachment
      #'
      #' Get the size of one attachment associated with the given study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the attachment,
      #'     to check if its content has changed
      #'
      #' @return The size of the attachment.
      get_studies_id_attachments_name_size = function(
        id,
        name,
        headers = NULL
      ) {
        self$GET(
          glue::glue("/studies/{id}/attachments/{name}/size"),
          headers = headers
        )
      },

      #' @description Uncompress attachment
      #'
      #' Change the compression scheme that is used to store an
      #'   attachment.
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Studies
      #'
      #' @return Nothing, invisibly.
      post_studies_id_attachments_name_uncompress = function(id, name) {
        self$POST(glue::glue("/studies/{id}/attachments/{name}/uncompress"))
      },

      #' @description Verify attachment
      #'
      #' Verify that the attachment is not corrupted, by validating its
      #'   MD5 hash
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the attachment, or its index
      #'   (cf. `UserContentType` configuration option).
      #'
      #' @family Studies
      #'
      #' @return On success, a valid JSON object is returned.
      post_studies_id_attachments_name_verify_md5 = function(id, name) {
        self$POST(glue::glue("/studies/{id}/attachments/{name}/verify-md5"))
      },

      #' @description Get child instances
      #'
      #' Get detailed information about the child instances of the DICOM
      #'   study whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If false or missing, only retrieve the list
      #'     of child instances
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return List containing information about the child DICOM
      #'   instances.
      get_studies_id_instances = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/instances"), params = params)
      },

      #' @description Get tags of instances
      #'
      #' Get the tags of all the child instances of the DICOM study whose
      #'   Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - ignore-length (array): Also include the DICOM tags that are
      #'     provided in this list, even if their associated value is
      #'     long
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return JSON object associating the Orthanc identifiers of the
      #'   instances, with the values of their DICOM tags.
      get_studies_id_instances_tags = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/instances-tags"), params = params)
      },

      #' @description List labels
      #'
      #' Get the labels that are associated with the given study (new in
      #'   Orthanc 1.12.0)
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #'
      #' @family Studies
      #'
      #' @return List containing the names of the labels.
      get_studies_id_labels = function(id) {
        self$GET(glue::glue("/studies/{id}/labels"))
      },

      #' @description Remove label
      #'
      #' Remove a label associated with a study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param label (character) The label to be removed.
      #'
      #' @family Studies
      #'
      #' @return Nothing, invisibly.
      delete_studies_id_labels_label = function(id, label) {
        self$DELETE(glue::glue("/studies/{id}/labels/{label}"))
      },

      #' @description Test label
      #'
      #' Test whether the study is associated with the given label
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param label (character) The label of interest.
      #'
      #' @family Studies
      #'
      #' @return Empty string is returned in the case of presence, error
      #'   404 in the case of absence.
      get_studies_id_labels_label = function(id, label) {
        self$GET(glue::glue("/studies/{id}/labels/{label}"))
      },

      #' @description Add label
      #'
      #' Associate a label with a study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param label (character) The label to be added.
      #'
      #' @family Studies
      #'
      #' @return Nothing, invisibly.
      put_studies_id_labels_label = function(id, label) {
        self$PUT(glue::glue("/studies/{id}/labels/{label}"))
      },

      #' @description Create DICOMDIR media
      #'
      #' Synchronously create a DICOMDIR media containing the DICOM study
      #'   whose Orthanc identifier is provided in the URL. This flavor
      #'   is synchronous, which might *not* be desirable to archive large
      #'   amount of data, as it might lead to network timeouts. Prefer the
      #'   asynchronous version using `POST` method.
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - extended (string): If present, will include additional
      #'     tags such as `SeriesDescription`, leading to a so-called
      #'     *extended DICOMDIR*
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - lossy-quality (number): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - transcode (string): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return ZIP file containing the archive.
      get_studies_id_media = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/media"), params = params)
      },

      #' @description Create DICOMDIR media
      #'
      #' Create a DICOMDIR media containing the DICOM study whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, create the archive in
      #'     asynchronous mode, which means that a job is submitted to
      #'     create the archive in background.
      #'   - Extended (logical): If `TRUE`, will include additional
      #'     tags such as `SeriesDescription`, leading to a so-called
      #'     *extended DICOMDIR*. Default value is `FALSE`.
      #'   - Filename (character): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'   - Synchronous (logical): If `TRUE`, create the archive
      #'     in synchronous mode, which means that the HTTP answer
      #'     will directly contain the ZIP file. This is the default,
      #'     easy behavior. However, if global configuration option
      #'     "SynchronousZipStream" is set to "false", asynchronous
      #'     transfers should be preferred for large amount of data, as
      #'     the creation of the temporary file might lead to network
      #'     timeouts.
      #'   - Transcode (character): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): In asynchronous mode, user data that will
      #'     be attached to the job.
      #'
      #' @return In asynchronous mode, information about the
      #'   job that has been submitted to generate the archive:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs.
      post_studies_id_media = function(id, json = NULL) {
        self$POST(glue::glue("/studies/{id}/media"), json = json)
      },

      #' @description Merge study
      #'
      #' Start a new job so as to move some DICOM resources into the
      #'   DICOM study whose Orthanc identifier is provided in the URL:
      #'   https://orthanc.uclouvain.be/book/users/anonymization.html#merging
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - KeepSource (logical): If set to `TRUE`, instructs Orthanc to
      #'     keep a copy of the original resources in their source study.
      #'     By default, the original resources are deleted from Orthanc.
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - Resources (list): The list of DICOM resources (studies,
      #'     series, and/or instances) to be merged into the study of
      #'     interest (mandatory option)
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return Nothing, invisibly.
      post_studies_id_merge = function(id, json = NULL) {
        self$POST(glue::glue("/studies/{id}/merge"), json = json)
      },

      #' @description List metadata
      #'
      #' Get the list of metadata that are associated with the given study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If present, also retrieve the value of the
      #'     individual metadata
      #'   - numeric (string): If present, use the numeric identifier of
      #'     the metadata instead of its symbolic name
      #'
      #' @return List containing the names of the available
      #'   metadata, or List mapping metadata to their
      #'   values (if `expand` argument is provided).
      get_studies_id_metadata = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/metadata"), params = params)
      },

      #' @description Delete metadata
      #'
      #' Delete some metadata associated with the given DICOM study. This
      #'   call will fail if trying to delete a system metadata (i.e. whose
      #'   index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the metadata, to check if its
      #'     content has not changed and can be deleted. This header is
      #'     mandatory if `CheckRevisions` option is `TRUE`.
      #'
      #' @return Nothing, invisibly.
      delete_studies_id_metadata_name = function(id, name, headers = NULL) {
        self$DELETE(
          glue::glue("/studies/{id}/metadata/{name}"),
          headers = headers
        )
      },

      #' @description Get metadata
      #'
      #' Get the value of a metadata that is associated with the given
      #'   study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional headers (`headers`):
      #'   - If-None-Match (string): Optional revision of the metadata,
      #'     to check if its content has changed
      #'
      #' @return Value of the metadata.
      get_studies_id_metadata_name = function(id, name, headers = NULL) {
        self$GET(glue::glue("/studies/{id}/metadata/{name}"), headers = headers)
      },

      #' @description Set metadata
      #'
      #' Set the value of some metadata in the given DICOM study. This
      #'   call will fail if trying to modify a system metadata (i.e. whose
      #'   index is < 1024).
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param name (character) The name of the metadata, or its index
      #'   (cf. `UserMetadata` configuration option).
      #' @param headers (list) Named-list of optional header parameters. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #' Request body: String value of the metadata (text/plain).
      #'
      #' Optional headers (`headers`):
      #'   - If-Match (string): Revision of the metadata, if this is not
      #'     the first time this metadata is set.
      #'
      #' @return Nothing, invisibly.
      put_studies_id_metadata_name = function(
        id,
        name,
        headers = NULL,
        data = NULL
      ) {
        self$PUT(
          glue::glue("/studies/{id}/metadata/{name}"),
          headers = headers,
          data = data
        )
      },

      #' @description Modify study
      #'
      #' Start a job that will modify all the DICOM instances within
      #'   the study whose identifier is provided in the URL. The
      #'   modified DICOM instances will be stored into a brand new
      #'   study, whose Orthanc identifiers will be returned by the job.
      #'   https://orthanc.uclouvain.be/book/users/anonymization.html#modification-of-studies-or-series
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - Force (logical): Allow the modification of tags related to
      #'     DICOM identifiers, at the risk of breaking the DICOM model
      #'     of the real world
      #'   - Keep (list): Keep the original value of the specified
      #'     tags, to be chosen among the `StudyInstanceUID`,
      #'     `SeriesInstanceUID` and `SOPInstanceUID` tags. Avoid this
      #'     feature as much as possible, as this breaks the DICOM model
      #'     of the real world.
      #'   - KeepSource (logical): If set to `FALSE`, instructs Orthanc
      #'     to the remove original resources. By default, the original
      #'     resources are kept in Orthanc.
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Replace`
      #'   - Remove (list): List of tags that must be removed from the
      #'     DICOM instances. Starting with Orthanc 1.9.4, paths to
      #'     subsequences can be provided using the same syntax as the
      #'     `dcmodify` command-line tool (wildcards are supported as
      #'     well).
      #'   - RemovePrivateTags (logical): Remove the private tags from
      #'     the DICOM instances (defaults to `FALSE`)
      #'   - Replace (list): Associative array to change the value
      #'     of some DICOM tags in the DICOM instances. Starting with
      #'     Orthanc 1.9.4, paths to subsequences can be provided
      #'     using the same syntax as the `dcmodify` command-line tool
      #'     (wildcards are supported as well).
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Transcode (character): Transcode the DICOM
      #'     instances to the provided DICOM transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return Nothing, invisibly.
      post_studies_id_modify = function(id, json = NULL) {
        self$POST(glue::glue("/studies/{id}/modify"), json = json)
      },

      #' @description Get study module
      #'
      #' Get the study module of the DICOM study whose Orthanc identifier
      #'   is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - ignore-length (array): Also include the DICOM tags that are
      #'     provided in this list, even if their associated value is
      #'     long
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return Information about the DICOM study.
      get_studies_id_module = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/module"), params = params)
      },

      #' @description Get patient module of study
      #'
      #' Get the patient module of the DICOM study whose Orthanc
      #'   identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - ignore-length (array): Also include the DICOM tags that are
      #'     provided in this list, even if their associated value is
      #'     long
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return Information about the DICOM study.
      get_studies_id_module_patient = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/module-patient"), params = params)
      },

      #' @description Get parent patient
      #'
      #' Get detailed information about the parent patient of the DICOM
      #'   study whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Information about the parent DICOM patient.
      get_studies_id_patient = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/patient"), params = params)
      },

      #' @description Reconstruct tags & optionally files of study
      #'
      #' Reconstruct the main DICOM tags in DB of the study whose
      #'   Orthanc identifier is provided in the URL. This is useful
      #'   if child studies/series/instances have inconsistent values
      #'   for higher-level tags, in order to force Orthanc to use the
      #'   value from the resource of interest. Beware that this is a
      #'   time-consuming operation, as all the children DICOM instances
      #'   will be parsed again, and the Orthanc index will be updated
      #'   accordingly.
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - LimitToThisLevelMainDicomTags (logical): Only reconstruct
      #'     this level MainDicomTags by re-reading them from a random
      #'     child instance of the resource. This option is much faster
      #'     than a full reconstruct and is useful e.g. if you have
      #'     modified the 'ExtraMainDicomTags' at the Study level to
      #'     optimize the speed of some C-Find. 'false' by default. (New
      #'     in Orthanc 1.12.4)
      #'   - ReconstructFiles (logical): Also reconstruct the
      #'     files of the resources (e.g: apply IngestTranscoding,
      #'     StorageCompression). 'false' by default. (New in Orthanc
      #'     1.11.0)
      #'
      #' @return Nothing, invisibly.
      post_studies_id_reconstruct = function(id, json = NULL) {
        self$POST(glue::glue("/studies/{id}/reconstruct"), json = json)
      },

      #' @description Get child series
      #'
      #' Get detailed information about the child series of the DICOM
      #'   study whose Orthanc identifier is provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - expand (string): If false or missing, only retrieve the list
      #'     of child series
      #'   - full (boolean): If present, report the DICOM tags in full
      #'     format (tags indexed by their hexadecimal format, associated
      #'     with their symbolic name and their value)
      #'   - requested-tags (string): If present, list the DICOM Tags
      #'     you want to list in the response. This argument is a
      #'     semi-column separated list of DICOM Tags identifiers;
      #'     e.g: 'requested-tags=0010,0010;PatientBirthDate'. The tags
      #'     requested tags are returned in the 'RequestedTags' field in
      #'     the response. Note that, if you are requesting tags that are
      #'     not listed in the Main Dicom Tags stored in DB, building the
      #'     response might be slow since Orthanc will need to access the
      #'     DICOM files. If not specified, Orthanc will return all Main
      #'     Dicom Tags to keep backward compatibility with Orthanc prior
      #'     to 1.11.0.
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return List containing information about the child DICOM
      #'   series.
      get_studies_id_series = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/series"), params = params)
      },

      #' @description Get shared tags
      #'
      #' Extract the DICOM tags whose value is constant across all the
      #'   child instances of the DICOM study whose Orthanc identifier is
      #'   provided in the URL
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - short (boolean): If present, report the DICOM tags in
      #'     hexadecimal format
      #'   - simplify (boolean): If present, report the DICOM tags in
      #'     human-readable format (using the symbolic name of the tags)
      #'
      #' @return JSON object containing the values of the DICOM tags.
      get_studies_id_shared_tags = function(id, params = NULL) {
        self$GET(glue::glue("/studies/{id}/shared-tags"), params = params)
      },

      #' @description Split study
      #'
      #' Start a new job so as to split the DICOM study whose
      #'   Orthanc identifier is provided in the URL, by taking some
      #'   of its children series or instances out of it and putting
      #'   them into a brand new study (this new study is created by
      #'   setting the `StudyInstanceUID` tag to a random identifier):
      #'   https://orthanc.uclouvain.be/book/users/anonymization.html#splitting
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family Studies
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - Instances (list): The list of instances to be separated from
      #'     the parent study. These instances must all be children of
      #'     the same source study, that is specified in the URI.
      #'   - KeepLabels (logical): Keep the labels of all resources level
      #'     (defaults to `FALSE`)
      #'   - KeepSource (logical): If set to `TRUE`, instructs Orthanc to
      #'     keep a copy of the original series/instances in the source
      #'     study. By default, the original series/instances are deleted
      #'     from Orthanc.
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - Remove (list): List of tags that must be removed in the new
      #'     study (from the same modules as in the `Replace` option)
      #'   - Replace (list): Associative array to change the value of
      #'     some DICOM tags in the new study. These tags must be part of
      #'     the "Patient Module Attributes" or the "General Study Module
      #'     Attributes", as specified by the DICOM 2011 standard in
      #'     Tables C.7-1 and C.7-3.
      #'   - Series (list): The list of series to be separated from the
      #'     parent study. These series must all be children of the same
      #'     source study, that is specified in the URI.
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return Nothing, invisibly.
      post_studies_id_split = function(id, json = NULL) {
        self$POST(glue::glue("/studies/{id}/split"), json = json)
      },

      #' @description Get study statistics
      #'
      #' Get statistics about the given study
      #'
      #' @param id (character) Orthanc identifier of the study of
      #'   interest.
      #'
      #' @family Studies
      #'
      #' @return Nothing, invisibly.
      get_studies_id_statistics = function(id) {
        self$GET(glue::glue("/studies/{id}/statistics"))
      },

      #' @description Get system information
      #'
      #' Get system information about Orthanc
      #'
      #' @family System
      #'
      #' @return Nothing, invisibly.
      get_system = function() {
        self$GET("/system")
      },

      #' @description List operations
      #'
      #' List the available operations under URI `/tools/`
      #'
      #' @family Other
      #'
      #' @return List of the available operations.
      get_tools = function() {
        self$GET("/tools")
      },

      #' @description Get accepted SOPClassUID
      #'
      #' Get the list of SOP Class UIDs that are accepted by Orthanc
      #'   C-STORE SCP. This corresponds to the configuration options
      #'   `AcceptedSopClasses` and `RejectedSopClasses`.
      #'
      #' @family System
      #'
      #' @return List containing the SOP Class UIDs.
      get_tools_accepted_sop_classes = function() {
        self$GET("/tools/accepted-sop-classes")
      },

      #' @description Get accepted transfer syntaxes
      #'
      #' Get the list of UIDs of the DICOM transfer syntaxes that
      #'   are accepted by Orthanc C-STORE SCP. This corresponds to
      #'   the configuration options `AcceptedTransferSyntaxes` and
      #'   `XXXTransferSyntaxAccepted`.
      #'
      #' @family System
      #'
      #' @return List containing the transfer syntax UIDs.
      get_tools_accepted_transfer_syntaxes = function() {
        self$GET("/tools/accepted-transfer-syntaxes")
      },

      #' @description Set accepted transfer syntaxes
      #'
      #' Set the DICOM transfer syntaxes that accepted by Orthanc C-STORE
      #'   SCP
      #'
      #' @param json (list) Named-list for request body. See Details.
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - (list): JSON array containing a list of transfer syntax UIDs
      #'     to be accepted. Wildcards `?` and `*` are accepted.
      #' Request body: UID of the transfer syntax to be accepted.
      #'   Wildcards `?` and `*` are accepted. (text/plain).
      #'
      #' @return List containing the now-accepted transfer syntax
      #'   UIDs.
      put_tools_accepted_transfer_syntaxes = function(
        json = NULL,
        data = NULL
      ) {
        self$PUT("/tools/accepted-transfer-syntaxes", json = json, data = data)
      },

      #' @description Anonymize a set of resources
      #'
      #' Start a job that will anonymize all the DICOM patients, studies,
      #'   series or instances whose identifiers are provided in the
      #'   `Resources` field.
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - DicomVersion (character): Version of the DICOM standard to
      #'     be used for anonymization. Check out configuration option
      #'     `DeidentifyLogsDicomVersion` for possible values.
      #'   - Force (logical): Allow the modification of tags related to
      #'     DICOM identifiers, at the risk of breaking the DICOM model
      #'     of the real world
      #'   - Keep (list): List of DICOM tags whose value must not be
      #'     destroyed by the anonymization. Starting with Orthanc 1.9.4,
      #'     paths to subsequences can be provided using the same syntax
      #'     as the `dcmodify` command-line tool (wildcards are supported
      #'     as well).
      #'   - KeepLabels (logical): Keep the labels of all resources level
      #'     (defaults to `FALSE`)
      #'   - KeepPrivateTags (logical): Keep the private tags from the
      #'     DICOM instances (defaults to `FALSE`)
      #'   - KeepSource (logical): If set to `FALSE`, instructs Orthanc
      #'     to the remove original resources. By default, the original
      #'     resources are kept in Orthanc.
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Replace`
      #'   - Remove (list): List of additional tags to be removed from
      #'     the DICOM instances. Starting with Orthanc 1.9.4, paths to
      #'     subsequences can be provided using the same syntax as the
      #'     `dcmodify` command-line tool (wildcards are supported as
      #'     well).
      #'   - Replace (list): Associative array to change the value
      #'     of some DICOM tags in the DICOM instances. Starting with
      #'     Orthanc 1.9.4, paths to subsequences can be provided
      #'     using the same syntax as the `dcmodify` command-line tool
      #'     (wildcards are supported as well).
      #'   - Resources (list): List of the Orthanc identifiers of the
      #'     patients/studies/series/instances of interest.
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Transcode (character): Transcode the DICOM
      #'     instances to the provided DICOM transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return The list of all the resources that have been created by
      #'   this anonymization.
      post_tools_bulk_anonymize = function(json = NULL) {
        self$POST("/tools/bulk-anonymize", json = json)
      },

      #' @description Describe a set of resources
      #'
      #' Get the content all the DICOM patients, studies, series or
      #'   instances whose identifiers are provided in the `Resources`
      #'   field, in one single call.
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Full (logical): If set to `TRUE`, report the DICOM tags
      #'     in full format (tags indexed by their hexadecimal format,
      #'     associated with their symbolic name and their value)
      #'   - Level (character): This optional argument specifies the
      #'     level of interest (can be `Patient`, `Study`, `Series`
      #'     or `Instance`). Orthanc will loop over the items inside
      #'     `Resources`, and explore upward or downward in the DICOM
      #'     hierarchy in order to find the level of interest.
      #'   - Metadata (logical): If set to `TRUE` (default value),
      #'     the metadata associated with the resources will also be
      #'     retrieved.
      #'   - Resources (list): List of the Orthanc identifiers of the
      #'     patients/studies/series/instances of interest.
      #'   - Short (logical): If set to `TRUE`, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return Nothing, invisibly.
      post_tools_bulk_content = function(json = NULL) {
        self$POST("/tools/bulk-content", json = json)
      },

      #' @description Delete a set of resources
      #'
      #' Delete all the DICOM patients, studies, series or instances whose
      #'   identifiers are provided in the `Resources` field.
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Resources (list): List of the Orthanc identifiers of the
      #'     patients/studies/series/instances of interest.
      #'
      #' @return Nothing, invisibly.
      post_tools_bulk_delete = function(json = NULL) {
        self$POST("/tools/bulk-delete", json = json)
      },

      #' @description Modify a set of resources
      #'
      #' Start a job that will modify all the DICOM patients, studies,
      #'   series or instances whose identifiers are provided in the
      #'   `Resources` field.
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, run the job in
      #'     asynchronous mode, which means that the REST API call will
      #'     immediately return, reporting the identifier of a job.
      #'     Prefer this flavor wherever possible.
      #'   - Force (logical): Allow the modification of tags related to
      #'     DICOM identifiers, at the risk of breaking the DICOM model
      #'     of the real world
      #'   - Keep (list): Keep the original value of the specified
      #'     tags, to be chosen among the `StudyInstanceUID`,
      #'     `SeriesInstanceUID` and `SOPInstanceUID` tags. Avoid this
      #'     feature as much as possible, as this breaks the DICOM model
      #'     of the real world.
      #'   - KeepSource (logical): If set to `FALSE`, instructs Orthanc
      #'     to the remove original resources. By default, the original
      #'     resources are kept in Orthanc.
      #'   - Level (character): Level of the modification (`Patient`,
      #'     `Study`, `Series` or `Instance`). If absent, the level
      #'     defaults to `Instance`, but is set to `Patient` if
      #'     `PatientID` is modified, to `Study` if `StudyInstanceUID`
      #'     is modified, or to `Series` if `SeriesInstancesUID` is
      #'     modified. (new in Orthanc 1.9.7)
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Permissive (logical): If `TRUE`, ignore errors during the
      #'     individual steps of the job. Default value is `FALSE`.
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'     Default value is `0`
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Replace`
      #'   - Remove (list): List of tags that must be removed from the
      #'     DICOM instances. Starting with Orthanc 1.9.4, paths to
      #'     subsequences can be provided using the same syntax as the
      #'     `dcmodify` command-line tool (wildcards are supported as
      #'     well).
      #'   - RemovePrivateTags (logical): Remove the private tags from
      #'     the DICOM instances (defaults to `FALSE`)
      #'   - Replace (list): Associative array to change the value
      #'     of some DICOM tags in the DICOM instances. Starting with
      #'     Orthanc 1.9.4, paths to subsequences can be provided
      #'     using the same syntax as the `dcmodify` command-line tool
      #'     (wildcards are supported as well).
      #'   - Resources (list): List of the Orthanc identifiers of the
      #'     patients/studies/series/instances of interest.
      #'   - Synchronous (logical): If `TRUE`, run the job in synchronous
      #'     mode, which means that the HTTP answer will directly contain
      #'     the result of the job. This is the default, easy behavior,
      #'     but it is *not* desirable for long jobs, as it might lead to
      #'     network timeouts.
      #'   - Transcode (character): Transcode the DICOM
      #'     instances to the provided DICOM transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): User data that will travel along with the
      #'     job.
      #'
      #' @return The list of all the resources that have been altered by
      #'   this modification.
      post_tools_bulk_modify = function(json = NULL) {
        self$POST("/tools/bulk-modify", json = json)
      },

      #' @description Count local resources
      #'
      #' This URI can be used to count the resources that are matching
      #'   criteria on the content of the local Orthanc server, in a way
      #'   that is similar to tools/find
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Full (logical): If set to `TRUE`, report the DICOM tags
      #'     in full format (tags indexed by their hexadecimal format,
      #'     associated with their symbolic name and their value)
      #'   - Labels (list): List of strings specifying which labels to
      #'     look for in the resources (new in Orthanc 1.12.0)
      #'   - LabelsConstraint (character): Constraint on the labels,
      #'     can be `All`, `Any`, or `None` (defaults to `All`, new in
      #'     Orthanc 1.12.0)
      #'   - Level (character): Level of the query (`Patient`, `Study`,
      #'     `Series` or `Instance`)
      #'   - MetadataQuery (list): Associative array containing the
      #'     filter on the values of the metadata (new in Orthanc 1.12.5)
      #'   - ParentPatient (character): Limit the reported resources to
      #'     descendants of this patient (new in Orthanc 1.12.5)
      #'   - ParentSeries (character): Limit the reported resources to
      #'     descendants of this series (new in Orthanc 1.12.5)
      #'   - ParentStudy (character): Limit the reported resources to
      #'     descendants of this study (new in Orthanc 1.12.5)
      #'   - Query (list): Associative array containing the filter on the
      #'     values of the DICOM tags
      #'   - Short (logical): If set to `TRUE`, report the DICOM tags in
      #'     hexadecimal format
      #'
      #' @return A JSON object with the `Count` of matching resources.
      post_tools_count_resources = function(json = NULL) {
        self$POST("/tools/count-resources", json = json)
      },

      #' @description Create ZIP archive
      #'
      #' Create a ZIP archive containing the DICOM resources (patients,
      #'   studies, series, or instances) whose Orthanc identifiers are
      #'   provided in the 'resources' argument
      #'
      #' @param resources (character) A comma separated list of Orthanc
      #'   resource identifiers to include in the ZIP archive..
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family System
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - lossy-quality (number): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - transcode (string): If present, the DICOM files
      #'     will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return Nothing, invisibly.
      get_tools_create_archive = function(resources = NULL, params = NULL) {
        self$GET(
          "/tools/create-archive",
          resources = resources,
          params = params
        )
      },

      #' @description Create ZIP archive
      #'
      #' Create a ZIP archive containing the DICOM resources (patients,
      #'   studies, series, or instances) whose Orthanc identifiers are
      #'   provided in the body
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, create the archive in
      #'     asynchronous mode, which means that a job is submitted to
      #'     create the archive in background.
      #'   - Filename (character): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'   - Resources (list): The list of Orthanc identifiers of
      #'     interest.
      #'   - Synchronous (logical): If `TRUE`, create the archive
      #'     in synchronous mode, which means that the HTTP answer
      #'     will directly contain the ZIP file. This is the default,
      #'     easy behavior. However, if global configuration option
      #'     "SynchronousZipStream" is set to "false", asynchronous
      #'     transfers should be preferred for large amount of data, as
      #'     the creation of the temporary file might lead to network
      #'     timeouts.
      #'   - Transcode (character): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): In asynchronous mode, user data that will
      #'     be attached to the job.
      #'
      #' @return In asynchronous mode, information about the
      #'   job that has been submitted to generate the archive:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs.
      post_tools_create_archive = function(json = NULL) {
        self$POST("/tools/create-archive", json = json)
      },

      #' @description Create one DICOM instance
      #'
      #' Create one DICOM instance, and store it into Orthanc
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Content (character): This field can be used to
      #'     embed an image (pixel data encoded as PNG or JPEG),
      #'     a PDF, or a 3D manufactoring model (MTL/OBJ/STL)
      #'     inside the created DICOM instance. The file to be
      #'     encapsulated must be provided using its [data URI scheme
      #'     encoding](https://en.wikipedia.org/wiki/Data_URI_scheme).
      #'     This field can possibly contain a JSON array, in which case
      #'     a DICOM series is created containing one DICOM instance for
      #'     each item in the `Content` field.
      #'   - Encapsulate (logical): If set to `TRUE`, encapsulate the
      #'     binary data of `ContentData` as such, using a compressed
      #'     transfer syntax. Only applicable if `ContentData` contains
      #'     a grayscale or color JPEG image in 8bpp, in which case the
      #'     transfer syntax is set to "1.2.840.10008.1.2.4.50". (new in
      #'     Orthanc 1.12.7)
      #'   - Force (logical): Avoid the consistency checks for the
      #'     DICOM tags that enforce the DICOM model of the real-world.
      #'     You can notably use this flag if you need to manually
      #'     set the tags `StudyInstanceUID`, `SeriesInstanceUID`, or
      #'     `SOPInstanceUID`. Be careful with this feature.
      #'   - InterpretBinaryTags (logical): If some
      #'     value in the `Tags` associative array is
      #'     formatted according to some [data URI scheme
      #'     encoding](https://en.wikipedia.org/wiki/Data_URI_scheme),
      #'     whether this value is decoded to a binary value or kept as
      #'     such (`TRUE` by default)
      #'   - Parent (character): If present, the newly created instance
      #'     will be attached to the parent DICOM resource whose Orthanc
      #'     identifier is contained in this field. The DICOM tags of the
      #'     parent modules in the DICOM hierarchy will be automatically
      #'     copied to the newly created instance.
      #'   - PrivateCreator (character): The private creator to be used
      #'     for private tags in `Tags`
      #'   - Tags (list): Associative array containing the tags of the
      #'     new instance to be created
      #'
      #' @return Nothing, invisibly.
      post_tools_create_dicom = function(json = NULL) {
        self$POST("/tools/create-dicom", json = json)
      },

      #' @description Create DICOMDIR media
      #'
      #' Create a DICOMDIR media containing the DICOM resources (patients,
      #'   studies, series, or instances) whose Orthanc identifiers are
      #'   provided in the 'resources' argument
      #'
      #' @param resources (character) A comma separated list of Orthanc
      #'   resource identifiers to include in the DICOMDIR media..
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family System
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - lossy-quality (number): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - transcode (string): If present, the DICOM files
      #'     will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return Nothing, invisibly.
      get_tools_create_media = function(resources = NULL, params = NULL) {
        self$GET("/tools/create-media", resources = resources, params = params)
      },

      #' @description Create DICOMDIR media
      #'
      #' Create a DICOMDIR media containing the DICOM resources (patients,
      #'   studies, series, or instances) whose Orthanc identifiers are
      #'   provided in the body
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, create the archive in
      #'     asynchronous mode, which means that a job is submitted to
      #'     create the archive in background.
      #'   - Extended (logical): If `TRUE`, will include additional
      #'     tags such as `SeriesDescription`, leading to a so-called
      #'     *extended DICOMDIR*. Default value is `FALSE`.
      #'   - Filename (character): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'   - Resources (list): The list of Orthanc identifiers of
      #'     interest.
      #'   - Synchronous (logical): If `TRUE`, create the archive
      #'     in synchronous mode, which means that the HTTP answer
      #'     will directly contain the ZIP file. This is the default,
      #'     easy behavior. However, if global configuration option
      #'     "SynchronousZipStream" is set to "false", asynchronous
      #'     transfers should be preferred for large amount of data, as
      #'     the creation of the temporary file might lead to network
      #'     timeouts.
      #'   - Transcode (character): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): In asynchronous mode, user data that will
      #'     be attached to the job.
      #'
      #' @return In asynchronous mode, information about the
      #'   job that has been submitted to generate the archive:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs.
      post_tools_create_media = function(json = NULL) {
        self$POST("/tools/create-media", json = json)
      },

      #' @description Create DICOMDIR media
      #'
      #' Create a DICOMDIR media containing the DICOM resources (patients,
      #'   studies, series, or instances) whose Orthanc identifiers are
      #'   provided in the 'resources' argument
      #'
      #' @param resources (character) A comma separated list of Orthanc
      #'   resource identifiers to include in the DICOMDIR media..
      #' @param params (list) Named-list of optional query parameters. See Details.
      #'
      #' @family System
      #'
      #' @details
      #'
      #' Optional query parameters (`params`):
      #'   - filename (string): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - lossy-quality (number): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - transcode (string): If present, the DICOM files
      #'     will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'
      #' @return Nothing, invisibly.
      get_tools_create_media_extended = function(
        resources = NULL,
        params = NULL
      ) {
        self$GET(
          "/tools/create-media-extended",
          resources = resources,
          params = params
        )
      },

      #' @description Create DICOMDIR media
      #'
      #' Create a DICOMDIR media containing the DICOM resources (patients,
      #'   studies, series, or instances) whose Orthanc identifiers are
      #'   provided in the body
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - Asynchronous (logical): If `TRUE`, create the archive in
      #'     asynchronous mode, which means that a job is submitted to
      #'     create the archive in background.
      #'   - Extended (logical): If `TRUE`, will include additional
      #'     tags such as `SeriesDescription`, leading to a so-called
      #'     *extended DICOMDIR*. Default value is `TRUE`.
      #'   - Filename (character): Filename to set in the
      #'     "Content-Disposition" HTTP header (including file extension)
      #'   - LossyQuality (numeric): If transcoding to a lossy transfer
      #'     syntax, this entry defines the quality as an integer
      #'     between 1 and 100. If not provided, the value is defined by
      #'     the "DicomLossyTranscodingQuality" configuration. (new in
      #'     v1.12.7)
      #'   - Priority (numeric): In asynchronous mode, the priority of
      #'     the job. The higher the value, the higher the priority.
      #'   - Resources (list): The list of Orthanc identifiers of
      #'     interest.
      #'   - Synchronous (logical): If `TRUE`, create the archive
      #'     in synchronous mode, which means that the HTTP answer
      #'     will directly contain the ZIP file. This is the default,
      #'     easy behavior. However, if global configuration option
      #'     "SynchronousZipStream" is set to "false", asynchronous
      #'     transfers should be preferred for large amount of data, as
      #'     the creation of the temporary file might lead to network
      #'     timeouts.
      #'   - Transcode (character): If present, the DICOM files in the
      #'     archive will be transcoded to the provided transfer syntax:
      #'     https://orthanc.uclouvain.be/book/faq/transcoding.html
      #'   - UserData (list): In asynchronous mode, user data that will
      #'     be attached to the job.
      #'
      #' @return In asynchronous mode, information about the
      #'   job that has been submitted to generate the archive:
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#jobs.
      post_tools_create_media_extended = function(json = NULL) {
        self$POST("/tools/create-media-extended", json = json)
      },

      #' @description Get default encoding
      #'
      #' Get the default encoding that is used by Orthanc if parsing
      #'   a DICOM instance without the `SpecificCharacterEncoding` tag,
      #'   or during C-FIND. This corresponds to the configuration option
      #'   `DefaultEncoding`.
      #'
      #' @family System
      #'
      #' @return The name of the encoding.
      get_tools_default_encoding = function() {
        self$GET("/tools/default-encoding")
      },

      #' @description Set default encoding
      #'
      #' Change the default encoding that is used by Orthanc if parsing
      #'   a DICOM instance without the `SpecificCharacterEncoding` tag,
      #'   or during C-FIND. This corresponds to the configuration option
      #'   `DefaultEncoding`.
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body: The name of the encoding. Check out
      #'   configuration option `DefaultEncoding` for the allowed values.
      #'   (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_default_encoding = function(data = NULL) {
        self$PUT("/tools/default-encoding", data = data)
      },

      #' @description Get DICOM conformance
      #'
      #' Get the DICOM conformance statement of Orthanc
      #'
      #' @family System
      #'
      #' @return The DICOM conformance statement.
      get_tools_dicom_conformance = function() {
        self$GET("/tools/dicom-conformance")
      },

      #' @description Trigger C-ECHO SCU
      #'
      #' Trigger C-ECHO SCU command against a DICOM modality described in
      #'   the POST body, without having to register the modality in some
      #'   `/modalities/{id}` (new in Orthanc 1.8.1)
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - AET (character): AET of the remote DICOM modality
      #'   - CheckFind (logical): Issue a dummy C-FIND command after the
      #'     C-GET SCU, in order to check whether the remote modality
      #'     knows about Orthanc. This field defaults to the value of the
      #'     `DicomEchoChecksFind` configuration option. New in Orthanc
      #'     1.8.1.
      #'   - Host (character): Host address of the remote DICOM modality
      #'     (typically, an IP address)
      #'   - LocalAet (character): Whether to override the default
      #'     DicomAet in the SCU connection initiated by Orthanc to this
      #'     modality
      #'   - Manufacturer (character): Manufacturer of the remote DICOM
      #'     modality (check configuration option `DicomModalities` for
      #'     possible values
      #'   - Port (numeric): TCP port of the remote DICOM modality
      #'   - Timeout (numeric): Whether to override the default
      #'     DicomScuTimeout in the SCU connection initiated by Orthanc
      #'     to this modality
      #'   - UseDicomTls (logical): Whether to use DICOM TLS in the SCU
      #'     connection initiated by Orthanc (new in Orthanc 1.9.0)
      #'
      #' @return Nothing, invisibly.
      post_tools_dicom_echo = function(json = NULL) {
        self$POST("/tools/dicom-echo", json = json)
      },

      #' @description Execute Lua script
      #'
      #' Execute the provided Lua script by the Orthanc server. This is
      #'   very insecure for Orthanc servers that are remotely accessible.
      #'   Since Orthanc 1.5.8, this route is disabled by default and can be
      #'   enabled thanks to the `ExecuteLuaEnabled` configuration.
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body: The Lua script to be executed (text/plain).
      #'
      #' @return Output of the Lua script.
      post_tools_execute_script = function(data = NULL) {
        self$POST("/tools/execute-script", data = data)
      },

      #' @description Look for local resources
      #'
      #' This URI can be used to perform a search on the content
      #'   of the local Orthanc server, in a way that is similar
      #'   to querying remote DICOM modalities using C-FIND SCU:
      #'   https://orthanc.uclouvain.be/book/users/rest.html#performing-finds-within-orthanc
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - CaseSensitive (logical): Enable case-sensitive search for
      #'     PN value representations (defaults to configuration option
      #'     `CaseSensitivePN`)
      #'   - Expand (logical): If set to "true", retrieve detailed
      #'     information about the individual resources, not only their
      #'     Orthanc identifiers
      #'   - Full (logical): If set to `TRUE`, report the DICOM tags
      #'     in full format (tags indexed by their hexadecimal format,
      #'     associated with their symbolic name and their value)
      #'   - Labels (list): List of strings specifying which labels to
      #'     look for in the resources (new in Orthanc 1.12.0)
      #'   - LabelsConstraint (character): Constraint on the labels,
      #'     can be `All`, `Any`, or `None` (defaults to `All`, new in
      #'     Orthanc 1.12.0)
      #'   - Level (character): Level of the query (`Patient`, `Study`,
      #'     `Series` or `Instance`)
      #'   - Limit (numeric): Limit the number of reported resources
      #'   - MetadataQuery (list): Associative array containing the
      #'     filter on the values of the metadata (new in Orthanc 1.12.5)
      #'   - OrderBy (list): Array of associative arrays containing the
      #'     requested ordering (new in Orthanc 1.12.5)
      #'   - ParentPatient (character): Limit the reported resources to
      #'     descendants of this patient (new in Orthanc 1.12.5)
      #'   - ParentSeries (character): Limit the reported resources to
      #'     descendants of this series (new in Orthanc 1.12.5)
      #'   - ParentStudy (character): Limit the reported resources to
      #'     descendants of this study (new in Orthanc 1.12.5)
      #'   - Query (list): Associative array containing the filter on the
      #'     values of the DICOM tags
      #'   - RequestedTags (list): A list of DICOM tags to include in
      #'     the response (applicable only if "Expand" is set to true).
      #'     The tags requested tags are returned in the 'RequestedTags'
      #'     field in the response. Note that, if you are requesting tags
      #'     that are not listed in the Main Dicom Tags stored in DB,
      #'     building the response might be slow since Orthanc will need
      #'     to access the DICOM files. If not specified, Orthanc will
      #'     return all Main Dicom Tags to keep backward compatibility
      #'     with Orthanc prior to 1.11.0.
      #'   - ResponseContent (list): Defines the content of response for
      #'     each returned resource. (this field, if present, overrides
      #'     the "Expand" field). Allowed values are `MainDicomTags`,
      #'     `Metadata`, `Children`, `Parent`, `Labels`, `Status`,
      #'     `IsStable`, `IsProtected`, `Attachments`. If not specified,
      #'     Orthanc will return `MainDicomTags`, `Metadata`, `Children`,
      #'     `Parent`, `Labels`, `Status`, `IsStable`, `IsProtected`.(new
      #'     in Orthanc 1.12.5)
      #'   - Short (logical): If set to `TRUE`, report the DICOM tags in
      #'     hexadecimal format
      #'   - Since (numeric): Show only the resources since the provided
      #'     index (in conjunction with `Limit`)
      #'
      #' @return List containing either the Orthanc identifiers, or
      #'   detailed information about the reported resources (if `Expand`
      #'   argument is `TRUE`).
      post_tools_find = function(json = NULL) {
        self$POST("/tools/find", json = json)
      },

      #' @description Generate an identifier
      #'
      #' Generate a random DICOM identifier
      #'
      #' @param level (character) Type of DICOM resource among: `patient`,
      #'   `study`, `series` or `instance`.
      #'
      #' @family System
      #'
      #' @return The generated identifier.
      get_tools_generate_uid = function(level = NULL) {
        self$GET("/tools/generate-uid", level = level)
      },

      #' @description Invalidate DICOM-as-JSON summaries
      #'
      #' Remove all the attachments of the type "DICOM-as-JSON"
      #'   that are associated will all the DICOM instances stored
      #'   in Orthanc. These summaries will be automatically
      #'   re-created on the next access. This is notably useful
      #'   after changes to the `Dictionary` configuration option.
      #'   https://orthanc.uclouvain.be/book/faq/orthanc-storage.html#storage-area
      #'
      #' @family System
      #'
      #' @return Nothing, invisibly.
      post_tools_invalidate_tags = function() {
        self$POST("/tools/invalidate-tags")
      },

      #' @description Get all the used labels
      #'
      #' List all the labels that are associated with any resource of the
      #'   Orthanc database
      #'
      #' @family System
      #'
      #' @return List containing the labels.
      get_tools_labels = function() {
        self$GET("/tools/labels")
      },

      #' @description Get main log level
      #'
      #' Get the main log level of Orthanc
      #'
      #' @family Logs
      #'
      #' @return Possible values: `default`, `verbose` or `trace`.
      get_tools_log_level = function() {
        self$GET("/tools/log-level")
      },

      #' @description Set main log level
      #'
      #' Set the main log level of Orthanc
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Logs
      #'
      #' @details
      #' Request body: Possible values: `default`, `verbose` or `trace`
      #'   (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_log_level = function(data = NULL) {
        self$PUT("/tools/log-level", data = data)
      },

      #' @description Get log level for `dicom`
      #'
      #' Get the log level of the log category `dicom`
      #'
      #' @family Logs
      #'
      #' @return Possible values: `default`, `verbose` or `trace`.
      get_tools_log_level_dicom = function() {
        self$GET("/tools/log-level-dicom")
      },

      #' @description Set log level for `dicom`
      #'
      #' Set the log level of the log category `dicom`
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Logs
      #'
      #' @details
      #' Request body: Possible values: `default`, `verbose` or `trace`
      #'   (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_log_level_dicom = function(data = NULL) {
        self$PUT("/tools/log-level-dicom", data = data)
      },

      #' @description Get log level for `generic`
      #'
      #' Get the log level of the log category `generic`
      #'
      #' @family Logs
      #'
      #' @return Possible values: `default`, `verbose` or `trace`.
      get_tools_log_level_generic = function() {
        self$GET("/tools/log-level-generic")
      },

      #' @description Set log level for `generic`
      #'
      #' Set the log level of the log category `generic`
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Logs
      #'
      #' @details
      #' Request body: Possible values: `default`, `verbose` or `trace`
      #'   (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_log_level_generic = function(data = NULL) {
        self$PUT("/tools/log-level-generic", data = data)
      },

      #' @description Get log level for `http`
      #'
      #' Get the log level of the log category `http`
      #'
      #' @family Logs
      #'
      #' @return Possible values: `default`, `verbose` or `trace`.
      get_tools_log_level_http = function() {
        self$GET("/tools/log-level-http")
      },

      #' @description Set log level for `http`
      #'
      #' Set the log level of the log category `http`
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Logs
      #'
      #' @details
      #' Request body: Possible values: `default`, `verbose` or `trace`
      #'   (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_log_level_http = function(data = NULL) {
        self$PUT("/tools/log-level-http", data = data)
      },

      #' @description Get log level for `jobs`
      #'
      #' Get the log level of the log category `jobs`
      #'
      #' @family Logs
      #'
      #' @return Possible values: `default`, `verbose` or `trace`.
      get_tools_log_level_jobs = function() {
        self$GET("/tools/log-level-jobs")
      },

      #' @description Set log level for `jobs`
      #'
      #' Set the log level of the log category `jobs`
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Logs
      #'
      #' @details
      #' Request body: Possible values: `default`, `verbose` or `trace`
      #'   (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_log_level_jobs = function(data = NULL) {
        self$PUT("/tools/log-level-jobs", data = data)
      },

      #' @description Get log level for `lua`
      #'
      #' Get the log level of the log category `lua`
      #'
      #' @family Logs
      #'
      #' @return Possible values: `default`, `verbose` or `trace`.
      get_tools_log_level_lua = function() {
        self$GET("/tools/log-level-lua")
      },

      #' @description Set log level for `lua`
      #'
      #' Set the log level of the log category `lua`
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Logs
      #'
      #' @details
      #' Request body: Possible values: `default`, `verbose` or `trace`
      #'   (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_log_level_lua = function(data = NULL) {
        self$PUT("/tools/log-level-lua", data = data)
      },

      #' @description Get log level for `plugins`
      #'
      #' Get the log level of the log category `plugins`
      #'
      #' @family Logs
      #'
      #' @return Possible values: `default`, `verbose` or `trace`.
      get_tools_log_level_plugins = function() {
        self$GET("/tools/log-level-plugins")
      },

      #' @description Set log level for `plugins`
      #'
      #' Set the log level of the log category `plugins`
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Logs
      #'
      #' @details
      #' Request body: Possible values: `default`, `verbose` or `trace`
      #'   (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_log_level_plugins = function(data = NULL) {
        self$PUT("/tools/log-level-plugins", data = data)
      },

      #' @description Get log level for `sqlite`
      #'
      #' Get the log level of the log category `sqlite`
      #'
      #' @family Logs
      #'
      #' @return Possible values: `default`, `verbose` or `trace`.
      get_tools_log_level_sqlite = function() {
        self$GET("/tools/log-level-sqlite")
      },

      #' @description Set log level for `sqlite`
      #'
      #' Set the log level of the log category `sqlite`
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family Logs
      #'
      #' @details
      #' Request body: Possible values: `default`, `verbose` or `trace`
      #'   (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_log_level_sqlite = function(data = NULL) {
        self$PUT("/tools/log-level-sqlite", data = data)
      },

      #' @description Look for DICOM identifiers
      #'
      #' This URI can be used to convert one DICOM identifier to a list of
      #'   matching Orthanc resources
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body: The DICOM identifier of interest (i.e. the value
      #'   of `PatientID`, `StudyInstanceUID`, `SeriesInstanceUID`, or
      #'   `SOPInstanceUID`) (text/plain).
      #'
      #' @return List containing a list of matching Orthanc
      #'   resources, each item in the list corresponding to a JSON object
      #'   with the fields `Type`, `ID` and `Path` identifying one DICOM
      #'   resource that is stored by Orthanc.
      post_tools_lookup = function(data = NULL) {
        self$POST("/tools/lookup", data = data)
      },

      #' @description Are metrics collected?
      #'
      #' Returns a Boolean specifying whether Prometheus metrics are
      #'   collected and exposed at `/tools/metrics-prometheus`
      #'
      #' @family System
      #'
      #' @return `1` if metrics are collected, `0` if metrics are
      #'   disabled.
      get_tools_metrics = function() {
        self$GET("/tools/metrics")
      },

      #' @description Enable collection of metrics
      #'
      #' Enable or disable the collection and publication of metrics at
      #'   `/tools/metrics-prometheus`
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body: `1` if metrics are collected, `0` if metrics are
      #'   disabled (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_metrics = function(data = NULL) {
        self$PUT("/tools/metrics", data = data)
      },

      #' @description Get usage metrics
      #'
      #' Get usage metrics of Orthanc in the
      #'   Prometheus file format (OpenMetrics):
      #'   https://orthanc.uclouvain.be/book/users/advanced-rest.html#instrumentation-with-prometheus
      #'
      #' @family System
      #'
      #' @return Nothing, invisibly.
      get_tools_metrics_prometheus = function() {
        self$GET("/tools/metrics-prometheus")
      },

      #' @description Get UTC time
      #'
      #' Get UTC time
      #'
      #' @family System
      #'
      #' @return The UTC time.
      get_tools_now = function() {
        self$GET("/tools/now")
      },

      #' @description Get local time
      #'
      #' Get local time
      #'
      #' @family System
      #'
      #' @return The local time.
      get_tools_now_local = function() {
        self$GET("/tools/now-local")
      },

      #' @description Reconstruct all the index
      #'
      #' Reconstruct the index of all the tags of all the DICOM instances
      #'   that are stored in Orthanc. This is notably useful after the
      #'   deletion of resources whose children resources have inconsistent
      #'   values with their sibling resources. Beware that this is a highly
      #'   time-consuming operation, as all the DICOM instances will be
      #'   parsed again, and as all the Orthanc index will be regenerated.
      #'   If you have a large database to process, it is advised to use the
      #'   Housekeeper plugin to perform this action resource by resource
      #'
      #' @param json (list) Named-list for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body JSON schema (application/json):
      #'   - ReconstructFiles (logical): Also reconstruct the
      #'     files of the resources (e.g: apply IngestTranscoding,
      #'     StorageCompression). 'false' by default. (New in Orthanc
      #'     1.11.0)
      #'
      #' @return Nothing, invisibly.
      post_tools_reconstruct = function(json = NULL) {
        self$POST("/tools/reconstruct", json = json)
      },

      #' @description Restart Orthanc
      #'
      #' Restart Orthanc
      #'
      #' @family System
      #'
      #' @return Nothing, invisibly.
      post_tools_reset = function() {
        self$POST("/tools/reset")
      },

      #' @description Shutdown Orthanc
      #'
      #' Shutdown Orthanc
      #'
      #' @family System
      #'
      #' @return Nothing, invisibly.
      post_tools_shutdown = function() {
        self$POST("/tools/shutdown")
      },

      #' @description Is unknown SOP class accepted?
      #'
      #' Shall Orthanc C-STORE SCP accept DICOM instances with an unknown
      #'   SOP class UID?
      #'
      #' @family System
      #'
      #' @return `1` if accepted, `0` if not accepted.
      get_tools_unknown_sop_class_accepted = function() {
        self$GET("/tools/unknown-sop-class-accepted")
      },

      #' @description Set unknown SOP class accepted
      #'
      #' Set whether Orthanc C-STORE SCP should accept DICOM instances
      #'   with an unknown SOP class UID
      #'
      #' @param data (bytes or character) Raw data for request body. See Details.
      #'
      #' @family System
      #'
      #' @details
      #' Request body: `1` if accepted, `0` if not accepted
      #'   (text/plain).
      #'
      #' @return Nothing, invisibly.
      put_tools_unknown_sop_class_accepted = function(data = NULL) {
        self$PUT("/tools/unknown-sop-class-accepted", data = data)
      }
    ),
    active = list(
      #' @field num_instances Number of instances.
      num_instances = function() {
        length(self$get_instances())
      },

      #' @field num_series Number of series.
      num_series = function() {
        length(self$get_series())
      },

      #' @field num_studies Number of studies.
      num_studies = function() {
        length(self$get_studies())
      },

      #' @field num_patients Number of patients.
      num_patients = function() {
        length(self$get_patients())
      }
    ),
    private = list(
      need_auth = FALSE,
      username = NULL,
      password = NULL,
      setup_credentials = function(username, password) {
        if (rlang::is_null(username) & rlang::is_null(password)) {
          return(invisible())
        }

        if (!rlang::is_null(username) & nchar(username) > 0) {
          private$username <- orthanc_credential(username)
          private$need_auth <- TRUE
        }

        if (!rlang::is_null(password) & nchar(password) > 0) {
          private$password <- orthanc_credential(password)
        }

        invisible()
      },
      auth_basic = function(req) {
        if (!private$need_auth) {
          return(req)
        }
        req |>
          httr2::req_auth_basic(
            username = private$username,
            password = private$password
          )
      },
      request_build = function(route, params, headers, cookies, method) {
        httr2::request(self$url) |>
          httr2::req_url_path_append(route) |>
          httr2::req_url_query(!!!params) |>
          httr2::req_headers(!!!headers) |>
          httr2::req_cookies_set(!!!cookies) |>
          private$auth_basic() |>
          httr2::req_method(method) |>
          httr2::req_user_agent(
            "orthanc (https://github.com/mattwarkentin/orthanc)"
          )
      },
      include_content = function(req, file, json, data) {
        if (!rlang::is_missing(file)) {
          ext <- tools::file_ext(file)

          req <-
            req |>
            httr2::req_body_file(file)

          if (ext == 'dcm') {
            req <- req |>
              httr2::req_headers("Content-Type" = "application/dicom")
          } else if (ext == 'zip') {
            req <- req |>
              httr2::req_headers("Content-Type" = "application/zip")
          } else {
            rlang::abort(
              message = glue::glue(
                "File type (.{ext}) not supported. Must be a DICOM file (.dcm) or ZIP archive (.zip)."
              ),
              call = rlang::caller_env(2)
            )
          }
        }

        if (!rlang::is_missing(data)) {
          req <-
            req |>
            httr2::req_body_raw(data)

          if (httr2::req_get_body_type(req) == 'raw') {
            req <-
              req |>
              httr2::req_headers("Content-Type" = "application/octet-stream")
          } else {
            req <-
              req |>
              httr2::req_headers("Content-Type" = "text/plain")
          }
        }

        if (!rlang::is_missing(json)) {
          req <-
            req |>
            httr2::req_body_json(json) |>
            httr2::req_headers("Content-Type" = "application/json")
        }
        req
      },
      request_perform = function(req) {
        resp <- httr2::req_perform(req)
        private$response_process(req, resp)
      },
      request_perform_stream = function(req) {
        resp_con <- httr2::req_perform_connection(req)
        resp_con
      },
      response_process = function(req, resp) {
        stopifnot(inherits(resp, "httr2_response"))

        content_type <- httr2::resp_content_type(resp)

        is_empty <- length(resp$body) == 0

        if (resp$status_code >= 200 & resp$status_code < 300) {
          if (is_empty) {
            return(invisible())
          } else if (
            grepl("^application/json", content_type, ignore.case = TRUE)
          ) {
            res <- httr2::resp_body_json(resp)
          } else if (grepl("^text/html", content_type, ignore.case = TRUE)) {
            res <- httr2::resp_body_html(resp)
          } else if (grepl("^text/plain", content_type, ignore.case = TRUE)) {
            res <- httr2::resp_body_string(resp)
          } else {
            res <- httr2::resp_body_raw(resp)
          }
        }

        class(res) <- c("orthanc_response", class(res))
        res
      }
    )
  )

default_api_url <- function() {
  Sys.getenv("ORTHANC_API_URL", unset = "http://localhost:8042")
}
