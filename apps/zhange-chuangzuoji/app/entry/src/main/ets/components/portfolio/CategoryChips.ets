import { Theme } from '../design-system/Theme'
import { PortfolioCategory } from '../../models/PortfolioModels'

@Component
export struct CategoryChips {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedId: string = 'all'
  @Prop includeAll: boolean = true
  onSelect: (id: string) => void = () => {}
  private categories: PortfolioCategory[] = PortfolioCategory.all()

  private visibleCategories(): PortfolioCategory[] {
    const rows: PortfolioCategory[] = []
    for (const cat of this.categories) {
      if (!this.includeAll && cat.id === 'all') {
        continue
      }
      rows.push(cat)
    }
    return rows
  }

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(this.visibleCategories(), (cat: PortfolioCategory) => {
          Text(cat.label)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.selectedId === cat.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor(this.selectedId === cat.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick(() => {
              this.onSelect(cat.id)
            })
        }, (cat: PortfolioCategory) => cat.id)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(44)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
