from conans import ConanFile, CMake,tools


class sparqlParserBase(ConanFile):
    name = "sparql-parser-base"
    version = "0.1.0"
    author = "DICE Group <info@dice-research.org>"
    description = "A ANTLR4 base for SPARQL parser."
    homepage = "https://github.com/dice-group/sparql-parser"
    url = homepage
    license = "AGPL"
    topics = "SPARQL", "parser", "semantic web","antlr4"
    settings = "os", "compiler", "build_type", "arch"
    generators = "cmake"
    exports = "LICENSE.txt"
    exports_sources = (
        "CMakeLists.txt",
        "antlr4cmake/*",
        "cmake/*",
        "Sparql.g4")
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
