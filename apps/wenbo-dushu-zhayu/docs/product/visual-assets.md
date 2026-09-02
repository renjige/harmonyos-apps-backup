# 读书札语 · 视觉资产

> 流水线：`knowledge/design-system/prompts/visual-asset-pipeline.md`  
> `productVisualType`: content-commerce（阅读内容管理，Hero + 封面 + 栏目图）

| 文件 | 用途 | 场景 |
|------|------|------|
| `hero_reading_desk.png` | 首页 Hero | 书桌阅读主视觉，顶部/底部留文案空间 |
| `checkin_morning.png` | 打卡 Hero | 晨读打卡氛围，叠字遮罩 |
| `hero_reading_classics.png` | 精选封面 | 读书破万卷 |
| `hero_borrow_books.png` | 精选封面 | 书非借不能读 |
| `hero_honest_reading.png` | 精选封面 | 诚实阅读 |
| `hero_poetry_grace.png` | 精选封面 | 腹有诗书 |
| `hero_dialogue_books.png` | 精选封面 | 与高尚的人谈话 |
| `hero_ladder_books.png` | 精选封面 | 进步的阶梯 |
| `book_classics_1.png` | 示例书目 | 《活着》 |
| `book_classics_2.png` | 示例书目 | 《百年孤独》 |
| `book_classics_3.png` | 示例书目 | 《苏菲的世界》 |
| `book_classics_4.png` | 示例书目 | 《人类简史》 |
| `book_classics_5.png` | 示例书目 | 《瓦尔登湖》 |
| `book_classics_6.png` | 示例书目 | 《思考，快与慢》 |
| `book_default.png` | 自添书籍默认封面 | 用户新增书籍 |
| `booklist_growth.png` | 专题书单 | 成长书单 |
| `booklist_travel.png` | 专题书单 | 旅行书单 |
| `booklist_family.png` | 专题书单 | 亲子阅读 |
| `booklist_classics.png` | 专题书单 | 经典文学 |
| `note_scene_desk.png` | 笔记配图 | 书桌现场 |
| `note_scene_window.png` | 笔记配图 | 窗边阅读 |
| `note_scene_lamp.png` | 笔记配图 | 灯下阅读 |
| `review_cover.png` | 书评 Hero | 书评封面 |
| `inspiration_cover.png` | 灵感 Hero | 思考库封面 |
| `monthly_review.png` | 月度回顾 Hero | 读书回顾 |
| `lamp_session.png` | 灯下共读 Hero | 夜灯陪读仪式，底部留文案空间 |
| `dialogue_pair.png` | 对读札 Hero | 两本书对开如对话 |

目录：`app/entry/src/main/resources/base/media/`  
映射：`ReadingMedia.coverMedia()` 一 key 一图，禁止共图。  
本 App 无独立资讯模块，封面配额由精选荐书 / 专题书单 / 笔记场景图承担。
