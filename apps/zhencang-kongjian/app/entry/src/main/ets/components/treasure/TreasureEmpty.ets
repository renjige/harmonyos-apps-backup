import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct TreasureEmpty {
  @Prop title: string = '这里还没有珍藏'
  @Prop subtitle: string = '从第一件值得留下的物品开始，建立你的珍藏档案。'
  @Prop actionLabel: string = '添加第一件珍藏'
  onAction: () => void = () => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      Image($r('app.media.empty_vault'))
        .width(120)
        .height(120)
        .opacity(0.9)
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(this.subtitle)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .textAlign(TextAlign.Center)
        .lineHeight(22)
      AppButton({ label: this.actionLabel, variant: 'primary', onTap: (): void => this.onAction() })
    }
    .width('100%')
    .padding(Theme.space.s8)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
