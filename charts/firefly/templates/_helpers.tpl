{{/*
  Copyright © 2022 Kaleido, Inc.

  SPDX-License-Identifier: Apache-2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://swww.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "firefly.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "firefly.fullname" -}}
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
{{- define "firefly.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "firefly.coreLabels" -}}
helm.sh/chart: {{ include "firefly.chart" . }}
{{ include "firefly.coreSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kuberentes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{- define "firefly.dataexchangeLabels" -}}
helm.sh/chart: {{ include "firefly.chart" . }}
{{ include "firefly.dataexchangeSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kuberentes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{- define "firefly.erc1155Labels" -}}
helm.sh/chart: {{ include "firefly.chart" . }}
{{ include "firefly.erc1155SelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kuberentes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{- define "firefly.erc20Labels" -}}
helm.sh/chart: {{ include "firefly.chart" . }}
{{ include "firefly.erc20SelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kuberentes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "firefly.ethconnectLabels" -}}
helm.sh/chart: {{ include "firefly.chart" . }}
{{ include "firefly.ethconnectSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kuberentes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "firefly.coreSelectorLabels" -}}
app.kubernetes.io/name: {{ include "firefly.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: core
{{- end }}

{{- define "firefly.dataexchangeSelectorLabels" -}}
app.kubernetes.io/name: {{ include "firefly.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: dx
{{- end }}

{{- define "firefly.erc1155SelectorLabels" -}}
app.kubernetes.io/name: {{ include "firefly.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: erc1155
{{- end }}

{{- define "firefly.erc20SelectorLabels" -}}
app.kubernetes.io/name: {{ include "firefly.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: erc20
{{- end }}

{{/*
Config helpers
*/}}
{{- define "firefly.dataexchangeP2PHost" -}}
{{- if .Values.dataexchange.ingress.enabled }}
{{- (index .Values.dataexchange.ingress.hosts 0).host }}
{{- else }}
{{- printf "%s-dx.%s.svc:%d" (include "firefly.fullname" .) .Release.Namespace (.Values.dataexchange.service.p2pPort | int64) }}
{{- end }}
{{- end }}

{{- define "firefly.coreConfig" -}}
{{- if .Values.config.debugEnabled }}
log:
  level: debug
debug:
  port: {{ .Values.core.service.debugPort }}
{{- end }}
http:
  port: {{ .Values.core.service.httpPort }}
  address: 0.0.0.0
admin:
  port:  {{ .Values.core.service.adminPort }}
  address: 0.0.0.0
  enabled: {{ .Values.config.adminEnabled }}
  preinit: {{ and .Values.config.adminEnabled .Values.config.preInit }}
metrics:
  enabled: {{ .Values.config.metricsEnabled }}
{{- if .Values.config.metricsEnabled }}
  path: {{ .Values.config.metricsPath }}
  address: 0.0.0.0
  port: {{  .Values.core.service.metricsPort }}
{{- end }}
ui:
  path: ./frontend
org:
  name: {{ .Values.config.organizationName }}
  key: {{ .Values.config.organizationKey }}
{{- if .Values.config.blockchainOverride }}
blockchain:
  {{- tpl .Values.config.blockchainOverride . | nindent 2 }}
{{- else if .Values.config.ethconnectUrl }}
blockchain:
  type: ethereum
  ethereum:
    ethconnect:
      url: {{ tpl .Values.config.ethconnectUrl . }}
      instance: {{ .Values.config.fireflyContractAddress }}
      topic: {{ .Values.config.ethconnectTopic | quote }}
      retry:
        enable: {{ .Values.config.ethconnectRetry }}
      {{- if and .Values.config.ethconnectUsername .Values.config.ethconnectPassword }}
      auth:
        username: {{ .Values.config.ethconnectUsername | quote }}
        password: {{ .Values.config.ethconnectPassword | quote }}
      {{- end }}
      {{- if .Values.config.ethconnectPrefixShort }}
      prefixShort: {{ .Values.config.ethconnectPrefixShort }}
      {{- end }}
      {{- if .Values.config.ethconnectPrefixLong }}
      prefixLong: {{ .Values.config.ethconnectPrefixLong }}
      {{- end }}
{{- else if .Values.config.fabconnectUrl }}
blockchain:
  type: fabric
  fabric:
    fabconnect:
      url: {{ tpl .Values.config.fabconnectUrl . }}
      {{- if and .Values.config.fabconnectUsername .Values.config.fabconnectPassword }}
      auth:
        username: {{ .Values.config.fabconnectUsername | quote }}
        password: {{ .Values.config.fabconnectPassword | quote }}
      {{- end }}
      retry:
        enable: {{ .Values.config.fabconnectRetry }}
      channel: {{ .Values.config.fabconnectChannel | quote }}
      chaincode: {{ .Values.config.fireflyChaincode | quote }}
      topic: {{ .Values.config.fabconnectTopic | quote }}
      signer: {{ .Values.config.fabconnectSigner | quote }}
{{- end }}
{{- if .Values.config.databaseOverride }}
database:
  {{- tpl .Values.config.databaseOverride . | nindent 2 }}
{{- else if .Values.config.postgresUrl }}
database:
  type: postgres
  postgres:
    url: {{ tpl .Values.config.postgresUrl . }}
    migrations:
      auto: {{ .Values.config.postgresAutomigrate }}
{{- end }}
{{- if .Values.config.publicstorageOverride }}
publicstorage:
  {{- tpl .Values.config.publicstorageOverride . | nindent 2 }}
{{- else if and .Values.config.ipfsApiUrl .Values.config.ipfsGatewayUrl }}
publicstorage:
  type: ipfs
  ipfs:
    api:
      url: {{ tpl .Values.config.ipfsApiUrl . }}
      {{- if and .Values.config.ipfsApiUsername .Values.config.ipfsApiPassword }}
      auth:
        username: {{ .Values.config.ipfsApiUsername |quote }}
        password:  {{ .Values.config.ipfsApiPassword | quote }}
      {{- end }}
    gateway:
      url: {{ tpl .Values.config.ipfsGatewayUrl . }}
      {{- if and .Values.config.ipfsGatewayUsername .Values.config.ipfsGatewayPassword }}
      auth:
        username: {{ .Values.config.ipfsGatewayUsername |quote }}
        password: {{ .Values.config.ipfsGatewayPassword | quote }}
      {{- end }}
{{- end }}
{{- if and .Values.config.dataexchangeOverride (not .Values.dataexchange.enabled) }}
dataexchange:
  {{- tpl .Values.config.dataexchangeOverride . | nindent 2 }}
{{- else }}
dataexchange:
  {{- if .Values.dataexchange.enabled }}
  https:
    url: http://{{ include "firefly.fullname" . }}-dx.{{ .Release.Namespace }}.svc:{{ .Values.dataexchange.service.apiPort }}
    {{- if .Values.dataexchange.apiKey }}
    headers:
      x-api-key: {{ .Values.dataexchange.apiKey | quote }}
    {{- end }}
  {{- else }}
  https:
    url: {{ tpl .Values.config.dataexchangeUrl . }}
    {{- if .Values.config.dataexchangeAPIKey }}
    headers:
      x-api-key: {{ .Values.config.dataexchangeAPIKey | quote }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if .Values.config.tokensOverride }}
tokens:
    {{- tpl .Values.config.tokensOverride . | nindent 2 }}
{{- else if or .Values.erc1155.enabled .Values.erc20.enabled }}
tokens:
  {{- if .Values.erc1155.enabled }}
  - plugin: fftokens
    name: erc1155
    url: http://{{ include "firefly.fullname" . }}-erc1155.{{ .Release.Namespace }}.svc:{{ .Values.erc1155.service.port }}
  {{- end }}
  {{- if .Values.erc20.enabled }}
    - plugin: fftokens
    name: erc20
    url: http://{{ include "firefly.fullname" . }}-erc20.{{ .Release.Namespace }}.svc:{{ .Values.erc20.service.port }}
  {{- end }}
{{- end }}
{{- end }}