import { Theme } from '../design-system/Theme'

@Component
export struct ProgressRing {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop progress: number = 0
  @Prop ringSize: number = 120
  @Prop strokeWidth: number = 10

  build() {
    Stack() {
      Progress({ value: this.progress, total: 100, type: ProgressType.Ring })
        .width(this.ringSize)
        .height(this.ringSize)
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .style({ strokeWidth: this.strokeWidth })
      Column({ space: 2 }) {
        Text(`${Math.round(this.progress)}%`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('今日完成')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
    }
  }
}
