# 消暑饮品

当前 App 名称：**消暑饮品**

HarmonyOS NEXT 工程（DevEco Studio 请打开本 `app/` 目录）。

ApiConfig：`saas16.qianqi.online` · 租户 `wenbo-xiaoshu-yinpin`

## 上架图标

华为应用市场请上传（1024×1024 直角合成图，勿在资源内自裁圆角）：

- `../store/logo/preview-1024.png` ← **上架主图标（优先用这个）**
- 本工程副本：`AppScope/resources/base/media/app_icon.png`
- 模块图标：`entry/src/main/resources/base/media/icon.png`

分层源文件：`../store/logo/foreground.png` + `../store/logo/background.png`

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
