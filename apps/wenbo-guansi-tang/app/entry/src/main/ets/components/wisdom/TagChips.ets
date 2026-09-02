import { Theme } from '../design-system/Theme'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct TagChips {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selected: string = '全部'
  @Prop options: string[] = []
  onSelect: (name: string) => void = () => {}

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(this.options, (name: string) => {
          Text(CategoryEmojiUtil.chipLabel(name))
            .fontSize(Theme.type.caption)
            .fontColor(this.selected === name ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.selected === name ?
              Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .border({
              width: 1,
              color: this.selected === name ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
            })
            .onClick((): void => { this.onSelect(name) })
        }, (name: string) => name)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
