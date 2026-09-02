# 部署说明 — 避暑游记

## 平台（同事独立站 saas16）

1. `node runtimes/register-tenant.mjs --slug wenbo-bishu-youji --app-spec apps/wenbo-bishu-youji/AppSpec.json`
2. `node runtimes/seed-cool-escape-tenant.mjs wenbo-bishu-youji`
3. `node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy`

Admin：https://saas16.qianqi.online/  
API：https://saas16.qianqi.online/api/v1  
租户：`wenbo-bishu-youji`  
账号见 `store/admin-account.md`

## 客户端

1. DevEco 打开 `apps/wenbo-bishu-youji/app/`
2. `ApiConfig` 已指向 `saas16.qianqi.online`，`TENANT_ID=wenbo-bishu-youji`
3. 发布前关闭调试；使用正式签名

## 审核

1. 演示账号只在 `store/demo-account.md`（登录页不展示、不预填）
2. 游客可逛首页与灵感；写游记需登录
3. 提交前再跑 `CHECKLIST.md`
