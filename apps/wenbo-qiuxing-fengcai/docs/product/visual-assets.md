# 球星风采 · 内容影像清单

productVisualType: `content-commerce`（体育人物百科 · 影像驱动首页与详情）

| 文件名 | 用途 | 场景描述 |
|---|---|---|
| hero_sports_discovery | 首页 Hero | 体育场馆/editorial 氛围，底部留文案区 |
| athlete_football_1 | 足球球星封面 | 绿茵场运动员 editorial 肖像 |
| athlete_football_2 | 足球球星封面 | 另一足球场景，区别于 1 |
| athlete_football_3 | 足球球星封面 | 训练/庆祝场景 |
| athlete_basketball_1 | 篮球球星封面 | 室内篮球馆运动员 |
| athlete_basketball_2 | 篮球球星封面 | 扣篮/投篮动作 |
| athlete_basketball_3 | 篮球球星封面 | 球队合影风格 |
| athlete_tennis_1 | 网球球星封面 | 红土/硬地网球选手 |
| athlete_tennis_2 | 网球球星封面 | 挥拍瞬间 |
| athlete_racing_1 | 赛车手封面 | F1/赛道头盔肖像 |
| athlete_racing_2 | 赛车手封面 |  paddock 现场 |
| athlete_other_1 | 综合运动封面 | 田径/游泳等 |
| athlete_other_2 | 综合运动封面 | 奥运风格 editorial |
| event_football_1 | 足球赛事封面 | 球场全景比赛氛围 |
| event_basketball_1 | 篮球赛事封面 | 场馆比赛夜场 |
| event_tennis_1 | 网球赛事封面 | 大满贯球场 |
| event_racing_1 | 赛车赛事封面 | 赛道起跑 |
| event_other_1 | 综合赛事封面 | 综合性运动会 |

## 登记（AppSpec.brand.visualAssets）

与 `entry/src/main/resources/base/media/` 文件名一一对应；HomePage / DetailPane / ListCard 均通过 `StarMedia.coverMedia(coverKey)` 或 `$r('app.media.*')` 引用。

## 验收

- 内容影像 ≥ 5（当前 18）
- HomePage Image 引用 ≥ 2
- 不同 coverKey 禁止共图（需逐张 GenerateImage 差异化）
