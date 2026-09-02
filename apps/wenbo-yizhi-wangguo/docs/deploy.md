# 部署

同事独立站 saas16：

```bash
node runtimes/register-tenant.mjs --slug wenbo-yizhi-wangguo
node runtimes/seed-kids-kingdom-tenant.mjs wenbo-yizhi-wangguo
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

Admin：https://saas16.qianqi.online/  
API：https://saas16.qianqi.online/api/v1  
TENANT_ID：wenbo-yizhi-wangguo
