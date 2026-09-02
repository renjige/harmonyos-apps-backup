# 自然探索志 — 与相近 App 差异说明

对比 avoidSlugs：`wenbo-shanye-tansuo`

1. **主 Tab 结构**：发现 | **记录** | 百科 | 我的 — 以本机探索日志为核心 Tab，非「路线」Tab
2. **工作台原型**：`timeline-board`（记录时间轴首屏） vs 山野探索 `catalog-tool`
3. **品牌色**：森林绿 `#2D5A27` + 米白 `#F5F0E8` vs 松石绿 `#2D8F6F`
4. **Logo**：指南针居中 + 深森林绿山脊 vs 偏右指南针 + 松石绿
5. **用户数据**：探索记录本机 Preferences 持久化，新用户记录列表为空
6. **发现分类**：森林徒步/山川/湖泊/星空/城市公园 五类瀑布流 vs 难度+方式路线筛选
7. **隐私首启**：PrivacyConsentOverlay 同意后继续（本地 App 无登录墙浏览）
8. **无支付、无生成式文本**：智慧推荐为规则匹配；FeatureFlags.LLM_ENABLED=false
