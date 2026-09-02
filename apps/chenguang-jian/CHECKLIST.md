# 晨光笺 交付自检

## 功能

- [x] 三 Tab 笺集 / 标签 / 我的，无脚手架智企/看板主 Tab
- [x] 列表 → 详情 Hero+正文+CTA → 编辑/删除确认
- [x] 撰写自动保存；新用户笺集为空
- [x] 栏目走 `/biz/dawn-slip/*`，无 localSeed
- [x] 登录页协议勾选；无独立隐私首屏；无演示账号预填
- [x] 撤回隐私：async revoke + flush + logout + 顶层 Toast
- [x] 无「删除业务数据」；有清除缓存
- [x] FeatureFlags.LLM_ENABLED=false
- [x] HomePage Image ≥ 2（Hero + Banner）

## 工程

- [x] ApiConfig → saas16.qianqi.online + TENANT_ID=chenguang-jian
- [x] Logo preview-1024 + 非脚手架 app_icon
- [x] visual-assets.md + media 独立文件
- [x] LegalDocs 与 store 四 md 同步，运营者魏文波
- [x] register-tenant + seed + deploy saas16（交付命令执行）
- [ ] DevEco assembleHap（本机未跑鸿蒙编译器）
