
lint:
	ct lint \
		--target-branch=main \
		--exclude-deprecated \
		--check-version-increment \
		--lint-conf=./charts/lintconf.yaml
	./hack/enforce-chart-conventions.sh
