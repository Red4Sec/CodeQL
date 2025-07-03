<p align="center">
  <a href="https://red4sec.com" target="_blank"><img src="https://red4sec.com/assets/img/logo.png" width="200px"></a>
</p>
<h1 align="center">
Red4Sec Cybersecurity
</h1>

Repository with several interesting Docker setups, including CodeQL CLI with support for multiple programming languages.

## Structure

- `CodeQL/`
  - `CodeQL.dockerfile`: Dockerfile to build the image with CodeQL and required tools.
  - `README.md`: Specific documentation for the CodeQL container.

## Description

This repository provides an easy-to-use environment for code analysis using CodeQL inside an Ubuntu 24.04 based Docker container. It includes:

- Latest version of CodeQL CLI.
- Support for languages: Go, Rust, Java, C++, Python, JavaScript, C#.
- Necessary tools and runtimes like Go, Rust, .NET SDK, Node.js, Python, and Java.
