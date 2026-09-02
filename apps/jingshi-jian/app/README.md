# DevEco 工程 — 静时笺

HarmonyOS NEXT 原生应用，ArkTS + ArkUI Stage 模型。

## 打开方式

DevEco Studio → Open → 选择本目录（`apps/jingshi-jian/app/`）

## 编译

Sync Project → Build → Build Hap(s)

## 主要页面

- `pages/Index.ets` — 入口 + 隐私同意
- `pages/MainTabPage.ets` — 四 Tab 主框架
- `pages/TimelinePage.ets` — 时间轴首页
- `pages/MoodPage.ets` — 心情统计
- `pages/WisdomPage.ets` — 智慧笺语
- `pages/MinePage.ets` — 我的空间

## 本地存储

`services/JianStore.ets` — Preferences 持久化
