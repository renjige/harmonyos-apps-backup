# 智行日记 — DevEco 工程

**App 名称**：智行日记  
**打开路径**：本目录（`apps/zhixing-riji/app/`）

## 运行

1. DevEco Studio 打开 `app/`
2. Sync 工程后 Run
3. 真机需与公网 API 同网或使用 HTTPS 公网地址（已配置 `saas16.qianqi.online`）

## 命令行打包 HAP（spawn java ENOENT 时）

ArkTS 编译通过后，若 `PackageHap` 报 `spawn java ENOENT`，说明系统 PATH 未配置 Java。

**方式 A（推荐）**：在本目录执行：

```powershell
.\build-hap.ps1
```

**方式 B**：DevEco 菜单 **Build → Rebuild Project**（IDE 会自动使用自带 JBR）

**方式 C**：手动设置环境变量后再构建：

```powershell
$env:JAVA_HOME = "E:\software\DevEco Studio\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
```

工程已含 `local.properties`（`java.home` / `sdk.dir` 指向 DevEco 安装目录；路径不同时请修改）。

## Tab 结构

首页 | 地图 | 时光 | 我的

## 上架图标

`../store/logo/preview-1024.png`
