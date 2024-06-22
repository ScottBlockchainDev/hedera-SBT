const { ethers } = require("hardhat");
const deployArgs = require("../constants/soulBoundTokenArgs.json");
require("dotenv").config();

module.exports = async (address, msg) => {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://testnet.hashio.io/api"
  );
  let backendWallet = new ethers.Wallet(
    process.env.TESTNET_OPERATOR_PRIVATE_KEY
  );
  backendWallet = backendWallet.connect(provider);
  const manageContract = await ethers.getContractAt(
    "ManageContract",
    deployArgs.manager,
    backendWallet
  );
  const updateTx = await manageContract
    .connect(backendWallet)
    .registerSBTContract("0x06b1Ba2ECE3E9c3acdf13008283998e204283320");
  console.log(updateTx);

  // return updateTx;
};
