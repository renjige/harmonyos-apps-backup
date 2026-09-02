# 茶香档案

当前 App 名称：**茶香档案**

茶香印记 · HarmonyOS NEXT · 纯本地个人茶品档案与品饮记录工具

记下每一款茶的香气与故事。

## 上架图标（华为应用市场请用这个）

- `apps/chaxiang-dangan/store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 打开工程

DevEco Studio 打开 **`apps/chaxiang-dangan/app/`**（不是上级 slug 目录）。

本 App **不联网、不登录、不部署 SaaS**。数据保存在本机 Preferences。

## 主闭环

1. 同意《用户协议》《隐私政策》
2. 首页「新增茶档案」→ 填写茶名与类型 → 保存进详情
3. 「记一笔品饮」→ 选日期/感受/评分 → 记录 Tab 可见
4. 茶库按绿茶/红茶等筛选；详情可编辑、加入茶单、删除（二次确认）
5. 回顾看时间轴与成就；我的可导出 JSON、撤回隐私同意

## 硬约束摘要

- 新用户无预置茶百科
- 不申请系统权限
- 禁止「删除业务数据」按钮
- 智慧整理为本地规则，不含生成式 AI
