# 时光档案 · 视觉资产清单

**productVisualType**: `ops-tool`  
**品牌色**: primary `#182333` · accent `#C99855` · background `#F7F6F2`

| 文件名 | 用途 | 场景描述 |
|--------|------|---------|
| `hero_ambient.png` | 时光总览 Hero / 档案详情 Hero | 暖色纸张质感、档案盒与柔和侧光，墨蓝+#C99855 点缀，留底部渐变空间叠字 |
| `empty_archive.png` | 空态插图 | 空置档案架/文件夹，温和商务氛围，非卡通 |

## 落盘路径

```
app/entry/src/main/resources/base/media/hero_ambient.png
app/entry/src/main/resources/base/media/empty_archive.png
```

## UI 引用

- `OverviewPage` → `$r('app.media.hero_ambient')` + `$r('app.media.empty_archive')`
- `ArchiveDetailPane` → `$r('app.media.hero_ambient')`

## 最少张数

ops-tool 类型 ≥2 张内容影像（已满足）。
