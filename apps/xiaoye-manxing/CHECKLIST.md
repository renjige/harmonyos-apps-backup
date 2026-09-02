# CHECKLIST（Gate B）· 夏野漫行

- requestId: req_1787207698483
- slug: xiaoye-manxing
- appName: 夏野漫行
- industry: summer-wander
- checkedAt: 2026-08-20

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] 核心业务流可走通（路线详情 → 收藏 / 清单 / 手记）
- [x] 登录退出可用；演示账号仅在 store/
- [x] 登录页可切换注册
- [x] 无强制邀请码
- [x] 主功能不依赖跳转三方
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] 无独立隐私首屏；协议勾选在登录页
- [x] 同意前不申敏感权限
- [x] 协议可打开全文
- [x] 收集清单与共享清单
- [x] 注销在设置与隐私；无「删除业务数据」按钮
- [x] 撤回隐私 async + Toast + logout
- [x] 仅 INTERNET

## B3 安全与技术

- [x] HTTPS saas16.qianqi.online
- [x] 无客户端演示密码
- [x] LLM 关闭
- [x] 栏目走 /biz/summer-wander/*

## B11 / B12 / B13

- [x] featureModules：swRoutes / swInspirations / swQuotes / appUsers
- [x] 路线 / 灵感详情 Hero + 正文 + CTA
- [x] App 注册登录 + Admin App 用户（平台已有）

## B7 差异化

- [x] docs/product/differentiation.md
