# 云水间 — 功能清单

更新日期：2026年9月1日

## 核心业务

| 功能 | 状态 | 实现位置 |
|------|------|---------|
| 札记（新建/编辑/删除/详情 Hero） | [x] | `JournalHubPage` · `NoteEditorSheet` · `NoteDetailPane` |
| 心情（今日选择与本机保存） | [x] | `HomePage` · `YunMoodRow` · `YunLocalStore` |
| 灵感（快捷创建与编辑） | [x] | `JournalHubPage` · `CraftEditorSheet` · `YunCraftStore` |
| 计划（待办新建/编辑/完成） | [x] | `PlanHubPage` · `TodoEditSheet` |
| 清单（购物/家务/出行/学习等类型） | [x] | `PlanHubPage` · `YunListTemplateBar` |
| 目标（经验库 goal 类卡片与进度） | [x] | `YunCraftItem` · `CraftDetailPane` |
| 习惯打卡（连续/累计天数） | [x] | `YunHabitBlock` · `YunLocalStore` |
| 收藏（灵感卡片 pin） | [x] | `CraftDetailPane` · `YunCraftCard` |
| 经验库（经验/问题/方案/挑战分类） | [x] | `JournalHubPage` Craft 分段 |
| 主题册（按月/按年照片墙） | [x] | `ReviewHubPage` Album 分段 |
| 回顾（月度摘要 + 时光轴） | [x] | `ReviewHubPage` |
| 数据看板（首页/我的统计卡片） | [x] | `HomePage` · `MinePage` · `buildMonthlyReview` |
| 成就（连续记录、挑战进度、月度里程碑） | [x] | `HomePage` streak · `YunCraftItem` challenge · `ReviewHubPage` |

## 导航与交互

| 功能 | 状态 | 说明 |
|------|------|------|
| 五 Tab 底栏（首页/札记/计划/回顾/我的） | [x] | `MainTabPage` |
| 列表 → 详情 Overlay + tabBarHidden | [x] | `DetailShell` · `YunDetailNav` |
| 全屏编辑 Sheet | [x] | `NoteEditorSheet` · `TodoEditSheet` · `CraftEditorSheet` |
| 全局搜索札记/标签 | [x] | `SearchPage` |
| 那年今日卡片 | [x] | `YunOnThisDayCard` |
| 快捷入口（写札记/记灵感/新计划/打卡） | [x] | `HomePage` quickChips |
| 删除二次确认 + 顶部 Toast | [x] | `YunConfirmDialog` 各页 |
| 深色模式（杀进程保持） | [x] | `MinePage` · `YunLocalStore.setDarkMode` |

## 我的页

| 功能 | 状态 | 说明 |
|------|------|------|
| 生活统计看板（札记/连续/照片/打卡等） | [x] | `MinePage` AppStatCard |
| 标签管理（重命名/删除） | [x] | `MinePage` |
| 纪念日（添加/删除/回顾页倒计时） | [x] | `MinePage` · `ReviewHubPage` |
| 设置与隐私（协议全文 Overlay） | [x] | `MinePage` · `LegalDocOverlay` |
| 清除缓存 | [x] | `YunLocalStore.clearCache` |
| 清除全部数据（二次确认） | [x] | `YunLocalStore.clearAllData` |
| 撤回本机隐私标记 | [x] | `PrivacyService.revoke` |

## 合规与工程

| 功能 | 状态 | 说明 |
|------|------|------|
| 纯本地存储（Preferences + flush） | [x] | `YunLocalStore` |
| 无 INTERNET 权限 | [x] | `module.json5` requestPermissions: [] |
| 无登录/注册页（启动直达 Main） | [x] | `Index.ets` → `MainTabPage` |
| 无 AI 对话页 | [x] | 未接入主 Tab |
| 无系统提醒调度 | [x] | 本地-only 交付范围 |
| 协议五文件同步（LegalDocs + store 四 md） | [x] | 2026-09-01 已重写 |
| 内容影像 Hero/Banner/封面引用 | [x] | `HomePage` · `visual-assets.md` |
| 独立 Logo | [x] | `store/logo/` |

## 有意不做

| 功能 | 状态 | 说明 |
|------|------|------|
| 账号注册/登录 | — | 纯本地 App |
| 云端同步 / SaaS API | — | 无网络权限 |
| 生成式 AI / LLM | — | `FeatureFlags.LLM_ENABLED=false` |
| 第三方 SDK / 广告 | — | 见 `third-party-list.md` |
| 系统推送与代理提醒 | — | 本地-only 范围 |

## 验收步骤（手动）

1. 冷启动 → 直达首页，无登录墙
2. 写一条札记 → 首页时光轴可见 → 点进详情 → 编辑 → 删除确认
3. 计划页新建清单项 → 勾选完成 → 首页完成数更新
4. 习惯打卡 → 连续天数变化
5. 经验库新建目标/挑战 → 收藏 → 札记 Tab 筛选可见
6. 回顾页查看主题册与月度回顾
7. 我的 → 统计数字与操作一致
8. 设置与隐私 → 协议全文 → 清除缓存 / 撤回隐私有 Toast
9. 切换深色模式 → 杀进程重开仍保持
