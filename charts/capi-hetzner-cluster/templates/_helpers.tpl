{{/*
Expand the name of the chart.
*/}}
{{- define "capi-hetzner-cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "capi-hetzner-cluster.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "capi-hetzner-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "capi-hetzner-cluster.labels" -}}
helm.sh/chart: {{ include "capi-hetzner-cluster.chart" . }}
{{ include "capi-hetzner-cluster.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "capi-hetzner-cluster.selectorLabels" -}}
app.kubernetes.io/name: {{ include "capi-hetzner-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the KubeadmConfigTemplate of a worker group.
Accepts a dict of { "root": $, "group": <a workers entry> }.
Cluster API only rolls a MachineDeployment when its own spec changes, an in
place update of the referenced template is ignored. Setting configVersion
suffixes the name, so bumping it creates a new template, changes the
bootstrap configRef and thereby rolls the group. Without it the name stays
as is.
*/}}
{{- define "capi-hetzner-cluster.workerBootstrapName" -}}
{{- $name := printf "%s-%s" (include "capi-hetzner-cluster.name" .root) .group.name -}}
{{- $version := .group.configVersion -}}
{{- if kindIs "float64" $version -}}
{{- $version = int64 $version -}}
{{- end -}}
{{- if $version -}}
{{- printf "%s-%v" $name $version -}}
{{- else -}}
{{- $name -}}
{{- end -}}
{{- end }}

{{/*
Resolve the effective static route configuration for a node group.
Accepts a dict of { "root": $, "group": <controlPlanes map or a workers entry> }.
A group's own staticRoutes replaces the chart wide network.staticRoutes,
it is not merged into it. Renders nothing when neither defines any routes.
*/}}
{{- define "capi-hetzner-cluster.staticRoutes" -}}
{{- $global := (.root.Values.network).staticRoutes | default dict -}}
{{- $group := (.group).staticRoutes | default dict -}}
{{- $effective := $global -}}
{{- if $group.routes -}}
{{- $effective = $group -}}
{{- end -}}
{{- if $effective.routes -}}
{{- toYaml $effective -}}
{{- end -}}
{{- end }}

{{/*
Netplan drop-in carrying the static routes of a node group, rendered as an
entry for a KubeadmConfig `files:` list. Netplan merges per interface keys
with the image own 50-cloud-init.yaml, so only the routes are declared here.
Accepts the same dict as capi-hetzner-cluster.staticRoutes.
*/}}
{{- define "capi-hetzner-cluster.staticRoutesFile" -}}
{{- $raw := include "capi-hetzner-cluster.staticRoutes" . -}}
{{- if $raw }}
{{- $routes := fromYaml $raw -}}
- content: |
    network:
      version: 2
      ethernets:
        {{ $routes.interface | default "eth0" }}:
          routes:
          {{- toYaml $routes.routes | nindent 12 }}
  owner: root:root
  path: /etc/netplan/99-static-routes.yaml
  permissions: "0600"
{{- end }}
{{- end }}

{{/*
Commands applying the netplan drop-in above. These have to run before any
command that depends on the routes, so they are placed at the top of
preKubeadmCommands.
Accepts the same dict as capi-hetzner-cluster.staticRoutes.
*/}}
{{- define "capi-hetzner-cluster.staticRoutesPreKubeadmCommands" -}}
{{- if include "capi-hetzner-cluster.staticRoutes" . -}}
- netplan apply
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "capi-hetzner-cluster.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "capi-hetzner-cluster.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
