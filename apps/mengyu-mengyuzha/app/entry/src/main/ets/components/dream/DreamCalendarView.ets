import { Theme } from '../design-system/Theme'
import { NoteItem } from '../../models/SlipModels'
import { MoodCatalog } from '../../services/MoodCatalog'
import { SlipDateUtil } from '../../services/SlipDateUtil'
import { SlipStore } from '../../services/SlipStore'

@Component
export struct DreamCalendarView {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop refreshToken: number = 0

  private daysInMonth(): number[] {
    const now = new Date()
    const year = now.getFullYear()
    const month = now.getMonth()
    const count = new Date(year, month + 1, 0).getDate()
    const out: number[] = []
    let d = 1
    while (d <= count) {
      out.push(d)
      d += 1
    }
    return out
  }

  private isoForDay(day: number): string {
    const now = new Date()
    const m = now.getMonth() + 1
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${now.getFullYear()}-${ms}-${ds}`
  }

  private noteForDay(day: number): NoteItem | undefined {
    const iso = this.isoForDay(day)
    for (const n of SlipStore.sorted()) {
      if (n.noteDate === iso) {
        return n
      }
    }
    return undefined
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text(`${new Date().getFullYear()} 年 ${new Date().getMonth() + 1} 月`)
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.daysInMonth(), (day: number) => {
          Column({ space: 4 }) {
            Text(`${day}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Row()
              .width(8)
              .height(8)
              .borderRadius(4)
              .backgroundColor(this.noteForDay(day) !== undefined ?
                MoodCatalog.primaryColor(this.noteForDay(day)?.mood ?? '') :
                Theme.colors().surfaceSubtle)
          }
          .width('14%')
          .padding(6)
          .alignItems(HorizontalAlign.Center)
        }, (day: number) => `${day}-${this.refreshToken}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
