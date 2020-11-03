const { expect } = require("chai");
import { ethers } from "hardhat";
import "@nomiclabs/hardhat-waffle";
import { LenderPool } from "../types/LenderPool";
import { Borrower } from "../types/Borrower";
import { ethers as E } from "ethers";
import { parseEther } from "ethers/lib/utils";

const oneETH = parseEther("1");
const twoETH = parseEther("2");
const threeETH = parseEther("3");

describe("Flashloan", function () {
  let provider: E.providers.JsonRpcProvider;
  let signer1: E.providers.JsonRpcSigner;
  let signer2: E.providers.JsonRpcSigner;
  let signer3: E.providers.JsonRpcSigner;
  let signer4: E.providers.JsonRpcSigner;
  let signer1Address: string;
  let signer2Address: string;
  let signer3Address: string;
  let signer4Address: string;
  let lenderPool: LenderPool;
  let borrower: Borrower;

  beforeEach(async function () {
    provider = new ethers.providers.JsonRpcProvider();
    signer1 = provider.getSigner(0);
    signer2 = provider.getSigner(1);
    signer3 = provider.getSigner(2);
    signer4 = provider.getSigner(3);

    signer1Address = await signer1.getAddress();
    signer2Address = await signer2.getAddress();
    signer3Address = await signer3.getAddress();
    signer4Address = await signer4.getAddress();

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
      value: oneETH,
    });
    await signer2.sendTransaction({
      to: lenderPool.address,
      value: twoETH,
    });
    await signer3.sendTransaction({
      to: lenderPool.address,
      value: threeETH,
    });

    expect(await lenderPool.depositOf(signer1Address)).to.equal(oneETH);
    await lenderPool.withdraw();
    expect(await lenderPool.depositOf(signer1Address)).to.equal(0);

    expect(await lenderPool.depositOf(signer2Address)).to.equal(twoETH);
    const lenderPool2 = lenderPool.connect(signer2);
    await lenderPool2.withdraw();
    expect(await lenderPool.depositOf(signer2Address)).to.equal(0);

    expect(await lenderPool.depositOf(signer3Address)).to.equal(threeETH);
    const lenderPool3 = lenderPool.connect(signer3);
    await lenderPool3.withdraw();
    expect(await lenderPool.depositOf(signer3Address)).to.equal(0);
  });

  // it("Should be able to lend and withdraw liquidity", async function () {
  //   await signer1.sendTransaction({
  //     to: lenderPool.address,
  //     value: oneETH,
  //   });

  //   await signer1.sendTransaction({
  //     to: lenderPool.address,
  //     value: oneETH,
  //   });

  //   lenderPool.connect(signer3);
  // });
});
