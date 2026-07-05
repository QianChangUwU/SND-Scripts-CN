# SND-Scripts-CN

SomethingNeedDoing (SND) 插件的中文汉化脚本合集。

## 脚本列表

| 脚本 | 路径 | 说明 | 依赖插件 |
|------|------|------|----------|
| 蛮族日常任务 | `Dailies/AlliedSocietiesQuests.lua` | 自动领取并完成指定蛮族的日常任务，支持全部蛮族及信誉等级 | Questionable, vnavmesh, Lifestream, TextAdvance |
| 鱼王（7.0） | `Gatherers/BigFish(DT).lua` | 自动钓取已追踪的 7.0 鱼王，支持鱼窗监控、天气判断、自动传送 | MissFisher, Lifestream, vnavmesh |

## 使用前提

1. 已安装 [SomethingNeedDoing](https://github.com/PunsherXIV/SomethingNeedDoing) 插件
2. 已安装各脚本所需的依赖插件（见上表）
3. 游戏客户端语言设置为**简体中文**（脚本中的数据键值已通过 EXDViewer 和 XIVAPI v2 查询游戏底层数据表获取准确中文名）

## 脚本说明

### 蛮族日常任务 (AlliedSocietiesQuests.lua)

- 自动前往指定的蛮族据点，接取 3 个日常任务，完成后前往下一个蛮族据点
- 支持 4 个蛮族轮换，可为每个蛮族指定不同的职业/特职
- 支持 2.0~7.x 全部蛮族（蜥蜴人族、妖精族、地灵族、鱼人族、鸟人族、瓦努族、骨颌族、莫古力族、甲人族、阿难陀族、鲶鱼精族、仙子族、奇塔利族、矮人族、悌阳象族、奥密克戎族、兔兔族、佩鲁佩鲁族、辉鳞族、尤卡巨人族）
- 2.0 蛮族支持按信誉等级选择任务发布者

### 鱼王 (7.0) (BigFish(DT).lua)

- 自动监控 7.0 (Dawntrail) 全部 40 种鱼王的钓鱼窗口
- 根据天气、时间、鱼饵自动判断并前往钓点
- 通过 MissFisher 预设自动钓鱼，支持游饵提前就位
- 支持鱼饵库存检查、空闲自动传送、失败重试

## 致谢

- 原作者: pot0to (https://ko-fi.com/pot0to)
- 维护者: Minnu (https://ko-fi.com/minnuverse)
- 汉化: QianChang (https://github.com/QianChangUwU)
