import { Theme } from '../design-system/Theme'
import { MoodOption } from '../../models/DailyModels'

@Component
export struct MoodPicker {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop options: MoodOption[] = []
  @Prop selectedKey: string = ''
  onSelect: (key: string, label: string) => void = () => {}

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(this.options, (opt: MoodOption) => {
        Column({ space: 4 }) {
          Text(opt.emoji)
            .fontSize(28)
          Text(opt.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.selectedKey === opt.key ?
              Theme.colors().brandPrimary : Theme.colors().textSecondary)
        }
        .width('30%')
        .padding(Theme.space.s3)
        .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
        .backgroundColor(this.selectedKey === opt.key ?
          Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)
        .border({
          width: this.selectedKey === opt.key ? 2 : 1,
          color: this.selectedKey === opt.key ?
            Theme.colors().brandPrimary : Theme.colors().strokeHairline
        })
        .onClick(() => this.onSelect(opt.key, opt.label))
      }, (opt: MoodOption) => opt.key)
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
