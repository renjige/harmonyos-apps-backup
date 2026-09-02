# CHECKLIST（Gate B）栖光札

- requestId: req_1788311625607
- slug: qiguang-zha
- appName: 栖光札
- industry: light-archive
- checkedAt: 2026-09-02 (gate:behavior)

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] **新用户登录后无测试数据**（用户活动列表为空）
- [x] **二级 / 三级页功能完整**（列表→详情→CTA）
- [x] 核心业务流可走通
- [x] 纯本地工具无需登录；演示说明仅在 store/
- [x] 无强制邀请码
- [x] 非半成品；主功能不依赖跳转三方完成
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] 本地工具协议 Overlay（无登录页）；非独立 PrivacyPage 路由
- [x] 同意前不采数不申权
- [x] 协议可打开全文 Overlay
- [x] 收集清单与共享清单
- [x] 注销账号 / 撤回同意；**禁止「删除业务数据」按钮**；可按需「清除缓存」
- [x] 权限三方一致（AppSpec / module / store）无系统权限

## B3 安全与技术

- [x] 纯本地不声明 INTERNET
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [x] IPv6 声明（无网络能力）
- [x] 关闭调试说明
- [x] DevEco 打开 `apps/qiguang-zha/app/`
- [x] `@Watch` 只装饰属性，不装饰方法
- [x] TextInput 有 onChange；无 Theme.space[n]
- [x] 图标为 HarmonyOS Symbol/矢量，无 Emoji/文字符号（icons-harmonyos）

## B4 齐套

- [x] AppSpec.json
- [x] docs/product/
- [x] db/
- [x] server/（本地工具未部署 SaaS）
- [x] ai/
- [x] app/
- [x] store/

## B5 上架

- [x] 介绍与截图计划合规
- [x] 演示账号文档（本地无需登录）

## B6 激励（警告级）

- [x] 鸿蒙特色已规划
- [x] incentive-notes.md

## B7 差异化（反换皮，见 app-differentiation.mdc）

- [x] 未基于已有 apps/{slug} 全文替换出货
- [x] 核心实体/字段与参考 App 可区分
- [x] Tab/首页入口文案行业专属
- [x] 列表含 ≥3 个行业字段；详情操作动词行业化
- [x] 无生成式 AI quickCommands
- [x] layoutVariant / 品牌色与最近同行业交付错开
- [x] docs/product/differentiation.md 存在且差异点 ≥6

## B8 品牌 Logo（见 app-logo.mdc）

- [x] store/logo/concept.md + symbol.svg + logo-horizontal.svg + 分层/预览图已落盘
- [x] agent-svg 渲染（customLock）
- [x] 工程 app_icon / icon / startIcon 已替换默认图
- [x] AppSpec.brand.logo 已登记
- [x] 无假角标；与参考 App Logo 可区分
- [x] 已注明 DevEco 分层再处理（上架前）
- [x] `apps/qiguang-zha/README.md` 含当前 App 名称；已指出上架图标路径

## B14 浅色 / 深色对比度

- [x] 浅色与深色模式控件文字与背景高对比（标题 ≥3:1，正文 ≥4.5:1）

## B11 Admin ↔ App 对齐（见 admin-app-alignment.mdc）

- [x] 纯本地工具：无平台 featureModules / 不部署 SaaS

## 结论

- status: `pass`
- blockers: []
- warnings: []
