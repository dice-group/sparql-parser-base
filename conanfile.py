from conans import ConanFile, CMake


class Hypertrie(ConanFile):
    name = "sparql-parser"
    version = "0.1"
    author = "DICE Group <info@dice-research.org>"
    description = "A ANTLR4 based SPARQL parser."
    homepage = "https://github.com/dice-group/hypertrie"
    url = homepage
    license = "AGPL"
    topics = "SPARQL", "parser", "semantic web"
    settings = "build_type", "compiler", "os", "arch"
    requires = ()
    generators = "cmake", "cmake_find_package", "cmake_paths"
    exports = "LICENSE.txt"
    exports_sources = "include/*", "CMakeLists.txt", "cmake/*"
    no_copy_source = True

    def package(self):
        cmake = CMake(self)

        #cmake.definitions["hypertrie_BUILD_TESTS"] = "OFF"
        cmake.configure()
        cmake.install()

    def package_id(self):
        pass
        # self.info.header_only()

    def imports(self):
        self.copy("license*", dst="licenses", folder=True, ignore_case=True)
