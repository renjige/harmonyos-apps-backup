# 儿童绘坊

当前 App 名称：**儿童绘坊**

魏文波 · HarmonyOS NEXT · 3–8 岁创意绘画启蒙

孩子的第一间数字画室——自由涂鸦、魔法贴纸、创意工坊与本机画廊，完全免费、无广告、无账号。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`

## DevEco 工程

打开目录：`apps/wenbo-ertong-huifang/app/`

## 核心功能

| 模块 | 说明 |
|------|------|
| 自由涂鸦 | Canvas 五种笔刷、24 色、撤销/橡皮/保存 |
| 魔法贴纸 | 12 款可爱贴纸，点画布即可贴，支持撤销与保存 |
| 创意工坊 | 点对点、拇指画、形状拼贴、轨迹 |
| 我的画廊 | 本机网格展示、重命名、删除 |
| 智慧引导 | 预设简笔画步骤（非 AI） |

## 合规要点

- 无独立隐私首屏；保存作品时同意协议
- 无 INTERNET 权限；数据仅存本机
- 无 AI 字样；FeatureFlags.LLM_ENABLED = false

## Slug / 租户

- slug: `wenbo-ertong-huifang`
- Admin: https://saas16.qianqi.online/
