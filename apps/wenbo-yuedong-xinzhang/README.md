# 跃动新章

把一段时间过成可收官的人生篇章 — 开章、执行、写作复盘，数据本机存储。

## DevEco 工程

打开目录：`apps/wenbo-yuedong-xinzhang/app/`

## 上架图标

- 合成预览：`apps/wenbo-yuedong-xinzhang/store/logo/preview-1024.png`
- 工程副本：`apps/wenbo-yuedong-xinzhang/app/AppScope/resources/base/media/app_icon.png`

## 核心功能（相对系统日历的差异）

| Tab | 能力 |
|-----|------|
| 今日章 | 进行中篇章、清单/小时轴、任务详情（备注+投入分钟） |
| 目标 | 里程碑拆解、进度、归档 |
| 复盘 | 跃动指数、工作/学习/生活时间账、篇章档案 |
| 我的 | 指数与收官数、深色模式、设置与隐私 |

**必须演示**：开启新章 → 写任务并补记分钟 → 章末复盘 ≥20 字收官。

## 数据与隐私

- 纯本地 Preferences 存储，无联网权限
- 首次启动隐私同意弹窗；撤回：我的 → 设置与隐私

## 运营者

魏文波（个人开发者）

## 验证

```bash
npm run gate:behavior -- apps/wenbo-yuedong-xinzhang
```
