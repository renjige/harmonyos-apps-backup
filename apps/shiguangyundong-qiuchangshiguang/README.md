# 球场拾光

**拾光运动科技** 旗下场地预约与个人球迷赛事记忆工具。

- **Slug**：`shiguangyundong-qiuchangshiguang`
- **Slogan**：场地预约 + 个人球迷记录与赛事记忆
- **DevEco 工程**：`apps/shiguangyundong-qiuchangshiguang/app/`
- **上架图标**：`apps/shiguangyundong-qiuchangshiguang/store/logo/preview-1024.png`（工程副本：`app/AppScope/resources/base/media/app_icon.png`）

## 功能概览

| Tab | 说明 |
|-----|------|
| 首页 | 智能推荐、分类筛选、可订场馆列表 |
| 发现 | 列表模式、距离排序 |
| 拾光 | 观赛/日志/球队/复盘等工作台 + 场地预约 |
| 我的 | 预约记录、消息、设置与隐私 |

## 平台

- **Admin**：https://saas16.qianqi.online/
- **API**：https://saas16.qianqi.online/api/v1
- **TenantId**：`shiguangyundong-qiuchangshiguang`

## 合规说明

- `open_optional`：游客可浏览场馆，预约需登录
- 无在线支付；预约仅生成凭证，到场支付
- 无生成式 AI（智慧选场为问卷模板报告）
- 隐私协议勾选在登录/注册页（无独立隐私首屏）

## Gate

```bash
npm run gate:behavior -- apps/shiguangyundong-qiuchangshiguang
# status: pass
```

## 演示账号

见 `store/demo-account.md`（仅供审核，客户端 UI 不展示）
