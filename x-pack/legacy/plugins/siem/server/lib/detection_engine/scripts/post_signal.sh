#!/bin/sh

#
# Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
# or more contributor license agreements. Licensed under the Elastic License;
# you may not use this file except in compliance with the Elastic License.
#

set -e
./check_env_variables.sh

# Uses a default if no argument is specified
SIGNALS=(${@:-./signals/root_or_admin_1.json})

# Example: ./post_signal.sh
# Example: ./post_signal.sh ./signals/root_or_admin_1.json
# Example glob: ./post_signal.sh ./signals/*
for SIGNAL in "${SIGNALS[@]}"
do {
  [ -e "$SIGNAL" ] || continue
  POST=$(jq '.output_index=env.SIGNALS_INDEX' $SIGNAL)
  curl -s -k \
  -H 'Content-Type: application/json' \
  -H 'kbn-xsrf: 123' \
  -u ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD} \
  -X POST ${KIBANA_URL}/api/detection_engine/rules \
  -d "$POST" \
  | jq .;
} &
done

wait
