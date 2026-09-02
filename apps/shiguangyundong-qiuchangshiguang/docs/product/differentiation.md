# 差异化说明 — 球场拾光

对比 avoidSlugs：`saichang-shilu`、`yundong-tuce`、`yundong-tuce`

1. **主闭环不同**：场地发现→预约→运动时光统计；非赛事录入日记或纯影像相册。
2. **Tab 结构**：首页/发现/时光/我的；非记录/相册/回顾五 Tab 手账结构。
3. **核心实体**：VenueItem + Booking + 时段网格；非 DiaryEntry/Album。
4. **平台 API**：`/biz/home-services/*` 场馆目录；非 life-journal 本地日记 API。
5. **工作台**：catalog-tool + 预约 Hero；非 timeline-board 札记首屏。
6. **智慧能力**：6 题选场问卷模板报告；非 LLM 对话或赛后复盘表单。
7. **视觉**：活力橙 #FF6B35 + 运动馆摄影 Hero；非手账奶油白或华为蓝赛事档案。
8. **无支付**：预约仅生成凭证，现场支付说明在详情与协议中明示。
9. **3.5 实质功能**：时段点选、收藏、到场打卡、取消预约，不是场馆黄页。
