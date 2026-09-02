import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { BreathModeCard } from '../components/cool/BreathModeCard'
import { BreathModeItem } from '../models/CoolPlanModels'
import { CoolPlanBizService } from '../services/CoolPlanBizService'
import { CoolPlanNav } from '../services/CoolPlanNav'

@Component
export struct BreathPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @State modes: BreathModeItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.modes = await CoolPlanBizService.loadBreathModes()
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppIcon({ name: 'heart', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .linearGradient({
          angle: 135,
          colors: [[Theme.colors().brandPrimary, 0], ['#4A9E9E', 1]]
        })
        .borderRadius(Theme.radius.lg)
        Column({ space: 4 }) {
          Text('🧘 智慧呼吸')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('三种节奏 · 圆环引导 · 练完自动记时')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      if (this.loading) {
        AppLoading({ label: '读取呼吸模式' })
      } else if (this.modes.length === 0) {
        AppEmpty({
          title: '暂无呼吸模式',
          description: '请检查网络后重试。模式来自平台 Admin 配置。',
          actionLabel: '重新加载',
          iconName: 'heart',
          emojiMark: '🧘',
          onAction: (): void => { void this.reload() }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('三种节奏引导：跟随圆环吸 · 屏 · 呼，练完自动记录时长。')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            ForEach(this.modes, (m: BreathModeItem) => {
              BreathModeCard({
                item: m,
                onTap: (): void => CoolPlanNav.openBreathMode(m.id)
              })
            }, (m: BreathModeItem) => m.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
