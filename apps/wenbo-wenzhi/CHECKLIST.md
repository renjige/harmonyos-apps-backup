# CHECKLIST（Gate B）— 问知

- requestId: req_1787712453418
- slug: wenbo-wenzhi
- appName: 问知
- industry: wisdom-ask
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

- [x] PrivacyService.revoke 为 async 且 await flush
- [x] MinePage handleRevokePrivacy + 顶层 Toast + 已登录 logout

## B3 安全与技术

- [x] HTTPS（saas16.qianqi.online）
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [x] IPv6 声明（系统网络栈）
- [x] 关闭调试说明
- [ ] DevEco Sync + CompileArkTS 通过（本机请 Sync 确认）
- [x] `@Watch` 只装饰属性，不装饰方法
- [x] TextInput 有 onChange；无 Theme.space[n]
- [x] 图标为 HarmonyOS Symbol/矢量，无 Emoji/文字符号

## B4 齐套

- [x] AppSpec.json
- [x] docs/product/
- [x] server/（遗留目录，业务以 platform 为准）
- [x] ai/
- [x] app/
- [x] store/

## B5 上架

- [x] 介绍与截图计划合规
- [x] 演示账号文档

## B6 激励（警告级）

- [x] 鸿蒙特色已规划
- [x] incentive-notes.md

## B7 差异化

- [x] 未基于已有 apps/{slug} 全文替换出货
- [x] 核心实体/字段与参考 App 可区分
- [x] Tab/首页入口文案行业专属
- [x] 列表含 ≥3 个行业字段；详情操作动词行业化
- [x] 求知偏好问卷含行业词（非通用经营诊断）
- [x] layoutVariant / 品牌色与最近同行业交付错开
- [x] docs/product/differentiation.md 存在且差异点 ≥6

## B8 品牌 Logo

- [x] store/logo/concept.md + symbol.svg + logo-horizontal.svg + 分层/预览图已落盘
- [x] 自定义问号 + 暖橙光点（customLock）
- [x] 工程 app_icon / icon / startIcon 已替换默认图
- [x] AppSpec.brand.logo 已登记
- [x] 无假角标；与参考 App Logo 可区分
- [x] 已注明 DevEco 分层再处理（上架前）
- [x] `apps/wenbo-wenzhi/README.md` 含当前 App 名称；已指出上架图标路径

## B11 Admin ↔ App 对齐

- [x] featureModules 全套在 Admin 侧栏可见且可 CRUD
- [x] runtime/{tenantId} 栏目种子（deploy 后公网可见）
- [x] App Messages 已对接平台 API

## B12 详情页

- [x] 首页卡片 → 详情；Hero + 摘要 + 正文 + CTA；顶层 Overlay

## B13 App 用户

- [x] 注册登录 + Admin App 注册用户（featureModules 含 appUsers）

## Gate C 影像

- [x] productVisualType content-commerce；media ≥5；visual-assets.md；HomePage Image ≥2

## B14 浅色 / 深色对比度

- [x] 浅色与深色模式控件文字与背景高对比（标题 ≥3:1，正文 ≥4.5:1）

## 结论

- status: `pass`（公网 deploy 成功后栏目 API 冒烟通过）
- blockers: []
- warnings: [本环境未跑 DevEco assembleHap]
