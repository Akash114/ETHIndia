// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract Test {

  function addNumber(uint32 _num1, uint32 _num2) public pure returns(bytes memory) {
    return abi.encodePacked(_num1+_num2);
  }
}