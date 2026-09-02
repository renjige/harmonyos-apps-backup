import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { InsightItem } from '../../models/AskModels'
import { AskBizService } from '../../services/AskBizService'
import { AskMedia } from '../../services/AskMedia'
import { AskNav } from '../../services/AskNav'

class CatalogStat {
  category: string = ''
  count: number = 0
}

@Component
export struct VaultPlatformSection {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State total: number = 0
  @State stats: CatalogStat[] = []
  @State featured: InsightItem[] = []

  aboutToAppear(): void {
    void this.load()
  }

  onRefreshTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const all = await AskBizService.loadInsights()
    this.total = all.length
    this.stats = VaultPlatformSection.buildStats(all)
    const picks: InsightItem[] = []
    for (let i = 0; i < all.length && i < 6; i++) {
      picks.push(all[i])
    }
    this.featured = picks
  }

  private static buildStats(all: InsightItem[]): CatalogStat[] {
    const cats: string[] = ['生活百科', '科普知识', '历史文化', '学习知识', '健康常识', '趣味知识']
    const rows: CatalogStat[] = []
    for (const cat of cats) {
      let n = 0
      for (const row of all) {
        if (row.category === cat) {
          n += 1
        }
      }
      const item = new CatalogStat()
      item.category = cat
      item.count = n
      rows.push(item)
    }
    return rows
  }

  private openCategory(cat: string): void {
    AppStorage.setOrCreate('catalogCategory', cat)
    AskNav.openLearn('catalog')
  }

  private openItem(item: InsightItem): void {
    AskNav.openDetail('insight', item.id)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: 2 }) {
          Text('平台知识百科')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          Text(`${this.total} 条结构化解答 · 6 大分类 · 可检索可收藏`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text('全部')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
          .onClick((): void => { AskNav.openLearn('catalog') })
      }
      .width('100%')

      Grid() {
        ForEach(this.stats, (row: CatalogStat) => {
          GridItem() {
            Row({ space: Theme.space.s2 }) {
              Text(`${row.count}`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
              Text(row.category)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .maxLines(1)
                .layoutWeight(1)
            }
            .width('100%')
            .height(48)
            .padding({ left: Theme.space.s3, right: Theme.space.s3 })
            .alignItems(VerticalAlign.Center)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { this.openCategory(row.category) })
          }
        }, (row: CatalogStat) => row.category)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(Theme.space.s2)
      .rowsGap(Theme.space.s2)
      .width('100%')

      Text('精选条目')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        .width('100%')

      ForEach(this.featured, (item: InsightItem) => {
        Row({ space: Theme.space.s3 }) {
          Image(AskMedia.resource(item.coverKey))
            .width(56)
            .height(56)
            .borderRadius(Theme.radius.sm)
            .objectFit(ImageFit.Cover)
          Column({ space: 4 }) {
            Text(item.title)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .maxLines(2)
            Text(item.category)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
        .borderRadius(Theme.radius.card)
        .onClick((): void => { this.openItem(item) })
      }, (item: InsightItem) => item.id)
    }
    .width('100%')
  }
}
