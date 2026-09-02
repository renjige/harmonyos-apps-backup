# 知微集

当前 App 名称：**知微集**

魏文波 · HarmonyOS NEXT

把微知识收进来，分类整理、每日一知、建成个人知识库

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/wenbo-zhiweiji/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 快速启动

1. DevEco Studio 打开 **`app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机

## 产品要点（v1.1.0）

- 底栏：**工作台 | 成长 | 探索 | 我的**
- 工作台：今日学习进度、统计四格、快捷记知识/每日一知/知识库/收藏
- 成长：周度洞察、学习回顾、成就墙、学习计划、近七日分类图
- 探索：每日一知 + 金句集市
- 微知识：文字 / 配图 / 口述、六大分类、学习标签、收藏夹、知识库专题
- 数据默认本机，断网可用；登录仅可选
- 无支付、无独立隐私首屏（协议勾选在登录/注册页）

## 管理后台

https://saas16.qianqi.online/  租户 `wenbo-zhiweiji`

管理员：`admin@wenbo-zhiweiji.local` / `AdminPass#2026`

## API

App `ApiConfig`：`saas16.qianqi.online` · `TENANT_ID=wenbo-zhiweiji`
