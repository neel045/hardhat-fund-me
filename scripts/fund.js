const { getNamedAccounts, ethers } = require("hardhat");

async function main() {
  const { deployer } = await getNamedAccounts();
  const fundMe = await ethers.getContract("FundMe", deployer);

  console.log("Funding contract......");

  const transactionResponse = await fundMe.fund({
    value: ethers.utils.parseEther("0.1"),
  });
  transactionResponse.wait(1);

  console.log("funding sucessful");
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.log(e);
    process.exit(1);
  });
