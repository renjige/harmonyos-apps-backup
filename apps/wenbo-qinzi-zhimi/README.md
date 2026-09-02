# 亲子智谜

面向 3–12 岁儿童与家长的亲子益智互动工作台：**今日闯关、探索题库、亲子对答、成长中心、错题本、家庭出题**。进度按账号隔离。

## DevEco 路径

`apps/wenbo-qinzi-zhimi/app/`

## 上架图标

`apps/wenbo-qinzi-zhimi/store/logo/preview-1024.png`

## 版本 1.0.3 丰富度升级

| 模块 | 新增 |
|------|------|
| 5 Tab | 今日 · **探索** · 亲子 · **成长** · 我的 |
| 今日工作台 | 四格数据卡、本周计划/错题摘要、最近动态、主题包、周回顾 |
| 探索中心 | 状态筛选（未做/已做/错题/收藏）、难度排序、收藏夹、主题包进度 |
| 成长中心 | 柱状图、打卡日历、时间轴、成就墙、分类掌握度、周回顾 Overlay |
| 数据层 | 时间轴、收藏夹、周计划目标（默认 15 题 + 1 次亲子） |

## 平台

- API：`https://saas16.qianqi.online/api/v1`
- 租户：`wenbo-qinzi-zhimi`

## Gate

`npm run gate:behavior -- apps/wenbo-qinzi-zhimi` — **pass**
