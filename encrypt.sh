#!/usr/bin/env bash
#
# +----------------------------------------------------------------------------+
# | encrypt.sh                                                                 |
# +----------------------------------------------------------------------------+
# |       Usage: ---                                                           |
# | Description: Script to encrypt files using gnupg                           |
# |    Requires: bash_framework.sh                                             |
# |       Notes: ---                                                           |
# |      Author: Waldemar Schroeer                                             |
# |     Company: Rechenzentrum Amper                                           |
# |     Version: 0.1                                                           |
# |     Created: 14.10.2022                                                    |
# |    Revision: ---                                                           |
# |                                                                            |
# | Copyright © 2022 Waldemar Schroeer                                         |
# |                  waldemar.schroeer(at)rz-amper.de                          |
# +----------------------------------------------------------------------------+






# +----- Help and Usage (Must start at line 25 and must stop with "######" ----+
#
# encrypt.sh [file]
#
# Simple bash script to encrypt files and directories with GnuPG    
#
# Options...
#  -h, --help           Print out help
#
#####

# +----- Include bash-framework.sh --------------------------------------------+
# set -o errexit
# set -o pipefail
export BASH_FRMWRK_MINVER=3
export LANG="en_US.UTF-8"
export base_dir="$(dirname "$(readlink -f "$0")")"
export cdir=$(pwd)
export scriptname="${BASH_SOURCE##*/}"
export scriptdir="${BASH_SOURCE%/*}"
export datetime="$(date "+%Y-%m-%d-%H-%M-%S")"
export logfile="${scriptdir}/${datetime}.log"
export framework_width=80

if [[ -f "${scriptdir}"/bash-framework.sh ]]; then
    BASH_FRMWRK_FILE="${scriptdir}/bash-framework.sh"
else
    test_file=$(which bash-framework.sh 2>/dev/null)
    if [[ $? = 0 ]]; then
        BASH_FRMWRK_FILE="${test_file}"
        unset test_file
    else
        echo -e "\nNo Bash Framework found.\n"
        exit 1
    fi
fi

source "${BASH_FRMWRK_FILE}"
if [[ "${BASH_FRMWRK_VER}" -lt "${BASH_FRMWRK_MINVER}" ]]; then
    echo -e "\nI've found version ${BASH_FRMWRK_VER} of bash_framework.sh, but I'm in need of version ${BASH_FRMWRK_MINVER}."
    echo -e "You may get the newest version from https://github.com/WieWaldi/bash-framework.sh\n"
    exit 1
fi

# +----- Variables ------------------------------------------------------------+

# +----- Functions ------------------------------------------------------------+
output_Variable() {
    __echo_Title "VAR"
    __echo_Left "cdir:"
    __echo_Right "${cdir}"
    __echo_Left "base_dir:"
    __echo_Right "${base_dir}"
    __echo_Left "scriptname:"
    __echo_Right "${scriptname}"
    __echo_Left "scriptdir:"
    __echo_Right "${scriptdir}"
    __echo_Left "BASH_SOURCE:"
    __echo_Right "${BASH_SOURCE}"
    __echo_Left "demo:"
    __echo_Right "${demo}"
    __echo_Left "framework_width:"
    __echo_Right "${framework_width}"
    __echo_Left "option:"
    __echo_Right "${option}"
}

encrypt_File() {
    echo "Enc File"
}

encrypt_Directory() {
    echo "Enc Dir"
}
# +----- Option Handling ------------------------------------------------------+
while [[ $# -gt 0 ]]; do
    case "$1" in
        -\?|-h|-help|--help) __exit_Help ;;                    # Standard help option
        -doc|--doc)          __exit_Help ;;
        -d|--demo)
            demo="True"
            ;;
        -w|--width)
            if [[ ${2} != *[^0-9]* ]]; then
                __exit_Usage 10 "Width must be an integer"
            fi
            framework_width="${2}"
            shift
            ;;
        -o|--option)
            if [[ ${2} = *[^0-9]* ]]; then
                __exit_Usage 10 "Option must be an integer"
            fi
            option="${2}"
            shift
            ;;
        --) shift; break ;;                                 # Force end of user option
        -*) __exit_Usage 10 "Unknown option \"${1}\"" ;;    # Unknown command line option
        *)  break ;;                                        # Unforced end of user options
    esac
    shift                                                   # Shift to next option
done

# +----- Main -----------------------------------------------------------------+

if [[ "$#" = "0" ]]; then
    __exit_Usage 10 "No file name specified."
fi

if [[ -e "${1}" ]]; then
    if [[ -f "${1}" ]]; then
        echo "File"
        file_in="${1}"
        file_out="${file_in}.${file_extension}"
        purge_file_in="$(__read_Antwoord_YN "Purge source file?")"
        password_1="$(__read_Antwoord_Secretly "Passphrase         ")"
        echo -e -n "\n"
        password_2="$(__read_Antwoord_Secretly "Confirm Passphrase ")"
        echo -e -n "\n"
        if [[ "${password_1}" = "${password_2}" ]]; then
            passphrase="${password_1}"
        else
            echo_Error_Msg "You messed up!"
            echo_Title "Done"
            exit 1
        fi

    fi
    if [[ -d "${1}" ]]; then
        echo "Directory"
        directory_in="${1}"
        directory_out="${directory_in}.${file_extension}"
    fi
else
    __exit_Usage 10 "File not found."
fi





output_Variable

echo "Und ${1}"

# +----- End ------------------------------------------------------------------+
echo -e "\n\n"
exit 0

