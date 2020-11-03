const { expect } = require("chai");
import "@nomiclabs/hardhat-waffle";
import { ethers } from "hardhat";
import { LenderPool } from "../types/LenderPool";
import { Borrower } from "../types/Borrower";

describe("Flashloan", function () {
  it("Should be able to lend and repay in same transaction", async function () {
    const provider = new ethers.providers.JsonRpcProvider();
    const signer1 = provider.getSigner(0);
    const signer2 = provider.getSigner(1);

    const lenderPoolOwner = await signer1.getAddress();
    const borrowerOwner = await signer2.getAddress();

    const LenderPoolFactory = await ethers.getContractFactory("LenderPool");
    const lenderPool = (await LenderPoolFactory.deploy()) as LenderPool;

    lenderPool.connect(signer1);

    await lenderPool.deployed();
  });
});
