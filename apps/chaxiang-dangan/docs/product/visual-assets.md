# 茶香档案 · 视觉资产清单

**productVisualType**: `ops-tool`  
**品牌色**: primary `#2F4A3C` · accent `#C4A574` · background `#F6F1E8`

| 文件名 | 用途 | 场景描述 |
|--------|------|---------|
| `hero_tea_space.png` | 首页茶香空间 Hero / 茶品详情 Hero | 茶席与暖光、留底部叠字空间 |
| `empty_cup.png` | 空态空杯 | 空杯与浅色茶席，非卡通 |
| `cabinet_wood.png` | 茶库档案柜材质 | 木质茶柜纹理 |
| `tasting_texture.png` | 品饮体验卡 / 品饮详情 | 茶汤与杯沿材质 |
| `review_ambient.png` | 回顾时间轴氛围 | 纸质年轮与茶香余韵 |

## 落盘路径

```
app/entry/src/main/resources/base/media/hero_tea_space.png
app/entry/src/main/resources/base/media/empty_cup.png
app/entry/src/main/resources/base/media/cabinet_wood.png
app/entry/src/main/resources/base/media/tasting_texture.png
app/entry/src/main/resources/base/media/review_ambient.png
```

## UI 引用

- `HomePage` → `$r('app.media.hero_tea_space')` + `$r('app.media.empty_cup')`
- `CabinetPage` → `$r('app.media.cabinet_wood')`
- `TeaDetailPane` → `$r('app.media.hero_tea_space')`
- `TastingDetailPane` → `$r('app.media.tasting_texture')`
- `ReviewPage` → `$r('app.media.review_ambient')`

## 最少张数

ops-tool 类型 ≥2 张内容影像（本 App 5 张，已满足）。
