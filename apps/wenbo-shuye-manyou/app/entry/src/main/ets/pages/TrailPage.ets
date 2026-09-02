import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { ReadLogEntry, RoamStats, RoamTime, ThemeTagCount } from '../models/RoamModels'
import { RoamBizService } from '../services/RoamBizService'
import { RoamStore } from '../services/RoamStore'

@Component
export struct TrailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State stats: RoamStats = new RoamStats()
  @State timeline: ReadLogEntry[] = []
  @State tags: ThemeTagCount[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await RoamBizService.loadExcerpts()
    this.stats = RoamStore.stats()
    this.timeline = RoamStore.sortedReadLog()
    this.tags = RoamStore.themeTags()
  }

  @Builder
  TagChip(tag: ThemeTagCount) {
    Text(`${tag.tag} · ${tag.count}`)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('阅读轨迹')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({ label: '收藏', value: `${this.stats.favorites}` }).layoutWeight(1)
          AppStatCard({ label: '稍后读', value: `${this.stats.readLater}` }).layoutWeight(1)
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({ label: '已读完', value: `${this.stats.finished}` }).layoutWeight(1)
          AppStatCard({ label: '笔记', value: `${this.stats.notes}` }).layoutWeight(1)
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('主题关键词')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.tags.length === 0) {
            Text('收藏或标记读完后，这里会出现你的阅读主题。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(this.tags, (tag: ThemeTagCount) => {
                this.TagChip(tag)
              }, (tag: ThemeTagCount) => tag.tag)
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        Column({ space: Theme.space.s3 }) {
          Text('时间线')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.timeline.length === 0) {
            AppEmpty({
              title: '还没有阅读足迹',
              description: '在首页收藏、稍后读或标记读完，轨迹会出现在这里。'
            })
          } else {
            ForEach(this.timeline, (row: ReadLogEntry) => {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  Text('●')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandAccent)
                }
                .width(16)
                Column({ space: 4 }) {
                  Text(`${row.actionLabel()} · ${row.bookTitle}`)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(row.theme.length > 0 ? row.theme : '阅读记录')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  Text(RoamTime.formatDateTime(row.at))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
            }, (row: ReadLogEntry) => row.id)
          }
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
