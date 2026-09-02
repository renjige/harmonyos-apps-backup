# 书页漫游 — 内容影像清单

`productVisualType`: **content-commerce**（≥5 张，不含 Logo）

品牌色：primary `#8B6B4D` · accent `#C0392B` · bg tint `#D4C5A9` · deep `#2D4A3E`

| 文件名 | 用途 | 场景描述 |
|--------|------|----------|
| `hero_home.png` | 首页氛围 Hero | 窗边打开的书页与暖光，留底部文字区；暖棕色调 |
| `banner_city.png` | 书单「城市漫游」封面 | 城市街角窗口与书堆，编辑摄影风 |
| `banner_winter.png` | 书单「冬日书单」封面 | 暖气旁阅读，冬夜暖光 |
| `cover_literature.png` | 文学类节选/书籍封面 | 经典文学书籍静物，暖棕纸质感 |
| `cover_philosophy.png` | 哲思类节选/书籍封面 | 思辨感书桌与笔记本 |
| `cover_history.png` | 历史类节选/书籍封面 | 古籍与地图元素，沉稳色调 |

落盘路径：`app/entry/src/main/resources/base/media/{name}.png`

App 引用：`RoamMedia.resource(coverKey)` → `$r('app.media.*')`  
平台 seed `coverKey` 与 media 文件名一一对应，禁止共图。

**状态**：PNG 待 GenerateImage 生成；代码已引用上述文件名。
