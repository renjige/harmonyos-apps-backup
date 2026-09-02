import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ContentCard } from '../components/ContentCard'
import { CommonSenseTime, FactItem } from '../models/CommonSenseModels'
import { CommonSenseBizService } from '../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseStore } from '../services/CommonSenseStore'
import { ReadAloudService } from '../services/ReadAloudService'
import { ShareService } from '../services/ShareService'
import { HomeToolGrid } from '../components/HomeToolGrid'
import { HomeWorkbench } from '../components/HomeWorkbench'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '常识集'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('fontScale') fontScale: number = 1.0
  @State today: FactItem = new FactItem()
  @State history: FactItem[] = []
  @State allFacts: FactItem[] = []
  @State favorited: boolean = false
  @State loading: boolean = true
  @StorageLink('factsLoadHint') factsLoadHint: string = ''
  @State loadBanner: string = ''
  @State toastText: string = ''
  @State calendarDays: string[] = CommonSenseTime.lastNDays(14)
  @State related: FactItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.loading = true
    try {
      const local = await CommonSenseBizService.loadLocalFacts()
      if (local.length > 0) {
        this.applyFacts(local)
        this.loading = false
      }
      const list = await CommonSenseBizService.loadFacts()
      this.applyFacts(list)
    } catch {
      AppStorage.setOrCreate('factsLoadHint', '加载失败，请稍后重试')
    } finally {
      this.loading = false
    }
  }

  private applyFacts(list: FactItem[]): void {
    this.allFacts = list
    this.today = CommonSenseBizService.pickToday(list)
    this.favorited = CommonSenseStore.isFavorite(this.today.id)
    const todayKey = CommonSenseTime.todayKey()
    const hist: FactItem[] = []
    for (const item of list) {
      if (item.publishDate !== todayKey && item.id !== this.today.id) {
        hist.push(item)
      }
    }
    hist.sort((a: FactItem, b: FactItem) => {
      if (a.publishDate > b.publishDate) {
        return -1
      }
      if (a.publishDate < b.publishDate) {
        return 1
      }
      return 0
    })
    this.history = hist.slice(0, 12)
    this.calendarDays = CommonSenseTime.lastNDays(14)
    let recBase = this.today
    const lastId = AppStorage.get<string>('lastReadFactId') ?? ''
    if (lastId.length > 0) {
      for (const item of list) {
        if (item.id === lastId) {
          recBase = item
        }
      }
    }
    this.related = CommonSenseBizService.relatedFacts(list, recBase, 3)
    const source = AppStorage.get<string>('factsLoadSource') ?? ''
    if (source === 'cache' || source === 'bootstrap') {
      this.loadBanner = '当前为离线内容，联网后将自动同步最新常识'
    } else {
      this.loadBanner = ''
    }
  }

  private async toggleFavorite(): Promise<void> {
    if (this.today.id.length === 0) {
      return
    }
    const on = await CommonSenseStore.toggleFavorite(this.today.id, this.today.title)
    this.favorited = on
    this.showToast(on ? '已收藏今日常识' : '已取消收藏')
  }

  private async shareToday(): Promise<void> {
    const msg = await ShareService.shareFact(this.today)
    this.showToast(msg)
  }

  private async readToday(): Promise<void> {
    const msg = await ReadAloudService.copyForReadAloud(this.today)
    this.showToast(msg)
  }

  private pickRandomToday(): void {
    const random = CommonSenseBizService.pickRandom(this.allFacts)
    if (random.id.length > 0) {
      this.today = random
      this.favorited = CommonSenseStore.isFavorite(random.id)
      this.showToast('已为你换一条随机常识')
    }
  }

  private openDay(dateKey: string): void {
    const found = CommonSenseBizService.factForDate(this.allFacts, dateKey)
    if (found !== undefined) {
      CommonSenseDetailNav.openFact(found.id)
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Column({ space: 4 }) {
              Text(this.appName)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(CommonSenseTime.todayKey())
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Column() {
              AppIcon({ name: 'calendar', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { CommonSenseDetailNav.openCheckIn() })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

          if (!this.loading && this.today.id.length > 0) {
            HomeWorkbench({ refreshToken: this.refreshToken })
          }

          if (this.loading) {
            Text('加载今日常识…')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .padding({ left: Theme.space.pageX })
          } else if (this.today.id.length === 0) {
            AppEmpty({
              title: '暂无常识内容',
              description: this.factsLoadHint.length > 0 ?
                `${this.factsLoadHint}，请检查网络后重试。` : '请检查网络后重试。',
              actionLabel: '重试',
              onAction: (): void => { void this.reload() }
            })
          } else {
            if (this.loadBanner.length > 0) {
              Text(this.loadBanner)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().warning)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_today'))
                .width('100%')
                .height(240)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(240)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(10,37,64,0.05)', 0.2], ['rgba(10,37,64,0.88)', 1]]
                })
              Column({ space: 8 }) {
                Text('今日常识')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandAccent)
                Text(this.today.title)
                  .fontSize(Theme.type.title2 * this.fontScale)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .maxLines(3)
                Text(this.today.summary)
                  .fontSize(Theme.type.subhead)
                  .fontColor('#E8ECF1')
                  .maxLines(2)
              }
              .padding(Theme.space.s5)
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .borderRadius(Theme.radius.card)
            .clip(true)
            .onClick((): void => { CommonSenseDetailNav.openFact(this.today.id) })

            Row({ space: Theme.space.s2 }) {
              this.ActionChip('收藏', 'heart', (): void => { void this.toggleFavorite() })
              this.ActionChip('分享', 'bookmark', (): void => { void this.shareToday() })
              this.ActionChip('随机', 'sparkle', (): void => { this.pickRandomToday() })
              this.ActionChip('朗读', 'book', (): void => { void this.readToday() })
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            HomeToolGrid()

            Image($r('app.media.banner_calendar'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.card)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            if (this.related.length > 0) {
              Column({ space: Theme.space.s2 }) {
                Text('相关推荐')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                ForEach(this.related, (row: FactItem) => {
                  Text(`${row.categoryLabel()} · ${row.title}`)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                    .padding({ top: 8, bottom: 8 })
                    .onClick((): void => { CommonSenseDetailNav.openFact(row.id) })
                }, (row: FactItem) => `rec_${row.id}`)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              .width('100%')
            }

            Column({ space: Theme.space.s2 }) {
              Text('近 14 日')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Scroll() {
                Row({ space: 8 }) {
                  ForEach(this.calendarDays, (day: string) => {
                    this.CalendarDay(day)
                  }, (day: string) => day)
                }
                .padding({ right: Theme.space.pageX })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }
            .padding({ left: Theme.space.pageX })
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text('往期常识')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.history, (row: FactItem) => {
                ContentCard({
                  item: row,
                  compact: false,
                  onOpen: (): void => { CommonSenseDetailNav.openFact(row.id) }
                })
              }, (row: FactItem) => row.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ActionChip(label: string, icon: AppIconName, onTap: () => void) {
    Column({ space: 4 }) {
      AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      Text(label)
        .fontSize(11)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }

  @Builder
  CalendarDay(day: string) {
    Column({ space: 4 }) {
      Text(CommonSenseTime.formatDisplay(day))
        .fontSize(11)
        .fontColor(day === CommonSenseTime.todayKey() ?
          Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      if (CommonSenseStore.isCheckedIn(day)) {
        AppIcon({
          name: 'check',
          iconSize: Theme.icon.sm,
          color: day === CommonSenseTime.todayKey() ?
            Theme.colors().brandOnPrimary : Theme.colors().brandPrimary
        })
      } else {
        Text('·')
          .fontSize(10)
          .fontColor(Theme.colors().textTertiary)
      }
    }
    .width(52)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor(day === CommonSenseTime.todayKey() ?
      Theme.colors().brandPrimary : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.sm)
    .onClick((): void => { this.openDay(day) })
  }
}
