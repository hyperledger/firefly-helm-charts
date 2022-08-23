#!/bin/bash

failed=0
for yamlTemplate in $(find ./charts -regex '^\.\/charts\/.*\/templates\/[^\/]*.*\/*.*\.yaml'); do
  kind=$(cat $yamlTemplate | grep -e '^kind:' | awk '{ printf("%s\n", $2) }' |  tr '[:upper:]' '[:lower:]')
  if ! basename "$yamlTemplate" | grep -E "^${kind}[s]?\-?[a-z\-]*\.yaml$" > /dev/null; then
    echo "ERROR: $yamlTemplate filename does not start with $kind"
    failed=$(($failed+1))
  fi

  if ! cat $yamlTemplate | grep "$(cat ./charts/license.tpl)"  > /dev/null; then
    echo "ERROR: $yamlTemplate filename does not start with the license"
    failed=$(($failed+1))
  fi
done

if [[ $failed -gt 0 ]]; then
  exit 1
fi
