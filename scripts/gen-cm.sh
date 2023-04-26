#!/bin/bash

tmpFile="../_tmp/shell-cm.yml"
cat shell-cm-head.tpl > "$tmpFile"
cat ../entrypoint.sh | sed 's/^/    /' >> "$tmpFile"
cp -f "$tmpFile" "../charts/kafka/templates/broker/configmap.yaml"