REGISTRY ?= your-docker-registry
IMAGE_NAME ?= recipe-wallet-backend
TAG ?= latest

# Full image tag combining registry, name, and tag
FULL_IMAGE = $(REGISTRY)/$(IMAGE_NAME):$(TAG)

.PHONY: help clean build docker-build docker-push release

help:
	@echo "Available commands:"
	@echo "  make clean        - Clean the Maven build"
	@echo "  make build        - Compile and package the Spring Boot app (skips tests)"
	@echo "  make docker-build - Build the Docker image"
	@echo "  make docker-push  - Push the Docker image to the registry"
	@echo "  make release      - Clean, build, docker-build, and docker-push"
	@echo ""
	@echo "Current image: $(FULL_IMAGE)"

clean:
	cd backend && ./mvnw clean

build:
	cd backend && ./mvnw package -DskipTests

docker-build:
	cd backend && docker build -t $(FULL_IMAGE) .

docker-push:
	docker push $(FULL_IMAGE)

release: clean build docker-build docker-push
