.PHONY: build run default test doc dg upstream downstream

VARIANT := upstream
DISTRO = fedora-26-x86_64
DG = /usr/bin/dg
GOMD2MAN = /usr/bin/go-md2man
POSTFIX_CERTS_PATH := /etc/postfix/certs
USER ?= user
PASSWD ?= passwd
DOCKERFILE_RENDERED = Dockerfile.rendered

DG_EXEC = ${DG} --max-passes 25 --distro ${DISTRO}.yaml --spec specs/configuration.yml --multispec specs/multispec.yml --multispec-selector variant=$(VARIANT)
DISTRO_ID = $(shell ${DG_EXEC} --template "{{ config.os.id }}")

IMAGE_REPOSITORY = $(shell ${DG_EXEC} --template "{{ spec.image_repository }}")

default: run

all: run run_tls run_imap

build: doc
	docker build --tag=$(IMAGE_REPOSITORY) -f $(DOCKERFILE_RENDERED) .

run: build
	docker run -p 25:10025 -e MYHOSTNAME=localhost $(IMAGE_REPOSITORY)

run_tls:
	docker run -p 25:10025 -e ENABLE_TLS -e SMTP_USER=$(USER):$(PASSWD) -e MYHOSTNAME=localhost $(IMAGE_REPOSITORY)

run_imap:
	docker run -p 587:10587 -e ENABLE_IMAP -e MYHOSTNAME=localhost -e SMTP_USER=$(USER):$(PWD) -v $(POSTFIX_CERTS_PATH):/etc/postfix/certs $(IMAGE_REPOSITORY)

doc: dg
	mkdir -p ./root/
	${GOMD2MAN} -in=help/help.md.rendered -out=./root/help.1

upstream:
	make -e doc VARIANT="upstream"
	make VARIANT="upstream"

downstream:
	make -e doc VARIANT="downstream"
	make VARIANT="downstream"

dg:
	${DG_EXEC} --template Dockerfile --output $(DOCKERFILE_RENDERED)
	${DG_EXEC} --template help/help.md --output help/help.md.rendered

test: build
    # for testing postfix
	cd tests; MODULE=docker DOCKERFILE="../$(DOCKERFILE_RENDERED)" URL="docker=$(IMAGE_REPOSITORY)" mtf *.py
	# for testing postfix with TLS

clean:
	rm -f Dockerfile.*
	rm -f help/help.md.*
	rm -r ./root
