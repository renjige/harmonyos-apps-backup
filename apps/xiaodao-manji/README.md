# 小岛慢记

个人生活档案与美好瞬间收藏空间——在忙碌世界里，为自己保留一座慢生活数字小岛。

## DevEco 工程

打开目录：`apps/xiaodao-manji/app/`

## 上架图标

- 推荐上传：`apps/xiaodao-manji/store/logo/preview-1024.png`
- 工程副本：`apps/xiaodao-manji/app/AppScope/resources/base/media/app_icon.png`

## 核心闭环

写慢记 / 收瞬间 → 整理状态 → 归入主题岛 → 记录心情 → 时间长廊回望 → 年度档案

## 特性

- 纯本地存储，**0 系统权限**（无网络、无相机、无定位）
- 五 Tab：小岛 · 慢记 · 主题 · 回望 · 我的
- 心情记录 · 生活清单 · 智慧整理 · 回忆册 · 成就墙
- 无登录、无生成式 AI

## 管理后台

本地工具，无 SaaS 租户与 Admin。

## 验收

```bash
npm run gate:behavior -- apps/xiaodao-manji
```
