import { Theme } from '../design-system/Theme'

export class StampDay {
  iso: string = ''
  label: string = ''
  marked: boolean = false
}

@Component
export struct MonthStampGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop year: number = 2026
  @Prop month: number = 1
  @Prop markedIso: string[] = []
  onPick: (iso: string) => void = (iso: string) => {
    if (iso.length === 0) {
      return
    }
  }

  private days(): StampDay[] {
    const last = new Date(this.year, this.month, 0).getDate()
    const out: StampDay[] = []
    let d = 1
    while (d <= last) {
      const mm = this.month < 10 ? `0${this.month}` : `${this.month}`
      const dd = d < 10 ? `0${d}` : `${d}`
      const cell = new StampDay()
      cell.iso = `${this.year}-${mm}-${dd}`
      cell.label = `${d}`
      for (const m of this.markedIso) {
        if (m === cell.iso) {
          cell.marked = true
        }
      }
      out.push(cell)
      d += 1
    }
    return out
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.days(), (day: StampDay) => {
        Column() {
          Text(day.label)
            .fontSize(Theme.type.caption)
            .fontColor(day.marked ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(day.marked ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .margin({ right: 6, bottom: 6 })
        .onClick((): void => { this.onPick(day.iso) })
      }, (day: StampDay) => day.iso)
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
