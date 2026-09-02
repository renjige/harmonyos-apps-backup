# 亲子乐拼

当前 App 名称：**亲子乐拼**

魏文波 · HarmonyOS NEXT · 教育（儿童益智拼图陪伴）

面向 3 到 8 岁儿童与家长：点主题大卡 → 选一幅图 → 4/9/16 块点选入格 → 亲子轮流 → 本机成长记录。无广告、无支付、无生成式对话。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## DevEco

打开目录：**`apps/wenbo-qinzi-lepin/app/`**（不要打开上级 slug 目录）

## 平台对接

- 站点：`https://saas16.qianqi.online/`
- API：`https://saas16.qianqi.online/api/v1`
- 租户：`wenbo-qinzi-lepin`
- 图库：`GET /biz/kids-jigsaw/themes|jigsaws|medals|guides`
- 进度：本机 Preferences，新用户成长列表为空

## 目录

```
apps/wenbo-qinzi-lepin/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可清除缓存、重置本机拼图记录
- 新用户成长/完成记录为空；栏目图库走平台 API
- 浅色/深色模式文字与背景高对比
