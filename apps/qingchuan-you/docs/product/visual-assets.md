# 晴川游 内容影像清单

productVisualType：`content-commerce`  
最少张数：≥5（本 App 已出 Hero / Banner / 8 目的地 / 6 灵感 / 6 笔记封面）

| 文件 | 用途 | 场景 |
|---|---|---|
| hero_bg.png | 首页氛围 / 回退封面 | 晴日山川远景，留上部或下部负空间 |
| banner_01.png | 首页 Banner | 湖岸晨雾，可叠标题 |
| banner_02.png | 首页 Banner | 暖阳下山脊轮廓 |
| dest_westlake.png | 杭州西湖 | 湖堤柳与春水 |
| dest_zhangjiajie.png | 张家界 | 石峰与云 |
| dest_chengdu.png | 成都 | 巷口茶馆与市井 |
| dest_dunhuang.png | 敦煌 | 沙丘与黄昏轮廓 |
| dest_huangshan.png | 黄山 | 松与云海 |
| dest_xian.png | 西安 | 城墙与暮色 |
| dest_dali.png | 大理 | 洱海岸线 |
| dest_qingdao.png | 青岛 | 红瓦坡路与海 |
| insp_lake.png | 灵感：湖 | 湖面倒影 |
| insp_peaks.png | 灵感：峰林 | 远峰层叠 |
| insp_chengdu.png | 灵感：市井 | 巷口餐桌 |
| insp_desert.png | 灵感：沙漠 | 沙脊线条 |
| insp_wall.png | 灵感：城墙 | 砖墙与光 |
| insp_sea.png | 灵感：海 | 浪与防波堤 |
| note_westlake.png | 笔记封面 | 湖边手记氛围 |
| note_valley.png | 笔记封面 | 谷中步道 |
| note_tea.png | 笔记封面 | 茶席 |
| note_spring.png | 笔记封面 | 春花小径 |
| note_xian.png | 笔记封面 | 古城巷 |
| note_qingdao.png | 笔记封面 | 海边石阶 |

品牌 Logo 不在本清单，见 `store/logo/` 与 `app-logo.mdc`。

落盘：`app/entry/src/main/resources/base/media/{name}.png`  
页面引用：`ScenicMedia.resource(key)` → `Image($r('app.media.xxx'))`，一 key 一图。
