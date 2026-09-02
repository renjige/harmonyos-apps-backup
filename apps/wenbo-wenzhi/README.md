# 问知

当前 App 名称：**问知**（WenZhi）

魏文波 · HarmonyOS NEXT · 智慧知识问答与信息洞察平台

提问求知、分类检索、每日一题、知识挑战与个人知识库，把答案真正留下来。

## 打开工程

DevEco Studio 打开：`apps/wenbo-wenzhi/app/`（不要打开上级 slug 目录）

## 上架图标（华为应用市场请用这个）

- `apps/wenbo-wenzhi/store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`apps/wenbo-wenzhi/app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`apps/wenbo-wenzhi/app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 平台对接（同事站点 saas16）

- Admin：https://saas16.qianqi.online/
- API：https://saas16.qianqi.online/api/v1
- 租户：`wenbo-wenzhi`（App `ApiConfig.TENANT_ID`）
- 租户管理员：`admin@wenbo-wenzhi.local` / `AdminPass#2026`
- 超管：`super@platform.local` / `SuperPass#2026`
- 审核演示账号：仅见 `store/demo-account.md`（客户端不展示、不预填）

## 功能

四 Tab：问答 · 知识库 · 新知 · 我的。栏目走 `/biz/wisdom-ask/*`。C 端无生成式对话，界面无「AI」字样。无支付。

学习工具（应对审核 3.5）：六分类检索、专题库、提问记录、收藏夹+标签、每日一题、知识挑战、错题本、笔记、学习计划、成长统计、知识卡片与分享。深色模式当前页即时切换（审核 3.1）。

隐私：无独立隐私首屏；协议勾选在登录/注册页。撤回路径：我的 → 设置与隐私。

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可「清除缓存」
- 新用户收藏为空；二级/三级页功能完整
- 浅色/深色模式文字与背景高对比
