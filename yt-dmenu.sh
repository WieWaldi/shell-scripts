#!/usr/bin/env bash
#
# +----------------------------------------------------------------------------+
# | yt-dmenu.sh                                                                |
# +----------------------------------------------------------------------------+
# |       Usage: Copy URL to clipboard, then start this script                 |
# | Description: Scipt do download audio from Youtube                          |
# |    Requires: bash_framework.sh                                             |
# |       Notes: ---                                                           |
# |      Author: Waldemar Schroeer                                             |
# |     Company: Rechenzentrum Amper                                           |
# |     Version: 1.0                                                           |
# |     Created: 01.12.2023                                                    |
# |    Revision: ---                                                           |
# |                                                                            |
# | Copyright © 2022 Waldemar Schroeer                                         |
# |                  waldemar.schroeer(at)rz-amper.de                          |
# +----------------------------------------------------------------------------+

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
url="$(xclip -selection clipboard)"
destdir="${HOME}/Music/Youtube"

# +----- Main -----------------------------------------------------------------+

if [ -z "${url}" ]; then
    notify-send "yt-dmenu.sh" "No URL provided."
    exit 1
else
    if [[ ! "${url}" == "https://www.youtube.com"* ]]; then
        notify-send "yt-dmenu.sh" "This is not Youtube."
        exit 1
    fi
fi

ytid="$(yt-dlp -F ${url%&list=*} | awk '/audio only/ && /https/' | dmenu -l 10 -c | awk '{print $1}')"
if [ -z "${ytid}" ]; then
    notify-send "yt-dmenu.sh" "Download aborted."
    exit 1
fi
notify-send "yt-dmenu.sh" "Start downloading from:\n${ytid}"
yt-dlp -q -i -f ${ytid} -o "${destdir}/Source/%(title)s.%(ext)s" ${url%&list=*}
yt-dlp -q -i -f "bestaudio/best" -o "${destdir}/MP3/%(title)s.%(ext)s" --extract-audio --audio-quality 0 --audio-format mp3 ${url%&list=*}
ls -1v ${destdir}/Source | grep "m4a\|webm"> ${destdir}/Source/1_Playlist.m3u
ls -1v ${destdir}/MP3 | grep "mp3" > ${destdir}/MP3/1_Playlist.m3u
notify-send "yt-dmenu.sh" "Download complete."

exit 0
# +----- End ------------------------------------------------------------------+
