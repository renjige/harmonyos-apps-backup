# CHECKLIST（Gate B）消暑饮品

- requestId: req_1787535779742
- slug: wenbo-xiaoshu-yinpin
- appName: 消暑饮品
- industry: summer-drinks
- checkedAt: 2026-08-24

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] **新用户登录后无测试数据**（收藏 / 试做为空）
- [x] **二级 / 三级页功能完整**（列表→详情→收藏/试做）
- [x] 核心业务流可走通
- [x] 登录退出可用；演示账号仅在 store/（登录页不展示、不预填）
- [x] 登录页可切换注册；`POST /auth/register` 可用
- [x] 无强制邀请码
- [x] 非半成品；主功能不依赖跳转三方完成
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] **无独立隐私授权首屏**；协议勾选在登录/注册页
- [x] 同意前不采数不申权
- [x] 协议可打开全文 Overlay
- [x] 收集清单与共享清单
- [x] 注销账号 / 撤回同意；**禁止「删除业务数据」按钮**；可清除缓存
- [x] 权限三方一致（仅 INTERNET）

## B3 安全与技术

- [x] HTTPS（saas16.qianqi.online）
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [ ] DevEco Sync + CompileArkTS 需在本机打开 `app/` 验证
- [x] `@Watch` 只装饰属性
- [x] TextInput 有 onChange
- [x] 图标为 HarmonyOS Symbol / 矢量

## B4 齐套

- [x] AppSpec.json
- [x] docs/product/
- [x] app/
- [x] store/
- [x] ai/

## B5 上架

- [x] 介绍与截图计划合规
- [x] 演示账号文档

## B7 差异化

- [x] docs/product/differentiation.md 差异点 ≥6

## B8 品牌 Logo

- [x] store/logo/ 分层 + preview-1024.png
- [x] customLock + render_logo.mjs
- [x] 工程 app_icon / icon / startIcon 已同步

## B11 / B12 / B13

- [x] featureModules 含 appUsers + sdDrinks/sdTips/sdTries/sdFavorites
- [x] 详情 Hero + 正文 + CTA；顶层 Overlay
- [x] 注册登录 + Admin App 注册用户（平台已有）
