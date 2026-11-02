# Ethernaut Foundry

Ethernaut CTF 的独立 Foundry 闯关工程。保留官方关卡合约与通关判定逻辑，去掉 React/JS 依赖，全部通过 `forge test` 本地复现。

## 目录结构

```
src/
  Ethernaut.sol            # 游戏核心：注册关卡、创建实例、提交通关
  metrics/                 # 统计合约（Statistics / ProxyStats）
  proxy/                   # 代理相关合约
  levels/                  # 41 个关卡 + Factory
  attacks/                 # 38 个参考攻击合约
  helpers/                 # 关卡依赖的辅助合约
test/
  Ethernaut.t.sol          # 游戏核心逻辑测试
  metrics/                 # 统计合约测试
  levels/<Level>.t.sol     # 每关一个测试：testInit + testSolve
  utils/Utils.sol          # 测试工具：建号、创建实例、提交通关
lib/                       # forge-std + 5 个版本的 OpenZeppelin
```

## 快速开始

```bash
forge build
forge test
```

单关运行：

```bash
forge test --match-contract TestFallback -vvv
# 或
make test-one LEVEL=Fallback
```

## 判定通关的方式

每关测试都遵循同一流程：

1. `setUp()`：部署 `Ethernaut` + 统计代理，注册关卡 Factory，以 `player` 身份创建实例。
2. `testInit()`：确认初始状态未通关，`submitLevelInstance` 返回 false。
3. `testSolve()`：执行攻击，最后断言 `assertTrue(submitLevelInstance(...))`。

`submitLevelInstance` 只有在 `Factory.validateInstance(instance, player)` 返回 true 时才会发出 `LevelCompletedLog`，因此测试通过即代表该关按官方规则通关。

## 关卡状态

| # | 关卡 | 测试 | 状态 |
|---|---|---|---|
| 0 | Hello Ethernaut | `Instance.t.sol` | ✅ |
| 1 | Fallback | `Fallback.t.sol` | ✅ |
| 2 | Fallout | `Fallout.t.sol` | ✅ |
| 3 | Coin Flip | `Coinflip.t.sol` | ✅ |
| 4 | Telephone | `Telephone.t.sol` | ✅ |
| 5 | Token | `Token.t.sol` | ✅ |
| 6 | Delegation | `Delegation.t.sol` | ✅ |
| 7 | Force | `Force.t.sol` | ✅ |
| 8 | Vault | `Vault.t.sol` | ✅ |
| 9 | King | `King.t.sol` | ✅ |
| 10 | Re-entrancy | `Reentrance.t.sol` | ✅ |
| 11 | Elevator | `Elevator.t.sol` | ✅ |
| 12 | Privacy | `Privacy.t.sol` | ✅ |
| 13 | Gatekeeper One | `GatekeeperOne.t.sol` | ✅ |
| 14 | Gatekeeper Two | `GatekeeperTwo.t.sol` | ✅ |
| 15 | Naught Coin | `NaughtCoin.t.sol` | ✅ |
| 16 | Preservation | `Preservation.t.sol` | ✅ |
| 17 | Recovery | `Recovery.t.sol` | ✅ |
| 18 | MagicNumber | `MagicNum.t.sol` | ✅ |
| 19 | Alien Codex | `AlienCodex.t.sol` | ✅ |
| 20 | Denial | `Denial.t.sol` | ✅ |
| 21 | Shop | `Shop.t.sol` | ✅ |
| 22 | Dex | `Dex.t.sol` | ✅ |
| 23 | Dex Two | `DexTwo.t.sol` | ✅ |
| 24 | Puzzle Wallet | `PuzzleWallet.t.sol` | ✅ |
| 25 | Motorbike | `Motorbike.t.sol` | ✅ |
| 26 | DoubleEntryPoint | `DoubleEntryPoint.t.sol` | ✅ |
| 27 | Good Samaritan | `GoodSamaritan.t.sol` | ✅ |
| 28 | Gatekeeper Three | `GatekeeperThree.t.sol` | ✅ |
| 29 | Switch | `Switch.t.sol` | ✅ |
| 30 | HigherOrder | `HigherOrder.t.sol` | ✅ |
| 31 | Stake | `Stake.t.sol` | ✅ |
| 32 | Impersonator | `Impersonator.t.sol` | ✅ |
| 33 | Magic Animal Carousel | `MagicAnimalCarousel.t.sol` | ✅ |
| 34 | Bet House | `BetHouse.t.sol` | ✅ |
| 35 | Elliptic Token | `EllipticToken.t.sol` | ✅ |
| 36 | Cashback | `Cashback.t.sol` | ✅ |
| 37 | Impersonator Two | `ImpersonatorTwo.t.sol` | ✅ |
| 38 | UniqueNFT | `UniqueNFT.t.sol` | 🚧 待解 |
| 39 | Forger | `Forger.t.sol` | 🚧 待解 |
| 40 | NotOptimisticPortal | `NotOptimisticPortal.t.sol` | 🚧 待解 |

> 后三关官方尚未提供解法。工程里已搭好部署/未通关断言，`testSolve` 用 `vm.skip(true)` 占位；补上攻击代码后去掉 skip 即可。

## 依赖说明

关卡跨多个 Solidity / OpenZeppelin 版本，因此保留 5 个 OZ 依赖：

| remapping | 用途 |
|---|---|
| `openzeppelin-contracts-08` | 核心合约与大部分关卡 |
| `openzeppelin-contracts-06` | Fallout、Motorbike 等 0.6 关卡 |
| `openzeppelin-upgradeable` | Statistics 代理 |
| `openzeppelin-contracts-v5.4.0` | Cashback、UniqueNFT、NotOptimisticPortal |
| `openzeppelin-contracts-v4.6.0` | Forger |
| `@openzeppelin/contracts` | NotOptimisticPortal 的导入路径，映射到 v5.4.0 |

## 与上游的关系

- 关卡源码、Factory、攻击合约、测试均来自 `OpenZeppelin/ethernaut` 仓库的 `contracts/`（vendored，未修改）。
- 上游 `client/` 的 React/JS 部分不参与本工程；通关判定直接在 Solidity 测试中完成。
- `test/levels/UniqueNFT.t.sol`、`Forger.t.sol`、`NotOptimisticPortal.t.sol` 为本工程新增的骨架。

## 验证结果（2026-11-02）

```
forge build   → exit 0（Solc 0.5.17 / 0.6.12 / 0.8.30 / 0.8.37）
forge test    → 45 suites, 101 passed, 0 failed, 3 skipped (104 total)
```

分批验证、每步命令和详细结果见 [PLAN.md](PLAN.md)。
