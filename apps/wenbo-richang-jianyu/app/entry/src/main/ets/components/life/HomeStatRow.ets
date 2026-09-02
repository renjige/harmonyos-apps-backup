import { Theme } from '../design-system/Theme'

@Component
export struct HomeStatRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop diaryCount: number = 0
  @Prop doneCount: number = 0
  @Prop favoriteCount: number = 0
  @Prop streakDays: number = 0

  build() {
    Row({ space: Theme.space.s2 }) {
      this.Cell('创作', `${this.diaryCount}`)
      this.Cell('任务', `${this.doneCount}`)
      this.Cell('收藏', `${this.favoriteCount}`)
      this.Cell('连续', `${this.streakDays}天`)
    }
    .width('100%')
  }

  @Builder
  Cell(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: Theme.space.s3, bottom: Theme.space.s3 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
