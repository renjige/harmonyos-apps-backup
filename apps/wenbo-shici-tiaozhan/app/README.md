# 诗词挑战

当前 App 名称：**诗词挑战**

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

## 构建失败：`spawn java ENOENT`

**ArkTS 已通过，仅 HAP 打包阶段失败** — 系统 PATH 中找不到 `java`，且 hvigor 守护进程可能缓存了旧环境。

### 方法一（推荐 · 永久）

Windows **用户环境变量** → `Path` → 新增：

```text
E:\software\DevEco Studio\jbr\bin
```

（DevEco 若装在其他盘，改成你的 `...\DevEco Studio\jbr\bin`）

改完后 **重启 DevEco Studio**，再 Build。

### 方法二（立即生效）

在 `app/` 目录 PowerShell 执行：

```powershell
.\build.ps1
```

脚本会自动设置 `JAVA_HOME`、停止旧 daemon 再打包。

### 方法三（DevEco 内）

1. **File → Settings → Build, Execution, Deployment → Build Tools** → Gradle JVM 选 **DevEco 自带 JBR**（或 JDK 21）
2. 终端执行停止 daemon（仓库已配 `local.properties`）：

```powershell
cd apps\wenbo-shici-tiaozhan\app
& "E:\software\DevEco Studio\tools\node\node.exe" "E:\software\DevEco Studio\tools\hvigor\bin\hvigorw.js" --stop-daemon
```

3. **Build → Clean Project** → 再 **Build Hap(s)/APP(s)**

