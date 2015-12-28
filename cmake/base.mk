RM = rm -rf
CP = cp
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
	$(call make_build, normal)

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

# {{{ Target: ycm

ycm:
ifeq (".","${v/root}")
	$(call make_build, ycm, -DCMAKE_EXPORT_COMPILE_COMMANDS=1)
	@$(CP) cmake/ycm_extra_conf.py .ycm_extra_conf.py
else
	@echo "ycm target can only be called from the root directory"
endif

# }}}
# {{{ Target: ctags

ctags:
ifeq (".","${v/root}")
	@ctags -o .tags
else
	@echo "ctags target can only be called from the root directory"
endif

# }}}
# {{{ Target: distclean

distclean:
	$(foreach profile, $(PROFILES), $(call make_distclean, $(profile)))
	@echo "DISTCLEAN > ycm"
	@$(RM) ./${v/root}/build/ycm

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
	@echo "DEBUGGING"
	@echo "---------"
	@echo "Verbose mode: make VERBOSE=1"

# }}}
# {{{ Target: forwarding

ifeq ($(findstring distclean,$(MAKECMDGOALS)),)
ifeq ($(findstring help,$(MAKECMDGOALS)),)
ifeq ($(findstring ycm,$(MAKECMDGOALS)),)
ifeq ($(findstring ctags,$(MAKECMDGOALS)),)

$(MAKECMDGOALS): ./build/${v/profile}/Makefile
	@ $(MAKE) -C ./${v/root}/build/${v/profile}/${v/current} $(MAKECMDGOALS)

endif
endif
endif
endif

# }}}
