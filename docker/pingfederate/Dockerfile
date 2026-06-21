ARG PINGID_ADAPTER_VERSION=2.17.0
ARG PINGID_INTEGRATION_KIT_VERSION=2.29.0
ARG PINGID_SDK_VERSION=1.14.6
ARG PINGID_SDK_ADAPTER_VERSION=1.8.2
ARG PINGID_SDK_INTEGRATION_KIT_VERSION=1.12
ARG ONETAP_ADAPTER_VERSION=1.0.0

FROM alpine:latest AS zip
ARG PINGID_ADAPTER_VERSION
ARG PINGID_INTEGRATION_KIT_VERSION
ARG PINGID_SDK_VERSION
ARG PINGID_SDK_ADAPTER_VERSION
ARG PINGID_SDK_INTEGRATION_KIT_VERSION
ARG ONETAP_ADAPTER_VERSION
RUN adduser -u 9031 -S ping -G root
COPY pf-pingid-integration-kit-2.29.0.zip /tmp
COPY pf-pingone-mfa-integration-kit-3.1.zip /tmp
COPY PingIDSDK_1.14.6.zip /tmp
COPY one-tap-status-adapter-${ONETAP_ADAPTER_VERSION}-dist.zip /tmp
RUN mkdir -p /tmp/pingfederate/deployments/ && \
    unzip /tmp/pf-pingid-integration-kit-2.29.0.zip -d /tmp/pingfederate/deployments/ && \
    unzip /tmp/pf-pingone-mfa-integration-kit-3.1.zip -d /tmp/pingfederate/deployments/ && \
    unzip /tmp/PingIDSDK_1.14.6.zip -d /tmp/pingfederate/deployments/ && \
    unzip /tmp/one-tap-status-adapter-${ONETAP_ADAPTER_VERSION}-dist.zip -d /tmp/pingfederate/deployments/
RUN mkdir -p /opt/server/server/default/deploy /opt/server/server/default/conf/language-packs /opt/server/server/default/conf/template /opt/server/server/default/lib && \
    cp /tmp/pingfederate/deployments/pf-pingid-integration-kit-${PINGID_INTEGRATION_KIT_VERSION}/pf-pingid-idp-adapter-${PINGID_ADAPTER_VERSION}/dist/pingid-web.war /opt/server/server/default/deploy/ && \
    cp /tmp/pingfederate/deployments/pf-pingid-integration-kit-${PINGID_INTEGRATION_KIT_VERSION}/pf-pingid-idp-adapter-${PINGID_ADAPTER_VERSION}/dist/pf-pingid-idp-adapter-${PINGID_ADAPTER_VERSION}.jar  /opt/server/server/default/deploy/ && \
    cp /tmp/pingfederate/deployments/pf-pingid-integration-kit-${PINGID_INTEGRATION_KIT_VERSION}/pf-pingid-idp-adapter-${PINGID_ADAPTER_VERSION}/dist/language-packs/* /opt/server/server/default/conf/language-packs && \
    cp /tmp/pingfederate/deployments/pf-pingid-integration-kit-${PINGID_INTEGRATION_KIT_VERSION}/pf-pingid-idp-adapter-${PINGID_ADAPTER_VERSION}/dist/pingid.offline.auth.login.template.html /opt/server/server/default/conf/template/ && \
    cp /tmp/pingfederate/deployments/pf-pingone-mfa-integration-kit/dist/pingfederate/server/default/deploy/* /opt/server/server/default/deploy/ && \
    cp -rf /tmp/pingfederate/deployments/pf-pingone-mfa-integration-kit/dist/pingfederate/server/default/conf/language-packs/* /opt/server/server/default/conf/language-packs/ && \
    cp -rf /tmp/pingfederate/deployments/pf-pingone-mfa-integration-kit/dist/pingfederate/server/default/conf/template/* /opt/server/server/default/conf/template/ && \
    cp /tmp/pingfederate/deployments/dist/pingfederate/server/default/deploy/* /opt/server/server/default/deploy/ && \
    cp -rf /tmp/pingfederate/deployments/dist/pingfederate/server/default/conf/* /opt/server/server/default/conf/ && \
    chown -R ping:root /opt/server/server/default && \
    find /opt/server/server/default -type d -exec chmod 0770 {} \; && \
    find /opt/server/server/default -type f -exec chmod 0660 {} \;
# RUN cp /tmp/pingfederate/deployments/PingIDSDK_${PINGID_SDK_VERSION}/pf-pingid-sdk-integration-kit-${PINGID_SDK_INTEGRATION_KIT_VERSION}/pf-pingid-sdk-idp-adapter-${PINGID_SDK_ADAPTER_VERSION}/dist/pingid-sdk-web.war /opt/server/server/default/deploy/ && \
#     cp /tmp/pingfederate/deployments/PingIDSDK_${PINGID_SDK_VERSION}/pf-pingid-sdk-integration-kit-${PINGID_SDK_INTEGRATION_KIT_VERSION}/pf-pingid-sdk-idp-adapter-${PINGID_SDK_ADAPTER_VERSION}/dist/pf-pingid-sdk-idp-adapter-${PINGID_SDK_ADAPTER_VERSION}.jar  /opt/server/server/default/deploy/ && \
#     cp /tmp/pingfederate/deployments/PingIDSDK_${PINGID_SDK_VERSION}/pf-pingid-sdk-integration-kit-${PINGID_SDK_INTEGRATION_KIT_VERSION}/pf-pingid-sdk-idp-adapter-${PINGID_SDK_ADAPTER_VERSION}/dist/pf-pingid-sdk-idp-selector-1.1.jar   /opt/server/server/default/deploy/ && \
#     cp /tmp/pingfederate/deployments/PingIDSDK_${PINGID_SDK_VERSION}/pf-pingid-sdk-integration-kit-${PINGID_SDK_INTEGRATION_KIT_VERSION}/pf-pingid-sdk-idp-adapter-${PINGID_SDK_ADAPTER_VERSION}/dist/language-packs/* /opt/server/server/default/conf/language-packs && \
#     cp /tmp/pingfederate/deployments/PingIDSDK_${PINGID_SDK_VERSION}/pf-pingid-sdk-integration-kit-${PINGID_SDK_INTEGRATION_KIT_VERSION}/pf-pingid-sdk-idp-adapter-${PINGID_SDK_ADAPTER_VERSION}/dist/templates/pingid.sdk.login.template.html /opt/server/server/default/conf/template/ && \
#     chown -R ping:root /opt/server/server/default && \
#     find /opt/server/server/default -type d -exec chmod 0770 {} \; && \
#     find /opt/server/server/default -type f -exec chmod 0660 {} \;
COPY pf.plugins.openidfederation.jar /opt/server/server/default/deploy/

FROM pingidentity/pingfederate:12.3.3-edge
ARG PINGID_ADAPTER_VERSION
ARG PINGID_INTEGRATION_KIT_VERSION
RUN rm -rf /opt/server/server/default/deploy/pingid-web.war && \
    rm -rf /opt/server/server/default/deploy/pf-pingid-idp-adapter-*.jar && \
    rm -rf /opt/server/server/default/conf/template/offline.auth.login.template.html && \
    rm -rf /opt/server/server/default/deploy/pf-pingone-mfa-adapter-2.7.jar && \
    rm -rf /opt/server/server/default/conf/template/pingone-mfa*
COPY --from=zip /opt/server/server/default/ /opt/server/server/default/


