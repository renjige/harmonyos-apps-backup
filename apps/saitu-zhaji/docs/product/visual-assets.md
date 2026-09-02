# 赛途札记 — 视觉资产清单

`productVisualType`: **ops-tool**（最少 2 张内容影像）

| 文件名 | 用途 | 场景描述 |
|--------|------|----------|
| `hero_ambient.png` | 看板 Hero / 详情无图兜底 / 列表缩略占位 | 赛途公路与跑道氛围，品牌蓝 #007AFF 色调，底部留白叠字 |
| `empty_trail.png` | 记录页空态 Hero | 静谧山径空镜，引导用户写第一条札记 |

## 登记（AppSpec.brand.visualAssets）

- `hero_ambient` → `$r('app.media.hero_ambient')` — 看板、详情 Hero
- `empty_trail` → `$r('app.media.empty_trail')` — 记录空态

## Logo（独立流水线）

见 `store/logo/` · 上架合成图：`store/logo/preview-1024.png`（render 后生成）
