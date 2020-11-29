.PHONY: build test clean docker

GO=CGO_ENABLED=0 GO111MODULE=on go

MICROSERVICES=cmd/device-restfulapi-go/device-restfulapi-go
.PHONY: $(MICROSERVICES)

VERSION=$(shell cat ./VERSION 2>/dev/null || echo 0.0.0)

GOFLAGS=-ldflags "-X github.com/edgexfoundry/device-restfulapi-go.Version=$(VERSION)"

GIT_SHA=$(shell git rev-parse HEAD)

build: $(MICROSERVICES)
	$(GO) install -tags=safe

cmd/device-restfulapi-go/device-restfulapi-go:
	$(GO) build  -mod=vendor  $(GOFLAGS) -o $@ ./cmd/device-restfulapi-go

docker:
	docker build \
		-f cmd/device-restfulapi-go/Dockerfile \
		--label "git_sha=$(GIT_SHA)" \
		-t lk/docker-device-restfulapi-go:$(VERSION) \
		.

test:
	$(GO) vet ./...
	gofmt -l .
	$(GO) test -coverprofile=coverage.out ./...
	./bin/test-attribution-txt.sh
	./bin/test-go-mod-tidy.sh

clean:
	rm -f $(MICROSERVICES)
