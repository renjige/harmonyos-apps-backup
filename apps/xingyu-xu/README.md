# 星隅叙

当前 App 名称：**星隅叙**

个人生活档案空间：用叙事收藏生活片段，用主题整理兴趣，用灵感星库留下想法，再用时间星轨与智慧回望看见成长。全部数据在本机，不申请额外系统权限，不接云端栏目 API。

## 上架图标（华为应用市场请用这个）

- `apps/xingyu-xu/store/logo/preview-1024.png` ← **上架主图标 1024×1024**
- 工程副本：`apps/xingyu-xu/app/AppScope/resources/base/media/app_icon.png`
- 模块图标：`apps/xingyu-xu/app/entry/src/main/resources/base/media/icon.png`
- 分层：`store/logo/foreground.png` + `store/logo/background.png`

## DevEco 路径

打开 **`apps/xingyu-xu/app/`**（不要打开上级 slug 目录）。

## 交付要点

| 项 | 值 |
|----|-----|
| slug | `xingyu-xu` |
| Bundle ID | `com.xingyu.xu` |
| 准入 | `open_optional`，游客可写 |
| 权限 | `requestPermissions: []`（无 INTERNET） |
| LLM | `FeatureFlags.LLM_ENABLED=false` |
| 平台 | 不接 `saasN` 栏目 API；不 deploy 业务站 |

## 验收步骤

1. 冷启动进入星隅首页（无独立隐私首屏）
2. 新建一条叙事 → 打开详情 → 收藏 → 编辑 → 删除确认
3. 创建一个主题并把叙事归入
4. 回望 Tab 查看星轨；有历史日期时看智慧回望
5. 我的 → 登录/注册须勾选协议；设置与隐私撤回同意有 Toast 并退出
6. 切换深色模式，杀进程重开仍为深色
