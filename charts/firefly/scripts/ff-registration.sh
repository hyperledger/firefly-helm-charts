#!/bin/sh

# Copyright © 2022 Kaleido, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://swww.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

for n in $FF_NAMESPACES; do
  until STATUS=$(curl ${FF_URL}/api/v1/namespaces/${n}/status -s); do
    echo "Waiting for FireFly..."
    sleep 5
  done

  if [ `echo $STATUS | jq -r .org.registered` != "true" ]; then

    echo "Registering organization"
    HTTP_CODE=`curl --silent --output /dev/stderr --write-out "%{http_code}" \
      -X POST -d '{}' -H 'Content-Type: application/json' \
      "${FF_URL}/api/v1/namespaces/${n}/network/organizations/self?confirm"`
    if [ "$HTTP_CODE" -ne 200 ]; then
      echo "Failed to register with code ${HTTP_CODE}"
      exit 1
    fi

  else

    echo "Org already registered."

  fi

  if [ `echo $STATUS | jq -r .node.registered` != "true" ]; then

    echo "Registering node"
    HTTP_CODE=`curl --silent --output /dev/stderr --write-out "%{http_code}" \
      -X POST -d '{}' -H 'Content-Type: application/json' \
      "${FF_URL}/api/v1/namespaces/${n}/network/nodes/self?confirm"`
    if [ "$HTTP_CODE" -ne 200 ]; then
      echo "Failed to register with code ${HTTP_CODE}"
      exit 1
    fi

  else

    echo "Node already registered."

  fi
done
