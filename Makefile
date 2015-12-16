RM = rm -rf
PROFILES = normal debug release asan msan tsan usan analyzer

v/profile   := $(or $(P),$(PROFILE),normal)
b/release   := "-DCMAKE_BUILD_TYPE=Debug"
b/debug     := "-DCMAKE_BUILD_TYPE=Debug"
b/use_clang := "-DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang"

all: ./build/$(v/profile)/Makefile
ifeq (${v/profile},analyzer)
	@scan-build $(MAKE) -C ./build/$(v/profile)
else
	@$(MAKE) -C ./build/$(v/profile)
endif

define make_build
	@(mkdir -p ./build/$(strip $(1)))
	@(cd ./build/$(strip $(1)) && $(3) cmake $(2) ../../)
endef

./build/normal/Makefile:
	$(call make_build, normal)

./build/release/Makefile:
	$(call make_build, release, "${b/release}")

./build/debug/Makefile:
	$(call make_build, debug, "${b/debug}")

./build/asan/Makefile:
	$(call make_build, asan, "${b/release} ${b/use_clang} -DCLANG_ASAN=ON")

./build/msan/Makefile:
	$(call make_build, msan, "${b/release} ${b/use_clang} -DCLANG_MSAN=ON")

./build/tsan/Makefile:
	$(call make_build, tsan, "${b/release} ${b/use_clang} -DCLANG_TSAN=ON")

./build/usan/Makefile:
	$(call make_build, usan, "${b/release} ${b/use_clang} -DCLANG_USAN=ON")

./build/analyzer/Makefile:
	$(call make_build, analyzer, "", "scan-build")

distclean:
	$(foreach profile, $(PROFILES), $(call make_distclean, $(profile)))

define make_distclean
	@echo "DISTCLEAN > $(strip $(1))"
	@(mkdir -p ./build/$(strip $(1)) && cd ./build/$(strip $(1)) > /dev/null 2>&1 && cmake ../../)
	@(cd ./build/$(strip $(1)) > /dev/null 2>&1 && cmake ../.. > /dev/null 2>&1)
	@$(MAKE) --silent -C ./build/$(strip $(1)) clean || true
	@$(RM) ./build/$(strip $(1))

endef

# {{{ Help

help:
	@echo "TARGETS"
	@echo "--------"
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "... clean"
	@echo "... distclean"
	@echo "... test"
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

ifeq ($(findstring distclean,$(MAKECMDGOALS)),)
ifeq ($(findstring help,$(MAKECMDGOALS)),)

$(MAKECMDGOALS): ./build/${v/profile}/Makefile
	@ $(MAKE) -C ./build/${v/profile} $(MAKECMDGOALS)

endif
endif
