# 部署

管理后台与 API 部署到同事独立站 **saas16.qianqi.online**（物理隔离，不覆盖他人站点）。

```bash
node runtimes/register-tenant.mjs --slug wenbo-linggan-jian --app-spec apps/wenbo-linggan-jian/AppSpec.json
node runtimes/seed-inspiration-slip-tenant.mjs wenbo-linggan-jian
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

- Admin：https://saas16.qianqi.online/
- API：https://saas16.qianqi.online/api/v1
- App `ApiConfig.DEV_HOST` = `saas16.qianqi.online`，`TENANT_ID` = `wenbo-linggan-jian`
- DevEco 打开 `apps/wenbo-linggan-jian/app/`

账号见 `store/admin-account.md` 与 `store/demo-account.md`（禁止写入客户端）。
