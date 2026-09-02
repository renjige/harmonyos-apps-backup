import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { TagCount } from '../models/YouyuModels'
import { YouyuMedia } from '../services/YouyuMedia'
import { YouyuNav } from '../services/YouyuNav'
import { YouyuStore } from '../services/YouyuStore'

@Component
export struct StatsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('youyuRev') @Watch('onStoreRev') storeRev: number = 0
  @StorageLink('youyuShowCompose') @Watch('onComposeClosed') showCompose: boolean = false
  @State total: number = 0
  @State streak: number = 0
  @State monthCount: number = 0
  @State tagRows: TagCount[] = []
  @State listEpoch: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onStoreRev(): void {
    this.reload()
  }

  onComposeClosed(): void {
    if (!this.showCompose) {
      this.reload()
    }
  }

  private tagRowKey(row: TagCount): string {
    return `${row.id}_${row.count}`
  }

  private reload(): void {
    const s = YouyuStore.stats()
    this.total = s.total
    this.streak = s.streak
    this.monthCount = s.monthCount
    const rows: TagCount[] = []
    for (const row of s.tags) {
      const copy = new TagCount()
      copy.id = row.id
      copy.name = row.name
      copy.count = row.count
      rows.push(copy)
    }
    this.tagRows = rows
    this.listEpoch += 1
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('纪事')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Image(YouyuMedia.coverLamp())
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Row({ space: Theme.space.s3 }) {
          Column({ space: 6 }) {
            Text(`${this.total}`)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('总记录')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding({ top: 16, bottom: 16 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)

          Column({ space: 6 }) {
            Text(`${this.streak}`)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('连续天')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding({ top: 16, bottom: 16 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)

          Column({ space: 6 }) {
            Text(`${this.monthCount}`)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('本月')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding({ top: 16, bottom: 16 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
        }
        .width('100%')
        .key(`stats_cards_${this.listEpoch}_${this.storeRev}`)

        Row() {
          Text('我的标签')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('管理')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().brandDeep)
            .padding({ left: 12, right: 12, top: 12, bottom: 12 })
            .onClick(() => YouyuNav.openTags())
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          ForEach(this.tagRows, (row: TagCount) => {
            Row() {
              Text(row.name)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Text(`${row.count} 条`)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
          }, (row: TagCount) => this.tagRowKey(row))
        }
        .width('100%')
        .key(`stats_tags_${this.listEpoch}_${this.storeRev}`)

        Blank().height(Theme.space.s10)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s6
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
