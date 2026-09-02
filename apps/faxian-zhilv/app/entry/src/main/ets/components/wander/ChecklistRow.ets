import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct ChecklistRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop @Watch('onDoneChange') done: boolean = false
  @State checked: boolean = false
  onToggle: () => void = () => {}
  onRemove: () => void = () => {}

  aboutToAppear(): void {
    this.checked = this.done
  }

  onDoneChange(): void {
    this.checked = this.done
  }

  private tapToggle(): void {
    this.checked = !this.checked
    this.onToggle()
  }

  build() {
    Row({ space: 12 }) {
      Column() {
        if (this.checked) {
          AppIcon({
            name: 'check',
            iconSize: Theme.icon.sm,
            color: Theme.colors().brandOnPrimary
          })
        }
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.checked ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .border({
        width: this.checked ? 0 : 1,
        color: Theme.colors().strokeStrong
      })
      .scale({ x: this.checked ? 1 : 0.96, y: this.checked ? 1 : 0.96 })
      .animation({ duration: 220, curve: Curve.EaseOut })
      .onClick(() => this.tapToggle())

      Text(this.label)
        .fontSize(Theme.type.body)
        .fontColor(this.checked ? Theme.colors().textTertiary : Theme.colors().textPrimary)
        .decoration({ type: this.checked ? TextDecorationType.LineThrough : TextDecorationType.None })
        .layoutWeight(1)
        .onClick(() => this.tapToggle())

      Text('删除')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .padding({ left: 8, right: 4, top: 8, bottom: 8 })
        .onClick(() => this.onRemove())
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
