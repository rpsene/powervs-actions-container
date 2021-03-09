FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

LABEL maintaner="Rafael Peria de Sene - rpsene@br.ibm.com "

ARG ACTION
ARG PVS_JENKINS_JOB_URL
ARG PVS_JENKINS_USER
ARG PVS_JENKINS_TOKEN
ARG PVS_API_KEY
ARG CLUSTER_REQUESTOR_EMAIL
ARG CLUSTER_OCP_VERSION
ARG CLUSTER_ID

COPY ./scripts/actions.sh /

RUN microdnf update && \
microdnf install -y git vi wget tar unzip yum-utils iputils jq && \
chmod +x ./actions.sh

ENTRYPOINT ["/bin/bash", "-c", "./actions.sh"]