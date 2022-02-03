'use strict';

const axios = require('axios');

import * as erc20ContractJson from "/root/solidity/build/contracts/ERC20WithData.json";
import * as erc721ContractJson from "/root/solidity/build/contracts/ERC20WithData.json";

const deployContracts = async () => {
  let FormData = require("form-data");
  const ETHCONNECT_BASE_URL = process.env.ETHCONNECT_URL;
  const ORG_KEY = process.env.ORG_KEY;
  const ERC20_TOKEN_NAME = process.env.ERC20_TOKEN_NAME;
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
          .post(`${ETHCONNECT_BASE_URL}/abis`, bodyFormData, {
              headers: bodyFormData.getHeaders(),
          })
          .catch((err) => {
              throw `Error in POST /abis with form data. ${err}`;
          });

      console.log("Sleeping 10s for sync...");
        await new Promise((f) => setTimeout(f, 10000));

      // POST /abis/<id>
      console.log("POST /abis/<id>");
      const contractRes = await axios
          .post(
              `${ETHCONNECT_BASE_URL}/abis/${abiRes.data.id}`,
              JSON.stringify({
                  name: tokenName,
                  symbol: tokenName,
              }),
              {
                  headers: {
                      accept: "application/json",
                      "Content-Type": "application/json",
                      "x-firefly-from": ORG_KEY,
                  },
              }
          )
          .catch((err) => {
              throw `Error in POST /abis/{id}. ${err}`;
          });

    return {
        address: contractRes.data.contractAddress,
        abiId: abiRes.data.abiId
    };
  }

  const erc20Contract = await deployTokenContract(erc20ContractJson, ERC20_TOKEN_NAME);
  const erc721Contract = await deployTokenContract(erc721ContractJson, ERC721_TOKEN_NAME);

  console.log("\n\n");

  console.log("ERC20");
  console.log(`\tAddress: ${erc20Contract.address}`);
  console.log(`\tABI ID: ${erc20Contract.abiId}\n`);

  console.log("ERC721");
  console.log(`\tAddress: ${erc721Contract.address}`);
  console.log(`\tABI ID: ${erc721Contract.abiId}\n`);
};

(async () => {
  try {
    await deployContracts();
  } catch (e) {
     console.error(`Failed to deploy contracts due to: ${e}`);
  }
})();
