import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { DayMission } from '../../models/MathModels'

@Component
export struct HomeMissionBoard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop missions: DayMission[] = []
  onMission: (id: string) => void = (_id: string) => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日任务')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.missions, (m: DayMission) => {
        Row({ space: Theme.space.s3 }) {
          AppIcon({
            name: m.done ? 'check' : 'empty',
            iconSize: Theme.icon.md,
            color: m.done ? Theme.colors().brandPrimary : Theme.colors().textSecondary
          })
          Column({ space: Theme.space.s1 }) {
            Text(m.title)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(m.hint)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onClick(() => this.onMission(m.id))
      }, (m: DayMission) => m.id)
    }
    .width('100%')
  }
}
