import { ethers } from "hardhat";

async function main() {
  const StudyNFT = await ethers.getContractFactory("StudyNFT");
  const contract = await StudyNFT.deploy();

  await contract.deployed();

  console.log(
    "StudyNFT deployed to:",
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
