# 手作心笺 — 产品页面规划

## 信息架构（5 Tab）

| Tab | 页面 | 核心能力 |
|-----|------|----------|
| 首页 | HomePage | 课堂示例、本周目标、创作课堂、分类、消息 |
| 创作 | CreatePage | 创建/编辑作品、材料管家、搜索 |
| 灵感 | InspirationPage | 个人灵感记录、标签筛选 |
| 工坊 | WorkshopPage | 制作计时、尺寸换算、材料成本（本机工具） |
| 我的 | MinePage | 我的作品、收藏清单、创作日历、设置与隐私 |

本应用不提供社区、公开评论或用户间互动。首页仅展示机构课堂示例。

## 二级页面

- 作品详情（WorkDetailPane）：Hero + 材料 + 步骤 + 心得 + 收藏
- 教程详情（GuideDetailPane）：步骤跟做
- 创作编辑（WorkEditOverlay）：全屏表单
- 材料管家（MaterialsOverlay）
- 消息中心（MessagesPage）

## 数据流

平台 `runtime/xinjian-shouzuo-xinjian/` → App `GET/POST /biz/handcraft/*`
