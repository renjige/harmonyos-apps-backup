import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct ProductIntroOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onDismiss: () => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(26,58,92,0.55)')

      Column({ space: Theme.space.s4 }) {
        Text('格物集是什么？')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Text('本应用是「每日一物 + 图鉴 + 格物路径」的学习工具，不是通用备忘录或日记本。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(24)
          .width('100%')

        Column({ space: Theme.space.s2 }) {
          Text('· 每日精选一个知识物，完成读 → 问 → 测 → 记 → 候')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('· 五门图鉴：植物 / 动物 / 昆虫 / 矿物 / 日常物品')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('· 观察札归入「功课」，须从图鉴选物写入')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)

        AppButton({
          label: '开始格物',
          variant: 'primary',
          onTap: (): void => { this.onDismiss() }
        })
      }
      .width('88%')
      .padding(Theme.space.s5)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .zIndex(30)
  }
}
