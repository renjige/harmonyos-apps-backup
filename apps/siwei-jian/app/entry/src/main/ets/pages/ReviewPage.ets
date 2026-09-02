import { Theme } from '../components/design-system/Theme'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { TimelineEvent, OrganizeHint, MonthlyBar, CatShare, YearReport, JianStats } from '../models/JianModels'
import { JianQuery } from '../services/JianQuery'
import { JianNav } from '../services/JianNav'
import { DateHelper } from '../services/DateHelper'
import { JianMedia } from '../services/JianMedia'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('jianDataRev') @Watch('onDataRevChange') jianDataRev: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State mode: string = 'time'
  @State events: TimelineEvent[] = []
  @State hints: OrganizeHint[] = []
  @State bars: MonthlyBar[] = []
  @State shares: CatShare[] = []
  @State report: YearReport = new YearReport()
  @State stats: JianStats = new JianStats()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataRevChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.events = await JianQuery.timeline()
    this.hints = await JianQuery.organizeHints()
    this.bars = await JianQuery.monthlyBars()
    this.shares = await JianQuery.categoryShares()
    this.report = await JianQuery.yearReport()
    this.stats = await JianQuery.stats()
  }

  private openHint(h: OrganizeHint): void {
    JianNav.openThought(h.entityId)
    JianNav.openEditor('thought', h.entityId)
  }

  private maxBar(): number {
    let m = 1
    for (const b of this.bars) {
      if (b.count > m) {
        m = b.count
      }
    }
    return m
  }

  build() {
    Column() {
      Text('成长回顾')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Row({ space: Theme.space.s2 }) {
        this.Seg('time', '时间轴')
        this.Seg('data', '数据')
        this.Seg('year', '年度')
        this.Seg('org', '整理')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.mode === 'time') {
            if (this.events.length === 0) {
              AppEmpty({ title: '时间轴还是空的', description: '写下思考后，成长轨迹会出现在这里' })
            } else {
              ForEach(this.events, (e: TimelineEvent) => {
                Row({ space: Theme.space.s3 }) {
                  Column()
                    .width(8)
                    .height(8)
                    .borderRadius(4)
                    .backgroundColor(Theme.colors().brandAccent)
                    .margin({ top: 6 })
                  Column({ space: 2 }) {
                    Text(DateHelper.displayDateFromTs(e.ts))
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                    Text(e.title)
                      .fontSize(Theme.type.subtitleS)
                      .fontColor(Theme.colors().textPrimary)
                    Text(e.subtitle)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .onClick((): void => {
                  if (e.kind === 'card') {
                    JianNav.openCard(e.id)
                  } else if (e.kind === 'spark') {
                    JianNav.openSpark(e.id)
                  } else {
                    JianNav.openThought(e.id)
                  }
                })
              }, (e: TimelineEvent) => `${e.kind}_${e.id}_${e.ts}`)
            }
          }

          if (this.mode === 'data') {
            AppCard({ title: '档案数字', variant: 'plain' }) {
              Text(`思考 ${this.stats.thoughtCount} · 灵感 ${this.stats.sparkCount} · 观点卡 ${this.stats.cardCount} · 主题 ${this.stats.themeCount} · 连续 ${this.stats.streakDays} 天`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
            }
            AppCard({ title: '月度趋势', variant: 'plain' }) {
              Column({ space: 8 }) {
                ForEach(this.bars, (b: MonthlyBar) => {
                  Row({ space: 8 }) {
                    Text(b.label).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width(36)
                    Stack({ alignContent: Alignment.Start }) {
                      Column().width('100%').height(10).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(5)
                      Column()
                        .width(`${Math.max(8, Math.floor(b.count * 100 / this.maxBar()))}%`)
                        .height(10)
                        .backgroundColor(Theme.colors().brandPrimary)
                        .borderRadius(5)
                    }
                    .layoutWeight(1)
                    Text(`${b.count}`).fontSize(Theme.type.caption).fontColor(Theme.colors().textPrimary)
                  }
                  .width('100%')
                }, (b: MonthlyBar) => b.monthKey)
              }
            }
            AppCard({ title: '分类比例', variant: 'plain' }) {
              Column({ space: 6 }) {
                ForEach(this.shares, (s: CatShare) => {
                  Text(`${s.label}  ${s.count}`)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }, (s: CatShare) => s.key)
              }
            }
          }

          if (this.mode === 'year') {
            Image(JianMedia.bannerThink())
              .width('100%')
              .height(100)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
            AppCard({ title: `我的${this.report.year}思维档案`, variant: 'plain' }) {
              Column({ space: 8 }) {
                Text(`思考 ${this.report.thoughtCount} 条`).fontColor(Theme.colors().textPrimary)
                Text(`灵感 ${this.report.sparkCount} 条`).fontColor(Theme.colors().textPrimary)
                Text(`主题 ${this.report.themeCount} 个`).fontColor(Theme.colors().textPrimary)
                Text(`收藏 ${this.report.favoriteCount} 条`).fontColor(Theme.colors().textPrimary)
                Text(`常用主题 ${this.report.topTheme}`).fontColor(Theme.colors().textSecondary)
                Text(`高频标签 ${this.report.topTag}`).fontColor(Theme.colors().textSecondary)
                Text(`最近记录 ${this.report.highlightTitle}`).fontColor(Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
          }

          if (this.mode === 'org') {
            Text('智慧整理基于你已有的档案做提醒，不使用生成式模型。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            if (this.hints.length === 0) {
              AppEmpty({ title: '暂无整理建议', description: '分类、标签都妥当的时候，这里会很安静' })
            } else {
              ForEach(this.hints, (h: OrganizeHint) => {
                Column({ space: 4 }) {
                  Text(h.title)
                    .fontSize(Theme.type.subtitleS)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(h.message)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .width('100%')
                .onClick((): void => { this.openHint(h) })
              }, (h: OrganizeHint) => h.id)
            }
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: this.bottomInset + 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  Seg(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.mode === key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.mode === key ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.mode = key })
  }
}
