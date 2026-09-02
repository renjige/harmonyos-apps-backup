import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { MonthCalendar } from '../components/journal/MonthCalendar'
import { JournalListCard } from '../components/journal/JournalListCard'
import { ShiyiEmpty } from '../components/journal/ShiyiEmpty'
import { JournalEntry, MonthInsight } from '../models/ShiyiModels'
import { CalendarUtil } from '../services/CalendarUtil'
import { ShiyiMedia } from '../services/ShiyiMedia'
import { ShiyiNav } from '../services/ShiyiNav'
import { ShiyiStore } from '../services/ShiyiStore'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State year: number = 2026
  @State month: number = 8
  @State marked: string[] = []
  @State insight: MonthInsight = new MonthInsight()
  @State dayItems: JournalEntry[] = []
  @State selectedDate: string = ''

  aboutToAppear(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    this.marked = ShiyiStore.datesWithJournal()
    this.insight = CalendarUtil.insight(this.year, this.month, ShiyiStore.journals())
    if (this.selectedDate.length > 0) {
      this.dayItems = ShiyiStore.findByDate(this.selectedDate)
    }
  }

  private shiftMonth(delta: number): void {
    let y = this.year
    let m = this.month + delta
    if (m < 1) {
      m = 12
      y -= 1
    }
    if (m > 12) {
      m = 1
      y += 1
    }
    this.year = y
    this.month = m
    this.selectedDate = ''
    this.dayItems = []
    this.reload()
  }

  private onPickDate(date: string): void {
    this.selectedDate = date
    const list = ShiyiStore.findByDate(date)
    this.dayItems = list
    let count = 0
    let onlyId = ''
    for (const item of list) {
      count += 1
      onlyId = item.id
    }
    if (count === 1) {
      ShiyiNav.openDetail(onlyId)
    }
  }

  private moodLine(): string {
    if (this.insight.journalCount === 0) {
      return '这个月还没有留下手账。'
    }
    if (this.insight.topMoodLabel.length === 0) {
      return `这个月，你留下了 ${this.insight.journalCount} 篇手账。`
    }
    return `这个月，你留下了 ${this.insight.journalCount} 篇手账。`
  }

  private extraLine(): string {
    if (this.insight.journalCount === 0) {
      return '统计来自你写下的记录，没有额外结论。'
    }
    let line = ''
    if (this.insight.topMoodLabel.length > 0) {
      line = `你最常记录的心情是：${this.insight.topMoodLabel}。`
    }
    if (this.insight.topTag.length > 0) {
      if (line.length > 0) {
        line = `${line}\n你最常记录的主题是：${this.insight.topTag}。`
      } else {
        line = `你最常记录的主题是：${this.insight.topTag}。`
      }
    }
    if (line.length === 0) {
      return '统计来自你写下的记录，没有额外结论。'
    }
    return line
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('回顾')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(ShiyiMedia.cover('banner_review'))
            .width('100%')
            .height(132)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(132)
            .linearGradient({
              angle: 180,
              colors: [['rgba(63,44,54,0.10)', 0], ['rgba(63,44,54,0.70)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Text('慢慢翻看已经留下的日子')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textOnInverse)
            .padding(Theme.space.s5)
        }
        .width('100%')

        Row() {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .rotate({ angle: 180 })
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.shiftMonth(-1)
          })
          Text(CalendarUtil.monthTitle(this.year, this.month))
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.shiftMonth(1)
          })
        }
        .width('100%')

        MonthCalendar({
          year: this.year,
          month: this.month,
          marked: this.marked,
          onSelectDate: (date: string) => {
            this.onPickDate(date)
          }
        })
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)

        Column({ space: Theme.space.s3 }) {
          Text('智慧回顾')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.moodLine())
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.extraLine())
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        if (this.selectedDate.length > 0) {
          Text(ShiyiStore.displayDate(this.selectedDate))
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.dayItems.length === 0) {
            ShiyiEmpty({
              title: '这一天还是空白。',
              description: '如果你愿意，现在就可以写下一页。',
              actionLabel: '写下这份拾意',
              onAction: (): void => {
                ShiyiNav.openCompose('', this.selectedDate)
              }
            })
          } else {
            ForEach(this.dayItems, (item: JournalEntry) => {
              JournalListCard({
                entry: item,
                onTap: (): void => {
                  ShiyiNav.openDetail(item.id)
                }
              })
            }, (item: JournalEntry) => item.id)
          }
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
