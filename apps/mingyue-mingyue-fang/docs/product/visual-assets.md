# 明阅坊 · 视觉资产

> 流水线：`knowledge/design-system/prompts/visual-asset-pipeline.md`  
> 源文件：`store/visual/` · 工程引用：`app/entry/.../media/`  
> 压缩：`node store/compress_media.mjs`（640×480 书封 / 1280×720 Hero）

## 书籍封面（摄影氛围 · 每 key 独立）

| 文件 | 书目 | 视觉 |
|------|------|------|
| `book_classics_1.png` | 《活着》 | 麦田黄昏 |
| `book_classics_2.png` | 《百年孤独》 | 殖民庭院夜雨 |
| `book_classics_3.png` | 《苏菲的世界》 | 哲学信封蝴蝶 |
| `book_classics_4.png` | 《人类简史》 | 人类与星空 |
| `book_classics_5.png` | 《瓦尔登湖》 | 湖雾晨光 |
| `book_classics_6.png` | 《思考，快与慢》 | 双轨思维 |
| `book_default.png` | 用户自添 | 精装书默认 |

## 今日明悟 Hero

| 文件 | 主题 |
|------|------|
| `hero_reading_desk.png` | 书桌夜读 |
| `hero_reading_classics.png` | 经典书堆 |
| `hero_borrow_books.png` | 借阅阅读 |
| `hero_honest_reading.png` | 诚实阅读 |
| `hero_poetry_grace.png` | 诗书气质 |
| `hero_dialogue_books.png` | 与高者对话 |
| `hero_ladder_books.png` | 进步阶梯 |

笔记仍用 `SymbolCover`（无摄影图）。映射：`ReadingMedia.coverMedia()`。
