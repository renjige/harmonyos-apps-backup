import { Theme } from '../design-system/Theme'
import { SportCategory } from '../../models/MatchModels'

@Component
export struct SportCategoryChips {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedKey: string = ''
  onSelect: (key: string) => void = () => {}
  private categories: SportCategory[] = SportCategory.all()

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(this.categories, (cat: SportCategory) => {
          Text(cat.label)
            .fontSize(Theme.type.subhead)
            .fontWeight(this.selectedKey === cat.key ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selectedKey === cat.key ?
              Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.selectedKey === cat.key ?
              Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.onSelect(cat.key) })
        }, (cat: SportCategory) => cat.key.length > 0 ? cat.key : 'hot')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
