import { Theme } from '../design-system/Theme'
import { MoodCatalog, MoodOption } from '../../services/MoodCatalog'

@Component
export struct MoodSelector {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selected: string = 'calm'
  onSelect: (id: string) => void = () => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      ForEach(MoodCatalog.all(), (m: MoodOption) => {
        Column({ space: 4 }) {
          Text(m.emoji)
            .fontSize(22)
          Text(m.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.selected === m.id ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
        }
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .backgroundColor(this.selected === m.id ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({
          width: this.selected === m.id ? 2 : 1,
          color: this.selected === m.id ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
        })
        .onClick((): void => { this.onSelect(m.id) })
      }, (m: MoodOption) => m.id)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
