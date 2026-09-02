# 慧忆册

当前 App 名称：**慧忆册**

慧忆智能 · HarmonyOS NEXT

智慧记忆管家，帮助用户极简记录生活信息并通过智能标签归类回顾。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/huiyi-ce/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 快速启动

1. DevEco Studio 打开 **`app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机
3. 平台 API：`https://saas16.qianqi.online/api/v1`，租户 `huiyi-ce`

## 功能

- 四 Tab：记录 / 归类 / 回顾 / 我的
- 本机记忆持久化；模板速记、智慧标签、记忆册、按日回顾与待温习（非生成式对话）
- 收藏、置顶、归档、导出 txt、深色模式、登录注册与隐私撤回

## Admin

https://saas16.qianqi.online/  租户管理员密码见同事手册（`AdminPass#2026`）

演示账号仅 `store/demo-account.md`，客户端不展示。

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可「清除缓存」
- 新用户无测试记忆；列表→详情→编辑/删除完整
- 浅色/深色文字与背景高对比
