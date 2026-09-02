import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MoodCatalog, MoodOption } from '../../services/MoodCatalog'

@Component
export struct MoodSelector {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selected: string = ''
  onSelect: (id: string) => void = (_id: string) => {}

  build() {
    Row() {
      ForEach(MoodCatalog.all(), (m: MoodOption) => {
        Column({ space: 6 }) {
          Column() {
            AppIcon({
              name: m.icon,
              iconSize: 22,
              color: this.selected === m.id ? Theme.colors().brandOnPrimary : m.color
            })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.selected === m.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          Text(m.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.selected === m.id ? Theme.colors().textPrimary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding({ top: 4, bottom: 4 })
        .onClick((): void => { this.onSelect(m.id) })
      }, (m: MoodOption) => m.id)
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
