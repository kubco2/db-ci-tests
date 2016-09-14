#!/bin/sh

if [ $# -lt 1 ] ; then
  echo "Usage `basename $0` <package> [ <package> ... ]"
  exit 1
fi

while [ -n "$1" ] ; do
  pushd "packages/$1"
  ./run.sh
  popd
  shift
done

