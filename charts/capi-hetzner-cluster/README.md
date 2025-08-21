# capi-hetzner-cluster

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

Helm chart to deploy a cluster api based Kubernetes cluster to the Hetzner Cloud

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| bootstrap.autoscaler.chartOverrides.interval | string | `"5m0s"` |  |
| bootstrap.autoscaler.chartOverrides.kubeConfig.secretRef.key | string | `""` |  |
| bootstrap.autoscaler.chartOverrides.kubeConfig.secretRef.name | string | `""` |  |
| bootstrap.autoscaler.chartOverrides.name | string | `"cluster-autoscaler"` |  |
| bootstrap.autoscaler.chartOverrides.values.cloudProvider | string | `"clusterapi"` |  |
| bootstrap.autoscaler.chartOverrides.values.clusterAPIMode | string | `"kubeconfig-incluster"` |  |
| bootstrap.autoscaler.chartOverrides.values.extraArgs.logtostderr | bool | `true` |  |
| bootstrap.autoscaler.chartOverrides.values.extraArgs.stderrthreshold | string | `"ERROR"` |  |
| bootstrap.autoscaler.chartOverrides.values.extraArgs.v | int | `4` |  |
| bootstrap.autoscaler.chartOverrides.values.rbac.additionalRules[0].apiGroups[0] | string | `"infrastructure.cluster.x-k8s.io"` |  |
| bootstrap.autoscaler.chartOverrides.values.rbac.additionalRules[0].resources[0] | string | `"hcloudmachinetemplates"` |  |
| bootstrap.autoscaler.chartOverrides.values.rbac.additionalRules[0].verbs[0] | string | `"get"` |  |
| bootstrap.autoscaler.chartOverrides.values.rbac.additionalRules[0].verbs[1] | string | `"list"` |  |
| bootstrap.autoscaler.chartOverrides.values.rbac.additionalRules[0].verbs[2] | string | `"watch"` |  |
| bootstrap.autoscaler.enabled | bool | `true` |  |
| bootstrap.autoscaler.repoOverrides.interval | string | `"5m0s"` |  |
| bootstrap.autoscaler.repoOverrides.type | string | `"default"` |  |
| bootstrap.autoscaler.repoOverrides.url | string | `"https://kubernetes.github.io/autoscaler"` |  |
| bootstrap.autoscaler.version | string | `"9.50.1"` |  |
| bootstrap.cilium.chartOverrides.interval | string | `"5m0s"` |  |
| bootstrap.cilium.chartOverrides.kubeConfig.secretRef.key | string | `""` |  |
| bootstrap.cilium.chartOverrides.kubeConfig.secretRef.name | string | `""` |  |
| bootstrap.cilium.chartOverrides.name | string | `"cilium"` |  |
| bootstrap.cilium.chartOverrides.targetNamespace | string | `"kube-system"` |  |
| bootstrap.cilium.chartOverrides.values.extraArgs[0] | string | `"--direct-routing-device=eth0"` |  |
| bootstrap.cilium.chartOverrides.values.hostFirewall.enabled | bool | `true` |  |
| bootstrap.cilium.chartOverrides.values.operator.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| bootstrap.cilium.chartOverrides.values.operator.tolerations[0].operator | string | `"Exists"` |  |
| bootstrap.cilium.chartOverrides.values.operator.tolerations[1].key | string | `"node-role.kubernetes.io/master"` |  |
| bootstrap.cilium.chartOverrides.values.operator.tolerations[1].operator | string | `"Exists"` |  |
| bootstrap.cilium.chartOverrides.values.operator.tolerations[2].key | string | `"node.kubernetes.io/not-ready"` |  |
| bootstrap.cilium.chartOverrides.values.operator.tolerations[2].operator | string | `"Exists"` |  |
| bootstrap.cilium.chartOverrides.values.operator.tolerations[3].key | string | `"node.cluster.x-k8s.io/uninitialized"` |  |
| bootstrap.cilium.chartOverrides.values.operator.tolerations[3].operator | string | `"Exists"` |  |
| bootstrap.cilium.chartOverrides.values.operator.tolerations[4].key | string | `"node.cloudprovider.kubernetes.io/uninitialized"` |  |
| bootstrap.cilium.chartOverrides.values.operator.tolerations[4].operator | string | `"Exists"` |  |
| bootstrap.cilium.enabled | bool | `true` |  |
| bootstrap.cilium.repoOverrides.interval | string | `"5m0s"` |  |
| bootstrap.cilium.repoOverrides.type | string | `"default"` |  |
| bootstrap.cilium.repoOverrides.url | string | `"https://helm.cilium.io/"` |  |
| bootstrap.cilium.version | string | `"1.18.1"` |  |
| bootstrap.flux.enabled | bool | `true` |  |
| bootstrap.flux.kustomizationOverrides.interval | string | `"5m0s"` |  |
| bootstrap.flux.kustomizationOverrides.kubeConfig.secretRef.key | string | `""` |  |
| bootstrap.flux.kustomizationOverrides.kubeConfig.secretRef.name | string | `""` |  |
| bootstrap.flux.kustomizationOverrides.path | string | `"./manifests/install"` |  |
| bootstrap.flux.kustomizationOverrides.prune | bool | `true` |  |
| bootstrap.flux.kustomizationOverrides.targetNamespace | string | `"flux-system"` |  |
| bootstrap.flux.kustomizationOverrides.timeout | string | `"1m"` |  |
| bootstrap.flux.repoOverrides.interval | string | `"5m0s"` |  |
| bootstrap.flux.repoOverrides.ref.branch | string | `"main"` |  |
| bootstrap.flux.repoOverrides.url | string | `"https://github.com/fluxcd/flux2.git"` |  |
| bootstrap.flux.version | string | `"9.50.1"` |  |
| bootstrap.hetznerCCM.chartOverrides.interval | string | `"5m0s"` |  |
| bootstrap.hetznerCCM.chartOverrides.kubeConfig.secretRef.key | string | `""` |  |
| bootstrap.hetznerCCM.chartOverrides.kubeConfig.secretRef.name | string | `""` |  |
| bootstrap.hetznerCCM.chartOverrides.name | string | `"hcloud-cloud-controller-manager"` |  |
| bootstrap.hetznerCCM.chartOverrides.targetNamespace | string | `"kube-system"` |  |
| bootstrap.hetznerCCM.chartOverrides.values.additionalTolerations[0].key | string | `"node.cluster.x-k8s.io/uninitialized"` |  |
| bootstrap.hetznerCCM.chartOverrides.values.additionalTolerations[0].operator | string | `"Exists"` |  |
| bootstrap.hetznerCCM.enabled | bool | `true` |  |
| bootstrap.hetznerCCM.repoOverrides.interval | string | `"5m0s"` |  |
| bootstrap.hetznerCCM.repoOverrides.type | string | `"default"` |  |
| bootstrap.hetznerCCM.repoOverrides.url | string | `"https://charts.hetzner.cloud"` |  |
| bootstrap.hetznerCCM.version | string | `"v1.26.0"` |  |
| controlPlanes.endpoint.host | string | `""` |  |
| controlPlanes.endpoint.port | int | `443` |  |
| controlPlanes.flavor.name | string | `"cx22"` |  |
| controlPlanes.image | string | `"ubuntu-24.04"` |  |
| controlPlanes.loadBalancer.region | string | `"fsn1"` |  |
| controlPlanes.network.enabled | bool | `false` |  |
| controlPlanes.nodes | int | `3` |  |
| controlPlanes.placement.type | string | `"spread"` |  |
| controlPlanes.regions[0] | string | `"fsn1"` |  |
| fullnameOverride | string | `""` |  |
| healthChecks.maxUnhealthy | string | `"100%"` |  |
| healthChecks.nodeStartupTimeout | string | `"15m"` |  |
| healthChecks.unhealhyConditions[0].status | string | `"Unknown"` |  |
| healthChecks.unhealhyConditions[0].timeout | string | `"180s"` |  |
| healthChecks.unhealhyConditions[0].type | string | `"Ready"` |  |
| healthChecks.unhealhyConditions[1].status | string | `"False"` |  |
| healthChecks.unhealhyConditions[1].timeout | string | `"180s"` |  |
| healthChecks.unhealhyConditions[1].type | string | `"Ready"` |  |
| hetzner.sshKeys[0] | string | `"default-0"` |  |
| hetzner.token.existingSecret.keys.hcloudToken | string | `"hcloud"` |  |
| hetzner.token.existingSecret.keys.hetznerRobotPassword | string | `"robot-password"` |  |
| hetzner.token.existingSecret.keys.hetznerRobotUser | string | `"robot-user"` |  |
| hetzner.token.existingSecret.name | string | `"prod"` |  |
| kubernetes.version | string | `"v1.32.7"` |  |
| nameOverride | string | `""` |  |
| network.clusterNetwork.podCidrBlocks[0] | string | `"10.244.0.0/16"` |  |
| nodeSelector | object | `{}` |  |
| remedation.retryLimit | int | `1` |  |
| remedation.timeout | string | `"180s"` |  |
| remedation.type | string | `"Reboot"` |  |
| tolerations | list | `[]` |  |
| workers[0].flavor.cpu | int | `2` |  |
| workers[0].flavor.ephemeralStorage | string | `"40Gi"` |  |
| workers[0].flavor.maxPods | int | `120` |  |
| workers[0].flavor.memory | string | `"4Gi"` |  |
| workers[0].flavor.name | string | `"cx22"` |  |
| workers[0].image | string | `"ubuntu-24.04"` |  |
| workers[0].maxNodes | int | `5` |  |
| workers[0].minNodes | int | `0` |  |
| workers[0].name | string | `"worker-1"` |  |
| workers[0].placement.type | string | `"spread"` |  |
| workers[0].region | string | `"fsn1"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
