//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

interface IBorrower {
    function onFundsReceived() external payable;
}
