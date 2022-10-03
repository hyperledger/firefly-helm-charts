

all: lint e2e

kind:
	kind create cluster || true

clean:
	kind delete cluster

lint:
	helm dep up charts/firefly
	helm template charts/firefly --set "erc20erc721.enabled=true" --set "erc1155.enabled=true" --set "ethconnect.enabled=true" --set "evmconnect.enabled=true"
	ct lint \
		--target-branch=main \
		--exclude-deprecated \
		--check-version-increment=false \
		--lint-conf=./charts/lintconf.yaml
	./hack/enforce-chart-conventions.sh

deps:
	kubectl create ns cert-manager || true
	kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.4.0/cert-manager.crds.yaml
	helm repo add jetstack https://charts.jetstack.io || true
	helm upgrade --install --skip-crds -n cert-manager cert-manager jetstack/cert-manager --wait
	kubectl apply -n cert-manager -f manifests/tls-issuers.yaml
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm upgrade --install --set kubeStateMetrics.enabled=false --set nodeExporter.enabled=false --set grafana.enabled=false kube-prometheus prometheus-community/kube-prometheus-stack
	helm repo add bitnami https://charts.bitnami.com/bitnami || true
	helm upgrade --install --set postgresqlPassword=firef1y --set extraEnv[0].name=POSTGRES_DATABASE --set extraEnv[0].value=firefly postgresql bitnami/postgresql --version 10.16.2
	kubectl create secret generic custom-psql-config --dry-run --from-literal="url=postgres://postgres:firef1y@postgresql.default.svc:5432/postgres?sslmode=disable" -o json | kubectl apply -f -
	kubectl apply -n default -f manifests/mtls-cert.yaml

starter: charts/firefly/local-values.yaml

charts/firefly/local-values.yaml:
	cp ./charts/firefly/ci/eth-values.yaml charts/firefly/local-values.yaml

deploy:
	helm upgrade -i firefly ./charts/firefly -f ./charts/firefly/local-values.yaml

test:
	ct install --namespace default --helm-extra-args="--timeout 120s" --charts charts/firefly

e2e: kind deps test
