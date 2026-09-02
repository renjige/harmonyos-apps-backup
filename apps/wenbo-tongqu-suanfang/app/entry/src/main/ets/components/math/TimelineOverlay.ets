import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { TimeEvent } from '../../models/MathModels'
import { MathBizService } from '../../services/MathBizService'

@Component
export struct TimelineOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('mathHomeTick') @Watch('onTick') dataTick: number = 0
  @State events: TimeEvent[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.events = MathBizService.timeline()
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('练习时间轴')
          .fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%').padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

      if (this.events.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有足迹',
            description: '完成一组练习后，这里会按日期排下来'
          })
        }
        .layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.events, (e: TimeEvent) => {
            ListItem() {
              Column({ space: Theme.space.s1 }) {
                Text(e.date)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(e.title)
                  .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(e.hint)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%').padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .margin({ bottom: Theme.space.s3 })
            }
          }, (e: TimeEvent) => e.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s8 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
