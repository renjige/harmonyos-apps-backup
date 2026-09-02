# CHECKLIST（Gate B）— 慧忆册

- requestId: req_huiyi_ce
- slug: huiyi-ce
- appName: 慧忆册
- industry: wisdom-memory
- checkedAt: 2026-08-25

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] 新用户登录后无测试数据
- [x] 二级 / 三级页功能完整（列表→详情→编辑/删除/收册/温习）
- [x] 核心业务流可走通（记录、记忆册、按日回顾、待温习）
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
- [x] 注销 / 撤回；无「删除业务数据」；可清除缓存
- [x] 权限三方一致

## B3 安全与技术

- [x] HTTPS saas16.qianqi.online
- [x] 无密钥 hardcode
- [x] 无 test 业务文案
- [ ] DevEco assembleHap 需在本机确认
- [x] @Watch 只装饰属性
- [x] TextInput 有 onChange
- [x] 功能图标 Symbol

## B7 差异化

- [x] docs/product/differentiation.md ≥6 条

## B8 Logo

- [x] concept + symbol.svg + preview-1024
- [x] customLock=true
- [x] 工程图标已替换

## B9 / B10 视觉

- [x] visual-assets.md + 5 张 media
- [x] Home Image ≥2（hero + empty）

## B11 / B13

- [x] featureModules 含 appUsers
- [x] 注册登录链
