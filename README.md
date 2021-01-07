# SPARQL-parser-base

This repository generates a [ANTLR-v4](https://github.com/antlr/antlr4)-based [SPARQL 1.0](https://www.w3.org/TR/rdf-sparql-query/) parser in C++. The ANTLR v4 code generator is called by CMake. 

## requirements

see [Dockerfile](Dockerfile). Currently builds only with gcc. 

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

## conan

To use it with [conan](https://conan.io/) you need to add the repository:
```shell
conan remote add dice-group https://api.bintray.com/conan/dice-group/tentris
```

To use it add `sparql-parser-base/0.1.0@dice-group/stable` to your conan file. 
