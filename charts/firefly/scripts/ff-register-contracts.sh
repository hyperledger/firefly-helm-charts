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

set -e

until STATUS=$(curl --fail -s ${ETHCONNECT_URL}/contracts); do
  echo "Waiting for Ethconnect..."
  sleep 5
done

# This script does the following for each pre-deployed contract:
## PublishABI
## POST /abis
## then
## RegisterContract
## POST /abis/{id}/{address}

# NOTE: ERC20 is special since theres a pre-deployed Factory contract and then the ERC20 contract itself which must be published but not deployed

# FF contract

if ! curl --fail -s "${ETHCONNECT_URL}/contracts/${FIREFLY_CONTRACT_ADDRESS}"; then
  echo "[${FIREFLY_CONTRACT_ADDRESS}] has not been registered for the FireFly contract, registering now..."
  publishResponse=$(curl -s --fail -F "abi=$(cat /var/lib/ethconnect/contracts/firefly.json | jq -r '.abi')" -F bytecode=$(cat /var/lib/ethconnect/contracts/firefly.json | jq -r '.bytecode') "${ETHCONNECT_URL}/abis")
  curl -s --fail -H "Content-Type: application/json" -X POST -H "x-${ETHCONNECT_PREFIX}-sync: true"  -H "x-${ETHCONNECT_PREFIX}-register: firefly" "${ETHCONNECT_URL}$(echo -n $publishResponse | jq -r .path)/${FIREFLY_CONTRACT_ADDRESS}"
else
  echo "[${FIREFLY_CONTRACT_ADDRESS}] is already registered for the FireFly contract."
fi


# ERC1155 contract
if [[ "${FIREFLY_ERC1155_ENABLED}" == "true" ]]; then

  if ! curl --fail -s "${ETHCONNECT_URL}/contracts/${FIREFLY_ERC1155_CONTRACT_ADDRESS}"; then
    # publish and register ERC1155
    echo "[${FIREFLY_ERC1155_CONTRACT_ADDRESS}] has not been registered for the FireFly ERC1155 contract, registering now..."
    publishResponse=$(curl -s --fail -F "abi=$(cat /var/lib/ethconnect/contracts/erc1155.json | jq -r '.abi')" -F bytecode=$(cat /var/lib/ethconnect/contracts/erc1155.json | jq -r '.bytecode') "${ETHCONNECT_URL}/abis")
    curl -s --fail -H "Content-Type: application/json" -X POST -H "x-${ETHCONNECT_PREFIX}-sync: true"  -H "x-${ETHCONNECT_PREFIX}-register: firefly-erc1155" "${ETHCONNECT_URL}$(echo -n $publishResponse | jq -r .path)/${FIREFLY_ERC1155_CONTRACT_ADDRESS}"
  else
    echo "[${FIREFLY_ERC1155_CONTRACT_ADDRESS}] is already registered for the FireFly ERC1155 contract."
  fi
fi
