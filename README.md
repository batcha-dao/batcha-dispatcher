# batcha-dispatcher

Smart contracts of BATCHA!

# Features

* IBATCH

* RBATCH

* Remote Transaction Call (RTC)

# Deploy

### Run Ganache CLI

```
$ ganache-cli -b 15
```

<!--
Ganache CLI v6.12.2 (ganache-core: 2.13.2)

Available Accounts
==================
(0) 0x79A575616CA4eB259aa88D6B13B3Ae33843C4A33 (100 ETH)
(1) 0xE4430c6Ab99357a705af0ac9F1064508AeE5D013 (100 ETH)
(2) 0x9744C5edF98EC3eD3BF4326a0dFC5C1879fE3162 (100 ETH)
(3) 0x1C13Ae984b7f2fD20c66630Bf4598354535e18b6 (100 ETH)
(4) 0x5a3c780846c18a09Ab43333e720F0E03f9DE932E (100 ETH)
(5) 0x0FDa95b5E2A236337863BEAD97820321C13Dc013 (100 ETH)
(6) 0x7fE079392872eD81eeA9DB32837939052488B6be (100 ETH)
(7) 0xED15352a348728d625606AbCc7Ed2D3b5fdFcA5E (100 ETH)
(8) 0x551051645f163AdD06b37Ca9c9B6979cD68Fd85A (100 ETH)
(9) 0x4b321a31cfC94c39071F1AEaF86BB3e5165Dc65A (100 ETH)

Private Keys
==================
(0) 0xde84d48a770a29e164b860c5b01ee4f3f064aa72377504a0243eb47c18c199ba
(1) 0x8c16cf32b54c9669365fff88197431c58ed820784d8a876d9a80d851a79efcab
(2) 0xe24639ae814afcea1a8295caafe3c6bba8edb057e36336abbf35d37e85d7c3fb
(3) 0x7738e79ce0a807cdaca37f16cce5ac35cfa6022d7afc6a68b07c5faa9f837f8a
(4) 0x125e093f13eeae700b39ccb0c602077b1bc49b0726d46d8be6ae6f484a3b53af
(5) 0x41e9de14db333df9092bae5c81ddef6c7c6390cedae4349ea9f88a02f2cf451a
(6) 0x4c6f283a10d4e083d8d6de3a2455e0c7692c205a3737bf4a1d1ecb05abc0988e
(7) 0xd3dd847c1fb3895d74ed5735b6fb878370bed18f4f1aa395bb05e8af649c1202
(8) 0x8d46ee5e35a7883b8ebe92c32fdb56b8485d35862ea8d67fb529bb0f36a62684
(9) 0x8f3ffb552f172b82d7b4e3624b3539b48e7ed21ebfc663bdd51d8f14ba082d6f

HD Wallet
==================
Mnemonic:      neither volume bomb just piece amazing crowd muscle summer reveal panda album
Base HD Path:  m/44'/60'/0'/0/{account_index}

Gas Price
==================
20000000000

Gas Limit
==================
6721975

Call Gas Limit
==================
9007199254740991

Listening on 127.0.0.1:8545
-->

### Compile & Migrate

Create migration template.

```
$ truffle create migrations relayer
```

Modify it. Then,

```
$ truffle compile
$ truffle migrate

  Transaction: 0x7774996c3cc29e72491a9e8672882cd1582fca06e5eee5e8118dad2706a1328f
  Gas usage: 27549
  Block Number: 9
  Block Time: Sun Dec 19 2021 01:37:09 GMT+0900 (Korean Standard Time)
```

# Get Signature (v, r, s)

```
$ truffle console

truffle(development)> web3.eth.accounts.sign("Hello, World!", "0x9fcdf25714e85405689382d7be5d454dcd05f295113b1101080c0795591294f7")

{
  message: 'Hello, World!',
  messageHash: '0xc8ee0d506e864589b799a645ddb88b08f5d39e8049f9f702b3b61fa15e55fc73',
  v: '0x1b',
  r: '0x0a390e62fb6afa20cda8fd29943623420d77606abad461aef13b8949ede3cc99',
  s: '0x3d7631d277b0b67bfc0a0dd45ec303dcf4eac66c0d5c97a873dd26fc4db6f122',
  signature: '0x0a390e62fb6afa20cda8fd29943623420d77606abad461aef13b8949ede3cc993d7631d277b0b67bfc0a0dd45ec303dcf4eac66c0d5c97a873dd26fc4db6f1221b'
}
```

# Documentation

```
$ solidity-docgen --solc-module ./node_modules/solc -i contracts -o docs
```
