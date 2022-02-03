'use strict';

// Copyright © 2022 Kaleido, Inc.
//
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://swww.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const axios = require('axios');

const erc20ContractJson = require('/root/solidity/build/contracts/ERC20WithData.json');
const erc721ContractJson = require('/root/solidity/build/contracts/ERC721WithData.json');

const deployContracts = async () => {
  let FormData = require("form-data");
  const ETHCONNECT_BASE_URL = process.env.ETHCONNECT_URL;
  const ETHCONNECT_PREFIX = process.env.ETHCONNECT_PREFIX | "fly";
  const ABIS_URI = process.env.ABIS_URI | "/abis";

  const TOKENS_OWNER_KEY = process.env.TOKENS_OWNER_KEY;

  const ERC20_ENABLED = process.env.ERC20_ENABLED === "true";
  const ERC20_TOKEN_NAME = process.env.ERC20_TOKEN_NAME;

  const ERC721_ENABLED = process.env.ERC721_ENABLED === "true";
  const ERC721_TOKEN_NAME = process.env.ERC721_TOKEN_NAME;
  // TODO if FF has an address resolver does ORG_KEY need to be resolved?

  async function deployTokenContract(jsonLink, tokenName) {
      const abi = jsonLink.abi;
      const byteCode = jsonLink.bytecode;

      // POST /abis
      const bodyFormData = new FormData();
      bodyFormData.append("abi", JSON.stringify(abi));
      bodyFormData.append("bytecode", byteCode);
      console.log("POST /abis with abi/bytecode form data");
      const abiRes = await axios
          .post(`${ETHCONNECT_BASE_URL}${ABIS_URI}`, bodyFormData, {
              headers: bodyFormData.getHeaders(),
          })
          .catch((err) => {
              throw `Error in POST ${ABIS_URI} with form data. ${err}`;
          });

      console.log("Sleeping 10s for sync...");
        await new Promise((f) => setTimeout(f, 10000));

      // POST /abis/<id>
      console.log("POST /abis/<id>");
      const contractRes = await axios
          .post(
              `${ETHCONNECT_BASE_URL}${ABIS_URI}/${abiRes.data.id}`,
              JSON.stringify({
                  name: tokenName,
                  symbol: tokenName,
              }),
              {
                  headers: {
                      accept: "application/json",
                      "Content-Type": "application/json",
                      [`x-${ETHCONNECT_PREFIX}-from`]: TOKENS_OWNER_KEY,
                  },
              }
          )
          .catch((err) => {
              throw `Error in POST ${ABIS_URI}/{id}. ${err}`;
          });

    return {
        address: contractRes.data.contractAddress,
        abiId: abiRes.data.abiId
    };
  }


  console.log("\n\n");

  if (ERC20_ENABLED) {
    const erc20Contract = await deployTokenContract(erc20ContractJson, ERC20_TOKEN_NAME);
    console.log("ERC20");
    console.log(`\tAddress: ${erc20Contract.address}`);
    console.log(`\tABI ID: ${erc20Contract.abiId}\n`);
  }

  if (ERC721_ENABLED) {
    const erc721Contract = await deployTokenContract(erc721ContractJson, ERC721_TOKEN_NAME);
    console.log("ERC721");
    console.log(`\tAddress: ${erc721Contract.address}`);
    console.log(`\tABI ID: ${erc721Contract.abiId}\n`);
  }
};

(async () => {
  try {
    await deployContracts();
  } catch (e) {
     console.error(`Failed to deploy contracts due to: ${e}`);
  }
})();