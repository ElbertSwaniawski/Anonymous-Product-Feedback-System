import { task, types } from "hardhat/config";
import type { HardhatRuntimeEnvironment } from "hardhat/types";

task("accounts", "Prints the list of accounts", async (args, hre: HardhatRuntimeEnvironment) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});
