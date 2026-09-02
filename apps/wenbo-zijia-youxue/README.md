# 自驾游学

当前 App 名称：**自驾游学**

魏文波 · HarmonyOS NEXT · 亲子自驾研学课堂

面向亲子家庭，把自驾沿途的自然与人文变成可学可记的研学课堂。游客可逛路线与百科；登录后可收藏、规划行程、写手账与打卡。无支付、无生成式对话。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 打开工程

DevEco Studio 打开 **`apps/wenbo-zijia-youxue/app/`**（不要打开上级 slug 目录）。

## 平台对接

- 域名：`https://saas16.qianqi.online/`
- API：`https://saas16.qianqi.online/api/v1`
- 租户：`wenbo-zijia-youxue`
- Admin：见 `store/admin-account.md`

## 目录

```
apps/wenbo-zijia-youxue/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可「清除缓存」
- 新用户登录后无测试数据；列表→详情→规划/问答/打卡闭环
- 浅色/深色模式文字与背景高对比
