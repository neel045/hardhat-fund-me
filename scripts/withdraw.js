const { getNamedAccounts, ethers } = require("hardhat");

async function main() {
  const { deployer } = await getNamedAccounts();
  const fundMe = await ethers.getContract("FundMe", deployer);

  console.log("Withdrawing ETH from contract......");

  const transactionResponse = await fundMe.withdraw();
  transactionResponse.wait(1);
  const balance = await ethers.provider.getBalance(deployer);
  console.log(balance.toString());
  console.log("Withdraw sucessful");
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.log(e);
    process.exit(1);
  });
