# 智阅册

当前 App 名称：**智阅册**

魏文波 · HarmonyOS NEXT

帮助知识工作者完成阅读、摘录、整理与回顾的完整知识管理闭环

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/wenbo-zhiyue-ce/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 快速启动

1. DevEco Studio 打开 **`app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机

## 交付信息

- DevEco 打开：`apps/wenbo-zhiyue-ce/app/`
- 上架图标：`apps/wenbo-zhiyue-ce/store/logo/preview-1024.png`
- Admin：https://saas16.qianqi.online/ 租户 `wenbo-zhiyue-ce`
- 租户管理员：`admin@wenbo-zhiyue-ce.local` / `AdminPass#2026`
- App API：`https://saas16.qianqi.online/api/v1` · `TENANT_ID=wenbo-zhiyue-ce`

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可按需「清除缓存」
- 新用户登录后无测试数据；二级/三级页功能完整
- 浅色/深色模式文字与背景高对比
- 审核修复（3.1 / 3.5）：导入中文标题解码；PDF 沙箱预览；自检写入节律计划文稿与摘录；收藏与深色模式即时刷新。AGC 粘贴文案见 `store/agc-review-reply.md`
