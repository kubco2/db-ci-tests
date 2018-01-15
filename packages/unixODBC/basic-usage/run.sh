#!/bin/bash

THISDIR=$(dirname ${BASH_SOURCE[0]})
source ${THISDIR}/../../../common/functions.sh
source ${THISDIR}/../include.sh

tempout=$(mktemp /tmp/tempoutXXXXXX)

result=0
function failtest() {
  echo "$@"
  result=1
}


# PostgreSQL connector test
postgresql-setup --initdb
service postgresql start

cp odbc-pgsql.ini /etc/odbc.ini
restorecon -v /etc/odbc.ini

# Run a trivial query using isql in batch mode
echo -e "SELECT 2+3;" | su postgres -c "/usr/bin/isql PostgreSQL postgres -v -b" &> "${tempout}"
grep "5" "${tempout}" || failtest "'5' not found in isql output ${tempout}: `cat ${tempout}`"
grep "1 row" "${tempout}" || failtest "'1 row' not found in isql output ${tempout}: `cat ${tempout}`"

# Run a trivial query using isql
su postgres -c "/usr/bin/isql PostgreSQL postgres -v" &> "${tempout}" <<EOF
select 123 * 456;
quit
EOF

grep "Connected" "${tempout}" || failtest "'Connected' not found in isql output ${tempout}: `cat ${tempout}`"
grep "56088" "${tempout}" || failtest "'56088' not found in isql output ${tempout}: `cat ${tempout}`"
grep "1 row" "${tempout}" || failtest "'1 row' not found in isql output ${tempout}: `cat ${tempout}`"
grep "ERROR" "${tempout}" && failtest "'ERROR' found in isql output ${tempout}: `cat ${tempout}`"


# MariaDB connector test
service mariadb start

cp odbc-mariadb.ini /etc/odbc.ini
restorecon /etc/odbc.ini

# Run a trivial query using isql
/usr/bin/isql MariaDB root -v &> "${tempout}" <<EOF
select 123 * 456;
quit
EOF
grep "56088" "${tempout}" || failtest "'56088' not found in isql output ${tempout}: `cat ${tempout}`"
grep "1 row" "${tempout}" || failtest "'1 row' not found in isql output ${tempout}: `cat ${tempout}`"
grep "ERROR" "${tempout}" && failtest "'ERROR' found in isql output ${tempout}: `cat ${tempout}`"

