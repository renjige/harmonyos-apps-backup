# CHECKLIST — 生活剧本（本地单机）

- requestId: req_1787638301138
- slug: shenghuo-juben
- appName: 生活剧本
- industry: life-journal
- checkedAt: 2026-08-25

## B1 功能闭环

- [x] 无空白主页面
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] 新用户无测试数据
- [x] 二级 / 三级页完整（列表→详情→编辑/删除）
- [x] 核心业务流可走通
- [x] 本 App 为单机，无登录墙（符合产品方案）
- [x] 非半成品；主功能不依赖三方完成
- [x] 非纯 Web 套壳

## B2 隐私与权限

- [x] 首次启动隐私弹窗（产品方案要求；单机无登录页勾选）
- [x] 同意前不采数不申权
- [x] 协议可打开全文 Overlay
- [x] 收集清单与共享清单
- [x] 撤回同意二次确认；无「删除业务数据」按钮
- [x] 无 INTERNET 权限

## B3 安全与技术

- [x] 无密钥 hardcode
- [x] 无 test/demo/mock 业务文案
- [x] 已删除脚手架登录/AI/HttpClient
- [x] 图标为 HarmonyOS Symbol
- [x] 创建页日期使用系统日期选择器

## B8 Logo

- [x] store/logo/concept.md + symbol.svg + logo-horizontal.svg + preview-1024.png
- [x] 工程 app_icon / icon / startIcon 已替换
- [x] README 含 App 名与上架图标路径

## 结论

- status: pass（本地单机交付；未对接 SaaS）
- blockers: []
- warnings: [云端备份未做，已用本地导出/复制替代]
