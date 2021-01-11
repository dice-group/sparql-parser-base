from conans import ConanFile, CMake,tools
import os

class sparqlParserBase(ConanFile):
    name = "sparql-parser-base"
    author = "DICE Group <info@dice-research.org>"
    description = "This repository generates a [ANTLR-v4](https://github.com/antlr/antlr4) -based [SPARQL 1.1](https://www.w3.org/TR/sparql11-overview/) parser in C++. The ANTLR v4 code generator is called by CMake."
    homepage = "https://github.com/dice-group/sparql-parser"
    url = homepage
    license = "AGPL"
    options = {'sparql_version': ['1.0', '1.1']}
    default_options = {'sparql_version': '1.1'}
    topics = "SPARQL", "parser", "semantic web","antlr4"
    settings = "os", "compiler", "build_type", "arch"
    generators = "cmake"
    exports = "LICENSE"
    exports_sources = (
        "CMakeLists.txt",
        "antlr4cmake/*",
        "cmake/*",
        "SPARQL_1.0/*",
        "SPARQL_1.1/*")
    no_copy_source = True

    def package(self):
        cmake = CMake(self)
        cmake.definitions['SPARQL_BASE_PARSER_SPARQL_VERSION'] = self.options.sparql_version
        cmake.configure()
        cmake.install()
        self.copy("*.a", dst="lib", keep_path=False)

    def imports(self):
        self.copy("license*", dst="licenses", folder=True, ignore_case=True)

    def package_info(self):
        self.cpp_info.libs = ["sparql-parser-base","antlr4-runtime"]
