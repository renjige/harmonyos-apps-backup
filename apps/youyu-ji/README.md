# 悠隅纪

当前 App 名称：**悠隅纪**

悠隅生活 · HarmonyOS NEXT

静谧一隅，温柔记录生活美好瞬间的私密智慧空间

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/youyu-ji/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 快速启动

1. DevEco Studio 打开 **`app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机

## 产品要点

- 轻量生活记录：心情五态 + 自定义标签 + 可选一张配图
- 时光胶囊随机回顾；纪事看总数 / 连续天 / 本月
- 数据默认本机，断网可用；登录仅可选
- 无支付、无生成式对话、无独立隐私首屏

## 管理后台

https://saas16.qianqi.online/  租户 `youyu-ji`

## API

App `ApiConfig`：`saas16.qianqi.online` · `TENANT_ID=youyu-ji`

