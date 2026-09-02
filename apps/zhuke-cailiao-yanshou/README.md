# 筑科材料验收

筑科建筑工程有限公司材料进场验收工具。按工点与批次登记到场材料，对照品类要点完成检查，异常可跟进与复验。

- **公司**：筑科建筑工程有限公司
- **运营者**：魏文波
- **Slug**：`zhuke-cailiao-yanshou`
- **DevEco 打开**：`apps/zhuke-cailiao-yanshou/app/`
- **上架图标**：`apps/zhuke-cailiao-yanshou/store/logo/preview-1024.png`
- **Admin**：https://saas16.qianqi.online/ （租户 `zhuke-cailiao-yanshou`）
- **ApiConfig**：`saas16.qianqi.online` · `TENANT_ID=zhuke-cailiao-yanshou`

## 核心闭环

1. 首页「开始验收」或「品类要点」→ 填写工点/批次/检查项 → 保存
2. 列表/首页卡片 → 详情 → 复制摘要 / 异常跟进 / 复验 / 编辑 / 删除
3. 记录页按近 7 日筛选；不通过记录进入异常跟进清单闭环

请在 DevEco 打开上述 `app/` 目录后 **Build Hap** 再提交审核。
