# CHECKLIST（Gate B）轻知阁

- requestId: req_1787274336396
- slug: wenbo-qingzhige
- appName: 轻知阁
- industry: light-knowledge
- checkedAt: 2026-08-21

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] 核心业务流可走通（发现→阅读→收藏→整理→记录→复习）
- [x] 登录退出可用；演示账号仅在 store/（登录页不展示、不预填）
- [x] 登录页可切换注册；`POST /auth/register` 可用；无「仅登录无注册」
- [x] 无强制邀请码
- [x] 非半成品；主功能不依赖跳转三方完成
- [x] 非纯 Web 套壳
- [x] 4 Tab：轻知 / 知识库 / 复习 / 我的；无第五 Tab
- [x] 游客可完成本机闭环；不强制登录

## B2 隐私与权限

- [x] 无独立隐私首屏；协议勾选在登录/注册页
- [x] 同意前不采数不申权
- [x] 协议可打开全文 Overlay
- [x] 收集清单与共享清单（store + LegalDocs）
- [x] 注销在「设置与隐私」；无「删除业务数据」按钮；撤回隐私 async + Toast
- [x] 权限仅 INTERNET（AppSpec / module / store 一致）

## B3 安全与技术

- [x] HTTPS（saas16.qianqi.online）
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [x] IPv6 声明（store）
- [x] 关闭调试说明
- [x] `@Watch` 只装饰属性
- [x] TextInput 有 onChange；无 Theme.space[n]
- [x] 图标为 HarmonyOS Symbol/矢量，无 Emoji/文字符号
- [x] 界面文案无「AI」字样；FeatureFlags.LLM_ENABLED=false

## B4 齐套

- [x] AppSpec.json
- [x] docs/product/
- [x] db/（平台 runtime，非独立库）
- [x] server/（指向平台）
- [x] ai/（备查提示词；C 端不调用）
- [x] app/
- [x] store/

## B5 上架

- [x] 介绍与截图计划合规（无 AI 宣传）
- [x] 演示账号文档

## B6 激励（警告级）

- [x] 鸿蒙特色已规划（incentive-notes.md）
- [x] incentive-notes.md

## B7 差异化

- [x] 未基于已有 apps/{slug} 全文替换出货（新建 light-knowledge Pack）
- [x] 核心实体/字段与参考 App 可区分（精选/知识/灵感/复习队列）
- [x] Tab/首页入口文案行业专属
- [x] 列表含 ≥3 个行业字段；详情操作动词行业化（收藏 / 记录相似 / 加入复习）
- [x] 无 C 端生成式对话；智能分类为本机关键词（不宣传 AI）
- [x] layoutVariant / 品牌色与最近同行业交付错开
- [x] docs/product/differentiation.md 存在且差异点 ≥6

## B8 品牌 Logo

- [x] store/logo/concept.md + symbol.svg + logo-horizontal.svg
- [x] 手写 Logo（customLock=true，非 premium house 模板）
- [x] 工程 app_icon / icon / startIcon 已替换
- [x] AppSpec.brand.logo 已登记
- [x] 无假角标；与参考 App Logo 可区分

## B11 Admin ↔ App 对齐

- [x] featureModules 全套在 Admin 侧栏（lkCategories / lkFeatured / lkCovers / lkEntries / lkSparks / appUsers）
- [x] runtime/{tenantId} 栏目种子已落盘并已 deploy 至 saas16
- [x] 公网 GET /biz/light-knowledge/featured 有精选数据
- [x] App Messages 对接平台 API

## B12 详情闭环

- [x] 首页/列表点击进详情（Hero + 摘要 + 正文 + CTA）
- [x] 详情 Overlay 顶层 + tabBarHidden

## 结论

- status: `pass`
- blockers: []
- warnings:
  - DevEco CompileArkTS 需在真机/模拟器本地确认
  - 撤回隐私同意需在真机点测一次
