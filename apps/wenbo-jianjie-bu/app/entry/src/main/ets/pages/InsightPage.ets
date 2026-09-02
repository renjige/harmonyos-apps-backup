import { Theme } from '../components/design-system/Theme'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { InsightStatCard } from '../components/book/InsightStatCard'
import { InsightActionGrid } from '../components/book/InsightActionGrid'
import { HeatmapPane } from '../components/book/HeatmapPane'
import { HeatDay, InsightEntry, KeywordItem } from '../models/InsightModels'
import { BarChartItem } from '../components/design-system/AppChart'
import { AppBarChart } from '../components/design-system/AppChart'
import { InsightStore } from '../services/InsightStore'
import { InsightDigestService } from '../services/InsightDigestService'
import { DateHelper } from '../services/DateHelper'
import { WorkbenchService } from '../services/WorkbenchService'

@Component
export struct InsightPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenSettings: () => void = () => {}
  onOpenMine: () => void = () => {}
  onOpenAchievements: () => void = () => {}
  onOpenActivity: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  onOpenTool: (kind: string) => void = (_k: string) => {}
  @StorageLink('themeRevision') themeRevision: number = 0
  @State weekDigest: string = ''
  @State todayDigest: string = ''
  @State words: KeywordItem[] = []
  @State total: number = 0
  @State streak: number = 0
  @State bookCount: number = 3
  @State starCount: number = 0
  @State days: HeatDay[] = []
  @State weekItems: BarChartItem[] = []
  @State weekList: InsightEntry[] = []
  @State wordHits: InsightEntry[] = []
  @State wordTitle: string = ''
  @State hitRate: number = 0
  @State achievementCount: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.weekDigest = await InsightDigestService.weekDigest()
    this.todayDigest = await InsightDigestService.todayDigest()
    this.words = await InsightDigestService.keywordCloud()
    const all = await InsightStore.loadAll()
    this.total = all.length
    this.streak = await InsightStore.streakDays()
    const books = await InsightStore.loadNotebooks()
    this.bookCount = books.length
    const stars = await InsightStore.starred()
    this.starCount = stars.length
    this.days = await InsightStore.heatmap28()
    const bars = await InsightStore.weekBars()
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const items: BarChartItem[] = []
    for (let i = 0; i < bars.length; i++) {
      const it = new BarChartItem()
      it.value = bars[i] + 0.01
      it.label = i < labels.length ? labels[i] : `${i}`
      items.push(it)
    }
    this.weekItems = items
    const week: InsightEntry[] = []
    const keys = DateHelper.lastNDays(7)
    for (const n of all) {
      for (const k of keys) {
        if (n.dateKey === k) {
          week.push(n)
        }
      }
    }
    this.weekList = week
    const stats = await WorkbenchService.loadStats()
    this.hitRate = stats.hitRate
    this.achievementCount = stats.achievementCount
  }

  private async openWord(w: string): Promise<void> {
    this.wordTitle = w
    this.wordHits = await InsightStore.containingWord(w)
  }

  private async openDay(dateKey: string): Promise<void> {
    this.wordTitle = dateKey
    this.wordHits = await InsightStore.byMonth(dateKey.substring(0, 7))
    const dayHits: InsightEntry[] = []
    for (const n of this.wordHits) {
      if (n.dateKey === dateKey) {
        dayHits.push(n)
      }
    }
    this.wordHits = dayHits
    this.wordTitle = `当日 · ${dateKey}`
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Column({ space: 2 }) {
            Text('成长')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('判断应验 · 徽章 · 本机计算')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Row({ space: 4 }) {
            Row() {
              AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
            }
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.onOpenMine() })
            Row() {
              AppIcon({ name: 'gear', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
            }
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.onOpenSettings() })
          }
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          InsightStatCard({ label: '应验率', value: `${this.hitRate}%` })
          InsightStatCard({ label: '徽章', value: `${this.achievementCount}` })
          InsightStatCard({ label: '连续天', value: `${this.streak}` })
        }
        .width('100%')

        Row({ space: 8 }) {
          Text('成就墙')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.onOpenAchievements() })
          Text('活动流')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.onOpenActivity() })
        }
        .width('100%')

        InsightActionGrid({
          onOpen: (kind: string) => { this.onOpenTool(kind) }
        })

        Stack() {
          Image($r('app.media.banner_insight'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          Column()
            .width('100%')
            .height(120)
            .borderRadius(Theme.radius.md)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,20,58,0.12)', 0], ['rgba(26,20,58,0.78)', 1]]
            })
          Column({ space: 4 }) {
            Text('智慧摘要')
              .fontSize(Theme.type.caption)
              .fontColor('#F0C27A')
            Text('把近期记录收成要点')
              .fontSize(Theme.type.subtitleL)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16, bottom: 16 })
        }
        .width('100%')
        .height(120)
        .clip(true)

        Row({ space: Theme.space.s3 }) {
          InsightStatCard({ label: '总见解', value: `${this.total}` })
          InsightStatCard({ label: '连续天', value: `${this.streak}` })
          InsightStatCard({ label: '星标', value: `${this.starCount}` })
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          InsightStatCard({ label: '笔记本', value: `${this.bookCount}` })
        }
        .width('100%')

        HeatmapPane({
          days: this.days,
          onPick: (k: string) => { void this.openDay(k) }
        })

        AppBarChart({ title: '近七日书写量', items: this.weekItems })

        AppCard({ title: '今日要点' }) {
          Text(this.todayDigest)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(22)
            .width('100%')
        }

        AppCard({ title: '本周智慧摘要' }) {
          Text(this.weekDigest)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(22)
            .width('100%')
        }

        if (this.weekList.length > 0) {
          AppCard({ title: '本周回看' }) {
            Column({ space: 8 }) {
              ForEach(this.weekList, (n: InsightEntry) => {
                Text(n.title)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                  .onClick((): void => { this.onOpen(n.id) })
              }, (n: InsightEntry) => `w_${n.id}`)
            }
            .width('100%')
          }
        }

        AppCard({ title: '关键词云图（点词回看）' }) {
          if (this.words.length === 0) {
            Text('写下几条见解后，这里会出现高频词。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.words, (w: KeywordItem) => {
                Text(w.word)
                  .fontSize(12 + Math.round(w.weight * 8))
                  .fontWeight(w.weight > 0.6 ? FontWeight.Bold : FontWeight.Medium)
                  .fontColor(w.weight > 0.6 ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
                  .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                  .margin({ right: 6, bottom: 6 })
                  .onClick((): void => { void this.openWord(w.word) })
              }, (w: KeywordItem) => w.word)
            }
            .width('100%')
          }
        }

        if (this.wordHits.length > 0) {
          AppCard({ title: this.wordTitle }) {
            Column({ space: 8 }) {
              ForEach(this.wordHits, (n: InsightEntry) => {
                Text(n.title)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                  .onClick((): void => { this.onOpen(n.id) })
              }, (n: InsightEntry) => `h_${n.id}`)
            }
            .width('100%')
          }
        }

        Image($r('app.media.insight_ambient'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: this.bottomInset + 24
      })
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .opacity(this.themeRevision >= 0 ? 1 : 1)
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .edgeEffect(EdgeEffect.Spring)
  }
}
