# 视觉资产说明 · 清凉计划

## 策略

本 App 采用 **HarmonyOS Symbol + 冰泉青渐变** 作为栏目封面与详情 Hero（`SymbolCover` / `SymbolHero`），功能图标走 `AppIcon`（官网 Symbol）。

文案点缀可用 Emoji（心情标签、空态、页眉提示），**禁止** Emoji 充当 Tab/菜单功能图标。

## 品牌色

| Token | 值 | 用途 |
|-------|-----|------|
| brandPrimary | `#2D8B7A` | 主色、Tab 选中、CTA |
| gradEnd | `#4A9E9E` | 渐变辅色 |
| scrim | `rgba(26,42,42,0.88)` | Hero 底部遮罩 |

## Logo / 上架

- 合成：`store/logo/preview-1024.png`
- 前景：`store/logo/foreground.png`
- 背景：`store/logo/background.png`
- 概念：水滴 + 嫩叶负空间

## 封面键映射（SymbolVisualUtil）

| coverKey / category | Symbol | 渐变气质 |
|---------------------|--------|----------|
| breath_calm / 平静呼吸 | heart | 深青 → 冰泉绿 |
| breath_focus / 专注呼吸 | sparkle(star) | 深蓝 → 青绿 |
| breath_sleep / 睡前呼吸 | clock | 暮蓝 |
| tea / leaf / morning | book / sparkle | 晨雾绿 |
| 语录 / mist | book | 雾湖青 |

## 对比度

- Hero 标题 `#F5FAF8` + 底部 scrim，禁止 opacity 降对比
- 副标题用 `textSecondary`，禁止 `#94A3B8` 级 tertiary 作正文
