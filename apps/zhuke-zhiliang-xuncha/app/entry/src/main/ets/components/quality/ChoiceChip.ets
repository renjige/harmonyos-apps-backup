import { Theme } from '../design-system/Theme'

/** 可点选芯片：选中态走 @Prop active，点击立即反馈，避免 @Builder 参数不刷新 */
@Component
export struct ChoiceChip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop active: boolean = false
  @State pressed: boolean = false
  onPick: () => void = () => {}

  build() {
    Text(this.label)
      .fontSize(Theme.type.footnote)
      .fontWeight(this.active ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.active ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.active ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(12)
      .border({
        width: this.active ? 0 : 1,
        color: Theme.colors().strokeHairline
      })
      .opacity(this.pressed ? 0.82 : 1)
      .scale({ x: this.pressed ? 0.96 : 1, y: this.pressed ? 0.96 : 1 })
      .animation({ duration: Theme.motion.instant, curve: Curve.EaseOut })
      .onTouch((e: TouchEvent) => {
        if (e.type === TouchType.Down) {
          this.pressed = true
        }
        if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
          this.pressed = false
        }
      })
      .onClick(() => this.onPick())
  }
}

@Component
export struct ChipSelectGroup {
  @Prop title: string = ''
  @Prop options: string[] = []
  @Link selected: string
  onPicked: (value: string) => void = (_value: string) => {}

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.options, (opt: string) => {
          ChoiceChip({
            label: opt,
            active: this.selected === opt,
            onPick: () => {
              this.selected = opt
              this.onPicked(opt)
            }
          })
        }, (opt: string) => `${this.title}-${opt}-${this.selected}`)
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
