//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";

/// @title The LenderPool contract which allows borrowers to make flashloans
/// @author Xander Deseyn
contract LenderPool {
    uint constant LOAN_FEE_BASIS_POINTS = 5;
    uint constant DEPOSIT_GRANULARITY = 10 ** 9;

    mapping (address => uint) _rewardsGeneratedAtTimeOfDeposit;
    mapping (address => uint) _deposits;
    address _owner;
    uint totalDeposited;
    uint totalRewardsGenerated;

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
        require(_deposits[msg.sender] == 0);
        _deposits[msg.sender] = msg.value;
        totalDeposited += msg.value;
        _rewardsGeneratedAtTimeOfDeposit[msg.sender] = totalRewardsGenerated;
        emit LiquidityAdded(msg.value, msg.sender);
    }

    /// @notice A user can only withdraw all his provided liquidity + all liquidity rewards he gained. This is for performance reasons http://batog.info/papers/scalable-reward-distribution.pdf
    function withdraw() external {
        uint deposit = _deposits[msg.sender];
        require(deposit > 0);
        _deposits[msg.sender] = 0;
        
        uint reward = (totalRewardsGenerated - _rewardsGeneratedAtTimeOfDeposit[msg.sender]) * deposit;

        (bool success,) = msg.sender.call{ value: deposit + reward }("");
        require(success);

        emit LiquidityRemoved(deposit + reward, msg.sender);
    }

    /// @param addr The address whose deposit to check
    /// @return deposit The deposit for addr
    function depositOf(address addr) public view returns (uint deposit) {
        return _deposits[addr];
    }

    /// @dev The borrower has to repay at least amountLended * (1 + LOAN_FEE_BASIS_POINTS / 10000) before his function returns control to this contract
    /// @param amount The amount to lend in wei
    function flashloan(uint amount) external {
        uint initialLiquidity = address(this).balance;
        require(amount <= initialLiquidity);

        (bool success,) = msg.sender.call{ value: amount }("");
        require(success);

        uint newLiquidity = address(this).balance;
        require(newLiquidity >= (initialLiquidity + initialLiquidity * LOAN_FEE_BASIS_POINTS / 10000));
        distributeRewards(newLiquidity - initialLiquidity);
    }

    function distributeRewards(uint amount) internal {
        require(amount > 0);
        totalRewardsGenerated = totalRewardsGenerated + amount / totalDeposited;
    }
}
