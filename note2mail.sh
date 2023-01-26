#!/usr/bin/env bash
#
# +----------------------------------------------------------------------------+
# | note2mail.sh                                                               |
# +----------------------------------------------------------------------------+
# |       Usage: ---                                                           |
# | Description: Script to convert markdown files to html and send them as mail|
# |    Requires: bash_framework.sh                                             |
# |       Notes: ---                                                           |
# |      Author: Waldemar Schroeer                                             |
# |     Company: Rechenzentrum Amper                                           |
# |     Version: 0.1                                                           |
# |     Created: 19.01.2023                                                    |
# |    Revision: ---                                                           |
# |                                                                            |
# | Copyright © 2023 Waldemar Schroeer                                         |
# |                  waldemar.schroeer(at)rz-amper.de                          |
# +----------------------------------------------------------------------------+






# +----- Help and Usage (Must start at line 25 and must stop with "######" ----+
#
# note2mail.sh [file]
#
# Simple bash script to convert markdown files into html files and
# use it as input for a html formated email.                          
#
# Options...
#  -f, --file           Text file containing markdown formated notes
#  -h, --help           Print out help
#  -r, --recipient      Text file cotaining email addresses line by line
#  -s, --subject        Subject used for Email
#  -t, --template       HTML File containing the template
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
cat="/usr/bin/cat"
pandoc="/usr/bin/pandoc"
base64="/usr/bin/base64"
uuidgen="/usr/bin/uuidgen"
sendmail="/usr/sbin/sendmail"
file_out_tmp="/tmp/note2mail.html"

# +----- Functions ------------------------------------------------------------+

# +----- Option Handling ------------------------------------------------------+
while [[ $# -gt 0 ]]; do
    case "$1" in
        -\?|-h|-help|--help) __exit_Help ;;                    # Standard help option
        -t|--template)
            if ! [[ -f "${2}" ]]; then
                __exit_Usage 10 "Template File does not exist."
            fi
            pandoctemplate="${2}"
            shift
            ;;
        -f|--file)
            if ! [[ -f "${2}" ]]; then
                __exit_Usage 10 "Notes File does not exist."
            fi
            if ! [[ "${2: -3}" = ".md" ]]; then
                __exit_Usage 10 "Not a .md file. I'm not even trying."
                exit 1
            fi
            file_in="${2}"
            shift
            ;;
        -r|--recipient)
            if ! [[ -f "${2}" ]]; then
                __exit_Usage 10 "Recipient File does not exist."
            fi
            recipients="${2}"
            shift
            ;;
        -s|--subject)
            subject="${2}"
            if [[ -z "${subject}" ]]; then
                __exit_Usage 10 "Subject missing."
            fi
            shift
            ;;
        --) shift; break ;;                                 # Force end of user option
        -*) __exit_Usage 10 "Unknown option \"${1}\"" ;;    # Unknown command line option
        *)  break ;;                                        # Unforced end of user options
    esac
    shift                                                   # Shift to next option
done

# +----- Main -----------------------------------------------------------------+
if ! command -v "${pandoc}" &> /dev/null; then
    __echo_Error_Msg "Pandoc not found"
    exit 1
fi

if ! command -v "${sendmail}" &> /dev/null; then
    __echo_Error_Msg "Sendmail not found"
    exit 1
fi

if ! command -v "${base64}" &> /dev/null; then
    __echo_Error_Msg "base64 not found"
    exit 1
fi

if ! command -v "${uuidgen}" &> /dev/null; then
    __echo_Error_Msg "uuidgen not found"
    exit 1
fi

# command -v vim >/dev/null 2>&1 || { echo "I require foo but it's not installed.  Aborting." >&2; exit 1; }
# command -v vima >/dev/null 2>&1 || { __exit_Usage 10 "Vim not found."; }
[[ -z "${file_in}" ]] && __exit_Usage 10 "File not specified."
[[ -z "${pandoctemplate}" ]] && __exit_Usage 10 "Template not specified."
[[ -z "${recipients}" ]] && __exit_Usage 10 "Recipients not specified."
[[ -z "${subject}" ]] && __exit_Usage 10 "Subject not specified."

if ! [[ -f "${recipients}" ]]; then
    __echo_Error_Msg "Recipient File does not exist!"
    exit 1
fi

if ! [[ "${file_in: -3}" = ".md" ]]; then
    __echo_Error_Msg "Not a .md file. I'm not even trying."
    __echo_Title "Done"
    exit 1
fi

# Read recipients from file line by line into array 'rcptlst'
rcptlst=()
while IFS= read -r line; do
    rcptlst+=("${line}")
done < ${recipients}

# Convert markdown into html
${pandoc} --standalone --template ${pandoctemplate} ${file_in} -o ${file_out_tmp}
message="$(${cat} ${file_out_tmp})"
attachment_cont="$(${base64} ${file_out_tmp})"
attachment_size="$(du -b ${file_out_tmp} | cut -f 1)"
mailboundary_body="$(uuidgen)"
mailboundary_text="$(uuidgen)"

echo "==="
echo "attachment_cont:  ${attachment_cont}"
echo "attachment_size:  ${attachment_size}"
echo "file in:  ${file_in}"
echo "file out: ${file_out}"
echo "dirname:  ${file_in%/*}"
echo "basename: ${file_in##*/}"
echo "recipient:  ${#rcptlst[@]}"
echo "recipient:  ${rcptlst[0]}"
echo "recipient:  ${rcptlst[1]}"
echo "recipient:  ${rcptlst[@]}"
echo "scriptdir:  ${scriptdir}"
echo "scriptname:  ${scriptname}"
echo "pandoctemplate:  ${pandoctemplate}"
echo "subject:  ${subject}"
echo "==="



# Loop through recipients list and send email
for i in "${rcptlst[@]}"; do
    echo "recipient: ${i}"
    (
        echo "From: \"Waldemar Schroeer\" <waldemar.schroeer@de.ttiinc.com>"
        echo "To: ${i}"
        echo "Subject: ${subject} -- Simple"
        echo "Thread-Topic: ${subject}"
        echo "Thread-Index: EDCISInfrastructureTopic/+Zg=="
        echo "MIME-Version: 1.0";
        echo "Content-Type: text/html;"
        echo ""
        echo "${message}";
    ) | ${sendmail} -t
done


for i in "${rcptlst[@]}"; do
    (
        echo "From: \"Waldemar Schroeer\" <waldemar.schroeer@de.ttiinc.com>"
        echo "To: ${i}"
        echo "Subject: ${subject}"
        echo "Thread-Topic: ${subject}"
        echo "Thread-Index: EDCISInfrastructureTopic/+Zg=="
        echo "MIME-Version: 1.0";
        echo "Content-Type: multipart/mixed; boundary=\"${mailboundary_body}\""
        echo ""
        echo "--${mailboundary_body}"
        echo "Content-Type: multipart/alternative; boundary=\"${mailboundary_text}\""
        echo ""
        echo "--${mailboundary_text}"
        # echo "Content-Type: text/plain; charset=\"iso-8859-1\""
        echo "Content-Type: text/plain;"
        echo ""
        echo "This message is in MIME format.  But if you can see this, "
        echo "you aren't using a MIME aware mail program.  You shouldn't "
        echo "have too many problems because this message is entirely in "
        echo "ASCII and is designed to be somewhat readable with old "
        echo "mail software."
        echo "--${mailboundary_text}"
        # echo "Content-Type: text/html; charset=\"iso-8859-1\""
        echo "Content-Type: text/html;"
        echo "Content-Disposition: inline"
        echo ""
        echo "${message}"
        echo ""
        echo "--${mailboundary_text}--"
        echo ""
        echo "--${mailboundary_body}"
        echo "Content-Type: text/html; name=\"EDC_IS_Network_Infrastructure_Topics.html\""
        echo "Content-Description: EDC_IS_Network_Infrastructure_Topics.html"
        echo "Content-Disposition: attachment;"
        echo "    filename="EDC_IS_Network_Infrastructure_Topics.html"; size=${attachment_size};"
        echo "    creation-date=\"Mon, 7 Apr 1975 20:15:00 GMT\";"
        echo "    modification-date=\"Mon, 7 Apr 1975 20:15:00 GMT\";"
        echo "Content-Transfer-Encoding: base64"
        echo ""
        echo "${attachment_cont}"
        echo ""
        echo "--${mailboundary_body}--"
    ) | ${sendmail} -t

done

# Get rid of tmp files
rm ${file_out_tmp}

# +----- End ------------------------------------------------------------------+
exit 0 
