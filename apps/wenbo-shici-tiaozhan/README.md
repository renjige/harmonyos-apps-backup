# 诗词挑战

当前 App 名称：**诗词挑战**

魏文波 · HarmonyOS NEXT · ApiConfig → `saas16.qianqi.online` · 租户 `wenbo-shici-tiaozhan`

国潮现代诗词竞技：每日五题填空配对排序、飞花令关键字接龙与百首经典图鉴注释赏析，游客即可开练

## 三 Tab 结构

| Tab | 页面 | 功能 |
|-----|------|------|
| 首页 | HomePage | Hero、今日五题、飞花令、诗库入口、连击徽章 |
| 记录 | RecordsPage | 每日成绩、飞花令统计、本机连击 |
| 诗库 | LibraryPage | 朝代/作者/题材筛选、详情注释译文赏析 |

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/wenbo-shici-tiaozhan/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 快速启动

1. DevEco Studio 打开 **`app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可按需「清除缓存」
- 新用户登录后无测试数据；二级/三级页功能完整
- 浅色/深色模式文字与背景高对比
