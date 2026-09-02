import { Theme } from '../design-system/Theme'

@Component
export struct CoolIndexRing {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop score: number = 60
  @Prop label: string = '清凉指数'
  @Prop ringSize: number = 160

  private ringColor(): string {
    if (this.score >= 75) {
      return Theme.colors().brandPrimary
    }
    if (this.score >= 50) {
      return Theme.colors().brandAccent
    }
    return Theme.colors().warning
  }

  build() {
    Stack() {
      Progress({
        value: this.score,
        total: 100,
        type: ProgressType.Ring
      })
        .width(this.ringSize)
        .height(this.ringSize)
        .color(this.ringColor())
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .style({ strokeWidth: 10 })

      Column({ space: 4 }) {
        Text(`${this.score}`)
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.label)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
    }
    .width(this.ringSize)
    .height(this.ringSize)
  }
}
