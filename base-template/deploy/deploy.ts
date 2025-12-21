import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const deployedContract = await deploy("ExampleContract", {
    from: deployer,
    log: true,
  });

  console.log("ExampleContract deployed to:", deployedContract.address);
};

export default func;
func.id = "deploy_example_contract";
func.tags = ["ExampleContract"];
