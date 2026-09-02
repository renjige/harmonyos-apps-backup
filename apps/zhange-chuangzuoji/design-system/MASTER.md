# 展格创作集 — Design System MASTER

> 来源：`ui-ux-pro-max` · Portfolio/Personal · Motion-Driven + Minimalism  
> Dials：variance=3 · motion=4 · density=4（留白优先）

## Pattern

**Portfolio Grid** — Hero（姓名/角色）→ 分类筛选 → 2 列作品网格 → 关于/联系

## Colors

| Token | Light | Dark |
|-------|-------|------|
| `--brand-primary` | `#2C3E6B` | `#4A6FA5` |
| `--brand-accent` | `#C9A84C` | `#D4B86A` |
| `--surface-page` | `#F5F6F8` | `#0D0D0D` |
| `--surface-card` | `#FFFFFF` | `#1C1C1E` |
| `--text-primary` | `#1A2332` | `#F5F6F8` |
| `--text-secondary` | `#6B7280` | `#9CA3AF` |

## Typography（HarmonyOS Sans）

- Hero：title2 Bold
- 卡片标题：subhead Medium
- 正文：body Regular，行高 22–24
- 标签：caption

## Spacing（8vp  rhythm）

- pageX/Y：16vp
- section：32vp
- card padding：16vp
- grid gutter：12vp

## Motion

- 卡片点击：scale 0.96 → 1.0，150ms
- 列表滚动：EdgeEffect.Spring
- 主题切换：240ms

## Anti-patterns（禁止）

- 工厂六件套（三 KPI + 宫格 + AI 横幅）
- 纯色/渐变冒充作品封面
- 底栏图标压扁、热区 < 44vp
- 浅底 `#94A3B8` 正文

## Components

- **TabBar**：浮动圆角胶囊容器 + 选中底 + Symbol 显色
- **ProjectCard**：16:9 封面 + 标题 + 分类标签 + 按压缩放
- **HeroBanner**：摄影底 + scrim + 短文案（1–2 帧 Editorial）
