## `Relayer`






### `deposit()` (public)





### `withdraw(uint256 amount) → struct Relayer.Result returnData` (public)





### `tryDispatch(struct Relayer.Call[] calls, struct Relayer.Sig[] sigs) → uint256 blockNumber, struct Relayer.Result[] returnData` (public)



Implement IBATCH and ETH receiving logic.

### `trySingleCall(struct Relayer.Call singleCall, struct Relayer.Sig singleSig) → uint256 blockNumber, struct Relayer.Result returnData` (public)



Single transaction call.
Using for RTC (Remote Transaction Call) relaying.

### `_call(struct Relayer.Call singleCall) → struct Relayer.Result returnData` (internal)





### `receive()` (external)





### `fallback()` (external)






