# DevEco 工程 — 森野小记

HarmonyOS NEXT 原生应用（API 12+）。

## 打开方式

DevEco Studio → Open → 本目录 `apps/senye-xiaoji/app/`

## 核心 Tab

记录 · 日历 · 整理 · 我的

## 数据

记录内容存储在本机 Preferences；可选注册账号对接平台 Auth。

## 打包 HAP 报 `spawn java ENOENT`

**原因**：系统 PATH 未包含 DevEco 自带 JDK，`PackageHap` 阶段找不到 `java` 命令。ArkTS 编译已通过时仍会出现此错误。

**方案 A（推荐 · 永久）**：Windows 环境变量

1. `JAVA_HOME` = `E:\software\DevEco Studio\jbr`
2. 在 `Path` 追加：`%JAVA_HOME%\bin`
3. 重启 DevEco Studio 后再 Build

**方案 B（本工程脚本）**：

```powershell
cd apps\senye-xiaoji\app
.\build-hap.ps1
```

**方案 C（DevEco 内）**：File → Settings → Build, Execution, Deployment → Build Tools → Gradle/Hvigor，确认 JDK 指向 DevEco 自带 JBR。

已生成 `local.properties`（sdk / java.home 路径）。
