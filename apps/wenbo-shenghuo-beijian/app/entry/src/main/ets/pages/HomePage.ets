import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { SlipListCard } from '../components/slip/SlipListCard'
import { SceneStrip } from '../components/slip/SceneStrip'
import { CatalogItem, SlipItem } from '../models/SlipModels'
import { SlipStore } from '../services/SlipStore'
import { SlipStats } from '../services/SlipStats'
import { SlipDateUtil } from '../services/SlipDateUtil'
import { SlipBizService } from '../services/SlipBizService'
import { SlipNav } from '../services/SlipNav'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '生活备笺'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State greeting: string = '今天也把生活安排得刚刚好。'
  @State openItems: SlipItem[] = []
  @State doneItems: SlipItem[] = []
  @State upcoming: SlipItem[] = []
  @State totalToday: number = 0
  @State doneCount: number = 0
  @State remindHint: string = ''
  @StorageLink('dailyRemindOn') dailyRemindOn: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = SlipStore.sorted()
    this.openItems = SlipStats.todayOpen(all)
    this.doneItems = SlipStats.todayDone(all)
    this.upcoming = SlipStats.upcoming(all)
    this.doneCount = this.doneItems.length
    this.totalToday = this.openItems.length + this.doneItems.length
    const greetings = await SlipBizService.loadGreetings()
    this.greeting = this.pickGreeting(greetings)
    if (this.dailyRemindOn && this.upcoming.length > 0) {
      this.remindHint = `智能提醒：今天还有 ${this.upcoming.length} 件待处理`
    } else {
      this.remindHint = ''
    }
  }

  private pickGreeting(list: CatalogItem[]): string {
    const fallback = SlipDateUtil.greetingFallback(
      SlipDateUtil.todayIso(), this.doneCount, this.totalToday)
    if (list.length === 0) {
      return fallback
    }
    if (this.totalToday > 0 && this.doneCount >= this.totalToday && list.length > 2) {
      return list[2].title
    }
    const day = new Date().getDay()
    const idx = day % list.length
    if (idx >= 0 && idx < list.length && list[idx].title.length > 0) {
      return list[idx].title
    }
    return fallback
  }

  private pct(): number {
    if (this.totalToday <= 0) {
      return 0
    }
    return Math.min(100, Math.floor((this.doneCount * 100) / this.totalToday))
  }

  private nowLabel(): string {
    const d = new Date()
    return `${SlipDateUtil.homeTitle(d)}  ${SlipDateUtil.weekdayLabel(d)}`
  }

  private helperLine(): string {
    if (this.totalToday === 0) {
      return '今天还没有备笺，轻轻记一件就好。'
    }
    return `已完成 ${this.doneCount} 件，还有 ${this.openItems.length} 件待处理`
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Text(this.appName)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column() {
            AppIcon({ name: 'user', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { AppStorage.setOrCreate('mainTabIndex', 3) })
        }
        .width('100%')

        Text(this.nowLabel())
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_today_paper'))
            .width('100%')
            .height(188)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(188)
            .linearGradient({
              angle: 180,
              colors: [['rgba(36,49,47,0)', 0.28], ['rgba(36,49,47,0.72)', 1]]
            })
          Column({ space: 8 }) {
            Text(this.nowLabel())
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .width('100%')
            Text(this.greeting)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .width('100%')
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 18 })
        }
        .width('100%')
        .borderRadius(Theme.radius.card)
        .clip(true)

        if (this.remindHint.length > 0) {
          Text(this.remindHint)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.lg)
        }

        SceneStrip()

        Column({ space: 10 }) {
          Row() {
            Text('今日事项')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Blank()
            Text(`${this.doneCount} / ${this.totalToday}`)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .width('100%')
          Stack({ alignContent: Alignment.Start }) {
            Row()
              .width('100%')
              .height(8)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
            Row()
              .width(`${this.pct()}%`)
              .height(8)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
          }
          .width('100%')
          .height(8)
          Text(this.helperLine())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        if (this.upcoming.length > 0) {
          Text('即将提醒')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.upcoming, (it: SlipItem) => {
            SlipListCard({
              item: it,
              onOpen: (id: string): void => { SlipNav.openDetail(id) },
              onToggle: (id: string): void => { void SlipStore.toggleDone(id) }
            })
          }, (it: SlipItem) => `up_${it.id}`)
        }

        Text('今日待办')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (this.openItems.length === 0) {
          AppEmpty({
            title: '今天没有需要操心的小事',
            description: '去做点真正想做的事情吧。',
            actionLabel: '记录一件事',
            onAction: (): void => { SlipNav.openWrite('') }
          })
        } else {
          ForEach(this.openItems, (it: SlipItem) => {
            SlipListCard({
              item: it,
              onOpen: (id: string): void => { SlipNav.openDetail(id) },
              onToggle: (id: string): void => { void SlipStore.toggleDone(id) }
            })
          }, (it: SlipItem) => `open_${it.id}`)
        }

        if (this.doneItems.length > 0) {
          Text('已完成')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.doneItems, (it: SlipItem) => {
            SlipListCard({
              item: it,
              onOpen: (id: string): void => { SlipNav.openDetail(id) },
              onToggle: (id: string): void => { void SlipStore.toggleDone(id) }
            })
          }, (it: SlipItem) => `done_${it.id}`)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }
}
