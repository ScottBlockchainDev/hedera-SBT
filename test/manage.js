const { expect } = require("chai");
const { ethers } = require("hardhat");

const deployArgs = require("../constants/soulBoundTokenArgs.json");

describe("ManageContract", function () {
  let ManageContract, manageContract, owner, addr1, addr2;
  let SoulBoundToken;

  beforeEach(async function () {
    ManageContract = await ethers.getContractFactory("ManageContract");
    SoulBoundToken = await ethers.getContractFactory("SoulBoundToken");
    [owner, addr1, addr2, _] = await ethers.getSigners();
    manageContract = await ManageContract.deploy(deployArgs.backend);
    soulBoundToken = await SoulBoundToken.deploy(
      manageContract.address,
      "EarlyAdopterToken",
      "EAT"
    );
    await manageContract.deployed();
  });

  it("Should register a new SBT contract", async function () {
    await manageContract.registerSBTContract(soulBoundToken.address);
    expect(await manageContract.getSBTContract(0)).to.equal(
      soulBoundToken.address
    );
  });

  it("Should mint a new SBT", async function () {
    // Assuming the mint function requires a valid signature, which is a complex topic
    // and beyond the scope of this basic test. We'll simulate a successful mint.
    const provider = ethers.provider;
    let _43Wallet = new ethers.Wallet(
      "0x2e7dcddaa71bf5e7c56faa18777cb3f2ce7b5e1a9018b6083cdc9c57dceb1465"
    );
    let backendWallet = new ethers.Wallet(
      "0x56a76bd58deabbb90a2c46c7217dc9c6705aed6f5e99352898cb22c2419d9202"
    );
    _43Wallet = _43Wallet.connect(provider);
    backendWallet = backendWallet.connect(provider);

    const tx = await addr1.sendTransaction({
      to: backendWallet.address,
      value: ethers.utils.parseEther("10"),
    });

    await manageContract.registerSBTContract(soulBoundToken.address);
    await manageContract.registerSBTContract(
      "0x3c4fdb28c4b4dae057691fadc997bfc8d2a1ba78"
    );
    const abi = ethers.utils.defaultAbiCoder;
    const encodedMessage = abi.encode(
      ["address", "uint256", "uint256"],
      ["0xcc32b942fed0FeDd4358852f7Ef4aA8a7f7B5861", 0, 0]
    );
    const messageHash = ethers.utils.keccak256(encodedMessage);
    const signature = await backendWallet.signMessage(
      ethers.utils.arrayify(messageHash)
    );

    const sig = ethers.utils.splitSignature(signature);

    await manageContract.connect(backendWallet).mint(0, sig.r, sig.s, sig.v);
    await expect(
      manageContract.mint(0, sig.r, sig.s, sig.v)
    ).to.be.revertedWith("INVALID_SIGNER");
  });
});
