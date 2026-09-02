import { Theme } from '../design-system/Theme'

@Component
export struct CategoryChips {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selected: string = '全部'
  @Prop options: string[] = []
  onSelect: (name: string) => void = (_n: string) => {}

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(this.options, (name: string) => {
          Text(name)
            .fontSize(Theme.type.caption)
            .fontWeight(this.selected === name ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selected === name ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .height(32)
            .padding({ left: 12, right: 12 })
            .textAlign(TextAlign.Center)
            .backgroundColor(this.selected === name ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.onSelect(name) })
        }, (name: string) => name)
      }
      .height(32)
      .padding({ right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(36)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
