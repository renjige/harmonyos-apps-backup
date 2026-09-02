# 部署说明

## 平台

同事独立站：`https://saas16.qianqi.online/`

```bash
node runtimes/register-tenant.mjs --slug wenbo-jiating-shixiang
node runtimes/seed-family-task-tenant.mjs wenbo-jiating-shixiang
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

## 客户端

1. DevEco 打开 `apps/wenbo-jiating-shixiang/app/`
2. ApiConfig：`saas16.qianqi.online` · TENANT_ID=`wenbo-jiating-shixiang`
3. 发布前关闭调试；使用正式签名

## 审核

演示账号见 `store/demo-account.md`（登录页不展示）。
