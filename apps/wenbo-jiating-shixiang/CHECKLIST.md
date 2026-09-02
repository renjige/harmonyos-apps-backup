# CHECKLIST（Gate B）家庭事项

- requestId: req_1787274346987
- slug: wenbo-jiating-shixiang
- appName: 家庭事项
- industry: family-task
- checkedAt: 2026-08-21

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] 核心业务流可走通
- [x] 登录退出可用；演示账号仅在 store/（登录页不展示、不预填）
- [x] 登录页可切换注册；`POST /auth/register` 可用
- [x] 无强制邀请码
- [x] 非半成品；主功能不依赖跳转三方完成
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] 无独立隐私首屏；协议勾选在登录页
- [x] 同意前不采数不申权
- [x] 协议可打开
- [x] 收集清单与共享清单
- [x] 注销在设置与隐私；无「删除业务数据」按钮
- [x] 权限三方一致（INTERNET）
- [x] handleRevokePrivacy + async revoke

## B3 安全与技术

- [x] HTTPS saas16.qianqi.online
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [x] IPv6 由平台 HTTPS 承载
- [x] 图标为 HarmonyOS Symbol，无 Emoji
- [x] @Watch 只装饰属性

## B7 差异化

- [x] docs/product/differentiation.md ≥6

## B8 Logo

- [x] 屋檐+勾选 customLock；icon 已同步

## B11 Admin ↔ App

- [x] featureModules：ftCategories / ftRhythm / ftTasks / appUsers / messages / kpis
- [x] runtime 栏目种子 + 用户事项空数组
- [x] GET /biz/family-task/*

## B12 详情

- [x] 事项/分类 DetailPane：Hero + 摘要 + 正文 + CTA；顶层 Overlay + tabBarHidden

## 结论

- status: `pass`
- blockers: []
- warnings: [系统通知权限未在第一版申请，提醒以应用内高亮为主]
