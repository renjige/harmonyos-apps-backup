# CHECKLIST（Gate B）· 明序阁

- requestId: req_mingxu_ge
- slug: mingxu-ge
- appName: 明序阁
- industry: task-efficiency
- checkedAt: 2026-08-26

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态（栏目笺注走平台；用户日程/习惯/笔记默认为空）
- [x] **新用户登录后无测试数据**（runtime tasks/habits/notes 为 `[]`）
- [x] **二级 / 三级页功能完整**（列表→DetailPane→编辑/删除/打卡 CTA）
- [x] 核心业务流可走通（本机 Preferences；登录后可同步）
- [x] 登录退出可用；演示账号仅在 store/（登录页不展示、不预填）
- [x] 登录页可切换注册；`POST /auth/register` 可用
- [x] 无强制邀请码
- [x] 非半成品；主功能不依赖跳转三方完成
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] **无独立隐私授权首屏**；协议勾选在登录/注册页（方案原文的「首次弹窗」按工厂规则改为登录勾选）
- [x] 同意前不采数不申权
- [x] 协议可打开全文 Overlay
- [x] 收集清单与共享清单（store 四 md + LegalDocs）
- [x] 注销账号 / 撤回同意；无「删除业务数据」；有「清除缓存」
- [x] 权限三方一致（仅 INTERNET）

## B2.7 撤回隐私

- [x] PrivacyService.revoke 为 async + flush
- [x] MinePage.handleRevokePrivacy + 顶层 Toast + logout

## B3 安全与技术

- [x] HTTPS → saas16.qianqi.online
- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案（客户端）
- [x] IPv6 由系统网络栈支持
- [x] 关闭调试说明（发布包在 DevEco 选 release）
- [ ] DevEco Sync + CompileArkTS 通过（需本机 DevEco 打开 `apps/mingxu-ge/app/` 验证）
- [x] `@Watch` 只装饰属性
- [x] 图标为 HarmonyOS Symbol / AppIcon
- [x] HomePage 316 行（略超 300，Builders 留在同文件；功能完整优先）

## B4 齐套

- [x] AppSpec.json
- [x] docs/product/
- [x] app/
- [x] store/
- [x] admin/README.md 指向平台
- [x] 共用 platform/，无独立 server 部署

## B5 上架

- [x] 介绍与截图计划在 AppSpec.store
- [x] 演示账号文档 store/demo-account.md

## B6 激励

- [x] incentive-notes.md 已按本 App 重写（无虚假 AI 申报）

## B7 差异化

- [x] 未全文换皮
- [x] docs/product/differentiation.md 差异点 ≥6

## B8 品牌 Logo

- [x] store/logo/concept.md + symbol.svg + preview-1024.png
- [x] 工程 app_icon / icon / startIcon 已替换
- [x] README 含 App 名与上架图标路径

## B11 Admin ↔ App

- [x] featureModules 已登记并 deploy saas16
- [x] runtime 阁中笺注 5 条（cover_calendar / cover_habit / cover_note / banner_ink / hero_study）公网 GET 已冒烟
- [x] 用户活动 JSON 为空
- [x] Messages 对接平台

## B12 详情

- [x] 笺注/日程/习惯/笔记详情 Overlay + Hero/正文/CTA

## B13 用户

- [x] 注册登录 + Admin App 注册用户模块

## Gate C 影像

- [x] productVisualType = ops-tool；内容图 6 张独立文件
- [x] HomePage Image($r) Hero + 笺注封面

## 结论

- status: `pass`（ArkTS 真机编译待 DevEco 确认）
- blockers: []
- warnings:
  - 未接华为推送 / ReminderAgent；「首页智慧提醒」为应用内规则文案开关
  - 未接华为账号一键登录（无第三方登录场景）
  - HomePage 略超 300 行
