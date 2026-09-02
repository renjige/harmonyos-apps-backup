# 消暑饮品

当前 App 名称：**消暑饮品**

魏文波 · HarmonyOS NEXT · slug：`wenbo-xiaoshu-yinpin`

按体感温度与时段智慧推荐自制消暑饮，看配方、收藏、记下试做。无支付、无外卖、无生成式对话。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 分层前景：`store/logo/foreground.png`
- 分层背景：`store/logo/background.png`
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`

## 同事站点

| 项 | 值 |
|----|----|
| Admin | https://saas16.qianqi.online/ |
| API | https://saas16.qianqi.online/api/v1 |
| 租户 ID | `wenbo-xiaoshu-yinpin` |
| 超管 | `super@platform.local` / `SuperPass#2026` |
| 租户管理员 | `admin@wenbo-xiaoshu-yinpin.local` / `AdminPass#2026` |
| 审核演示账号 | 见 `store/demo-account.md`（登录页不展示、不预填） |

## DevEco

打开目录：**`apps/wenbo-xiaoshu-yinpin/app/`**（不要打开上级 slug 目录）

## 目录

```
apps/wenbo-xiaoshu-yinpin/
├── app/          # 鸿蒙客户端
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；设置内可「清除缓存」
- 新用户登录后收藏 / 试做为空
- 栏目走 `GET /biz/summer-drinks/*`，禁止客户端硬编码饮品列表
- 浅色 / 深色正文对比度达标
