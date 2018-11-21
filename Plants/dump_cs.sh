#!/bin/bash

HOST_SCRIPT=$1
DB=$2

echo "HOST SCRIPT : $HOST_SCRIPT" >&2
echo "DB          : $DB"          >&2

SQL="
  SELECT
    \"$DB\", name
  FROM
    $DB.coord_system
"

#echo "$SQL"

$HOST_SCRIPT $DB -Ne "$SQL"

