# 自然探索志

当前 App 名称：**自然探索志**（Nature Quest）

魏文波 · HarmonyOS NEXT · 自然与户外探索内容平台

探索自然之美，记录户外足迹 —— 您的随身自然指南。

## 上架图标（华为应用市场请用这个）

- **`store/logo/preview-1024.png`** ← 上架主图标 1024×1024
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## DevEco 工程

打开目录：**`apps/wenbo-ziran-tansuo-zhi/app/`**

Sync → Build → 运行到模拟器或真机（HarmonyOS 5.0+）

## 功能概览

| Tab | 功能 |
|-----|------|
| 发现 | 分类浏览、智慧推荐、探索点瀑布流、季节专题 Banner |
| 记录 | 本机探索日志 CRUD、时间轴、足迹地图 |
| 百科 | 植物/动物/地质/天文/户外技巧、搜索 |
| 我的 | 统计、收藏、设置与隐私 |

## 平台 API

- Admin：`https://saas1.qianqi.online/`
- API：`https://saas1.qianqi.online/api/v1`
- 租户：`wenbo-ziran-tansuo-zhi`
- Admin 账号见 `store/admin-account.md`

## 合规要点

- 首次启动隐私同意弹窗；同意前不采集信息
- 无支付、无生成式文本功能
- 探索记录默认本机存储；登录后可同步收藏
- 演示账号仅 `store/demo-account.md`，客户端不展示

## 视觉资产

清单见 `docs/product/visual-assets.md`（13 张内容影像 + Logo）
