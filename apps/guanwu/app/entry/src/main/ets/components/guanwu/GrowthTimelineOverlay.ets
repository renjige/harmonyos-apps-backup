import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { ActivityEvent } from '../../models/ActivityModels'

@Component
export struct GrowthTimelineOverlay {
  @Prop events: ActivityEvent[] = []
  onClose: () => void = () => {}
  onOpenRecord: (id: string) => void = () => {}
  onOpenSubject: (id: string) => void = () => {}

  build() {
    Column() {
      Row() {
        Text('我的轨迹')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        AppButton({ label: '关闭', variant: 'ghost', onTap: (): void => this.onClose() })
      }
      .width('100%')
      .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4 })

      if (this.events.length === 0) {
        AppEmpty({
          title: '还没有轨迹',
          description: '记录、打卡、收藏或建档后，这里会串联你的成长历史',
          actionLabel: '去记录',
          onAction: (): void => this.onClose()
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.events, (ev: ActivityEvent) => {
              Column({ space: 4 }) {
                Text(ev.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(ev.summary)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Text(`${ev.dateKey}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => {
                if (ev.type === 'record' || ev.type === 'record_edit' || ev.type === 'favorite') {
                  if (ev.refId.length > 0) {
                    this.onOpenRecord(ev.refId)
                  }
                } else if (ev.type === 'atlas' && ev.refId.length > 0) {
                  this.onOpenSubject(ev.refId)
                }
              })
            }, (ev: ActivityEvent) => ev.id)
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s8 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
