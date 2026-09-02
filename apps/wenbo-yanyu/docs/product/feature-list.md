# 功能清单 · 研语 v1.2.0

## Tab 页（工作台架构）

- [x] **首页**（HubPage）— 周目标进度、今日思考、四宫格数据、快捷操作、最近活动、推荐表达
- [x] **表达**（ExpressPage）— 润色/摘要 Segment；场景成稿、表达诊断、范例收藏入口
- [x] **研究**（ResearchPage）— 个人知识整理工作台（新用户数据为空）
- [x] **成长**（GrowthPage）— 知识统计、成就墙、本周回顾、时间线入口
- [x] **我的**（MinePage）— 统计、稿本库/历史/收藏/诊断、深浅色、设置与隐私

## v1.2 新增

- [x] HubStore — 稿本库、活动流、周目标、成就（本机 Preferences）
- [x] 稿本库 — 润色/摘要「存稿本」集中管理，可复制/再润色/删除
- [x] 润色增强 — 改写说明含字数变化；结果块「存稿本/存历史/复制」
- [x] 成就系统 — 8 项徽章，成长页展示
- [x] 本周回顾 — 基于真实活动数据聚合

## 研究工作台（本机 Preferences）

- [x] 研究笔记：主题、正文、观点、相册配图、详情编辑/删除/生成观点卡/收藏/送到润色台
- [x] 专题资料库：历史研究/读书笔记/行业观察/兴趣收藏
- [x] 知识标签：待学习/已整理/重点关注/灵感记录 + 自定义 + 筛选
- [x] 灵感收集：快记 + 备注 + 灵感库
- [x] 时间线整理：按时间回顾笔记/灵感/阅读/每日思考
- [x] 观点卡片：从笔记生成核心观点速览
- [x] 阅读记录：内容、进度、感想
- [x] 研究计划：目标 + 三阶段勾选进度
- [x] 收藏管理：星标 + 自定义分类
- [x] 每日思考：一天一个观点 + 连续天数
- [x] 内容搜索：关键词 + 标签筛选
- [x] 个人知识统计：笔记量、近 7 天、连续思考

## 服务

- [x] LanguageEngineService — 本机规则润色/摘要
- [x] LanguageCraftBizService — GET /biz/language-craft/inspirations
- [x] LocalRecordStore — 润色最多 20 条 + 摘要历史
- [x] FavoriteStore — 本机灵感收藏
- [x] ResearchStore — 本机研究资料
- [x] HubStore — 稿本/活动/目标/成就/仪表盘聚合
- [x] DiagnoseService — 表达问卷 7 题 + 模板报告

## 合规

- [x] open_optional · 无独立隐私首屏
- [x] FeatureFlags.LLM_ENABLED=false · UI 无生成式 AI 对话
- [x] LegalDocs 已按研语功能定制
- [x] handleRevokePrivacy + 设置与隐私二级页
