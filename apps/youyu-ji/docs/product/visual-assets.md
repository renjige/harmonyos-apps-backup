# 视觉资产清单 — 悠隅纪

productVisualType：`content-commerce`（生活影像，窗边光 / 茶席 / 纸本）

| 文件名 | 用途 | 场景描述 |
|--------|------|----------|
| hero_window.png | 首页 Hero | 窗边晨光、纱帘、木窗台与一杯茶，顶部留叠字空间 |
| banner_tea.png | 首页 Banner | 俯拍茶盏与茶壶，暖杏米白色调 |
| banner_paper.png | 胶囊页氛围 | 打开的素纸笔记本与钢笔 |
| cover_plant.png | 详情默认封面 | 室内一隅绿植 |
| cover_lamp.png | 纪事 / 胶囊 | 夜灯木几，胡桃与暖杏 |
| empty_corner.png | 空态 / 我的 | 空窗龛与木凳，等待被填满 |

均已 GenerateImage 出图并落入 `app/entry/src/main/resources/base/media/`。
首页 `Image($r('app.media.hero_window'))` + `Image($r('app.media.banner_tea'))`，空态另引用 `empty_corner`。
各文件独立，禁止共图。
