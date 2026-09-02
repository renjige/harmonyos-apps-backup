import { Theme } from '../design-system/Theme'

@Component
export struct RichTextToolbar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onAction: (kind: string) => void = () => {}

  @Builder
  ToolButton(label: string, kind: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.bodyS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .height(36)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.sm)
    .onClick((): void => {
      this.onAction(kind)
    })
  }

  build() {
    Row({ space: Theme.space.s2 }) {
      this.ToolButton('粗体', 'bold')
      this.ToolButton('斜体', 'italic')
      this.ToolButton('列表', 'list')
    }
    .width('100%')
  }
}
