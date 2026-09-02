# 清凉出行

当前 App 名称：**清凉出行**

魏文波 · HarmonyOS NEXT

用清凉指数与树荫路线，帮通勤族在炎热天气里选更舒适的出行方式

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/wenbo-qingliang-chuxing/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 快速启动

1. DevEco Studio 打开 **`apps/wenbo-qingliang-chuxing/app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机
3. 客户端 API：`https://saas16.qianqi.online/api/v1`，租户 `wenbo-qingliang-chuxing`

## 管理后台

- 地址：https://saas16.qianqi.online/
- 租户管理员：`admin@wenbo-qingliang-chuxing.local` / `AdminPass#2026`
- 超管：`super@platform.local` / `SuperPass#2026`

演示账号仅见 `store/demo-account.md`，登录页不预填。

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可按需「清除缓存」
- 新用户登录后无测试数据；二级/三级页功能完整
- 浅色/深色模式文字与背景高对比
