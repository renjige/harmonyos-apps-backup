# 晴川游

当前 App 名称：**晴川游**

晴川旅行文化 · HarmonyOS NEXT

轻量智慧旅行伴侣：行前发现目的地灵感，行中用智能规划生成每日上午、下午、晚上行程。不含支付，不含生成式对话。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## DevEco

打开目录：**`apps/qingchuan-you/app/`**（不要打开上级 slug 目录）

## 平台

- Admin：https://saas16.qianqi.online/
- API：https://saas16.qianqi.online/api/v1
- 租户：`qingchuan-you`（App 请求头 `X-Tenant-Id`）
- 演示账号：仅见 `store/demo-account.md`（客户端不展示）

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可按需「清除缓存」
- 新用户登录后无测试行程/收藏；二级/三级页功能完整
- 浅色/深色模式文字与背景高对比
