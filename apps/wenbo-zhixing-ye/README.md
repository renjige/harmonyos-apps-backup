# 知行页

当前 App 名称：**知行页**

魏文波 · HarmonyOS NEXT 学习工具：把知识沉淀为卡片与图谱，再转化为计划、习惯与行动日志。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/wenbo-zhixing-ye/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 快速启动

1. DevEco Studio 打开 **`app/`** 目录  
2. Sync Project → Build → 运行到模拟器或真机  
3. API：`https://saas16.qianqi.online/api/v1`，租户 `wenbo-zhixing-ye`

## Admin

- 后台：https://saas16.qianqi.online/  
- 演示账号见 `store/demo-account.md`（不要出现在客户端）

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页  
- 禁止「删除业务数据」按钮；可「清除缓存」  
- 新用户无测试数据；列表→详情→编辑/删除完整  
- 浅色/深色高对比；无支付；无生成式对话
