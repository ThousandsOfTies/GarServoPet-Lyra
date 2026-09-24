# GarServoPet-Lyra Agent Rules

このリポジトリは `gar-servo-pet` applicationと `luckfox-rk3506` targetを固定した
Product rootです。別の物理targetを追加せず、別Product repositoryとして作成して
ください。Deployment dispatcherやtarget selectorを再導入しないでください。

## Ownership

- `sources/gar-servo-pet`: application behaviorとmotion logic
- `sources/gar-tools`: reusable target/simulation tooling
- `hardware`: Lyra版Product固有の配線、channel、校正
- `scripts/target`: Lyra版Product固有のpackageとboard hook
- `config/artifact.json`: このrepositoryだけが生成するGAR成果物契約

Product固有のhardware CSVや校正値を `sources/gar-tools/targets` に置かないで
ください。submodule変更は子repositoryで先にcommit・pushし、その後に親pointerを
更新します。生成artifactはcommitしません。

## Web simulator

For any GAR App simulator, read `sources/gar-tools/AGENTS.md`
before editing the panel. If the pinned copy lacks it, consult the latest
gar-tools guide; update the pin when using newer shared components. Build
reusable device UI and interactions as shared Web
Components in `sources/gar-tools/web-simulator/components/`; keep Product
mapping, bridge protocol, and commands in the Product adapter.
