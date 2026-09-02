# 视觉资产清单 — 思维匣

productVisualType：`content-commerce`（灵感卡片 + 匣格导读影像）

| 文件 | 用途 | 场景描述 |
|------|------|----------|
| hero_open_box.png | 首页 Hero | 微启木匣，卡片从缝隙滑出 |
| banner_capture.png | 速记氛围 | 手写在米白纸上 |
| banner_mindmap.png | 导图页背景 | 纸面层级节点 |
| cover_cards.png | 详情默认封面 | 叠放的思维卡片 |
| cover_tags.png | 标签页封面 | 亚麻上的纸质标签 |
| empty_linen.png | 空态 | 打开的匣子内里 |
| texture_paper.png | 我的页氛围 | 纸纹材质 |

落盘：`app/entry/src/main/resources/base/media/`  
引用：`BoxMedia.resource()` → `Image($r('app.media.xxx'))`  
禁止共图：每个 coverKey 独立文件。
