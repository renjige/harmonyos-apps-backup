# 出行备忘部署说明

## 统一平台

- Admin：`https://saas16.qianqi.online/`
- API：`https://saas16.qianqi.online/api/v1`
- 租户：`wenbo-chuxing-beiwang`
- 部署命令：`node runtimes/deploy-platform-saas.mjs --env runtimes/colleague/saas16.env.deploy`
- PM2：`harmonyos-saas16-api`

## 客户端

1. DevEco Studio 打开 `apps/wenbo-chuxing-beiwang/app/`
2. `ApiConfig.ets` 已配置 `saas16.qianqi.online` 与租户 ID
3. 同步工程并使用 HarmonyOS 5.0.0(12) 或兼容 SDK
4. 发布前关闭调试并使用正式签名

## 审核

1. 审核账号见 `store/demo-account.md`
2. 按 `AppSpec.store.screenshotPlan` 拍摄至少 5 张真实界面
3. 提交前执行 Gate A、Gate B，并在真机验证登录持久化、撤回隐私、注销和通知
