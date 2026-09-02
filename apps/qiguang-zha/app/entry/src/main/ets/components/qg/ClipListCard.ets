import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { QgClip, QgLabels } from '../../models/QgModels'

@Component
export struct ClipListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: QgClip = new QgClip()
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({
          name: this.item.treasured ? 'heart' : 'sparkle',
          iconSize: Theme.icon.md,
          color: Theme.colors().brandAccent
        })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      Column({ space: 4 }) {
        Text(QgLabels.clipKindLabel(this.item.clipKind))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
        Text(this.item.text)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(3)
          .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.onOpen() })
  }
}
