// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract CallbackTest {

  uint public number;

  function getNumber(bytes memory _number) public returns(bool) {
      number = uint256(bytes32(_number));
    return true;
  }
}