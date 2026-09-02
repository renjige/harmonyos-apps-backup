import { Theme } from '../design-system/Theme'
import { ActivityEvent } from '../../models/LifeGrowthModels'
import { LifeHubNav } from '../../services/LifeHubNav'
import { JournalDetailNav } from '../../services/JournalDetailNav'

@Component
export struct HomeActivityStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: ActivityEvent[] = []

  private open(row: ActivityEvent): void {
    if (row.kind === 'diary') {
      JournalDetailNav.openDiary(row.refId)
      return
    }
    LifeHubNav.open('activity', false)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('最近动态')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('全部')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { LifeHubNav.open('activity', false) })
      }
      .width('100%')
      if (this.items.length === 0) {
        Text('写一页、记心情或完成待办后，这里会出现你的生活轨迹。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.items, (row: ActivityEvent) => {
          Text(`${row.date}  ${row.title}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .maxLines(1)
            .onClick((): void => { this.open(row) })
        }, (row: ActivityEvent) => row.id)
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
