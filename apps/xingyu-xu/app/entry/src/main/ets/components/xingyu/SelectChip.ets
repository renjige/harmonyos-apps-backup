import { Theme } from '../design-system/Theme'

/** 可选芯片：用 @Component 承接点击，避免 @Builder 传 onTap 失效 */
@Component
export struct SelectChip {
  @Prop label: string = ''
  @Prop active: boolean = false
  onSelect: () => void = () => {}

  build() {
    Text(this.label)
      .fontSize(Theme.type.caption)
      .fontWeight(this.active ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.active ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.active ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.onSelect()
      })
  }
}
