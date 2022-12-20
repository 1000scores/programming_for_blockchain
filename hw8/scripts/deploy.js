// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");


async function main() {
    await run("compile");
    const [deployer] = await ethers.getSigners();

    console.log(`Address deploying the contract --> ${deployer.address}`)
    const DummyContract = await ethers.getContractFactory("DummyContract");
    const dummy_contract = await DummyContract.deploy();

    await dummy_contract.deployed();

    console.log("DummyContract Deployed to :", dummy_contract.address);
    return dummy_contract.address
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });