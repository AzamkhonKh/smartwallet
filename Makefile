REGISTRY ?= ghcr.io/azamkhonkh
IMAGE_NAME ?= recipe-wallet-backend
TAG ?= latest

# Full image tag combining registry, name, and tag
FULL_IMAGE = $(REGISTRY)/$(IMAGE_NAME):$(TAG)

.PHONY: help clean build docker-build docker-push release setup db-up db-down run-backend run-frontend run-all

help:
	@echo "Available commands:"
	@echo "  make setup        - Verify local environment and setup .env"
	@echo "  make db-up        - Start database & Langfuse services"
	@echo "  make db-down      - Stop database & Langfuse services"
	@echo "  make run-backend  - Start the Spring Boot backend locally"
	@echo "  make run-frontend - Start the Flutter client"
	@echo "  make run-all      - Start database and backend locally"
	@echo "  make clean        - Clean Maven build and Flutter temp files"
	@echo "  make build        - Package Spring Boot app (skips tests)"
	@echo "  make docker-build - Build Docker image"
	@echo "  make docker-push  - Push Docker image"
	@echo "  make release      - Clean, build, docker-build, and docker-push"
	@echo ""
	@echo "Current image: $(FULL_IMAGE)"

setup:
	./manage.sh setup

db-up:
	./manage.sh db-up

db-down:
	./manage.sh db-down

run-backend:
	./manage.sh backend

run-frontend:
	./manage.sh frontend

run-all:
	./manage.sh run-all

clean:
	./manage.sh clean

build:
	cd backend && ./mvnw package -DskipTests

docker-build:
	cd backend && docker build -t $(FULL_IMAGE) .

docker-push:
	docker push $(FULL_IMAGE)

release: clean build docker-build docker-push
