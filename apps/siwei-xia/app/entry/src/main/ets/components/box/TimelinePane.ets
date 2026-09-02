import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { TimelineEvent } from '../../models/SparkLinkModels'
import { TimelineInsightService } from '../../services/TimelineInsightService'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct TimelinePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReloadChange') reloadToken: number = 0
  @State items: TimelineEvent[] = []
  onClose: () => void = () => {}
  onOpenCard: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onReloadChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await TimelineInsightService.timeline(80)
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('思考时间线')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')
      .padding({ top: Theme.space.s3, bottom: Theme.space.s3 })

      Text('按时间串联灵感与加工记录，看见想法如何被推进。')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.items.length === 0) {
            AppEmpty({ title: '时间线还是空的', description: '记下灵感或进入思考工坊加工后会出现在这里' })
          } else {
            ForEach(this.items, (e: TimelineEvent) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text(TimelineInsightService.kindLabel(e.kind))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandOnPrimary)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.pill)
                  Text(DateHelper.formatShort(e.at))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .width(72)
                Column({ space: 4 }) {
                  Text(e.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(e.subtitle)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => {
                if (e.cardId.length > 0) {
                  this.onOpenCard(e.cardId)
                }
              })
            }, (e: TimelineEvent) => `${e.id}|${e.at}`)
          }
        }
        .padding({ bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.On)
    }
    .width('100%')
    .height('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
