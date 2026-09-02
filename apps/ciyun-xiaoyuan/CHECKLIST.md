# CHECKLIST — 词韵小院

- requestId: req_1787645836365
- slug: ciyun-xiaoyuan
- appName: 词韵小院
- industry: poetry-courtyard
- checkedAt: 2026-08-25

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] **新用户登录后无测试数据**（作品/收藏空）
- [x] **二级 / 三级页功能完整**（列表→详情→收藏/检测）
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
- [x] 注销账号 / 撤回同意；**禁止「删除业务数据」按钮**；可清除缓存
- [x] 权限三方一致（仅 INTERNET inuse）

## B3 安全与技术

- [x] HTTPS saas16.qianqi.online
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [x] IPv6 由系统栈支持
- [x] 关闭调试说明见工程
- [ ] DevEco Sync + CompileArkTS（请在本机 DevEco 打开 `apps/ciyun-xiaoyuan/app/` 验证）
- [x] `@Watch` 只装饰属性
- [x] TextInput 有 onChange
- [x] 图标为 HarmonyOS Symbol

## B7 差异化

- [x] docs/product/differentiation.md ≥6 点
- [x] 与寻宝/飞花令/手账主实体不同

## B8 品牌 Logo

- [x] store/logo concept + symbol + preview
- [x] customLock + render_logo.mjs
- [x] README 含上架图标路径

## B11 / B12 / B13

- [x] featureModules：cyPoems / cyCipai / cyRhymes / cyArticles / appUsers
- [x] 详情 Hero + 正文 + CTA
- [x] 登录注册 + Admin App 用户

## B14

- [x] 浅色宣纸底深墨字；深色可切换；Hero 有 scrim

## 结论

- status: pass（DevEco 编译待本机确认）
- blockers: []
- warnings: [DevEco assembleHap 需在开发机执行]
