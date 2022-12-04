// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IXReceiver} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Execute{
    
    IConnext public immutable connext;

    using Address for address;

    uint nonce;

    constructor(IConnext _connext) {
        connext = _connext;
    }

    bytes32 public resultUUID;

    struct contractInfo{
      address sourceAddress;
      string sourceFunction;
    }

    mapping(bytes32 => contractInfo) uuidToContractInfo;

    event xCallCreated(
      bytes32 uuid,
      uint indexed DestinationDomain,
      address indexed Target,
      address indexed Executer,
      bytes callData
    );

    event CallbackCreated(
      bytes32 uuid,
      string sourceFunction,
      bytes data
    );

    /**
    @notice Function to compute on different chain and get result. 
    **/
    function executecompute( 
    bytes memory _byteCode,
    bytes calldata _encodedFunctionData,
    address callbackContractAddress,
    address _target, 
    uint32 _destinationDomain,
    uint256 _relayerFee
    ) public {

    bytes32 uuid = keccak256(abi.encodePacked(block.number, msg.data, nonce++));

    bytes memory callData = abi.encode(uuid,_byteCode,_encodedFunctionData, address(this));

    uuidToContractInfo[uuid];

    connext.xcall{value: _relayerFee}(
      _destinationDomain, // _destination: Domain ID of the destination chain
      _target,            // _to: address of the target contract
      address(0),    // _asset: address of the token contract
      msg.sender,        // _delegate: address that can revert or forceLocal on destination
      0,              // _amount: amount of tokens to transfer
      0,                // _slippage: the max slippage the user will accept in BPS (0.3%)
      callData           // _callData: the encoded calldata to send
    );

    emit xCallCreated(uuid,_destinationDomain,_target, msg.sender, callData);

  }
    /**
    @notice Function to receive callback data and call souce contract with received data 
    **/

  function xReceive(
    bytes32 _transferId,
    uint256 _amount,
    address _asset,
    address _originSender,
    uint32 _origin,
    bytes memory _callData
  ) external returns (bytes memory) {
    // Unpack the _callData
    (bytes32 resultuuid, bytes memory data )  = abi.decode(_callData, (bytes32, bytes));
    _resultUuidUpdate(resultuuid);
    bytes memory encodedFunctionData= abi.encodeWithSignature(uuidToContractInfo[resultuuid].sourceFunction,data);
    uuidToContractInfo[resultuuid].sourceAddress.call(encodedFunctionData);

    emit CallbackCreated(resultUUID, uuidToContractInfo[resultuuid].sourceFunction,data);
  }

  function _resultUuidUpdate(bytes32 _data) public {
    resultUUID = _data; 
  }
}