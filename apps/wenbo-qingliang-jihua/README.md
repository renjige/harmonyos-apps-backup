# 清凉计划

当前 App 名称：**清凉计划**

魏文波 · HarmonyOS NEXT

在喧嚣中找回内心的清凉——你的智慧心灵休憩站

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/wenbo-qingliang-jihua/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 快速启动

1. DevEco Studio 打开 **`apps/wenbo-qingliang-jihua/app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机
3. API：`https://saas16.qianqi.online/api/v1`，租户 `wenbo-qingliang-jihua`

## 管理后台

- https://saas16.qianqi.online/ · 租户 `wenbo-qingliang-jihua`
- 账号见 `store/admin-account.md`

## 核心功能

- 首页：智慧语录 · 清凉指数 · 心情标签 · 心语 · 浏览全部语录
- 呼吸：4-7-8 / 4-4-4 / 4-8-4 全屏圆环引导
- 记录：心境日历 · 三色标记（心情/心语/呼吸）· 删除记录
- 我的：连续打卡 · 呼吸提醒 · 登录合并本机记录 · 设置与隐私
- 消息：机构通知（平台 API 动态拉取）

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可按需「清除缓存」
- 新用户登录后无测试数据；二级/三级页功能完整
- 浅色/深色模式文字与背景高对比
