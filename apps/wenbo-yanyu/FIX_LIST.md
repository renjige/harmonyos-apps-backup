# FIX_LIST

## Behavioral (gate:behavior)
1. Gate C HomePage Image($r('app.media.*')) refs=0 (need ≥2)
2. UX-dark-subscribe: MainTabPage 须 @StorageLink('themeEpoch') 订阅主题变更 (app/entry/src/main/ets/pages/MainTabPage.ets)
3. HUAWEI-简单: 平台型 App 仅 1 种详情页（审核会认为只能看列表；需 ≥2 实体详情+CTA）
4. HUAWEI-异常: MessagesPage 未对接 GET /messages（消息 Tab 空白 = 功能不完整）
