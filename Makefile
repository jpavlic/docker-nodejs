NAME := $(or $(NAME),$(NAME),jpavlic)
VERSION := $(or $(VERSION),$(VERSION),1.001.01-gold)
NAMESPACE := $(or $(NAMESPACE),$(NAMESPACE),$(NAME))
AUTHORS := $(or $(AUTHORS),$(AUTHORS),jpavlic)
PLATFORM := $(shell uname -s)
BUILD_ARGS := $(BUILD_ARGS)
MAJOR := $(word 1,$(subst ., ,$(VERSION)))
MINOR := $(word 2,$(subst ., ,$(VERSION)))
MAJOR_MINOR_PATCH := $(word 1,$(subst -, ,$(VERSION)))

all: nodejs nodejs_debug standalone_nodejs standalone_nodejs_debug

generate_all:	\
	generate_nodejsbase \
	generate_nodejs \
	generate_nodejs_debug \
	generate_standalone_nodejs \
	generate_standalone_nodejs_debug

build: all

build_nodejs: nodejs

ci: standalone_nodejs release_standalone_nodejs

base:
	cd ./Base && docker build $(BUILD_ARGS) -t $(NAME)/base:$(VERSION) .

generate_nodejsbase:
	cd ./NodeJSBase && ./generate.sh $(VERSION) $(NAMESPACE) $(AUTHORS)

nodejsbase: base generate_nodejsbase
	cd ./NodeJSBase && docker build $(BUILD_ARGS) -t $(NAME)/nodejs-base:$(VERSION) .

generate_nodejs:
	cd ./NodeJS && ./generate.sh $(VERSION) $(NAMESPACE) $(AUTHORS)

nodejs: nodejsbase generate_nodejs
	cd ./NodeJS && docker build $(BUILD_ARGS) -t $(NAME)/nodejs:$(VERSION) .

generate_standalone_nodejs:
	cd ./Standalone && ./generate.sh StandaloneNodeJS nodejs $(VERSION) $(NAMESPACE) $(AUTHORS)

standalone_nodejs: nodejs generate_standalone_nodejs
	cd ./StandaloneNodeJS && docker build $(BUILD_ARGS) -t $(NAME)/standalone-nodejs:$(VERSION) .

generate_standalone_nodejs_debug:
	cd ./StandaloneNodeJS && ./generate.sh StandaloneNodeJSDebug nodejs-debug $(VERSION) $(NAMESPACE) $(AUTHORS)

standalone_nodejs_debug: nodejs_debug generate_standalone_nodejs_debug
	cd ./StandaloneNodeJSDebug && docker build $(BUILD_ARGS) -t $(NAME)/standalone-nodejs-debug:$(VERSION) .

nodejs_debug: nodejs generate_nodejs_debug
	cd ./NodeJSDebug && docker build $(BUILD_ARGS) -t $(NAME)/nodejs-debug:$(VERSION) .

generate_nodejs_debug:
	cd ./NodeJSBase && ./generate.sh $(VERSION) $(NAMESPACE) $(AUTHORS)

tag_latest:
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:latest
	docker tag $(NAME)/nodejs-base:$(VERSION) $(NAME)/nodejs-base:latest
	docker tag $(NAME)/nodejs:$(VERSION) $(NAME)/nodejs:latest
	docker tag $(NAME)/nodejs-debug:$(VERSION) $(NAME)/nodejs-debug:latest
	docker tag $(NAME)/standalone-nodejs:$(VERSION) $(NAME)/standalone-nodejs:latest
	docker tag $(NAME)/standalone-nodejs-debug:$(VERSION) $(NAME)/standalone-nodejs-debug:latest

tag_nodejs:
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:$(VERSION)
	docker tag $(NAME)/nodejs-base:$(VERSION) $(NAME)/nodejs-base:$(VERSION)
	docker tag $(NAME)/nodejs:$(VERSION) $(NAME)/nodejs:$(VERSION)

release_nodejs:
	docker push $(NAME)/base:$(VERSION)
	docker push $(NAME)/nodejs-base:$(VERSION)
	docker push $(NAME)/nodejs:$(VERSION)

tag_nodejs_debug:
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:$(VERSION)
	docker tag $(NAME)/nodejs-base:$(VERSION) $(NAME)/nodejs-base:$(VERSION)
	docker tag $(NAME)/nodejs-debug:$(VERSION) $(NAME)/nodejs-debug:$(VERSION)

release_nodejs_debug:
	docker push $(NAME)/base:$(VERSION)
	docker push $(NAME)/nodejs-base:$(VERSION)
	docker push $(NAME)/nodejs-debug:$(VERSION)

tag_standalone_nodejs:
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:$(VERSION)
	docker tag $(NAME)/nodejs-base:$(VERSION) $(NAME)/nodejs-base:$(VERSION)
	docker tag $(NAME)/standalone-nodejs:$(VERSION) $(NAME)/standalone-nodejs:$(VERSION)

release_standalone_nodejs:
	docker push $(NAME)/base:$(VERSION)
	docker push $(NAME)/nodejs-base:$(VERSION)
	docker push $(NAME)/standalone-nodejs:$(VERSION)

tag_standalone_nodejs_debug:
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:$(VERSION)
	docker tag $(NAME)/nodejs-base:$(VERSION) $(NAME)/nodejs-base:$(VERSION)
	docker tag $(NAME)/standalone-nodejs-debug:$(VERSION) $(NAME)/standalone-nodejs-debug:$(VERSION)

release_standalone_nodejs_debug:
	docker push $(NAME)/base:$(VERSION)
	docker push $(NAME)/nodejs-base:$(VERSION)
	docker push $(NAME)/standalone-nodejs-debug:$(VERSION)

tag_major_minor:
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:$(MAJOR)
	docker tag $(NAME)/nodejs-base:$(VERSION) $(NAME)/nodejs-base:$(MAJOR)
	docker tag $(NAME)/nodejs:$(VERSION) $(NAME)/nodejs:$(MAJOR)
	docker tag $(NAME)/nodejs-debug:$(VERSION) $(NAME)/nodejs-debug:$(MAJOR)
	docker tag $(NAME)/standalone-nodejs:$(VERSION) $(NAME)/standalone-nodejs:$(MAJOR)
	docker tag $(NAME)/standalone-nodejs-debug:$(VERSION) $(NAME)/standalone-nodejs-debug:$(MAJOR)
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:$(MAJOR).$(MINOR)
	docker tag $(NAME)/nodejs-base:$(VERSION) $(NAME)/nodejs-base:$(MAJOR).$(MINOR)
	docker tag $(NAME)/nodejs:$(VERSION) $(NAME)/nodejs:$(MAJOR).$(MINOR)
	docker tag $(NAME)/nodejs-debug:$(VERSION) $(NAME)/nodejs-debug:$(MAJOR).$(MINOR)
	docker tag $(NAME)/standalone-nodejs:$(VERSION) $(NAME)/standalone-nodejs:$(MAJOR).$(MINOR)
	docker tag $(NAME)/standalone-nodejs-debug:$(VERSION) $(NAME)/standalone-nodejs-debug:$(MAJOR).$(MINOR)
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/nodejs-base:$(VERSION) $(NAME)/nodejs-base:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/nodejs:$(VERSION) $(NAME)/nodejs:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/nodejs-debug:$(VERSION) $(NAME)/nodejs-debug:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/standalone-nodejs:$(VERSION) $(NAME)/standalone-nodejs:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/standalone-nodejs-debug:$(VERSION) $(NAME)/standalone-nodejs-debug:$(MAJOR_MINOR_PATCH)

release: tag_major_minor
	@if ! docker images $(NAME)/base | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/nodejs-base | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/nodejs-base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/nodejs | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/nodejs version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/nodejs-debug | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/nodejs-debug version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/standalone-nodejs | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/standalone-nodejs version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/standalone-nodejs-debug | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/standalone-nodejs-debug version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)/base:$(VERSION)
	docker push $(NAME)/nodejs-base:$(VERSION)
	docker push $(NAME)/nodejs:$(VERSION)
	docker push $(NAME)/nodejs-debug:$(VERSION)
	docker push $(NAME)/standalone-nodejs:$(VERSION)
	docker push $(NAME)/standalone-nodejs-debug:$(VERSION)
	docker push $(NAME)/base:$(MAJOR)
	docker push $(NAME)/nodejs-base:$(MAJOR)
	docker push $(NAME)/nodejs:$(MAJOR)
	docker push $(NAME)/nodejs-debug:$(MAJOR)
	docker push $(NAME)/standalone-nodejs:$(MAJOR)
	docker push $(NAME)/standalone-nodejs-debug:$(MAJOR)
	docker push $(NAME)/base:$(MAJOR).$(MINOR)
	docker push $(NAME)/nodejs-base:$(MAJOR).$(MINOR)
	docker push $(NAME)/nodejs:$(MAJOR).$(MINOR)
	docker push $(NAME)/nodejs-debug:$(MAJOR).$(MINOR)
	docker push $(NAME)/standalone-nodejs:$(MAJOR).$(MINOR)
	docker push $(NAME)/standalone-nodejs-debug:$(MAJOR).$(MINOR)
	docker push $(NAME)/base:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/nodejs-base:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/nodejs:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/nodejs-debug:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/standalone-nodejs:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/standalone-nodejs-debug:$(MAJOR_MINOR_PATCH)

test: test_nodejs \
 test_nodejs_debug \
 test_nodejs_standalone \
 test_nodejs_standalone_debug


test_nodejs:
	VERSION=$(VERSION) NAMESPACE=$(NAMESPACE) ./tests/bootstrap.sh NodeJS

test_nodejs_debug:
	VERSION=$(VERSION) NAMESPACE=$(NAMESPACE) ./tests/bootstrap.sh NodeJSDebug

test_nodejs_standalone:
	VERSION=$(VERSION) NAMESPACE=$(NAMESPACE) ./tests/bootstrap.sh StandaloneNodeJS

test_nodejs_standalone_debug:
	VERSION=$(VERSION) NAMESPACE=$(NAMESPACE) ./tests/bootstrap.sh StandaloneNodeJSDebug

.PHONY: \
	all \
	base \
	build \
	nodejs \
	nodejs_debug \
	ci \
	generate_all \
	generate_nodejsbase \
	generate_nodejs \
	generate_nodejs_debug \
	generate_standalone_nodejs \
	generate_standalone_nodejs_debug \
	nodejsbase \
	release \
	standalone_nodejs \
	standalone_nodejs_debug \
	tag_latest \
	test
