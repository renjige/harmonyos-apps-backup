import { Theme } from '../design-system/Theme'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct WeekActivityStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop dayKeys: string[] = []
  @Prop activeKeys: string[] = []
  onDayTap: (dateKey: string) => void = () => {}

  private isActive(key: string): boolean {
    for (const k of this.activeKeys) {
      if (k === key) {
        return true
      }
    }
    return false
  }

  private isToday(key: string): boolean {
    return key === DateHelper.todayKey()
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('本周活跃')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        ForEach(this.dayKeys, (key: string) => {
          Column({ space: 4 }) {
            Column()
              .width(28)
              .height(28)
              .borderRadius(14)
              .backgroundColor(this.isActive(key) ?
                Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .border({
                width: this.isToday(key) ? 2 : 0,
                color: Theme.colors().brandPrimary
              })
            Text(DateHelper.displayWeekday(key).replace('周', ''))
              .fontSize(10)
              .fontColor(this.isActive(key) ?
                Theme.colors().brandPrimary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .constraintSize({ minHeight: 44 })
          .onClick((): void => { this.onDayTap(key) })
        }, (key: string) => key)
      }
      .width('100%')
    }
    .width('100%')
  }
}
