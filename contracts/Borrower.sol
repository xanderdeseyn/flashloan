//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";
import "./LenderPool.sol";

contract Borrower {
    LenderPool private pool;

    constructor(address payable poolAddress) {
        console.log("Deploying Borrower");
        console.log("Owner:", msg.sender);
        console.log("LenderPool:", poolAddress);
        pool = LenderPool(poolAddress);
    }

    receive() external payable { }

    function executeFlashloan() public {
        pool.flashloan(10 ** 18);
    }

    function onFundsReceived() external payable {
        pool.repay{ value: 10**18 + 10**16 / 2 }();
    }
}
