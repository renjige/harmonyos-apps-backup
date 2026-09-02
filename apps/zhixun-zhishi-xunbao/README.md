# 知识寻宝

当前 App 名称：**知识寻宝**

知寻探索 · HarmonyOS NEXT · 行业 Pack `knowledge-quest`

以主题知识地图闯关解锁宝藏，在趣味探索中积累智慧值。覆盖历史探秘、科学发现、文化艺术、自然奇观、生活智慧。

## 上架图标（华为应用市场请用这个）

- `apps/zhixun-zhishi-xunbao/store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## DevEco

打开目录：**`apps/zhixun-zhishi-xunbao/app/`**（不要打开上级 slug 目录）

## 平台对接

- 同事站点：`https://saas16.qianqi.online/`
- API：`https://saas16.qianqi.online/api/v1`
- 租户：`TENANT_ID=zhixun-zhishi-xunbao`
- Admin 账号见 `store/admin-account.md` / `runtimes/colleague/README.md`

## 目录

```
apps/zhixun-zhishi-xunbao/
├── app/          # 鸿蒙客户端（DevEco 打开此目录）
├── store/        # 上架资料与 Logo
├── docs/         # 产品文档
└── AppSpec.json
```

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可「清除缓存」
- 栏目走平台 API；新用户本机闯关进度为空
- 无支付；应用名称/描述/界面无「AI」字样
- 浅色/深色模式文字与背景高对比
