import { Theme } from '../design-system/Theme'

@Component
export struct LifeTagChips {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop tags: string[] = []
  @Prop compact: boolean = false
  onTagTap: (tag: string) => void = () => {}

  build() {
    Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
      ForEach(this.tags, (tag: string) => {
        Text(tag)
          .fontSize(this.compact ? Theme.type.caption : Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({
            left: this.compact ? 6 : 10,
            right: this.compact ? 6 : 10,
            top: this.compact ? 2 : 4,
            bottom: this.compact ? 2 : 4
          })
          .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.onTagTap(tag) })
      }, (tag: string) => tag)
    }
    .width('100%')
  }
}
