# 时光档案

**公司**：时光印记  
**App 名称**：时光档案  
**定位**：把重要时刻，整理成一生的档案

纯本地个人经历整理工具：档案 + 时间节点 + 分类标签 + 时间轴 + 阶段回顾 + 统计。无需登录、无网络、无 SaaS、无内购。

## DevEco 工程路径

```
apps/shiguang-dangan/app/
```

在 DevEco Studio 中打开上述 `app/` 目录（不是上级 slug 目录）。

## 上架图标

- **华为应用市场上传**：`store/logo/preview-1024.png`
- 工程图标：`app/AppScope/resources/base/media/app_icon.png`

## 五 Tab 结构

| Tab | 页面 | 功能 |
|-----|------|------|
| 首页 | HomePage | 今日状态、计划进度、四快捷入口、往年今日、数据摘要 |
| 档案 | ArchiveLibraryPage | 搜索、分类/收藏筛选、待整理 |
| 计划 | PlanPage | 今日任务、生活计划、目标、习惯打卡 |
| 回顾 | ReviewPage | 日历矩阵、时间轴、日/周/月/年回顾、**数据中心** |
| 我的 | MinePage | **主题册/人生清单/经验库/收藏中心**、成就、标签、导出、设置与隐私 |

## 核心闭环

1. 创建档案（多步向导）
2. 添加时间节点（发生了什么 / 为何重要 / 感受 / 改变）
3. 档案库浏览 → 详情 Hero + 时光轴
4. 全局时间轴筛选浏览
5. 我的 → 时光回顾 + JSON 导出

## 数据存储

全部数据保存在本机 `Preferences`（`ArchiveStore`），不上传云端。

## 运营者

魏文波（见 `AppSpec.json` · `store/privacy-policy.md`）

## 行为门禁

```bash
npm run gate:behavior -- apps/shiguang-dangan
```

## 视觉资产

见 `docs/product/visual-assets.md`：

- `hero_ambient.png` — 总览/详情 Hero
- `empty_archive.png` — 空态插图
