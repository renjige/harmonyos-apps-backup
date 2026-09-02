# 约定提醒 — DevEco 工程

用 DevEco Studio 打开本目录（`apps/wenbo-yueding-tixing/app/`），不要打开上一级 slug 目录。

上架图标：`apps/wenbo-yueding-tixing/store/logo/preview-1024.png`


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
