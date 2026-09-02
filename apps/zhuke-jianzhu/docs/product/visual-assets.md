# Visual Assets — 筑科建筑（industrial-field / construction-showcase）

> 流水线：`knowledge/design-system/prompts/visual-asset-pipeline.md`  
> 工厂规则：`factory/rules/MOCK_VISUAL_ASSETS.md` §5.2 建筑工程企业展示  
> 落盘：`app/entry/src/main/resources/base/media/` · 源镜像 `store/visual/`

## 类型

- **productVisualType**：`industrial-field`
- **visualDirection**：`construction-showcase`
- **气质**：现代商务 · 蓝白 `#0B6BCB` · 建筑现场/工程摄影

## 资产清单（15 张）

| id | 文件 | 用途 | Mock imageKey / coverKey |
|----|------|------|--------------------------|
| hero_bg | hero_bg.png | 首页 Hero 氛围 | hero_bg |
| banner_landmark | banner_landmark.png | Banner 筑造城市地标 | banner_landmark |
| banner_municipal | banner_municipal.png | Banner 市政工程 | banner_municipal |
| banner_green | banner_green.png | Banner 绿色建造 | banner_green |
| project_building | project_building.png | 房建工程封面 | p1, p2, project_building |
| project_municipal | project_municipal.png | 市政工程封面 | p3, p4, project_municipal |
| project_decoration | project_decoration.png | 装饰装修封面 | p5, p6, project_decoration |
| project_landscape | project_landscape.png | 园林工程封面 | p7, p8, project_landscape |
| news_company | news_company.png | 企业新闻 | n1, n5, news_company |
| news_industry | news_industry.png | 行业资讯 | n3, n7, news_industry |
| news_project | news_project.png | 项目动态 | n2, n6, news_project |
| news_notice | news_notice.png | 通知公告 | n4, n8, news_notice |
| cert_qualification | cert_qualification.png | 资质证书 | c1–c4, cert_qualification |
| honor_trophy | honor_trophy.png | 荣誉展示 | h1–h4, honor_trophy |
| contact_office | contact_office.png | 联系页/地图 | contact_office |

## 代码引用

- `config/MediaCatalog.ets` → `$r('app.media.*')`
- `components/common/ContentCover.ets` → `Image(MediaCatalog.byKey(key))`

## 禁止项

- ❌ Banner / 工程 / 资讯 / 证书用纯色或渐变矩形代替摄影
- ❌ Mock 有 coverKey 但 media 目录无对应 PNG
- ❌ 用 Symbol 或 Emoji 代替内容影像
