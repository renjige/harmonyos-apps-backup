import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

/** 我的页设置行 — @Prop 保证副标题数字随 @State 刷新 */
@Component
export struct MineSettingRow {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop fontScale: number = 1
  onTap: () => void = () => {}

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(Theme.type.body * this.fontScale)
          .fontColor(Theme.colors().textPrimary)
        Text(this.subtitle)
          .fontSize(Theme.type.caption * this.fontScale)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.onTap() })
  }
}
