# 部署说明 · 文波错题析

同事独立站：**saas16.qianqi.online**

## 平台

```bash
node runtimes/register-tenant.mjs --slug wenbo-cuoti-fenxi --app-spec apps/wenbo-cuoti-fenxi/AppSpec.json
node runtimes/seed-wrong-notebook-tenant.mjs wenbo-cuoti-fenxi
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

Admin：https://saas16.qianqi.online/  
API：https://saas16.qianqi.online/api/v1  
租户：`wenbo-cuoti-fenxi`

## 客户端

1. DevEco 打开 `apps/wenbo-cuoti-fenxi/app/`
2. `ApiConfig`：`DEV_HOST = saas16.qianqi.online`，`TENANT_ID = wenbo-cuoti-fenxi`
3. 发布前关闭调试；使用正式签名；支持 IPv6

## 审核

1. 演示账号仅见 `store/demo-account.md`，登录页不得预填
2. 截图见 `store/screenshot-plan.md`
3. 上架图标：`store/logo/preview-1024.png`
