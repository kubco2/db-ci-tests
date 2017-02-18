#!/bin/bash

# Caution: This is common script that is shared by more packages.
# If you need to do changes related to this particular collection,
# create a copy of this file instead of symlink.

THISDIR=$(dirname ${BASH_SOURCE[0]})
source ${THISDIR}/../../../common/functions.sh

set -xe

cqlsh <<'EOF'
CREATE KEYSPACE cycling
WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };

CREATE TABLE cycling.cyclist_name (
  id UUID,
  fname text,
  lname text,
  PRIMARY KEY (id)
);

INSERT INTO cycling.cyclist_name (id, fname, lname)
  VALUES (7562c0f3-2f6c-41da-b276-88abac471eaf, 'john', 'smith');
INSERT INTO cycling.cyclist_name (id,  fname, lname)
  VALUES (e69be414-f7eb-4e5a-b635-446ee5849810, 'john', 'doe');
INSERT INTO cycling.cyclist_name (id,  fname, lname)
  VALUES (d4aa012a-8d71-4189-bcc8-24a858b713b6, 'john', 'smith');

EXIT;
EOF

out=$(
cqlsh <<'EOF'
SELECT * FROM cycling.cyclist_name WHERE lname = 'smith' ALLOW FILTERING;
EOF
)

out=$(echo "$out"|tail -n 1)

[ "$out" == "(2 rows)" ]

