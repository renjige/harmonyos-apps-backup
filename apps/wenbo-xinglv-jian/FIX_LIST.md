# FIX_LIST

## Behavioral (gate:behavior)
1. B12 platform app missing components/detail/DetailShell.ets
2. B12 platform app missing at least one *DetailPane.ets
3. Gate C HomePage Image($r('app.media.*')) refs=0 (need ≥2)
4. HUAWEI-简单: 平台型 App 仅 0 种详情页（审核会认为只能看列表；需 ≥2 实体详情+CTA）
5. HUAWEI-简单: 首页区块过少（仅标题+列表感 = 模板/demo；需 Hero+≥2 栏目+可点卡片）
6. HUAWEI-简单: feature-list.md 仍是脚手架占位，未列出真实闭环（审核员会对照介绍验功能）
7. HUAWEI-异常: MessagesPage 未对接 GET /messages（消息 Tab 空白 = 功能不完整）

## Behavioral (gate:behavior)
1. B12 DetailPane must include Hero Image( and at least one CTA (AppButton/onTap)
2. Gate C HomePage Image($r('app.media.*')) refs=0 (need ≥2)
