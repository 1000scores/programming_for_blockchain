const { expect } = require("chai");

describe("Dummy contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner] = await ethers.getSigners();

    const DummyContract = await ethers.getContractFactory("DummyContract");

    const hardhatToken = await DummyContract.deploy();

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
