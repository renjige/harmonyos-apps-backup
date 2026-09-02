# 灵感手册

魏文波旗下创意灵感管理 App — 记录、画板、计划、收藏与成长打卡一体化工作台。

## DevEco 工程

打开目录：`apps/wenbo-linggan-shouce/app/`

## 平台

| 项 | 值 |
|---|---|
| Admin | https://saas16.qianqi.online/ |
| API | https://saas16.qianqi.online/api/v1 |
| TENANT_ID | `wenbo-linggan-shouce` |

## 上架资料

- 应用图标（合成）：`store/logo/preview-1024.png`
- 工程图标：`app/AppScope/resources/base/media/app_icon.png`

## 版本

1.1.0 — 工作台首页、成长中心、时间轴、专题、统一搜索、计划里程碑

## 验收路径

1. 游客：工作台 → 推荐灵感详情
2. 登录：记录灵感 → 画板 → 计划（里程碑）→ 收藏 → 智慧整理搜索
3. 我的：成长中心打卡 → 时间轴 → 消息中心 → 设置撤回/注销

```bash
npm run gate:behavior -- apps/wenbo-linggan-shouce
```
