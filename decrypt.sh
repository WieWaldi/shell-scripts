#!/usr/bin/env bash
#
# +----------------------------------------------------------------------------+
# | decrypt.sh                                                                 |
# +----------------------------------------------------------------------------+
# |       Usage: ---                                                           |
# | Description: Script to decrypt files using gnupg                           |
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
# decrypt.sh [file]
#
# Simple bash script to decrypt files with GnuPG    
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
export file_extension="crypt"
export gnupg="/usr/bin/gpg"
export algo="AES256"

# +----- Functions ------------------------------------------------------------+

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

__echo_Title "Decrypting file"
file_in="${1}"

if ! [[ "${file_in: -6}" = ".crypt" ]]; then
    __echo_Error_Msg "Not a .crypt file. I'm not even trying."
    __echo_Title "Done"
    exit 1
fi

file_out="${file_in%.crypt}"
if [[ -f "${file_out}" ]]; then
    __echo_Error_Msg "Output file exists."
    __echo_Title "Done"
    exit 1
fi

passphrase="$(__read_Antwoord_Secretly "Passphrase: ")"
echo -e -n "\n"

__echo_Left "Decrypting \"${file_in}\""
${gnupg} --no-tty --batch --passphrase ${passphrase} --decrypt --cipher-algo ${algo} --output "${file_out}" "${file_in}" >/dev/null 2>&1
if [[ $? = "0" ]]; then
    __echo_Done
else
    __echo_Failed
    __echo_Title "Done"
    exit 1
fi

__echo_Title "Done"
# +----- End ------------------------------------------------------------------+
exit 0
