// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Dispatcher
 * 
 * Inspired by multicall and timelock contract.
 *
 * - https://github.com/makerdao/multicall/blob/master/src/Multicall.sol
 * - https://github.com/compound-finance/compound-protocol/blob/v2.8.1/contracts/Timelock.sol
 */
contract Dispatcher is Ownable {
    // TODO: gas limit per Call.

    struct Call {
        address account; // caller
        address target; // callee
        uint256 value; // wei
        string signature; // function selector
        bytes data; // args
    }

    struct Sig {
        uint8 v; bytes32 r; bytes32 s;
    }

    struct Result {
        bool success;
        bytes returnData;
        uint256 returnWei;
    }

    function tryDispatch(
        Call[] memory calls, // be a bmsg
        Sig[] memory sigs
    ) public payable returns (
        uint256 blockNumber,
        Result[] memory returnData
    ) {
        blockNumber = block.number;
        returnData = new Result[](calls.length);
        
        // bmsg
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19Ethereum Signed Message:\n32',
                keccak256(abi.encode(calls))
            )
        );

        // TODO: random order using ChainLink VRF.
        for(uint256 i = 0; i < calls.length; i++) {
            Call memory callEach = calls[i];
            Sig memory sigEach = sigs[i];

            address recoveredAddress = ecrecover(digest, sigEach.v, sigEach.r, sigEach.s);
            require(
                recoveredAddress != address(0) && recoveredAddress == callEach.account,
                "INVALID_SIGNATURE"
            );

            bytes memory callData;
            if (bytes(callEach.signature).length == 0) {
                callData = callEach.data;
            } else {
                callData = abi.encodePacked(
                    bytes4(keccak256(bytes(callEach.signature))), callEach.data
                );
            }

            (bool success, bytes memory ret) = callEach.target.call{value: callEach.value}(callData);            
            returnData[i] = Result(success, ret, address(this).balance);

            if (address(this).balance != 0) {
                callEach.account.call{value: address(this).balance}("");
            }
        }   
    }

    function trySingleCall(
        Call memory singleCall, // bmsg
        Sig memory singleSig
    ) public payable returns (
        uint256 blockNumber,
        Result memory returnData
    ) {
        blockNumber = block.number;
        
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19Ethereum Signed Message:\n32',
                keccak256(abi.encode(singleCall))
            )
        );

        address recoveredAddress = ecrecover(digest, singleSig.v, singleSig.r, singleSig.s);
        require(
            recoveredAddress != address(0) && recoveredAddress == singleCall.account,
            "INVALID_SIGNATURE"
        );

        bytes memory callData;
        if (bytes(singleCall.signature).length == 0) {
            callData = singleCall.data;
        } else {
            callData = abi.encodePacked(
                bytes4(keccak256(bytes(singleCall.signature))), singleCall.data
            );
        }

        (bool success, bytes memory ret) = singleCall.target.call{value: singleCall.value}(callData);            
        returnData = Result(success, ret, address(this).balance);

        if (address(this).balance != 0) {
            singleCall.account.call{value: address(this).balance}("");
        }
    }

    function withdrawEth() public onlyOwner {
        msg.sender.call{value: address(this).balance}("");
    }

    receive() external payable { }

    fallback() external payable { }
}
