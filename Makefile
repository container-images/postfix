.PHONY: build run default

TLS=TLS
IMAP=IMAP
IMAGE_NAME = postfix
IMAGE_NAME_TLS = postfix-`echo $(TLS) | tr '[:upper:]' '[:lower:]'`
IMAGE_NAME_IMAP = postfix-`echo $(IMAP) | tr '[:upper:]' '[:lower:]'`
DOCKER_TLS=Dockerfile.$(TLS)
DOCKER_IMAP=Dockerfile.$(IMAP)

all: run run_tls run_imap
default: run

build:
	docker build --tag=$(IMAGE_NAME) .

build_tls:
	docker build -f $(DOCKER_TLS) --tag=$(IMAGE_NAME_TLS) .

build_imap:
	docker build -f $(DOCKER_IMAP) --tag=$(IMAGE_NAME_IMAP) .

run: build
	docker run -p 25:10025 -e MYHOSTNAME=localhost $(IMAGE_NAME)

run_tls: build_tls
	docker run -p 25:10025 -e MYHOSTNAME=localhost $(IMAGE_NAME_TLS)

run_imap: build_imap
	docker run -p 25:25 -p 143:10143 -e MYHOSTNAME=localhost $(IMAGE_NAME_IMAP)

test:
	run_test.sh
