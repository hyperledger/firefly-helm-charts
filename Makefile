

all: lint e2e

kind:
	kind create cluster --name firefly --config kind-config.yml
	kind export kubeconfig -n firefly

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

besu:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install monitoring prometheus-community/kube-prometheus-stack --version 34.10.0 --namespace=quorum --create-namespace --values ./values/monitoring.yml --wait
	kubectl --namespace quorum apply -f  ./values/monitoring/
	helm install genesis ./charts/besu-genesis --namespace quorum --create-namespace --values ./values/genesis-besu.yml
	helm install validator-1 ./charts/besu-node --namespace quorum --values ./values/validator.yml

deps:
	kubectl create ns cert-manager || true
	kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.4.0/cert-manager.crds.yaml
	helm repo add jetstack https://charts.jetstack.io || true
	helm upgrade --install --skip-crds -n cert-manager cert-manager jetstack/cert-manager --wait
	kubectl apply -n cert-manager -f manifests/tls-issuers.yaml
	# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	# helm upgrade --install --set kubeStateMetrics.enabled=false --set nodeExporter.enabled=false --set grafana.enabled=false kube-prometheus prometheus-community/kube-prometheus-stack
	helm repo add bitnami https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami || true
	helm upgrade --install --set global.postgresql.auth.postgresPassword=firef1y --set extraEnv[0].name=POSTGRES_DATABASE --set extraEnv[0].value=firefly postgresql bitnami/postgresql --version 14.3.0
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

stack: kind besu deps
	helm upgrade -i firefly-signer ./charts/firefly-signer -f ./charts/firefly/values.yaml
	helm upgrade -i firefly ./charts/firefly -f ./charts/firefly/local-kind-values.yaml

clean-stack:
	kind delete cluster --name firefly