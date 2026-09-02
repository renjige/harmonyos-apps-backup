# 筑科建筑

筑科建筑工程有限公司 · HarmonyOS NEXT 企业展示应用  
建筑工程企业宣传平台：工程案例、业务范围、企业资质、新闻资讯、人才招聘与联系我们。

## 目录

```
apps/zhuke-jianzhu/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── server/       # NestJS API（可选对接）
├── db/           # 数据库迁移与种子数据
├── docs/         # 产品文档
└── AppSpec.json
```

## 快速启动

### 鸿蒙 App

1. DevEco Studio 打开 **`app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机
3. 默认 **游客可浏览**，登录后可同步收藏与浏览记录

### 后端 API（SaaS 联调）

```bash
cd server
cp .env.example .env
npm install
npm run start
# http://127.0.0.1:3000/api/v1
```

客户端默认连接 `http://127.0.0.1:3000/api/v1`（真机需改为电脑局域网 IP）。详见 `docs/deploy.md`。

## 页面结构

| Tab | 页面 | 功能 |
|-----|------|------|
| 首页 | HomePage | Banner 轮播、企业简介、主营业务、精品工程、最新资讯、联系我们 |
| 案例 | ProjectsPage | 房建/市政/装饰/园林分类筛选、项目详情 |
| 业务 | BusinessPage | 五大业务范围、业务详情 |
| 资讯 | NewsPage | 企业新闻/行业资讯/项目动态/通知公告 |
| 我的 | MinePage | 登录、收藏、浏览记录、消息通知、意见反馈、关于我们 |

### 子页面

- 企业资质（简介、文化、荣誉、证书）
- 人才招聘（岗位列表、岗位详情）
- 联系我们（地址、电话、地图导航、在线留言）

## 设计规范

- 现代商务风格，蓝色（#0B6BCB）+ 白色配色
- 遵循 HarmonyOS NEXT Design 设计规范
- 默认启动时**自动同步 SaaS 后台**；后台不可达时降级为本地 Mock 数据

## 合规边界

本应用**不包含**以下功能，符合华为应用市场审核规范：

- 在线支付 / 购物车 / 订单交易
- AI 生成 / 智能对话
- 用户社区 / UGC / 即时聊天 / 直播

## 后台管理（已实现 API）

| 模块 | API 前缀 |
|------|----------|
| Banner 管理 | `GET/POST/PUT/DELETE /api/v1/admin/banners` |
| 工程案例管理 | `GET/POST/PUT/DELETE /api/v1/admin/projects` |
| 新闻管理 | `GET/POST/PUT/DELETE /api/v1/admin/news` |
| 企业资质管理 | `GET/POST /api/v1/admin/certificates` |
| 招聘管理 | `GET/POST /api/v1/admin/jobs` |
| 荣誉管理 | `GET/POST /api/v1/admin/honors` |
| 通知管理 | `GET/POST /api/v1/admin/notifications` |
| 留言管理 | `GET/PUT /api/v1/admin/messages` |
| 用户管理 | `GET /api/v1/users` |
| 数据统计 | `GET /api/v1/dashboard/stats` |

> 客户端启动时自动调用 `/api/v1/content/*` 同步；后台修改内容后重启 App 即可生效。

## 校验

```bash
node runtimes/validate-delivery.mjs apps/zhuke-jianzhu
```
