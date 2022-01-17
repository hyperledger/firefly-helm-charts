
kind:
	kind create cluster

clean:
	kind delete cluster

lint:
	ct lint \
		--target-branch=main \
		--exclude-deprecated \
		--lint-conf=./charts/lintconf.yaml
	./hack/enforce-chart-conventions.sh

deps:
	kubectl create ns cert-manager || true
	kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.4.0/cert-manager.crds.yaml
	helm repo add jetstack https://charts.jetstack.io || true
	helm install --skip-crds -n cert-manager cert-manager jetstack/cert-manager --wait
	kubectl apply -n cert-manager -f manifests/tls-issuers.yaml
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm install --set kubeStateMetrics.enabled=false --set nodeExporter.enabled=false --set grafana.enabled=false kube-prometheus prometheus-community/kube-prometheus-stack
	helm repo add bitnami https://charts.bitnami.com/bitnami || true
	helm install --set postgresqlPassword=firef1y --set extraEnv[0].name=POSTGRES_DATABASE --set extraEnv[0].value=firefly postgresql bitnami/postgresql

starter: charts/firefly/local-values.yaml

charts/firefly/local-values.yaml:
	cp ./charts/firefly/ci/eth-values.yaml charts/firefly/local-values.yaml

deploy:
	helm upgrade -i firefly ./charts/firefly -f ./charts/firefly/local-values.yaml
