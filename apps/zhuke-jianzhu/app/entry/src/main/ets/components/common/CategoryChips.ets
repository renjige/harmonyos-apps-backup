import { Theme } from '../design-system/Theme'
import { CategoryTab } from '../../models/ZhukeModels'

@Component
export struct CategoryChips {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop tabs: CategoryTab[] = []
  @Prop selected: string = 'all'
  onSelect: (key: string) => void = (_key: string) => {}

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(this.tabs, (tab: CategoryTab) => {
          Text(tab.label)
            .fontSize(Theme.type.footnote)
            .fontColor(this.selected === tab.key ?
              Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .fontWeight(this.selected === tab.key ? FontWeight.Medium : FontWeight.Normal)
            .padding({
              left: Theme.space.s3,
              right: Theme.space.s3,
              top: Theme.space.s2,
              bottom: Theme.space.s2
            })
            .backgroundColor(this.selected === tab.key ?
              Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .border({
              width: 1,
              color: this.selected === tab.key ?
                Theme.colors().brandPrimary : Theme.colors().strokeHairline
            })
            .onClick(() => this.onSelect(tab.key))
        }, (tab: CategoryTab) => tab.key)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
