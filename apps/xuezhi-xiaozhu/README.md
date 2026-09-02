# 学知小筑

当前 App 名称：**学知小筑**

选一个领域，按路径把知识一点点筑进日常。完全免费的学习工具：有序路径、知识卡片、进度徽章、智慧问答（仅供参考）。

## 上架图标（华为应用市场请用这个）

- `apps/xuezhi-xiaozhu/store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`apps/xuezhi-xiaozhu/app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`apps/xuezhi-xiaozhu/app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## DevEco

打开目录：`apps/xuezhi-xiaozhu/app/`（不要打开上级 slug 目录）

## 平台对接

- 站点：https://saas16.qianqi.online/
- API：https://saas16.qianqi.online/api/v1
- 租户：`xuezhi-xiaozhu`
- Admin 账号见 `store/admin-account.md`（register-tenant 后生成）

## 核心闭环

1. 首页选路径 → 路径详情 → 课时详情 → 登录后标记完成 → 进度页刷新
2. 知识库卡片 → 详情 → 收藏 → 收藏夹
3. 学习匹配问卷 → 打开推荐路径
4. 智慧问答词条匹配（每页标注仅供参考）

## 合规

- 无独立隐私首屏；协议勾选在登录/注册页
- 无「AI」字样；`FeatureFlags.LLM_ENABLED=false`
- 无支付、无广告
- 撤回隐私：我的 → 设置与隐私
