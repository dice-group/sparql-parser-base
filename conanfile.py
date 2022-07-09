import os
import re

from conan.tools.microsoft import is_msvc
from conans import ConanFile, CMake, tools
from conans.errors import ConanInvalidConfiguration


class Recipe(ConanFile):
    name = "sparql-parser-base"
    author = "DICE Group <info@dice-research.org>"
    description = "This repository generates a [ANTLR-v4](https://github.com/antlr/antlr4) -based [SPARQL 1.1](https://www.w3.org/TR/sparql11-overview/) parser in C++. The ANTLR v4 code generator is called by CMake."
    homepage = "https://github.com/dice-group/sparql-parser"
    url = homepage
    license = "BSD-3-Clause", "Apache-2.0"
    topics = "SPARQL", "parser", "semantic web", "antlr4"

    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        'sparql_version': ['1.0', '1.1'],
    }
    default_options = {
        "shared": False,
        "fPIC": True,
        'sparql_version': '1.1',
    }
    requires = "antlr4-cppruntime/4.10.1",
    settings = "os", "compiler", "build_type", "arch"
    generators = ("CMakeDeps", "CMakeToolchain")
    exports_sources = "CMakeLists.txt", "antlr4cmake/antlr4-generator.cmake.in", "cmake/*", "SparqlLexer_1.1.g4", "SparqlParser_1.0.g4", "SparqlParser_1.1.g4"

    def set_version(self):
        if not hasattr(self, 'version') or self.version is None:
            cmake_file = tools.load(os.path.join(self.recipe_folder, "CMakeLists.txt"))
            self.version = re.search(r"project\([^)]*VERSION\s+(\d+\.\d+.\d+)[^)]*\)", cmake_file).group(1)

    compiler_required_cpp17 = {
        "Visual Studio": "16",
        "gcc": "7",
        "clang": "5",
        "apple-clang": "9.1"
    }

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def validate(self):
        if str(self.settings.arch).startswith("arm"):
            raise ConanInvalidConfiguration("arm architectures are not supported")
            # Need to deal with missing libuuid on Arm.
            # So far ANTLR delivers macOS binary package.

        compiler_version = tools.Version(self.settings.compiler.version)
        if is_msvc(self) and compiler_version < "16":
            raise ConanInvalidConfiguration("library claims C2668 'Ambiguous call to overloaded function'")

        if self.settings.get_safe("compiler.cppstd"):
            tools.check_min_cppstd(self, "17")

        minimum_version = self.compiler_required_cpp17.get(str(self.settings.compiler), False)

        if minimum_version:
            if compiler_version < minimum_version:
                raise ConanInvalidConfiguration(
                    "{} requires C++17, which your compiler does not support.".format(self.name))
        else:
            self.output.warn(
                "{} requires C++17. Your compiler is unknown. Assuming it supports C++17.".format(self.name))

    _cmake = None

    def _configure_cmake(self):
        if self._cmake:
            return self._cmake
        self._cmake = CMake(self)
        self._cmake.definitions['CONAN_CMAKE'] = False
        self._cmake.definitions['ANTLR4_TAG'] = self.requires['antlr4-cppruntime'].ref.version
        self._cmake.configure()
        return self._cmake

    def build(self):
        cmake = self._configure_cmake()
        cmake.build()

    def package(self):
        cmake = self._configure_cmake()
        cmake.install()
        self.copy("LICENSE", src=self.folders.base_source, dst="licenses")
        tools.rmdir(os.path.join(self.package_folder, "cmake"))
        tools.rmdir(os.path.join(self.package_folder, "share"))

    def package_info(self):
        self.cpp_info.libs = ["sparql-parser-base"]
