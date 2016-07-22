#!/bin/bash
set -x
echo PASS >/tmp/1minutetip.result

git clone https://github.com/hhorak/db-ci-tests.git
cd "db-ci-tests/packages/${TEST_REPO_SUBDIR}"
./run.sh


