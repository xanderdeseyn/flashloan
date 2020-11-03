//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";

contract LenderPool {

    mapping (address => uint) _rewards;
    mapping (address => uint) _balances;
    address _owner;

    event LiquidityAdded(uint amount, address addr);
    event LiquidityRemoved(uint amount, address addr);

    constructor() {
        console.log("Deploying LenderPool");
        console.log("Owner:", msg.sender);
    }

    receive() external payable {
        _balances[msg.sender] += msg.value;
        emit LiquidityAdded(msg.value, msg.sender);
    }



    function withdraw() public returns (uint amount) {
        require(amount <= _balances[msg.sender] + _rewards[msg.sender]);
        _balances[msg.sender] -= amount;
        (bool success,) = msg.sender.call{ value: amount }("");
        require(success);

        emit LiquidityRemoved(amount, msg.sender);
    }

     function balanceOf(address addr) public view returns (uint balance) {
        return _balances[addr];
    }
}
