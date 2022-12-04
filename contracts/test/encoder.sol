// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract Demo{

 function generateEncodedFunctionData() public pure returns(bytes memory){
    bytes memory encodedFunctionData = abi.encodeWithSignature("addNumber(uint32 _num1, uint32 _num2)",3,10);
    return encodedFunctionData;           
    }
    
}