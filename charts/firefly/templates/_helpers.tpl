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
Create a Firefly node name. These must be unique within their Firefly network.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "firefly.nodeName" -}}
{{- if .Values.core.nodeNameOverride }}
{{- .Values.core.nodeNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Namespace (include "firefly.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
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
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{- define "firefly.dataexchangeLabels" -}}
helm.sh/chart: {{ include "firefly.chart" . }}
{{ include "firefly.dataexchangeSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{- define "firefly.erc1155Labels" -}}
helm.sh/chart: {{ include "firefly.chart" . }}
{{ include "firefly.erc1155SelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{- define "firefly.erc20erc721Labels" -}}
helm.sh/chart: {{ include "firefly.chart" . }}
{{ include "firefly.erc20erc721SelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{- define "firefly.sandboxLabels" -}}
helm.sh/chart: {{ include "firefly.chart" . }}
{{ include "firefly.sandboxSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end }}

{{- define "firefly.ethconnectLabels" -}}
helm.sh/chart: {{ include "firefly.chart" . }}
{{ include "firefly.ethconnectSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
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

{{- define "firefly.erc20erc721SelectorLabels" -}}
app.kubernetes.io/name: {{ include "firefly.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: erc20-erc721
{{- end }}

{{- define "firefly.ethconnectSelectorLabels" -}}
app.kubernetes.io/name: {{ include "firefly.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: ethconnect
{{- end }}

{{- define "firefly.sandboxSelectorLabels" -}}
app.kubernetes.io/name: {{ include "firefly.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: sandbox
{{- end }}

{{- define "firefly.ethconnectRegisterContractsJobName" -}}
{{ printf "%s-%s-%s-register-contracts" (include "firefly.fullname" .) (.Values.config.organizationName | lower) .Chart.Version | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "firefly.erc20erc721DeployContractsJobName" -}}
{{ printf "%s-%s-%s-erc20-erc-721-deploy-contracts" (include "firefly.fullname" .) (.Values.config.organizationName | lower) .Chart.Version | trunc 63 | trimSuffix "-" }}
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

{{- define "firefly.coreHttpPublicURL" -}}
{{- if .Values.core.ingress.enabled }}
{{- if .Values.core.ingress.tls }}
{{- printf "https://%s" (index .Values.core.ingress.hosts 0).host }}
{{- else }}
{{- printf "http://%s" (index .Values.core.ingress.hosts 0).host }}
{{- end }}
{{- else }}
{{- printf "http://%s.%s.svc:%d" (include "firefly.fullname" .) .Release.Namespace (.Values.core.service.httpPort | int64) }}
{{- end }}
{{- end }}

{{- define "firefly.coreAdminPublicURL" -}}
{{- printf "http://%s.%s.svc:%d" (include "firefly.fullname" .) .Release.Namespace (.Values.core.service.adminPort | int64) }}
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
  publicURL: {{ .Values.config.httpPublicUrl | default (include "firefly.coreHttpPublicURL" . ) }}
  {{- if .Values.config.httpTls }}
  tls:
    {{- toYaml .Values.config.httpTls | nindent 4 }}
  {{- end }}
admin:
  port:  {{ .Values.core.service.adminPort }}
  address: 0.0.0.0
  publicURL: {{ .Values.config.adminPublicUrl | default (include "firefly.coreAdminPublicURL" . ) }}
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

plugins:
  {{- if .Values.config.blockchainOverride }}
  blockchain:
    {{- tpl .Values.config.blockchainOverride . | nindent 4 }}
  {{- else }}{{/* if not overridden */}}
  blockchain:
  {{- if or .Values.config.ethconnectUrl .Values.ethconnect.enabled }}
    - name: eth0
      type: ethereum
      ethereum:
        ethconnect:
          {{ if .Values.ethconnect.enabled }}
          url: http://{{ include "firefly.fullname" . }}-ethconnect.{{ .Release.Namespace }}.svc:{{ .Values.ethconnect.service.apiPort }}
          {{ else }}
          url: {{ tpl .Values.config.ethconnectUrl . }}
          {{ end }}
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
        {{- if .Values.config.addresssResolverUrlTemplate }}
        addressResolver:
          urlTemplate: {{ .Values.config.addresssResolverUrlTemplate }}
        {{- end }}
  {{- else if .Values.evmconnect.enabled }}
    - name: eth0
      type: ethereum
      ethereum:
        ethconnect:
          {{- if .Values.evmconnect.enabled }}
          url: http://{{ include "firefly.fullname" . }}-evmconnect.{{ .Release.Namespace }}.svc:{{ .Values.evmconnect.service.port }}
          {{- end }}
          topic: {{ .Values.config.evmconnectTopic | quote }}
          retry:
            enable: {{ .Values.config.evmconnectRetry }}
        {{- if .Values.config.addresssResolverUrlTemplate }}
        addressResolver:
          urlTemplate: {{ .Values.config.addresssResolverUrlTemplate }}
        {{- end }}
  {{- end }}
  {{- if .Values.config.fabconnectUrl }}
    - name: fabric0
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
  {{- if .Values.config.extraBlockchains }}
    {{- tpl .Values.config.extraBlockchains . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- if .Values.config.databaseOverride }}
  database:
    {{- tpl .Values.config.databaseOverride . | nindent 4 }}
  {{- else }}
  database:
  {{- if .Values.config.postgresUrl }}
    - name: database0
      type: postgres
      postgres:
        url: {{ tpl .Values.config.postgresUrl . }}
        migrations:
          auto: {{ .Values.config.postgresAutomigrate }}
  {{- end }}
  {{- if .Values.config.extraDatabases }}
    {{- tpl .Values.config.extraDatabases . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- if .Values.config.sharedstorageOverride }}
  sharedstorage:
    {{- tpl .Values.config.sharedstorageOverride . | nindent 4 }}
  {{- else }}
  sharedstorage:
  {{- if and .Values.config.ipfsApiUrl .Values.config.ipfsGatewayUrl }}
    - name: sharedstorage0
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
            username: {{ .Values.config.ipfsGatewayUsername | quote }}
            password: {{ .Values.config.ipfsGatewayPassword | quote }}
          {{- end }}
  {{- end }}
  {{- if .Values.config.extraSharedstorage }}
    {{- tpl .Values.config.extraSharedstorage . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- if and .Values.config.dataexchangeOverride (not .Values.dataexchange.enabled) }}
  dataexchange:
    {{- tpl .Values.config.dataexchangeOverride . | nindent 4 }}
  {{- else }}
  dataexchange:
    {{- if .Values.dataexchange.enabled }}
    - type: ffdx
      name: dataexchange0
      ffdx:
        url: http://{{ include "firefly.fullname" . }}-dx.{{ .Release.Namespace }}.svc:{{ .Values.dataexchange.service.apiPort }}
        {{- if .Values.dataexchange.apiKey }}
        headers:
          x-api-key: {{ .Values.dataexchange.apiKey | quote }}
        {{- end }}
    {{- else }}
    - type: ffdx
      name: dataexchange0
      ffdx:
        url: {{ tpl .Values.config.dataexchangeUrl . }}
        {{- if .Values.config.dataexchangeAPIKey }}
        headers:
          x-api-key: {{ .Values.config.dataexchangeAPIKey | quote }}
        {{- end }}
    {{- end }}
    {{- if .Values.config.extraDataexchanges }}
    {{- tpl .Values.config.extraDataexchanges . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if .Values.config.tokensOverride }}
  tokens:
    {{- tpl .Values.config.tokensOverride . | nindent 4 }}
  {{- else }}
  {{- if or .Values.erc1155.enabled .Values.erc20erc721.enabled .Values.config.extraTokens }}
  tokens:
    {{- if .Values.erc1155.enabled }}
    - type: fftokens
      name: erc1155
      remoteName: erc1155
      fftokens:
        url: http://{{ include "firefly.fullname" . }}-erc1155.{{ .Release.Namespace }}.svc:{{ .Values.erc1155.service.port }}
    {{- end }}
    {{- if .Values.erc20erc721.enabled }}
    - type: fftokens
      name: erc20-erc721
      remoteName: erc20-erc721
      fftokens:
        url: http://{{ include "firefly.fullname" . }}-erc20-erc721.{{ .Release.Namespace }}.svc:{{ .Values.erc20erc721.service.port }}
    {{- end }}
  {{- end }}
  {{- end }}

namespaces:
  default: default
  predefined:
    {{- if .Values.config.extraNamespaces }}
    {{- tpl .Values.config.extraNamespaces . | nindent 4 }}
    {{- end }}
    - name: default
      remoteName: default
      description: Default predefined namespace
      {{- if and (eq .Values.config.defaultBlockchainType "ethereum") (or .Values.config.evmconnectUrl .Values.evmconnect.enabled .Values.config.ethconnectUrl .Values.ethconnect.enabled) }}
      defaultKey: {{ .Values.config.organizationKey }}
      {{- else if .Values.config.fabconnectUrl }}
      defaultKey: {{ .Values.config.fabconnectSigner }}
      {{- end }}
      plugins:
        - database0
        {{- if and (eq .Values.config.defaultBlockchainType "ethereum") (or .Values.config.evmconnectUrl .Values.evmconnect.enabled .Values.config.ethconnectUrl .Values.ethconnect.enabled) }}
        - eth0
        {{- else if .Values.config.fabconnectUrl }}
        - fabric0
        {{- end }}
        - dataexchange0
        - sharedstorage0
        {{- if .Values.erc1155.enabled }}
        - erc1155
        {{- end }}
        {{- if .Values.erc20erc721.enabled }}
        - erc20-erc721
        {{- end }}
      multiparty:
        enabled: true
        org:
          name: {{ .Values.config.organizationName }}
          description: The {{ .Values.config.organizationName }} organization
          {{- if and (eq .Values.config.defaultBlockchainType "ethereum") (or .Values.config.evmconnectUrl .Values.evmconnect.enabled .Values.config.ethconnectUrl .Values.ethconnect.enabled) }}
          key: {{ .Values.config.organizationKey }}
          {{- else if .Values.config.fabconnectUrl }}
          key: {{ .Values.config.fabconnectSigner }}
          {{- end }}
        node:
          name: {{ include "firefly.nodeName" . }}
          description: {{ include "firefly.nodeName" . }}
        contract:
          {{- if and (eq .Values.config.defaultBlockchainType "ethereum") (or .Values.config.evmconnectUrl .Values.evmconnect.enabled .Values.config.ethconnectUrl .Values.ethconnect.enabled) }}
          - location:
              address: {{ .Values.config.fireflyContractAddress }}
            firstEvent: {{ .Values.config.fireflyContractFirstEvent }}
          {{- if .Values.config.fireflyContracts }}
          {{- range .Values.config.fireflyContracts }}
          - location:
              address: {{ .address | quote }}
            firstEvent: {{ .firstEvent }}
          {{- end }}
          {{- end }}
          {{- else if .Values.config.fabconnectUrl }}
          - location:
              chaincode: {{ .Values.config.fireflyChaincode }}
              channel: {{ .Values.config.fabconnectChannel }}
            firstEvent: ""
          {{- if .Values.config.fireflyContracts }}
          {{- range .Values.config.fireflyContracts }}
          - location:
              channel: {{ .channel | quote }}
              chaincode: {{ .chaincode | quote }}
            firstEvent: {{ .firstEvent }}
          {{- end }}
          {{- end }}
          {{- end }}
{{- end }}

{{- define "firefly.ethconnectUrlEnvVar" -}}
- name: ETHCONNECT_URL
{{- if .Values.ethconnect.enabled }}
  value: "http://{{ include "firefly.fullname" . }}-ethconnect.{{ .Release.Namespace }}.svc:{{ .Values.ethconnect.service.apiPort }}"
{{- else if .Values.evmconnect.enabled }}
  value: "http://{{ include "firefly.fullname" . }}-evmconnect.{{ .Release.Namespace }}.svc:{{ .Values.evmconnect.service.port }}"
{{- else if .Values.config.ethconnectUrl }}
  value: {{ tpl .Values.config.ethconnectUrl . }}
{{- else }}
  value: {{ tpl .Values.config.evmconnectUrl . }}
{{- end }}
{{- end }}