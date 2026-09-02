# Logo 概念 — 筑科建筑

## 设计方向

- **语义**：筑（建造）+ 科（科技/专业）→ 现代建筑几何块面
- **形态**：抽象高层轮廓 + 基座方块，象征稳重与品质工程
- **配色**：主色 `#0B6BCB`，深底 `#0A2540`，启动图标白底蓝标

## 分层

| 层 | 说明 |
|----|------|
| 背景 | 圆角矩形 `#FFFFFF`（app_icon）或 `#0B6BCB`（深色场景） |
| 图形 | 三阶方块堆叠成塔形，顶部略收窄 |
| 安全区 | 图形占画布 60%，四边各留 20% |

## 落盘

- 源文件：`store/logo/app_icon_zhuke.png`
- 工程：`app/entry/src/main/resources/base/media/app_icon.png`
- 启动：`icon.png` / `startIcon.png`（DevEco 分层导出前使用同图）

## DevEco 上架前

按 `.cursor/rules/app-logo.mdc` 做分层图标导出（foreground + background）。
