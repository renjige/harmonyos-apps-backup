import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { SlipListCard } from '../components/slip/SlipListCard'
import { CalCell, SlipItem } from '../models/SlipModels'
import { SlipStore } from '../services/SlipStore'
import { SlipDateUtil } from '../services/SlipDateUtil'
import { SlipNav } from '../services/SlipNav'

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State year: number = 2026
  @State month: number = 8
  @State selected: string = ''
  @State cells: CalCell[] = []
  @State dayItems: SlipItem[] = []
  @State headers: string[] = SlipDateUtil.weekHeaders()

  aboutToAppear(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    this.selected = SlipDateUtil.todayIso()
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.cells = SlipDateUtil.buildMonth(this.year, this.month, this.selected, SlipStore.markedDates())
    this.dayItems = SlipStore.byDate(this.selected)
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m < 1) {
      m = 12
      y -= 1
    }
    if (m > 12) {
      m = 1
      y += 1
    }
    this.month = m
    this.year = y
    this.reload()
  }

  private selectDay(iso: string): void {
    this.selected = iso
    this.reload()
  }

  private selectedLabel(): string {
    const d = SlipDateUtil.parseIso(this.selected)
    return `${d.getMonth() + 1}月${d.getDate()}日 · ${SlipDateUtil.weekdayLabel(d)}`
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Text('生活日历')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.shiftMonth(-1) })
        Text(SlipDateUtil.monthTitle(this.year, this.month))
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.shiftMonth(1) })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: 8 }) {
        Row() {
          ForEach(this.headers, (h: string) => {
            Text(h)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('14.2%')
              .textAlign(TextAlign.Center)
          }, (h: string) => h)
        }
        .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.cells, (c: CalCell) => {
            Column({ space: 4 }) {
              Text(`${c.day}`)
                .fontSize(Theme.type.body)
                .fontWeight(c.isSelected || c.isToday ? FontWeight.Medium : FontWeight.Normal)
                .fontColor(this.cellColor(c))
              Row()
                .width(5)
                .height(5)
                .borderRadius(Theme.radius.pill)
                .backgroundColor(c.hasItems ? Theme.colors().brandPrimary : Color.Transparent)
            }
            .width('14.2%')
            .height(48)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(c.isSelected ? Theme.colors().brandPrimaryContainer : Color.Transparent)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.selectDay(c.iso) })
          }, (c: CalCell) => c.iso)
        }
        .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Text(this.selectedLabel())
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      Text(this.dayItems.length > 0 ? `这一天有 ${this.dayItems.length} 件备笺` : '这一天还很清静')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.dayItems.length === 0) {
        AppEmpty({
          title: '这一天还没有备笺',
          description: '想到什么，就写下来。',
          actionLabel: '记录一件事',
          onAction: (): void => { SlipNav.openWrite('') }
        })
          .layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.dayItems, (it: SlipItem) => {
            ListItem() {
              SlipListCard({
                item: it,
                onOpen: (id: string): void => { SlipNav.openDetail(id) },
                onToggle: (id: string): void => { void SlipStore.toggleDone(id) }
              })
            }
          }, (it: SlipItem) => it.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private cellColor(c: CalCell): string {
    if (!c.inMonth) {
      return Theme.colors().textTertiary
    }
    if (c.isSelected) {
      return Theme.colors().brandPrimary
    }
    return Theme.colors().textPrimary
  }
}
