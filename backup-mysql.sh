#!/usr/bin/env bash
#
# +----------------------------------------------------------------------------+
# | backup-mysql.sh                                                            |
# +----------------------------------------------------------------------------+
# |       Usage: ---                                                           |
# | Description: Script to backup a bunch of MySQL databases                   |
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


backupdir=/var/Backup/sql
today=`/usr/bin/date +"__%Y_%m_%d__%k-%M"`
sqlusername=root
sqlpassword=pw4mysql001

/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} mysql >> ${backupdir}/mysql_${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} addressdb1 >> ${backupdir}/addressdb1${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} cactidb2 >> ${backupdir}/cactidb2${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} cactidb3 >> ${backupdir}/cactidb3${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} filmdb1 >> ${backupdir}/filmdb1${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} information_schema >> ${backupdir}/information_schema${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} rcmaildb1 >> ${backupdir}/rcmaildb1${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} unsinndb1 >> ${backupdir}/unsinndb1${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} unsinndb2 >> ${backupdir}/unsinndb2${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} wikidbprod1 >> ${backupdir}/wikidbprod1${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} wordpressdb1 >> ${backupdir}/wordpressdb1${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} shoutboxdb1 >> ${backupdir}/shoutboxdb1${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} ownclouddb1 >> ${backupdir}/ownclouddb1${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} ownclouddb2 >> ${backupdir}/ownclouddb2${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} pastebindb1 >> ${backupdir}/pastebindb1${today}.sql
/usr/local/bin/mysqldump --databases -u ${sqlusername} -p${sqlpassword} p4ssdb >> ${backupdir}/p4ssdb${today}.sql



