import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { AppCard } from '../components/design-system/AppCard'
import { AnalyzeEngine, CatalogOptions } from '../services/AnalyzeEngine'
import { WrongBizService } from '../services/WrongBizService'
import { WrongDetailNav } from '../services/WrongDetailNav'
import { WrongMedia } from '../services/WrongMedia'
import { CatalogItem, CatalogKind, SuggestionCard, SubjectOption, WeakPoint, WrongEntry } from '../models/WrongModels'

@Component
export struct DashboardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State entries: WrongEntry[] = []
  @State tips: CatalogItem[] = []
  @State methods: CatalogItem[] = []
  @State subject: string = 'all'
  @State bars: BarChartItem[] = []
  @State week: BarChartItem[] = []
  @State weak: WeakPoint[] = []
  @State ideas: SuggestionCard[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.tips = await WrongBizService.loadTips()
    this.methods = await WrongBizService.loadMethods()
    this.entries = await WrongBizService.loadEntries()
    this.applyFilter()
  }

  private applyFilter(): void {
    const filtered: WrongEntry[] = []
    for (const e of this.entries) {
      if (this.subject === 'all' || e.subjectCode === this.subject) {
        filtered.push(e)
      }
    }
    this.bars = AnalyzeEngine.subjectBars(this.entries)
    this.week = AnalyzeEngine.weekBars(filtered)
    this.weak = AnalyzeEngine.weakPoints(filtered)
    this.ideas = AnalyzeEngine.suggestions(filtered)
  }

  build() {
    Column() {
      Text('智慧分析')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY
        })
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(WrongMedia.resource('banner_progress'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(120)
              .linearGradient({
                angle: 180,
                colors: [['rgba(11,31,74,0.1)', 0], ['rgba(11,31,74,0.7)', 1]]
              })
            Text('按你自己的错题统计，不是全校排名')
              .fontSize(Theme.type.subhead)
              .fontColor('#FFFFFF')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .borderRadius(Theme.radius.md)
          .clip(true)

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              Text('全部')
                .fontSize(Theme.type.caption)
                .fontColor(this.subject === 'all' ?
                  Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.subject === 'all' ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick(() => {
                  this.subject = 'all'
                  this.applyFilter()
                })
              ForEach(CatalogOptions.subjects(), (s: SubjectOption) => {
                Text(s.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.subject === s.code ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.subject === s.code ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => {
                    this.subject = s.code
                    this.applyFilter()
                  })
              }, (s: SubjectOption) => `an-${s.code}`)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.entries.length === 0) {
            AppEmpty({
              title: '还没有可分析的错题',
              description: '登录并保存错题后，这里会出现学科分布与复习建议。'
            })
          } else {
            AppBarChart({ title: '各学科错题数量', items: this.bars })
            AppBarChart({ title: '近七日新增', items: this.week })
            AppCard({ title: '薄弱知识点' }) {
              if (this.weak.length === 0) {
                Text('给错题加上知识点标签后，会自动按频率排序。')
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              } else {
                Column({ space: Theme.space.s2 }) {
                  ForEach(this.weak, (w: WeakPoint) => {
                    Row() {
                      Text(w.tag)
                        .fontSize(Theme.type.body)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .layoutWeight(1)
                      Text(`${w.count} 次`)
                        .fontSize(Theme.type.subhead)
                        .fontColor(Theme.colors().brandAccent)
                    }
                    .width('100%')
                  }, (w: WeakPoint) => w.tag)
                }
              }
            }
            Text('学习建议')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.ideas, (s: SuggestionCard) => {
              AppCard({ title: s.title }) {
                Text(s.body)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
            }, (s: SuggestionCard) => s.title)
          }

          Text('复习建议模板')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.tips, (t: CatalogItem) => {
            AppCard({
              title: t.title,
              onTap: () => WrongDetailNav.openCatalog(CatalogKind.TIP, t.id)
            }) {
              Text(t.summary)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
          }, (t: CatalogItem) => t.id)

          Text('纠错方法')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.methods, (m: CatalogItem) => {
            AppCard({
              title: m.title,
              onTap: () => WrongDetailNav.openCatalog(CatalogKind.METHOD, m.id)
            }) {
              Text(m.summary)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
          }, (m: CatalogItem) => m.id)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10,
          top: Theme.space.s3
        })
        .constraintSize({ maxWidth: 720 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
