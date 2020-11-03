//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";

/// @title The LenderPool contract which allows borrowers to make flashloans
/// @author Xander Deseyn
contract LenderPool {

    uint constant LOAN_FEE_BASIS_POINTS = 5;

    mapping (address => uint) _rewards;
    mapping (address => uint) _balances;
    address _owner;

    event LiquidityAdded(uint amount, address addr);
    event LiquidityRemoved(uint amount, address addr);

    constructor() {
        console.log("Deploying LenderPool");
        console.log("Owner:", msg.sender);
        _owner = msg.sender;
    }

    /// @dev This could also be moved to a function, but I decided this is the easiest way for users to provide liquidity. In addition, this prevents ETH sent to the contract from being lost.
    /// @notice Sending ETH to this contract automatically makes you a liquidity provider
    receive() external payable {
        _balances[msg.sender] += msg.value;
        emit LiquidityAdded(msg.value, msg.sender);
    }

    /// @notice A user can withdraw his provided liquidity + any liquidity rewards he gained
    /// @param amount The amount of wei to withdraw
    function withdraw(uint amount) external {
        require(amount <= _balances[msg.sender] + _rewards[msg.sender]);
        _balances[msg.sender] -= amount;
        (bool success,) = msg.sender.call{ value: amount }("");
        require(success);

        emit LiquidityRemoved(amount, msg.sender);
    }

    /// @param addr The address whose balance to check
    /// @return balance The balance for addr
    function balanceOf(address addr) public view returns (uint balance) {
        return _balances[addr];
    }

    /// @dev The borrower has to repay at least amountLended * (1 + LOAN_FEE_BASIS_POINTS / 10000) before his function returns control to this contract
    /// @param amount The amount to lend in wei
    function flashloan(uint amount) external {
        uint initialLiquidity = address(this).balance;
        require(amount <= address(this).balance);

        (bool success,) = msg.sender.call{ value: amount }("");
        require(success);

        uint newLiquidity = address(this).balance;
        require(newLiquidity >= (initialLiquidity + initialLiquidity * LOAN_FEE_BASIS_POINTS / 10000));
    }
}
