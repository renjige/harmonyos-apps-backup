import { Theme } from '../design-system/Theme'
import { WeekBar } from '../../models/SlipModels'

@Component
export struct MineLifeCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop totalDone: number = 0
  @Prop weekDone: number = 0
  @Prop streak: number = 0
  @Prop topCat: string = '生活'
  @Prop bars: WeekBar[] = []

  build() {
    Column({ space: 12 }) {
      Text('我的生活记录')
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row() {
        this.StatCell('累计完成', `${this.totalDone}`)
        this.StatCell('本周完成', `${this.weekDone}`)
        this.StatCell('连续记录', `${this.streak} 天`)
      }
      .width('100%')
      Text(`最常记录：${this.topCat}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: 6 }) {
        ForEach(this.bars, (b: WeekBar) => {
          Column({ space: 6 }) {
            Column()
              .width(10)
              .height(12 + b.done * 8)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(4)
            Text(b.label)
              .fontSize(10)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.End)
        }, (b: WeekBar) => b.label)
      }
      .width('100%')
      .height(72)
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  StatCell(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(26)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct MineReviewCard {
  @Prop weekDone: number = 0
  @Prop streak: number = 0
  @Prop topCat: string = '生活'

  build() {
    Column({ space: 8 }) {
      Text('本周生活小结')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`你完成了 ${this.weekDone} 件事情`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`最常记录：${this.topCat}`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(`本周连续记录 ${this.streak} 天`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text('给认真生活的自己，点个赞。')
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
