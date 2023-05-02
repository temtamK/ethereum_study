import { expect } from "chai";
import { ethers } from "hardhat";

describe("flip coin test", function () {
  it("flip coin", async function () {
    const Flipcoin = await ethers.getContractFactory("CoinFlip");
    const flipcoin = await Flipcoin.deploy();
    await flipcoin.deployed();
    const res: boolean = true;

    expect(await flipcoin.flip(res)).to.equal(true);
  })
})  