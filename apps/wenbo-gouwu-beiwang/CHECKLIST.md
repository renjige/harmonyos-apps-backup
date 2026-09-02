# CHECKLIST（Gate B）模板

> 复制到 `apps/{slug}/CHECKLIST.md`，生成结束后逐项勾选。

- requestId:
- slug:
- appName:
- industry:
- checkedAt:

## B1 功能闭环

- [ ] 无空白主页面
- [ ] 无死按钮
- [ ] 列表有数据或空态
- [ ] 核心业务流可走通
- [ ] 登录退出可用；演示账号仅在 store/（登录页不展示、不预填）
- [ ] 登录页可切换注册；`POST /auth/register` 可用；无「仅登录无注册」
- [ ] 无强制邀请码
- [ ] 非半成品；主功能不依赖跳转三方完成
- [ ] 非纯 Web 套壳

## B2 隐私与权限

- [ ] 隐私同意页
- [ ] 同意前不采数不申权
- [ ] 协议可打开
- [ ] 收集清单与共享清单
- [ ] 注销与删数
- [ ] 权限三方一致（AppSpec / module / store）

## B3 安全与技术

- [ ] HTTPS
- [ ] 无密钥 hardcode
- [ ] 无 test/demo/mock 业务文案
- [ ] IPv6 声明
- [ ] 关闭调试说明
- [ ] DevEco Sync + CompileArkTS 通过（见 `.cursor/rules/arkts-deveco.mdc`）
- [ ] `@Watch` 只装饰属性，不装饰方法（10905112）
- [ ] TextInput 有 onChange；无 Theme.space[n]
- [ ] 图标为 HarmonyOS Symbol/矢量，无 Emoji/文字符号（icons-harmonyos）

## B4 齐套

- [ ] AppSpec.json
- [ ] docs/product/
- [ ] db/
- [ ] server/
- [ ] ai/
- [ ] app/
- [ ] store/

## B5 上架

- [ ] 介绍与截图计划合规
- [ ] 演示账号文档

## B6 激励（警告级）

- [ ] 鸿蒙特色已规划
- [ ] incentive-notes.md

## B7 差异化（反换皮，见 app-differentiation.mdc）

- [ ] 未基于已有 apps/{slug} 全文替换出货
- [ ] 核心实体/字段与参考 App 可区分
- [ ] Tab/首页入口文案行业专属
- [ ] 列表含 ≥3 个行业字段；详情操作动词行业化
- [ ] AI quickCommands 含行业词
- [ ] layoutVariant / 品牌色与最近同行业交付错开
- [ ] docs/product/differentiation.md 存在且差异点 ≥6

## B8 品牌 Logo（见 app-logo.mdc）

- [ ] store/logo/concept.md + symbol.svg + logo-horizontal.svg + 分层/预览图已落盘
- [ ] premium_logo.py 生成（对比度/24px 自动质检）
- [ ] 工程 app_icon / icon / startIcon 已替换默认图
- [ ] AppSpec.brand.logo 已登记
- [ ] 无假角标；与参考 App Logo 可区分
- [ ] 已注明 DevEco 分层再处理（上架前）

## B11 Admin ↔ App 对齐（见 admin-app-alignment.mdc）

- [ ] featureModules 全套在 Admin 侧栏可见且可 CRUD
- [ ] runtime/{tenantId} 栏目种子已落盘并已 deploy
- [ ] Admin 改一条 → App 刷新同步
- [ ] App Messages 等已对接平台 API（若 featureModules 含 messages）

## 结论

- status: `pass` | `fail`
- blockers: []
- warnings: []
