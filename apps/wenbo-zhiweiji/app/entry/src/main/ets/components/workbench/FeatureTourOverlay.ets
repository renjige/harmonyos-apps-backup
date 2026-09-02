import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ZhiweiNav } from '../../services/ZhiweiNav'
import { ZhiweiStore } from '../../services/ZhiweiStore'

@Component
export struct FeatureTourOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State page: number = 0
  onDone: () => void = () => {}

  private titles: string[] = ['内置知识文库', '引导式学习路径', '间隔复习巩固', '消化跟进闭环']
  private bodies: string[] = [
    '30 篇分类短文，安装即可阅读，无需先记笔记。',
    '入门 / 职场 / 生活三条路径，分步体验学习与整理。',
    '抽卡回忆，按记得/模糊/忘了自动安排复习。',
    '待消化 → 跟进中 → 已消化，完整知识管理流程。'
  ]

  private async finish(openPath: boolean): Promise<void> {
    await ZhiweiStore.markTourDone()
    this.onDone()
    if (openPath) {
      ZhiweiNav.openLearningPath()
    }
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(15,23,42,0.55)')
      Column({ space: Theme.space.s4 }) {
        Text('知微集 · 学习管理')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .width('100%')
        Text(this.titles[this.page])
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
          .width('100%')
        Text(this.bodies[this.page])
          .fontSize(Theme.type.body)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .width('100%')
          .lineHeight(22)
        Text(`${this.page + 1} / 4`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
          .width('100%')
        if (this.page < 3) {
          AppButton({
            label: '下一步',
            variant: 'primary',
            onTap: (): void => { this.page += 1 }
          })
          AppButton({
            label: '跳过引导',
            variant: 'ghost',
            onTap: (): void => { void this.finish(false) }
          })
        } else {
          AppButton({
            label: '开始体验学习路径',
            variant: 'primary',
            onTap: (): void => { void this.finish(true) }
          })
          AppButton({
            label: '进入应用',
            variant: 'secondary',
            onTap: (): void => { void this.finish(false) }
          })
        }
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
      .borderRadius(Theme.radius.lg)
    }
    .width('100%')
    .height('100%')
    .zIndex(100)
  }
}
