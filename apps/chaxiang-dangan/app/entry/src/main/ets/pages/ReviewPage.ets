import { Theme } from '../components/design-system/Theme'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { AchievementDef, MonthBar, TeaStats, TimelineMark, TypeShare } from '../models/TeaModels'
import { TeaMedia } from '../services/TeaMedia'
import { TeaStatsService } from '../services/TeaStatsService'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('teaRev') @Watch('onTeaRevChange') teaRev: number = 0
  @State stats: TeaStats = new TeaStats()
  @State marks: TimelineMark[] = []
  @State bars: BarChartItem[] = []
  @State shares: TypeShare[] = []
  @State unlocked: string[] = []
  @State catalog: AchievementDef[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onTeaRevChange(): void {
    this.reload()
  }

  private reload(): void {
    this.stats = TeaStatsService.compute()
    this.marks = TeaStatsService.timeline()
    this.shares = TeaStatsService.typeShares()
    this.unlocked = TeaStatsService.unlockedAchievements()
    this.catalog = TeaStatsService.catalog()
    const next: BarChartItem[] = []
    const months: MonthBar[] = TeaStatsService.monthBars()
    for (const m of months) {
      const b = new BarChartItem()
      b.label = m.label
      b.value = m.value
      next.push(b)
    }
    this.bars = next
  }

  private isOn(id: string): boolean {
    return this.unlocked.indexOf(id) >= 0
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(TeaMedia.review())
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(140)
            .linearGradient({
              angle: 180,
              colors: [['rgba(28,46,38,0.1)', 0], ['rgba(28,46,38,0.75)', 1]]
            })
          Text('茶香回顾')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
            .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
        }
        .clip(true)
        .borderRadius(Theme.radius.lg)

        Row() {
          Column({ space: 2 }) {
            Text(`${this.stats.teaCount}`).fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary)
            Text('茶品').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }.layoutWeight(1)
          Column({ space: 2 }) {
            Text(`${this.stats.tastingCount}`).fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary)
            Text('品饮').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }.layoutWeight(1)
          Column({ space: 2 }) {
            Text(`${this.stats.albumCount}`).fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary)
            Text('主题').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }.layoutWeight(1)
          Column({ space: 2 }) {
            Text(`${this.stats.dayCount}`).fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary)
            Text('天数').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }.layoutWeight(1)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)

        Text('时间轴')
          .fontSize(Theme.type.subtitleS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        if (this.marks.length === 0) {
          Text('有了第一款茶和第一次品饮，轨迹会出现在这里。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        ForEach(this.marks, (m: TimelineMark) => {
          Row({ space: Theme.space.s3 }) {
            Column()
              .width(10)
              .height(10)
              .borderRadius(5)
              .backgroundColor(Theme.colors().brandAccent)
            Column({ space: 2 }) {
              Text(m.dateKey).fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary)
              Text(m.title).fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
              Text(m.body).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
        }, (m: TimelineMark) => m.id)

        AppBarChart({ title: '近六月品饮', items: this.bars })

        Text('茶类比例')
          .fontSize(Theme.type.subtitleS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        ForEach(this.shares, (s: TypeShare) => {
          Row() {
            Text(s.name).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textPrimary).layoutWeight(1)
            Text(`${s.count}`).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
        }, (s: TypeShare) => s.key.length > 0 ? s.key : 'none')

        Text('茶香成就')
          .fontSize(Theme.type.subtitleS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.catalog, (a: AchievementDef) => {
            Column({ space: 4 }) {
              Text(a.title)
                .fontSize(Theme.type.caption)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isOn(a.id) ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              Text(this.isOn(a.id) ? '已点亮' : a.hint)
                .fontSize(10)
                .fontColor(this.isOn(a.id) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            }
            .width('46%')
            .padding(Theme.space.s3)
            .margin({ right: 8, bottom: 8 })
            .borderRadius(Theme.radius.md)
            .backgroundColor(this.isOn(a.id) ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .alignItems(HorizontalAlign.Start)
          }, (a: AchievementDef) => a.id)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: 96
      })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear((): void => { this.reload() })
    .backgroundColor(this.teaRev >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
