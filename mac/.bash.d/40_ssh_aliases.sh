# -*- bash -*-

ssh-add ~/.ssh/id_github
# Uses a jq regex to select node/nodes
function aal () {
    match="$1"
    # list instances for ssh
    jq --version >/dev/null 2>&1
    RV=$?
    if [ "$RV" != "0" ] ; then
        echo "The jq tool isn't present" 1>&2
        return 2
    fi
    raws "$match" ec2 describe-instances | jq "[.Reservations[].Instances | select(.[].Tags | length > 0) | select(.[].Tags[].Value | test(\"$match\") ) | select(.[].Tags[].Key == \"Name\") | {InstanceId: .[].InstanceId, PrivateIpAddress: .[].PrivateIpAddress, State: .[].State, LaunchTime: .[].LaunchTime, Tags: .[].Tags, AvailabilityZone: .[].Placement.AvailabilityZone, ImageId: .[].ImageId  }]"
}

function aaname () {
    match="$1"
    # Get the instance names from their "Name" tag
    jq --version >/dev/null 2>&1
    RV=$?
    if [ "$RV" != "0" ] ; then
        echo "The jq tool isn't present" 1>&2
        return 2
    fi
    aal "$match" | jq -S '.[].Tags[] | select(.Key == "Name") |.Value'
}


function aag () {
    target=$1

    host=$(aal "$target" | jq -r ".[] | select(.Tags[].Key == \"Name\") | select (.Tags[].Value == \"$target\" ) | select (.State.Name == \"Running\") | .PrivateIpAddress")
    nonstrictssh -i $AMAZON_SSH_KEY_FILE -l ubuntu $host
}

function ashuf () {
    match=$1
    shift
    gshuf --version 2>&1 > /dev/null
    RV=$?
    if [ "$RV" != "0" ] ; then
        echo "The gshuf from gnu coreutils isn't present or active $(which gshuf)" 1>&2
        return 2
    fi
    host=$(aal "$match" | jq -r ".[] | select(.State.Name == \"running\") | select(.Tags[].Key == \"Name\") | select (.Tags[].Value | test(\"$match\") ) | .PrivateIpAddress" | gshuf -n 1)
    nonstrictssh -i $AMAZON_SSH_KEY_FILE -l ubuntu $host "$@"
}

function nonstrictssh () {
    if [ "$AWSAM_ACTIVE_ACCOUNT" == "prod" ] ; then
        AMAZON_SSH_KEY_FILE=~/.ssh/portal-keypair.pem
    elif [ "$AWSAM_ACTIVE_ACCOUNT" == "staging" ] ; then
        AMAZON_SSH_KEY_FILE=~/.ssh/portal-dev-keypair
    else
        echo "\$AMAZON_SSH_KEY_FILE isn't set" 1>&2
        return 2
    fi
    echo "$@"

    ssh -i $AMAZON_SSH_KEY_FILE \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "$@"
}

function raws () {
    match="$1"
    shift 1
    aws --version 2> /dev/null
    RV=$?
    if [ $RV != 0 ] ; then
        echo "The aws tool isn't present or active $(which aws)" 1>&2
        return 2
    fi
    echo "$match" | grep -q dogfood
    RV=$?
    if [ $RV -eq 0 ] ; then
        aws --region us-west-2 "$@"
    else
        aws "$@"
    fi
}
