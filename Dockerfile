FROM ubuntu:groovy AS builder
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update
RUN apt-get -qq install -y make cmake uuid-dev git openjdk-11-jdk  libstdc++-10-dev g++10 clang-11 pkg-config
RUN apt-get -qq install -y python3-pip python3-setuptools python3-wheel

# install and configure conan
RUN pip3 install conan
RUN conan user && \
    conan profile new --detect gcc10 && \
    conan profile update settings.compiler.libcxx=libstdc++11  gcc10  && \
    conan profile new --detect clang11 && \
    conan profile update settings.compiler=clang clang11 &&\
    conan profile update settings.compiler.version=11 clang11 && \
    conan profile update settings.compiler.libcxx=libstdc++11 clang11 && \
    conan profile update env.CXX=/usr/bin/clang++-11 clang11 && \
    conan profile update env.CC=/usr/bin/clang-11 clang11

RUN apt-get -qq install -y
# import project files
WORKDIR /sparql-parser-base
COPY antlr4cmake antlr4cmake
COPY cmake cmake
COPY CMakeLists.txt CMakeLists.txt
COPY conanfile.py conanfile.py
COPY LICENSE LICENSE
COPY SparqlParser_1_0.g4 SparqlParser_1_0.g4
COPY SparqlParser_1_1.g4 SparqlParser_1_1.g4
COPY SparqlLexer_1_1.g4 SparqlLexer_1_1.g4

WORKDIR /sparql-parser-base
#RUN conan create . "sparql-parser-base/test1@dice-group/stable" --build missing --profile gcc10
RUN conan create . "sparql-parser-base/test2@dice-group/stable" --build missing --profile gcc10 -o sparql-parser-base:sparql_version=1.0

#ENV CXX="clang++-11"
#ENV CC="clang-11"
#
#WORKDIR /sparql-parser-base
#RUN conan create . "sparql-parser-base/test3@dice-group/stable" --build missing --profile clang11
#RUN conan create . "sparql-parser-base/test4@dice-group/stable" --build missing --profile clang11 -o sparql-parser-base:sparql_version=1.0
