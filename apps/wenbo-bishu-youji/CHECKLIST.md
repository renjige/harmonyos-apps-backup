# CHECKLIST（Gate B）— 避暑游记

- requestId: req_1787368702721
- slug: wenbo-bishu-youji
- appName: 避暑游记
- industry: cool-escape
- checkedAt: 2026-08-22

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] **新用户登录后无测试数据**（游记/收藏为空）
- [x] **二级 / 三级页功能完整**（目的地/攻略详情 → 收藏或写游记）
- [x] 核心业务流可走通
- [x] 登录退出可用；演示账号仅在 store/
- [x] 登录页可切换注册
- [x] 无强制邀请码
- [x] 非半成品
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] **无独立隐私授权首屏**；协议勾选在登录/注册页
- [x] 同意前不采数不申权
- [x] 协议可打开全文 Overlay
- [x] 收集清单与共享清单
- [x] 注销账号 / 撤回同意；无「删除业务数据」；有「清除缓存」
- [x] 权限仅 INTERNET

## B3 安全与技术

- [x] HTTPS saas16.qianqi.online
- [x] 无密钥 hardcode
- [x] 客户端无演示账号预填
- [ ] DevEco Sync + CompileArkTS（需本机 DevEco）
- [x] `@Watch` 只装饰属性
- [x] 图标为 HarmonyOS Symbol

## B7 差异化

- [x] docs/product/differentiation.md ≥6

## B8 品牌 Logo

- [x] store/logo 分层 + preview-1024
- [x] README 含 App 名与上架图标路径

## B11 / B12 / B13

- [x] featureModules 含 appUsers + ceDestinations/ceGuides/ceJournals/ceFavorites
- [x] 详情 Hero + 正文 + CTA；顶层 Overlay + tabBarHidden
- [x] 注册登录 + Admin App 用户模块

## 结论

- status: pass (platform deployed; DevEco 编译待本机确认)
- blockers: []
- warnings: ["需 DevEco 打开 app/ 编译运行"]
