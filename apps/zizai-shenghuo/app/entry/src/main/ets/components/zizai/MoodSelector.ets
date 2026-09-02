import { Theme } from '../design-system/Theme'
import { MoodOption } from '../../models/ZizaiModels'

@Component
export struct MoodSelector {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedKey: string = '3'
  onSelect: (key: string) => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      ForEach(MoodOption.all(), (m: MoodOption) => {
        Column({ space: 4 }) {
          Text(m.emoji)
            .fontSize(28)
          Text(m.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.selectedKey === m.key ?
              Theme.colors().brandPrimary : Theme.colors().textSecondary)
        }
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .backgroundColor(this.selectedKey === m.key ?
          Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { this.onSelect(m.key) })
      }, (m: MoodOption) => m.key)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
