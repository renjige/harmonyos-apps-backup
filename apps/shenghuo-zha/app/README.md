# 生活札

当前 App 名称：**生活札**

HarmonyOS NEXT 工程（DevEco Studio 请打开本 `app/` 目录）。由 `runtimes/scaffold.mjs` 生成，禁止只留「工程模板」套话。

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

## 审核修复说明（1.0.2）

- 新增「锦囊」Tab：经验卡、问题记录、生活目标、方案收藏、轻量挑战、灵感（不新增系统权限）
- 日常增加清单模板；时间线增加去年今天回顾
- 我的页增加生活档案统计
- 启动不再弹出应用内隐私授权窗（华为隐私托管）
- 时间线支持生活模板 / 图文 / 心情；详情可删除
- 日常 Tab：打卡 + 生活清单；保存提醒时写入系统通知
- 回忆相册使用 file:// 沙箱图 + 固定宽高比网格
