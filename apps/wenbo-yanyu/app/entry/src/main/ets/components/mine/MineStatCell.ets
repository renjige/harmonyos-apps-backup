import { Theme } from '../design-system/Theme'

/** 我的页统计格 — 独立 @Component，避免 @Builder 传参不刷新 */
@Component
export struct MineStatCell {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop label: string = ''
  @Prop valueText: string = '0'
  onTap: () => void = (): void => {}

  build() {
    Column() {
      Text(this.valueText)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.of(this.darkModeOn).brandPrimary)
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.of(this.darkModeOn).textSecondary)
    }
    .constraintSize({ minHeight: 48 })
    .onClick((): void => { this.onTap() })
    .gesture(
      TapGesture({ count: 1 }).onAction((): void => { this.onTap() })
    )
  }
}
