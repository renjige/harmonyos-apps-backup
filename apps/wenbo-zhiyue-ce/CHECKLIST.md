# CHECKLIST（Gate B）— 智阅册

- requestId: req_1787716614447
- slug: wenbo-zhiyue-ce
- appName: 智阅册
- industry: wisdom-folio
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

## B3 安全与技术

- [x] HTTPS
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [ ] IPv6 声明（随系统网络栈）
- [ ] 关闭调试说明（发布包由 DevEco release 构建）
- [ ] DevEco Sync + CompileArkTS 通过（需本机 DevEco 验证）
- [x] `@Watch` 只装饰属性，不装饰方法（10905112）
- [x] TextInput 有 onChange；无 Theme.space[n]
- [x] 图标为 HarmonyOS Symbol/矢量，无 Emoji/文字符号（icons-harmonyos）

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

- [x] 鸿蒙特色已规划
- [x] incentive-notes.md

## B7 差异化（反换皮，见 app-differentiation.mdc）

- [x] 未基于已有 apps/{slug} 全文替换出货
- [x] 核心实体/字段与参考 App 可区分
- [x] Tab/首页入口文案行业专属
- [x] 列表含 ≥3 个行业字段；详情操作动词行业化
- [x] 智慧归类 quickCommands 含行业词
- [x] layoutVariant / 品牌色与最近同行业交付错开
- [x] docs/product/differentiation.md 存在且差异点 ≥6

## B8 品牌 Logo（见 app-logo.mdc）

- [x] store/logo/concept.md + symbol.svg + logo-horizontal.svg + 分层/预览图已落盘
- [x] 工程 app_icon / icon / startIcon 已替换默认图
- [x] customLock=true

## B9 / Gate C 影像

- [x] visual-assets.md + media 真图 ≥5
- [x] HomePage Image 引用 ≥2
- [x] 知识册封面独立 PNG 无共图
