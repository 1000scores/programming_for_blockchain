
require("dotenv").config();
const yargs = require('yargs');

const argv = yargs
    .option('account', {
        alias: 'a',
        description: 'From which account you want to paricipate',
        type: 'number'
    }).argv;

const {
    ethers
} = require("hardhat");

const hre = require("hardhat");

const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;
const API_URL = process.env.API_URL;


const contract = require("../artifacts/contracts/RockPaperScissors.sol/RockPaperScissors.json");

console.log(JSON.stringify(contract.abi));


async function main(args) {
    signers = await ethers.getSigners();
    const provider = new ethers.providers.AlchemyProvider(network = "goerli", API_KEY);
    console.log(
        `
            signer_0 --> ${signers[0].address}
            signer_1 -- > ${signers[1].address}
        `
    );

    console.log(`Choosing ${signers[argv.account].address} address for participation`)
}


/*

const signer = new ethers.Wallet(PRIVATE_KEY, provider);
const dummyContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);

async function main() {
  const message = await dummyContract.getValue();
  console.log("Previous value: ", message);

  console.log("Updating the message...");
  const tx = await dummyContract.setValue(12345);
  await tx.wait();
  const newMessage = await dummyContract.getValue();
  console.log("The new message is: ", newMessage);
}


*/

main();