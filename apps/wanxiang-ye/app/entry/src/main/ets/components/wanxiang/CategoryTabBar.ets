import { Theme } from '../design-system/Theme'
import { InfoCategory } from '../../models/InfoModels'

@Component
export struct CategoryTabBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop categories: InfoCategory[] = InfoCategory.all()
  @Prop selectedKey: string = 'recommend'
  onSelect: (key: string) => void = () => {}

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(this.categories, (cat: InfoCategory) => {
          Column({ space: 6 }) {
            Text(`${cat.emoji} ${cat.label}`)
              .fontSize(Theme.type.bodyS)
              .fontWeight(this.selectedKey === cat.key ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(this.selectedKey === cat.key ?
                Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 16, right: 16, top: 10, bottom: 8 })
              .backgroundColor(this.selectedKey === cat.key ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .border({
                width: this.selectedKey === cat.key ? 0 : 1,
                color: Theme.colors().strokeStrong
              })
              .onClick((): void => this.onSelect(cat.key))

            Row()
              .width(this.selectedKey === cat.key ? 20 : 0)
              .height(3)
              .backgroundColor('#FF9500')
              .borderRadius(Theme.radius.pill)
              .opacity(this.selectedKey === cat.key ? 1 : 0)
          }
        }, (cat: InfoCategory) => cat.key)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }
}
