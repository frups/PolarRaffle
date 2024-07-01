/* eslint-disable no-undef */
// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PolarRaffle", function () {
  it("test initial value", async function () {
    const PolarRaffle = await ethers.getContractFactory("PolarRaffle");
    const polarRaffle = await StoPolarRaffleage.deploy();
    await polarRaffle.deployed();
    console.log("polarRaffle deployed at:" + polarRaffle.address);
    expect((await polarRaffle.retrieve()).toNumber()).to.equal(0);
  });
  it("test updating and retrieving updated value", async function () {
    const PolarRaffle = await ethers.getContractFactory("PolarRaffle");
    const polarRaffle = await PolarRaffle.deploy();
    await polarRaffle.deployed();
    const polarRaffle2 = await ethers.getContractAt("PolarRaffle", storage.address);
    const setValue = await polarRaffle2.store(56);
    await setValue.wait();
    expect((await polarRaffle2.retrieve()).toNumber()).to.equal(56);
  });
});
