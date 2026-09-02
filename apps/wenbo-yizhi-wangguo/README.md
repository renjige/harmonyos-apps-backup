# 益智王国

当前 App 名称：**益智王国**

魏文波 · HarmonyOS NEXT · slug `wenbo-yizhi-wangguo`

面向 3 到 12 岁儿童的分级益智闯关：图形配对、色彩识别、数字序列与简单推理。进度保存在本机。无广告、无支付。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 平台对接

- Admin：https://saas16.qianqi.online/
- API：https://saas16.qianqi.online/api/v1
- 租户：`wenbo-yizhi-wangguo`（`ApiConfig.TENANT_ID`）
- 栏目：`GET /biz/kids-kingdom/levels|questions|dailies|relics|guides`
- 通知：`GET /messages`

## DevEco

打开目录：`apps/wenbo-yizhi-wangguo/app/`（不要打开上级 slug 目录）

## 账号（勿写进客户端）

- App 审核演示：见 `store/demo-account.md`
- Admin 租户管理员：见 `store/admin-account.md`

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可「清除缓存」
- 新用户闯关记录为空；栏目题目走平台 API
- 大厅卡片进详情；详情含封面、正文与可执行按钮
