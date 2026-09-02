# 部署说明

## 平台（同事独立站 saas16）

```bash
node runtimes/register-tenant.mjs --slug zhuke-yinhuan-paicha --app-spec apps/zhuke-yinhuan-paicha/AppSpec.json
cd platform/server && npm run build
node runtimes/seed-site-hazard-tenant.mjs zhuke-yinhuan-paicha
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

Admin：https://saas16.qianqi.online/  
API：https://saas16.qianqi.online/api/v1  
租户：`zhuke-yinhuan-paicha`

## 客户端

1. DevEco 打开 `apps/zhuke-yinhuan-paicha/app/`
2. `ApiConfig.DEV_HOST = saas16.qianqi.online`，`USE_HTTPS = true`
3. 发布前关闭调试；使用正式签名

## 审核

演示账号仅见 `store/demo-account.md`，禁止出现在登录页。
