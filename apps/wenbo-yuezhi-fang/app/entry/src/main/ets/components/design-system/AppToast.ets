import { Theme } from './Theme'

/** 顶部 Toast：深浅色高对比，zIndex 置顶，绑定 themeEpoch 实时刷新 */
@Component
export struct AppToast {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop message: string = ''
  @Prop marginTop: number = 72

  build() {
    Column() {
      Text(this.message)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.toastInk(this.themeEpoch))
        .padding({ left: 18, right: 18, top: 12, bottom: 12 })
        .backgroundColor(Theme.toastFill(this.themeEpoch))
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.toastBorder(this.themeEpoch) })
        .maxLines(4)
        .textAlign(TextAlign.Center)
        .constraintSize({ maxWidth: '92%' })
    }
    .width('100%')
    .padding({
      top: this.marginTop,
      left: Theme.space.pageX,
      right: Theme.space.pageX
    })
    .alignItems(HorizontalAlign.Center)
    .zIndex(1000)
    .hitTestBehavior(HitTestMode.None)
  }
}
