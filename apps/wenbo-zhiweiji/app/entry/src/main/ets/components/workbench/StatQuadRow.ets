import { Theme } from '../design-system/Theme'
import { CaptureStats } from '../../models/ZhiweiModels'

@Component
export struct StatQuadRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop stats: CaptureStats = new CaptureStats()

  build() {
    Row({ space: 8 }) {
      this.Cell('笔记', `${this.stats.total}`)
      this.Cell('已掌握', `${this.stats.masteredCount}`)
      this.Cell('收藏', `${this.stats.favCount}`)
      this.Cell('连续', `${this.stats.streak}天`)
    }
    .width('100%')
  }

  @Builder
  Cell(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}
