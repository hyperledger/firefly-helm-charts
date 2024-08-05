# Hyperledger FireFly Helm Charts

<img src="https://github.com/hyperledger/firefly/raw/main/images/hyperledger_firefly_logo.png" />

The official [Helm chart](https://helm.sh/) for [Hypeledger Firefly](https://hyperledger.github.io/firefly/) and its
related connector microservices. See the [chart `README`](charts/firefly/README.md) for installation and
configuration instructions.

## Quick Start

If you want to run these charts locally on your own machine, you can run a single command to get a fully working stack, end-to-end:

```
make stack
```

This will create a pre-set environment with the following configuration:

- Runs all containers in [kind](https://kind.sigs.k8s.io/)
- Sets up a PostgreSQL DB in the K8s cluster
- Creates a basic single node Besu blockchain also running in the K8s cluster
- Sets up FireFly and all of its dependencies to use these services
- Sets up an ERC-20 / ERC-721 Token Connector in this stack
- Provides an optional script to enable multiparty mode after initial set up

If you wish to make changes to your stack you can modify `./charts/firefly/local-kind-values.yaml` and run:

```
helm upgrade --install firefly ./charts/firefly -f ./charts/firefly/local-kind-values.yaml
```

### Enabling multiparty mode

After you run the quickstart command above, you can also (optionally) enable Multiparty mode. This will enabled FireFly's advanced Messaging features. To enable that, you can run the shell script:

```
./hack/multiparty.sh
```

This will deploy the multiparty contract, update the config file, and register the org/node for you automatically. If you need to upgrade the multiparty in the future, you can run this script again and it will deploy and configure a new contract. It will not re-run registration if the org/node are already registered.

> NOTE: If you have enabled multiparty mode and you wish to make changes by customizing your values file, be sure to include the multiparty values as well, otherwise they will be removed and your multiparty network will not work.
>
> ```
> helm upgrade --install firefly ./charts/firefly -f ./charts/firefly/local-kind-values.yaml -f ./hack/multiparty-values.yaml
> ```

### Modifying configuration

Configuration of the stack for non-default options is possible using these charts, broadly there are 2 places to make changes. For Besu charts, the appropriate `values.yaml` files in the `values` directory allows for configuration of values such as the genesis block, and Besu-specific options. For FireFly related components the `values.yaml` file within the sub-directory for the chart (stored in `charts/`) contains the configuration for options.

Viewing the appropriate README for each microservice, will give information around the values and structure of the configuration in the `values.yaml` files. 

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

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-with-a-package-manager) 0.11+
- [helm](https://helm.sh/docs/intro/install/) 3.7+
- [ct](https://github.com/helm/chart-testing#installation) 3.4+

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
