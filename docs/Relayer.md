## `Relayer`






### `feeUpdate(uint256 newFee)` (public)





### `getRandomNumber() → bytes32 requestId` (public)

Requests randomness



### `fulfillRandomness(bytes32 requestId, uint256 randomness)` (internal)

Callback function used by VRF Coordinator



### `deposit()` (public)





### `withdraw(uint256 amount) → struct Relayer.Result returnData` (public)





### `bmsg(struct Relayer.Call[] calls) → bytes32` (public)

Get bmsg from multiple `calls`.



### `bmsg(struct Relayer.Call singleCall) → bytes32` (public)

Get bmsg from a `singleCall`.



### `tryDispatch(struct Relayer.Call[] calls, struct Relayer.Sig[] sigs) → uint256 blockNumber, struct Relayer.Result[] returnData` (public)

Implement IBATCH and ETH receiving logic.



### `trySingleCall(struct Relayer.Call singleCall, struct Relayer.Sig singleSig) → uint256 blockNumber, struct Relayer.Result returnData` (public)

Single transaction call.
Using for RTC (Remote Transaction Call) relaying.



### `_call(struct Relayer.Call singleCall) → struct Relayer.Result returnData` (internal)





### `receive()` (external)





### `fallback()` (external)






