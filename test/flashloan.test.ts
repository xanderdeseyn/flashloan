const { expect } = require("chai");
import { ethers } from "hardhat";
import "@nomiclabs/hardhat-waffle";
import { LenderPool } from "../types/LenderPool";
import { Borrower } from "../types/Borrower";
import { ethers as E } from "ethers";

describe("Flashloan", function () {
  let provider: E.providers.JsonRpcProvider;
  let signer1: E.providers.JsonRpcSigner;
  let signer2: E.providers.JsonRpcSigner;
  let signer1Address: string;
  let signer2Address: string;
  let lenderPool: LenderPool;
  let borrower: Borrower;

  beforeEach(async function () {
    provider = new ethers.providers.JsonRpcProvider();
    signer1 = provider.getSigner(0);
    signer2 = provider.getSigner(1);

    signer1Address = await signer1.getAddress();
    signer2Address = await signer2.getAddress();

    const LenderPoolFactory = await ethers.getContractFactory(
      "LenderPool",
      signer1
    );
    lenderPool = (await LenderPoolFactory.deploy()) as LenderPool;

    const BorrowerFactory = await ethers.getContractFactory(
      "Borrower",
      signer2
    );
    borrower = (await BorrowerFactory.deploy()) as Borrower;

    await lenderPool.deployed();
    await borrower.deployed();
  });

  it("Should be able to lend and withdraw liquidity", async function () {
    await signer1.sendTransaction({
      to: lenderPool.address,
      value: 100,
    });
    expect(await lenderPool.balanceOf(signer1Address)).to.equal(100);
    await lenderPool.withdraw(50);
    expect(await lenderPool.balanceOf(signer1Address)).to.equal(50);
    await lenderPool.withdraw(50);
    expect(await lenderPool.balanceOf(signer1Address)).to.equal(0);
  });
});
