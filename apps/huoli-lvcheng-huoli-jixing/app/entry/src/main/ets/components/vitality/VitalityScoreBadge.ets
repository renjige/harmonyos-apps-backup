import { Theme } from '../design-system/Theme'

@Component
export struct VitalityScoreBadge {
  @Prop score: number = 0

  build() {
    Stack() {
      Progress({ value: this.score, total: 9, type: ProgressType.Ring })
        .width(76)
        .height(76)
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .style({ strokeWidth: 7 })

      Column({ space: 0 }) {
        Text(`${this.score}`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Text('活力')
          .fontSize(11)
          .fontColor(Theme.colors().textSecondary)
      }
    }
    .width(76)
    .height(76)
  }
}
