// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Relayer
 * 
 * Inspired by multicall, timelock contracts and permit.
 *
 * - https://github.com/makerdao/multicall/blob/master/src/Multicall.sol
 * - https://github.com/compound-finance/compound-protocol/blob/v2.8.1/contracts/Timelock.sol
 * - https://github.com/Uniswap/v2-core/blob/v1.0.1/contracts/UniswapV2ERC20.sol
 */
contract Relayer is Ownable {
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

    // ETH Vault
    // TODO: ERC20, et al. from DAO governance.
    mapping (address => uint256) public vault;

    function deposit() public payable {
        vault[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public returns (Result memory returnData) {
        // TODO: check overflow test logic contains this line.
        require(vault[msg.sender] >= amount, "Relayer: INVALID_AMOUNT");
        vault[msg.sender] -= amount;
        (bool success, bytes memory ret) = msg.sender.call{value: amount}("");
        returnData = Result(success, ret, amount);
    }

    /**
     * @dev Implement IBATCH and ETH receiving logic.
     */
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
                "Relayer: INVALID_SIGNATURE"
            );

            returnData[i] = _call(callEach);
        }   
    }

    /**
     * @dev Single transaction call.
     * Using for RTC (Remote Transaction Call) relaying.
     */
    function trySingleCall(
        Call memory singleCall, // be a bmsg
        Sig memory singleSig
    ) public payable returns (
        uint256 blockNumber,
        Result memory returnData
    ) {
        blockNumber = block.number;
        
        // bmsg
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19Ethereum Signed Message:\n32',
                keccak256(abi.encode(singleCall))
            )
        );

        address recoveredAddress = ecrecover(digest, singleSig.v, singleSig.r, singleSig.s);
        require(
            recoveredAddress != address(0) && recoveredAddress == singleCall.account,
            "Relayer: INVALID_SIGNATURE"
        );

        returnData = _call(singleCall);
    }

    function _call(
        Call memory singleCall
    ) internal returns (
        Result memory returnData
    ) {
        uint256 prevBalance = address(this).balance;

        bytes memory callData;
        if (bytes(singleCall.signature).length == 0) {
            callData = singleCall.data;
        } else {
            callData = abi.encodePacked(
                bytes4(keccak256(bytes(singleCall.signature))), singleCall.data
            );
        }

        if (singleCall.value != 0) {
            // TODO: check overflow test logic contains this line.
            require(vault[singleCall.account] >= singleCall.value, "Relayer: INVALID_AMOUNT");
            vault[singleCall.account] -= singleCall.value;
        }
        (bool success, bytes memory ret) = singleCall.target.call{value: singleCall.value}(callData);

        uint256 receivedETH = address(this).balance - prevBalance;
        returnData = Result(success, ret, receivedETH);
        if (receivedETH != 0) {
            vault[singleCall.account] += receivedETH;
        }
    }

    receive() external payable { }

    fallback() external payable { }
}
