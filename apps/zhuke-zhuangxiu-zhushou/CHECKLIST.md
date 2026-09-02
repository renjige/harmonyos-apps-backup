# CHECKLIST · 筑科装修助手 1.0.1

- slug: zhuke-zhuangxiu-zhushou
- appName: 筑科装修助手
- industry: reno-assist
- checkedAt: 2026-08-26

## 审核三项

- [x] 3.4 首次进入无预置测试项目；启动清除 sample_ / 云栖雅苑 示例
- [x] 3.5 费用备忘 + 施工时间线 + 项目纪要导出 + 智能清单 + 验收
- [x] 3.1 保存/删除后列表通过 renoRev + tick 即时刷新，不再先拉旧云端覆盖

## B1 功能闭环

- [x] 无空白主页面（空态可创建）
- [x] 无死按钮
- [x] 列表有数据或空态
- [x] 核心业务流可走通
- [x] 登录退出可用；演示账号仅在 store/
- [x] 登录页可切换注册
- [x] 无强制邀请码
- [x] 主功能不依赖跳转三方
- [x] 非纯 Web 套壳

## B2 隐私

- [x] 无独立隐私首屏；协议勾选在登录页
- [x] 协议可打开全文
- [x] 撤回隐私同意 async + Toast
- [x] 禁止「删除业务数据」；可清除缓存
- [x] LegalDocs 与 store 四 md 一致

## 结论

- status: 待 CompileArkTS 验证后视为可提审
- blockers: []
