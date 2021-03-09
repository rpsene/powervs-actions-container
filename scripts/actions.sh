#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

: '
    This script calls an API to create a new ppc64le OpenShift
    Cluster on IBM Cloud, using the PowerVS service.
'

function check_connectivity() {

    if ! curl --output /dev/null --silent --head --fail http://cloud.ibm.com -eq 0
    then
        echo
        echo "ERROR: Please, check your internet connection."
        echo "       It was not possible reach IBM Cloud."
        exit 1
    fi
}

function create(){

    local CLUSTER_OCP_VERSION=$1
    local CLUSTER_REQUESTOR_EMAIL=$2

    if curl -sS --fail -X POST "$PVS_JENKINS_JOB_URL" \
    --user "$PVS_JENKINS_USER":"$PVS_JENKINS_TOKEN" \
    --data API_KEY="$PVS_API_KEY" \
    --data REQUESTOR_EMAIL="$CLUSTER_REQUESTOR_EMAIL" \
    --data OPENSHIFT_VERSION="$CLUSTER_OCP_VERSION"
    then
        echo
        echo "SUCCESS: job was created and you will be notified at $CLUSTER_REQUESTOR_EMAIL."
        echo
    else
        echo
        echo "ERROR: there was a problem posting you request. Please, try again."
        echo
    fi
}

function destroy(){

    local OCP_CLUSTER_ID=$1

    if curl -sS --fail -X POST "$PVS_JENKINS_JOB_URL" \
    --user "$PVS_JENKINS_USER":"$PVS_JENKINS_TOKEN" \
    --data REQUESTOR_EMAIL="$CLUSTER_REQUESTOR_EMAIL" \
    --data API_KEY="$PVS_API_KEY" \
    --data CLUSTER_ID="$OCP_CLUSTER_ID"
    then
        echo
        echo "SUCCESS: job was created and you will be notified at $CLUSTER_REQUESTOR_EMAIL."
        echo
    else
        echo
        echo "ERROR: there was a problem posting you request. Please, try again."
        echo
    fi
}

function run (){

    check_connectivity

    local ACTIONS=("create" "destroy")

	if [ -z "$ACTION" ]; then
        printf "ERROR: %s\n" "select one of the supported actions: " "${ACTIONS[@]}"
		exit 1
    else
        for action in "${ACTIONS[@]}"; do
        [[ ! "$ACTION" = "$action" ]] && echo "This action ($ACTION) is not supported."
        exit 1
        done
    fi
    if [[ "$ACTION" == "create" ]]; then
        if [ -z "$CLUSTER_OCP_VERSION" ]; then
		    echo
		    echo "ERROR: please, set the RedHat OpenShift version."
            echo "       ./upi-conf-powervs-commands.sh ACTION OCP_VERSION REQUESTOR_EMAIL"
		    echo
		    exit 1
        else
            if [ -z "$CLUSTER_REQUESTOR_EMAIL" ]; then
		        echo
		        echo "ERROR: please, set the email of the cluster requestor."
                echo "       ./upi-conf-powervs-commands.sh ACTION OCP_VERSION REQUESTOR_EMAIL"
		        echo
		        exit 1
            else
                create "$CLUSTER_OCP_VERSION" "$CLUSTER_REQUESTOR_EMAIL"
            fi
        fi
	elif [[ "$ACTION" == "destroy" ]]; then
        if [ -z "$CLUSTER_ID" ]; then
		    echo
		    echo "ERROR: please, set the cluster you want to destroy."
		    echo "       ./upi-conf-powervs-commands.sh ACTION CLUSTER_ID CLUSTER_REQUESTOR_EMAIL"
		    echo
		    exit 1
        else
            destroy "$CLUSTER_ID" "$CLUSTER_REQUESTOR_EMAIL"
        fi
    fi
}

run "$@"