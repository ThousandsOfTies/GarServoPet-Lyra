# GarServoPet-Lyra

GarServoPet の Luckfox Lyra Plus（RK3506）製品リポジトリです。1つの
Application Capsule `gar-servo-pet` と、1つの物理ターゲット
`luckfox-rk3506` を固定して構成します。

このリポジトリにはターゲット選択機能がありません。別のコントローラを使う
製品構成は別リポジトリで管理します。これにより、Product の履歴、CI、設定、
成果物が物理ターゲットごとに独立します。

## 構成

```text
GarServoPet-Lyra/
  config/
    artifact.json                 # Lyra用GAR成果物契約
    luckfox-rk3506.env.example    # SDK/toolchain設定例
    product.env
  hardware/
    binding.json                  # Lyra I2C1との固定binding
    i2c.csv                       # /dev/i2c-1 runtime設定
    connections.csv
    servo-calibration.csv
  scripts/
    product-target-build.sh       # GARから呼ばれる固定entrypoint
    target/                       # Lyra固有package・DT・health hook
  sources/
    gar-servo-pet/                # 共通Application Capsule submodule
    gar-tools/                    # 共通Target Pack submodule
  panel/                          # ブラウザシミュレータ
```

`scripts/product-target-build.sh` は固定値を設定して
`scripts/target/package.sh` を直接呼びます。Deployment Profile、
`GAR_DEPLOYMENT`、dispatcher は使用しません。`GAR_TARGET` に
`luckfox-rk3506` 以外が渡された場合は構成ミスとして終了します。

## セットアップと検証

```bash
git clone --recurse-submodules \
  https://github.com/ThousandsOfTies/GarServoPet-Lyra.git
cd GarServoPet-Lyra
make setup
make check
```

既存checkoutでは次を実行します。

```bash
git submodule update --init --recursive
```

親リポジトリは子リポジトリの正確なcommitを記録します。子側の変更は先に
commit・pushし、その後でこのリポジトリのsubmodule pointerを更新します。

## Lyra向け成果物の作成

既定では、隣接workspaceの
`../LuckFox/luckfox-lyra-sdk-250815` にLuckfox SDKがあるものとして検索します。
別の場所を使う場合は設定例をコピーします。

```bash
cp config/luckfox-rk3506.env.example config/luckfox-rk3506.env
# GAR_LUCKFOX_SDK_ROOT を編集
scripts/product-target-build.sh
```

packageはLuckfox公式の `arm-none-linux-gnueabihf` toolchainで静的ARMv7
hard-float binaryを作成し、次のGAR SSH成果物を出力します。

```text
artifacts/from-codespace/
  artifact.json
  files/gar-servo-pet/
    gar-servoctl
    run
    README.md
    hardware/
```

GAR workspaceのtargetは `luckfox-rk3506` として登録し、通常どおりbuild・deploy
します。

```bash
gar target prepare --workspace <name>
gar target build --workspace <name>
gar target deploy --workspace <name>
```

初回deploy時のhookは正確な `Luckfox Lyra Plus` modelを確認し、boot partitionを
backupしてから、I2C1に必要なFIT Device Treeだけを更新します。再起動後に
`/dev/i2c-1` が存在することを確認してください。

## ハードウェア契約

PCA9685はLyra PlusのI2C1へ接続します。

- SDA: physical pin 17 / RM_IO11
- SCL: physical pin 19 / RM_IO10
- bus/device: `1` / `/dev/i2c-1`
- address: `0x40`
- frequency: 100 kHz
- logic: 3.3 V

PCA9685のlogicのみを3.3 Vへ接続します。4個のSG90のV+には十分な容量の別5 V
電源を使い、Lyraと共通GNDにしてください。headerからservoを給電しないで
ください。

target上ではbundle済みentrypointを使います。

```bash
cd /opt/gar/apps/gar-servo-pet
./run validate
./run probe
./run off
```

引数なしのservice modeとhealth hookは非駆動です。明示的な `probe` や動作命令を
実行する前に配線と機構の安全を確認してください。
