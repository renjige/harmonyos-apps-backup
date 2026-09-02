# 脑力探秘

当前 App 名称：**脑力探秘**

魏文波 · HarmonyOS NEXT

通过游戏化每日训练探索记忆、专注、反应与逻辑潜能，生成脑力图谱并追踪成长轨迹

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/wenbo-naoli-tanmi/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 快速启动

1. DevEco Studio 打开 **`app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机

## 平台

- API：`https://saas16.qianqi.online/api/v1`
- 租户：`wenbo-naoli-tanmi`
- Admin：https://saas16.qianqi.online/ （`admin@wenbo-naoli-tanmi.local` / `AdminPass#2026`）

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可按需「清除缓存」
- 新用户登录后无测试数据；二级/三级页功能完整
- 浅色/深色模式文字与背景高对比
- 界面不出现「AI」字样；测评叫脑力图谱 / 智慧指数
