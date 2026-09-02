# 积累日记 — DevEco 工程

应用名称：**积累日记**

## 打开方式

在 DevEco Studio 中打开本目录（`app/`），非上级 `jilei-riji/`。

## 打包 / 运行

若 DevEco 报 **`spawn java ENOENT`**（PackageHap 失败）：

1. 将 **`E:\software\DevEco Studio\jbr\bin`** 加入系统 **Path**（`JAVA_HOME` 仅设变量不够，hvigor 需能在 Path 里找到 `java`）
2. 关闭 DevEco，或在终端执行一次 `--stop-daemon` 清掉旧后台进程
3. 在本目录执行：

```powershell
.\build-hap.ps1          # 仅打包
.\run-emulator.ps1       # 打包 + 安装模拟器 + 启动
```

脚本会自动设置 `JAVA_HOME`、刷新 Path，并停止旧的 hvigor daemon。

## 主要页面

- `pages/WritePage.ets` — 每日记录（默认 Tab）
- `pages/TimelinePage.ets` — 时间轴
- `pages/ReviewPage.ets` — 智慧回顾
- `pages/SettingsPage.ets` — 设置

## 上架图标

`AppScope/resources/base/media/app_icon.png`（源：`../store/logo/preview-1024.png`）
