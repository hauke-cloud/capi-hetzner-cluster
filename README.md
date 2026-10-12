<!-- llm-readme-management spec=1 commit=0d846cbaf5565e9b99a80c5ef664e3fd41ee81db template=helm model=qwen3.8-27b-q4 digest=5b6cfbe96d9f generated=2026-10-12T05:18:40Z -->
<a href="https://hauke.cloud" target="_blank"><img src="https://img.shields.io/badge/home-hauke.cloud-brightgreen" alt="hauke.cloud" style="display: block;" /></a>
<a href="https://github.com/hauke-cloud" target="_blank"><img src="https://img.shields.io/badge/github-hauke.cloud-blue" alt="hauke.cloud Github Organisation" style="display: block;" /></a>
<a href="https://github.com/hauke-cloud/llm-readme-management" target="_blank"><img src="https://img.shields.io/badge/template-helm-orange" alt="Repository type - helm" style="display: block;" /></a>


# Capi Hetzner Cluster


<img src="https://raw.githubusercontent.com/hauke-cloud/.github/main/resources/img/organisation-logo-small.png" alt="hauke.cloud logo" width="109" height="123" align="right">


<llm header hint="Name the chart and what it deploys.">

A Helm chart (`capi-hetzner-cluster`) that deploys a Cluster API workload cluster to Hetzner Cloud, rendering Cluster, HetznerCluster, KubeadmControlPlane, and MachineDeployment objects into your management cluster and optionally bootstrapping the result with Cilium, Hetzner CCM/CSI, cluster-autoscaler, and Flux. It is for platform operators who already run a management cluster with Cluster API, the Hetzner provider, and Flux 2.

</llm>


## :book: Description

<llm description>

`capi-hetzner-cluster` is a Helm chart that provisions a workload Kubernetes cluster on Hetzner Cloud using Cluster API. You point it at an existing management cluster that already runs Cluster API (`v1beta1`), the Hetzner infrastructure provider, and Flux 2, and a single `helm install` renders the full set of CAPI objects needed to bring up a control plane and one or more worker node pools.

The chart handles node bootstrap (runc, containerd, kubelet, kubeadm, kubectl) and, by default, installs Cilium, the Hetzner cloud-controller-manager, the Hetzner CSI driver, cluster-autoscaler, and Flux 2 itself on the new cluster through Flux `HelmRelease` and `Kustomization` objects. The chart is published as an OCI artifact at `oci://ghcr.io/hauke-cloud/charts/capi-hetzner-cluster`.

- Renders `Cluster`, `HetznerCluster`, `KubeadmControlPlane`, `HCloudMachineTemplate`, and `MachineDeployment` resources with per-pool cluster-autoscaler annotations.
- Configures node bootstrap: locale, swap, runc 1.2.5, containerd 1.7.26, Kubernetes v1.37.1 packages, sysctl and containerd tuning.
- Creates `MachineHealthCheck` and `HCloudRemediationTemplate` pairs for control-plane and worker machines.
- Supports optional OIDC API-server arguments, an HCloud private network, and per-node-group static routes.
- Rolls a worker pool by bumping its `configVersion`, which changes the `KubeadmConfigTemplate` name and triggers a `MachineDeployment` rollout.

</llm>


## :clipboard: Requirements

<llm requirements hint="Give the Kubernetes version constraint from Chart.yaml, the Helm version, and any dependency charts or CRDs that must already be present.">

- Helm 3 (no specific version is pinned; `Chart.yaml` declares no `kubeVersion` constraint).
- A management Kubernetes cluster with the Cluster API v1beta1 CRDs installed: `cluster.x-k8s.io`, `controlplane.cluster.x-k8s.io`, `bootstrap.cluster.x-k8s.io`.
- The Hetzner infrastructure provider CRDs installed: `infrastructure.cluster.x-k8s.io` (`HetznerCluster`, `HCloudMachineTemplate`, `HCloudRemediationTemplate`).
- Flux 2 controllers in the management cluster providing `source.toolkit.fluxcd.io/v1`, `helm.toolkit.fluxcd.io/v2`, and `kustomize.toolkit.fluxcd.io/v1` (all `bootstrap.*` objects are enabled by default).
- A Kubernetes secret in the release namespace (default name `prod`) carrying the keys `hcloud`, `robot-user`, and `robot-password`.
- SSH key(s) pre-registered in your Hetzner Cloud project (default name `default-0`).
- A secret in the workload cluster (default name `capi-hetzner-cluster`, key `hcloud`) for the CCM and CSI bootstrap objects.
- Outbound internet access from provisioned nodes to github.com, pkgs.k8s.io, and apt mirrors.
- Pull access to `oci://ghcr.io/hauke-cloud/charts`.
- `pre-commit` for contributors (see `CONTRIBUTING.md`).

</llm>


## 🚀 Getting started

<llm getting_started hint="helm repo add, helm install and helm upgrade with the real repository URL and chart name. Show a values override only if the chart needs one to start.">

1. Clone the repository.

```bash
git clone https://github.com/hauke-cloud/capi-hetzner-cluster.git
cd capi-hetzner-cluster
```

2. In your management cluster (which must already run Cluster API v1beta1, the Hetzner provider, and Flux 2, and whose Hetzner Cloud project has an SSH key named `default-0`), create the HCloud token secret the chart expects (conventional command):

```bash
kubectl create secret generic prod --from-literal=hcloud=<your-hcloud-token>
```

3. Install the chart to provision a workload cluster on Hetzner Cloud:

```bash
helm install capi-hetzner-cluster oci://ghcr.io/hauke-cloud/charts/capi-hetzner-cluster
```

4. Once Cluster API has created the kubeconfig secret, extract it to connect to the new cluster:

```bash
kubectl get secret capi-hetzner-cluster-kubeconfig -o jsonpath='{.data.value}' | base64 -d > workload-kubeconfig
```

</llm>


## :airplane: Usage

<llm usage hint="Show installing with a values file, and how to reach or verify the deployed workload.">

Before installing, ensure a secret named `prod` (the default for `hetzner.token.existingSecret.name`) exists in the release namespace with the keys `hcloud`, `robot-user`, and `robot-password`, and that the SSH key `default-0` is registered in your Hetzner Cloud project.

```bash
kubectl create secret generic prod --from-literal=hcloud=<your-hcloud-token>
```

Install the chart with a values file that sets your cluster topology:

```yaml
# values.yaml
hetzner:
  token:
    existingSecret:
      name: prod
  sshKeys:
    - default-0
kubernetes:
  version: v1.37.1
controlPlanes:
  nodes: 3
  regions:
    - fsn1
  flavor:
    name: cx22
workers:
  - name: worker-1
    minNodes: 0
    maxNodes: 5
    region: fsn1
    flavor:
      name: cx23
```

```bash
helm install capi-hetzner-cluster \
  oci://ghcr.io/hauke-cloud/charts/capi-hetzner-cluster \
  -f values.yaml
```

By default the chart also creates Flux `HelmRelease` objects for Cilium, the Hetzner CCM, the Hetzner CSI driver, and cluster-autoscaler, plus a `Kustomization` that installs Flux 2 on the workload cluster. These objects remain pending until Cluster API creates the `capi-hetzner-cluster-kubeconfig` secret.

Once the `KubeadmControlPlane` has converged, retrieve the workload kubeconfig and verify the cluster:

```bash
kubectl get secret capi-hetzner-cluster-kubeconfig \
  -o jsonpath='{.data.value}' | base64 -d > workload-kubeconfig

KUBECONFIG=workload-kubeconfig kubectl get nodes
```

</llm>


## :wrench: Configuration

<llm configuration hint="A table of the top-level values from values.yaml: key, default, description. Point at values.yaml for the full set.">

The chart is configured entirely through Helm values. The table below covers the top-level keys that affect rendered objects; see `charts/capi-hetzner-cluster/values.yaml` for the full set, including standard `nameOverride`/`fullnameOverride` entries.

| Key | Default | Description |
|-----|---------|-------------|
| `hetzner.token.existingSecret.name` | `"prod"` | Secret in the release namespace; expected to carry keys `hcloud`, `robot-user`, and `robot-password`. |
| `hetzner.sshKeys` | `["default-0"]` | SSH key names that must already exist in the Hetzner Cloud project. |
| `kubernetes.version` | `"v1.37.1"` | Version for `KubeadmControlPlane`/`MachineDeployment` and for packages installed in `preKubeadmCommands`. |
| `controlPlanes` | *(object)* | Control-plane pool: `image` (`ubuntu-24.04`), `nodes` (3), `regions` (`["fsn1"]`), `flavor.name` (`cx22`), `endpoint` (host `""`, port 443), `loadBalancer` (`{region: fsn1}`), `placement.type` (`spread`), `staticRoutes`, `kubeadmConfigTemplate`. |
| `workers` | *(list)* | Worker pools: `name`, `image`, `minNodes` (0), `maxNodes` (5), `region` (`fsn1`), `flavor` (`cx23`, 2 cpu, 4Gi mem, 40Gi disk, 120 maxPods), `placement.type` (`spread`), `staticRoutes`, `configVersion` (bump to roll the pool), `kubeadmConfigTemplate`. |
| `oidc.enabled` | `false` | When true, injects `oidc.args` (issuer URL, client ID, claims) into the API server. |
| `bootstrap.*` | `enabled: true` | Flux bootstrap blocks for Cilium, HCloud CCM, HCloud CSI, cluster-autoscaler, and Flux; each has `version`, `repoOverrides`, and `chartOverrides`/`kustomizationOverrides`. |
| `network` | *(object)* | `clusterNetwork.pods.cidrBlocks` (`["10.244.0.0/16"]`), `hcloudNetwork.enabled` (`false`), `staticRoutes` (`{}`). |
| `remediation` | `retryLimit: 1`, `timeout: "180s"`, `type: "Reboot"` | Parameters for `HCloudRemediationTemplate`. |
| `healthChecks` | `maxUnhealthy: "100%"`, `nodeStartupTimeout: "15m"` | Parameters for `MachineHealthCheck`. The conditions key is misspelled `unhealhyConditions` in `values.yaml`. |

`nodeSelector`, `tolerations`, and `affinity` are declared in `values.yaml` but referenced by no template.

</llm>


## 📄 License

This Project is licensed under the GNU General Public License v3.0

- see the [LICENSE](LICENSE) file for details.


## :coffee: Contributing

To become a contributor, please check out the [CONTRIBUTING](CONTRIBUTING.md) file.


## :email: Contact

For any inquiries or support requests, please open an issue in this
repository or contact us at [contact@hauke.cloud](mailto:contact@hauke.cloud).
