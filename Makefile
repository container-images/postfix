.PHONY: build run default

IMAGE_NAME = postfix


default: run

build:
	docker build --tag=$(IMAGE_NAME) .

run: build
	docker run -p 25:25 -p 587:587 -e MYHOSTNAME=localhost $(IMAGE_NAME)

test:
	run_test.sh
