import { Theme } from '../components/design-system/Theme'
import { TaskCard } from '../components/daily/TaskCard'
import { QuoteCard } from '../components/daily/QuoteCard'
import { DailyLocalStore, DateHelper } from '../services/DailyLocalStore'
import { DailyQuoteItem, DailyTaskItem } from '../models/DailyModels'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '青柠日常'
  @State dateText: string = ''
  @State task: DailyTaskItem = new DailyTaskItem()
  @State quote: DailyQuoteItem = new DailyQuoteItem()
  @State taskExpanded: boolean = false
  @State taskDone: boolean = false
  @State quoteFav: boolean = false
  @State celebrate: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.dateText = DateHelper.displayDate(new Date())
    this.task = DailyLocalStore.todayTask()
    this.quote = DailyLocalStore.todayQuote()
    void this.loadState()
  }

  private async loadState(): Promise<void> {
    this.taskDone = await DailyLocalStore.isTaskDoneToday()
    this.quoteFav = await DailyLocalStore.isQuoteFavorite(this.quote.id)
  }

  private async handleComplete(): Promise<void> {
    if (!this.taskExpanded) {
      this.taskExpanded = true
      return
    }
    await DailyLocalStore.markTaskDoneToday()
    this.taskDone = true
    this.celebrate = true
    setTimeout(() => {
      this.celebrate = false
    }, 1800)
  }

  private async toggleFavorite(): Promise<void> {
    this.quoteFav = await DailyLocalStore.toggleQuoteFavorite(this.quote.id)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_ambient'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column({ space: 4 }) {
            Text(this.appName)
              .fontSize(Theme.type.overline)
              .fontColor('rgba(255,255,255,0.85)')
            Text(this.dateText)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .padding(Theme.space.s5)
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(45,74,30,0.72)', 1]]
          })
        }
        .width('100%')
        .height(168)
        .borderRadius(Theme.radius.xl)
        .clip(true)

        TaskCard({
          task: this.task,
          done: this.taskDone,
          expanded: this.taskExpanded,
          celebrate: this.celebrate,
          onToggleExpand: () => { this.taskExpanded = !this.taskExpanded },
          onComplete: () => { void this.handleComplete() }
        })

        QuoteCard({
          quote: this.quote,
          favorited: this.quoteFav,
          onToggleFavorite: () => { void this.toggleFavorite() }
        })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
