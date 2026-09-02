# CHECKLIST（Gate B）识趣阁

- requestId: req_wenbo_shiqu_ge
- slug: wenbo-shiqu-ge
- appName: 识趣阁
- industry: curious-pavilion
- checkedAt: 2026-08-26

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] **新用户登录后无测试数据**（收藏/阅读记录本机为空）
- [x] **二级 / 三级页功能完整**（列表→详情→收藏 CTA）
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
- [x] 注销账号 / 撤回同意；**禁止「删除业务数据」按钮**；有「清除缓存」
- [x] 权限三方一致（仅 INTERNET）

## B3 安全与技术

- [x] HTTPS → saas16.qianqi.online
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [x] IPv6 声明
- [x] 关闭调试说明
- [ ] DevEco Sync + CompileArkTS（请在本机打开 `apps/wenbo-shiqu-ge/app/` 验证）
- [x] `@Watch` 只装饰属性
- [x] TextInput 有 onChange；无 Theme.space[n]
- [x] 图标为 HarmonyOS Symbol / AppIcon

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

- [x] 鸿蒙特色已规划（原生 ArkUI + 深色模式）
- [x] incentive-notes.md

## B7 差异化

- [x] 未基于已有 App 全文替换出货
- [x] 核心实体与轻知阁 / 书页漫游 / 思见堂可区分
- [x] Tab/首页入口文案行业专属
- [x] 列表含分类/体裁/阅读时长等字段
- [x] 识趣偏好问卷为模板匹配，非生成式对话
- [x] layoutVariant A / 暖灰褐
- [x] docs/product/differentiation.md 差异点 ≥6

## B8 品牌 Logo

- [x] concept.md + symbol.svg + logo-horizontal.svg + 分层/预览图
- [x] render_logo.mjs 栅格化（customLock）
- [x] 工程 app_icon / icon / startIcon 已替换
- [x] AppSpec.brand.logo 已登记
- [x] 与参考 App Logo 可区分
- [x] README 含 App 名称与上架图标路径

## B11 Admin ↔ App

- [x] featureModules：qgArticles / qgDaily / qgFavorites / appUsers
- [x] runtime 种子 + deploy saas16
- [x] 公网 Biz list 冒烟（articles 8 / daily 4）
- [x] 栏目走 `/biz/curious-pavilion/*`

## B12 详情

- [x] ArticleDetailPane / DailyDetailPane：Hero + 摘要 + 正文 + 收藏 CTA
- [x] 顶层 Overlay + tabBarHidden

## B13 用户

- [x] LoginPage 注册+登录+协议
- [x] Admin appUsers 模块已登记

## B14 对比度

- [x] 浅/深双色；Hero 叠字有 scrim

## 结论

- status: `pass`（DevEco Sync 需本机确认）
- blockers: []
- warnings: [DevEco 需本机 Sync]
