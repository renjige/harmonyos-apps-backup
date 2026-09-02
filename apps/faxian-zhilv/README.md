# 发现之旅

**公司**：发现科技  
**App**：发现之旅  
**定位**：城市探索与生活发现 App，帮助用户发现城市中值得探访的地点、活动与故事。

## DevEco 工程

打开目录：`apps/faxian-zhilv/app/`

## 平台 API

- 域名：`https://saas16.qianqi.online/api/v1`
- 租户：`faxian-zhilv`
- Admin：`https://saas16.qianqi.online/`（租户切换至「发现之旅」）

## 功能 Tab

| Tab | 说明 |
|-----|------|
| 发现 | 精选推荐、今日探索、分类浏览、探索灵感 |
| 探索目录 | 全部探索点列表，支持时长/场景筛选 |
| 旅记 | 用户探索笔记（本地持久，新用户为空） |
| 我的 | 成就徽章、收藏、设置与隐私 |

## 上架图标

- 合成预览：`apps/faxian-zhilv/store/logo/preview-1024.png`
- 工程图标：`apps/faxian-zhilv/app/entry/src/main/resources/base/media/app_icon.png`

## 审核演示账号

见 `store/demo-account.md`（禁止写入客户端 UI）

## 部署

```bash
node runtimes/seed-summer-wander-tenant.mjs faxian-zhilv
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```
