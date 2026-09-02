import { Theme } from '../design-system/Theme'
import { DutySlot, SceneTip } from '../../models/JujiaModels'

@Component
export struct SceneTipBlock {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop tips: SceneTip[] = []
  onAction: (code: string) => void = (_c: string) => {}

  build() {
    if (this.tips.length > 0) {
      Column({ space: 8 }) {
        Text('智慧场景')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.tips, (tip: SceneTip) => {
          Column({ space: 4 }) {
            Text(tip.title)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(tip.body)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.onAction(tip.action))
        }, (tip: SceneTip) => tip.id)
      }
      .width('100%')
    }
  }
}

@Component
export struct DutyStampBlock {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop slots: DutySlot[] = []
  @Prop stamps: number = 0
  onOpenMembers: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('今日轮值')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('家人')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => this.onOpenMembers())
      }
      .width('100%')

      if (this.slots.length === 0) {
        Text('添加家人后，倒垃圾 / 洗碗 / 浇花会按星期自动轮值。')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding(12)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.onOpenMembers())
      } else {
        ForEach(this.slots, (slot: DutySlot) => {
          Row() {
            Text(slot.chore)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Text(slot.memberName)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }, (slot: DutySlot) => `${slot.weekday}_${slot.chore}`)
      }

      Text(`本周盖章 ${this.stamps} / 7`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: 6 }) {
        ForEach([0, 1, 2, 3, 4, 5, 6], (i: number) => {
          Column() {
            Text(i < this.stamps ? '章' : '·')
              .fontSize(8)
              .fontColor(i < this.stamps ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          }
            .width(28)
            .height(28)
            .borderRadius(14)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(i < this.stamps ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
        }, (i: number) => `st_${i}`)
      }
      .width('100%')
    }
    .width('100%')
  }
}
