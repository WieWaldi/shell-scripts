#!/usr/bin/env bash
#
# +----------------------------------------------------------------------------+
# | backup-www.sh                                                              |
# +----------------------------------------------------------------------------+
# |       Usage: ---                                                           |
# | Description: Script to backup a bunch of www directories and configs       |
# |    Requires: ---                                                           |
# |       Notes: ---                                                           |
# |      Author: Waldemar Schroeer                                             |
# |     Company: Rechenzentrum Amper                                           |
# |     Version: 1.0                                                           |
# |     Created: 2012                                                          |
# |    Revision: 2                                                             |
# |                                                                            |
# | Copyright © 2022 Waldemar Schroeer                                         |
# |                  waldemar.schroeer(at)rz-amper.de                          |
# +----------------------------------------------------------------------------+


backupdir=/var/Backup/www
today=`/usr/bin/date +"__%Y_%m_%d__%k-%M"`
grep='/usr/local/bin/grep'
gzip='/usr/local/bin/gzip'
tar='/usr/local/bin/tar'

if [ ! -d "$backupdir" ]; then
  mkdir -p $backupdir
fi

for i in `ls -1 /var | /usr/local/bin/grep -E "www_"`;do
  echo Creating tarball for /var/${i}
  ${tar} -cf ${backupdir}/${i}_${today}.tar /var/${i}
  echo Compressing ${backupdir}/${i}_${today}.tar
  ${gzip} ${backupdir}/${i}_${today}.tar
done
