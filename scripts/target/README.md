# GarServoPet Luckfox Lyra Plus target

このディレクトリはGarServoPet-Lyra固有の物理ターゲット実装です。

- `package.sh`: 固定ApplicationをARMv7 hard-floatでbuildしてSSH成果物を作る
- `configure-target`: board modelを確認してFIT Device TreeのI2C1を有効にする
- `health`: servoを駆動しないlifecycle health check
- `rk3506-gar-servo-pet-i2c1-overlay.dts`: RM_IO10/RM_IO11 pinmux

リポジトリの公開entrypointは `scripts/product-target-build.sh` です。targetの選択や
dispatchは行わず、このdirectoryの `package.sh` を直接呼びます。

`configure-target` は `/dev/mtdblock1` に触れる前に正確な
`Luckfox Lyra Plus` modelを確認し、最初のboot partition imageを
`/var/lib/gar/backups` に保存します。FIT payloadとSHA-256 metadataだけを更新し、
再起動が必要な場合はstatus 10を返します。
