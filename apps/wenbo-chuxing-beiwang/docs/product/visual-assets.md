# 出行备忘视觉资产

## 视觉方向

- 风格包：`harmonyos-official`
- 产品视觉类型：`ops-tool`
- 主色：智慧蓝 `#1677FF`
- 气质：高端、简洁、年轻、克制科技感
- 构图：蓝色时刻旅行摄影作为首页视觉中心，雪域灰承载任务卡片，深蓝渐变遮罩保证白字对比度

## 已落盘资产

| key | 文件 | 用途 | 处理 |
|---|---|---|---|
| `travel_hero` | `media/travel_hero.png` | 首页最近行程 Hero | 底部深色渐变遮罩 + 白字 |
| `travel_checklist` | `media/travel_checklist.png` | 清单页分类引导 Banner | 轻蓝遮罩，不叠小字号正文 |
| `travel_route` | `media/travel_route.png` | 行程详情 Hero | 底部深色渐变遮罩 + 目的地 |

三张内容图语义和文件独立，不共用映射。功能图标统一使用 HarmonyOS Symbol；品牌 Logo 使用 `store/logo/` 矢量源文件。

## 无障碍与审核

- Hero 白字区域叠加深色 scrim，不直接覆盖亮图
- 卡片正文使用高对比度文本 token
- 图片仅作为内容语义，不承载唯一状态
- 不使用 Emoji、支付图形或广告角标
