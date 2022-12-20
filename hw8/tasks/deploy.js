// tasks/deploy.ts

import { task } from "hardhat/config";

task("deploy", "Deploys DummyContract").setAction(
  async (_args, { ethers, run }) => {
    await run("compile");
    const [deployer] = await ethers.getSigners();
    const nonce = await deployer.getTransactionCount();

    const DummyContract = await ethers.getContractFactory("DummyContract");
    const dummy_contract = await DummyContract.deploy({ nonce: nonce });

    await dummy_contract.deployed();

    console.log("DummyContract Deployed to :", dummy_contract.address);
    return dummy_contract.address
  }
);
