import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { FollowAlongService } from '../services/FollowAlongService'
import { ScenarioItem, ScenarioPlayService } from '../services/ScenarioPlayService'

@Component
export struct PlayTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State queueCount: number = 0
  @State scenarios: ScenarioItem[] = []
  onOpenRoulette: () => void = () => {}
  onOpenBreath: () => void = () => {}
  onOpenFollowAlong: () => void = () => {}
  onOpenWeekPlaybook: () => void = () => {}
  onSwitchDiscover: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenHub: (kind: string) => void = () => {}
  onScenario: (id: string) => void = () => {}

  aboutToAppear(): void {
    this.queueCount = FollowAlongService.listQueueIds().length
    this.scenarios = ScenarioPlayService.list()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        this.Hero()
        Text('按场景一键进入：跟练、呼吸、图鉴、挑战、笔记等可交互玩法。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        this.MainPlay('ai', '今天玩什么', '随机 10 种运动场景', (): void => { this.onOpenRoulette() })
        this.MainPlay('refresh', '呼吸放松', '4-7-8 计时引导', (): void => { this.onOpenBreath() })
        this.MainPlay('sparkle', '动作跟练', `${this.queueCount} 个待练 · 逐步计时`, (): void => {
          this.onOpenFollowAlong()
        })
        this.MainPlay('calendar', '周运动剧本', '每天不同玩法安排', (): void => { this.onOpenWeekPlaybook() })

        Text('生活场景玩法')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.scenarios, (s: ScenarioItem) => {
          this.ScenarioCard(s)
        }, (s: ScenarioItem) => s.id)

        Text('探索与工具')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        this.SecondaryRow('动作图鉴', (): void => { this.onSwitchDiscover() })
        this.SecondaryRow('挑战馆 / 复盘', (): void => { this.onSwitchDiscover() })
        this.SecondaryRow('运动笔记', (): void => { this.onOpenHub('card') })
        this.SecondaryRow('任务清单', (): void => { this.onOpenHub('check') })
        this.SecondaryRow('阶段目标', (): void => { this.onOpenHub('goal') })
        this.SecondaryRow('成长报告', (): void => { this.onOpenGrowth() })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6, bottom: Theme.space.s10 + 88 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch))
    .edgeEffect(EdgeEffect.Spring)
    .onAppear((): void => {
      this.queueCount = FollowAlongService.listQueueIds().length
    })
  }

  @Builder
  Hero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.fun_quest_bg'))
        .width('100%')
        .height(168)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(168)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(10,14,26,0.1)', 0.0],
            ['rgba(10,14,26,0.9)', 1.0]
          ]
        })
      Column({ space: 6 }) {
        Text('玩法中心')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.heroOnPhoto())
        Text('跟练 · 随机玩法 · 呼吸 · 周剧本 · 图鉴 · 挑战')
          .fontSize(Theme.type.footnote)
          .fontColor('rgba(255,255,255,0.95)')
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
  }

  @Builder
  MainPlay(icon: AppIconName, title: string, sub: string, action: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: icon, iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(sub)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.cardBg(this.themeEpoch))
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { action() })
  }

  @Builder
  ScenarioCard(s: ScenarioItem) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(s.title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(s.subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text(s.actionHint)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.cardBg(this.themeEpoch))
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onScenario(s.id) })
  }

  @Builder
  SecondaryRow(label: string, action: () => void) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding({ top: Theme.space.s3, bottom: Theme.space.s3 })
    .onClick((): void => { action() })
  }
}
