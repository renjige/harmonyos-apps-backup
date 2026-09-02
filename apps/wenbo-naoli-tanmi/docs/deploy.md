# 部署 — 脑力探秘

同事独立站 saas16（勿用 legacy 共享站）。

```bash
node runtimes/register-tenant.mjs --slug wenbo-naoli-tanmi
node runtimes/seed-brain-explore-tenant.mjs wenbo-naoli-tanmi
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

验收：

```bash
curl -s -H "X-Tenant-Id: wenbo-naoli-tanmi" \
  https://saas16.qianqi.online/api/v1/biz/brain-explore/drills
```
