import { Theme } from '../design-system/Theme'

@Component
export struct CategoryChips {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop labels: string[] = []
  @Prop keys: string[] = []
  @Prop selectedKey: string = ''
  @Prop showAll: boolean = true
  onSelect: (key: string) => void = () => {}

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        if (this.showAll) {
          this.Chip('全部', '')
        }
        ForEach(this.keys, (key: string, index: number) => {
          this.Chip(this.labels[index], key)
        }, (key: string) => key)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  Chip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.selectedKey === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.selectedKey === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.onSelect(key) })
  }
}
