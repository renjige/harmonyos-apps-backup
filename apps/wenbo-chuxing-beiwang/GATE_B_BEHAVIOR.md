# Gate B Behavioral Result

- status: **fail**
- slug: wenbo-chuxing-beiwang
- productVisualType: ops-tool
- platformBiz: true
- contentImages: 3
- checkedAt: 2026-08-31T07:04:46.796Z

## Blockers (4)
1. B12 platform app missing components/detail/DetailShell.ets
2. B12 platform app missing at least one *DetailPane.ets
3. Gate C HomePage Image($r('app.media.*')) refs=0 (need ≥2)
4. HUAWEI-简单: 平台型 App 仅 0 种详情页（审核会认为只能看列表；需 ≥2 实体详情+CTA）

## Warnings (4)
1. LegalDocs.ets may missing legalOperator (魏文波)
2. CHECKLIST.md mostly unchecked (52 open) — run npm run gate:behavior after fixes
3. [huawei] HUAWEI-简单: AppSpec.coreFlows < 2（建议写清主闭环+次闭环，如浏览→详情→预约）
4. [huawei] HUAWEI-异常: Index 可能未做登录态分支

## Auto-passed (22)
- B2.7 PrivacyService.revoke is async
- B2.7 handleRevokePrivacy present
- LegalDocs.ets scanned for scaffold phrases
- LoginPage demo-account UI scan
- Gate C 3 content images (min 2)
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
- HUAWEI-简单: 4 个文件含写操作 API
- HUAWEI-50104: 9 个业务页
- HUAWEI-50104: differentiation.md 存在
- HUAWEI-50104: 30 处写/提交逻辑

> Re-run: `npm run gate:behavior -- wenbo-chuxing-beiwang`
