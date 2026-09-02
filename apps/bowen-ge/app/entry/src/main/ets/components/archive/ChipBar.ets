import { Theme } from '../design-system/Theme'
import { LabelOption } from '../../models/BowenModels'

@Component
export struct ChipBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: string = 'cat'
  @Prop selected: string = ''
  onSelect: (key: string) => void = () => {}

  private opts(): LabelOption[] {
    if (this.mode === 'kind') {
      return LabelOption.thoughtKinds()
    }
    if (this.mode === 'status') {
      return LabelOption.statuses()
    }
    if (this.mode === 'source') {
      return LabelOption.sources()
    }
    if (this.mode === 'spark') {
      return LabelOption.sparkKinds()
    }
    if (this.mode === 'favtier') {
      return LabelOption.favoriteTiers()
    }
    if (this.mode === 'cardsource') {
      return LabelOption.cardSources()
    }
    return LabelOption.categories()
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.opts(), (o: LabelOption) => {
        Text(o.label)
          .fontSize(Theme.type.caption)
          .fontColor(this.selected === o.key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .margin({ right: 8, bottom: 8 })
          .backgroundColor(this.selected === o.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.onSelect(o.key) })
      }, (o: LabelOption) => o.key)
    }
    .width('100%')
  }
}
