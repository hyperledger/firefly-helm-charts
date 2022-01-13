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
