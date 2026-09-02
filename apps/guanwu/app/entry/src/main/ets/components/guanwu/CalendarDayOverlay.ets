import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { RecordTimelineCard } from './RecordTimelineCard'
import { ObserveRecord } from '../../models/ObserveModels'

@Component
export struct CalendarDayOverlay {
  @Prop dateLabel: string = ''
  @Prop items: ObserveRecord[] = []
  onClose: () => void = () => {}
  onOpenRecord: (id: string) => void = () => {}
  onCreate: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text(`${this.dateLabel} 的记录`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        AppButton({ label: '关闭', variant: 'ghost', onTap: (): void => this.onClose() })
      }
      .width('100%')
      .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '这一天还没有记录',
          description: '补一条观察，让日历更有温度',
          actionLabel: '立即记录',
          onAction: (): void => this.onCreate()
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: ObserveRecord) => {
              RecordTimelineCard({
                record: item,
                onTap: (): void => this.onOpenRecord(item.id)
              })
            }, (item: ObserveRecord) => item.id)
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
