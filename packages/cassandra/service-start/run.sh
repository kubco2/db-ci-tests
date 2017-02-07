#!/bin/bash

THISDIR=$(dirname ${BASH_SOURCE[0]})
source ${THISDIR}/../../../common/functions.sh
source ${THISDIR}/../include.sh

# clean all datadirs to have a fresh new cassandra
rm -rf /var/lib/cassandra/data/*

service "$SERVICE_NAME" start
exit $?
