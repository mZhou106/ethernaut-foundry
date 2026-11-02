# Ethernaut Foundry（练习分支）

> 当前分支：`practice`。所有参考解已移除：`src/attacks/` 已删除，41 个关卡测试只保留 `setUp` 与 `testInit`。
> 完整参考解见 `master` 分支。

Ethernaut CTF 的独立 Foundry 闯关工程。保留官方关卡合约与通关判定逻辑，去掉 React/JS 依赖，全部通过 `forge test` 本地复现。

## 目录结构

```
src/
  Ethernaut.sol            # 游戏核心：注册关卡、创建实例、提交通关
  metrics/                 # 统计合约（Statistics / ProxyStats）
  proxy/                   # 代理相关合约
  levels/                  # 41 个关卡 + Factory
  helpers/                 # 关卡依赖的辅助合约
test/
  Ethernaut.t.sol          # 游戏核心逻辑测试
  metrics/                 # 统计合约测试
  levels/<Level>.t.sol     # 每关：setUp + testInit（待你补 testSolve）
  utils/Utils.sol          # 测试工具：建号、创建实例、提交通关
  utils/Manufactured.sol   # 核心测试用的 mock（非关卡答案）
lib/                       # forge-std + 5 个版本的 OpenZeppelin
```

## 快速开始

```bash
forge build
forge test
```

当前分支的测试只验证环境与初始状态：

```
45 suites, 52 passed, 0 failed, 0 skipped
```

## 如何做题

每关的 `setUp()` 已经完成：部署 `Ethernaut` + 统计代理、注册 Factory、以 `player` 身份创建实例。

以 Fallback 为例，在 `test/levels/Fallback.t.sol` 的测试合约里添加：

```solidity
function testSolve() public {
    vm.startPrank(player);

    // 1. 编写攻击逻辑（可直接写在测试里，或新建 src/attacks/MyAttack.sol）

    // 2. 提交实例；validateInstance 返回 true 时才算通关
    assertTrue(submitLevelInstance(ethernaut, address(instance)));
}
```

运行：

```bash
forge test --match-contract TestFallback -vvv
# 或
make test-one LEVEL=Fallback
```

判定规则：`submitLevelInstance` 内部调用 `Factory.validateInstance(instance, player)`，只有返回 true 才会发出 `LevelCompletedLog`。测试断言 `assertTrue` 通过即代表按官方规则通关。

## 关卡清单

| # | 关卡 | 测试文件 |
|---|---|---|
| 0 | Hello Ethernaut | `Instance.t.sol` |
| 1 | Fallback | `Fallback.t.sol` |
| 2 | Fallout | `Fallout.t.sol` |
| 3 | Coin Flip | `Coinflip.t.sol` |
| 4 | Telephone | `Telephone.t.sol` |
| 5 | Token | `Token.t.sol` |
| 6 | Delegation | `Delegation.t.sol` |
| 7 | Force | `Force.t.sol` |
| 8 | Vault | `Vault.t.sol` |
| 9 | King | `King.t.sol` |
| 10 | Re-entrancy | `Reentrance.t.sol` |
| 11 | Elevator | `Elevator.t.sol` |
| 12 | Privacy | `Privacy.t.sol` |
| 13 | Gatekeeper One | `GatekeeperOne.t.sol` |
| 14 | Gatekeeper Two | `GatekeeperTwo.t.sol` |
| 15 | Naught Coin | `NaughtCoin.t.sol` |
| 16 | Preservation | `Preservation.t.sol` |
| 17 | Recovery | `Recovery.t.sol` |
| 18 | MagicNumber | `MagicNum.t.sol` |
| 19 | Alien Codex | `AlienCodex.t.sol` |
| 20 | Denial | `Denial.t.sol` |
| 21 | Shop | `Shop.t.sol` |
| 22 | Dex | `Dex.t.sol` |
| 23 | Dex Two | `DexTwo.t.sol` |
| 24 | Puzzle Wallet | `PuzzleWallet.t.sol` |
| 25 | Motorbike | `Motorbike.t.sol` |
| 26 | DoubleEntryPoint | `DoubleEntryPoint.t.sol` |
| 27 | Good Samaritan | `GoodSamaritan.t.sol` |
| 28 | Gatekeeper Three | `GatekeeperThree.t.sol` |
| 29 | Switch | `Switch.t.sol` |
| 30 | HigherOrder | `HigherOrder.t.sol` |
| 31 | Stake | `Stake.t.sol` |
| 32 | Impersonator | `Impersonator.t.sol` |
| 33 | Magic Animal Carousel | `MagicAnimalCarousel.t.sol` |
| 34 | Bet House | `BetHouse.t.sol` |
| 35 | Elliptic Token | `EllipticToken.t.sol` |
| 36 | Cashback | `Cashback.t.sol` |
| 37 | Impersonator Two | `ImpersonatorTwo.t.sol` |
| 38 | UniqueNFT | `UniqueNFT.t.sol` |
| 39 | Forger | `Forger.t.sol` |
| 40 | NotOptimisticPortal | `NotOptimisticPortal.t.sol` |

> `UniqueNFT`、`Forger`、`NotOptimisticPortal` 上游也没有参考解，适合作为额外挑战。

## 练习分支的特殊处理

- **MagicNum**：`testInit` 断言初始 `solver == address(0)`。没有 solver 时调用 `submitLevelInstance` 会 revert，因此该关的 `testInit` 不调用提交。
- **Motorbike**：原参考解在 `setUp` 里完成 selfdestruct；本分支已移除，`setUp` 只创建实例，`testInit` 断言未通关。
- **Reentrance**：关卡是 `^0.6.12`，0.8 测试无法直接 import，测试文件内用空接口 `interface Reentrance {}` 作为类型。
- **AlienCodex / HigherOrder / Fallout / Token**：测试文件保留本地接口，仅删除了作弊合约。
- **Manufactured**：核心测试用的 mock，放在 `test/utils/Manufactured.sol`，不是关卡答案。

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

## 验证结果（2026-11-02）

```
forge build   → exit 0（Solc 0.5.17 / 0.6.12 / 0.8.30 / 0.8.37）
forge test    → 45 suites, 52 passed, 0 failed, 0 skipped
```
