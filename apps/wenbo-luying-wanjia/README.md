# 露营玩家

当前 App 名称：**露营玩家**

魏文波 · HarmonyOS NEXT

面向露营爱好者的智慧露营助手：规划行程、称重打包、发现营地、写下林下记忆。全部功能免费，不含支付。

## 上架图标（华为应用市场请用这个）

- `store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## DevEco

打开目录：`apps/wenbo-luying-wanjia/app/`

## 平台

- Admin：https://saas16.qianqi.online/
- API：https://saas16.qianqi.online/api/v1
- 租户：`wenbo-luying-wanjia`
- 账号见 `store/admin-account.md`；审核演示账号仅见 `store/demo-account.md`

## 硬约束摘要

- 首次进入无独立隐私弹窗；协议勾选在登录/注册页
- 禁止「删除业务数据」按钮；可按需「清除缓存」
- 新用户登录后无测试数据；栏目走 `/biz/camp-player/*`
- 天气为目的地规则预览，不申请定位
- 智慧清单为问卷规则匹配装备模板，不是生成式对话
