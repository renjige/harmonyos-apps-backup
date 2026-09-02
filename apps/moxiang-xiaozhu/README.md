# 墨香小筑

当前 App 名称：**墨香小筑**（墨香雅集）

读今日书摘，写下墨迹，在小筑与文友打卡。HarmonyOS NEXT 原生阅读与笔记工具。

## 上架图标（华为应用市场请用这个）

- `apps/moxiang-xiaozhu/store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 分层：`store/logo/foreground.png` + `store/logo/background.png`
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`

## DevEco

打开目录：**`apps/moxiang-xiaozhu/app/`**（不要打开上级 slug 目录）

## 平台对接

- API：`https://saas16.qianqi.online/api/v1`
- 租户：`moxiang-xiaozhu`
- Admin：https://saas16.qianqi.online/  
  账号 `admin@moxiang-xiaozhu.local` / `AdminPass#2026`
- 演示账号仅见 `store/demo-account.md`（客户端不预填）

## 功能

游客可浏览今日书摘、智慧书房书单、文友圈精选笺。登录后可写墨迹、书评与打卡；新用户这些列表为空。书房匹配为问卷 + 规则模板，不含生成式对话。

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；设置内可「清除缓存」
- 栏目走平台 `/biz/ink-cottage/*`，禁止客户端假数据
- 浅色 / 深色模式高对比
