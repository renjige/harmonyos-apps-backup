# 展格配色卡 — DevEco 工程

HarmonyOS NEXT 工程目录。应用名称：**展格配色卡**（墨展工作室）。

## 构建

Sync 后 Run `entry` 模块，或在工程目录执行：

```powershell
.\build-hap.ps1
```

### 若报错 `spawn java ENOENT`

ArkTS 已编译通过，但打包 HAP 需要 **Java**。本工程已含 `local.properties`（指向 DevEco SDK/JBR）。

**任选一种修复：**

1. **推荐**：在 DevEco 菜单 **Build → Build Hap(s)/APP(s) → Build Hap(s)** 构建（IDE 会自动注入 Java 环境）
2. 将 DevEco 自带 JBR 加入系统 PATH：`E:\software\DevEco Studio\jbr\bin`
3. 运行本目录 `build-hap.ps1`（脚本会自动设置 `JAVA_HOME` 与 PATH）

纯本地配色 App，无需配置 ApiConfig / 平台 API。
