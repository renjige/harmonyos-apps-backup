import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { SectionHeader } from '../components/design-system/SectionHeader'
import { MetricChipRow } from '../components/box/MetricChipRow'
import { BreakdownPane } from '../components/think/BreakdownPane'
import { NotePane } from '../components/think/NotePane'
import { OpinionPane } from '../components/think/OpinionPane'
import { DailyPane } from '../components/think/DailyPane'
import { GoalPane } from '../components/think/GoalPane'
import { ReviewPane } from '../components/think/ReviewPane'
import { ThinkStore } from '../services/ThinkStore'

class ThinkEntry {
  key: string = ''
  title: string = ''
  hint: string = ''
  count: number = 0
}

@Component
export struct ThinkPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tbReload') @Watch('onReloadChange') tbReload: number = 0
  @StorageLink('tbSparkCount') sparkCount: number = 0
  @StorageLink('tbNoteCount') noteCount: number = 0
  @StorageLink('tbBreakCount') breakCount: number = 0
  @StorageLink('tbStreakDays') streakDays: number = 0
  @StorageLink('tbGoalCount') goalCount: number = 0
  @StorageLink('tbReviewCount') reviewCount: number = 0
  @StorageLink('tbOpinionCount') opinionCount: number = 0
  @Prop @Watch('onReloadChange') reloadToken: number = 0
  @Prop @Watch('onTabVisibleChange') tabVisible: boolean = true
  @State tool: string = ''
  @State paneEpoch: number = 0
  @State activeStat: string = 'hub'
  @State metricCsv: string = ''
  @StorageLink('thinkToolAutoOpen') @Watch('onAutoToolChange') thinkToolAutoOpen: string = ''
  onSwitchHome: () => void = () => {}

  aboutToAppear(): void {
    void ThinkStore.syncGrowthToAppStorage()
    this.metricCsv =
      `灵感|${this.sparkCount}|0;笔记|${this.noteCount}|0;拆解|${this.breakCount}|0;连续天|${this.streakDays}|1`
    this.tryAutoOpenTool()
  }

  onAutoToolChange(): void {
    this.tryAutoOpenTool()
  }

  onTabVisibleChange(): void {
    if (this.tabVisible) {
      this.tryAutoOpenTool()
    }
  }

  private tryAutoOpenTool(): void {
    const key = this.thinkToolAutoOpen.trim()
    if (key.length === 0 || !this.tabVisible) {
      return
    }
    AppStorage.setOrCreate('thinkToolAutoOpen', '')
    this.openTool(key)
  }

  onReloadChange(): void {
    void ThinkStore.syncGrowthToAppStorage()
    this.metricCsv =
      `灵感|${this.sparkCount}|0;笔记|${this.noteCount}|0;拆解|${this.breakCount}|0;连续天|${this.streakDays}|1`
    if (this.tool.length > 0) {
      this.paneEpoch = this.paneEpoch + 1
    }
  }

  private entries(): ThinkEntry[] {
    const list: ThinkEntry[] = []
    const rows: string[][] = [
      ['break', '问题拆解', '把问题拆成现状、原因、方案', `${this.breakCount}`],
      ['note', '思维笔记', '标题 + 正文，建立思考档案', `${this.noteCount}`],
      ['opinion', '观点卡片', '留下一句判断，方便回头对照', `${this.opinionCount}`],
      ['daily', '每日思考', '每天一个问题，养成记录习惯', `${this.streakDays}`],
      ['goal', '目标推演', '设定目标并拆分实现路径', `${this.goalCount}`],
      ['review', '思考复盘', '对照旧理解，写下新的收获', `${this.reviewCount}`]
    ]
    for (const r of rows) {
      const e = new ThinkEntry()
      e.key = r[0]
      e.title = r[1]
      e.hint = r[2]
      e.count = parseInt(r[3], 10)
      list.push(e)
    }
    return list
  }

  private openTool(key: string): void {
    this.activeStat = key
    this.tool = key
    this.paneEpoch = this.paneEpoch + 1
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeTool(): void {
    this.tool = ''
    this.activeStat = 'hub'
    AppStorage.setOrCreate('tabBarHidden', false)
    void ThinkStore.syncGrowthToAppStorage()
  }

  private openSparkHome(): void {
    this.activeStat = 'spark'
    this.tool = ''
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onSwitchHome()
  }

  build() {
    Column() {
      if (this.tool.length > 0) {
        Row() {
          Text('返回工坊')
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.closeTool() })
          Blank()
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        if (this.tool === 'break') {
          BreakdownPane({ paneToken: this.paneEpoch }).layoutWeight(1)
        } else if (this.tool === 'note') {
          NotePane({ paneToken: this.paneEpoch }).layoutWeight(1)
        } else if (this.tool === 'opinion') {
          OpinionPane({ paneToken: this.paneEpoch }).layoutWeight(1)
        } else if (this.tool === 'daily') {
          DailyPane({ paneToken: this.paneEpoch }).layoutWeight(1)
        } else if (this.tool === 'goal') {
          GoalPane({ paneToken: this.paneEpoch }).layoutWeight(1)
        } else {
          ReviewPane({ paneToken: this.paneEpoch }).layoutWeight(1)
        }
      } else {
          Scroll() {
            Column({ space: Theme.space.section }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image($r('app.media.cover_cards'))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [
                      ['rgba(15,23,42,0.06)', 0.0],
                      ['rgba(15,23,42,0.55)', 0.5],
                      ['rgba(26,35,50,0.90)', 1.0]
                    ]
                  })
                Column({ space: 4 }) {
                  Text('思考工坊')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textOnInverse)
                  Text(`${this.streakDays}`)
                    .fontSize(Theme.type.display)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().textOnInverse)
                  Text('连续思考天数')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textOnInverse)
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
              }
              .width('100%')
              .height(220)

              Column({ space: Theme.space.s3 }) {
                SectionHeader({
                  title: '成长概览',
                  subtitle: '点选指标或下方工具进入对应模块'
                })
                MetricChipRow({ chipsCsv: this.metricCsv })
              }

              Column({ space: Theme.space.s3 }) {
                SectionHeader({
                  title: '结构化工具',
                  subtitle: '把灵感推进为可执行的思考档案'
                })
                ForEach(this.entries(), (e: ThinkEntry) => {
                  Row({ space: Theme.space.s3 }) {
                    Column({ space: 4 }) {
                      Text(e.title)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.colors().textPrimary)
                        .width('100%')
                      Text(e.hint)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textSecondary)
                        .width('100%')
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    Text(`${e.count}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                    AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
                  }
                  .width('100%')
                  .padding(Theme.space.s5)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.xl)
                  .border({ width: 1, color: Theme.colors().strokeHairline })
                  .onClick((): void => { this.openTool(e.key) })
                }, (e: ThinkEntry) => `${e.key}|${e.count}|${this.tbReload}`)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .padding({ bottom: 88 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number): void => {
            if (isVisible && currentRatio > 0 && this.tabVisible) {
              void ThinkStore.syncGrowthToAppStorage()
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
