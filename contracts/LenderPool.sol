//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";

contract LenderPool {

    mapping (address => uint) _rewards;
    mapping (address => uint) _balances;
    address _owner;

    constructor() {
        console.log("Deploying LenderPool");
        console.log("Owner:", msg.sender);
    }

    receive() external payable {
        _balances[msg.sender] += msg.value;
    }

    function withdraw() public returns (uint amount) {
        require(amount <= _balances[msg.sender] + _rewards[msg.sender]);
        _balances[msg.sender] -= amount;
        (bool success,) = msg.sender.call{ value: amount }("");
        require(success);
    }

     function balanceOf(address addr) public view returns (uint balance) {
        return _balances[addr];
    }
}
