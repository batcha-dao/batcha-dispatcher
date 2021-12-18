// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

/**
 * @title Relayer
 * 
 * Inspired by multicall, timelock contracts and permit.
 *
 * - https://github.com/makerdao/multicall/blob/master/src/Multicall.sol
 * - https://github.com/compound-finance/compound-protocol/blob/v2.8.1/contracts/Timelock.sol
 * - https://github.com/Uniswap/v2-core/blob/v1.0.1/contracts/UniswapV2ERC20.sol
 */
contract Relayer is
    Ownable,
    VRFConsumerBase(
        0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
        0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
    )
{
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

    // Chainlink VRF
    bytes32 public constant keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    uint256 public fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    function feeUpdate(uint newFee) public onlyOwner { fee = newFee; }

    uint256 public randomResult;

    /** 
     * @notice Requests randomness 
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * @notice Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
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
     * @notice Get bmsg from multiple `calls`.
     */
    function bmsg(Call[] memory calls) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                '\x19Ethereum Signed Message:\n32',
                keccak256(abi.encode(calls))
            )
        );
    }

    /**
     * @notice Get bmsg from a `singleCall`.
     */
    function bmsg(Call memory singleCall) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                '\x19Ethereum Signed Message:\n32',
                keccak256(abi.encode(singleCall))
            )
        );
    }

    /**
     * @notice Implement IBATCH and ETH receiving logic.
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
     * @notice Single transaction call.
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
