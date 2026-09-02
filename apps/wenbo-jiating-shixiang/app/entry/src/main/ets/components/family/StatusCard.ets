import { Theme } from '../design-system/Theme'

@Component
export struct StatusCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop pending: number = 0
  @Prop done: number = 0
  @Prop rate: number = 0

  private mood(): string {
    if (this.pending === 0 && this.done === 0) {
      return '今天的时间，留一点给自己。'
    }
    if (this.pending === 0) {
      return '家里又井井有条了一天。'
    }
    if (this.rate >= 70) {
      return '节奏刚好，剩下的也可以慢慢做。'
    }
    return '今天很从容，慢慢完成即可。'
  }

  private headline(): string {
    if (this.pending === 0 && this.done > 0) {
      return '今日事项全部完成'
    }
    return '今日家庭事项'
  }

  build() {
    Column({ space: 16 }) {
      Text(this.headline())
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row() {
        Column() {
          Text(`${this.pending}`)
            .fontSize(Theme.type.displayS)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('今日待处理')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Column() {
          Text(`${this.done}`)
            .fontSize(Theme.type.titleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('已完成')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Stack({ alignContent: Alignment.Center }) {
          Progress({ value: this.rate, total: 100, type: ProgressType.Ring })
            .width(76)
            .height(76)
            .color(Theme.colors().brandPrimary)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
          Text(`${this.rate}%`)
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Text(this.mood())
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .shadow({ radius: 12, color: 'rgba(36,68,58,0.08)', offsetX: 0, offsetY: 4 })
  }
}
