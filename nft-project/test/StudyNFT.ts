import { ethers } from "hardhat"
import { Signer } from "ethers"
import { expect } from "chai"

describe("StudyNFT", function () {
  let owner: Signer;
  
  before(async function () {
    [owner] = await ethers.getSigners();
  });

  it("Should have 10 nfts", async function () {
    const StudyNFT = await ethers.getContractFactory("StudyNFT");
    const contract = await StudyNFT.deploy();

    await contract.deployed();

    expect(await contract.balanceOf(await owner.getAddress())).to.be.equal(10);
  });
});
   
    