#!/bin/bash

THISDIR=$(dirname ${BASH_SOURCE[0]})
source ${THISDIR}/../../../common/functions.sh
source ${THISDIR}/../include.sh

mongo_version=`mongo --version|grep -oe '[0-9\.]*$'`
case "$mongo_version" in
  2.4.*) echo "smallfiles = true" >>/etc/mongodb.conf ;;
  3.0.*) echo "smallfiles = true" >>/etc/mongod.conf ;;
  *) sed -i -e 's/#mmapv1:/mmapv1:/' -e 's/#smallFiles:.*/smallFiles: true/' /etc/mongod.conf ;;
esac

service "$SERVICE_NAME" start
exit $?
