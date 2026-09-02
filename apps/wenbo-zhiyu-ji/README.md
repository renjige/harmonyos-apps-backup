# 知语集

**公司**：魏文波  
**App 名称**：知语集  
**定位**：轻量级智慧语录应用，每日精选金句浏览收藏分享，留白中的知性阅读体验

## 功能概览

| Tab | 功能 |
|-----|------|
| 首页 | 每日智慧卡片、分类导航、按作者、收藏/分享、下拉刷新 |
| 语录库 | 6 大分类浏览、作者筛选、搜索、分页加载、下拉刷新 |
| 我的 | 收藏管理、消息中心、深色模式、设置与隐私（含清单） |

## DevEco 工程

打开目录：`apps/wenbo-zhiyu-ji/app/`

## 平台 API

- Admin：`https://saas16.qianqi.online/`
- API：`https://saas16.qianqi.online/api/v1`
- 租户 ID：`wenbo-zhiyu-ji`

## 上架图标

- 工程内：`app/AppScope/resources/base/media/app_icon.png`
- 交付预览：`store/logo/preview-1024.png`

## 审核说明

- 准入模式：`open_optional`（游客可浏览；协议勾选在登录/注册页，无独立隐私首屏）
- 无 AI 生成式对话（`FeatureFlags.LLM_ENABLED = false`）
- 栏目语录走平台 `/biz/wisdom-hall/quotes` API（510 条 · 6 分类）
- 收藏与今日已阅：本机 Preferences 持久化

## 演示账号

见 `store/demo-account.md`（仅审核使用，客户端不展示）
