import { Theme } from '../design-system/Theme'

@Component
export struct HomeGoalCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop weekDone: number = 0
  @Prop weekTarget: number = 50
  onOpen: () => void = () => {}

  private pct(): number {
    if (this.weekTarget <= 0) {
      return 0
    }
    const p = Math.floor((this.weekDone / this.weekTarget) * 100)
    return p > 100 ? 100 : p
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('本周目标')
        .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`${this.weekDone} / ${this.weekTarget} 题 · ${this.pct()}%`)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Stack({ alignContent: Alignment.Start }) {
        Row().width('100%').height(8).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(99)
        Row().width(`${this.pct()}%`).height(8)
          .backgroundColor(Theme.colors().brandPrimary).borderRadius(99)
      }
      .width('100%').height(8)
    }
    .width('100%').padding(Theme.space.s4).alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(() => this.onOpen())
  }
}
