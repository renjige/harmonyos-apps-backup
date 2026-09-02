import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct OnboardingGuidePane {
  @State step: number = 0
  onFinish: () => void = () => {}

  private titles: string[] = [
    '个人阅读工作台',
    '书架 + 计划 + 摘录',
    '专注阅读 + 成长回顾',
    '开始你的阅读闭环'
  ]

  private bodies: string[] = [
    '纸上方不只是记书摘，而是帮你完成「选书 → 阅读 → 摘录 → 回顾 → 成长」的完整闭环。',
    '在「书架」管理在读/想读/已读书籍；在「书房」记录金句；阅读计划自动统计进度。',
    '专注阅读计时记录场次；成长页有抽卡回顾、成就墙、本周复盘与阅读诊断报告。',
    '添加第一本书，或先写一条书摘。数据保存在本机，随时可导出。'
  ]

  private icons: ('book' | 'grid' | 'chart' | 'sparkle')[] = ['book', 'grid', 'chart', 'sparkle']

  private async finish(): Promise<void> {
    await StudyStore.markOnboardingDone()
    this.onFinish()
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.45)')

      Column({ space: Theme.space.s4 }) {
        AppIcon({ name: this.icons[this.step], iconSize: 48, color: Theme.colors().brandPrimary })
        Text(this.titles[this.step])
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .textAlign(TextAlign.Center)
        Text(this.bodies[this.step])
          .fontSize(Theme.type.bodyM)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
        Row({ space: 6 }) {
          ForEach([0, 1, 2, 3], (i: number) => {
            Column()
              .width(this.step === i ? 20 : 8)
              .height(8)
              .backgroundColor(this.step === i ?
                Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(4)
          }, (i: number) => `${i}`)
        }
        if (this.step < 3) {
          AppButton({
            label: '下一步',
            onTap: (): void => { this.step = this.step + 1 }
          })
          AppButton({
            label: '跳过',
            variant: 'secondary',
            onTap: (): void => { void this.finish() }
          })
        } else {
          AppButton({
            label: '开始使用',
            onTap: (): void => { void this.finish() }
          })
        }
      }
      .width('88%')
      .padding(24)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(20)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .zIndex(50)
  }
}
