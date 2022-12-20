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
    const RockPaperScissors = await ethers.getContractFactory("RockPaperScissors");
    const rockPaperScissors = await RockPaperScissors.deploy();

    await rockPaperScissors.deployed();

    console.log("RockPaperScissors deployed to :", rockPaperScissors.address);
    return rockPaperScissors.address
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
