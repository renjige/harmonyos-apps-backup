# CHECKLIST（Gate B）生活备笺

- requestId: req_1787217749039
- slug: wenbo-shenghuo-beijian
- appName: 生活备笺
- industry: life-memo
- checkedAt: 2026-08-20

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] 核心业务流可走通（记录→分类→提醒→完成→回顾）
- [x] 登录退出可用；演示账号仅在 store/（登录页不展示、不预填）
- [x] 登录页可切换注册；`POST /auth/register` 可用；无「仅登录无注册」
- [x] 无强制邀请码
- [x] 非半成品；主功能不依赖跳转三方完成
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] 无独立隐私首屏；协议勾选在登录/注册页
- [x] 同意前不采数不申权
- [x] 协议可打开（LegalDocOverlay）
- [x] 收集清单与共享清单
- [x] 注销在设置与隐私；撤回隐私 async + Toast
- [x] 权限三方一致（仅 INTERNET）

## B3 安全与技术

- [x] HTTPS（saas16.qianqi.online）
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [x] IPv6 声明（平台站）
- [x] 关闭调试说明
- [x] DevEco 打开 `apps/wenbo-shenghuo-beijian/app/`
- [x] `@Watch` 只装饰属性
- [x] TextInput 有 onChange
- [x] 图标为 HarmonyOS Symbol

## B4 齐套

- [x] AppSpec.json
- [x] docs/product/
- [x] db/
- [x] server/
- [x] ai/
- [x] app/
- [x] store/

## B5 上架

- [x] 介绍与截图计划合规
- [x] 演示账号文档

## B6 激励（警告级）

- [x] 鸿蒙特色已规划（卡片/快捷入口）
- [x] incentive-notes.md（不主打生成式对话）

## B7 差异化

- [x] 未基于已有 apps 全文替换出货
- [x] 核心实体 Slip 与日记/心情/家庭清单可区分
- [x] Tab：今日/笺记/日历/我的
- [x] 详情含分类、日期、提醒、完成 CTA
- [x] 界面无「AI」字样
- [x] 青绿+暖米白+layoutVariant B
- [x] docs/product/differentiation.md ≥6 条

## B8 品牌 Logo

- [x] store/logo/concept.md + symbol.svg + 分层/预览图
- [x] render_logo.mjs / ps1 栅格化
- [x] 工程 icon / startIcon / app_icon 已替换
- [x] AppSpec.brand.logo 已登记
- [x] 无假角标；折角笺纸+光点

## B11 Admin ↔ App 对齐

- [x] featureModules：appUsers / lmCategories / lmGreetings / lmScenes / lmNotes / messages / kpis
- [x] runtime 栏目种子 + notes 空表
- [x] 问候/分类/场景走 /biz/life-memo/*
- [x] Messages 对接 GET /messages

## B12 详情

- [x] 备笺详情 Hero + 摘要 + 正文 + CTA
- [x] 分类/场景详情 Hero + 正文 + 「按这个分类记一件事」
- [x] 顶层 Overlay + tabBarHidden

## B13 App 用户

- [x] 注册登录 + Admin「App 注册用户」
- [x] 演示账号仅 store/

## 结论

- status: `pass`
- blockers: []
- warnings: [DevEco CompileArkTS 需本机打开工程确认]
