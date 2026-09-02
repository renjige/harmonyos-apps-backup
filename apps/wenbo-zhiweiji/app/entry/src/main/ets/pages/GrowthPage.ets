import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { DayChip, InsightDigest, CaptureStats } from '../models/ZhiweiModels'
import { ZhiweiMedia } from '../services/ZhiweiMedia'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRev') refreshToken: number = 0
  @State today: InsightDigest = new InsightDigest()
  @State history: InsightDigest[] = []
  @State days: DayChip[] = []
  @State stats: CaptureStats = new CaptureStats()
  @State barItems: BarChartItem[] = []
  @State achUnlocked: number = 0
  @State achTotal: number = 10

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.today = ZhiweiStore.todayDigest()
    this.history = ZhiweiStore.historyDays()
    this.days = ZhiweiStore.recentDayChips()
    this.stats = ZhiweiStore.stats()
    const bars = ZhiweiStore.weeklyBarItems()
    const rows = ZhiweiStore.categoryRows(bars)
    const items: BarChartItem[] = []
    for (const row of rows) {
      const b = new BarChartItem()
      b.label = row.name
      b.value = row.count
      items.push(b)
    }
    this.barItems = items
    const ach = ZhiweiStore.achievements()
    let u = 0
    for (const a of ach) {
      if (a.unlocked) {
        u += 1
      }
    }
    this.achUnlocked = u
    this.achTotal = ach.length
  }

  private async refreshNow(): Promise<void> {
    this.today = await ZhiweiStore.refreshTodayDigest()
    void this.reload()
  }

  build() {
    Column() {
      Text('成长')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack() {
            Image(ZhiweiMedia.bannerInsight())
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(140)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0.12)', 0], ['rgba(26,26,46,0.80)', 1]]
              })
            Column({ space: 4 }) {
              Text('学习成长中心')
                .fontSize(Theme.type.caption)
                .fontColor('#F5F7FA')
                .width('100%')
              Text(`连续 ${this.stats.streak} 天 · 已掌握 ${this.stats.masteredCount} 条`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F5F7FA')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 14, right: 14, bottom: 12 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height(140)
          .borderRadius(Theme.radius.md)
          .clip(true)

          Row({ space: 8 }) {
            this.LinkCard('周度洞察', '六分类分布与摘要', (): void => ZhiweiNav.openWeekly())
            this.LinkCard('本周回顾', '亮点与统计', (): void => ZhiweiNav.openReview('week'))
          }
          .width('100%')
          Row({ space: 8 }) {
            this.LinkCard('间隔复习', '抽卡巩固待学习条目', (): void => ZhiweiNav.openReviewDeck())
            this.LinkCard('消化处理台', '待消化→跟进→已消化', (): void => ZhiweiNav.openInbox())
          }
          .width('100%')
          Row({ space: 8 }) {
            this.LinkCard('成就墙', `${this.achUnlocked}/${this.achTotal} 已解锁`, (): void => ZhiweiNav.openAchievement())
            this.LinkCard('学习计划', '设定本周目标', (): void => ZhiweiNav.openPlan())
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('今日智慧摘要')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
            Text(this.today.summary.length > 0 ? this.today.summary : '今日还没有摘要，记一条微知识后刷新试试。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
              .lineHeight(22)
            AppButton({
              label: '刷新今日摘要',
              variant: 'secondary',
              onTap: (): void => { void this.refreshNow() }
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.card)

          if (this.barItems.length > 0) {
            AppBarChart({ title: '近七日分类', items: this.barItems })
          }

          Text('近七日记录（点日期查看）')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.days, (d: DayChip) => {
              Column({ space: 4 }) {
                Text(d.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                Text(`${d.count}`)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
              }
              .width(44)
              .padding({ top: 8, bottom: 8 })
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .margin({ right: 8, bottom: 8 })
              .onClick(() => ZhiweiNav.openFocus('day', d.dateKey, ZhiweiStore.displayDate(d.dateKey)))
            }, (d: DayChip) => d.dateKey)
          }
          .width('100%')

          Text('历史摘要')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          if (this.history.length === 0) {
            AppEmpty({
              title: '还没有历史摘要',
              description: '收录并刷新后，每日摘要会出现在这里。'
            })
          } else {
            ForEach(this.history, (d: InsightDigest) => {
              Column({ space: 6 }) {
                Text(ZhiweiStore.displayDate(d.dateKey))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
                  .width('100%')
                Text(d.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.card)
            }, (d: InsightDigest) => d.id)
          }
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }

  @Builder
  LinkCard(title: string, sub: string, tap: () => void) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        .width('100%')
      Text(sub)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
        .width('100%')
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick(() => tap())
  }
}
