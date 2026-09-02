# 晨光笺

当前 App 名称：**晨光笺**

智慧随笔：每日一笺，在晨光里把心情与念头写成信笺，按时间线优雅陈列。完全免费，无支付。随笔正文默认保存在本机。

## 打开工程

DevEco Studio 打开：**`apps/chenguang-jian/app/`**

## 上架图标（华为应用市场请用这个）

- `apps/chenguang-jian/store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`apps/chenguang-jian/app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`apps/chenguang-jian/app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 平台对接

- 同事站点：`https://saas16.qianqi.online/`
- API：`https://saas16.qianqi.online/api/v1`
- 租户：`chenguang-jian`（`ApiConfig.TENANT_ID`）
- Admin 账号见 `store/admin-account.md`（register-tenant 后写入）
- 演示账号（仅审核，客户端不展示）：`store/demo-account.md`

## 功能摘要

- 三 Tab：笺集 | 标签 | 我的
- 撰写自动保存、智慧标签（词表规则）、列表/月视图
- 每日晨语（平台栏目）、收藏、天气笺语（按时辰，不定位）
- 书写习惯自检（问卷 + 规则模板，不提供生成式对话）
- 游客可写笺；登录/注册协议勾选在登录页
- 撤回隐私同意：我的 → 设置与隐私

## 硬约束

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可「清除缓存」
- 新用户本机笺集为空；栏目走平台 `/biz/dawn-slip/*`
- 浅色/深色模式文字与背景高对比
- 文案不使用「AI」字样
