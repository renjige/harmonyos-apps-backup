# 上架资料自检 — 见解簿

对照华为审核指南 50104 与工厂 Gate。

## 应用信息

- [x] 名称 ≤15 汉字：见解簿（3 字）
- [x] 一句话简介与完整描述与实际功能一致
- [x] 无「官方/权威/免费躺赚」等营销词
- [x] Bundle：com.wenbo.jianjiebu
- [x] 上架图标非脚手架默认：`store/logo/preview-1024.png`

## 功能

- [x] 记录 → 详情 → 编辑/删除 闭环
- [x] 整理三视图可用
- [x] 洞察摘要与词云可用
- [x] 新用户见解列表为空
- [x] 无死按钮、无「即将上线」
- [x] 无 INTERNET 权限
- [x] CompileArkTS + assembleHap 通过

## 隐私

- [x] 首次启动隐私由华为托管，应用内不重复弹窗
- [x] 协议全文可应用内查看（LegalDocs + store md）
- [x] 撤回隐私：async + flush + 顶层 Toast
- [x] 五文件一致：LegalDocs + privacy/user/personal/third-party
- [x] 运营者：魏文波
- [x] 无「删除业务数据」按钮

## 截图与审核表单

- [ ] 真机截图 ≥4 张（见 screenshot-plan.md）
- [ ] 隐私政策 HTTPS URL 已托管并填入审核表单
- [ ] 用户协议 HTTPS URL 已托管（若表单要求）

## 演示

- [x] 游客全功能，无需演示账号（见 demo-account.md）
- [x] 客户端无预填审核密码

## 明确不做

- [x] 无华为账号联网登录
- [x] 无生成式 AI 对话
- [x] 无支付/广告
