# 避暑游记

当前 App 名称：**避暑游记**

魏文波 · HarmonyOS NEXT · 夏日避暑旅行灵感与记录工具

按气温与地貌推荐避暑目的地，并把旅途写成可回看的游记。游客可逛首页与灵感；写游记、收藏需登录。不含支付，不含生成式对话。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png`（透明前景）+ `store/logo/background.png`（纯色 `#1B4F72`）
- 勿在资源内自裁圆角或加内边距

## DevEco

打开目录：**`apps/wenbo-bishu-youji/app/`**

`ApiConfig`：`https://saas16.qianqi.online/api/v1`，租户 `wenbo-bishu-youji`

## 管理后台

https://saas16.qianqi.online/ 账号见 `store/admin-account.md`

## 审核注意

- 首次进入**无**独立隐私弹窗；协议勾选在登录/注册页
- 演示账号只在 `store/demo-account.md`，登录页不展示、不预填
- 新用户游记与收藏为空
