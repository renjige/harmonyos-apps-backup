# 元素探索者 · 产品升级方案 v2.1

> 日期：2026-09-01  
> 工程：`apps/kexue-tansuozhe/`  
> 状态：**渐进式重构进行中 · 核心闭环已可用**

---

## 1. 产品定位

**元素探索者** = 身边事物探索 + 个人图鉴 + 探索任务 + 探索档案。

- 不是百科 / 文章阅读器 / 纯图鉴列表  
- Tagline：**世界很大，也藏在每天经过的地方。**  
- 核心闭环：**探索 → 发现 → 记录 → 分类 → 收藏 → 任务 → 图鉴 → 回顾 → 沉淀**

---

## 2. 当前问题（v1 → v2 已解决 / 仍待深化）

| 问题 | 状态 |
|------|------|
| 「元素」= 化学周期表 | ✅ 主流程改为生活探索；v1 化学页保留深链可选 |
| 无用户 UGC | ✅ 探索记录 CRUD + 图鉴笔记 |
| 纯浏览易 3.5 拒审 | ✅ 任务/挑战/收藏/专题/统计联动 |
| Tab 周期表百科感 | ✅ 改为 首页｜探索｜图鉴｜记录｜我的 |
| AppSpec/feature-list 旧文案 | ⚠️ feature-list 已 v2；AppSpec.json 待同步 |

---

## 3. 差异化方向

- **官方 87 则图鉴** + **用户自建发现** 双轨内容  
- **领域地图**（无定位）替代真实地图  
- **智慧探索 / 智慧回顾**（规则推荐，无 AI 字样）  
- **探索圆环** Logo · 深墨绿自然探索视觉  
- 首装 **3 条示例记录**（可删，标「示例」）

---

## 4. 功能架构

| 模块 | 实现文件 | 完成度 |
|------|----------|--------|
| 探索工作台 | `HomePage.ets` | ✅ |
| 探索中心 | `ExploreHubPage.ets` | ✅ |
| 官方/我的图鉴 | `AtlasPage.ets`, `AtlasDetailPane.ets` | ✅ |
| 探索记录 | `RecordPage.ets`, `RecordEditor/DetailOverlay` | ✅ |
| 收藏中心 | `FavoritesOverlay.ets` | ✅ |
| 探索专题 | `TopicsOverlay.ets` | ✅ |
| 每日任务 / 7日挑战 | `TaskBank`, `ChallengeTrack`, overlays | ✅ |
| 徽章 / 统计 / 时间轴 / 日历 | `Badges/Stats/Timeline/CalendarOverlay` | ✅ |
| 领域地图 | `DomainMapOverlay.ets` | ✅ |
| 智慧探索 | `ExplorationStore.wisdomTips()` | ✅ |
| 搜索 | `SearchOverlay.ets` | ✅ |
| 数据层 | `ExplorationStore.ets`, `AtlasCatalog.ets` | ✅ |

**P2 待做**：14/21/30 日挑战、专题内关联条目、标签管理页、收藏夹内移条目、周/月趋势图。

---

## 5. 页面结构

```
Index → MainTabPage
  ├─ 首页 HomePage（工作台）
  ├─ 探索 ExploreHubPage
  ├─ 图鉴 AtlasPage（官方 | 我的）
  ├─ 记录 RecordPage
  └─ 我的 MinePage
Overlays: 详情/编辑/搜索/统计/时间轴/日历/挑战/徽章/领域/收藏/专题
```

---

## 6. 导航结构

**底部 Tab（5）**：首页｜探索｜图鉴｜记录｜我的  

二级能力通过 Overlay + 我的页入口，不增加权限。

---

## 7. 首页设计（已实现）

今日探索 Hero → 我的探索数据 → 任务进度条 → 快捷四格 → 最近发现 → 领域点亮 → 探索回顾 → 智慧探索

---

## 8. 数据关联

| 动作 | 联动 |
|------|------|
| 新建发现 | 图鉴计数、时间轴、首页最近、统计 |
| 图鉴笔记/状态 | 我的图鉴、领域、徽章 |
| 完成任务 | 首页进度、徽章、时间轴 |
| 收藏 | 收藏中心、统计 |
| 创建专题 | 时间轴、徽章进度 |
| 连续打开 | streak、等级 |

存储：`ExplorationStore` + Preferences（`element_explorer_v2`）

---

## 9. UI 规范

- 色：深墨绿 `#1B4332`、植物青 `#52B788`、云雾白、暖金点缀  
- 摄影 Hero：`hero_explore.png`、`ambient_nature.png`  
- Symbol 功能图标 + 圆角卡片 + 大留白  
- `AppCard.pressable` 与内部按钮分离，避免点击拦截  

---

## 10. 华为 3.5 风险

| 风险 | 对策 |
|------|------|
| 纯信息展示 | 强制记录/任务/收藏/专题写操作 |
| 模板感 | 五 Tab 差异化结构 + 用户数据沉淀 |
| 假数据 | 仅 3 条标「示例」；统计来自真实行为 |
| 功能单一 | 图鉴+记录+任务+成长+回顾全链 |

---

## 11. 权限检查

`module.json5`：**0 新增系统权限**（无 INTERNET / 相机 / 定位 / 相册）

---

## 12. 开发优先级

| 优先级 | 项 | 状态 |
|--------|-----|------|
| P0 | 五 Tab + 记录 CRUD + 图鉴 87 + 任务/挑战 | ✅ |
| P0 | 收藏/专题/日历 + 首页工作台补全 | ✅ |
| P1 | AppSpec 同步、Logo 探索圆环终稿 | 进行中 |
| P2 | 多轨挑战、标签页、专题关联、趋势图 | 待做 |
| P3 | 化学进阶库深链（可选） | 待做 |

---

DevEco：`apps/kexue-tansuozhe/app/`  
门禁：`npm run gate:behavior -- apps/kexue-tansuozhe`
