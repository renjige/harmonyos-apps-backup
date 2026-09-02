import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { GuideService } from '../../services/GuideService'

class GuideSlide {
  icon: AppIconName = 'home'
  title: string = ''
  body: string = ''
  tab: number = 0

  constructor(icon: AppIconName, title: string, body: string, tab: number) {
    this.icon = icon
    this.title = title
    this.body = body
    this.tab = tab
  }
}

/** 首次启动产品引导（非隐私页）— 让审核员 10 秒内看到完整产品结构 */
@Component
export struct ProductGuideOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: number = 0
  private slides: GuideSlide[] = [
    new GuideSlide('home', '生活笺台，不只是日记',
      '笺台汇总今日进度、心情与计划；记录只是五大模块之一。', 0),
    new GuideSlide('check', '计划 Tab：执行层',
      '周期计划、今日待办、习惯打卡、生活目标 — 独立底栏，一键可达。', 2),
    new GuideSlide('book', '灵感 Tab：创作层',
      '12+ 生活场景模板、本周挑战与精选片段，降低创作门槛。', 1),
    new GuideSlide('chart', '成长 Tab：回顾层',
      '周月回顾、趋势图、成就墙与生活动态，看见自己的变化。', 4)
  ]

  private current(): GuideSlide {
    if (this.step >= 0 && this.step < this.slides.length) {
      return this.slides[this.step]
    }
    return this.slides[0]
  }

  private async finish(goTab: number): Promise<void> {
    await GuideService.markSeen()
    if (goTab >= 0) {
      AppStorage.setOrCreate('pendingTab', goTab)
    }
  }

  build() {
    Column() {
      Column({ space: Theme.space.s4 }) {
        AppIcon({
          name: this.current().icon,
          iconSize: 48,
          color: Theme.colors().brandPrimary
        })
        Text(`日常笺语 · 功能导览 ${this.step + 1}/${this.slides.length}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
          .textAlign(TextAlign.Center)
        Text(this.current().title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .textAlign(TextAlign.Center)
        Text(this.current().body)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
        if (this.step < this.slides.length - 1) {
          AppButton({
            label: '下一步',
            onTap: (): void => { this.step += 1 }
          })
          AppButton({
            label: '跳过导览',
            variant: 'secondary',
            onTap: (): void => { void this.finish(-1) }
          })
        } else {
          AppButton({
            label: '去体验计划 Tab',
            onTap: (): void => { void this.finish(2) }
          })
          AppButton({
            label: '进入笺台',
            variant: 'secondary',
            onTap: (): void => { void this.finish(0) }
          })
        }
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(61,58,54,0.55)')
    .zIndex(30)
  }
}
