#!/bin/sh

THISDIR=$(dirname ${BASH_SOURCE[0]})

usage() {
  echo "Usage `basename $0` <package> [ <package> ... ] <task_id> [ <task_id> ... ]"
  exit 1
}

[ $# -lt 1 ] && usage

dnf install -y koji createrepo

packages=""
while [ -d "${THISDIR}/packages/$1" ] ; do
  packages="$packages $1"
  shift
done


repodir=$(mktemp -d /var/tmp/db-ci-test-XXXXXX)
pushd "${repodir}"
while [ -n "$1" ] ; do
  koji download-task --arch noarch --arch x86_64 $1
  shift
done
createrepo .
popd

cat >/etc/yum.repos.d/db-ci.repo <<EOF
[db-ci]
name=db-ci
baseurl=file://${repodir}
enabled=1
gpgcheck=0
EOF

[ "$packages" == "" ] && usage

export SKIP_REPO_CREATE=1
"${THISDIR}/run.sh" $packages

