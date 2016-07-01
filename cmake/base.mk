# {{{ Variables

RM = rm -rf
CP = cp
SED = sed
RTAGS = rc
PROFILES = normal debug release asan msan tsan usan analyzer

v/build     := .build
v/generator := Unix Makefiles
v/profile   := $(or $(P),$(PROFILE),normal)
b/release   := -DCMAKE_BUILD_TYPE=Release
b/debug     := -DCMAKE_BUILD_TYPE=Debug
b/use_clang := -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang

# }}}
# {{{ Cores

v/procs:=4
OS:=$(shell uname -s)

ifeq ($(OS),Linux)
  v/procs:=$(shell grep -c ^processor /proc/cpuinfo)
endif
ifeq ($(OS),Darwin) # Assume Mac OS X
  v/procs:=$(shell system_profiler | awk '/Number Of CPUs/{print $4}{next;}')
endif
v/procs:= $(or $(J),$(JOBS),${v/procs})

# }}}

.PHONY: test 

all: ./${v/root}/${v/build}/$(v/profile)/Makefile
ifeq (${v/profile},analyzer)
	@scan-build $(MAKE) -j ${v/procs} -C ./${v/root}/${v/build}/$(v/profile)/${v/current}
else
	@$(MAKE) -j ${v/procs} -C ./${v/root}/${v/build}/$(v/profile)/${v/current} $(MAKECMDGOALS)
endif

# Defines the different build targets depending on the profiles
# $1: The build profiles
# $2: The cmake project flag
# $3: Prefix command before executing cmake (exe:scan-build)
define make_build
	@(mkdir -p ./${v/root}/${v/build}/$(strip $(1)))
	@(cd ./${v/root}/${v/build}/$(strip $(1)) && $(3) cmake $(2) -G "${v/generator}" ../../)

endef

./${v/root}/${v/build}/normal/Makefile:
	$(call make_build, normal, ${b/debug})

./${v/root}/${v/build}/release/Makefile:
	$(call make_build, release, ${b/release})

./${v/root}/${v/build}/debug/Makefile:
	$(call make_build, debug, ${b/debug})

./${v/root}/${v/build}/asan/Makefile:
	$(call make_build, asan, ${b/debug} ${b/use_clang} -DCLANG_ASAN=ON)

./${v/root}/${v/build}/msan/Makefile:
	$(call make_build, msan, ${b/debug} ${b/use_clang} -DCLANG_MSAN=ON)

./${v/root}/${v/build}/tsan/Makefile:
	$(call make_build, tsan, ${b/debug} ${b/use_clang} -DCLANG_TSAN=ON)

./${v/root}/${v/build}/usan/Makefile:
	$(call make_build, usan, ${b/debug} ${b/use_clang} -DCLANG_USAN=ON)

./${v/root}/${v/build}/analyzer/Makefile:
	$(call make_build, analyzer, -DCLANG_STATIC_ANALYZER=ON, scan-build)

./${v/root}/${v/build}/compile_flags:
ifeq (".","${v/root}")
	$(call make_build, compile_flags, ${b/use_clang} ${b/debug} -DCMAKE_EXPORT_COMPILE_COMMANDS=1)
else
	$(error this target can only be called from the root directory)
endif

# {{{ Target: ycm

ycm: ./${v/root}/${v/build}/compile_flags
	@$(CP) cmake/ycm_extra_conf.py .ycm_extra_conf.py
	@${SED} -i 's/__BUILD__/${v/build}/' .ycm_extra_conf.py

# }}}
# {{{ Target: rtags

rtags: ./${v/root}/${v/build}/compile_flags
	@$(RTAGS) -J ${v/build}/compile_flags/

# }}}
# {{{ Target: ctags

ctags: ./${v/root}/${v/build}/compile_flags
	@ctags -o .tags

# }}}
# {{{ Target: distclean

distclean:
	$(foreach profile, $(PROFILES), $(call make_distclean, $(profile)))
	@echo "DISTCLEAN > compile_flags"
	@$(RM) ./${v/root}/${v/build}/compile_flags

define make_distclean
	@echo "DISTCLEAN > $(strip $(1))"
	@$(RM) ./${v/root}/${v/build}/$(strip $(1))

endef

# }}}
# {{{ Target: help

help:
	@echo "USAGES EXAMPLE"
	@echo "--------------"
	@echo "... make PROFILE=asan test"
	@echo "... make P=debug check"
	@echo "... make valgrind"
	@echo ""
	@echo "TARGETS"
	@echo "--------"
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "... clean, distclean, ycm, ctags, rtags, test, valgrind"
	@echo ""
	@echo "PARALLEL COMPILATION (JOBS)"
	@echo "-----------------------------"
	@echo "If the OS is Mac or Linux the number of core available will be detected automatically."
	@echo "To override the value found  set 'J' or 'JOBS' to the number of jobs."
	@echo "... make T=12 "
	@echo ""
	@echo "PROFILES"
	@echo "--------"
	@echo "Available Profiles are:"
	@echo "... normal, debug, release, asan, msan, tsan, usan, analyzer"
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
	@echo ""
	@echo "TESTING"
	@echo "-------"
	@echo "Unit test are copied in the lib/test directories under the name ctest"

# }}}
# {{{ Target: forwarding

# TODO use or
ifeq ($(findstring distclean,$(MAKECMDGOALS)),)
ifeq ($(findstring help,$(MAKECMDGOALS)),)
ifeq ($(findstring ycm,$(MAKECMDGOALS)),)
ifeq ($(findstring ctags,$(MAKECMDGOALS)),)
ifeq ($(findstring rtags,$(MAKECMDGOALS)),)

$(MAKECMDGOALS): ./${v/root}/${v/build}/${v/profile}/Makefile
	@ $(MAKE) -j ${v/procs} -C ./${v/root}/${v/build}/${v/profile}/${v/current} $(MAKECMDGOALS)

endif
endif
endif
endif
endif

# }}}
