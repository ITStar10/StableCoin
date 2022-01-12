import chai from "chai"
import chaiAsPromised from "chai-as-promised"
import { solidity } from 'ethereum-waffle'
import { expect } from "chai"
import { artifacts, ethers } from "hardhat";

import { Address } from "cluster"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { BigNumber } from "@ethersproject/bignumber"
import hre from "hardhat";
import { StableCoin } from "../typechain";

chai.use(solidity)
chai.use(chaiAsPromised)

describe("StableCoin", function () {
  let contract : StableCoin;
  let accountList : SignerWithAddress[];
  let owner : SignerWithAddress;

  this.beforeAll(async function() {
    await hre.network.provider.send("hardhat_reset")

    console.log('Deploying StableCoin...');
    accountList = await ethers.getSigners();

    const contractFactory = await ethers.getContractFactory('StableCoin');
    contract = await contractFactory.deploy();

    // await contract.deployed();
    console.log("Contract deployed to:", contract.address);
  })

  it ("Freeze Test", async function() {
    expect(await contract.balanceOf(accountList[1].address)).to.be.eq(0);
    await contract.transfer(accountList[1].address, BigNumber.from('100'));
    expect(await contract.balanceOf(accountList[1].address)).to.be.eq(100);

    // Freeze account[2]
    await contract.freeze(accountList[2].address);
    await expect(contract.transfer(accountList[2].address, 100)).to.be.revertedWith("address frozen");

    // Freeze Owner
    await contract.freeze(accountList[0].address);
    await expect(contract.transfer(accountList[3].address, 100)).to.be.revertedWith("address frozen");

    // Unfreeze Owner & account[2]
    await contract.unfreeze(accountList[0].address);
    await contract.unfreeze(accountList[2].address);
    expect(await contract.balanceOf(accountList[2].address)).to.be.eq(0);
    await contract.transfer(accountList[2].address, 200);
    expect(await contract.balanceOf(accountList[2].address)).to.be.eq(200);

  })

});
