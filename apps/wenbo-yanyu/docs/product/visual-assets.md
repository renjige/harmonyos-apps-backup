# 研语 · 内容影像资产清单

productVisualType: `content-commerce`  
品牌主色: `#1A3A5C` · 点缀: `#D4AF37`

## 落盘目录

`app/entry/src/main/resources/base/media/{filename}.png`

## 清单

| 文件名 | 用途 | 场景描述 |
|--------|------|----------|
| hero_desk | 润色页 Hero | 清晨书桌：深蓝笔记本、钢笔、纸页与窗边柔光，Editorial 摄影，顶部留白叠字 |
| banner_polish | 润色氛围 | 纸页与钢笔特写，香槟金细线点缀，横版 Banner |
| banner_summary | 摘要页 Banner | 叠放文稿与荧光标记，商务编辑风，底部渐变留白 |
| cover_meeting | 灵感·会议纪要 | 现代会议室桌面、笔记本与水杯，职场沟通 |
| cover_email | 灵感·邮件 | 笔记本电脑邮件界面氛围，克制商务 |
| cover_workplace | 灵感·汇报 | 开放式工位与文档，向上汇报场景 |
| cover_academic | 灵感·学术 | 大学图书馆书桌、论文与台灯 |
| cover_essay | 灵感·文献 | 书堆与阅读笔记，文献评述 |
| cover_library | 灵感·论证 | 安静阅读角，论证写作 |
| cover_daily | 灵感·日常 | 日常对话场景，咖啡桌与手机 |
| cover_cafe | 灵感·请人帮忙 | 咖啡馆交谈，轻松日常 |
| cover_letter | 灵感·安慰 | 手写信与温暖织物，日常表达 |
| cover_creative | 灵感·卖点 | 创意工作台，文案策划 |
| cover_copy | 灵感·预热 | 活动物料与便签，创意文案 |
| cover_story | 灵感·品牌故事 | 品牌叙事桌面，故事开篇 |

## 引用约定

- HomePage: `Image($r('app.media.hero_desk'))`
- SummaryPage: `banner_summary`
- InspirePage / DetailPane: `LanguageCraftMedia.cover(coverKey)` 一 key 一图
- 禁止多 key 共用同一 PNG

## Logo（独立流水线）

见 `store/logo/preview-1024.png` · `app-logo.mdc`
