import { Theme } from '../design-system/Theme'
import { CalendarCell } from '../../services/StatisticsUtil'

@Component
export struct TrainMonthGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop cells: CalendarCell[] = []
  onSelectDay: (dateKey: string) => void = (_k: string) => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
          Text(w)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width(40)
            .textAlign(TextAlign.Center)
        }, (w: string) => w)
      }
      .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.cells, (c: CalendarCell, idx: number) => {
          Column() {
            if (c.inMonth) {
              Text(`${c.day}`)
                .fontSize(Theme.type.caption)
                .fontWeight(c.count > 0 ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(c.count > 0 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            }
          }
          .width(40)
          .height(40)
          .margin({ bottom: 4 })
          .justifyContent(FlexAlign.Center)
          .borderRadius(Theme.radius.sm)
          .backgroundColor(c.inMonth ? this.cellBg(c.count) : 'transparent')
          .onClick((): void => {
            if (c.inMonth && c.dateKey.length > 0) {
              this.onSelectDay(c.dateKey)
            }
          })
        }, (c: CalendarCell, idx: number) => `${idx}_${c.dateKey}`)
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }

  private cellBg(count: number): string {
    if (count <= 0) {
      return Theme.colors().surfaceSubtle
    }
    if (count === 1) {
      return 'rgba(255,107,53,0.45)'
    }
    if (count === 2) {
      return 'rgba(255,107,53,0.72)'
    }
    return '#FF6B35'
  }
}
