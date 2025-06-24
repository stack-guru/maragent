import "@nomicfoundation/hardhat-verify";
import "@nomicfoundation/hardhat-ethers";
import '@openzeppelin/hardhat-upgrades';
import "@nomicfoundation/hardhat-toolbox";
/** @type import('hardhat/config').HardhatUserConfig */
import * as dotenv from "dotenv";
dotenv.config();

module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200, // You can adjust to 50, 100, or higher based on needs
      },
      outputSelection: {
        "*": {
          "*": [
            "evm.bytecode",
            "evm.deployedBytecode",
            "devdoc",
            "userdoc",
            "metadata",
            "abi"
          ]
        }
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  defaultNetwork: "amoy",
  networks: {
    amoy: {
      url: "https://polygon-amoy-bor-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY!]
    },
    polygon: {
      url: "https://polygon-rpc.com",
      accounts: [process.env.PRIVATE_KEY!]
    }
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGON_APIKEY!,
      polygonAmoy: process.env.AMOY_APIKEY!
    }
  },
};
