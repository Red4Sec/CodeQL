<p align="center">
  <a href="https://red4sec.com" target="_blank"><img src="https://red4sec.com/assets/img/logo.png" width="200px"></a>
</p>
<h1 align="center">
Red4Sec Cybersecurity
</h1>


This repository provides an easy-to-use environment for code analysis using CodeQL inside an Ubuntu 24.04 based Docker container. It includes:

Latest version of CodeQL CLI.
Support for languages: Go, Rust, Java, C++, Python, JavaScript, C#.
Necessary tools and runtimes like Go, Rust, .NET SDK, Node.js, Python, and Java.

## Features

- Installs CodeQL CLI from the latest official release.
- Supports code analysis for Go, Rust, C++, JavaScript, Python, C#, and Java.
- Installs Go and Rust for compilation and analysis.
- Includes .NET SDK 9.0.
- Node.js 24.0.2 installed via NVM with npm updated.
- Python 3 with a configured virtual environment.
- Default Java JDK installed.

## Usage

Build the image:

```bash
docker build -t codeql-container -f CodeQL.dockerfile .
```

## Next Steps

- Add usage examples.
- Include more languages or custom configurations.

## References

- [CodeQL CLI Manual](https://docs.github.com/en/code-security/codeql-cli/codeql-cli-manual/query-compile)
- [Official CodeQL Container Repository](https://github.com/microsoft/codeql-container)
