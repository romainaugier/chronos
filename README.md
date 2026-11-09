# chronos

[![CI](https://github.com/romainaugier/chronos/actions/workflows/ci.yml/badge.svg)](https://github.com/romainaugier/chronos/actions/workflows/ci.yml)

chronos is a strategy tester (backtesting engine) written in C++17. Strategies are written in a small Python-like language, JIT-compiled with LLVM.

Work in progress.

## Dependencies

- [stdromano](https://github.com/romainaugier/stdromano), as a git submodule in `ext/stdromano`. The build scripts build and install it in `ext/stdromano/install` with the same build type, architecture and sanitizers as chronos, and rebuild it only when these change. stdromano gets its own dependencies (mimalloc) through vcpkg, cloned on its first build

Clone with the submodules:
```bash
git clone --recursive https://github.com/romainaugier/chronos.git
```

or in an existing clone:
```bash
git submodule update --init --recursive
```

To use another stdromano install, configure with `-Dstdromano_DIR=<install>/cmake`.

## Build and tests

Build scripts are used to build, test and install for different targets (they are wrappers around the CMake command line).
The following arguments are used:
 - `--debug`: builds in debug (default is release)
 - `--reldebug`: builds in release with debug info
 - `--tests`: builds and runs the tests
 - `--clean`: cleans the previous build/install
 - `--install`: creates an installation (default directory is $(pwd)/install)
 - `--installdir:<path>`: specifies where to install the library
 - `--version:<x.x.x>`: specifies the build version (`--version:MAJOR.MINOR.PATCH`)
 - `--addrsan`: builds using the address sanitizer
 - `--leaksan`: builds using the leak sanitizer (not available on macOS and Windows)
 - `--ubsan`: builds using the undefined behavior sanitizer (GCC/Clang)
 - `--threadsan`: builds using the thread sanitizer (GCC/Clang, cannot be combined with `--addrsan` or `--leaksan`)
 - `--coverage`: builds with code coverage instrumentation (GCC/Clang)
 - `--vectorize-report`: prints the loops vectorized by the compiler (GCC/Clang)
 - `--export-compile-commands`: copies compile_commands.json to the root directory (not available on Windows)
 - `--arch:<x64|arm64>`: target architecture (Windows only, defaults to the host)
 - `--rebuild-stdromano`: rebuilds and reinstalls stdromano even if it is up to date (after updating the submodule)
 - `--vcpkgpath:<path>`: uses an existing vcpkg repository for the stdromano dependencies

On Windows, only `--addrsan` is available among the sanitizers.

On Linux and macOS:
```bash
./build.sh --tests
```

On Windows:
```bat
build --tests
```

## CI

The CI builds and runs the tests in Release and Debug on Linux (x64, arm64), macOS (arm64) and Windows (x64, arm64), and with the sanitizers (ASan + UBSan + LSan, TSan) on Linux x64.

## License

BSD-3-Clause, see [LICENSE](LICENSE).
