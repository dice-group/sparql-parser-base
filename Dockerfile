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
COPY Sparql.g4 Sparql.g4

WORKDIR /sparql-parser-base/build_gcc10
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make -j sparql-parser-base

#doesn't work right now
#WORKDIR /sparql-parser-base/build_clang11
#RUN export CXX="clang++-11" && export CC="clang-11" && \
#    cmake -DCMAKE_BUILD_TYPE=Release ..
#RUN export CXX="clang++-11" && export CC="clang-11" && \
#    make -j sparql-parser-base
##build

WORKDIR /sparql-parser-base
RUN conan create . "sparql-parser-base/0.1.0@dice-group/stable" --build missing --profile gcc10
#doesn't work right now
#RUN conan create . "sparql-parser-base/0.1.0@dice-group/stable" --build missing --profile clang11
