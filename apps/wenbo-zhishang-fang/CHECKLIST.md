# CHECKLIST（Gate B）

- requestId: req_1787712323109
- slug: wenbo-zhishang-fang
- appName: 纸上方
- industry: paper-excerpt
- checkedAt: 2026-08-26

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] **新用户登录后无测试数据**（书房为空）
- [x] **二级 / 三级页功能完整**（列表→详情→收藏/编辑/删除）
- [x] 核心业务流可走通
- [x] 登录退出可用；演示账号仅在 store/
- [x] 登录页可切换注册
- [x] 无强制邀请码
- [x] 非半成品
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] 无独立隐私授权首屏；协议勾选在登录/注册页
- [x] 同意前不采数不申权
- [x] 协议可打开全文 Overlay
- [x] 收集清单与共享清单
- [x] 注销 / 撤回；无「删除业务数据」；有清除缓存
- [x] 权限三方一致（仅 INTERNET；无 user_grant / 无 CAMERA）

## B7 差异化

- [x] 未换皮读书札语 / 慧忆册
- [x] 主实体 BookNote（书名+页码+摘录+感悟）
- [x] 三 Tab 书房/添加/智慧回顾
- [x] docs/product/differentiation.md ≥6 条

## B8 Logo

- [x] concept.md + symbol.svg + preview-1024.png
- [x] customLock + render_logo.mjs
- [x] 工程 app_icon / icon / startIcon 已替换
- [x] README 含 App 名与上架图标路径

## B10 / Gate C

- [x] productVisualType ops-tool，出图 4 张
- [x] Home Image ≥2（hero_library + empty_desk）
- [x] visual-assets.md + AppSpec.brand.visualAssets

## B2.7 撤回

- [x] PrivacyService.revoke async + flush
- [x] MinePage handleRevokePrivacy + 顶层 Toast

## 结论

- status: `pass`（待 DevEco Sync 与 saas16 deploy 冒烟）
- blockers: []
- warnings: [DevEco 真机未在本环境 assembleHap]
