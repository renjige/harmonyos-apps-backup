# 观思堂

面向知识工作者的智慧笔记与思维管理 HarmonyOS 应用。

## DevEco 打开路径

`apps/wenbo-guansi-tang/app/`

## 平台 API

- Admin：`https://saas16.qianqi.online/`
- API：`https://saas16.qianqi.online/api/v1`
- 租户：`wenbo-guansi-tang`

## Admin 账号

见 `store/admin-account.md`

## 上架图标

- 矢量源：`store/logo/symbol.svg`
- 华为应用市场上传：`store/logo/preview-1024.png`（由 symbol.svg 导出；工程副本 `app/AppScope/resources/base/media/app_icon.png`）

## 核心 Tab

1. **洞察笔记** — 标签筛选、搜索、列表/卡片切换、骨架屏、半屏新建  
2. **思辨空间** — 每日一问摄影 Hero、思考记录、思维导图预览  
3. **智慧洞察** — 统计、热力图、周报/月报（纯统计）  
4. **我的** — 数据备份导出、关于、消息、设置与隐私  

## 本次完善项

- 半屏底部新建笔记面板（遮罩 + 圆角 Sheet）
- 笔记列表/卡片视图切换 + 加载骨架屏
- 思辨空间每日一问 Hero 摄影图
- 数据备份（纯文本摘要导出页）
- 关于与反馈、消息中心对接平台 API
- 视觉资产：cover_wisdom / cover_topic_daily / cover_reading 等
- 全站「思录」文案统一为「笔记」

## 演示账号

见 `store/demo-account.md`（禁止写入客户端 UI）

## 合规说明

- 无支付、无「AI」字样、无生成式对话  
- 首次启动无独立隐私弹窗；协议勾选在登录/注册页  
- `FeatureFlags.LLM_ENABLED = false`
