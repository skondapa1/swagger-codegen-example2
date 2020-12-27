#GOARCH=386
#prefix=$(shell bash -c pwd)
#export GOPATH=${prefix}
GOARCH=amd64
GOCMD=go
GOBUILD=GOARCH=${GOARCH} $(GOCMD) build
GOINSTALL=GOARCH=${GOARCH} $(GOCMD) install


#generate model objects from spec file
#generate server source without the model
#generate client source

generate: 
	swagger-codegen generate -i ./swagger/basic_auth.yml -l go  -o basic_auth -c config_client.json
	swagger-codegen generate -i ./swagger/basic_auth.yml -l go-server  -o basic_auth_server -t ./resources/ -c config_server.json

deps:
	go get -d -v swagger-codegen-example2/...

build: deps
	$(GOINSTALL) swagger-codegen-example2/basic_auth_client/... 
	$(GOINSTALL) swagger-codegen-example2/basic_auth_server/...

all: generate build

clean:
	-rm -rf basic_auth_server
	-rm -rf basic_auth
	-go clean -i swagger-codegen-example2/basic_auth_client/...
	-go clean -i swagger-codegen-example2/basic_auth_server/...
	-rm -f $(GOPATH)/bin/basic_auth_client
	-rm -f $(GOPATH)/bin/basic_auth_server


.DEFAULT_GOAL := all 

.PHONY:  all build clean  deps  



