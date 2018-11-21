#!/bin/bash

HOST_SCRIPT=$1
DB=$2
KEY=$3

echo "HOST SCRIPT : $HOST_SCRIPT" >&2
echo "DB          : $DB"          >&2

SP=${DB%_core_*}

SQL="
  SELECT
    \"$SP\", \"$KEY\",
    meta_value
  FROM
    $DB.meta
  WHERE
    meta_key = \"$KEY\"
"

#echo "$SQL"

$HOST_SCRIPT $DB -Ne "$SQL"

