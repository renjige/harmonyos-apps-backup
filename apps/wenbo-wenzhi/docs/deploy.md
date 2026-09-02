# 部署说明 — 问知

本 App 对接同事独立站 **saas16**，不部署 per-app Admin。

```bash
node runtimes/register-tenant.mjs --slug wenbo-wenzhi --app-spec apps/wenbo-wenzhi/AppSpec.json
node runtimes/seed-wisdom-ask-tenant.mjs wenbo-wenzhi
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

## 客户端

1. DevEco 打开 `apps/wenbo-wenzhi/app/`
2. `ApiConfig.DEV_HOST = saas16.qianqi.online`，`TENANT_ID = wenbo-wenzhi`，HTTPS
3. 发布前关闭调试；使用正式签名

## 审核

1. 使用 `store/demo-account.md` 中账号（禁止出现在客户端）
2. 按 AppSpec.store.screenshotPlan 截图
3. 提交前再跑 `apps/wenbo-wenzhi/CHECKLIST.md`
