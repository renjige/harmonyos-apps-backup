# 云水间 — 视觉资产清单

productVisualType：`content-commerce`（生活美学内容型，≥5 张内容影像）

品牌主色：`#3D8277` · 辅色 `#D6A86E` · 气质：暖纸留白 + 青绿金点缀

## 内容影像

| 文件名 | 用途 | 场景描述 | 比例 |
|--------|------|---------|------|
| `hero_mist_life.png` | 首页 Hero 主视觉 | 晨雾中的生活美学空间：窗边茶杯、柔光与留白，青绿暖金色调，底部留深色渐变区供标题叠字 | 16:9 横图，安全裁切 |
| `banner_yun_01.png` | 首页/札记 Editorial Banner 1 | 云水间主题：远山水雾、简约茶席或书案，编辑级摄影，上方或下方负空间供短文案 | 2:1 横图 |
| `banner_yun_02.png` | 首页/计划 Editorial Banner 2 | 日常规划氛围：整洁桌面、手账与绿植，温润自然光，非 UI 截图 | 2:1 横图 |
| `cover_daily.png` | 札记「日常」分类封面 | 居家日常片段：早餐、阳光、生活小物，与 daily 语义对应 | 1:1 方图 |
| `cover_travel.png` | 札记「旅行」分类封面 | 旅途窗景或步道远景，轻盈出行感，色调与其他封面可区分 | 1:1 方图 |
| `cover_food.png` | 札记「美食」分类封面 | 简约餐桌或时令食材特写，暖色食欲感但克制高级 | 1:1 方图 |

## 落盘路径

```text
apps/yunshui-jian/app/entry/src/main/resources/base/media/{filename}.png
```

## GenerateImage 提示词骨架

```text
Commercial mobile app content photography for lifestyle aesthetics app 云水间 — {specific scene from table row}.
Photoreal editorial, warm paper-tea-window light mood, NOT UI screenshot, NOT cartoon, NOT 3D robot.
No purple AI glow, no stock fake smile collage, no text/watermark in image.
Subtly match brand primary #3D8277 and accent #D6A86E.
{For hero/banner: leave negative space at top or bottom for text overlay.}
Square or {aspect ratio from table}, safe for mobile crop.
```

## AppSpec 登记

写入 `AppSpec.brand.visualAssets[]`：

| id | file | usage |
|----|------|-------|
| hero_mist_life | hero_mist_life.png | 首页 Hero |
| banner_yun_01 | banner_yun_01.png | Editorial Banner 1 |
| banner_yun_02 | banner_yun_02.png | Editorial Banner 2 |
| cover_daily | cover_daily.png | 日常分类封面 |
| cover_travel | cover_travel.png | 旅行分类封面 |
| cover_food | cover_food.png | 美食分类封面 |

## Logo（独立流水线）

| 文件 | 用途 |
|------|------|
| `store/logo/symbol.svg` | 品牌 Symbol 矢量源 |
| `store/logo/preview-1024.png` | 华为上架 1024×1024 |
| `store/logo/foreground.png` | 分层前景 |
| `store/logo/background.png` | 分层背景 |

## 引用要求

- `HomePage` Hero：`Image($r('app.media.hero_mist_life'))`
- Banner 轮播/编辑条：`banner_yun_01` · `banner_yun_02`
- 各分类 seed `coverMedia` key 独立映射，禁止共图

## 交付自检

```text
□ 内容影像 ≥ 6 张且 file size 互不相同
□ visual-assets.md 与 media/ 文件名一致
□ HomePage Image($r('app.media.*')) ≥ 2
□ 详情 Hero 有真图或用户照片，非纯色 Rectangle
□ Logo preview-1024 非脚手架默认
```
