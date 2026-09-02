# 部署说明 · 户外装备库

## 同事站点

- Admin：https://saas16.qianqi.online/
- API：https://saas16.qianqi.online/api/v1
- 租户：`wenbo-huwai-zhuangbeiku`
- 客户端：`ApiConfig.DEV_HOST = saas16.qianqi.online`

## 命令

```bash
node runtimes/register-tenant.mjs --slug wenbo-huwai-zhuangbeiku --app-spec apps/wenbo-huwai-zhuangbeiku/AppSpec.json
node runtimes/seed-outdoor-gear-tenant.mjs wenbo-huwai-zhuangbeiku
node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy
```

DevEco 打开 `apps/wenbo-huwai-zhuangbeiku/app/`。
