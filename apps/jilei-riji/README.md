# 积累日记

轻量级智慧日记应用 — **每日积累，见证成长**。

## DevEco 工程

打开目录：`apps/jilei-riji/app/`

**包名（与签名 Profile 一致）**：`jlrj.lwl.huawei`  
对应 Profile：`F:/download/jlrj.lwl.huaweiRelease.p7b`

### DevEco 启动报 com.qingjilei.jileiriji 不存在？

1. **完全关闭 DevEco** 后重新打开 `apps/jilei-riji/app/`
2. 菜单 **File → Sync and Refresh Project**
3. 再 Run；或直接用 `app/run-emulator.ps1`

## 核心功能

| 模块 | 说明 |
|------|------|
| 每日记录 | 启动即写，富文本标记（粗体/斜体/列表），单张配图，自动保存 |
| 时间轴 | 按日期倒序浏览，点击进入详情 |
| 智慧回顾 | 月度记录天数、连续记录、本地高频词云（无「AI」字样） |
| 设置 | 纯文本导出、隐私政策、关于、深色模式 |

## 数据存储

日记正文与配图路径保存在本机 `Preferences`，无需登录即可使用。

## 隐私合规

- 首次启动弹出隐私政策弹窗，同意后方可写入与选图
- 协议全文：`store/privacy-policy.md` · `store/user-agreement.md`

## 上架图标

- **完整合成图**：`store/logo/preview-1024.png`
- **工程图标**：`app/AppScope/resources/base/media/app_icon.png`
- **SVG 源文件**：`store/logo/symbol.svg`

## 视觉资产

- `app/entry/src/main/resources/base/media/hero_paper_bg.png`
- `app/entry/src/main/resources/base/media/empty_timeline.png`

## 激励计划 2026

见 `store/incentive-notes.md`
