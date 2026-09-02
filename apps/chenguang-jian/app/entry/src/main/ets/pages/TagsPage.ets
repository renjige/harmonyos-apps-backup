import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { EssayListCard } from '../components/essay/EssayListCard'
import { CatalogItem, EssayItem, TagStat } from '../models/EssayModels'
import { DawnMedia } from '../services/DawnMedia'
import { EssayBizService } from '../services/EssayBizService'
import { EssayNav } from '../services/EssayNav'
import { EssayStore } from '../services/EssayStore'

@Component
export struct TagsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @StorageLink('filterTag') @Watch('onFilterTag') pendingTag: string = ''
  @State stats: TagStat[] = []
  @State presets: CatalogItem[] = []
  @State filter: string = ''
  @State filtered: EssayItem[] = []
  @State maxCount: number = 1

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onFilterTag(): void {
    if (this.pendingTag.length > 0) {
      this.applyFilter(this.pendingTag)
      AppStorage.setOrCreate('filterTag', '')
    }
  }

  private async reload(): Promise<void> {
    this.stats = EssayStore.tagStats()
    this.maxCount = 1
    for (const s of this.stats) {
      if (s.count > this.maxCount) {
        this.maxCount = s.count
      }
    }
    this.presets = await EssayBizService.loadTagCatalog()
    const pending = AppStorage.get<string>('filterTag') ?? ''
    if (pending.length > 0) {
      this.applyFilter(pending)
      AppStorage.setOrCreate('filterTag', '')
    } else if (this.filter.length > 0) {
      this.applyFilter(this.filter)
    }
  }

  private applyFilter(tag: string): void {
    this.filter = tag
    this.filtered = EssayStore.byTag(tag)
  }

  private fontOf(count: number): number {
    if (this.maxCount <= 1) {
      return 16
    }
    const ratio = count / this.maxCount
    if (ratio > 0.7) {
      return 26
    }
    if (ratio > 0.4) {
      return 20
    }
    return 14
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(DawnMedia.cover('banner_gold_beam'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
            Column() {
              Text('全部标签')
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
              Text('字越大，写过的次数越多')
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 16 })
            .linearGradient({
              angle: 180,
              colors: [['rgba(61,50,40,0)', 0], ['rgba(61,50,40,0.72)', 1]]
            })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .borderRadius(Theme.radius.lg)
          .clip(true)

          if (this.stats.length === 0) {
            AppEmpty({
              title: '标签云还是空的',
              description: '写一张笺，智慧标签会慢慢长出来。'
            })
          } else {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
              ForEach(this.stats, (s: TagStat) => {
                Text(s.name)
                  .fontSize(this.fontOf(s.count))
                  .fontColor(this.filter === s.name ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 10 })
                  .backgroundColor(this.filter === s.name ?
                    Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.applyFilter(s.name) })
              }, (s: TagStat) => s.name)
            }
            .width('100%')
          }

          if (this.presets.length > 0) {
            Text('栏目标签')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            ForEach(this.presets, (p: CatalogItem) => {
              Row() {
                Text(p.title)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text('详情')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { EssayNav.openDetail('tag', p.id) })
            }, (p: CatalogItem) => p.id)
          }

          if (this.filter.length > 0) {
            Text(`含「${this.filter}」的笺`)
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.filtered.length === 0) {
              AppEmpty({ title: '还没有写过这个标签', description: '去笺集写一张新的吧。' })
            } else {
              ForEach(this.filtered, (it: EssayItem) => {
                EssayListCard({
                  item: it,
                  onTap: (): void => { EssayNav.openDetail('essay', it.id) }
                })
              }, (it: EssayItem) => it.id)
            }
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
