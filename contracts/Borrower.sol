//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";

contract Borrower {
    constructor() {
        console.log("Deploying Borrower");
        console.log("Owner:", msg.sender);
    }
}
