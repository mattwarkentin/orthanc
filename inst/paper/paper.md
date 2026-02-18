---
title: 'orthanc: An R Interface for Orthanc DICOM Servers'
tags:
- R
- Orthanc
- Medical physics
- Medical imaging
date: "4 February 2026"
authors:
- name: Matthew T. Warkentin
  corresponding: true
  orcid: 0000-0001-8730-3511
  email: matthew.warkentin@ucalgary.ca
  affiliation: 1
affiliations:
- name: Department of Oncology, Cumming School of Medicine, University of Calgary, Calgary, AB, Canada
  index: 1
bibliography: paper.bib
---

# Summary

Medical imaging plays a central role in modern biomedical research and clinical practice. The Digital Imaging and Communications in Medicine (DICOM) standard underpins the storage, exchange, and management of medical images across modalities such as computed tomography (CT), magnetic resonance imaging (MRI), positron emission tomography (PET), ultrasound, and digital pathology [@dicom2020]. As imaging data become increasingly integrated into quantitative research workflows, particularly in artificial intelligence (AI) and machine learning (ML), there is a growing need for robust, reproducible, and programmatic access to imaging archives.

Over the past decade, there has been an explosion in the volume of medical imaging data generated worldwide. Advances in imaging technology, increased clinical utilization, multi-phase acquisition protocols, and the growth of large-scale research cohorts have resulted in rapidly expanding DICOM archives. Modern scanners routinely produce hundreds to thousands of slices per study, and longitudinal imaging further multiplies data volume per patient. This dramatic growth in image data intensifies the need for scalable, programmatic tools to efficiently query, manage, and analyze imaging repositories.

Orthanc is a lightweight, open-source DICOM server that exposes a comprehensive REST API for managing, querying, retrieving, and modifying DICOM resources [@jodogne2018orthanc]. It is widely adopted in research settings due to its ease of deployment, extensibility, and compliance with DICOM standards. While Orthanc provides a powerful HTTP-based interface, interacting with its REST API directly requires manual construction of requests, careful handling of authentication and responses, and detailed knowledge of Orthanc’s resource hierarchy.

The `orthanc` R package provides a high-level, idiomatic interface to the Orthanc REST API for the R language [@orthanc]. Inspired by the design and usability of the PyOrthanc Python package [@couture2025pyorthanc], `orthanc` enables R users to interact programmatically with Orthanc servers using familiar R paradigms. The package abstracts HTTP details, models DICOM resources as structured R objects, and supports reproducible workflows for querying, retrieving, filtering, and managing imaging data. By bridging Orthanc and R ecosystems, `orthanc` facilitates imaging-based research, statistical analysis, and AI development within a unified environment.

# Statement of Need

Medical imaging has become foundational to precision medicine, population health research, and the development of AI-driven diagnostic and prognostic tools. Large-scale imaging cohorts, hospital-based archives, and multi-center research studies generate terabytes to petabytes of DICOM data. These datasets are increasingly used to train predictive models, extract radiomic features, validate quantitative biomarkers, and integrate imaging with clinical and genomic data. As a result, the ability to programmatically access and manage DICOM data is now a core requirement for many data scientists.

DICOM is the international standard for medical imaging. It defines not only file formats but also metadata structures, hierarchical relationships (Patient -> Study -> Series -> Instance), and communication protocols. While DICOM ensures interoperability, it is inherently complex. Navigating DICOM metadata, managing identifiers, extracting encapsulated or embedded documents (e.g., PDF)and handling binary pixel data can be technically demanding, especially when interacting with remote servers.

Orthanc addresses many of these challenges by providing a modern, RESTful interface to DICOM archives. It supports storage, search, anonymization, modification, plugin-based extensions, and integration with external systems. Its REST API exposes resources corresponding to patients, studies, series, and instances, as well as endpoints for querying metadata, downloading files, and performing server-side operations. Orthanc has therefore become a popular choice in academic and research settings, where flexibility and open-source tooling are essential.

Despite its strengths, interacting directly with the Orthanc REST API presents several challenges:

1. Low-level HTTP handling: Users must construct requests, manage authentication headers, handle response codes, and parse responses.

2. Hierarchical resource navigation: Traversing patients, studies, series, and instances requires repeated calls and careful bookkeeping of identifiers.

3. Error handling and robustness: Direct API use requires explicit management of network failures, timeouts, and malformed responses.

4. Reproducibility and abstraction: Embedding raw HTTP calls within analytical scripts can reduce clarity and hinder maintainability.

In the Python ecosystem, packages such as PyOrthanc provide higher-level abstractions that simplify these interactions. However, the R ecosystem has lacked a comparable, dedicated interface to Orthanc. The `orthanc` R package has been designed with the goal of achieving feature parity with PyOrthanc, providing comparable resource abstractions, querying capabilities, and server interactions so that R users can access a similarly complete and expressive interface to the Orthanc REST API.

Without a dedicated interface, R users must either rely on _ad hoc_ HTTP code, external scripts in other languages, or manual exports from Orthanc, introducing inefficiencies and potential reproducibility issues. The `orthanc` package addresses this gap by providing an R-native, object-oriented interface to the Orthanc REST API. It enables researchers to remain within the R environment for the entire imaging workflow: from data discovery and retrieval to downstream statistical analysis and AI model development. By reducing boilerplate HTTP code and encapsulating Orthanc’s resource model in intuitive R classes and functions, `orthanc` lowers the barrier to entry and promotes reproducible imaging research.

# Features and Functionality

The `orthanc` package provides a comprehensive and user-friendly interface to the Orthanc REST API, designed to align with idiomatic R workflows while preserving the structure and semantics of DICOM resources. 

The `orthanc` package leverages the `httr2` R package for HTTP communication [@httr2], providing a modern, robust, and well-structured framework for constructing requests, handling authentication, managing errors, and processing responses, thereby ensuring reliable and maintainable interactions with the Orthanc REST API. The package also utilizes `mirai` to provide an asynchronous client interface, enabling non-blocking API requests and concurrent operations that improve performance and scalability when interacting with large imaging archives [@mirai].

## Client Abstraction

At the core of the package is an R6-based client object that represents a connection to an Orthanc server. Implemented using R6 object-oriented programming, the client encapsulates:
 
+ Server URL configuration
+ Authentication credentials
+ HTTP request handling
+ Response parsing and binary data management

Using R6 allows the client to maintain state (e.g., base URL, authentication headers, configuration options) across method calls, providing a natural and efficient interface for repeated interactions with an Orthanc server [@R6]. Methods on the client object wrap Orthanc REST endpoints, abstracting low-level HTTP details and returning structured R objects rather than raw responses. This design promotes clarity, reuse, and testability while shielding users from the complexities of direct API interaction.

## Object-Oriented Representation of DICOM Resources

The package models Orthanc resources (patients, studies, series, and instances) as R6 classes that respect the DICOM hierarchy. Each resource is represented as an R6 object that:

+ Encapsulates the corresponding Orthanc identifier
+ Maintains a reference to the originating client
+ Provides methods and fields to retrieve metadata
+ Supports navigation across hierarchical relationships
+ Enables downloading of DICOM files or pixel data

By leveraging R6, these objects combine data and behavior, allowing users to interact with DICOM resources through intuitive method calls (e.g., retrieving child resources or accessing metadata) while preserving internal state. The use of R6 supports encapsulation, inheritance where appropriate, and clean separation of public and private methods, making the API expressive yet structured.

Reflecting the DICOM hierarchy directly in R6 classes enables intuitive traversal of imaging archives (e.g., from patient to study to series to instance) and promotes readable, object-oriented workflows within the R environment.

## Querying and Filtering

`orthanc` provides high-level functions to query and filter DICOM resources based on metadata. Users can:

+ Search for patients or studies using DICOM tags
+ Apply predicate functions (filters) in R to refine results
+ Iterate across resources using vectorized or functional programming tools

This design integrates naturally with the programming paradigms common in modern R workflows.

## Data Retrieval and Management

The package supports:

+ Downloading DICOM instances as raw binary data
+ Exporting resources to disk
+ Accessing and modifying metadata
+ Performing anonymization and other server-side operations (when supported by the Orthanc configuration)

Binary handling is abstracted so users can focus on analysis rather than low-level file management.

## Asynchronous Parallelization and Scalability

To support high-throughput imaging workflows, `orthanc` integrates asynchronous execution via the `mirai` R package [@mirai]. This enables non-blocking API requests and concurrent operations across multiple Orthanc resources, which is particularly valuable when querying large cohorts, uploading or retrieveing many DICOM resources, or performing repeated metadata lookups. By allowing requests to be dispatched and resolved in parallel using background R processes, the package improves responsiveness and overall throughput in data-intensive research settings.

The `mirai` framework is built on top of `nanonext` [@nanonext], an R interface to the Nanomsg Next Generation (NNG) messaging library. This architecture provides a lightweight, high-performance, message-passing infrastructure that supports scalable parallel computation with minimal overhead. By leveraging `mirai` and its NNG-based backend, `orthanc` offers a robust and efficient asynchronous client model that scales from local multicore environments to distributed systems, while maintaining a simple and idiomatic R interface. 

## Integration with the R Ecosystem

By operating natively in R, `orthanc` enables seamless integration with:

+ Statistical modeling packages
+ Machine learning frameworks
+ Visualization tools
+ Reproducible reporting systems (e.g., R Markdown, Quarto)

This integration is particularly valuable for imaging-based AI workflows, where DICOM metadata and derived features must be linked to clinical outcomes and analyzed statistically.

# Conclusion

In summary, `orthanc` fills a critical gap in the R ecosystem by providing a robust, high-level interface to the Orthanc DICOM server. As medical imaging continues to drive innovation in AI and quantitative research, accessible and reproducible tools for managing DICOM data are essential. By simplifying interaction with Orthanc and embedding imaging workflows directly within R, `orthanc` supports the growing community of researchers working at the intersection of imaging, statistics, and data science.

# Acknowledgements

We gratefully acknowledge the authors and maintainers of Orthanc for developing and maintaining an open-source, standards-compliant DICOM server that has become an essential tool in medical imaging research. Orthanc’s thoughtful design, comprehensive REST API, and commitment to openness have made it possible for researchers to build reproducible and extensible imaging workflows across institutions and disciplines. The continued development of open-source infrastructure is foundational to collaborative, transparent, and reproducible research in medical imaging.

We also thank the authors and contributors of PyOrthanc, whose work provided important conceptual and design inspiration for this package. Their efforts in creating a clear and accessible programmatic interface to Orthanc in the Python ecosystem helped inform the structure and usability goals of the `orthanc` R package.

# References
