# 视觉方向 — 思维匣（工厂 UI V2）

## 设计依据

- **工厂规则**：`harmonyos-components.mdc` §V2 · `factory-ui-v2-visual-refresh.md`
- **产品类型**：`ops-tool` 偏工具，但首页采用 content-commerce V2 构图（沉浸 Hero + Editorial Banner）
- **品牌气质**：深空蓝 `#1A2332` + 纸面暖灰 `#F7F5F0` + 琥珀点缀；木匣/纸面摄影，非紫调备忘或后台 KPI 模板

## 记忆点（第二轮）

**纸笺从匣口滑出**：速记工作台以纸卡叠在全宽 Hero 底部（负边距），顶部一条琥珀金短杠，像从木匣抽出的便签。标签芯片改为直角纸签而非胶囊。导图分组是「抽屉」：左侧琥珀金脊线 + 纸面卡片，禁止整条海军蓝标题栏。

1. **唯一视觉中心**：全宽沉浸 Hero **240vp**，顶边对齐，底部 F4 渐变遮罩 + `titleL` 品牌语 + 主 CTA「此刻记下」
2. **Editorial Banner**：2 帧 Swiper（速记 / 思考工坊），16:9 感，露出下一帧 12vp
3. **指标区**：横向滑动 **MetricChip**（灵感/已加工/拆解/笔记/观点），禁止三等分 KPI 横排
4. **快捷入口**：≤2 个 Pill（思考工坊 / 标签导图），禁止 2×2 Symbol 宫格
5. **区块标题在卡片外**：`SectionHeader` + 间距 `Theme.space.section (32vp)`
6. **ListCard**：80vp 左封面 + `radius.xl` + 内边距 `s5`

## 导航（F1-V2）

- **悬浮 Tab Dock**：左右 `pageX`、底 12vp、高 56、圆角 `sheet`、`surfaceGlass` + `BlurStyle.Thin`
- 选中态：48×28 胶囊底 + 显式 `AppIcon.color`
- 内容区底部留白 **88vp**，避免被 Dock 遮挡

## 各 Tab 要点

| Tab | V2 处理 |
|-----|---------|
| 灵感 | 上述首页构图 |
| 思考 | 大图 + **单一大数字**（连续天 display）+ MetricChip + 工具 ListCard |
| 导图 | 保留业务逻辑，区块标题外置（后续迭代） |
| 标签 | 保留业务逻辑，列表复用 ThoughtCardView |
| 我的 | 沉浸头图 + MetricChip 横滑 + Section 分区（洞察 / 数据设置） |

## 对比度（F3/F4）

- Hero/Banner 叠字必须三层 scrim，禁止 opacity 降对比度
- 浅色标签字用 `labelOnContainer` / `brandPrimary`，禁止 `brandAccent` 作小字

## 与 avoidSlugs 差异

- 非「小 Hero 168vp 嵌 pageX 圆角卡」旧脚手架
- 非三格等宽统计 + 堆叠 s4 卡片
- 非贴底平 Tab + 顶部分割线

## 影像引用

- Hero / Banner / 空态 / 列表默认封面均 `Image($r('app.media.*'))`
- 清单见 `docs/product/visual-assets.md`
