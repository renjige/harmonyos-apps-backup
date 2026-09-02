import { Theme } from '../design-system/Theme'
import { SportStats } from '../../models/SportRecord'

@Component
export struct StatsOverviewCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop stats: SportStats = new SportStats()
  @Prop periodLabel: string = '本月'

  build() {
    Column({ space: 0 }) {
      Row() {
        Text(this.periodLabel)
          .fontSize(Theme.type.caption)
          .fontColor('rgba(255,255,255,0.9)')
        Blank()
        Text('概览')
          .fontSize(Theme.type.caption)
          .fontColor('rgba(255,255,255,0.75)')
      }
      .width('100%')
      .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4, bottom: Theme.space.s3 })
      .linearGradient({
        angle: 135,
        colors: [['#0B6BCB', 0], ['#0A2540', 1]]
      })
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })

      Row({ space: Theme.space.s3 }) {
        this.StatCell(`${this.stats.totalCount}`, '总场次')
        this.StatCell(`${this.stats.totalMinutes}`, '总时长(分)')
        this.StatCell(this.stats.topSportLabel.length > 0 ? this.stats.topSportLabel : '—', '最常运动')
        this.StatCell(`${this.stats.monthCount}`, '本期场次')
      }
      .width('100%')
      .padding(Theme.space.s4)
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 8, color: 'rgba(15,23,42,0.08)', offsetY: 3 })
  }

  @Builder
  StatCell(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }
}
