# 部署

平台独立站：https://saas16.qianqi.online/

```bash
node runtimes/register-tenant.mjs --slug xiaoye-manxing
node runtimes/seed-summer-wander-tenant.mjs xiaoye-manxing
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

App `ApiConfig`：`saas16.qianqi.online` · `TENANT_ID=xiaoye-manxing`
