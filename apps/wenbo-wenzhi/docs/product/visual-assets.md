# 视觉资产 — 问知

productVisualType：`content-commerce`（≥5 张内容影像，不含 Logo）

全部落盘 `app/entry/src/main/resources/base/media/`。页面通过 `AskMedia.resource()` → `Image($r('app.media.*'))` 真引用。一 key 一图，禁止共图。

| 文件 | 用途 | 场景 |
|------|------|------|
| hero_ask.png | 首页提问台 Hero | 清晨书桌、笔记本与暖光，顶部留负空间叠白字 |
| banner_insight.png | 解答/求知偏好 Banner | 窗边书架与翻开的书页，知识洞察氛围 |
| banner_daily.png | 每日新知栏目 Banner | 晨读茶席与一页纸，轻量学习感 |
| cover_work.png | 工作类解答封面 | 简洁办公桌、计时器与笔记，番茄工作法气质 |
| cover_study.png | 学习类解答封面 | 长文与荧光笔、书桌阅读 |
| cover_life.png | 生活类解答封面 | 居家窗边、生活判断场景 |
| cover_tech.png | 方法/思维类封面 | 草稿纸上的复利曲线与笔记 |
| cover_history.png | 判断/溯源类封面 | 对照两则剪报、核实来源的桌面 |
| daily_hero.png | 每日新知主卡片 | 大幅晨读摄影，底部可叠标题 |

品牌 Logo 不在本清单，见 `store/logo/`（问号曲线 + 暖橙光点）。
