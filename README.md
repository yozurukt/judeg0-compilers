# Judge0 Compilers (Optimized Edition)

A high-performance, modernized Docker image containing compilers, interpreters, and the [Isolate](https://github.com/ioi/isolate) sandbox. Designed for competitive programming platforms and online judges.

## ✨ Key Features

*   **Cutting-Edge Toolchain**:
    *   **GCC 15.2** & **Clang 21**: Defaulting to **C23** and **C++23** standards.
    *   **Java 21 LTS** & **Java 25 LTS**: Latest OpenJDK builds.
    *   **Python 3.14** & **Node.js 24**: Modern scripting environments.
    *   **Kotlin 1.9 & 2.3**: Full Kotlin support.
*   **Optimized Performance**:
    *   **Fast Builds**: Uses multi-stage Docker builds to copy pre-compiled binaries, reducing build time from minutes to seconds.
    *   **Auto-Imported Headers**: Common headers (std.h, stdc++.h) are automatically included, and common classes (Scanner, Collection) are pre-imported for convenience.
*   **Security First**:
    *   Includes **Isolate** sandbox pre-installed from official Debian repositories.
    *   Configured with reasonable memory and process limits.

## 🚀 Quick Start

### Build the Image
```bash
docker pull yozuru/judge0-compilers:latest .
```

### Verify Installation
Run the included test suite to verify all compilers are compiling and executing code correctly:
```bash
bin/run-tests
```
Expect output:
```text
--- C (Clang 21) ---
Hello, Yozuru
--- C++ (GCC 15.2) ---
Hello, Yozuru
...
```

## 🛠️ Supported Languages

| Language | Version | Source | Standards |
|----------|---------|--------|-----------|
| **C** | GCC 15.2 / Clang 21 | Official Docker Images | C23 (`-std=c23`) |
| **C++** | GCC 15.2 / Clang 21 | Official Docker Images | C++23 (`-std=c++23`) |
| **Java** | 21 / 25 | Eclipse Temurin | OpenJDK |
| **Python** | 3.14.2 | Official Slim Image | Standard |
| **Node.js** | 24.13.0 | Official Slim Image | Standard |
| **Kotlin** | 1.9.0 / 2.3.0 | GitHub Releases | JVM |
| **Bash** | 5.2.37 | Debian Bookworm | Standard |

## ⚙️ Configuration

The project includes a `generate_json.py` script to generate a `db.json` configuration file for use with Judge0 or compatible systems.

## 📄 License

This project is licensed under the **GNU General Public License v3.0**.

Original work Copyright (C) 2017 Herman Zvonimir Došilović.

Modifications Copyright (C) 2026 Yozuru.

See [LICENSE](LICENSE) for details.
