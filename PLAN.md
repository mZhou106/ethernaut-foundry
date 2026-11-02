# 迁移计划与验证记录

> 本文件记录 `master` 分支的完整迁移过程。`practice` 分支在其基础上删除了 `src/attacks/` 与所有 `testSolve`，仅保留 `setUp` + `testInit`；因此下文步骤 6/8 中的关卡测试数量仅适用于带参考解的分支。

目标：把 Ethernaut CTF 从上游仓库迁移为独立 Foundry 工程，全部关卡可在本地通过 `forge test` 复现通关。

约定：`UPSTREAM=/home/mzhou/git-repos/ethernaut/ethernaut`，`PROJECT=/home/mzhou/git-repos/ethernaut/ethernaut-foundry`。

## 步骤 0：现状盘点

- 上游 `contracts/` 已是 Foundry 工程：41 关、38 个解法测试、26 个攻击合约。
- `contracts/lib/` 下 6 个 submodule 为空，无法编译。
- `UniqueNFT`、`Forger`、`NotOptimisticPortal` 三关没有上游测试。

验证：`find contracts/src -name '*.sol' | wc -l` → 128；`find contracts/test -name '*.sol' | wc -l` → 43。

状态：✅

## 步骤 1：创建工程骨架

产物：`foundry.toml`、`remappings.txt`、`.gitignore`、`Makefile`。

验证：

```bash
forge config --json    # src/test/out/libs/optimizer/evm_version 符合预期
forge remappings       # 7 条 remapping
```

状态：✅ 通过。

## 步骤 2：落地依赖

由用户手动执行：

```bash
cd "$UPSTREAM"
git submodule update --init --recursive
```

随后同步到新工程（排除 `.git`）：

```bash
cd "$PROJECT"
for lib in forge-std openzeppelin-contracts-06 openzeppelin-contracts-08 \
           openzeppelin-contracts-upgradeable openzeppelin-contracts-v4.6.0 \
           openzeppelin-contracts-v5.4.0; do
  rsync -a --exclude='.git' "$UPSTREAM/contracts/lib/$lib/" "lib/$lib/"
done
```

验证：

```bash
for d in lib/*/; do printf '%s: %s\n' "$d" "$(find "$d" -name '*.sol' | wc -l)"; done
```

结果：

| 库 | Solidity 文件数 |
|---|---|
| forge-std | 45 |
| openzeppelin-contracts-06 | 140 |
| openzeppelin-contracts-08 | 275 |
| openzeppelin-contracts-upgradeable | 320 |
| openzeppelin-contracts-v4.6.0 | 270 |
| openzeppelin-contracts-v5.4.0 | 404 |

状态：✅

## 步骤 3：导入核心合约

`src/Ethernaut.sol`、`src/metrics/`、`src/proxy/`、`src/levels/base/`、`src/helpers/`、`src/factory/`。

验证：`forge build` → exit 0，编译通过。

状态：✅

## 步骤 4：导入 41 关源码与攻击合约

验证：

```bash
find src -name '*.sol' | wc -l                  # 128
find src/levels -name '*Factory.sol' | wc -l    # 42
find src/attacks -name '*.sol' | wc -l          # 26
comm -3 <(cd "$UPSTREAM/contracts" && find src -name '*.sol' | sort) \
        <(find src -name '*.sol' | sort)        # 无输出
```

结果：与上游逐文件一致（缺失 0、多余 0），`forge build` 通过。

状态：✅

## 步骤 5：导入测试基础设施与核心测试

`test/utils/Utils.sol`、`test/metrics/`、`test/Ethernaut.t.sol`。

验证：

```bash
forge test --match-contract TestEthernaut -vv
```

结果：`7 passed; 0 failed; 0 skipped`。

状态：✅

## 步骤 6：分批运行关卡测试

```bash
# 1) 常规 0.8 关卡
forge test --match-contract 'Test(Fallback|Coinflip|Telephone|Token|Delegation|Force|Vault|King|Reentrance|Elevator|Privacy|NaughtCoin|Recovery|MagicNum|AlienCodex|Denial|Shop|Dex|DexTwo|GatekeeperOne|GatekeeperTwo|GatekeeperThree|Preservation|Switch|HigherOrder|Stake|BetHouse|MagicAnimalCarousel|Instance)'

# 2) 0.6 / OZ-06 关卡
forge test --match-contract 'Test(Fallout|Motorbike)'

# 3) v4.6 / v5.4 关卡
forge test --match-contract 'Test(Cashback|EllipticToken|Impersonator|ImpersonatorTwo|UniqueNFT|Forger|NotOptimisticPortal)'

# 4) 代理/多合约复杂关卡
forge test --match-contract 'Test(PuzzleWallet|DoubleEntryPoint|GoodSamaritan)'
```

结果：

| 批次 | 结果 |
|---|---|
| 1 | 62 passed, 0 failed, 0 skipped |
| 2 | 4 passed, 0 failed, 0 skipped |
| 3 | 18 passed, 0 failed, 3 skipped |
| 4 | 6 passed, 0 failed, 0 skipped |

状态：✅

## 步骤 7：补齐无测试关卡骨架

新增 `UniqueNFT.t.sol`、`Forger.t.sol`、`NotOptimisticPortal.t.sol`：`testInit` 验证实例部署且未通关，`testSolve` 用 `vm.skip(true)` 占位。

验证：三关 `testInit` 通过，`testSolve` 显示 `[SKIP]`。

状态：✅

## 步骤 8：全量回归与收尾

```bash
forge clean && forge build
forge test
```

结果：

- `forge build`：exit 0；Solc 0.5.17 / 0.6.12 / 0.8.30 / 0.8.37 均编译成功。
- `forge test`：45 个 suite，**101 passed, 0 failed, 3 skipped（104 个用例）**。
- 3 个 skipped 均为新增待解关卡的 `testSolve()`。
- 已知无害告警：18 条 `AST source not found`，来自 forge 1.8.5 的 lint 器读取 0.5/0.6 编译器 AST 的限制；不影响编译与测试（exit 0）。

状态：✅
