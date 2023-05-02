import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const ALCHEMY_API_KEY = "kJbdBtK4VYZ7Az9MIeFzHRpjL9An6rb0";
const PRIVATE_KEY = "741c24df1c4be24574ee458fbdc4672d33bdc8d7a9c3a0805932d8bc6929e3b9";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
  },
};

export default config;
