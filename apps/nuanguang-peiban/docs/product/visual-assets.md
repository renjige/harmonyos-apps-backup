# 暖光陪伴 — 内容影像资产清单

`productVisualType`: **content-commerce**（≥5 张内容影像，不含 Logo）

品牌主色 `#F5A623` · 强调 `#FF8A7A` · 背景 `#FFF8F0`

## 落盘路径

`app/entry/src/main/resources/base/media/{filename}.png`

## 清单

| 文件名 | 用途 | 场景描述 | 宽高建议 |
|--------|------|----------|----------|
| `hero_warm_glow` | 首页 Hero | 暖阳室内光晕，米白墙面与柔和窗光，留出底部文字区 | 16:9 / 方形可裁 |
| `banner_warm_01` | 语录 Banner / 轮播 | 金色午后咖啡桌与暖色织物，编辑感摄影 | 16:9 |
| `banner_warm_02` | 语录 Banner / 轮播 | 雨天窗边的暖灯与书本，低饱和治愈 | 16:9 |
| `cover_quote_cozy` | 暖心语录封面 | 沙发毯与暖色抱枕特写，无文字 | 1:1 |
| `cover_quote_rain` | 暖心语录封面 | 雨滴窗玻璃与室内暖光反射，与 cozy 区分色调 | 1:1 |
| `cover_breath_soft` | 呼吸模式封面 · 轻呼吸 | 柔和光晕与浅景深，平静氛围 | 1:1 |
| `cover_breath_glow` | 呼吸模式封面 · 稳呼吸 | 午后阳光穿过窗帘，略亮于 soft | 1:1 |
| `cover_breath_night` | 呼吸模式封面 · 深呼吸/睡前 | 夜间暖色台灯与暗部，适合睡前场景 | 1:1 |
| `cover_noise_rain` | 白噪音 · 雨声 | 雨夜窗户或湿润叶片特写 | 1:1 |
| `cover_noise_ocean` | 白噪音 · 海浪 | 暖色调海滩或浪线抽象，非冷蓝 stock | 1:1 |
| `cover_noise_fire` | 白噪音 · 篝火 | 篝火或蜡烛暖光材质 | 1:1 |
| `cover_noise_forest` | 白噪音 · 森林 | 林间光束与绿色，偏暖色温 | 1:1 |
| `cover_noise_wind` | 白噪音 · 风铃 | 窗边风铃或轻纱飘动 | 1:1 |
| `cover_badge_glow` | 徽章墙统一封面 | 光点/徽章抽象暖金材质，可共用底图但 UI 按解锁态区分 | 1:1 |

## GenerateImage 提示词骨架

```text
Commercial mobile app content photography for warm emotional companion app — {scene from table}.
Photoreal or premium editorial, NOT UI screenshot, NOT cartoon.
No purple AI glow, no stock fake smile, no text/watermark in image.
Warm golden tone #F5A623 accent, cream background mood #FFF8F0.
For hero/banner: leave negative space at top or bottom for text overlay.
Square or 16:9, safe for mobile crop.
```

## AppSpec 登记

生成后写入 `AppSpec.brand.visualAssets[]`，每项 `{ id, file, usage }`。

## 当前状态

已按上表 GenerateImage 生成 14 张内容影像并落盘 `entry/.../media/`；Logo 见 `store/logo/preview-1024.png`。

## Logo（独立流水线）

见 `store/logo/` · `.cursor/rules/app-logo.mdc` — 不包含在本清单计数内。
