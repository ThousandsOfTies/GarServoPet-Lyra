# GarServoPet-Lyra hardware

このディレクトリは、Lyra版GarServoPet固有の配線と機械校正を所有します。

- `binding.json`: RK3506 I2C1、pin 17 SDA、pin 19 SCLの電気的契約
- `i2c.csv`: applicationが使う `/dev/i2c-1` とPCA9685 address `0x40`
- `connections.csv`: PCA9685 channel 0..3と4個のSG90の対応
- `servo-calibration.csv`: direction、neutral、pulse range、rate limit
- `components.csv`: シミュレーション上の部品一覧

bindingとruntime CSVは同じbus/device/addressを示す必要があり、`make check` が
一致を検証します。I2Cは100 kHz、3.3 V logicです。

Lyra pinmux実装は
`scripts/target/rk3506-gar-servo-pet-i2c1-overlay.dts` に隔離されています。
Product固有のCSVや校正値を `sources/gar-tools/targets` に置かないでください。

servo V+はcontroller boardとは別の5 V電源を使い、GNDのみ共有します。実機で
負荷時の電流と可動域を測るまでは、現在のpulse envelopeを広げないでください。
