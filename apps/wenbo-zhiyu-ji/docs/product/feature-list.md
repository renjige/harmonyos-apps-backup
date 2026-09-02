# 功能清单 — 知语集

## Tab 结构（3 Tab）

| Tab | 页面 | 功能 |
|-----|------|------|
| 首页 | HomePage | 每日智慧卡片、分类 Chip、按作者入口、搜索、收藏/分享、今日已阅、下拉刷新 |
| 语录库 | LibraryPage | 6 大分类筛选、作者筛选、搜索、分页（20/页）、下拉刷新、详情 |
| 我的 | MinePage | 收藏管理、深色模式、设置与隐私、登录/注册 |

## 二级 / 三级闭环

- 列表卡片 → QuoteDetailPane（Hero + 摘要 + 正文 + 收藏/分享 CTA）
- AuthorListOverlay → 按作者筛选语录库
- QuoteSearchOverlay → 全文搜索

## 平台对接

- `GET /biz/wisdom-hall/quotes` — 510 条语录（6 分类）
- `GET /messages` — 机构通知（我的 → 消息中心）
- `POST /auth/register|login` — 可选账号
- 收藏 / 今日已阅 — 本机 Preferences（FavoriteLocalService / ReadTodayService）

## 明确不做

- 无 AI 生成式对话（FeatureFlags.LLM_ENABLED = false）
- 无思录 / 思友圈 / 支付 / 会员
- 无独立隐私首屏（open_optional + 登录页协议勾选）
