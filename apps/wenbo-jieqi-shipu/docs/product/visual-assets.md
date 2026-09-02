# 节气食谱 · 内容影像资产清单

`productVisualType`: **content-commerce**（≥5 张内容影像，不含 Logo）

品牌色：主色 `#E8833A` · 点缀 `#3A7D44` · 背景 `#F5F0E8` · 正文 `#2C2420`

落盘目录：`app/entry/src/main/resources/base/media/`

映射代码：`app/entry/src/main/ets/services/SolarMedia.ets`

---

## Hero / Banner（首页必用）

| 文件名 | coverKey | 用途 | 场景描述 |
|--------|----------|------|----------|
| hero_bg.png | hero_bg | 首页 Hero | 暖橙+米白东方食养氛围，当季食材与陶瓷餐具静物，顶部留白叠字 |
| banner_01.png | banner_01 | 首页/运营位 | 立春时蔬春饼场景，编辑感摄影 |
| banner_02.png | banner_02 | 首页/运营位 | 夏至清补凉面/时令面点，清爽夏意 |
| banner_03.png | banner_03 | 空态/氛围 | 节气日历页背景材质，纸纹+墨绿点缀 |

---

## 节气封面（24 × term_*）

每个 `st_{slug}` 对应 `term_{slug}.png`，用于节气日历格、节气详情 Hero、首页当前节气卡。

| slug | 文件名 | 节气 |
|------|--------|------|
| lichun | term_lichun.png | 立春 |
| yushui | term_yushui.png | 雨水 |
| jingzhe | term_jingzhe.png | 惊蛰 |
| chunfen | term_chunfen.png | 春分 |
| qingming | term_qingming.png | 清明 |
| guyu | term_guyu.png | 谷雨 |
| lixia | term_lixia.png | 立夏 |
| xiaoman | term_xiaoman.png | 小满 |
| mangzhong | term_mangzhong.png | 芒种 |
| xiazhi | term_xiazhi.png | 夏至 |
| xiaoshu | term_xiaoshu.png | 小暑 |
| dashu | term_dashu.png | 大暑 |
| liqiu | term_liqiu.png | 立秋 |
| chushu | term_chushu.png | 处暑 |
| bailu | term_bailu.png | 白露 |
| qiufen | term_qiufen.png | 秋分 |
| hanlu | term_hanlu.png | 寒露 |
| shuangjiang | term_shuangjiang.png | 霜降 |
| lidong | term_lidong.png | 立冬 |
| xiaoxue | term_xiaoxue.png | 小雪 |
| daxue | term_daxue.png | 大雪 |
| dongzhi | term_dongzhi.png | 冬至 |
| xiaohan | term_xiaohan.png | 小寒 |
| dahan | term_dahan.png | 大寒 |

---

## 食谱封面（48 × recipe_{slug}_{1|2}）

平台 seed 每条食谱独立 `coverKey`，与 `solar-recipes-recipes.json` 一一对应。示例：

| coverKey | 菜品（seed） |
|----------|-------------|
| recipe_lichun_1 | 春饼卷时蔬 |
| recipe_lichun_2 | 韭菜炒核桃仁 |
| recipe_yushui_1 | 山药薏米粥 |
| recipe_yushui_2 | 荠菜鲜肉馄饨 |
| … | 每节气 2 道，共 48 张 |

完整列表见 `SolarMedia.ets`（100 keys）。

---

## 食养贴士（24 × tip_*）

| 模式 | 示例 | 用途 |
|------|------|------|
| tip_{slug}.png | tip_lichun.png | 首页贴士横滑、贴士详情 Hero |

---

## AppSpec.brand.visualAssets 登记（摘要）

```json
[
  { "id": "hero", "file": "hero_bg.png", "usage": "HomePage Hero" },
  { "id": "banner1", "file": "banner_01.png", "usage": "Editorial banner" },
  { "id": "banner2", "file": "banner_02.png", "usage": "Editorial banner" },
  { "id": "term_covers", "file": "term_*.png", "usage": "Calendar + TermDetail" },
  { "id": "recipe_covers", "file": "recipe_*_*.png", "usage": "Library grid + RecipeDetail" },
  { "id": "tip_covers", "file": "tip_*.png", "usage": "Home tips + TipDetail" }
]
```

---

## 生成提示词骨架

```text
Commercial mobile app content photography for Chinese solar-term seasonal cooking — {scene from row above}.
Photoreal editorial food styling, NOT UI screenshot, NOT cartoon.
Warm orange #E8833A and rice paper #F5F0E8 mood, subtle green accent #3A7D44.
No purple AI glow, no text/watermark in image.
Square or 4:3, safe for mobile crop; hero/banner leave negative space for text overlay.
```

---

## 验收

- [x] media/ 文件数 ≥ 5 内容影像 + 各 seed coverKey 独立 PNG（2026-08-25 GenerateImage 全量 96 张）
- [x] HomePage `Image($r('app.media.hero_bg'))` + 列表/详情 ≥2 处真图引用
- [x] 同语义 key 不共用同一 PNG 字节
- [x] 清单与 `SolarMedia.ets` 一致

**生成流水线**：`node scripts/build-photo-manifest.mjs` → GenerateImage → `node scripts/sync-assets-to-media.mjs`
