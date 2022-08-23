#!/usr/bin/env bash
#
# +----------------------------------------------------------------------------+
# | example.sh                                                                 |
# +----------------------------------------------------------------------------+
# |       Usage: ---                                                           |
# | Description: Example script to show off how bash_framework.sh works        |
# |    Requires: bash_framework.sh                                             |
# |       Notes: ---                                                           |
# |      Author: Waldemar Schroeer                                             |
# |     Company: Rechenzentrum Amper                                           |
# |     Version: 3                                                             |
# |     Created: 10.08.2022                                                    |
# |    Revision: ---                                                           |
# |                                                                            |
# | Copyright © 2022 Waldemar Schroeer                                         |
# |                  waldemar.schroeer(at)rz-amper.de                          |
# +----------------------------------------------------------------------------+

# +----- Include bash-framework.sh --------------------------------------------+
export LANG="en_US.UTF-8"
export base_dir="$(dirname "$(readlink -f "$0")")"
export cdir=$(pwd)
export datetime="$(date "+%Y-%m-%d-%H-%M-%S")"
export logfile="${cdir}/${datetime}.log"
export framework_width=80
export BASH_FRMWRK_NEEDED="0.3"
export BASH_FRMWRK_FILE="${HOME}/.local/bin/bash-framework.sh"
if [[ ! -f ${BASH_FRAMEWORK_FILE} ]]; then
    export BASH_FRMWRK_FILE="${cdir}/bash_framework.sh"
    echo "framework ist nicht im home!"
fi
source ${BASH_FRAMEWORK_FILE}
echo "so: ${BASH_FRAMEWORK_VERSION}"

if [[ -n ${BASH_FRAMEWORK_VERSION} ]]; then
    if (( $( ${BASH_FRAMEWORK_NEEDED} -lt ${BASH_FRAMEWORK_VERSION} | bc -l ) )); then
        echo "Bash Framework Version ${BASH_FRAMEWORK_NEEDED} needed."
        exit 1
    fi
else
    echo "Bash Framework not found."
    exit 1
fi


# +----- Variables ------------------------------------------------------------+

# +----- Functions ------------------------------------------------------------+

# +----- Main -----------------------------------------------------------------+

display_Notice ${cdir}/${notice}
if [[ "${proceed}" = "no" ]]; then
    exit 1
fi

echo_Title "Example Start"

GoAhead="$(read_Antwoord "Shall we conitnue? ${YN}")"
echo -n -e "We shall continue:\r"
if [[ "${GoAhead}" = "yes" ]]; then
    # Do some work
    echo_Done
else
    echo_Skipped
fi
echo_Left "So geht's weiter"
echo_Done
echo_Left "Das lassen wir mal bleiben..."
echo_Skipped
echo_Left "Das ist voll shief"
echo_Failed


declare -A affe
read -p "Key 1:" key1
read -p "Value:" value

echo "Key 1: $key1"
echo "Value: $value"

affe[$key1]=$value

read -p "Key 2:" key2
read -p "Value:" value

echo "Key 2: $key2"
echo "Value: $value"
affe[$key2]=$value

echo "Key 1: ${affe["key1"]}"
echo "Key 2: ${affe["key2"]}"



echo_Title "Example End"
# +----- End ------------------------------------------------------------------+
echo -e "\n\n"
exit 0
