import { network } from "hardhat";

async function main() {
  const { viem } = await network.connect({
    network: "ritual",
    chainType: "generic",
  });

  const contract = await viem.deployContract("OmenPrivateBountyJudge");

  console.log("OmenPrivateBountyJudge deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});