// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IXReceiver} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";

contract Compute{

    IConnext public immutable connext;

    using Address for address;
   
    constructor(IConnext _connext) {
        connext = _connext;
    }


  function xReceive(
    bytes32 _transferId,
    uint256 _amount,
    address _asset,
    address _originSender,
    uint32 _origin,
    bytes memory _callData
  ) external {

    // Unpack the _callData

  (string memory uuid, bytes memory byteCode, bytes memory encodedFunctionData, address executeContractAddress )  = abi.decode(_callData, (string, bytes, bytes, address));

  address deployedAddress = Create2.deploy(0, keccak256(abi.encodePacked(address(0))), byteCode);
 
  (bool _success,bytes memory data) =  deployedAddress.call(encodedFunctionData);  

  bytes memory resultCallData = abi.encode(uuid, data);

  connext.xcall{value: 0}(
      1735353714, // _destination: Domain ID of the destination chain
      executeContractAddress,            // _to: address of the target contract
      address(0),    // _asset: address of the token contract
      address(this),               // _delegate: address that can revert or forceLocal on destination
      0,              // _amount: amount of tokens to transfer
      0,                // _slippage: the max slippage the user will accept in BPS (0.3%)
      resultCallData           // _callData: the encoded calldata to send
    );
  }

}