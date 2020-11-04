//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

interface LenderPool {
    function repay() external payable;

    function deposit() external payable;

    function withdraw() external;

    function depositOf(address addr) external view returns (uint256 deposit);

    function rewardsOf(address addr) external view returns (uint256 rewards);

    function flashloan(uint256 amount) external;
}
