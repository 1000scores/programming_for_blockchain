require("dotenv").config();
const { MNEMONIC, PROJECT_ID } = process.env;

const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: "7545",
      network_id: "*"
    },
    loc_helloworld_helloworld: {
      network_id: "*",
      port: 7545,
      host: "127.0.0.1"
    },
    goerli: {
      provider: () =>
          new HDWalletProvider(
              MNEMONIC,
              `https://goerli.infura.io/v3/${PROJECT_ID}`,
          ),
      network_id: 5, // Goerli's id
      confirmations: 2, // # of confirmations to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },
  },
  compilers: {
    solc: {
      version: "^0.8.0"
    }
  }
};
