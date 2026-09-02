# 《App 丰富度升级方案》— 纸上方 v1.1

> 目标：从「简易书摘记录」升级为「有持续使用价值的个人阅读工作台」  
> 原则：渐进式增强 · 真实数据闭环 · 0 新增系统权限 · 保留纸上方差异化  
> 状态：**方案阶段，待确认后实施**

---

## 一、现有项目分析（Step 1）

### 1.1 产品定位

| 项 | 现状 |
|---|---|
| 名称 | 纸上方（PaperWise） |
| 核心 | 纸质书摘录 → 分类整理 → 主动回顾 → 阅读成长 |
| 用户 | 爱读纸质书、希望沉淀金句与感悟的读者 |
| 存储 | 本机 Preferences，无云同步（符合无新权限约束） |
| 差异化 | 三 Tab 含独立「添加」、智慧分类本地规则、抽卡回顾、墨蓝纸页视觉 |

### 1.2 已有功能

- **内容层**：书摘 CRUD（书名/页码/摘录/感悟/封面）
- **操作层**：全文搜索、按书筛选、智慧分类、左滑收藏/删除
- **记录层**：摘录时间线（8 条）、书籍档案、同书摘录
- **成长层（初版）**：今日智慧、抽卡回顾、阅读足迹、本月报告、阅读目标进度条、标签云
- **个性化**：收藏、CSV 导出、金句卡片复制、深色模式
- **合规**：隐私撤回、登录可选、无 CAMERA

### 1.3 页面结构

```
Index → MainTabPage
  Tab0 书房 HomePage（列表 + 搜索 + 书籍档案）
  Tab1 添加 CapturePage
  Tab2 智慧回顾 ReviewPage
  Overlay: NoteDetailPane / CapturePage(edit) / MinePage
```

### 1.4 数据模型

- 持久化：`BookNote` + `dark_mode` + `today_recall` + `month_goal`
- 衍生：`BookProfile`、`MonthlyReadingReport`、`TimelineItem`、`ReadingInsight` 等（运行时计算）

### 1.5 跳转关系

列表/今日智慧/时间线/标签结果 → **详情** → **编辑**（已修复分类刷新）  
**缺口**：无二级「计划详情」「专题详情」「成就详情」；相关书摘切换无返回栈。

### 1.6 当前问题（审核 & 产品）

| # | 问题 | 严重度 |
|---|---|---|
| P1 | 华为 3.5：仍被判定为「简易书摘记录」，层次与持续使用动机不足 | **Block** |
| P2 | 首页偏「列表页」，缺少工作台式信息密度（今日进度/快捷/摘要） | 高 |
| P3 | 「成长」能力分散在回顾 Tab 内，缺独立**计划 / 打卡 / 成就**闭环 | 高 |
| P4 | 时间轴仅 8 条，非完整个人阅读史 | 中 |
| P5 | 收藏无「专题/书架」组织，用户无法自建内容集合 | 中 |
| P6 | 统计缺可视化（分类占比、趋势），月报偏文字 | 中 |
| P7 | `paper_texture` 影像未引用；部分脚手架页残留 | 低 |
| P8 | 运营者/版本号文档不一致 | 低（合规警告） |

### 1.7 不属于的问题（避免误改）

- ❌ 不做 OCR / 相机扫页（需新权限）
- ❌ 不做推送提醒（需 REMINDER 权限，本版不加）
- ❌ 不改为四 Tab 堆砌空页
- ❌ 不删除「添加」独立 Tab（差异化要点）

---

## 二、产品重新定位（Step 2）

### 2.1 一句话

> **纸上方 = 纸质阅读者的个人阅读工作台**  
> 不只是「记一条摘录」，而是：**记录 → 归档 → 计划 → 打卡 → 回顾 → 看见成长**。

### 2.2 与 3.7「记事本类」的区隔

| 普通记事本 | 纸上方 |
|---|---|
| 任意文本 | 结构化书摘（书名/页码/摘录/感悟） |
| 无回顾机制 | 抽卡回顾 + 今日智慧 + 周/月复盘 |
| 无阅读语境 | 书籍档案、同书摘录、专题书架 |
| 无成长反馈 | 阅读计划、打卡连续、成就徽章 |
| 平铺列表 | 工作台首页 + 四层信息架构 |

---

## 三、功能地图（Step 3）

覆盖提示词 A～L 中 **10 项**（与阅读主题强相关，非机械凑数）：

| 代号 | 模块 | 类型 | 用户场景 |
|---|---|---|---|
| F1 | **书房工作台首页** | A 首页工作台 | 打开 App 即见今日阅读进度、数据摘要、快捷入口 |
| F2 | **阅读计划** | F 计划系统 | 为某本书设「本月摘录 N 条」或「读完前摘录 20 条」 |
| F3 | **每日阅读打卡** | G 打卡系统 | 今日是否阅读/摘录，连续天数，补一句今日心得 |
| F4 | **专题书架** | K 主题系统 | 用户自建「哲学专题」「职场书单」聚合多条书摘 |
| F5 | **完整阅读时间轴** | H 时间轴 | 按日/月浏览全部摘录历史，可进详情 |
| F6 | **数据统计中心** | I 数据统计 | 分类占比、周趋势、书籍 Top3、完成率（真实计算） |
| F7 | **成就徽章墙** | J 成就系统 | 首次摘录、连续 7 天、50 条书摘、复习达人等 |
| F8 | **周/月回顾页** | L 回顾系统 | 本周新增、最常读分类、复习完成率、精选金句 |
| F9 | **收藏与筛选增强** | C + E | 收藏 Tab 内二级页；多条件筛选（标签+时间+书籍） |
| F10 | **详情栈与关联阅读** | 层级 | 同书/同专题摘录切换保留返回 |

**保留不动**：添加书摘、智慧分类、抽卡回顾、CSV 导出、隐私合规、相册封面（无新权限）。

---

## 四、信息架构 & 页面结构（Step 4）

### 4.1 底部导航（三 Tab，改名 + 内涵升级）

| Tab | 现名 | **新名** | 职责 |
|---|---|---|---|
| 0 | 书房 | **书房** | 工作台首页 + 书摘列表 + 搜索筛选 |
| 1 | 添加 | **添加** | 不变，保持差异化 |
| 2 | 智慧回顾 | **成长** | 统计 + 回顾 + 成就 + 计划进度 + 抽卡 |

> 不机械套用「首页｜探索｜计划｜记录｜我的」五 Tab；**计划/打卡/专题**以书房与成长 Tab 内二级页呈现，设置仍从书房齿轮进入。

### 4.2 四层页面结构

```
【一级 · Tab 页】
  书房工作台 / 添加 / 成长

【二级 · 全屏 Overlay】
  书摘详情 / 阅读计划列表 / 专题书架列表 / 完整时间轴 / 筛选结果 / 周回顾·月回顾 / 成就墙 / 设置

【三级 · 全屏 Overlay】
  编辑书摘 / 新建·编辑计划 / 新建·编辑专题 / 计划详情 / 专题详情

【操作层】
  打卡确认 / 完成计划任务 / 解锁成就 Toast / 删除二次确认
```

### 4.3 新增页面清单

| 页面/组件 | 路径建议 | 说明 |
|---|---|---|
| `StudyWorkbench` | `components/study/StudyWorkbench.ets` | 书房顶部工作台区块（嵌入 HomePage） |
| `ReadingPlanListPane` | `components/plan/ReadingPlanListPane.ets` | 计划列表二级页 |
| `ReadingPlanDetailPane` | `components/plan/ReadingPlanDetailPane.ets` | 计划详情 + 关联书摘 + 完成 |
| `ReadingPlanEditor` | `components/plan/ReadingPlanEditor.ets` | 新建/编辑计划 |
| `CheckInCard` | `components/study/CheckInCard.ets` | 每日打卡卡片（书房 + 成长） |
| `TopicShelfListPane` | `components/topic/TopicShelfListPane.ets` | 我的专题书架 |
| `TopicDetailPane` | `components/topic/TopicDetailPane.ets` | 专题内书摘列表 |
| `TopicEditor` | `components/topic/TopicEditor.ets` | 新建/编辑专题 |
| `FullTimelinePane` | `components/study/FullTimelinePane.ets` | 完整时间轴（按日分组） |
| `StatsCenterPane` | `components/study/StatsCenterPane.ets` | 统计图表中心 |
| `AchievementWallPane` | `components/study/AchievementWallPane.ets` | 成就徽章墙 |
| `WeeklyRecapPane` | `components/study/WeeklyRecapPane.ets` | 本周回顾 |
| `FilterResultPane` | `components/note/FilterResultPane.ets` | 组合筛选结果 |
| `DetailNavStack` | `services/DetailNavStack.ets` | 详情 id 栈，支持返回 |

---

## 五、数据模型升级（Step 5）

### 5.1 新增持久化实体

```typescript
// ReadingPlan — 阅读计划
class ReadingPlan {
  id: string
  title: string           // 如「读完《XX》摘录 20 条」
  bookName: string        // 关联书名（可空=通用计划）
  targetCount: number     // 目标摘录条数
  doneCount: number       // 已完成（自动统计关联书摘）
  deadline: number        // 截止日期 ms，0=无
  status: 'active' | 'done' | 'archived'
  createdAt: number
  updatedAt: number
}

// DailyCheckIn — 每日打卡
class DailyCheckIn {
  dateKey: string         // YYYYMMDD
  checked: boolean
  moodNote: string        // 可选一句今日心得
  excerptCount: number    // 当日新增摘录数（自动）
}

// TopicShelf — 用户专题
class TopicShelf {
  id: string
  title: string           // 如「2026 哲学书单」
  summary: string
  noteIds: string[]       // 关联 BookNote.id
  coverNoteId: string     // 封面取自某条书摘
  createdAt: number
  updatedAt: number
}

// Achievement — 成就（解锁时间持久化）
class AchievementRecord {
  id: string              // first_note / streak_7 / notes_50 ...
  unlockedAt: number
}

// ActivityEvent — 统一时间轴事件（可选，或由 BookNote+CheckIn 聚合）
class ActivityEvent {
  type: 'note' | 'checkin' | 'plan_done' | 'achievement'
  refId: string
  at: number
  label: string
}
```

### 5.2 Preferences 键扩展

| Key | 内容 |
|---|---|
| `reading_plans` | ReadingPlan[] 序列化 |
| `daily_checkins` | DailyCheckIn[] |
| `topic_shelves` | TopicShelf[] |
| `achievements` | AchievementRecord[] |

### 5.3 数据关联

```
BookNote ──┬── bookName ──→ ReadingPlan.bookName（自动计入 doneCount）
           ├── noteIds ────→ TopicShelf.noteIds
           └── tags ───────→ Stats 分类统计

DailyCheckIn.excerptCount ← 当日 BookNote.createdAt 计数

Achievement ← 监听 NoteStore / CheckIn / Plan / Recall 变化后 evaluate
```

### 5.4 新增 Service

- `PlanStore.ets` — 计划 CRUD + 进度同步
- `CheckInStore.ets` — 打卡读写 + 连续天数
- `TopicStore.ets` — 专题 CRUD + 书摘关联
- `AchievementService.ets` — 条件判定 + 解锁 + Toast
- `StatsService.ets` — 聚合 Chart 数据
- `ActivityService.ets` — 统一时间轴聚合
- `DetailNavStack.ets` — 详情导航栈

---

## 六、首页布局方案（Step 6 · 书房工作台）

自上而下五层（有数据时全展示，无数据时精致空态）：

```
┌─────────────────────────────────────┐
│ 纸上方                    ⚙️        │
├─────────────────────────────────────┤
│ 【Layer 1 · 今日阅读进度】           │
│  本月目标 ████████░░ 8/10           │
│  今日打卡 ○ 未打卡 → 点击打卡        │
├─────────────────────────────────────┤
│ 【Layer 2 · 四格数据】               │
│  书摘128 | 书籍12 | 收藏42 | 连续7天│
├─────────────────────────────────────┤
│ 【Layer 3 · 快捷入口】               │
│  +添加  📋计划  📚专题  📊统计       │
├─────────────────────────────────────┤
│ 【Layer 4 · 最近动态】               │
│  最近 3 条书摘卡片 → 详情            │
├─────────────────────────────────────┤
│ 【Layer 5 · 搜索 + 书籍筛选 + 列表】  │
│  （保留现有列表能力）                 │
└─────────────────────────────────────┘
```

背景：`paper_texture` 轻量铺底或 Section 分隔，消除 Demo 空旷感。

---

## 七、成长 Tab 布局（原智慧回顾升级）

```
今日智慧 Banner
ReviewStatBar（四格统计）
每日打卡状态 + 本周打卡日历
阅读计划进度（进行中计划 Top2 → 计划详情）
抽卡回顾入口
本周回顾 / 本月回顾 入口
完整时间轴入口
成就墙入口（已解锁 N/总 M）
标签云 + 收藏（保留）
```

---

## 八、UI 视觉方向（Step 7）

| 维度 | 方向 |
|---|---|
| 关键词 | 墨蓝纸页 · 编辑书房 · 轻量高级 · 鸿蒙 Symbol |
| 色彩 | 延续 `#2C3E6B` + `#D4A84B`，禁止紫 AI 光效 |
| 卡片 | 12vp 圆角，浅阴影，Hero 摄影 + scrim |
| 图表 | 简易柱状/环形成就进度（`AppChart` 或自绘 Column，无新依赖） |
| 密度 | 首页 ≥5 个可视区块；成长 Tab ≥6 区块 |
| 空态 | 插画 `empty_desk` + 引导文案 + 主 CTA |
| 成就 | 徽章圆形 + 未解锁灰态，解锁时顶部 Toast |

---

## 九、用户使用闭环（Step 8）

```
浏览：书房工作台看见进度与最近摘录
  ↓
使用：添加书摘 → 自动智慧分类建议 → 计入今日打卡与计划进度
  ↓
管理：加入专题书架 / 收藏 / 设阅读计划
  ↓
回顾：抽卡复习 + 周/月复盘 + 完整时间轴
  ↓
成长：统计图表 + 成就解锁 + 连续打卡
  ↓
沉淀：CSV 导出 / 金句复制 / 专题合集
```

**一次操作的联动示例**：

保存书摘 → 刷新工作台四格 → 计划 doneCount+1 → 打卡 excerptCount+1 → 评估成就 → noteEpoch 广播 → 列表/详情/统计同步。

---

## 十、华为 3.5 / 3.7 合规检查（Step 9）

| 指南 | 对策 |
|---|---|
| 3.5 非纯展示 | 用户自建书摘/计划/专题；统计来自真实本地数据 |
| 3.5 非单一列表 | 工作台 + 计划 + 专题 + 成就 + 回顾 多模块 |
| 3.5 有创意 | 抽卡回顾 + 书籍档案 + 专题书架 + 阅读计划组合 |
| 3.7 非简易记事本 | 阅读垂直闭环，结构化书摘 + 复习 + 成长体系 |
| 3.1 功能完整 | 所有入口可点、有反馈、无「即将上线」 |
| 权限 | **0 新增**；仍仅 INTERNET（登录可选） |

**审核说明建议文案**：

> 纸上方是面向纸质阅读者的个人阅读工作台，提供书摘记录、阅读计划、每日打卡、专题书架、抽卡回顾、数据统计与成就成长体系，帮助用户持续沉淀与复习读过书籍的精华内容，非简单记事本或单一列表应用。

---

## 十一、实施顺序（Step 10 · 开发排期）

| 阶段 | 内容 | 预估 |
|---|---|---|
| **S1** | 数据层：PlanStore / CheckInStore / TopicStore / AchievementService / StatsService | 1 |
| **S2** | DetailNavStack + 详情返回栈 | 0.5 |
| **S3** | 书房工作台 UI（StudyWorkbench + CheckInCard） | 1 |
| **S4** | 计划模块（列表/详情/编辑 + 进度联动） | 1 |
| **S5** | 专题书架（列表/详情/编辑 + 详情页「加入专题」） | 1 |
| **S6** | 成长 Tab 重构 + StatsCenter + FullTimeline + WeeklyRecap | 1 |
| **S7** | 成就墙 + 解锁联动 Toast | 0.5 |
| **S8** | 筛选增强 + paper_texture 视觉 + 清理脚手架残留页 | 0.5 |
| **S9** | 协议/feature-list/differentiation 同步 + gate + Release | 0.5 |
| | **合计** | **~7** |

版本建议：**1.1.0**（`1000100`）

---

## 十二、验收标准（Step 16）

### 产品

- [ ] 首页 ≥5 个功能区块，非纯列表
- [ ] 计划/打卡/专题/成就/统计 均可创建、查看、有反馈
- [ ] 保存书摘后 ≥3 个模块数据同步更新
- [ ] 新用户各模块空态可引导首操作

### UI

- [ ] 无大片空白主屏
- [ ] `paper_texture` 至少 1 处引用
- [ ] 深色模式对比度合格

### 交互

- [ ] 详情栈可返回
- [ ] 删除/归档二次确认 + Toast
- [ ] 成就解锁有感知

### 审核

- [ ] gate:behavior pass
- [ ] 无新权限
- [ ] 截图可展示：工作台 / 计划 / 专题 / 成就 / 抽卡回顾

---

## 十三、待你确认后进入编码

请确认：

1. **Tab 命名**：「智慧回顾」改为「成长」是否 OK？
2. **计划默认**：是否默认「本月 10 条摘录」计划（可改）？
3. **专题**：是否允许一条书摘属于多个专题？（建议：允许）

确认后即按 S1→S9 顺序实施，不推倒重来。
