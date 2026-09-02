import { Theme } from '../design-system/Theme'
import { GrowthMedia } from '../../services/GrowthMedia'

@Component
export struct CoverPicker {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedKey: string = ''
  onSelect: (key: string) => void = () => {}
  @State keys: string[] = GrowthMedia.recordCoverKeys()

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('选择封面')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.keys, (key: string) => {
          Column() {
            Image(GrowthMedia.coverMedia(key))
              .width(72)
              .height(72)
              .borderRadius(Theme.radius.lg)
              .objectFit(ImageFit.Cover)
              .border({
                width: this.selectedKey === key ? 2 : 1,
                color: this.selectedKey === key ?
                  Theme.colors().brandPrimary : Theme.colors().strokeHairline
              })
          }
          .margin({ right: 8, bottom: 8 })
          .onClick((): void => { this.onSelect(key) })
        }, (key: string) => key)
      }
      .width('100%')
    }
    .width('100%')
  }
}
