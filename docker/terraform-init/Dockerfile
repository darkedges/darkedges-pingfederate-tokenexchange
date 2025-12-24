# # Stage 1: compile the Artifactory terraform provider
FROM busybox:1.36 AS builder

# VAULT provider
ARG VAULT_PROVIDER_VERSION=5.6.0
WORKDIR /src/plugins/registry.terraform.io/hashicorp/vault/${VAULT_PROVIDER_VERSION}/linux_amd64/
ADD https://releases.hashicorp.com/terraform-provider-vault/${VAULT_PROVIDER_VERSION}/terraform-provider-vault_${VAULT_PROVIDER_VERSION}_linux_amd64.zip terraform-provider-vault_${VAULT_PROVIDER_VERSION}_linux_amd64.zip
RUN unzip terraform-provider-vault_${VAULT_PROVIDER_VERSION}_linux_amd64.zip && \
    rm -f terraform-provider-vault_${VAULT_PROVIDER_VERSION}_linux_amd64.zip

# Kubernetes provider
ARG KUBERNETES_PROVIDER_VERSION=3.0.1
WORKDIR /src/plugins/registry.terraform.io/hashicorp/kubernetes/${KUBERNETES_PROVIDER_VERSION}/linux_amd64/
ADD https://releases.hashicorp.com/terraform-provider-kubernetes/${KUBERNETES_PROVIDER_VERSION}/terraform-provider-kubernetes_${KUBERNETES_PROVIDER_VERSION}_linux_amd64.zip terraform-provider-kubernetes_${KUBERNETES_PROVIDER_VERSION}_linux_amd64.zip
RUN unzip terraform-provider-kubernetes_${KUBERNETES_PROVIDER_VERSION}_linux_amd64.zip && \
    rm -f terraform-provider-kubernetes_${KUBERNETES_PROVIDER_VERSION}_linux_amd64.zip

# kubectl provider
ARG KUBECTL_PROVIDER_VERSION=1.19.0
WORKDIR /src/plugins/registry.terraform.io/gavinbunney/kubectl/${KUBECTL_PROVIDER_VERSION}/linux_amd64/
ADD https://github.com/gavinbunney/terraform-provider-kubectl/releases/download/v${KUBECTL_PROVIDER_VERSION}/terraform-provider-kubectl_${KUBECTL_PROVIDER_VERSION}_linux_amd64.zip terraform-provider-kubectl_${KUBECTL_PROVIDER_VERSION}_linux_amd64.zip
RUN unzip terraform-provider-kubectl_${KUBECTL_PROVIDER_VERSION}_linux_amd64.zip && \
    rm -f terraform-provider-kubectl_${KUBECTL_PROVIDER_VERSION}_linux_amd64.zip

# k8s provider
ARG K8S_PROVIDER_VERSION=2023.9.4
WORKDIR /src/plugins/registry.terraform.io/metio/k8s/${K8S_PROVIDER_VERSION}/linux_amd64/
ADD https://github.com/metio/terraform-provider-k8s/releases/download/${K8S_PROVIDER_VERSION}/terraform-provider-k8s_${K8S_PROVIDER_VERSION}_linux_amd64.zip terraform-provider-k8s_${K8S_PROVIDER_VERSION}_linux_amd64.zip
RUN unzip terraform-provider-k8s_${K8S_PROVIDER_VERSION}_linux_amd64.zip && \
    rm -f terraform-provider-k8s_${K8S_PROVIDER_VERSION}_linux_amd64.zip

# LOCAL provider
ARG LOCAL_PROVIDER_VERSION=2.6.1
WORKDIR /src/plugins/registry.terraform.io/hashicorp/local/${LOCAL_PROVIDER_VERSION}/linux_amd64/
ADD https://releases.hashicorp.com/terraform-provider-local/${LOCAL_PROVIDER_VERSION}/terraform-provider-local_${LOCAL_PROVIDER_VERSION}_linux_amd64.zip terraform-provider-local_${LOCAL_PROVIDER_VERSION}_linux_amd64.zip
RUN unzip terraform-provider-local_${LOCAL_PROVIDER_VERSION}_linux_amd64.zip && \
    rm -f terraform-provider-local_${LOCAL_PROVIDER_VERSION}_linux_amd64.zip

# pkcs12 provider
ARG PKCS12_PROVIDER_VERSION=0.2.5
WORKDIR /src/plugins/registry.terraform.io/chilicat/pkcs12/${PKCS12_PROVIDER_VERSION}/linux_amd64/
ADD https://github.com/chilicat/terraform-provider-pkcs12/releases/download/v${PKCS12_PROVIDER_VERSION}/terraform-provider-pkcs12_${PKCS12_PROVIDER_VERSION}_linux_amd64.zip terraform-provider-pkcs12_${PKCS12_PROVIDER_VERSION}_linux_amd64.zip
RUN unzip terraform-provider-pkcs12_${PKCS12_PROVIDER_VERSION}_linux_amd64.zip && \
    rm -f terraform-provider-pkcs12_${PKCS12_PROVIDER_VERSION}_linux_amd64.zip

# Stage 2: build hashicorp/terraform image with providers baked in
FROM hashicorp/terraform:1.14.3

# Install requirements via Artifactory alpine mirror
RUN apk add --no-cache jq curl libcurl

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.34.1/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Copy Terraform provider binaries from first stage
COPY --from=builder /src/plugins/registry.terraform.io/ /terraform.d/plugins/registry.terraform.io/
COPY scripts/init-vault.sh /init-vault.sh

# Checkpoint itself can be entirely disabled for all HashiCorp products
# RUN echo 'disable_checkpoint = true' > /root/.terraformrc
ENV CHECKPOINT_DISABLE=1

ENV TF_DATA_DIR=/mnt/terraform/data

ENV TF_CLI_ARGS_init="-plugin-dir=/terraform.d/plugins"

COPY init/* /mnt/init/

WORKDIR /mnt/init

ENTRYPOINT [ "/init-vault.sh" ]
