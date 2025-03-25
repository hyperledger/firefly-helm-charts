

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
		--excluded-charts besu-node,besu-genesis\
		--check-version-increment=false \
		--lint-conf=./charts/lintconf.yaml
	./hack/enforce-chart-conventions.sh

besu:
	kubectl --namespace default apply -f  ./values/monitoring/
	mkdir -p besu
	git clone --depth 1 https://github.com/Consensys/quorum-kubernetes besu-chart
	helm upgrade --install genesis ./besu-chart/helm/charts/besu-genesis --namespace default --create-namespace --values ./values/genesis-besu.yml
	kubectl --namespace default wait --for=condition=complete job/besu-genesis-init --timeout=600s
	helm upgrade --install validator-1 ./besu-chart/helm/charts/besu-node --namespace default --values ./values/validator.yml
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=besu-statefulset --timeout=600s

deps:
	kubectl create ns cert-manager || true
	kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.4.0/cert-manager.crds.yaml
	helm repo add jetstack https://charts.jetstack.io || true
	helm upgrade --install --skip-crds -n cert-manager cert-manager jetstack/cert-manager --wait
	kubectl apply -n cert-manager -f manifests/tls-issuers.yaml
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm upgrade --install --set kubeStateMetrics.enabled=false --set nodeExporter.enabled=false --set grafana.enabled=false kube-prometheus prometheus-community/kube-prometheus-stack
	helm repo add bitnami https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami || true
	helm upgrade --install --set global.postgresql.auth.postgresPassword=firef1y --set extraEnv[0].name=POSTGRES_DATABASE --set extraEnv[0].value=firefly postgresql bitnami/postgresql --version 14.3.0
	kubectl create secret generic custom-psql-config --dry-run --from-literal="url=postgres://postgres:firef1y@postgresql.default.svc:5432/postgres?sslmode=disable" -o json | kubectl apply -f -
	kubectl apply -n default -f manifests/mtls-cert.yaml
	helm upgrade --install ipfs ./charts/ipfs -f ./charts/ipfs/values.yaml

starter: charts/firefly/local-values.yaml

charts/firefly/local-values.yaml:
	cp ./charts/firefly/ci/eth-values.yaml charts/firefly/local-values.yaml

deploy:
	helm upgrade -i firefly ./charts/firefly -f ./charts/firefly/local-values.yaml

test:
	ct install --namespace default --helm-extra-args="--timeout 120s" --charts charts/firefly

e2e: kind deps test

stack: kind deps besu
	helm upgrade -i firefly-signer ./charts/firefly-signer -f ./charts/firefly/values.yaml
	helm upgrade -i firefly ./charts/firefly -f ./charts/firefly/local-kind-values.yaml

clean-stack:
	kind delete cluster --name firefly
	yq -i '.config.fireflyContracts = []' ./hack/multiparty-values.yaml
	rm -rf besu/