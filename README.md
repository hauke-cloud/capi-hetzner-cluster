<!-- llm-readme-management spec=1 commit=563d583bbb07d9d3c484b7e0df73c061e83baf05 template=helm model=qwen3.8-27b-q4 digest=5b6cfbe96d9f generated=2026-09-08T12:49:14Z -->
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

The chart also handles node bootstrap (runc, containerd, kubelet, kubeadm, kubectl) and, optionally, installs Cilium, the Hetzner cloud-controller-manager, the Hetzner CSI driver, and cluster-autoscaler on the new cluster through Flux `HelmRelease` objects. The chart is published as an OCI artifact at `oci://ghcr.io/hauke-cloud/charts/capi-hetzner-cluster`.

- Renders `Cluster`, `HetznerCluster`, `KubeadmControlPlane`, `HCloudMachineTemplate`, and `MachineDeployment` resources with per-pool autoscaler annotations.
- Configures node bootstrap: locale, swap, runc 1.2.5, containerd 1.7.26, Kubernetes v1.37.1 packages, sysctl and containerd tuning.
- Optionally bootstraps the remote cluster with Cilium 1.19.4, hcloud-cloud-controller-manager, hcloud-csi, and cluster-autoscaler via Flux.
- Creates `MachineHealthCheck` and `HCloudRemediationTemplate` pairs for control-plane and worker machines.
- Supports optional OIDC API-server arguments, an HCloud private network, and per-node-group static routes.

</llm>


## :clipboard: Requirements

<llm requirements hint="Give the Kubernetes version constraint from Chart.yaml, the Helm version, and any dependency charts or CRDs that must already be present.">

- Helm 3 (no specific version pinned in the repository).
- A management Kubernetes cluster with the Cluster API v1beta1 CRDs (`cluster.x-k8s.io`, `controlplane.cluster.x-k8s.io`, `bootstrap.cluster.x-k8s.io`) installed.
- The cluster-api-provider-hetzner CRDs (`infrastructure.cluster.x-k8s.io`: `HetznerCluster`, `HCloudMachineTemplate`, `HCloudRemediationTemplate`) installed.
- Flux 2 controllers (source-controller, helm-controller, kustomize-controller) running in the management cluster, providing `source.toolkit.fluxcd.io/v1`, `helm.toolkit.fluxcd.io/v2`, and `kustomize.toolkit.fluxcd.io/v1`.
- A Kubernetes secret in the release namespace holding your HCloud API token (default secret name `prod`, key `hcloud`).
- SSH key(s) pre-registered in your Hetzner Cloud project.
- Egress internet access for provisioned nodes (they download runc 1.2.5, containerd 1.7.26, and Kubernetes v1.37.1 packages at boot).
- Pull access to `oci://ghcr.io/hauke-cloud/charts` (public; no authentication required).

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

3. Render the chart from the public OCI registry to verify the output:

```bash
helm template oci://ghcr.io/hauke-cloud/charts/capi-hetzner-cluster
```

4. Install the chart to provision a workload cluster on Hetzner Cloud:

```bash
helm install capi-hetzner-cluster oci://ghcr.io/hauke-cloud/charts/capi-hetzner-cluster
```

</llm>


## :airplane: Usage

<llm usage hint="Show installing with a values file, and how to reach or verify the deployed workload.">

The chart is published as an OCI artifact. Install it into your management cluster with a values file that supplies the Hetzner credentials and cluster topology:

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
  --version 1.0.0 \
  -f values.yaml
```

Before running the install, make sure a secret named `prod` exists in the target namespace with the HCloud API token under the key `hcloud`, and that the SSH key `default-0` is registered in your Hetzner Cloud project.

Once the `KubeadmControlPlane` has converged, the chart creates a kubeconfig secret named `capi-hetzner-cluster-kubeconfig` (key `value`). Retrieve it and point `kubectl` at the new workload cluster:

```bash
kubectl get secret capi-hetzner-cluster-kubeconfig \
  -o jsonpath='{.data.value}' | base64 -d > workload-kubeconfig

KUBECONFIG=workload-kubeconfig kubectl get nodes
```

</llm>


## :wrench: Configuration

<llm configuration hint="A table of the top-level values from values.yaml: key, default, description. Point at values.yaml for the full set.">

The chart is configured entirely through Helm values. The table below covers the top-level keys; see `charts/capi-hetzner-cluster/values.yaml` for the full set.

| Key | Default | Description |
|-----|---------|-------------|
| `hetzner.token.existingSecret.name` | `"prod"` | Secret in the release namespace holding the HCloud API token (key `hcloud`). |
| `hetzner.sshKeys` | `["default-0"]` | SSH key names registered in the Hetzner Cloud project. |
| `kubernetes.version` | `"v1.37.1"` | Version for `KubeadmControlPlane` and `MachineDeployment`; also hard-coded in `preKubeadmCommands`. |
| `controlPlanes` | *(object)* | Control-plane pool: `image` (`ubuntu-24.04`), `nodes` (3), `regions` (`[fsn1]`), `flavor.name` (`cx22`), `endpoint`, `placement.type` (`spread`), `staticRoutes`, `kubeadmConfigTemplate`. |
| `workers` | *(list)* | Worker pools: `name`, `image`, `minNodes` (0), `maxNodes` (5), `region` (`fsn1`), `flavor` (`cx23`), `placement.type` (`spread`), `staticRoutes`, `configVersion` (increase to roll the pool onto a changed bootstrap config), `kubeadmConfigTemplate`. |
| `oidc.enabled` | `false` | When true, injects `oidc.*` args into the API server. |
| `bootstrap.*` | `enabled: true` | Flux bootstrap blocks for Cilium, HCloud CCM, HCloud CSI, cluster-autoscaler, and Flux itself; each has `version`, `repoOverrides`, and `chartOverrides`/`kustomizationOverrides`. |
| `network` | *(object)* | `clusterNetwork.pods.cidrBlocks` (`["10.244.0.0/16"]`), `hcloudNetwork.enabled` (`false`), `staticRoutes` (`{}`). |
| `remediation` | `retryLimit: 1`, `timeout: "180s"`, `type: "Reboot"` | Parameters for `HCloudRemediationTemplate`. |
| `healthChecks` | `maxUnhealthy: "100%"`, `nodeStartupTimeout: "15m"` | Parameters for `MachineHealthCheck`. |

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
