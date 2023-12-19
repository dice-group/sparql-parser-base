import os
import re

from conan import ConanFile
from conan.errors import ConanInvalidConfiguration
from conan.tools.build import check_min_cppstd
from conan.tools.cmake import CMake
from conan.tools.files import load, rmdir, copy
from conan.tools.microsoft import is_msvc


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
    }
    default_options = {
        "shared": False,
        "fPIC": True,
    }
    settings = "os", "compiler", "build_type", "arch"
    generators = ("CMakeDeps", "CMakeToolchain")
    exports_sources = "CMakeLists.txt", "antlr4cmake/antlr4-generator.cmake.in", "cmake/*", "SparqlLexer.g4", "SparqlParser.g4"

    def requirements(self):
        self.requires("antlr4-cppruntime/4.13.1", transitive_headers=True)

    def set_version(self):
        if not hasattr(self, 'version') or self.version is None:
            cmake_file = load(self, os.path.join(self.recipe_folder, "CMakeLists.txt"))
            self.version = re.search(r"project\([^)]*VERSION\s+(\d+\.\d+.\d+)[^)]*\)", cmake_file).group(1)

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def validate(self):
        if str(self.settings.arch).startswith("arm"):
            raise ConanInvalidConfiguration("arm architectures are not supported")
            # Need to deal with missing libuuid on Arm.
            # So far ANTLR delivers macOS binary package.

        compiler_version = self.settings.compiler.version
        if is_msvc(self) and compiler_version < "16":
            raise ConanInvalidConfiguration("library claims C2668 'Ambiguous call to overloaded function'")

        if self.settings.get_safe("compiler.cppstd"):
            check_min_cppstd(self, "17")

    _cmake = None

    def _configure_cmake(self):
        if self._cmake:
            return self._cmake
        self._cmake = CMake(self)
        self._cmake.configure(
            variables=
            {"USE_CONAN": False,
             "ANTLR4_TAG": self.dependencies['antlr4-cppruntime'].ref.version}
        )
        self._cmake.configure()
        return self._cmake

    def build(self):
        cmake = self._configure_cmake()
        cmake.build()

    def package(self):
        cmake = self._configure_cmake()
        cmake.install()
        copy(self, "LICENSE", src=self.folders.base_source, dst="licenses")
        rmdir(self, os.path.join(self.package_folder, "cmake"))
        rmdir(self, os.path.join(self.package_folder, "share"))

    def package_info(self):
        self.cpp_info.libs = ["sparql-parser-base"]

        self.cpp_info.set_property("cmake_find_mode", "both")
        self.cpp_info.set_property("cmake_target_name", "sparql-parser-base::sparql-parser-base")
        self.cpp_info.set_property("cmake_file_name", "sparql-parser-base")
