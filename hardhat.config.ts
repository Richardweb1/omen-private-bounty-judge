import { defineConfig } from "hardhat/config";
import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import "dotenv/config";

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin],
  solidity: {
    version: "0.8.28",
  },
  networks: {
    ritual: {
      type: "http",
      chainType: "generic",
      url: process.env.RITUAL_RPC_URL || "https://rpc.ritualfoundation.org",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
});