import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { FreeSlot } from '../../models/AppointmentModels'

@Component
export struct SlotFinderOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop slots: FreeSlot[] = []
  @Prop durationMin: number = 60
  onClose: () => void = () => {}
  onDuration: (mins: number) => void = () => {}
  onPick: (slot: FreeSlot) => void = () => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('找空档')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text(' ')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('按时长扫描未来 7 天，点选即可新建约定')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row({ space: 8 }) {
            ForEach([30, 60, 90, 120], (mins: number) => {
              Text(mins < 60 ? `${mins} 分` : `${mins / 60} 小时`)
                .fontSize(Theme.type.caption)
                .fontColor(this.durationMin === mins ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.durationMin === mins ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.onDuration(mins) })
            }, (mins: number) => `d_${mins}`)
          }
          .width('100%')

          if (this.slots.length === 0) {
            Text('近 7 天没有足够空档，可缩短时长或改期现有约定')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.slots, (slot: FreeSlot) => {
              Row() {
                Text(slot.label)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text('占用')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .onClick((): void => { this.onPick(slot) })
            }, (slot: FreeSlot) => `${slot.date}_${slot.time}`)
          }
          AppButton({ label: '关闭', variant: 'secondary', onTap: (): void => { this.onClose() } })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
