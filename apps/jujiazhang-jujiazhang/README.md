# 居家章

当前 App 名称：**居家章**

居家章 · HarmonyOS NEXT

面向家庭的智能事务协同管理工具，家务分配、物品到期、备忘共享一站式完成

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/jujiazhang-jujiazhang/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 版本

- **1.7.0**（versionCode 1000010）：**冷启动默认「发现」Tab**；场景/指南详情页；总览页去除待办勾选；底栏顺序发现优先。
- **1.6.0**（versionCode 1000009）：「发现」升为底栏 Tab；计划并入生活；家庭手册。
- **1.5.0**（versionCode 1000008）：生活发现全屏页、有序指数 Hero、8 场景包、多模块引导种子、弱化纯待办首屏。
- **1.4.0**（versionCode 1000007）：针对 3.5 — 生活场景包（一键清单+计划+备忘）、能力导览条、本周报告、四页功能导览。
- **1.3.1**（versionCode 1000006）：修复登录后看板待办/家庭概览不显示；备忘详情编辑直达表单；意见反馈可提交。
- **1.3.0**（versionCode 1000005）：商业级丰富度升级 — 看板工作台、全局搜索、收藏、成长页、计划月历、家庭目标与动态联动。

## 快速启动

1. DevEco Studio 打开 **`app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可按需「清除缓存」
- 新用户登录后无测试数据；二级/三级页功能完整
- 浅色/深色模式文字与背景高对比
