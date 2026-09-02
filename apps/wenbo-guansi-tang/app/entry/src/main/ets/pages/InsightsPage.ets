import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { WisdomItem } from '../models/WisdomHallModels'
import { WisdomHallBizService } from '../services/WisdomHallBizService'

class HeatCell {
  dateKey: string = ''
  count: number = 0
  level: number = 0
}

class ReportSection {
  title: string = ''
  body: string = ''
}

@Component
export struct InsightsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @State noteCount: number = 0
  @State tagCount: number = 0
  @State streakDays: number = 0
  @State heatCells: HeatCell[] = []
  @State showReport: boolean = false
  @State reportTitle: string = ''
  @State reportSections: ReportSection[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const thoughts = await WisdomHallBizService.loadThoughts()
    const tags = await WisdomHallBizService.loadTags()
    this.noteCount = thoughts.length
    this.tagCount = tags.length
    this.streakDays = InsightsPage.computeStreak(thoughts)
    this.heatCells = InsightsPage.buildHeatmap(thoughts)
    this.loading = false
  }

  private static computeStreak(items: WisdomItem[]): number {
    const daySet: string[] = []
    for (const item of items) {
      const key = InsightsPage.dateKeyFromIso(item.updatedAt)
      if (key.length > 0 && !daySet.includes(key)) {
        daySet.push(key)
      }
    }
    let streak = 0
    const today = new Date()
    for (let i = 0; i < 365; i++) {
      const d = new Date(today.getTime() - i * 86400000)
      const key = InsightsPage.dateKeyFromDate(d)
      if (daySet.includes(key)) {
        streak += 1
      } else if (i > 0) {
        break
      }
    }
    return streak
  }

  private static dateKeyFromIso(iso: string): string {
    if (iso.length < 10) {
      return ''
    }
    return iso.substring(0, 10)
  }

  private static dateKeyFromDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  private static buildHeatmap(items: WisdomItem[]): HeatCell[] {
    const map: Map<string, number> = new Map()
    for (const item of items) {
      const key = InsightsPage.dateKeyFromIso(item.updatedAt)
      if (key.length === 0) {
        continue
      }
      const prev = map.get(key) ?? 0
      map.set(key, prev + 1)
    }
    const cells: HeatCell[] = []
    const today = new Date()
    for (let i = 83; i >= 0; i--) {
      const d = new Date(today.getTime() - i * 86400000)
      const key = InsightsPage.dateKeyFromDate(d)
      const count = map.get(key) ?? 0
      const cell = new HeatCell()
      cell.dateKey = key
      cell.count = count
      if (count === 0) {
        cell.level = 0
      } else if (count === 1) {
        cell.level = 1
      } else if (count <= 3) {
        cell.level = 2
      } else {
        cell.level = 3
      }
      cells.push(cell)
    }
    return cells
  }

  private heatColor(level: number): string {
    if (level === 0) {
      return Theme.colors().strokeHairline
    }
    if (level === 1) {
      return '#E8DFD0'
    }
    if (level === 2) {
      return '#C9A96E'
    }
    return Theme.colors().brandPrimary
  }

  private openWeeklyReport(): void {
    this.reportTitle = '本周思考摘要'
    const sections: ReportSection[] = []
    const s1 = new ReportSection()
    s1.title = '笔记总数'
    s1.body = `本周共记录 ${this.noteCount} 条洞察笔记，使用 ${this.tagCount} 个标签分类。`
    sections.push(s1)
    const s2 = new ReportSection()
    s2.title = '连续活跃'
    s2.body = `已连续 ${this.streakDays} 天有思考记录，保持节奏有助于沉淀洞察。`
    sections.push(s2)
    const s3 = new ReportSection()
    s3.title = '说明'
    s3.body = '本报告基于本地笔记统计生成，不含生成式内容，仅供个人复盘参考。'
    sections.push(s3)
    this.reportSections = sections
    AppStorage.setOrCreate('tabBarHidden', true)
    this.showReport = true
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row({ space: Theme.space.s3 }) {
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width(40)
                .height(40)
                .linearGradient({
                  angle: 135,
                  colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
                })
                .borderRadius(12)
              AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandAccent })
            }
            Column({ space: 2 }) {
              Text('智慧洞察')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text('📊 基于笔记的纯统计复盘')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')

          if (this.accessToken.length === 0) {
            AppEmpty({
              title: '登录后查看洞察数据',
              description: '统计基于你的笔记与思考记录 📈',
              iconName: 'chart',
              emojiMark: '📊',
              actionLabel: '',
              onAction: (): void => {}
            })
          } else if (this.loading) {
            Column({ space: Theme.space.s3 }) {
              Row({ space: Theme.space.s2 }) {
                ForEach([0, 1, 2], (i: number) => {
                  Column()
                    .layoutWeight(1)
                    .height(72)
                    .backgroundColor(Theme.colors().strokeHairline)
                    .borderRadius(Theme.radius.card)
                }, (i: number) => `isk-${i}`)
              }
              .width('100%')
              Column()
                .width('100%')
                .height(120)
                .backgroundColor(Theme.colors().strokeHairline)
                .borderRadius(Theme.radius.card)
            }
            .width('100%')
          } else {
            Row({ space: Theme.space.s2 }) {
              AppStatCard({ label: '📝 笔记', value: `${this.noteCount}`, iconName: 'biz' })
              AppStatCard({ label: '🏷 标签', value: `${this.tagCount}`, iconName: 'bookmark' })
              AppStatCard({ label: '🔥 连续', value: `${this.streakDays}`, iconName: 'calendar' })
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Row({ space: 6 }) {
                AppIcon({ name: 'chart', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                Text('思考热力图')
                  .fontSize(Theme.type.subtitleL)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .width('100%')
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(this.heatCells, (cell: HeatCell) => {
                  Column()
                    .width(12)
                    .height(12)
                    .margin(2)
                    .backgroundColor(this.heatColor(cell.level))
                    .borderRadius(2)
                }, (cell: HeatCell) => cell.dateKey)
              }
              .width('100%')
              Text('🔥 颜色越深表示当日笔记越多')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)

            Row({ space: Theme.space.s3 }) {
              this.ReportEntry('📅 周报摘要', 'calendar', (): void => { this.openWeeklyReport() })
              this.ReportEntry('📈 月报摘要', 'chart', (): void => {
                this.reportTitle = '本月思考摘要'
                const sections: ReportSection[] = []
                const s1 = new ReportSection()
                s1.title = '月度概览'
                s1.body = `本月累计 ${this.noteCount} 条笔记，活跃 ${this.streakDays} 天。`
                sections.push(s1)
                const s2 = new ReportSection()
                s2.title = '建议'
                s2.body = '可在思辨空间围绕每日一问深化思考，并在洞察笔记中归档结论。'
                sections.push(s2)
                this.reportSections = sections
                AppStorage.setOrCreate('tabBarHidden', true)
                this.showReport = true
              })
            }
            .width('100%')
          }

          Column().height(Theme.space.s10).width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showReport) {
        this.ReportOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ReportEntry(label: string, iconName: string, onTap: () => void) {
    Column({ space: Theme.space.s2 }) {
      Column() {
        AppIcon({
          name: iconName === 'calendar' ? 'calendar' : 'chart',
          iconSize: Theme.icon.md,
          color: Theme.colors().brandAccent
        })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(10)
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text('纯统计 · 无生成')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick((): void => { onTap() })
  }

  @Builder
  ReportOverlay() {
    Column() {
      Row() {
        Text(this.reportTitle)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => {
            this.showReport = false
            AppStorage.setOrCreate('tabBarHidden', false)
          })
      }
      .width('100%')
      .padding(Theme.space.pageX)

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          ForEach(this.reportSections, (sec: ReportSection, idx: number) => {
            Column({ space: Theme.space.s2 }) {
              Text(sec.title)
                .fontSize(Theme.type.subtitleL)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(sec.body)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .lineHeight(26)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
          }, (sec: ReportSection, idx: number) => `r-${idx}`)
        }
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(20)
  }
}
