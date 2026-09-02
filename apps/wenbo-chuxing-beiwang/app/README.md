# 出行备忘 HarmonyOS NEXT 客户端

DevEco Studio 请直接打开本 `app/` 目录。

## 必需文件清单

- `hvigor/hvigor-config.json5` — hvigor 全局配置（缺此文件会导致「工程同步失败」）
- `build-profile.json5` — 工程级构建（`app` + `modules` 结构）
- `entry/build-profile.json5` — 模块级构建
- `hvigorfile.ts` / `entry/hvigorfile.ts`
- `oh-package.json5` / `entry/oh-package.json5`
- `AppScope/app.json5` + `AppScope/resources/base/media/app_icon.png`
- `entry/src/main/module.json5` + 模块图标资源

## SDK 要求

- DevEco Studio 5.0+
- compatibleSdkVersion: `5.0.0(12)`

## 运行配置

- API：`https://saas16.qianqi.online/api/v1`
- Tenant：`wenbo-chuxing-beiwang`
- 启动模式：`open_optional`
- App 名：`出行备忘`

客户端业务数据全部通过统一平台 API 获取；网络失败展示空态与重试，不使用本地业务种子。
