const { network } = require("hardhat");
const {
  developmentChains,
  DECIMALS,
  INTIAL_ANSWER,
} = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  if (developmentChains.includes(network.name)) {
    log("local network detected Deploying contracts");
    await deploy("MockV3Aggregator", {
      contract: "MockV3Aggregator",
      from: deployer,
      log: true,
      args: [DECIMALS, INTIAL_ANSWER],
    });
    log("Mocks Deployed");
    log("----------------------------------------------------------");
  }
};

module.exports.tags = ["all", "mocks"];
