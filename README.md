# SPARQL-parser-base

This repository generates a [ANTLR-v4-based](https://github.com/antlr/antlr4) [SPARQL 1.0](https://www.w3.org/TR/rdf-sparql-query/) and [SPARQL 1.1](https://www.w3.org/TR/sparql11-overview/) parser in C++. The ANTLR v4 code generator is called by CMake.

## requirements

- C++17 compatible compiler
- only tested on linux, x86_64
- see [Dockerfile](Dockerfile) for details 

## build it

```shell
#get it 
git clone https://github.com/dice-group/sparql-parser-base.git
cd sparql-base-parser
#build it
mkdir build
cd build
cmake  -DCMAKE_BUILD_TYPE=Release ..
make -j sparql-parser-base
```

There are three project-specific options you can set for CMake:

- `SPARQL_BASE_PARSER_WITH_LIBCXX`: Building with libc++ (in Linux). To enable with: `-DSPARQL_BASE_PARSER_WITH_LIBCXX=On`
- `SPARQL_BASE_PARSER_MARCH`: Allows you to set the -march parameter. If you are building for your local machine, you should set it to `-DSPARQL_BASE_PARSER_MARCH=native`
- `SPARQL_BASE_PARSER_SPARQL_VERSION`: You can switch between SPARQL1.0 and SPARQL1.1 parsers being generated. The parsers for SPARQL1.0 and SPARQL1.1 are not API compatible. Default is SPARQL1.1. To generate a SPARQL1.0 instead, switch the version with: `-DSPARQL_BASE_PARSER_SPARQL_VERSION="1.0"`   

## conan

To use it with [conan](https://conan.io/) you need to add the repository:
```shell
conan remote add dice-group https://api.bintray.com/conan/dice-group/tentris
```

To use it add `sparql-parser-base/0.2.0@dice-group/stable` to the `[requires]` section of your conan file.
By default, this uses SPARQL1.1. 
If you want to use SPARQL1.0 instead, add `sparql-parser-base:sparql_version=1.0` to the `[options]` section of your conan file.

