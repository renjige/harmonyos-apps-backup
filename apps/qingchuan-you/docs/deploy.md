# 部署说明

晴川游对接同事独立站 **saas16**，无需为本 App 单独部署 Admin。

```bash
node runtimes/register-tenant.mjs --slug qingchuan-you --app-spec apps/qingchuan-you/AppSpec.json
node runtimes/seed-scenic-travel-tenant.mjs qingchuan-you
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

- Admin：https://saas16.qianqi.online/
- 健康检查：https://saas16.qianqi.online/api/v1/platform/health
- App `ApiConfig.DEV_HOST = saas16.qianqi.online`，`TENANT_ID = qingchuan-you`

审核演示账号见 `store/demo-account.md`。
