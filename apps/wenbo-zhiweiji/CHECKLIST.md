# CHECKLIST（Gate B）— 知微集

- requestId: req_1787712464255
- slug: wenbo-zhiweiji
- appName: 知微集
- industry: micro-insight
- checkedAt: 2026-08-26

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] **新用户登录后无测试数据**（用户活动列表为空）
- [x] **二级 / 三级页功能完整**（列表→详情→CTA）
- [x] 核心业务流可走通
- [x] 登录退出可用；演示账号仅在 store/（登录页不展示、不预填）
- [x] 登录页可切换注册；`POST /auth/register` 可用；无「仅登录无注册」
- [x] 无强制邀请码
- [x] 非半成品；主功能不依赖跳转三方完成
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] **无独立隐私授权首屏**；协议勾选在登录/注册页
- [x] 同意前不采数不申权
- [x] 协议可打开全文 Overlay
- [x] 收集清单与共享清单
- [x] 注销账号 / 撤回同意；**禁止「删除业务数据」按钮**；可按需「清除缓存」
- [x] 权限三方一致（AppSpec / module / store）

## B2.7 撤回隐私

- [x] PrivacyService.revoke async + flush
- [x] MinePage handleRevokePrivacy + 顶层 Toast + 退出登录

## B3 安全与技术

- [x] HTTPS（saas16.qianqi.online）
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [ ] DevEco Sync 需同事本机确认
- [x] `@Watch` 只装饰属性
- [x] TextInput 有 onChange
- [x] 功能图标为 HarmonyOS Symbol

## B7 差异化

- [x] docs/product/differentiation.md 差异 ≥6
- [x] 未换皮已有 App

## B8 Logo

- [x] concept.md + symbol.svg + 分层/预览图
- [x] app_icon 已替换
- [x] README 含 App 名与上架图标路径

## B10 / Gate C 影像

- [x] productVisualType content-commerce
- [x] visual-assets.md + 8 张独立 PNG
- [x] Home Image ≥2（Hero + 列表封面）

## B11 Admin

- [x] featureModules：overview / appUsers / messages / kpis
- [x] 收录为用户本机数据，不灌种子

## B12 详情

- [x] CaptureDetailPane / QuoteDetailPane：Hero + 摘要 + 正文 + CTA
- [x] 顶层 Overlay + tabBarHidden

## B13 用户

- [x] 注册登录 + Admin App 注册用户

## 结论

- status: `pass`（DevEco 真机编译待同事确认）
- blockers: []
- warnings: [DevEco assembleHap 需本机确认]
