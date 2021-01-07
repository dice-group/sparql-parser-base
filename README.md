# SPARQL-parser-base

This repository generates a [ANTLR-v4](https://github.com/antlr/antlr4) -based [SPARQL 1.1](https://www.w3.org/TR/sparql11-overview/) parser in C++. The ANTLR v4 code generator is called by CMake.

## requirements

see [Dockerfile](Dockerfile). 

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

There are two project-specific options you can set for CMake:

- `SPARQL_BASE_PARSER_WITH_LIBCXX`: Building with libc++ (in Linux). To enable with: `-DSPARQL_BASE_PARSER_WITH_LIBCXX=On`
- `SPARQL_BASE_PARSER_MARCH`: Allows you to set the -march parameter. If you are building for your local machine, you should set it to `-DSPARQL_BASE_PARSER_MARCH=native` 

## conan

To use it with [conan](https://conan.io/) you need to add the repository:
```shell
conan remote add dice-group https://api.bintray.com/conan/dice-group/tentris
```

To use it add `sparql-parser-base/0.1.1@dice-group/stable` to your conan file. 
