# 生活剧本

以剧本形式记录和回顾日常生活的轻量级鸿蒙应用。**每个人都是自己生活的主角。**

## DevEco 工程路径

```
apps/shenghuo-juben/app/
```

请用 DevEco Studio 打开 **`app/`** 目录（不是上级 slug 目录），执行 Sync 后编译运行。

## 核心功能（完整闭环）

| Tab | 能力 |
|-----|------|
| **首页** | 卡片流、搜索、心情筛选 → 详情 → 编辑 / 删除确认 |
| **创建** | 可选日期、标题、场景≤500、心情、1–3配图可删、智慧开场白 |
| **时光相册** | 月历圆点/数量；同日多部选择；当月空态提示 |
| **我的** | 头像、昵称保存、统计、版本、导出/复制、隐私撤回确认、深色持久化 |

- 首次启动 **隐私弹窗**；撤回后即时重新弹出；暂不同意 **退出应用**
- **纯本地存储**，已移除联网权限与登录/AI 脚手架页

## 品牌色

- 主色 `#E8A87C` · 辅色 `#2C3E50` · 背景 `#FDF8F3`

## 上架图标

- 矢量源：`store/logo/symbol.svg`
- 华为应用市场上传：优先 `store/logo/preview-1024.png`（运行 Logo 流水线后生成）
- 工程内：`app/AppScope/resources/base/media/app_icon.png`

生成 Logo：

```bash
node runtimes/ensure-app-logo.mjs apps/shenghuo-juben
```

## 运营者

魏文波（见 `AppSpec.json` → `store.legalOperator`）

## 华为激励计划提示

- 报名截止：2026年9月25日
- 上架周期：2026年3月12日—9月30日
- 建议预留 ≥1 周审核与调整时间
