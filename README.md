# Hyperledger FireFly Helm Charts

<img src="https://github.com/hyperledger/firefly/raw/main/images/hyperledger_firefly_logo.png" />

The official [Helm chart](https://helm.sh/) for [Hypeledger Firefly](https://hyperledger.github.io/firefly/) and its
related connector microservices. See the [chart `README`](charts/firefly/README.md) for installation and
configuration instructions.

## Accessing the Helm Repo

Helm's [experimental OCI registry support](https://helm.sh/docs/topics/registries/) is used for publishing and retrieving
the FireFly Helm chart, as a result one must log into [GHCR](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
to download the chart:

```shell
export HELM_EXPERIMENTAL_OCI=1

helm registry login ghcr.io
```

> **NOTE**: you must use a [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
> when authenticating to the GHCR registry as opposed to using your GitHub password.

## Development

### Prerequisites

* [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-with-a-package-manager) 0.11+
* [helm](https://helm.sh/docs/intro/install/) 3.7+
* [ct](https://github.com/helm/chart-testing#installation) 3.4+

### Linting

Lint the chart using [`ct`](https://github.com/helm/chart-testing) and ensure it adheres to the project conventions:

```shell
make lint
```

### Testing

Create a local Kubernetes cluster in Docker via [`kind`](https://kind.sigs.k8s.io/):

```shell
make kind
```

Then install FireFly dependencies to the cluster (i.e. PostgreSQL, cert-manager, Prometheus):

```shell
make deps
```

Run the E2E tests:

```shell
make test
```

Or deploy the chart using your own customized `charts/firefly/local-values.yaml`:

```shell
make deploy
```

If you are unsure of what to initially put in your `charts/firefly/locall-values.yaml` file, we
suggest using the [Ethereum CI values](charts/firefly/ci/eth-values.yaml) as a starting point
and reading the [chart configuration documentation](charts/firefly/README.md#configuration):

```shell
make starter
```

If you are developing with a Fabric blockchain see the [Fabric CI values](charts/firefly/ci/fab-values.yaml) and
[additional chart documentation](charts/firefly/README.md#fabric).
