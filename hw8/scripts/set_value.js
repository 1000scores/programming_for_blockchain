require("dotenv").config()

const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

const {
    ethers
  } = require("hardhat");

const contract = require("../artifacts/contracts/DummyContract.sol/DummyContract.json");

console.log(JSON.stringify(contract.abi));

const provider = new ethers.providers.AlchemyProvider(network = "goerli", API_KEY);
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
main();