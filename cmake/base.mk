RM = rm -rf
CP = cp
RTAGS = rc
PROFILES = normal debug release asan msan tsan usan analyzer

v/profile   := $(or $(P),$(PROFILE),normal)
b/release   := -DCMAKE_BUILD_TYPE=Release
b/debug     := -DCMAKE_BUILD_TYPE=Debug
b/use_clang := -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang

all: ./build/$(v/profile)/Makefile
ifeq (${v/profile},analyzer)
	@scan-build $(MAKE) -C ./${v/root}/build/$(v/profile)/${v/current}
else
	@$(MAKE) -C ./${v/root}/build/$(v/profile)/${v/current}
endif

# Defines the different build targets depending on the profiles
# $1: The build profiles
# $2: The cmake project flag
# $3: Prefix command before executing cmake (exe:scan-build)
define make_build
	@(mkdir -p ./${v/root}/build/$(strip $(1)))
	@(cd ./${v/root}/build/$(strip $(1)) && $(3) cmake $(2) ../../)

endef

./build/normal/Makefile:
	$(call make_build, normal, ${b/debug})

./build/release/Makefile:
	$(call make_build, release, ${b/release})

./build/debug/Makefile:
	$(call make_build, debug, ${b/debug})

./build/asan/Makefile:
	$(call make_build, asan, ${b/debug} ${b/use_clang} -DCLANG_ASAN=ON)

./build/msan/Makefile:
	$(call make_build, msan, ${b/debug} ${b/use_clang} -DCLANG_MSAN=ON)

./build/tsan/Makefile:
	$(call make_build, tsan, ${b/debug} ${b/use_clang} -DCLANG_TSAN=ON)

./build/usan/Makefile:
	$(call make_build, usan, ${b/debug} ${b/use_clang} -DCLANG_USAN=ON)

./build/analyzer/Makefile:
	$(call make_build, analyzer, "", scan-build)

./build/compile_flags:
ifeq (".","${v/root}")
	$(call make_build, compile_flags, ${b/use_clang} ${b/debug} -DCMAKE_EXPORT_COMPILE_COMMANDS=1)
else
	$(error this target can only be called from the root directory)
endif

# {{{ Target: ycm

ycm: ./build/compile_flags
	@$(CP) cmake/ycm_extra_conf.py .ycm_extra_conf.py

# }}}
# {{{ Target: rtags

rtags: ./build/compile_flags
	@$(RTAGS) -J build/compile_flags/

# }}}
# {{{ Target: ctags

ctags: ./build/compile_flags
	@ctags -o .tags

# }}}
# {{{ Target: distclean

distclean:
	$(foreach profile, $(PROFILES), $(call make_distclean, $(profile)))
	@echo "DISTCLEAN > compile_flags"
	@$(RM) ./${v/root}/build/compile_flags

define make_distclean
	@echo "DISTCLEAN > $(strip $(1))"
	@$(RM) ./${v/root}/build/$(strip $(1))

endef

# }}}
# {{{ Target: help

help:
	@echo "TARGETS"
	@echo "--------"
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "... clean"
	@echo "... distclean"
	@echo "... test"
	@echo "... ycm"
	@echo "... ctags"
	@echo "... rtags"
	@echo ""
	@echo "PROFILES"
	@echo "--------"
	@echo "Usage:"
	@echo "... make PROFILE=asan test"
	@echo "... make P=debug check"
	@echo ""
	@echo "Available Profiles are:"
	@echo "... normal"
	@echo "... debug"
	@echo "... release"
	@echo "... asan"
	@echo "... msan"
	@echo "... tsan"
	@echo "... usan"
	@echo "... analyzer"
	@echo ""
	@echo "Default profile: normal"
	@echo ""
	@echo "PROJECT ARCHITECTURE"
	@echo "--------------------"
	@echo " src/"
	@echo "  |--- lib1"
	@echo "  |     |--- include"
	@echo "  |     |     |--- lib1"
	@echo "  |     |           |--- subdirectory1"
	@echo "  |     |           |     |--- public_header.hpp"
	@echo "  |     |           |--- subdirectory2"
	@echo "  |     |                 |--- public_header.hpp"
	@echo "  |     |--- subdirectory1"
	@echo "  |     |     |--- private_header.hpp"
	@echo "  |     |     |--- files.cpp"
	@echo "  |     |--- subdirectory2"
	@echo "  |     |     |--- private_header.hpp"
	@echo "  |     |     |--- files.cpp"
	@echo "  |     |--- test"
	@echo "  |     |     |--- test.hpp"
	@echo "  |     |     |--- test.cpp"
	@echo ""
	@echo " Example of header inclusion in the test directory:"
	@echo "    > include <lib1/subdirectory1/public_header.hpp"
	@echo "    > include <subdirectory1/public_header.hpp"
	@echo "    > include <test/test.hpp"
	@echo ""
	@echo "DEBUGGING"
	@echo "---------"
	@echo "Verbose mode: make VERBOSE=1"

# }}}
# {{{ Target: forwarding

ifeq ($(findstring distclean,$(MAKECMDGOALS)),)
ifeq ($(findstring help,$(MAKECMDGOALS)),)
ifeq ($(findstring ycm,$(MAKECMDGOALS)),)
ifeq ($(findstring ctags,$(MAKECMDGOALS)),)
ifeq ($(findstring rtags,$(MAKECMDGOALS)),)

$(MAKECMDGOALS): ./build/${v/profile}/Makefile
	@ $(MAKE) -C ./${v/root}/build/${v/profile}/${v/current} $(MAKECMDGOALS)

endif
endif
endif
endif
endif

# }}}
