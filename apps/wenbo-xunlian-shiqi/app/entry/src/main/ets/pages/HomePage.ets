import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { FunQuest, TrainingRecord, TrainingSummary, VitalityState } from '../models/TrainingModels'
import { TrainingAnalytics } from '../services/TrainingAnalytics'
import { TrainingStore } from '../services/TrainingStore'
import { FunQuestStore } from '../services/FunQuestStore'
import { FunQuestService } from '../services/FunQuestService'
import { ProfileStore } from '../services/ProfileStore'
import { VitalityService } from '../services/VitalityService'
import { TrainingDetailNav } from '../services/TrainingDetailNav'
import { PracticeNav } from '../services/PracticeNav'
import { MoveCatalog } from '../services/MoveCatalog'
import { DataRefresh } from '../services/DataRefresh'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @State summary: TrainingSummary = new TrainingSummary()
  @State nickname: string = '训练者'
  @State vitality: VitalityState = new VitalityState()
  @State indexScore: number = 0
  @State taskRate: number = 0
  @State recent: TrainingRecord[] = []
  @State quests: FunQuest[] = []
  @State smartTip: string = ''
  @Prop refreshToken: number = 0
  onStartTraining: () => void = () => {}
  onOpenRecords: () => void = () => {}
  onOpenPlan: () => void = () => {}
  onOpenDiscover: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenHub: (kind: string) => void = () => {}
  onOpenFollowAlong: () => void = () => {}
  onOpenRoulette: () => void = () => {}
  onOpenBreath: () => void = () => {}
  onOpenWeekPlaybook: () => void = () => {}
  onOpenPlayTab: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onDataEpoch(): void {
    this.reload()
  }

  private reload(): void {
    this.summary = TrainingAnalytics.summarize()
    this.nickname = ProfileStore.get().nickname
    this.vitality = VitalityService.copyState()
    this.indexScore = VitalityService.index()
    this.taskRate = VitalityService.taskRate()
    this.recent = TrainingStore.recent(3)
    this.quests = FunQuestStore.active()
    this.smartTip = VitalityService.smartTip()
  }

  private async tapWarm(): Promise<void> {
    await VitalityService.toggleWarm()
    DataRefresh.bump()
    this.reload()
  }

  private async tapNote(): Promise<void> {
    await VitalityService.toggleNote()
    DataRefresh.bump()
    this.reload()
  }

  private async scenarioMoves(): Promise<void> {
    await MoveCatalog.importZone('热身')
    DataRefresh.bump()
    this.onOpenDiscover()
  }

  private async scenarioChallenge(): Promise<void> {
    await FunQuestStore.saveItem(FunQuestService.fromHall('d7'))
    await VitalityService.award(5)
    DataRefresh.bump()
    this.reload()
    this.onOpenDiscover()
  }

  private scenarioNote(): void {
    this.onOpenHub('card')
  }

  private scenarioGrowth(): void {
    this.onOpenGrowth()
  }

  build() {
    Scroll() {
      Column({ space: 0 }) {
        this.HeroSection()
        Column({ space: Theme.space.s4 }) {
          this.PlayHub()
          this.TodayCard()
          this.FeatureMatrix()
          this.SmartTip()
          this.ChallengeRec()
          Stack({ alignContent: Alignment.Center }) {
            Image($r('app.media.ambient_empty_bg'))
              .width('100%')
              .height(88)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
              .opacity(0.45)
            Text('去玩法 Tab 试试「今天玩什么」或「晨起唤醒」')
              .fontSize(Theme.type.bodyS)
              .fontColor('#F8FAFC')
              .padding(Theme.space.s4)
          }
          .width('100%')
          .onClick((): void => { this.onOpenPlayTab() })
        }
        .padding(Theme.space.pageX)
        .margin({ top: -28 })
        .padding({ bottom: Theme.space.s10 + 88 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch))
    .edgeEffect(EdgeEffect.Spring)
    .onAppear((): void => { this.reload() })
  }

  @Builder
  HeroSection() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_training_bg'))
        .width('100%')
        .height(228)
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height(228)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(10,14,26,0.12)', 0.0],
            ['rgba(10,14,26,0.92)', 1.0]
          ]
        })
      Column({ space: 6 }) {
        Text('训练拾趣')
          .fontSize(Theme.type.caption)
          .fontColor('rgba(255,255,255,0.88)')
        Text(`你好，${this.nickname}`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.heroOnPhoto())
        Text('运动玩法中心 · 跟练 / 随机 / 呼吸 / 图鉴 / 挑战')
          .fontSize(Theme.type.footnote)
          .fontColor('rgba(255,255,255,0.95)')
          .width('100%')
        if (this.summary.streakDays > 0) {
          Text(`已连续运动 ${this.summary.streakDays} 天`)
            .fontSize(Theme.type.caption)
            .fontColor('rgba(255,255,255,0.88)')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
  }

  @Builder
  PlayHub() {
    Column({ space: Theme.space.s3 }) {
      Text('运动玩法')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.PlayTile('今天玩什么', (): void => { this.onOpenRoulette() })
        this.PlayTile('呼吸放松', (): void => { this.onOpenBreath() })
      }
      .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.PlayTile('动作跟练', (): void => { this.onOpenFollowAlong() })
        this.PlayTile('全部玩法', (): void => { this.onOpenPlayTab() })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  PlayTile(label: string, action: () => void) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor('#FFFFFF')
      .fontWeight(FontWeight.Medium)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .padding({ top: 16, bottom: 16 })
      .linearGradient({
        angle: 135,
        colors: [['#007AFF', 0.0], ['#0056CC', 1.0]]
      })
      .borderRadius(Theme.radius.lg)
      .onClick((): void => { action() })
  }

  @Builder
  FeatureMatrix() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('快捷入口')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('玩法 Tab')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onOpenPlayTab() })
      }
      .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.MatrixCell('sparkle', '跟练', (): void => { this.onOpenFollowAlong() })
        this.MatrixCell('ai', '随机玩', (): void => { this.onOpenRoulette() })
        this.MatrixCell('refresh', '呼吸', (): void => { this.onOpenBreath() })
        this.MatrixCell('biz', '发现', (): void => { this.onOpenDiscover() })
      }
      .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.MatrixCell('check', '清单', (): void => { this.onOpenHub('check') })
        this.MatrixCell('message', '笔记', (): void => { this.onOpenHub('card') })
        this.MatrixCell('calendar', '目标', (): void => { this.onOpenHub('goal') })
        this.MatrixCell('chart', '成长', (): void => { this.onOpenGrowth() })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.cardBg(this.themeEpoch))
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  MatrixCell(icon: AppIconName, label: string, action: () => void) {
    Column({ space: 6 }) {
      Column() {
        AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding({ top: 8, bottom: 8 })
    .onClick((): void => { action() })
  }

  @Builder
  ScenarioSection() {
    Column({ space: Theme.space.s3 }) {
      Text('推荐训练场景')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('按场景进入不同模块，覆盖学习动作、习惯挑战、写笔记与看成长。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      this.ScenarioCard('动作学习日', '复制热身动作到图鉴', (): void => { void this.scenarioMoves() })
      this.ScenarioCard('7 天习惯挑战', '加入挑战馆并跟踪天数', (): void => { void this.scenarioChallenge() })
      this.ScenarioCard('写训练笔记', '记录心得与小技巧', (): void => { this.scenarioNote() })
      this.ScenarioCard('查看成长报告', '月度统计与热力日历', (): void => { this.scenarioGrowth() })
    }
    .width('100%')
  }

  @Builder
  ScenarioCard(title: string, subtitle: string, action: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { action() })
  }

  @Builder
  TodayCard() {
    Column({ space: Theme.space.s3 }) {
      Text('今日活力指数')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Row() {
        Text(`${this.indexScore}`)
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Text(' / 100')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        Blank()
        Text(`${this.vitality.points} 积分`)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.accentOnSurface())
      }
      .width('100%')
      Text(`今日任务完成度 ${this.taskRate}% · 继续加油`)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  StartButton() {
    Row({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'sparkle', iconSize: Theme.icon.md, color: '#FFFFFF' })
        Text('跟练模式')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .layoutWeight(1)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .linearGradient({
        angle: 135,
        colors: [['#007AFF', 0.0], ['#0056CC', 1.0]]
      })
      .borderRadius(Theme.radius.lg)
      .onClick((): void => { this.onOpenFollowAlong() })

      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        Text('记训练')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandPrimary)
      }
      .layoutWeight(1)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick((): void => { this.onStartTraining() })
    }
    .width('100%')
  }

  @Builder
  TaskCard() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('今日活力任务')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('运动工坊')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onOpenPlan() })
      }
      .width('100%')
      this.TaskRow('完成热身', this.vitality.warmDone, (): void => { void this.tapWarm() })
      this.TaskRow('完成训练', this.vitality.trainDone, (): void => { this.onStartTraining() })
      this.TaskRow('记录心得', this.vitality.noteDone, (): void => { void this.tapNote() })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  TaskRow(label: string, done: boolean, action: () => void) {
    Row({ space: Theme.space.s3 }) {
      AppIcon({
        name: done ? 'check' : 'empty',
        iconSize: Theme.icon.md,
        color: done ? Theme.colors().brandPrimary : Theme.colors().textSecondary
      })
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      Text(done ? '已完成' : '去完成')
        .fontSize(Theme.type.caption)
        .fontColor(done ? Theme.colors().success : Theme.accentOnSurface())
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
    .onClick((): void => { action() })
  }

  @Builder
  SmartTip() {
    Column({ space: 6 }) {
      Text('智慧训练建议')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text(this.smartTip)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textPrimary)
        .lineHeight(20)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  WorkshopSection() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('运动工坊')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('清单 · 笔记 · 目标 · 方案')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.WorkshopTile('任务清单', '热身/拉伸勾选', 'check')
        this.WorkshopTile('训练笔记', '心得与小技巧', 'card')
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.WorkshopTile('阶段目标', '次数/分钟追踪', 'goal')
        this.WorkshopTile('运动工坊', '七大能力总览', 'workshop')
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  WorkshopTile(title: string, subtitle: string, hub: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(subtitle)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.cardBg(this.themeEpoch))
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => {
      if (hub === 'plan' || hub === 'workshop') {
        this.onOpenPlan()
      } else {
        this.onOpenHub(hub)
      }
    })
  }

  @Builder
  QuickRow() {
    Row({ space: Theme.space.s3 }) {
      this.QuickChip('训练记录', (): void => { this.onOpenRecords() })
      this.QuickChip('动作图鉴', (): void => { this.onOpenDiscover() })
    }
    .width('100%')
    Row({ space: Theme.space.s3 }) {
      this.QuickChip('挑战中心', (): void => { this.onOpenDiscover() })
      this.QuickChip('成长报告', (): void => { this.onOpenGrowth() })
    }
    .width('100%')
  }

  @Builder
  QuickChip(label: string, action: () => void) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(Theme.colors().textPrimary)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .padding({ top: 14, bottom: 14 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick((): void => { action() })
  }

  @Builder
  RecentBlock() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('最近训练')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('全部')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onOpenRecords() })
      }
      .width('100%')
      ForEach(this.recent, (item: TrainingRecord) => {
        Row() {
          Column({ space: 4 }) {
            Text(item.trainingType)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(`${item.recordDate} · ${item.feeling} · ${item.completeStatus}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { TrainingDetailNav.open(item.id) })
      }, (item: TrainingRecord) => item.id)
    }
    .width('100%')
  }

  @Builder
  ChallengeRec() {
    Column({ space: Theme.space.s3 }) {
      Text('趣味挑战推荐')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.quests.length === 0) {
        Text('去发现页加入 7 天运动挑战，跟练或记一次即可计入天数。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .onClick((): void => { this.onOpenDiscover() })
      } else {
        ForEach(this.quests, (q: FunQuest) => {
          Text(`${q.title} · ${FunQuestService.progress(q).current}/${FunQuestService.progress(q).target}${FunQuestService.progress(q).unit}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { TrainingDetailNav.openQuest(q.id) })
        }, (q: FunQuest) => q.id)
      }
    }
    .width('100%')
  }
}
