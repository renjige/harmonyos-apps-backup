# 观物（GuanWu）

智慧生活观察与洞察 — 四象记录、物品图鉴、分类与模板、成长时间轴、探索任务、图集与周报。数据默认本机存储。

**当前版本：1.0.5**

## DevEco 工程

打开目录：`apps/guanwu/app/` → **Build → Clean Project** → **Run**

## 上架图标（分层 1024）

- **华为应用市场上传**：`apps/guanwu/store/logo/preview-1024.png`（1024×1024 合成预览）
- **工程分层配置**：`AppScope/resources/base/media/layered_image.json` + `icon_foreground.png` / `icon_background.png`（各 1024×1024）
- 重新生成：`node apps/guanwu/store/logo/render_logo.mjs`

## 平台 Admin

- 站点：https://saas16.qianqi.online/
- 租户：`guanwu`
- Admin：`admin@guanwu.local` / `AdminPass#2026`（见 `store/admin-account.md`）
- 审核演示账号：见 `store/demo-account.md`（**禁止**写入客户端 UI）

## ApiConfig

- `saas16.qianqi.online` · `TENANT_ID=guanwu`

## 核心验收（提审前自测）

1. **首次打开只有华为隐私托管弹窗**，应用内不再出现自建隐私声明弹窗
2. **今日工作台**：进度环 + KPI + 打卡 + 计划自动联动 + 探索中心
3. 记录：搜索/筛选/收藏、**7 日日历可点击查看当日记录**、观物图集
4. 图鉴：建档、成长时间轴、本周图鉴计划
5. **成长 Tab**：成就墙、我的轨迹、日/周/月/年回顾、统计图表
6. 写记录/收藏/打卡/新建图鉴 → 计划进度 + 成就 + 轨迹 **同步更新**
7. 智慧提醒：允许「发布提醒」权限后正常预约，不会立刻弹出
8. 可选登录注册（协议默认不勾选）
7. 可选登录注册（协议默认不勾选，仅登录页勾选）
8. 图标为 layered_image（非 41px 单层 icon.png）
