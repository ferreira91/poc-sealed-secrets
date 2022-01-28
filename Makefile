IMAGE ?= poc-sealed-secrets
NAMESPACE ?= default
REGISTRY ?= localhost:5000/poc-sealed-secrets
SEALED_SECRETS_VERSION ?= v0.17.2
TAG ?= latest

### Kind ###
create-cluster-with-registry:
	./tools/kind-with-registry.sh

### Gradle ###
gradle-build:
	./gradlew build

### Docker ###
docker-build: gradle-build
	docker build -t $(IMAGE):$(TAG) .
docker-tag:
	docker tag $$(docker images --filter=reference=$(IMAGE) --format "{{.ID}}") $(REGISTRY):$(TAG)
docker-push: docker-tag
	docker push $(REGISTRY):$(TAG)

### Kubeseal ###
download-controller-kubeseal:
	wget https://github.com/bitnami-labs/sealed-secrets/releases/download/$(SEALED_SECRETS_VERSION)/controller.yaml -P tools/
install-controller-kubeseal: download-controller-kubeseal
	 kubectl apply -f controller.yaml
create-secrets-kubeseal:
	kubeseal --format=yaml < tools/basesecret.yaml > k8s/charts/templates/secret.yaml

### Kubernetes ###
create-deployment:
	helm -n $(NAMESPACE) install $(IMAGE) k8s/charts/ --values k8s/charts/values.yaml
upgrade-deployment:
	helm -n $(NAMESPACE) upgrade $(IMAGE) k8s/charts/ --values k8s/charts/values.yaml