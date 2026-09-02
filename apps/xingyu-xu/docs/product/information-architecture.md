# 星隅叙 · 信息架构

底栏五 Tab：

1. **星隅** `HomePage` — Hero、数字、快捷入口、最近片段、今日回望
2. **叙事** `NarrativePage` — 档案列表、筛选、搜索、新建
3. **主题** `ThemeSpacePage` — 主题星域卡片
4. **回望** `ReviewPage` — 星轨 / 智慧回望 / 年册 / 数据
5. **我的** `MinePage` — 星徽、收藏、标签、设置与隐私

详情一律走 `MainTabPage` 顶层 Overlay + `DetailShell` + `*DetailPane`，打开时隐藏底栏。
