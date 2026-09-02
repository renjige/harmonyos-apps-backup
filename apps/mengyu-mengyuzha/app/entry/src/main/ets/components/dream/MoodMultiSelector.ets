import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MoodCatalog, MoodOption } from '../../services/MoodCatalog'

@Component
export struct MoodMultiSelector {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedCsv: string = ''
  onToggle: (id: string) => void = (_id: string) => {}

  private isOn(id: string): boolean {
    return MoodCatalog.parseEmotions(this.selectedCsv).indexOf(id) >= 0
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(MoodCatalog.all(), (m: MoodOption) => {
        Row({ space: 6 }) {
          AppIcon({
            name: m.icon,
            iconSize: 16,
            color: this.isOn(m.id) ? Theme.colors().brandOnPrimary : m.color
          })
          Text(m.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.isOn(m.id) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .margin({ right: 8, bottom: 8 })
        .backgroundColor(this.isOn(m.id) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.onToggle(m.id) })
      }, (m: MoodOption) => m.id)
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
