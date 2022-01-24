#!/bin/bash

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

apk add curl jq

# TODO genercize for ERC contracts

# PublishABI
# POST /abis

cat /var/lib/ethconnect/contracts/firefly.json | jq -r '.abi' > /tmp/firefly-abi.json
cat /var/lib/ethconnect/contracts/firefly.json | jq -r '.bytecode' > /tmp/firefly-bytecode

publishReponse=$(curl -H "Accept: application/json" -X POST -F abi=@/tmp/firefly-abi.json -F bytecode=@/tmp/firefly-bytecode "${ETHCONNECT_URL}/abis")
# TODO get ABI ID from response
echo "$publishReponse"

# RegisterContract
# POST /abis/{id}/{address}

# TODO whats the registered name?
curl -H "Content-Type: application/json" -X POST -H "x-${ETHCONNECT_PREFIX}-sync: true"  -H "x-${ETHCONNECT_PREFIX}-register: firefly" "${ETHCONNECT_URL}/abis/${abiId}/${FIREFLY_CONTRACT_ADDRESS}"
