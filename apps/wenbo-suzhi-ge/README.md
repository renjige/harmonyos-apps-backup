# 素知阁

当前 App 名称：**素知阁**

魏文波 · HarmonyOS NEXT

以质朴之心探寻智慧之境，口袋里的东方智慧阅读书房，每日精选语录与文萃分类浏览。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 三 Tab 信息架构

| Tab | 功能 |
|-----|------|
| 智慧阁 | 今日精选语录、换一换、收藏/分享、文萃推荐 |
| 文萃 | 五类主题浏览、本地搜索、详情 Hero+正文+收藏 |
| 我的 | 本地收藏、字号/深色模式、设置与隐私 |

## 平台对接

- **Admin**：https://saas16.qianqi.online/
- **API**：https://saas16.qianqi.online/api/v1
- **租户**：`wenbo-suzhi-ge`
- **管理员**：`admin@wenbo-suzhi-ge.local` / `AdminPass#2026`
- **超管**：`super@platform.local` / `SuperPass#2026`

## DevEco 工程

1. DevEco Studio 打开 **`apps/wenbo-suzhi-ge/app/`**
2. Sync Project → Build → 运行

`ApiConfig` 已指向 `saas16.qianqi.online`，`TENANT_ID=wenbo-suzhi-ge`。

## 合规要点

- `open_optional`：游客可直接使用全部阅读功能；收藏存本机 Preferences
- 无独立隐私首屏；协议勾选在登录/注册页（可选登录）
- 无 AI 生成式对话（`FeatureFlags.LLM_ENABLED=false`）
- 无支付、无社交圈；与「思见堂」差异化（3 Tab 纯阅读）

## 演示账号（仅 store/demo-account.md，客户端不展示）

见 `store/demo-account.md`
