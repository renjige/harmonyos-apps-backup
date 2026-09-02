import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DayChip, InsightDigest } from '../models/ZhiweiModels'
import { ZhiweiMedia } from '../services/ZhiweiMedia'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct InsightPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRev') refreshToken: number = 0
  @State today: InsightDigest = new InsightDigest()
  @State history: InsightDigest[] = []
  @State days: DayChip[] = []
  @State captureCount: number = 0
  @State workCount: number = 0
  @State lifeCount: number = 0
  @State studyCount: number = 0
  @State sparkCount: number = 0
  @State summary: string = ''
  @State keywordCsv: string = ''
  @State dateKey: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.today = ZhiweiStore.todayDigest()
    this.summary = this.today.summary
    this.keywordCsv = this.today.keywordCsv
    this.dateKey = this.today.dateKey
    this.captureCount = this.today.captureCount
    this.workCount = this.today.workCount
    this.lifeCount = this.today.lifeCount
    this.studyCount = this.today.studyCount
    this.sparkCount = this.today.sparkCount
    this.history = ZhiweiStore.historyDays()
    this.days = ZhiweiStore.recentDayChips()
  }

  private async refreshNow(): Promise<void> {
    this.today = await ZhiweiStore.refreshTodayDigest()
    this.reload()
  }

  build() {
    Column() {
      Text('智能洞察')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack() {
            Image(ZhiweiMedia.bannerInsight())
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(160)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0.12)', 0], ['rgba(26,26,46,0.80)', 1]]
              })
            Column({ space: 6 }) {
              Text('今日洞察')
                .fontSize(Theme.type.caption)
                .fontColor('#F5F7FA')
                .width('100%')
              Text(ZhiweiStore.displayDate(this.dateKey.length > 0 ? this.dateKey : ZhiweiStore.today()))
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F5F7FA')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 16 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height(160)
          .borderRadius(Theme.radius.md)
          .clip(true)

          Column({ space: 10 }) {
            Text('今日智慧摘要')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
            Text(this.summary)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
              .lineHeight(22)
            Text(`今日 ${this.captureCount} 条微知识 · 点「查看周度洞察」看六大分类分布`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            if (this.keywordCsv.length > 0) {
              Text(`线索 ${this.keywordCsv}（点此查看相关收录）`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
                .width('100%')
                .onClick(() => {
                  const words = this.keywordCsv.split('、')
                  let first = ''
                  for (const w of words) {
                    first = w.trim()
                    break
                  }
                  if (first.length > 0) {
                    ZhiweiNav.openFocus('keyword', first, `线索「${first}」`)
                  }
                })
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.card)

          Text('近七日（点日期看当天收录）')
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

          AppButton({
            label: '刷新今日摘要',
            variant: 'secondary',
            onTap: (): void => { void this.refreshNow() }
          })
          AppButton({
            label: '查看周度洞察',
            variant: 'primary',
            onTap: (): void => ZhiweiNav.openWeekly()
          })

          Text('历史洞察')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
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
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                Text(d.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(4)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
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
    .id(`insight_${this.themeEpoch}`)
  }
}
