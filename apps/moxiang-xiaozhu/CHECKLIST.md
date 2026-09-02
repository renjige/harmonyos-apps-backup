# CHECKLIST（Gate B）— 墨香小筑

- requestId: req_1787707534645
- slug: moxiang-xiaozhu
- appName: 墨香小筑
- industry: ink-cottage
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
- [x] PrivacyService.revoke async + handleRevokePrivacy + 顶层 Toast

## B3 安全与技术

- [x] HTTPS（saas16.qianqi.online）
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [x] IPv6 声明（系统网络栈）
- [x] 关闭调试说明
- [x] `@Watch` 只装饰属性
- [x] TextInput 有 onChange
- [x] 图标为 HarmonyOS Symbol

## B4 齐套

- [x] AppSpec.json
- [x] docs/product/
- [x] app/
- [x] store/
- [x] ai/prompts/system.md（Admin 备查，C 端 LLM 关闭）

## B5 上架

- [x] 介绍与截图计划合规
- [x] 演示账号文档

## B6 激励

- [x] incentive-notes.md

## B7 差异化

- [x] docs/product/differentiation.md 差异点 ≥6
- [x] 未基于已有 App 全文替换
- [x] Tab 文案行业专属

## B8 品牌 Logo

- [x] store/logo 分层 + preview-1024
- [x] AppSpec.brand.logo 已登记
- [x] README 含 App 名与上架图标路径

## B11 Admin ↔ App

- [x] featureModules 含 mox* + appUsers
- [x] runtime 种子脚本 seed-ink-cottage-tenant.mjs
- [x] Messages 对接 `/biz/ink-cottage/messages`

## B12 详情

- [x] 书摘 / 书单 / 精选笺 / 墨迹 DetailPane + 顶层 Overlay + tabBarHidden

## B13 用户

- [x] 登录注册 + Admin App 注册用户模块

## Gate C 影像

- [x] productVisualType content-commerce；media ≥5；HomePage Image ≥2
- [x] visual-assets.md + AppSpec.brand.visualAssets

## 结论

- status: `pass`（平台 deploy 后公网栏目可验）
- blockers: []
- warnings: [DevEco assembleHap 需本机环境；撤回需真机点测]
