RM = rm -rf
PROFILES = normal debug release asan msan tsan usan

v/profile := $(or $(P),$(PROFILE),normal)

all: ./build/$(v/profile)/Makefile
	@$(MAKE) -C ./build/$(v/profile)

./build/normal/Makefile:
	@(mkdir -p ./build/normal && cd ./build/normal > /dev/null 2>&1 && cmake ../../)

./build/asan/Makefile:
	@(mkdir -p ./build/asan && cd ./build/asan > /dev/null 2>&1 && cmake ../../)

./build/msan/Makefile:
	@(mkdir -p ./build/msan && cd ./build/msan > /dev/null 2>&1 && cmake ../../)

./build/tsan/Makefile:
	@(mkdir -p ./build/tsan && cd ./build/asan > /dev/null 2>&1 && cmake ../../)

./build/usan/Makefile:
	@(mkdir -p ./build/usan && cd ./build/msan > /dev/null 2>&1 && cmake ../../)

distclean:
	$(foreach profile, $(PROFILES), $(call make_distclean, $(profile)))

define make_distclean
	@echo "DISTCLEAN > $(strip $(1))"
	@(mkdir -p ./build/$(strip $(1)) && cd ./build/$(strip $(1)) > /dev/null 2>&1 && cmake ../../)
	@(cd ./build/$(strip $(1)) > /dev/null 2>&1 && cmake ../.. > /dev/null 2>&1)
	@$(MAKE) --silent -C ./build/$(strip $(1)) clean || true
	@$(RM) -rf ./build/$(strip $(1))

endef

help:
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "... distclean"
	@echo ""
	@echo "Available Profiles are:"
	@echo "... normal"
	@echo "... debug"
	@echo "... release"
	@echo "... asan"
	@echo "... msan"
	@echo "... tsan"
	@echo "... usan"

ifeq ($(findstring distclean,$(MAKECMDGOALS)),)
ifeq ($(findstring help,$(MAKECMDGOALS)),)

$(MAKECMDGOALS): ./build/${v/profile}/Makefile
	@ $(MAKE) -C ./build/${v/profile} $(MAKECMDGOALS)

endif
endif
