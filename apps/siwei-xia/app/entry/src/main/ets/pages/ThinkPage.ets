import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { BreakdownPane } from '../components/think/BreakdownPane'
import { NotePane } from '../components/think/NotePane'
import { OpinionPane } from '../components/think/OpinionPane'
import { DailyPane } from '../components/think/DailyPane'
import { GoalPane } from '../components/think/GoalPane'
import { ReviewPane } from '../components/think/ReviewPane'
import { ThinkStore } from '../services/ThinkStore'
import { BoxMedia } from '../services/BoxMedia'

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
  @Prop tabVisible: boolean = true
  @State tool: string = ''
  @State paneEpoch: number = 0
  @State activeStat: string = 'hub'
  onSwitchHome: () => void = () => {}

  aboutToAppear(): void {
    void ThinkStore.syncGrowthToAppStorage()
  }

  onReloadChange(): void {
    void ThinkStore.syncGrowthToAppStorage()
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
        Text('思考工坊')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Image(BoxMedia.resource('cover_cards'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Text('点选统计卡片进入对应工具；保存后会自动刷新本机统计。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              Column({ space: 4 }) {
                Text(`${this.sparkCount}`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.activeStat === 'spark' ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
                Text('灵感')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.activeStat === 'spark' ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding({ top: 4, bottom: 4 })
              .backgroundColor(this.activeStat === 'spark' ? Theme.colors().brandPrimaryContainer : 'transparent')
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openSparkHome() })

              Column({ space: 4 }) {
                Text(`${this.noteCount}`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.activeStat === 'note' ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
                Text('笔记')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.activeStat === 'note' ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding({ top: 4, bottom: 4 })
              .backgroundColor(this.activeStat === 'note' ? Theme.colors().brandPrimaryContainer : 'transparent')
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openTool('note') })

              Column({ space: 4 }) {
                Text(`${this.breakCount}`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.activeStat === 'break' ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
                Text('拆解')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.activeStat === 'break' ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding({ top: 4, bottom: 4 })
              .backgroundColor(this.activeStat === 'break' ? Theme.colors().brandPrimaryContainer : 'transparent')
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openTool('break') })

              Column({ space: 4 }) {
                Text(`${this.streakDays}`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.activeStat === 'daily' ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
                Text('连续天')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.activeStat === 'daily' ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding({ top: 4, bottom: 4 })
              .backgroundColor(this.activeStat === 'daily' ? Theme.colors().brandPrimaryContainer : 'transparent')
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openTool('daily') })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

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
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { this.openTool(e.key) })
            }, (e: ThinkEntry) => `${e.key}|${e.count}|${this.tbReload}`)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
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
