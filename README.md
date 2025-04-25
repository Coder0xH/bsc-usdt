## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
# 仅部署合约
$ forge script script/Deploy.s.sol:DeployScript --rpc-url bsc --broadcast

# 部署并自动验证合约（一条龙服务）
$ forge script script/Deploy.s.sol:DeployScript --rpc-url bsc --broadcast --verify -vvvv
```

### Verify (如果部署时没有使用--verify参数)

```shell
$ forge verify-contract --chain bsc <CONTRACT_ADDRESS> src/Erc20PaymentProcessor.sol:Erc20PaymentProcessor --constructor-args <ABI_ENCODED_ARGS> --watch
```

生成构造函数参数编码：
```shell
$ cast abi-encode "constructor(address,address,address)" <TOKEN_ADDRESS> <RECEIVER_ADDRESS> <OWNER_ADDRESS>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
