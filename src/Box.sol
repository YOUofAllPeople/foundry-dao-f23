// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable {
    uint256 private value;

    event NumberChanged(uint256 newNumber);

    function store(uint256 newNumber) public onlyOwner {
        value = newNumber;
        emit NumberChanged(newNumber);
    }

    function getNumber() public view returns (uint256) {
        return value;
    }
}
