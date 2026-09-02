import { Theme } from '../design-system/Theme'
import { MoodCatalog, MoodOption } from '../../services/MoodCatalog'

@Component
export struct MoodSelector {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedId: string = ''
  onSelect: (id: string) => void = () => {}

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(MoodCatalog.all(), (m: MoodOption) => {
        Column({ space: 4 }) {
          Text(m.emoji)
            .fontSize(18)
          Text(m.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.selectedId === m.id ?
              Theme.colors().brandPrimary : Theme.colors().textSecondary)
        }
        .width('30%')
        .padding({ top: 10, bottom: 10 })
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(this.selectedId === m.id ?
          Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .border({
          width: this.selectedId === m.id ? 1.5 : 0,
          color: Theme.colors().brandPrimary
        })
        .margin({ right: '3%', bottom: Theme.space.s2 })
        .onClick((): void => { this.onSelect(m.id) })
      }, (m: MoodOption) => m.id)
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
