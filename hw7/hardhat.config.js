require("dotenv").config();
const { API_URL, PRIVATE_KEY_1, PRIVATE_KEY_2 } = process.env;
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: API_URL,
      accounts: [
        `0x${PRIVATE_KEY_1}`,
        `0x${PRIVATE_KEY_2}`
      ]
    }
  }
};

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});