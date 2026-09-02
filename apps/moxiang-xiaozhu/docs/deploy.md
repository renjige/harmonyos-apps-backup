# 部署说明 — 墨香小筑

本 App 对接同事独立站 **saas16**（无需 git pull）。

```bash
node runtimes/register-tenant.mjs --slug moxiang-xiaozhu --app-spec apps/moxiang-xiaozhu/AppSpec.json
node runtimes/seed-ink-cottage-tenant.mjs moxiang-xiaozhu
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

- Admin：https://saas16.qianqi.online/
- API：https://saas16.qianqi.online/api/v1
- 租户 ID：`moxiang-xiaozhu`
- App：`ApiConfig.DEV_HOST = saas16.qianqi.online`

禁止并行第二条 deploy（见 `.cursor/rules/saas-concurrent-generate.mdc`）。
