# 诗词寻宝 · 部署

同事独立站 **saas16**（无需 git pull）。

```bash
node runtimes/register-tenant.mjs --slug wenbo-shici-xunbao
node runtimes/seed-poetry-hunt-tenant.mjs wenbo-shici-xunbao
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

- Admin：https://saas16.qianqi.online/
- API：https://saas16.qianqi.online/api/v1
- App `ApiConfig`：`DEV_HOST = saas16.qianqi.online`，`TENANT_ID = wenbo-shici-xunbao`

账号见 `store/admin-account.md`。演示账号仅 `store/demo-account.md`。
