# 购物备忘 · DevEco 工程

请用 DevEco Studio 打开本目录（`apps/wenbo-gouwu-beiwang/app/`），不要打开上级 slug 目录。

当前 App 名称：**购物备忘**。上架图标见 `../store/logo/preview-1024.png`。

---

生成 App 时由 `runtimes/scaffold.mjs` 复制到 `app/` 目录。

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
