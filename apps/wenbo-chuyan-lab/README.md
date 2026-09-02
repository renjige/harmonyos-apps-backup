# 厨验Lab

当前 App 名称：**厨验Lab**

魏文波 · HarmonyOS NEXT

管理家中食材保质期、智慧匹配可做菜谱、记录烹饪实验笔记的智慧厨房助手

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## 目录

```
apps/wenbo-chuyan-lab/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 功能 Tab

| Tab | 页面 | 说明 |
|-----|------|------|
| 看板 | HomePage | KPI、保质期提醒、智慧推荐菜谱 |
| 食材 | PantryPage | 分类库存、添加/编辑（登录同步） |
| 菜谱 | RecipeBrowsePage | 菜系/难度筛选、详情 |
| 采购 | ShoppingPage | 清单勾选、分享 |
| 我的 | MinePage | 收藏、实验笔记、设置与隐私 |

## API 配置

- 域名：`saas16.qianqi.online`
- 租户：`wenbo-chuyan-lab`
- 路径前缀：`/api/v1/biz/kitchen-lab/*`

## 快速启动

1. DevEco Studio 打开 **`app/`** 目录
2. Sync Project → Build → 运行到模拟器或真机

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可按需「清除缓存」
- 新用户登录后无测试数据；二级/三级页功能完整
- 浅色/深色模式文字与背景高对比
