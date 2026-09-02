# 视觉资产 · 露营课堂

| 文件 | 用途 | 场景 |
|------|------|------|
| `hero_camp_night.png` | 首页 Hero | 星空下的帐篷营地，底部留白叠字 |
| `banner_pack.png` | 装备区块氛围 | 铺陈的背包与露营装备 |
| `guide_tent.png` | 课程封面 | 搭帐篷教学 |
| `guide_rain.png` | 课程封面 | 雨天露营避坑 |
| `guide_cook.png` | 课程封面 | 户外炊具与营地做饭 |
| `guide_stars.png` | 课程封面 | 星空观测露营 |
| `guide_kids.png` | 课程封面 | 亲子露营场景 |
| `guide_altitude.png` | 课程封面 | 高海拔营地 |
| `tpl_newbie.png` | 装备模板 | 新手过夜套装 |
| `tpl_ultralight.png` | 装备模板 | 轻量徒步套装 |
| `tpl_family.png` | 装备模板 | 家庭露营套装 |

- **productVisualType**：`content-commerce`
- **品牌色**：森林绿 `#16A34A` + 暖阳橙 `#FB923C`
- **生成方式**：Cursor `GenerateImage` 商业摄影（2026-08-25 替换 procedural 色块）；备用脚本 `store/render_camp_media.mjs` 仅作占位
- **上架图标**：`store/logo/preview-1024.png`
- 摄影 Hero 叠字须加底部 scrim；功能图标走 HarmonyOS Symbol（`AppIcon`）
- 列表/空态文案 Emoji 走 `CampEmojiUtil`（非功能图标）
