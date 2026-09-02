# 技能闯关册

面向个人成长与技能提升的智慧闯关学习工具，通过完成技能关卡挑战积累成长值、解锁成就勋章。

## DevEco 工程

打开目录：`apps/wenbo-jineng-chuangguan-ce/app/`

## 平台 API

- Host: `https://saas16.qianqi.online/api/v1`
- Tenant: `wenbo-jineng-chuangguan-ce`

## 五 Tab

| Tab | 页面 | 说明 |
|-----|------|------|
| 闯关 | HomePage | Hero、今日推荐 5 关、成长统计 |
| 关卡 | LevelsPage | 分类筛选、关卡列表 |
| 成长 | GrowthPage | 成长值、雷达、勋章 |
| 排行 | LeaderboardPage | 总榜 + 分类榜 |
| 我的 | MinePage | 统计、设置与隐私 |

## 闯关闭环

关卡详情 → 自评提交（1–5 星 + 备注）→ `ProgressStore` 本机持久化

## 上架图标

- App 图标：`app/AppScope/resources/base/media/app_icon.png`
- 商店预览：`store/logo/preview-1024.png`（Logo 流水线完成后）

## Admin

`https://saas16.qianqi.online/` — 租户 `wenbo-jineng-chuangguan-ce`

## 验收

1. 登录后进首页，可见 Hero 与今日推荐
2. 点击关卡进详情，提交闯关心得后成长值增加
3. 成长页勋章与雷达更新
4. 设置与隐私 → 撤回同意有 Toast 且需重新勾选协议
