#***********************************************#
# ----------Author: Anthony Scinocco------------#
# -------------November 10, 2016----------------#
# -------Get the host machines private ip-------#
#***********************************************#

# get the os type
SYS_UNAME="$(uname)"

# IP validation regex
IP_REGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
# IP 192 string for validation
IP_192_STRING="192"
# IP 10 string for validation
IP_10_STRING="10"
# IP 172 string for validation
IP_172_STRING="172"
# loopback IP for validation
IP_127_STRING="127"

# stores the resulting interfaces
declare -a iFaceResultsArray
# stores the resulting ip addresses
declare -a iPResultsArray

function setResults {
    if ! [ -z "$2" ]; then
        if validate "$1" "$2" ; then
            iFaceResultsArray+=($1)
            iPResultsArray+=($2)
            return 0
        else
            return 1
        fi
    fi
}

function processResults {
    if [ ${#iFaceResultsArray[@]} -eq 0 ] || [ ${#iPResultsArray[@]} -eq 0 ]; then
        export PRIVATE_IP=127.0.0.1
        export PRIVATE_IFACE="lo"
    elif [ ${#iFaceResultsArray[@]} -gt 1 ] || [ ${#iPResultsArray[@]} -gt 1 ]; then
        export PRIVATE_IP=127.0.0.1
        export PRIVATE_IFACE="lo"
    else
        export PRIVATE_IP=$iPResultsArray
        export PRIVATE_IFACE=$iFaceResultsArray
    fi
}

function isDockerInterFace {
    if [[ $1 == *"docker"* ]]; then
        return 0
    else
        return 1
    fi
}

function isLoopBack {
    if [[ $1 == "$IP_127_STRING"* ]]; then
        return 0
    else
        return 1
    fi
}

function isPrivateIp {
    if [[ $1 == "$IP_172_STRING"* ]] || [[ $1 == "$IP_10_STRING"* ]] || [[ $1 == "$IP_192_STRING"* ]]; then
        return 0
    else
        return 1
    fi
}

function isValidIp {
    if [[ $1 =~ $IP_REGEX ]]; then
        return 0
    else
        return 1
    fi
}

function validate {
    local iface=$1
    local ip=$2
    if ! isDockerInterFace $iface ; then
        if isValidIp $ip ; then
            if isPrivateIp $ip ; then
                return 0
            elif isLoopBack $ip ; then
                return 1
            else
                return 1
            fi
        else
            return 1
        fi
    else
        return 1
    fi
}

function getOsxPrivate {
    declare -a iFaceArray
    # output all interfaces to ifaces.txt
    local OSX_IFACE=$(networksetup -listallhardwareports | grep "Device: " | awk '{gsub("Device: ", "");print}')
    iFaceArray=($OSX_IFACE)
    for (( i = 0 ; i < ${#iFaceArray[@]} ; i++ ))
    do
        local iface="${iFaceArray[$i]}"
        local ip="$(ipconfig getifaddr ${iFaceArray[$i]})"
        setResults "$iface" "$ip"
    done
}

function getUbuntuPrivate {
    declare -a iFaceArray
    local UBUNTU_IFACE=$(ifconfig | grep -o -P ".{0,10}Link" | sed 's/[^a-zA-Z0-9]//g' | awk '{sub("Link",""); print}' | awk '{sub("Scope",""); print}')
    iFaceArray=($UBUNTU_IFACE)

    for (( i = 0 ; i < ${#iFaceArray[@]} ; i++ ))
    do
        local iface="${iFaceArray[$i]}"
        local ip="$(ifconfig ${iFaceArray[$i]} 2>/dev/null | grep "inet addr" | awk -F 'Bcast' '{print $1}' | awk '{sub(/.*:/,""); print}')"
        setResults "$iface" "$ip"
    done
}

function getCentosPrivate {
    declare -a iFaceArray
    local CENTOS_IFACE=$(ip -o link show | awk '{print $2}' | awk '{sub(":",""); print}')
    iFaceArray=($CENTOS_IFACE)

    for (( i = 0; i < ${#iFaceArray[@]}; i++ ))
    do
        local iface="${iFaceArray[$i]}"
        local ip="$(ip addr show ${iFaceArray[$i]} | sed -n '/inet /{s/^.*inet \([0-9.]\+\).*$/\1/;p}')"
        setResults "$iface" "$ip"
    done
}

function getRhelPrivate {
    declare -a iFaceArray
    local RHEL_IFACE=$(ip -o link show | awk '{print $2}' | awk '{sub(":",""); print}')
    iFaceArray=($RHEL_IFACE)

    for (( i = 0; i < ${#iFaceArray[@]}; i++ ))
    do
        local iface="${iFaceArray[$i]}"
        local ip="$(ip addr show ${iFaceArray[$i]} | sed -n '/inet /{s/^.*inet \([0-9.]\+\).*$/\1/;p}')"
        setResults "$iface" "$ip"
    done
}

function run {
    if [ "$SYS_UNAME" == "Linux" ]; then
        # grab the release file names if we have one or more of them
        RELEASE_FILES="$(ls /etc/*release)"

        # check if we have release files
        if ! [[ -z "$RELEASE_FILES" ]]; then
            # ubuntu
            if [[ -e "/etc/lsb-release" ]]; then
                getUbuntuPrivate
            # centos
            elif [[ -e "/etc/centos-release" ]]; then
                getCentosPrivate
            # rhel
            elif [[ -e "/etc/redhat-release" ]]; then
                getRhelPrivate
            else
                echo "Unsupported Linux Distro"
                echo "Terminating..."
                exit 1
            fi
        else
            # if we can't find the release files return error and exit script
            exit 1
        fi

    elif [ "$SYS_UNAME" == "Darwin" ]; then
        getOsxPrivate
    fi
    # export the variables
    processResults
}

# Entry point, runs the script
run