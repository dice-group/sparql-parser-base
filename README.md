# SPARQL-parser-base

[ANTLR-v4-based](https://github.com/antlr/antlr4)-based C++17 parser for [SPARQL 1.1](https://www.w3.org/TR/sparql11-overview/)
with visitors and listeners. During CMake configuration, the ANTLR v4 code generator is called. 

## Requirements

- C++17 compatible compiler
- Only tested on linux, x86_64
- Conan installed or antlr4-runtime available via CMake's find_package

## Usage

### As Conan Package

It is available via the artifactory of the [DICE Research Group](https://dice-research.org/).

You need the [package manager Conan](https://conan.io/downloads.html) installed and set up. You can add the DICE
artifactory with:

```shell
conan remote add dice-group https://conan.dice-research.org/artifactory/api/conan/tentris
```

To use sparql-parser-base, add it to your `conanfile.txt`:

```
[requires]
sparql-parser-base/0.3.9
```

### With FetchContent

Use 

```
include(FetchContent)
FetchContent_Declare(
        sparql-parser-base
        GIT_REPOSITORY "${CMAKE_CURRENT_SOURCE_DIR}/../"
        GIT_TAG 0.3.9
        GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(sparql-parser-base)
```

to make the library target `sparql-parser-base::sparql-parser-base` available.

Beware: Conan will not be used for dependency retrieval if you include sparql-parser-base via FetchContent. It is your
responsibility that all dependencies are available before.

## Build

```shell
#get it 
git clone https://github.com/dice-group/sparql-parser-base.git
cd sparql-base-parser
#build it
mkdir build
cd build
cmake  -DCMAKE_BUILD_TYPE=Release .. # uses conan by default if installed
make -j sparql-parser-base
```

### CMake Config Options:

`-DBUILD_EXAMPLES=ON/OFF [default: OFF]`: Build the examples.



`-DANTLR4_TAG=... [default: "4.13.1"]`: ANTLR4 version to be used.

`-DCONAN_CMAKE=ON/OFF [default: ON]`: If available, use Conan to retrieve dependencies.