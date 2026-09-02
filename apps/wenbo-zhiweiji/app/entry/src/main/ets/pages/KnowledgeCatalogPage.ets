import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { DailyKnowItem } from '../models/ZhiweiModels'
import { DailyKnowCatalog } from '../services/DailyKnowCatalog'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct KnowledgeCatalogPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: DailyKnowItem[] = []
  @State keyword: string = ''
  @State filterId: string = ''
  private catIds: string[] = CategoryEmojiUtil.allIds()

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    const pool = DailyKnowCatalog.all()
    const out: DailyKnowItem[] = []
    const key = this.keyword.trim()
    for (const row of pool) {
      if (this.filterId.length > 0 && CategoryEmojiUtil.normalize(row.category) !== this.filterId) {
        continue
      }
      if (key.length > 0) {
        const blob = `${row.title}${row.body}`
        if (blob.indexOf(key) < 0) {
          continue
        }
      }
      out.push(row)
    }
    this.items = out
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => ZhiweiNav.closeKnowledgeCatalog())
        Text('知识文库')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text(`内置 ${DailyKnowCatalog.all().length} 篇可读短文，可按分类浏览并收进个人知识库。`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
            .width('100%')
          TextInput({ text: this.keyword, placeholder: '搜索文库标题或正文' })
            .width('100%')
            .height(44)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .placeholderColor(Theme.colors().textTertiary)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => {
              this.keyword = v
              this.reload()
            })
          Flex({ wrap: FlexWrap.Wrap }) {
            this.CatChip('', '全部分类')
            ForEach(this.catIds, (id: string) => {
              this.CatChip(id, CategoryEmojiUtil.chipLabel(id))
            }, (id: string) => `kc_${id}`)
          }
          .width('100%')
          if (this.items.length === 0) {
            AppEmpty({ title: '没有匹配文章', description: '换个关键词或分类试试。' })
          } else {
            ForEach(this.items, (row: DailyKnowItem) => {
              Row({ space: 10 }) {
                Column({ space: 4 }) {
                  Text(row.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                  Text(CategoryEmojiUtil.chipLabel(row.category))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colorOf(this.themeEpoch).textSecondary })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onClick(() => ZhiweiNav.openDaily(row.id))
            }, (row: DailyKnowItem) => row.id)
          }
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }

  @Builder
  CatChip(id: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filterId === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.filterId === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.filterId = id
        this.reload()
      })
  }
}
