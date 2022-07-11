# FireFly Grafana Dashboards

...

### Table of Contents

* [Prerequisites](#prerequisites)
* [Get Repo Info](#get-repo-info)
* [Install Chart](#install-chart)
* [Uninstall Chart](#uninstall-chart)
* [Upgrading Chart](#upgrading-chart)
* [Using as a Dependency](#using-as-a-dependency)

## Prerequisites

* Kubernetes 1.18+
* Helm 3.7+
* PV provisioner support in the underlying infrastructure
* _Recommended:_ cert-manager 1.4+

## Get Repo Info

Helm's [experimental OCI registry support](https://helm.sh/docs/topics/registries/) is used for publishing and retrieving
the FireFly Helm chart, as a result one must log into [GHCR](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
to download the chart:

```shell
export HELM_EXPERIMENTAL_OCI=1

helm registry login ghcr.io
```

> **NOTE**: you must use a [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
> when authenticating to the GHCR registry as opposed to using your GitHub password.

## Install Chart

```shell
helm install [RELEASE_NAME] --version 0.5.0 oci://ghcr.io/hyperledger/helm/firefly-grafana-dashboards
```

_See [configuration](#Configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```shell
helm uninstall [RELEASE_NAME]
```

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```shell
helm upgrade [RELEASE_NAME] --install --version 0.5.0 oci://ghcr.io/hyperledger/helm/firefly-grafana-dashboards
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Using as a Dependency

You can also use the FireFly chart within your own parent chart's `Chart.yaml`:

```yaml
dependencies:
  # ...
  - name: firefly-grafana-dashboards
    repository: "oci://ghcr.io/hyperledger/helm/"
    version: 0.5.0
```

Then download the chart dependency into your parent chart:

```shell
helm dep up path/to/parent-chart
```

_See [helm dependency](https://helm.sh/docs/helm/helm_dependency/) for command documentation._

## Configuration

... label config
