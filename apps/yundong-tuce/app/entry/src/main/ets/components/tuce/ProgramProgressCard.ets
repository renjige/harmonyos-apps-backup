import { Theme } from '../design-system/Theme'
import { ProgramItem } from '../../models/TuceModels'
import { TuceEngine } from '../../services/TuceEngine'

@Component
export struct ProgramProgressCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop program: ProgramItem = new ProgramItem()
  onTap: () => void = () => {}

  private doneCount(): number {
    return TuceEngine.splitIdsSafe(this.program.doneDates).length
  }

  private pct(): number {
    if (this.program.days <= 0) {
      return 0
    }
    return Math.min(1, this.doneCount() / this.program.days)
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.program.name)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`已坚持 ${this.doneCount()} / ${this.program.days} 天`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Stack() {
          Progress({ value: this.pct() * 100, total: 100, type: ProgressType.Ring })
            .width(52)
            .height(52)
            .color(Theme.colors().brandPrimary)
            .style({ strokeWidth: 6 })
          Text(`${Math.round(this.pct() * 100)}`)
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
        }
      }
      .width('100%')
      Progress({ value: this.pct() * 100, total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(6)
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .style({ strokeWidth: 6 })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.onTap() })
  }
}
