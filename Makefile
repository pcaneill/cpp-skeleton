RM = rm -rf
PROFILES = normal debug release asan msan tsan usan analyzer

v/profile := $(or $(P),$(PROFILE),normal)

all: ./build/$(v/profile)/Makefile
ifeq (${v/profile},analyzer)
	@scan-build $(MAKE) -C ./build/$(v/profile)
else
	@$(MAKE) -C ./build/$(v/profile)
endif

./build/normal/Makefile:
	@(mkdir -p ./build/normal && cd ./build/normal > /dev/null 2>&1 && cmake ../../)

./build/release/Makefile:
	@(mkdir -p ./build/release && cd ./build/release > /dev/null 2>&1 && cmake -DCMAKE_BUILD_TYPE=Release ../../)

./build/debug/Makefile:
	@(mkdir -p ./build/debug && cd ./build/debug > /dev/null 2>&1 && cmake -DCMAKE_BUILD_TYPE=Debug ../../)

./build/asan/Makefile:
	@(mkdir -p ./build/asan && cd ./build/asan > /dev/null 2>&1 && cmake -DCMAKE_BUILD_TYPE=Debug ../../)

./build/msan/Makefile:
	@(mkdir -p ./build/msan && cd ./build/msan > /dev/null 2>&1 && cmake -DCMAKE_BUILD_TYPE=Debug ../../)

./build/tsan/Makefile:
	@(mkdir -p ./build/tsan && cd ./build/asan > /dev/null 2>&1 && cmake -DCMAKE_BUILD_TYPE=Debug ../../)

./build/usan/Makefile:
	@(mkdir -p ./build/usan && cd ./build/msan > /dev/null 2>&1 && cmake -DCMAKE_BUILD_TYPE=Debug ../../)

./build/analyzer/Makefile:
	@(mkdir -p ./build/analyzer && cd ./build/analyzer > /dev/null 2>&1 && scan-build cmake ../../)

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
