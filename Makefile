#GOARCH=386
#prefix=$(shell bash -c pwd)
#export GOPATH=${prefix}
GOARCH=amd64
GOCMD=go
GOBUILD=GOARCH=${GOARCH} $(GOCMD) build
GOINSTALL=GOARCH=${GOARCH} $(GOCMD) install

#-------------------------
# Download libraries and tools
#-------------------------
.PHONY: get.tools

## Retrieve tools packages
get.tools:
	# License checker
	go get -u github.com/frapposelli/wwhrd
 	# linter
	go get -u github.com/golangci/golangci-lint/cmd/golangci-lint


#generate model objects from spec file
#generate server source without the model
#generate client source

generate: 
	swagger-codegen generate -i ./swagger/basic_auth.yml -l go  -o basic_auth_client -t ./resources -c config_client.json
	swagger-codegen generate -i ./swagger/basic_auth.yml -l go-server  -o basic_auth_server -t ./resources/ -c config_server.json

deps:
	go get -d -v swagger-codegen-example2/...

build: deps
	$(GOINSTALL) swagger-codegen-example2/basic_auth_client/... 
	$(GOINSTALL) swagger-codegen-example2/basic_auth_server/...

all: generate build

clean:
	-go clean -i swagger-codegen-example2/basic_auth_client/...
	-go clean -i swagger-codegen-example2/basic_auth_server/...
	-rm -rf basic_auth_server
	-rm -rf basic_auth_client
	-rm -f $(GOPATH)/bin/basic_auth_client
	-rm -f $(GOPATH)/bin/basic_auth_server


.DEFAULT_GOAL := all 

.PHONY:  all build clean  deps  


#-------------------------
# Checks
#-------------------------
.PHONY: format license license.csv lint.fast lint.full lint.sonar stats.loc

check: format license lint.full

## Apply code format, import reorganization and code simplification on source code
format:
	@echo "==> formatting code"
	@$(GO) fmt $(pkgs)
	@echo "==> clean imports"
	@goimports -w $(pkgDirs)
	@echo "==> simplify code"
	@gofmt -s -w $(pkgDirs)

## Check external license usage
license:
ifndef WWHRD
	$(error "Please install wwhrd! make get-tools")
endif
	@echo "==> license check"
	wwhrd check

## Launch linter
lint.fast:
ifndef GOLANGCI
	$(error "Please install golangci! make get-tools")
endif
	@echo "==> linters (fast)"
	@golangci-lint run -v --fast $(pkgDirs)

## Validate code
lint.full:
ifndef GOLANGCI
	$(error "Please install golangci! make get-tools")
endif
	@echo "==> linters (slow)"
	@golangci-lint run -v $(pkgDirs)

#-------------------------
# Build artefacts
#-------------------------
#.PHONY: build build.http-server-go

## Build all binaries
#build:
#	$(GO) build -o bin/http-go-server internal/main.go

## Compress all binaries
pack:
	@echo ">> packing all binaries"
	@upx -7 -qq $(GOPATH)/bin/*

#-------------------------
# Target: depend
#-------------------------
.PHONY: depend vendor.check depend.status depend.update depend.cleanlock depend.update.full

## Use go modules
depend: depend.tidy depend.verify depend.vendor

depend.tidy:
	@echo "==> Running dependency cleanup"
	$(GO) mod tidy -v

depend.verify:
	@echo "==> Verifying dependencies"
	$(GO) mod verify

depend.vendor:
	@echo "==> Freezing dependencies"
	$(GO) mod vendor

depend.update:
	@echo "==> Update go modules"
	$(GO) get -u -v

depend.update.full: depend.cleanlock depend.update

#-------------------------
# Target: help
#-------------------------

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)


TARGET_MAX_CHAR_NUM=20
## Show help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

#-------------------------
# Target: swagger.validate
#-------------------------
#.PHONY: swagger.validate

#swagger.validate:
#	swagger validate pkg/swagger/swagger.yml

#-------------------------
# Target: swagger.doc
#-------------------------
.PHONY: swagger.doc

swagger.doc:
	sudo docker run -i yousan/swagger-yaml-to-html < ./swagger/basic_auth.yml > doc/index.html

