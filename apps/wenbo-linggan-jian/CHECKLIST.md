# CHECKLIST（Gate B）灵感笺

- requestId: req_linggan_jian_20260820
- slug: wenbo-linggan-jian
- appName: 灵感笺
- industry: inspiration-slip
- checkedAt: 2026-08-20

## B1 功能闭环

- [x] 无空白主页面（空态文案完整）
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] 核心业务流可走通：记录 → 标签 → 灵感卡 → 灵感签
- [x] 登录退出可用；演示账号仅在 store/
- [x] 登录页可切换注册
- [x] 无强制邀请码
- [x] 非半成品；主功能不跳三方
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] 无独立隐私首屏；协议勾选在登录页
- [x] 同意前不采数不申权
- [x] 协议可打开全文
- [x] 收集清单与共享清单
- [x] 注销在设置与隐私；无「删除业务数据」按钮；撤回异步 flush + logout + Toast
- [x] 权限三方一致：仅 INTERNET

## B3 安全与技术

- [x] HTTPS saas16.qianqi.online
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [x] IPv6 由公网站承担
- [x] 关闭调试说明见 store
- [ ] DevEco Sync + CompileArkTS（需本机 DevEco）
- [x] `@Watch` 只装饰属性
- [x] TextInput 有 onChange
- [x] 图标为 HarmonyOS Symbol

## B7 差异化

- [x] docs/product/differentiation.md 差异点 ≥6

## B8 Logo

- [x] 笺纸 + 星芒；customLock + render_logo.mjs

## B11 / B12 / B13

- [x] featureModules 对齐 Admin
- [x] 栏目种子 tags/templates/quotes；用户灵感本机空
- [x] 详情 Hero + 正文 + CTA
- [x] App 注册 + Admin App 用户

## 结论

- status: pass（DevEco 真机编译待同事本机确认）
- blockers: []
- warnings: [DevEco CompileArkTS 需本机]
