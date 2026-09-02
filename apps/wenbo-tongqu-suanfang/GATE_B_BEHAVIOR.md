# Gate B Behavioral Result

- status: **fail**
- slug: wenbo-tongqu-suanfang
- productVisualType: ops-tool
- platformBiz: true
- contentImages: 14
- checkedAt: 2026-08-31T02:23:08.167Z

## Blockers (2)
1. HUAWEI-简单: 平台型 App 仅 1 种详情页（审核会认为只能看列表；需 ≥2 实体详情+CTA）
2. HUAWEI-异常: MessagesPage 未对接 GET /messages（消息 Tab 空白 = 功能不完整）

## Warnings (3)
1. CHECKLIST.md mostly unchecked (52 open) — run npm run gate:behavior after fixes
2. [huawei] HUAWEI-简单: AppSpec.coreFlows < 2（建议写清主闭环+次闭环，如浏览→详情→预约）
3. [huawei] HUAWEI-异常: Index 可能未做登录态分支

## Auto-passed (24)
- B2.7 PrivacyService.revoke is async
- B2.7 handleRevokePrivacy present
- LegalDocs.ets scanned for scaffold phrases
- LoginPage demo-account UI scan
- B12 1 detail pane(s) with Image+CTA
- Gate C 14 content images (min 2)
- Gate C HomePage 2 media Image refs
- B2.7-revoke-async OK (app/entry/src/main/ets/services/PrivacyService.ets)
- B2.7-revoke-handler OK (app/entry/src/main/ets/pages/MinePage.ets)
- B2.7-revoke-direct-tap OK (app/entry/src/main/ets/components/design-system/AppButton.ets)
- B2.7-revoke-direct-tap OK (app/entry/src/main/ets/components/design-system/AppCard.ets)
- B2.7-revoke-direct-tap OK (app/entry/src/main/ets/components/design-system/AppChart.ets)
- B2.7-revoke-direct-tap OK (app/entry/src/main/ets/components/design-system/AppDatePickerField.ets)
- B2.7-revoke-direct-tap OK (app/entry/src/main/ets/components/design-system/AppEmpty.ets)
- B2.7-revoke-direct-tap OK (app/entry/src/main/ets/components/design-system/AppError.ets)
- B2.7-revoke-direct-tap OK (app/entry/src/main/ets/components/design-system/AppHeader.ets)
- B2.7-revoke-direct-tap OK (app/entry/src/main/ets/components/design-system/AppIcon.ets)
- B2.7-revoke-direct-tap OK (app/entry/src/main/ets/components/design-system/AppListRow.ets)
- B2.7-revoke-direct-tap OK (app/entry/src/main/ets/components/design-system/AppLoading.ets)
- HUAWEI-简单: 首页有足够区块
- HUAWEI-简单: 3 个文件含写操作 API
- HUAWEI-50104: 10 个业务页
- HUAWEI-50104: differentiation.md 存在
- HUAWEI-50104: 33 处写/提交逻辑

> Re-run: `npm run gate:behavior -- wenbo-tongqu-suanfang`
