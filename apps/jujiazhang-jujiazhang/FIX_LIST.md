# FIX_LIST

## Behavioral (gate:behavior)
1. B12 platform app missing components/detail/DetailShell.ets
2. B12 platform app missing at least one *DetailPane.ets
3. Gate C duplicate PNG byte-size (copy-paste covers): cat_chore.png=memo_repair.png, cat_family.png=item_document.png, cat_other.png=item_other.png=memo_other.png, cat_shop.png=memo_shop.png
4. HUAWEI-简单: 平台型 App 仅 0 种详情页（审核会认为只能看列表；需 ≥2 实体详情+CTA）
5. HUAWEI-异常: 空按钮/空点击 app/entry/src/main/ets/components/family/ConfirmSheet.ets（审核一点就「没反应」）
6. HUAWEI-异常: MessagesPage 未对接 GET /messages（消息 Tab 空白 = 功能不完整）

## Behavioral (gate:behavior)
1. B12 DetailPane must include Hero Image( and at least one CTA (AppButton/onTap)
