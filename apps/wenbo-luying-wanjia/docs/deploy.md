# 部署 · 露营玩家

同事站点：**saas16.qianqi.online**

```
node runtimes/register-tenant.mjs --slug wenbo-luying-wanjia
node runtimes/seed-camp-player-tenant.mjs wenbo-luying-wanjia
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

App `ApiConfig`：`DEV_HOST = saas16.qianqi.online`，`TENANT_ID = wenbo-luying-wanjia`，`USE_HTTPS = true`。
