import { Theme } from '../design-system/Theme'
import { DailyStats } from '../../models/DailyModels'

@Component
export struct StatisticsCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop stats: DailyStats = new DailyStats()

  build() {
    Row({ space: Theme.space.s3 }) {
      this.StatCell('连续打卡', `${this.stats.streakDays}`, '天')
      this.StatCell('心情记录', `${this.stats.totalMoods}`, '条')
      this.StatCell('收藏句子', `${this.stats.favoriteCount}`, '句')
    }
    .width('100%')
  }

  @Builder
  StatCell(label: string, value: string, unit: string) {
    Column({ space: 4 }) {
      Row({ space: 2 }) {
        Text(value)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Text(unit)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .margin({ top: 8 })
      }
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .alignItems(HorizontalAlign.Center)
  }
}
