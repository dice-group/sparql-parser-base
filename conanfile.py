from conans import ConanFile, CMake


class sparqlParserBase(ConanFile):
    name = "sparql_Grammer-parser-base"
    version = "0.1"
    author = "DICE Group <info@dice-research.org>"
    description = "A ANTLR4 base for SPARQL parser."
    homepage = "https://github.com/dice-group/sparql_Grammer-parser"
    url = homepage
    license = "AGPL"
    topics = "SPARQL", "parser", "semantic web"
    settings = "build_type", "compiler", "os", "arch"
    requires = ()
    generators = "cmake", "cmake_find_package", "cmake_paths"
    exports = "LICENSE.txt"
    exports_sources ="ANTLR_bin/*","ANTLR_runtime/*", "sparql_Grammer/*", "CMakeLists.txt", "cmake/*"
    no_copy_source = True

    def package(self):
        cmake = CMake(self)

        cmake.configure()
        cmake.install()



    def imports(self):
        self.copy("license*", dst="licenses", folder=True, ignore_case=True)
