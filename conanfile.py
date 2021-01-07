from conans import ConanFile, CMake,tools


class sparqlParserBase(ConanFile):
    name = "sparql-parser-base"
    version = "0.1.1"
    author = "DICE Group <info@dice-research.org>"
    description = "This repository generates a [ANTLR-v4](https://github.com/antlr/antlr4) -based [SPARQL 1.1](https://www.w3.org/TR/sparql11-overview/) parser in C++. The ANTLR v4 code generator is called by CMake."
    homepage = "https://github.com/dice-group/sparql-parser"
    url = homepage
    license = "AGPL"
    topics = "SPARQL", "parser", "semantic web","antlr4"
    settings = "os", "compiler", "build_type", "arch"
    generators = "cmake"
    exports = "LICENSE"
    exports_sources = (
        "CMakeLists.txt",
        "antlr4cmake/*",
        "cmake/*",
        "SparqlLexer.g4",
        "SparqlParser.g4")
    no_copy_source = True

    def package(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.install()
        self.copy("*.a", dst="lib", keep_path=False)

    def imports(self):
        self.copy("license*", dst="licenses", folder=True, ignore_case=True)

    def package_info(self):
        self.cpp_info.libs = ["sparql-parser-base","antlr4-runtime"]
