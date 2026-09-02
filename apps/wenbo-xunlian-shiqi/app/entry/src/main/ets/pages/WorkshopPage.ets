import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { PracticeHubStore } from '../services/PracticeHubStore'
import { PracticeService } from '../services/PracticeService'
import { FollowAlongService } from '../services/FollowAlongService'
import { FunQuestStore } from '../services/FunQuestStore'
import { PracticeNav } from '../services/PracticeNav'

@Component
export struct WorkshopPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @Prop refreshToken: number = 0
  @State planCount: number = 0
  @State moveCount: number = 0
  @State questCount: number = 0
  @State noteCount: number = 0
  @State goalCount: number = 0
  @State queueCount: number = 0
  @State checkPreview: string = ''
  onOpenFollowAlong: () => void = () => {}
  onOpenRoulette: () => void = () => {}
  onOpenBreath: () => void = () => {}
  onOpenWeekPlaybook: () => void = () => {}
  onSwitchDiscover: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onDataEpoch(): void {
    this.reload()
  }

  private reload(): void {
    this.planCount = PracticeHubStore.listPlans().length
    this.moveCount = PracticeHubStore.listMoves().length
    this.questCount = FunQuestStore.list().length
    this.noteCount = PracticeHubStore.listCards().length
    this.goalCount = PracticeHubStore.listGoals().length
    this.queueCount = FollowAlongService.listQueueIds().length
    this.checkPreview = WorkshopPage.checkPreview()
  }

  private static checkPreview(): string {
    const c = PracticeHubStore.getChecks()
    const before = PracticeService.unpackLines(c.beforePacked)
    let done = 0
    let total = 0
    for (const line of before) {
      total += 1
      if (line.done) {
        done += 1
      }
    }
    const after = PracticeService.unpackLines(c.afterPacked)
    for (const line of after) {
      total += 1
      if (line.done) {
        done += 1
      }
    }
    if (total === 0) {
      return '尚未启用清单，点进可加载热身/拉伸模板'
    }
    return `清单进度 ${done}/${total} · 训练前后勾选`
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        this.Hero()
        Text('运动工坊 · 十大玩法')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text('计划只是其中之一：随机玩法、呼吸、周剧本、跟练、图鉴、挑战等覆盖多种运动生活场景。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(20)
          .width('100%')

        this.ModuleCard('ai', '今天玩什么', '随机抽玩法 · 10 种场景',
          '开始抽取', (): void => { this.onOpenRoulette() })
        this.ModuleCard('refresh', '呼吸放松', '4-7-8 节奏引导 · 练后舒缓',
          '开始呼吸', (): void => { this.onOpenBreath() })
        this.ModuleCard('calendar', '周运动剧本', '周一～周日不同玩法',
          '查看剧本', (): void => { this.onOpenWeekPlaybook() })
        this.ModuleCard('sparkle', '动作跟练', `${this.queueCount} 个待练 · 计时逐步引导`,
          '开始跟练', (): void => { this.onOpenFollowAlong() })
        this.ModuleCard('list', '趣味计划库', `${this.planCount} 份 · 模板复制后勾选`,
          '进入计划库', (): void => { PracticeNav.openHub('plan') })
        this.ModuleCard('check', '训练任务清单', this.checkPreview, '打开清单', (): void => {
          PracticeNav.openHub('check')
        })
        this.ModuleCard('message', '训练笔记', `${this.noteCount} 条 · 心得与小技巧`,
          '写笔记', (): void => { PracticeNav.openHub('card') })
        this.ModuleCard('calendar', '阶段目标', `${this.goalCount} 个 · 次数/分钟追踪`,
          '设目标', (): void => { PracticeNav.openHub('goal') })
        this.ModuleCard('biz', '动作图鉴', `${this.moveCount} 个 · 五专区收藏`,
          '逛图鉴', (): void => { this.onSwitchDiscover() })
        this.ModuleCard('chart', '挑战与复盘', `${this.questCount} 个挑战 · 周复盘问卷`,
          '去发现', (): void => { this.onSwitchDiscover() })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6, bottom: Theme.space.s10 + 88 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch))
    .edgeEffect(EdgeEffect.Spring)
    .onAppear((): void => { this.reload() })
  }

  @Builder
  Hero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_training_bg'))
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(160)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(10,14,26,0.1)', 0.0],
            ['rgba(10,14,26,0.9)', 1.0]
          ]
        })
      Column({ space: 6 }) {
        Text('运动工坊')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.heroOnPhoto())
        Text('跟练 · 计划 · 清单 · 笔记 · 图鉴 · 挑战 · 目标')
          .fontSize(Theme.type.footnote)
          .fontColor('rgba(255,255,255,0.95)')
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
  }

  @Builder
  ModuleCard(icon: AppIconName, title: string, subtitle: string, actionLabel: string, action: () => void) {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppIcon({ name: icon, iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.md)
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
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      Text(actionLabel)
        .fontSize(Theme.type.bodyS)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .backgroundColor(Theme.primaryButtonFill())
        .borderRadius(Theme.radius.lg)
        .onClick((): void => { action() })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.cardBg(this.themeEpoch))
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
