import { Theme } from '../design-system/Theme'
import { CalendarDay } from '../../models/SportExtra'

@Component
export struct MatchCalendar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop days: CalendarDay[] = []
  @Prop selectedKey: string = ''
  onSelect: (key: string) => void = (_k: string) => {}
  private weeks: string[] = ['日', '一', '二', '三', '四', '五', '六']

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        ForEach(this.weeks, (w: string) => {
          Text(w)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('14.2%')
            .textAlign(TextAlign.Center)
        }, (w: string) => w)
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.days, (d: CalendarDay) => {
          Column() {
            if (!d.blank) {
              Text(`${d.dayNum}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.selectedKey === d.dateKey ?
                  Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              if (d.hasMark) {
                Circle()
                .width(4)
                .height(4)
                .fill(this.selectedKey === d.dateKey ?
                  Theme.colors().brandOnPrimary : Theme.colors().brandAccent)
              }
            }
          }
          .width('14.2%')
          .height(40)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .borderRadius(Theme.radius.sm)
          .backgroundColor(this.cellBg(d))
          .onClick((): void => {
            if (!d.blank) {
              this.onSelect(d.dateKey)
            }
          })
        }, (d: CalendarDay, index: number) => `${index}-${d.dateKey}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  private cellBg(d: CalendarDay): string {
    if (d.blank) {
      return 'transparent'
    }
    if (this.selectedKey === d.dateKey) {
      return Theme.colors().brandPrimary
    }
    if (d.isToday) {
      return Theme.colors().brandPrimaryContainer
    }
    return 'transparent'
  }
}
